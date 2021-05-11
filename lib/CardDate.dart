import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardDate {
  //CardDate(this.objetivo, this.data, this.semana, this.horas);

  String objetivo;
  DateTime data;
  List<String> semana;
  List<DateTime> horas;

  void clear() {
    this.objetivo = "";
    this.data = null;
    this.semana = [];
    this.horas = [];
  }

  Future<void> firebase() async {
    final QuerySnapshot result = await Future.value(
        Firestore.instance.collection("infoAgenda").getDocuments());

    //var list = result.documents;
  }

  void update() {
    this.data = DateTime.now();
  }
}
