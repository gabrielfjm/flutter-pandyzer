mixin AvaliacoesRepository {
  static Future<List<String>> fetchAvaliacoes() async {
    // Simula um delay de requisição
    await Future.delayed(const Duration(seconds: 1));
    return ['Avaliação 1', 'Avaliação 2', 'Avaliação 3'];
  }
}
