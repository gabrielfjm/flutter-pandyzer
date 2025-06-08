import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_event.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_state.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_data_picker_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_dropdown.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_objectives.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';
import 'package:intl/intl.dart';
import 'modal/app_avaliadores_select.dart';

class CadastroAvaliacoesPage extends StatefulWidget {
  final AvaliacoesBloc bloc;
  final int? evaluationId;

  const CadastroAvaliacoesPage({
    required this.bloc,
    this.evaluationId,
    super.key,
  });

  @override
  State<CadastroAvaliacoesPage> createState() => _CadastroAvaliacoesPageState();
}

class _CadastroAvaliacoesPageState extends State<CadastroAvaliacoesPage> {
  bool get _isEditMode => widget.evaluationId != null;

  late AppTextField descricaoField;
  late AppTextField linkField;
  late AppDatePickerField dataInicialField;
  late AppDatePickerField dataFinalField;
  late AppAvaliadoresSelector avaliadoresButton;

  final _descricaoController = TextEditingController();
  final _linkController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  List<String> _objectives = <String>[];
  ApplicationType? _selectedDominio;
  final List<String> _avaliadores = <String>[];
  late List<ApplicationType> _dominios = [];

  void _onChangeState(AvaliacoesState state) {
    if (state is AvaliacaoCamposLoaded) {
      setState(() {
        _dominios = state.dominios;
      });
    }

    if (state is EvaluationDetailsLoaded) {
      final eval = state.evaluation;
      if (eval != null) {
        _descricaoController.text = eval.description ?? '';
        _linkController.text = eval.link ?? '';
        _startDateController.text = AppConvert.convertIsoDateToFormattedDate(eval.startDate);
        _endDateController.text = AppConvert.convertIsoDateToFormattedDate(eval.finalDate);
        setState(() {
          _dominios = state.dominios;

          ApplicationType? foundDominio;
          try {
            foundDominio = _dominios.firstWhere(
                  (d) => d.id == eval.applicationType?.id,
            );
          } catch (e) {
            foundDominio = null;
          }
          _selectedDominio = foundDominio;
          _objectives = state.objectives.map((o) => o.description ?? '').toList();
        });
      }
    }

    if (state is AvaliacaoCadastrada) {
      showAppToast(context: context, message: 'Avaliação cadastrada com sucesso!');
      NavigationManager().goTo(const AvaliacoesPage());
    }

    if (state is AvaliacaoUpdated) {
      showAppToast(context: context, message: 'Avaliação atualizada com sucesso!');
      NavigationManager().goTo(const AvaliacoesPage());
    }

    if (state is AvaliacoesError) {
      showAppToast(context: context, message: AppStrings.mensagemDeErro, isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      widget.bloc.add(LoadEvaluationDetailsEvent(widget.evaluationId!));
    } else {
      widget.bloc.add(LoadCamposCadastroAvaliacao());
    }

    descricaoField = AppTextField(
      label: AppStrings.descricao,
      controller: _descricaoController,
      width: double.infinity,
    );
    linkField = AppTextField(
      label: AppStrings.linkDaInterface,
      controller: _linkController,
      width: double.infinity,
    );
    dataInicialField = AppDatePickerField(
      label: AppStrings.dataInicial,
      controller: _startDateController,
      width: double.infinity,
    );
    dataFinalField = AppDatePickerField(
      label: AppStrings.dataFinal,
      controller: _endDateController,
      width: double.infinity,
    );
    avaliadoresButton = AppAvaliadoresSelector(
      onSelected: (selected) => setState(() => _avaliadores.addAll(selected)),
      avaliadores: _avaliadores,
    );

    _setDefaultDates();
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final formatter = DateFormat('dd/MM/yyyy');

    _startDateController.text = formatter.format(now);
    _endDateController.text = formatter.format(lastDayOfMonth);
  }

  void _voltar() {
    NavigationManager().goTo(const AvaliacoesPage());
  }

  void _salvar() {
    if (_descricaoController.text.isEmpty ||
        _linkController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _selectedDominio == null ||
        _objectives.isEmpty) {
      showAppToast(context: context, message: "Todos os campos são obrigatórios.", isError: true);
      return;
    }

    final formatter = DateFormat('dd/MM/yyyy');
    final startDate = formatter.parse(_startDateController.text);
    final endDate = formatter.parse(_endDateController.text);

    if (endDate.isBefore(startDate)) {
      showAppToast(
        context: context,
        message: "A Data Final não pode ser anterior à Data Inicial.",
        isError: true,
      );
      return;
    }

    if (_isEditMode) {
      widget.bloc.add(
        UpdateAvaliacaoEvent(
          id: widget.evaluationId!,
          descricao: _descricaoController.text,
          link: _linkController.text,
          dataInicio: _startDateController.text,
          dataFim: _endDateController.text,
          tipoAplicacao: _selectedDominio!,
          objetivos: _objectives,
        ),
      );
    } else {
      widget.bloc.add(
        CadastrarAvaliacaoEvent(
          descricao: _descricaoController.text,
          link: _linkController.text,
          dataInicio: _startDateController.text,
          dataFim: _endDateController.text,
          tipoAplicacao: _selectedDominio!,
          objetivos: _objectives,
          avaliadores: _avaliadores,
        ),
      );
    }
  }

  Widget header() {
    return appContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          appText(
            text: _isEditMode ? 'Editar Avaliação' : AppStrings.cadastrarAvaliacao,
            fontSize: AppFontSize.fs28,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ],
      ),
    );
  }

  Widget _botoesFormulario() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppTextButton(
          onPressed: _voltar,
          text: AppStrings.voltar,
          backgroundColor: AppColors.white,
          textColor: AppColors.black,
          border: true,
          borderColor: AppColors.black,
        ),
        appSizedBox(width: AppSpacing.normal),
        AppTextButton(
          onPressed: _salvar,
          text: _isEditMode ? AppStrings.salvar : AppStrings.cadastrar,
        ),
      ],
    );
  }

  Widget form() {
    return appContainer(
      width: 1600,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColors.grey800,
        ),
        borderRadius: BorderRadius.circular(AppSizes.s10),
      ),
      padding: const EdgeInsets.all(AppSpacing.big),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header(),
            appSizedBox(height: AppSpacing.big),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: descricaoField),
                appSizedBox(width: AppSpacing.big),
                Expanded(child: linkField),
              ],
            ),
            appSizedBox(height: AppSpacing.big),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: dataInicialField),
                appSizedBox(width: AppSpacing.big),
                Expanded(child: dataFinalField),
              ],
            ),
            appSizedBox(height: AppSpacing.big),
            AppDropdown<ApplicationType>(
              label: AppStrings.dominio,
              value: _selectedDominio,
              items: _dominios,
              width: double.infinity,
              onChanged: (dominio) {
                setState(() {
                  _selectedDominio = dominio;
                });
              },
              itemLabelBuilder: (dominio) => dominio.description ?? '',
            ),
            appSizedBox(height: AppSpacing.big),
            AppObjectivesField(
              width: double.infinity,
              objectives: _objectives,
              onAdd: (text) {
                setState(() {
                  _objectives.add(text);
                });
              },
              onRemove: (text) {
                setState(() {
                  _objectives.remove(text);
                });
              },
            ),
            appSizedBox(height: AppSpacing.big),
            Row(
              children: [
                avaliadoresButton,
              ],
            ),
            appSizedBox(height: AppSpacing.big),
            _botoesFormulario(),
          ],
        ),
      ),
    );
  }

  Widget body() {
    return Center(
      child: form(),
    );
  }

  Widget _blocConsumer() {
    return BlocConsumer<AvaliacoesBloc, AvaliacoesState>(
      bloc: widget.bloc,
      listener: (context, state) => _onChangeState(state),
      builder: (context, state) {
        if (state is AvaliacoesLoading) {
          return const AppLoading(color: AppColors.black,);
        }
        if (state is AvaliacoesError) {
          return AppError();
        }
        return body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _blocConsumer(),
    );
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _linkController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}