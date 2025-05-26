import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_event.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_state.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/widgets/avaliacao_card.dart';
import 'cadastro/cadastro_avaliacoes_page.dart';

class AvaliacoesPage extends StatefulWidget {
  const AvaliacoesPage({super.key});

  @override
  State<AvaliacoesPage> createState() => _AvaliacoesPageState();
}

class _AvaliacoesPageState extends State<AvaliacoesPage> {
  final AvaliacoesBloc _bloc = AvaliacoesBloc();

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
    _bloc.add(LoadAvaliacoesEvent());
  }

  void _addAvaliacao(){
    NavigationManager().goTo(CadastroAvaliacoesPage(bloc: _bloc));
  }

  Widget header() {
    return appContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.centerLeft,
      child: appText(
        text: AppStrings.avaliacoes,
        fontSize: AppFontSize.fs28,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }

  Widget filters() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _addAvaliacao(),
          icon: const Icon(Icons.add),
          label: const Text('Criar Avaliação'),
        ),
        appSizedBox(width: 16),
        const Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filtrar avaliações...',
              border: OutlineInputBorder(),
            ),
          ),
        )
      ],
    );
  }

  Widget list(List<Evaluation> avaliacoes) {
    if (avaliacoes.isEmpty) {
      return Center(
        child: appText(
          text: 'Nenhuma avaliação disponível.',
          color: AppColors.white,
        ),
      );
    }

    return ListView.builder(
      itemCount: avaliacoes.length,
      itemBuilder: (context, index) {
        return AvaliacaoCard(
          evaluation: avaliacoes[index],
          onView: () {},
          onEdit: (){},
          onDelete: (){},
        );
      },
    );
  }


  Widget body(List<Evaluation> avaliacoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header(),
        filters(),
        appSizedBox(height: 16),
        Expanded(child: list(avaliacoes)),
      ],
    );
  }


  Widget _blocListener() {
    return BlocListener<AvaliacoesBloc, AvaliacoesState>(
      bloc: _bloc,
      listener: (context, state) => _onChangeState(state),
      child: BlocBuilder<AvaliacoesBloc, AvaliacoesState>(
        bloc: _bloc,
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
    _bloc.close();
    super.dispose();
  }
}
