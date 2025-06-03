import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_data_operations.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_event.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_state.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_data_picker_field.dart';
import 'package:flutter_pandyzer/structure/widgets/app_dropdown.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_icon_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_objectives.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_field.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/widgets/app_toast.dart';

import 'modal/app_avaliadores_select.dart';

class CadastroAvaliacoesPage extends StatefulWidget {
  final AvaliacoesBloc bloc;

  const CadastroAvaliacoesPage({required this.bloc, super.key});

  @override
  State<CadastroAvaliacoesPage> createState() => _CadastroAvaliacoesPageState();
}

class _CadastroAvaliacoesPageState extends State<CadastroAvaliacoesPage> {

  late AppTextField descricaoField;
  late AppTextField linkField;
  late AppDatePickerField dataInicialField;
  late AppDatePickerField dataFinalField;
  late AppDropdown dominioDropdown;
  late AppObjectivesField objetivosField;
  late AppAvaliadoresSelector avaliadoresButton;

  final _descricaoController = TextEditingController();
  final _linkController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  List<String> _objectives = <String>[];
  ApplicationType? _selectedDominio;
  final _avaliadores = <String>[];
  late List<ApplicationType> _dominios = [];

  void _onChangeState(AvaliacoesState state) {
    if(state is AvaliacaoCamposLoaded){
      setState(() {
        _dominios = state.dominios;
      });
    }

    if (state is AvaliacaoCadastrada) {
      NavigationManager().goTo(const AvaliacoesPage());
    }
  }

  @override
  void initState() {
    descricaoField = AppTextField(
      label: AppStrings.descricao,
      controller: _descricaoController,
    );

    linkField = AppTextField(
      label: AppStrings.linkDaInterface,
      controller: _linkController,
    );

    dataInicialField = AppDatePickerField(
      label: AppStrings.dataInicial,
      controller: _startDateController,
    );

    dataFinalField = AppDatePickerField(
      label: AppStrings.dataFinal,
      controller: _endDateController,
    );

    avaliadoresButton = AppAvaliadoresSelector(
      onSelected: (selected) => setState(() => _avaliadores.addAll(selected)),
      avaliadores: _avaliadores,
    );

    _loadFilters();
    super.initState();
  }

  void _loadFilters(){
    widget.bloc.add(LoadCamposCadastroAvaliacao());
  }

  void _voltar() {
    NavigationManager().goTo(const AvaliacoesPage());
  }

  void _salvar() {
    if(_descricaoController.text == AppStrings.empty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemDescricaoEstaVazio,
      );
      return;
    }

    if(_linkController.text == AppStrings.empty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemLinkEstaVazio,
      );
      return;
    }

    if(_startDateController.text == AppStrings.empty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemDataInicialEstaVazio,
      );
      return;
    }

    if(_endDateController.text == AppStrings.empty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemDataFinalEstaVazio,
      );
      return;
    }

    String verificacaoDatas = validarDatas(_startDateController.text, _endDateController.text);
    if(verificacaoDatas != AppStrings.empty){
      showAppToast(
        context: context,
        message: verificacaoDatas,
      );
      return;
    }

    if(_selectedDominio == null){
      showAppToast(
        context: context,
        message: AppStrings.selecioneUmDominio,
      );
      return;
    }

    if(_objectives.isEmpty){
      showAppToast(
        context: context,
        message: AppStrings.mensagemObjetivos,
      );
      return;
    }

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

  Widget botaoVoltar() {
    return AppIconButton(
      icon: AppIcons.arrowBack,
      onPressed: _voltar,
      iconColor: AppColors.black,
    );
  }

  Widget header() {
    return appContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          botaoVoltar(),
          appSizedBox(width: AppSpacing.normal),
          appText(
            text: AppStrings.cadastrarAvaliacao,
            fontSize: AppFontSize.fs28,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ],
      )
    );
  }

  Widget _botoesFormulario(){
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
          text: AppStrings.salvar,
        ),
      ],
    );
  }

  Widget form() {
    return appContainer(
      width: 900,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColors.grey800,
        ),
        borderRadius: BorderRadius.circular(AppSizes.s10),
      ),
      padding: EdgeInsets.all(AppSpacing.big),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            children: [
              appSizedBox(height: AppSpacing.big),
              Wrap(
                children: [
                  descricaoField,
                  appSizedBox(width: AppSpacing.big),
                  linkField,
                ],
              ),
              appSizedBox(height: AppSpacing.big),
              Wrap(
                children: [
                  dataInicialField,
                  appSizedBox(width: AppSpacing.big),
                  dataFinalField,
                ],
              ),
              appSizedBox(height: AppSpacing.big),
              AppDropdown<ApplicationType>(
                label: AppStrings.dominio,
                value: _selectedDominio,
                items: _dominios,
                onChanged: (dominio) {
                  setState(() {
                    _selectedDominio = dominio;
                  });
                },
                itemLabelBuilder: (dominio) => '${dominio.description}',
              ),
              appSizedBox(height: AppSpacing.big),
              AppObjectivesField(
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
              avaliadoresButton,
              appSizedBox(height: AppSpacing.big),
              _botoesFormulario(),
            ],
          ),
        ),
      ),
    );
  }

  Widget body(){
    return Column(
      children: [
        header(),
        appSizedBox(height: AppSpacing.normal),
        form(),
      ],
    );
  }

  Widget _blocConsumer() {
    return BlocConsumer<AvaliacoesBloc, AvaliacoesState>(
      bloc: widget.bloc,
      listener: (context, state) => _onChangeState(state),
      builder: (context, state) {
        switch(state.runtimeType){
          case AvaliacoesLoading:
            return const AppLoading();
          case AvaliacaoCamposLoaded:
            return body();
          case AvaliacoesError:
            return AppError();
          default:
            return appSizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _blocConsumer();
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
