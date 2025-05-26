import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_state.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_icon_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';

class CadastroAvaliacoesPage extends StatefulWidget {
  AvaliacoesBloc bloc;

  CadastroAvaliacoesPage({required this.bloc, super.key});

  @override
  State<CadastroAvaliacoesPage> createState() => _CadastroAvaliacoesPageState();
}

class _CadastroAvaliacoesPageState extends State<CadastroAvaliacoesPage> {

  void _onChangeState(AvaliacoesState state) {
    if (state is AvaliacoesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _voltar(){
    NavigationManager().goTo(const AvaliacoesPage());
  }

  Widget botaoVoltar(){
    return AppIconButton(
      icon: AppIcons.arrowBack,
      onPressed: _voltar,
    );
  }

  Widget header() {
    return appContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.centerLeft,
      child: appText(
        text: AppStrings.cadastrarAvaliacao,
        fontSize: AppFontSize.fs28,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }

  Widget body(List<Evaluation> avaliacoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            botaoVoltar(),
            appSizedBox(width: AppSpacing.normal),
            header(),
          ],
        )
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
          } else if (state is AvaliacoesLoaded) {
            return body(state.avaliacoes);
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
    super.dispose();
  }
}
