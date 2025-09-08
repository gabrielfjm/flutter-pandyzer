class DashboardIndicators {
  final int avaliacoesEmAndamento;
  final int avaliacoesConcluidas;
  final int avaliacoesNaoIniciadas;

  DashboardIndicators({
    required this.avaliacoesEmAndamento,
    required this.avaliacoesConcluidas,
    required this.avaliacoesNaoIniciadas,
  });

  factory DashboardIndicators.fromJson(Map<String, dynamic> json) {
    return DashboardIndicators(
      avaliacoesEmAndamento: json['avaliacoesEmAndamento'] ?? 0,
      avaliacoesConcluidas: json['avaliacoesConcluidas'] ?? 0,
      avaliacoesNaoIniciadas: json['avaliacoesNaoIniciadas'] ?? 0,
    );
  }
}