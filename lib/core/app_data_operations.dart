// Recebe datas no padrão "25/05/2025"
String validarDatas(String dataInicial, String dataFinal) {
  try {
    final formato = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

    if (!formato.hasMatch(dataInicial) || !formato.hasMatch(dataFinal)) {
      return 'Formato de data inválido.';
    }

    final partesInicial = dataInicial.split('/');
    final partesFinal = dataFinal.split('/');

    final inicio = DateTime(
      int.parse(partesInicial[2]),
      int.parse(partesInicial[1]),
      int.parse(partesInicial[0]),
    );

    final fim = DateTime(
      int.parse(partesFinal[2]),
      int.parse(partesFinal[1]),
      int.parse(partesFinal[0]),
    );

    if (inicio.isAfter(fim)) {
      return 'A data inicial não pode ser maior que a data final.';
    }

    return '';
  } catch (e) {
    return 'Erro ao processar as datas.';
  }
}
