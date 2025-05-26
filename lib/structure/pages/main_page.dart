import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/perfil/perfil_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_bar_custom.dart';
import 'package:flutter_pandyzer/structure/widgets/app_icon_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button_app_bar.dart';
import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Widget _bodyContent = const HomePage();

  void _navigateTo(Widget page) {
    setState(() {
      _bodyContent = page;
    });
  }

  @override
  void initState() {
    super.initState();
    NavigationManager().registerNavigation(_navigateTo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        leading: [
          AppTextButtonAppBar(
            onPressed: () => _navigateTo(const HomePage()),
            text: AppStrings.home,
            textColor: AppColors.white,
          ),
          AppTextButtonAppBar(
            onPressed: () => _navigateTo(const AvaliacoesPage()),
            text: AppStrings.avaliacoes,
            textColor: AppColors.white,
          ),
        ],
        actions: [
          AppIconButton(
            icon: AppIcons.person,
            border: true,
            onPressed: () => _navigateTo(const PerfilPage()),
          ),
          appSizedBox(width: AppSpacing.normal),
          AppTextButton(
            onPressed: () => _navigateTo(const HomePage()),
            text: AppStrings.logout,
            backgroundColor: AppColors.grey900,
            textColor: AppColors.white,
            border: true,
            borderColor: AppColors.grey800,
          ),
        ],
      ),
      body: Container(
        color: AppColors.grey900,
        width: double.infinity,
        height: double.infinity,
        child: _bodyContent,
      ),
    );
  }
}
