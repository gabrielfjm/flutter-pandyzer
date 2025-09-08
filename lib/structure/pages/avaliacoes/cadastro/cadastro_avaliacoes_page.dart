import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// CORE
import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/core/app_data_operations.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';

// MODELS
import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Status.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

// SERVICES (usamos direto os services atuais)
import 'package:flutter_pandyzer/structure/http/services/avaliacao_service.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliador_service.dart';
import 'package:flutter_pandyzer/structure/http/services/objetivo_service.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';
import 'package:flutter_pandyzer/structure/http/services/status_service.dart';

// LIST PAGE
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';

// WIDGETS
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_data_picker_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_dropdown.dart';
import 'package:flutter_pandyzer/structure/widgets/app_objectives.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';

import 'modal/app_avaliadores_select.dart';

/// Máscara simples para datas no formato dd/MM/yyyy
class DateMaskTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// Aceita apenas dígitos
class DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    return TextEditingValue(text: digits, selection: TextSelection.collapsed(offset: digits.length));
  }
}

class CadastroAvaliacaoPage extends StatefulWidget {
  final int? editarAvaliacaoId;
  const CadastroAvaliacaoPage({super.key, this.editarAvaliacaoId});

  @override
  State<CadastroAvaliacaoPage> createState() => _CadastroAvaliacaoPageState();
}

class _CadastroAvaliacaoPageState extends State<CadastroAvaliacaoPage> {
  final _descricaoController = TextEditingController();
  final _linkController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _limitController = TextEditingController();

  bool _isPublic = false;

  List<ApplicationType> _dominios = [];
  ApplicationType? _dominioSelecionado;
  List<User> _avaliadoresDisponiveis = [];
  List<User> _avaliadoresSelecionados = [];
  List<String> _objetivos = [];

  bool _loadingTela = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _linkController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  // ===== Helpers HTTP locais para endpoints simples =====
  Future<List<ApplicationType>> _fetchApplicationTypes() async {
    // Controller: /applicationtype
    final resp = await HttpClient.get('/applicationtype');
    if (resp.statusCode == 200) {
      final list = (jsonDecode(resp.body) as List)
          .map((e) => ApplicationType.fromJson(e))
          .toList();
      return list;
    }
    throw Exception('Erro ao buscar tipos de aplicação: ${resp.statusCode}');
  }

  Future<List<User>> _fetchEvaluatorUsers() async {
    // Backend (users): use a rota em inglês
    // Ajuste aqui caso sua rota seja diferente:
    // ex.: GET /users/evaluators
    final resp = await HttpClient.get('/users/evaluators');
    if (resp.statusCode == 200) {
      final list = (jsonDecode(resp.body) as List)
          .map((e) => User.fromJson(e))
          .toList();
      return list;
    }
    // Deixa explícito o status para facilitar debug
    throw Exception('Erro ao buscar usuários avaliadores: ${resp.statusCode}');
  }

  Future<void> _bootstrap() async {
    try {
      final now = DateTime.now();
      final fmt = DateFormat('dd/MM/yyyy');
      _startDateController.text = fmt.format(now);
      _endDateController.text = fmt.format(now.add(const Duration(days: 7)));

      final results = await Future.wait([
        _fetchApplicationTypes(),
        _fetchEvaluatorUsers(),
      ]);

      _dominios = results[0] as List<ApplicationType>;
      _avaliadoresDisponiveis = results[1] as List<User>;
      if (_dominios.isNotEmpty) _dominioSelecionado = _dominios.first;

      if (widget.editarAvaliacaoId != null) {
        await _carregarDetalhes(widget.editarAvaliacaoId!);
      }
    } catch (e) {
      showAppToast(context: context, message: e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loadingTela = false);
    }
  }

  void _onPublicChanged(bool v) {
    setState(() {
      _isPublic = v;
      if (_isPublic) {
        final current = int.tryParse(_limitController.text.trim()) ?? 0;
        if (current <= 0) _limitController.text = '1';
      } else {
        _limitController.text = '';
      }
    });
  }

  int _parsedLimit() => int.tryParse(_limitController.text.trim()) ?? 0;

