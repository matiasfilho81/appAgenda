/// FeedbackForm is a data class which stores data fields of Feedback.
class FeedbackForm {
  String checkList;
  String objetivo;
  String data;
  String hora;
  String numListAtiva; //<-- int
  String semana;
  String horas;
  String numBotaoAtual; //<-- int

  FeedbackForm(this.checkList, this.objetivo, this.data, this.hora,
      this.numListAtiva, this.semana, this.horas, this.numBotaoAtual);

  factory FeedbackForm.fromJson(dynamic json) {
    return FeedbackForm(
        "${json['checkList']}",
        "${json['objetivo']}",
        "${json['data']}",
        "${json['hora']}",
        "${json['numListAtiva']}",
        "${json['semana']}",
        "${json['horas']}",
        "${json['numBotaoAtual']}");
  }

  // Method to make GET parameters.
  Map toJson() => {
        'checkList': checkList,
        'objetivo': objetivo,
        'data': data,
        'hora': hora,
        'numListAtiva': numListAtiva,
        'semana': semana,
        'horas': horas,
        'numBotaoAtual': numBotaoAtual
      };
}
