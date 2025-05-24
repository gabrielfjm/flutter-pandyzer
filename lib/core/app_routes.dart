import 'package:flutter/material.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_page.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_page.dart';
import 'package:flutter_pandyzer/structure/pages/perfil/perfil_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String avaliacoes = '/avaliacoes';
  static const String perfil = '/perfil';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomePage(),
    avaliacoes: (context) => const AvaliacoesPage(),
    perfil: (context) => const PerfilPage(),
  };
}