  Future<void> _carregarDetalhes(int id) async {
    final results = await Future.wait([
      AvaliacaoService.getById(id),
      ObjetivoService.getObjetivoByIdAvaliacao(id),
      AvaliadorService.getByEvaluation(id),
    ]);

    final Evaluation eva = results[0] as Evaluation;
    final objectives = results[1] as List<Objective>;
    final evaluators = results[2] as List<Evaluator>;

    _descricaoController.text = eva.description ?? '';
    _linkController.text = eva.link ?? '';
    _startDateController.text = AppConvert.convertIsoDateToFormattedDate(eva.startDate);
    _endDateController.text = AppConvert.convertIsoDateToFormattedDate(eva.finalDate);

    final targetId = eva.applicationType?.id;
    if (targetId != null) {
      final i = _dominios.indexWhere((d) => d.id == targetId);
      if (i >= 0) _dominioSelecionado = _dominios[i];
    }

    _objetivos = objectives
        .map((o) => o.description ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    _avaliadoresSelecionados =
        evaluators.map((e) => e.user).whereType<User>().toList();

    _isPublic = eva.isPublic;
    if ((eva.evaluatorsLimit ?? 0) > 0) {
      _limitController.text = (eva.evaluatorsLimit!).toString();
    }
  }

  Future<void> _salvar() async {
    // Validações básicas
    if (_descricaoController.text.trim().isEmpty) {
      showAppToast(context: context, message: 'Título é obrigatório', isError: true);
      return;
    }
    if (_linkController.text.trim().isEmpty) {
      showAppToast(context: context, message: AppStrings.mensagemLinkEstaVazio, isError: true);
      return;
    }
    if (_dominioSelecionado == null) {
      showAppToast(context: context, message: AppStrings.dominio, isError: true);
      return;
    }
    if (_objetivos.isEmpty) {
      showAppToast(context: context, message: AppStrings.mensagemObjetivos, isError: true);
      return;
    }

    // Limite / Público
    final int limit = _parsedLimit();
    if (_isPublic && limit <= 0) {
      showAppToast(
        context: context,
        message: 'Defina um limite de avaliadores > 0 para avaliações públicas.',
        isError: true,
      );
      return;
    }
    final bool isPublicFinal = _isPublic && limit > 0;

    // Datas
    final msgDatas = validarDatas(
      _startDateController.text.trim(),
      _endDateController.text.trim(),
    );
    if (msgDatas.isNotEmpty) {
      showAppToast(context: context, message: msgDatas, isError: true);
      return;
    }

    setState(() => _salvando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) throw Exception('Usuário não autenticado.');

      final creator = await UsuarioService.getUsuarioById(int.parse(userId));
      final nowIso = DateTime.now().toIso8601String();

      // Seleção de avaliadores
      final selecionados = List<User>.from(_avaliadoresSelecionados);
      if (selecionados.isEmpty && (creator.userType?.description == 'Avaliador')) {
        selecionados.add(creator);
      }

      if (widget.editarAvaliacaoId == null) {
        // ============== CREATE ==============
        final avaliacao = Evaluation(
          description: _descricaoController.text.trim(),
          link: _linkController.text.trim(),
          startDate: AppConvert.convertDateToIso(_startDateController.text.trim()),
          finalDate: AppConvert.convertDateToIso(_endDateController.text.trim()),
          applicationType: _dominioSelecionado,
          user: creator,
          register: nowIso,
          isPublic: isPublicFinal,
          evaluatorsLimit: isPublicFinal ? limit : 0,
        );

        final criada = await AvaliacaoService.insert(avaliacao);

        // Objetivos
        for (final desc in _objetivos) {
          await ObjetivoService.postObjetivo(
            Objective(description: desc, evaluation: criada, register: nowIso),
          );
        }

        // Avaliadores -> status 3 no cadastro
        final Status statusCreate = await StatusService.getById(3);
        for (final av in selecionados) {
          await AvaliadorService.create(
            Evaluator(user: av, evaluation: criada, register: nowIso, status: statusCreate),
          );
        }
      } else {
        // ============== UPDATE ==============
        final avaliacao = Evaluation(
          id: widget.editarAvaliacaoId,
          description: _descricaoController.text.trim(),
          link: _linkController.text.trim(),
          startDate: AppConvert.convertDateToIso(_startDateController.text.trim()),
          finalDate: AppConvert.convertDateToIso(_endDateController.text.trim()),
          applicationType: _dominioSelecionado,
          user: creator,
          register: nowIso,
          isPublic: isPublicFinal,
          evaluatorsLimit: isPublicFinal ? limit : 0,
        );
        await AvaliacaoService.update(avaliacao.id!, avaliacao);

        // Objetivos (apaga e recria)
        final antigosObjs = await ObjetivoService.getObjetivoByIdAvaliacao(widget.editarAvaliacaoId!);
        for (final o in antigosObjs) {
          if (o.id != null) await ObjetivoService.deleteObjetivo(o.id!);
        }
        for (final desc in _objetivos) {
          await ObjetivoService.postObjetivo(
            Objective(description: desc, evaluation: avaliacao, register: nowIso),
          );
        }

        // Avaliadores (preserva status do que já existe)
        final antigosAvals = await AvaliadorService.getByEvaluation(widget.editarAvaliacaoId!);
        final existingByUserId = <int, Evaluator>{};
        for (final ev in antigosAvals) {
          final uid = ev.user?.id;
          if (uid != null) existingByUserId[uid] = ev;
        }
        final desiredIds = selecionados.map((u) => u.id).whereType<int>().toSet();
        final existingIds = existingByUserId.keys.toSet();
        final toAdd = desiredIds.difference(existingIds);
        final toRemove = existingIds.difference(desiredIds);

        for (final uid in toRemove) {
          final ev = existingByUserId[uid];
          if (ev != null && ev.id != null) {
            await AvaliadorService.delete(ev.id!);
          }
        }

        final Status statusAdd = await StatusService.getById(3);
        for (final uid in toAdd) {
          final user = selecionados.firstWhere((u) => u.id == uid);
          await AvaliadorService.create(
            Evaluator(user: user, evaluation: avaliacao, register: nowIso, status: statusAdd),
          );
        }
      }

      if (!mounted) return;
      showAppToast(context: context, message: 'Operação realizada com sucesso!');
      NavigationManager().goTo(const AvaliacoesPage());
    } catch (e) {
      if (!mounted) return;
      showAppToast(context: context, message: e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          if (_loadingTela)
            const Center(child: AppLoading(color: AppColors.black))
          else
            Padding(
              padding: const EdgeInsets.all(AppSpacing.big),
              child: appContainer(
                width: 1600,
                padding: const EdgeInsets.all(AppSpacing.big),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: AppColors.black),
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                ),
                child: LayoutBuilder(
                  builder: (_, c) {
                    final isWide = c.maxWidth >= 1200;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            appText(
                              text: widget.editarAvaliacaoId == null
                                  ? AppStrings.cadastrarAvaliacao
                                  : 'Editar ${AppStrings.avaliacao}',
                              fontSize: AppFontSize.fs28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ],
                        ),
                        appSizedBox(height: AppSpacing.big),

                        // Content scroll
                        Expanded(
                          child: SingleChildScrollView(
                            child: _FormGrid(
                              isWide: isWide,
                              descricaoController: _descricaoController,
                              linkController: _linkController,
                              startDateController: _startDateController,
                              endDateController: _endDateController,
                              dominioSelecionado: _dominioSelecionado,
                              dominios: _dominios,
                              onChangeDominio: (v) => setState(() => _dominioSelecionado = v),
                              isPublic: _isPublic,
                              onPublicChanged: _onPublicChanged,
                              limitController: _limitController,
                              objetivos: _objetivos,
                              onAddObjetivo: (s) => setState(() => _objetivos.add(s)),
                              onRemoveObjetivo: (s) => setState(() => _objetivos.remove(s)),
                              avaliadoresDisponiveis: _avaliadoresDisponiveis,
                              avaliadoresSelecionados: _avaliadoresSelecionados,
                              onChangeAvaliadores: (list) => setState(() => _avaliadoresSelecionados = list),
                            ),
                          ),
                        ),

                        // Footer actions
                        Row(
                          children: [
                            const Spacer(),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(140, 48),
                                side: const BorderSide(color: Colors.black, width: 1.5),
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => NavigationManager().goTo(const AvaliacoesPage()),
                              child: const Text('Voltar'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(140, 48),
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _salvar,
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          if (_salvando)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.06),
                alignment: Alignment.center,
                child: const AppLoading(color: AppColors.black),
              ),
            ),
        ],
      ),
    );
  }
}

