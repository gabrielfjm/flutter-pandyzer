import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/widgets/app_feature_card.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
            color: AppColors.grey900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(AppIcons.searchCheck, size: 64, color: Colors.white),
                const SizedBox(height: AppSpacing.medium),
                appText(
                  text: 'Panda: Eleve a Experiência do Usuário',
                  fontSize: AppFontSize.fs32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.medium),
                appText(
                  text:
                  'Uma plataforma para realizar avaliações heurísticas de forma colaborativa e inteligente.',
                  fontSize: AppFontSize.fs18,
                  color: Colors.white70,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.big),
          Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(AppSpacing.big),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appText(
                  text: 'Por que usar o Pandyzer?',
                  fontSize: AppFontSize.fs24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  spacing: AppSpacing.big,
                  runSpacing: AppSpacing.big,
                  children: [
                    appFeatureCard(
                      icon: AppIcons.users,
                      title: 'Colaborativo',
                      description:
                      'Atribua avaliadores, acompanhe processos e unifique avaliações com facilidade.',
                    ),
                    appFeatureCard(
                      icon: AppIcons.brain,
                      title: 'Assistente Inteligente',
                      description:
                      'Receba sugestões baseadas nas heurísticas de Nielsen com apoio de IA.',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.big * 2),
        ],
      ),
    );
  }
}
