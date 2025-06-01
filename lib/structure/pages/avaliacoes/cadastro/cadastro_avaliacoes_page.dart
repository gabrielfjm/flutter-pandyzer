import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
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
  final _objectives = <String>[];
  ApplicationType? _selectedApplicationType;
  final _avaliadores = <String>[];
  late List<ApplicationType> _dominios = [];


  void _onChangeState(AvaliacoesState state) {

    print(state.toString());

    if (state is AvaliacoesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      print('erro');
    }

    if(state is AvaliacaoCamposLoaded){
      print('cheguei aqui!');
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

    objetivosField = AppObjectivesField(
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
    widget.bloc.add(
      CadastrarAvaliacaoEvent(
        descricao: _descricaoController.text,
        link: _linkController.text,
        dataInicio: _startDateController.text,
        dataFim: _endDateController.text,
        tipoAplicacao: _selectedApplicationType!,
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
          AppDropdown(
            label: AppStrings.dominio,
            items: _dominios,
            onChanged: (value) => setState(() => _selectedApplicationType = value),
            value: _selectedApplicationType,
          ),
          appSizedBox(height: AppSpacing.big),
          objetivosField,
          appSizedBox(height: AppSpacing.big),
          avaliadoresButton,
          appSizedBox(height: AppSpacing.big),
          _botoesFormulario(),
        ],
      )
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

  Widget _blocListener() {
    return BlocListener<AvaliacoesBloc, AvaliacoesState>(
      bloc: widget.bloc,
      listener: (context, state) => _onChangeState(state),
      child: BlocBuilder<AvaliacoesBloc, AvaliacoesState>(
        bloc: widget.bloc,
        builder: (context, state) {
          if (state is AvaliacoesLoading) {
            return const AppLoading();
          } else if (state is AvaliacaoCamposLoaded) {
            return body();
          } else if (state is AvaliacoesError) {
            return AppError(message: state.message);
          } else {
            return appSizedBox();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _blocListener(),
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