/// ------- GRID + CARDS (somente UI) -------

class _FormGrid extends StatelessWidget {
  final bool isWide;

  // Basics
  final TextEditingController descricaoController;
  final TextEditingController linkController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;

  // Domínio
  final ApplicationType? dominioSelecionado;
  final List<ApplicationType> dominios;
  final ValueChanged<ApplicationType?> onChangeDominio;

  // Configurações
  final bool isPublic;
  final ValueChanged<bool> onPublicChanged;
  final TextEditingController limitController;

  // Objetivos
  final List<String> objetivos;
  final ValueChanged<String> onAddObjetivo;
  final ValueChanged<String> onRemoveObjetivo;

  // Avaliadores
  final List<User> avaliadoresDisponiveis;
  final List<User> avaliadoresSelecionados;
  final ValueChanged<List<User>> onChangeAvaliadores;

  const _FormGrid({
    required this.isWide,
    required this.descricaoController,
    required this.linkController,
    required this.startDateController,
    required this.endDateController,
    required this.dominioSelecionado,
    required this.dominios,
    required this.onChangeDominio,
    required this.isPublic,
    required this.onPublicChanged,
    required this.limitController,
    required this.objetivos,
    required this.onAddObjetivo,
    required this.onRemoveObjetivo,
    required this.avaliadoresDisponiveis,
    required this.avaliadoresSelecionados,
    required this.onChangeAvaliadores,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isWide ? 2 : 1;
    final gap = AppSpacing.big.toDouble();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _SectionCard(
              title: 'Informações básicas',
              icon: AppIcons.info,
              width: _cellWidth(crossAxisCount),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Título da Avaliação',
                    controller: descricaoController,
                    width: double.infinity,
                  ),
                  appSizedBox(height: AppSpacing.medium),
                  AppTextField(
                    label: AppStrings.linkDaInterface,
                    controller: linkController,
                    width: double.infinity,
                  ),
                  appSizedBox(height: AppSpacing.medium),
                  Row(
                    children: [
                      Expanded(
                        child: AppDatePickerField(
                          label: AppStrings.dataInicial,
                          controller: startDateController,
                          width: double.infinity,
                          inputFormatters: [DateMaskTextInputFormatter()],
                          keyboardType: TextInputType.number,
                          openPickerOnTap: false,
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: AppDatePickerField(
                          label: AppStrings.dataFinal,
                          controller: endDateController,
                          width: double.infinity,
                          inputFormatters: [DateMaskTextInputFormatter()],
                          keyboardType: TextInputType.number,
                          openPickerOnTap: false,
                        ),
                      ),
                    ],
                  ),
                  appSizedBox(height: AppSpacing.medium),
                  AppDropdown<ApplicationType>(
                    label: AppStrings.dominio,
                    value: dominioSelecionado,
                    items: dominios,
                    itemLabelBuilder: (d) => d.description ?? 'Domínio',
                    onChanged: onChangeDominio,
                    width: double.infinity,
                    hintText: AppStrings.dominio,
                  ),
                ],
              ),
            ),

