import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/structure/widgets/app_bar_custom.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        actions: [
          AppTextButtonAppBar(
            onPressed: () => _navigateTo(const HomePage()),
            text: AppStrings.home.toUpperCase(),
            textColor: AppColors.white,
          ),
          AppTextButtonAppBar(
            onPressed: () => _navigateTo(const HomePage()),
            text: AppStrings.avaliacoes.toUpperCase(),
            textColor: AppColors.white,
          ),
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
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: _bodyContent,
      ),
    );
  }
}
