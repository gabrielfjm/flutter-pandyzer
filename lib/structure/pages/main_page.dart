import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_icons.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_page.dart';
import 'package:flutter_pandyzer/structure/pages/perfil/perfil_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_bar_custom.dart';
import 'package:flutter_pandyzer/structure/widgets/app_icon_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button.dart';
import 'package:flutter_pandyzer/structure/widgets/app_text_button_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Widget _bodyContent = const HomePage();
  String _userName = '';

  void _navigateTo(Widget page) {
    setState(() {
      _bodyContent = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    NavigationManager().registerNavigation(_navigateTo);
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    User usuario = await UsuarioService.getUsuarioById(int.parse(userId!));
    setState(() {
      _userName = usuario.name!;
    });
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
          appText(
            text: _userName,
            color: AppColors.white,
            fontSize: AppFontSize.fs15,
          ),
          appSizedBox(width: AppSpacing.normal),
          AppIconButton(
            icon: AppIcons.person,
            border: true,
            onPressed: () => _navigateTo(const PerfilPage()),
          ),
          appSizedBox(width: AppSpacing.big),
          AppTextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
            text: AppStrings.logout,
            backgroundColor: AppColors.grey900,
            textColor: AppColors.white,
            border: true,
            borderColor: AppColors.grey800,
            icon: AppIcons.logout,
          ),
        ],
      ),
      body: Container(
        color: AppColors.white,
        width: double.infinity,
        height: double.infinity,
        child: _bodyContent,
      ),
    );
  }
}
