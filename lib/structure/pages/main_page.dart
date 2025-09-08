import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/core/app_strings.dart';
import 'package:flutter_pandyzer/core/navigation_manager.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/login/login_page.dart';
import 'package:flutter_pandyzer/structure/pages/profile/profile_page.dart';
import 'package:flutter_pandyzer/structure/widgets/app_bar_custom.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
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
    if (userId != null) {
      User usuario = await UsuarioService.getUsuarioById(int.parse(userId));
      setState(() {
        _userName = usuario.name ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String initialLetter =
    _userName.isNotEmpty ? _userName[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBarCustom(
        leading: [
          TextButton(
            onPressed: () => _navigateTo(const HomePage()),
            child: Text(
              AppStrings.home,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppFontSize.fs15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _navigateTo(const AvaliacoesPage()),
            child: Text(
              AppStrings.avaliacoes,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppFontSize.fs15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actions: [
          // Botão de perfil
          InkWell(
            onTap: () => _navigateTo(const ProfilePage()),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Text(
                      initialLetter,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          appSizedBox(width: AppSpacing.normal),

          // Botão de logout
          InkWell(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                children: const [
                  Icon(Icons.logout, size: 18, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
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
