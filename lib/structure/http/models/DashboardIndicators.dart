class DashboardIndicators {
  final int avaliacoesCriadas;
  final int avaliacoesFeitas;
  final int avaliacoesEmAndamento;

  DashboardIndicators({
    required this.avaliacoesCriadas,
    required this.avaliacoesFeitas,
    required this.avaliacoesEmAndamento,
  });

  factory DashboardIndicators.fromJson(Map<String, dynamic> json) {
    return DashboardIndicators(
      avaliacoesCriadas: json['avaliacoesCriadas'] ?? 0,
      avaliacoesFeitas: json['avaliacoesFeitas'] ?? 0,
      avaliacoesEmAndamento: json['avaliacoesEmAndamento'] ?? 0,
    );
  }
}