            _SectionCard(
              title: AppStrings.objetivos,
              icon: AppIcons.checklist,
              width: _cellWidth(crossAxisCount),
              child: AppObjectivesField(
                objectives: objetivos,
                onAdd: onAddObjetivo,
                onRemove: onRemoveObjetivo,
                width: double.infinity,
              ),
            ),

            _SectionCard(
              title: 'Avaliadores',
              icon: AppIcons.users,
              width: _cellWidth(crossAxisCount),
              child: AppAvaliadoresSelector(
                availableEvaluators: avaliadoresDisponiveis,
                selectedEvaluators: avaliadoresSelecionados,
                onSelectionChanged: onChangeAvaliadores,
              ),
            ),

            _SectionCard(
              title: 'Configurações',
              icon: AppIcons.settings,
              width: _cellWidth(crossAxisCount),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Avaliação pública'),
                    value: isPublic,
                    onChanged: onPublicChanged,
                  ),
                  if (isPublic) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 260,
                        child: AppTextField(
                          label: 'Limite de avaliadores',
                          controller: limitController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [DigitsOnlyFormatter()],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _cellWidth(int crossAxisCount) {
    final max = 1200.0;
    return crossAxisCount == 2 ? (max - AppSpacing.big) / 2 : max;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final double width;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.s10),
        border: Border.all(color: AppColors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.black),
              const SizedBox(width: 8),
              appText(
                text: title,
                fontWeight: FontWeight.w600,
                fontSize: AppFontSize.fs18,
                color: AppColors.black,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 24, thickness: 1, color: Colors.black12),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
