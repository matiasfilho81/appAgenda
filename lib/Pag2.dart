import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/Pag1.dart';
import 'package:agenda/utils/common.dart';
import 'package:agenda/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:core';

class Pag2 extends StatefulWidget {
  Pag2({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState2 createState() => _MyHomePageState2();
}

class _MyHomePageState2 extends State<Pag2> {
  // ------------------------- variaveis ---------------------------

  int numListaObjetivo = 0; // a posição que as informações esta salva na lista

  bool jaPegouInformacao = false; // ve se ja pegou as informações salvas

  String conteudoObjetivo = ""; // o nome do objetivo

  int selecaoBarraNavegacao = 1;
  // 0 = salvar, 1 = cancelar, qual botao da barra ta selecionado

  var onOffPai = [false, false]; // on off pai da notificação e alarme

  var onOffFilho = [false, false, false, false];
  // on off filhos da notificação e alarme

  DateTime selecionaData = DateTime.now(); // é a data do termino

  TimeOfDay selecionaHora = TimeOfDay.now(); // é a hora limite

  TimeOfDay selecionaListaDeHora = TimeOfDay.now(); // as horas dos filhos

  var listaDeHorasIniciais = ["00:00", "00:00", "00:00", "00:00"];
  // horario da notificação e alarme q vai aparecer na tela (usa essa string pra ver q a hora mudou da anterior, alem de conseguir começar a hora com 00:00)

  var selecionaDiaSemana = ["0", "0", "0", "0", "0", "0", "0"];
  // selecionar o dia da semana q o objetivo se repete

  // -----------------------------------------------------------------

  BottomNavigationBarItem criaBotaoBarraNavegacao(String nome, Icon icone) {
    /*---------------------------------------------------------------------- \
    |   cria a barra de seleção com os botoes                                |
    \ ----------------------------------------------------------------------*/

    return BottomNavigationBarItem(
      icon: icone,
      label: "$nome",
    );
  }

  Container criaDiaSemana(String letra, int numero) {
    /*---------------------------------------------------------------------- \
    |   Cria os botões dos dias da semana                                    |
    \ ----------------------------------------------------------------------*/

    return Container(
      height: AppConsts.botaoCircular,
      width: setWidth(AppConsts.botaoCircular - 1),
      padding: EdgeInsets.only(left: 2, right: 2),
      child: FloatingActionButton.extended(
        label: Text("$letra"),
        heroTag: "btnDias$numero",
        onPressed: () {
          setState(() {
            selecionaDiaSemana[numero] =
                selecionaDiaSemana[numero] == "0" ? "1" : "0";
          });
        },
        backgroundColor: AppConsts.corBotaoSemana(selecionaDiaSemana[numero]),
      ),
    );
  }

  Container criaOnOffPai(String titulo, int number) {
    /*---------------------------------------------------------------------- \
    |   Cria a estrutura dos Switch (on off) pai                             |
    \ ----------------------------------------------------------------------*/

    return Container(
      height: 70,
      padding: EdgeInsets.only(left: setWidth(10)),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            '$titulo',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: onOffPai[number],
            onChanged: (bool value) {
              setState(() {
                onOffPai[number] = value;
                if (onOffPai[number] == false && number == 0) {
                  onOffFilho[0] = false;
                  listaDeHorasIniciais[0] = "00:00";
                  mudaChaveFilha(0, number);
                  onOffFilho[1] = false;
                  listaDeHorasIniciais[1] = "00:00";
                  mudaChaveFilha(1, number);
                } else if (onOffPai[number] == false && number == 1) {
                  onOffFilho[2] = false;
                  listaDeHorasIniciais[2] = "00:00";
                  mudaChaveFilha(2, number);
                  onOffFilho[3] = false;
                  listaDeHorasIniciais[3] = "00:00";
                  mudaChaveFilha(3, number);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Container criaOnOffFilho(String titulo, int numero, int pai) {
    /*---------------------------------------------------------------------- \
    |   Cria a estrutura dos Switch (on off) filho                           |
    \ ----------------------------------------------------------------------*/

    return Container(
      height: 85,
      padding: EdgeInsets.only(left: setWidth(25)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          switchFilho(titulo, numero, pai),
          criaHoraInicial(numero, pai),
        ],
      ),
    );
  }

  Row switchFilho(String titulo, int numOn, int pai) {
    /*---------------------------------------------------------------------- \
    |   retorna o titulo e o switch filho                                    |
    \ ----------------------------------------------------------------------*/

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          '$titulo',
          style: AppConsts.estiloTextoAlarmeNotifPai(onOffPai[pai]),
        ),
        mudaChaveFilha(numOn, pai),
      ],
    );
  }

  Switch mudaChaveFilha(int numOn, int pai) {
    /*---------------------------------------------------------------------- \
    |   muda o valor dos Switch filho e coloca a hora 00:00                  |
    \ ----------------------------------------------------------------------*/

    return Switch(
      value: onOffFilho[numOn],
      onChanged: (bool value) {
        setState(() {
          if (onOffPai[pai] == true) {
            onOffFilho[numOn] = value;
            listaDeHorasIniciais[numOn] = "00:00";
          } else {
            onOffFilho[numOn] = false;
            listaDeHorasIniciais[numOn] = "00:00";
          }
        });
      },
    );
  }

  Container criaHoraInicial(int numHora, int pai) {
    /*---------------------------------------------------------------------- \
    |   botão das horas de notificação e alarme                              |
    \ ----------------------------------------------------------------------*/

    return Container(
      height: 30,
      padding: EdgeInsets.only(left: setWidth(20)),
      alignment: Alignment.centerLeft,
      child: FloatingActionButton.extended(
          label: Text(listaDeHorasIniciais[numHora],
              style:
                  AppConsts.estiloTextoHorasAlarmeNotif(onOffFilho[numHora])),
          elevation: AppConsts.dateAndHourElevation,
          backgroundColor: AppConsts.corFundoDataHora,
          heroTag: "btnHoras$numHora",
          onPressed: () => selecionaListaDeHoras(context, numHora, pai)),
    );
  }

  DateTime formataTimeOfDay(TimeOfDay tod) {
    /*---------------------------------------------------------------------- \
    |   Converte TimeOfDay em DateTime                                       |
    \ ----------------------------------------------------------------------*/

    final now = selecionaData;
    DateTime dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return dt;
  }

  void selecionaDate(BuildContext context) async {
    /*---------------------------------------------------------------------- \
    |   Seleciona a data final                                               |
    \ ----------------------------------------------------------------------*/

    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selecionaData,
      firstDate: DateTime.now(),
      lastDate: DateTime(2080),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (picked != null && picked != selecionaData)
      setState(() {
        selecionaData = picked;
      });
  }

  void selecionaHoras(BuildContext context) async {
    /*---------------------------------------------------------------------- \
    |   Seleciona a hora final                                               |
    \ ----------------------------------------------------------------------*/

    TimeOfDay picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (picked != null && picked != selecionaHora)
      setState(() {
        selecionaHora = picked;
        selecionaData = formataTimeOfDay(selecionaHora);
      });
  }

  void selecionaListaDeHoras(BuildContext context, int number, int pai) async {
    /*---------------------------------------------------------------------- \
    |   Seleciona as horas da notificação e alarme                           |
    \ ----------------------------------------------------------------------*/

    if (onOffPai[pai] == true && onOffFilho[number] == true) {
      TimeOfDay picked = await showTimePicker(
        initialTime: TimeOfDay.now(),
        context: context,
      );

      TimeOfDay selectedTimeListTemporario = TimeOfDay.fromDateTime(
          DateTime.parse("2021-01-01 " +
              listaDeHorasIniciais[number].substring(0, 2) +
              ":" +
              listaDeHorasIniciais[number].substring(3, 5) +
              ":00Z"));

      if (picked != null && picked != selectedTimeListTemporario)
        setState(() {
          selecionaListaDeHora = picked;
          listaDeHorasIniciais[number] = DateFormat('kk:mm')
              .format(formataTimeOfDay(selecionaListaDeHora));
          selecionaListaDeHora = TimeOfDay(hour: 0, minute: 0);
        });
    }
  }

  void mudaTela() {
    /*---------------------------------------------------------------------- \
    |   Muda para a Pag1                                                     |
    \ ----------------------------------------------------------------------*/

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Pag1()),
    );
  }

  Future<void> salvaObjetivo(int index) async {
    /*---------------------------------------------------------------------- \
    |   Salva as informações do objetivo na memória                          |
    \ ----------------------------------------------------------------------*/

    SharedPreferences prefs = await SharedPreferences.getInstance();

    selecaoBarraNavegacao = index;

    // verifica se a pag 2 foi chamada pelo botão dos objetivos ja existentes

    if (selecaoBarraNavegacao == 0 &&
        (prefs.getInt('numBotaoAtual') ?? [20]) != 20) {
      /* 
      // apaga informções salvas
      prefs.setStringList('objetivo', []);
      prefs.setStringList('data', []);
      prefs.setStringList('hora', []);
      prefs.setStringList('semana', []);
      prefs.setStringList('horas', []);
      prefs.setInt('numListAtiva', 0);*/

      // --------------------- pega as informações salvas -------------------

      List<String> objetivoTemporario = prefs.getStringList('objetivo') ?? [""];
      List<String> dataTemporaria = prefs.getStringList('data') ?? [""];
      List<String> horaTemporaria = prefs.getStringList('hora') ?? [""];
      List<String> semanaTemporaria = prefs.getStringList('semana') ?? ["0"];
      List<String> horasTemporarias = prefs.getStringList('horas') ?? ["00:00"];

      // ---- insere as novas informações no lugar das antigas na lista ----

      objetivoTemporario[numListaObjetivo] = conteudoObjetivo;
      dataTemporaria[numListaObjetivo] =
          DateFormat('dd/MM/yy').format(selecionaData);
      horaTemporaria[numListaObjetivo] =
          DateFormat('kk:mm').format(formataTimeOfDay(selecionaHora));

      for (int i = 0; i < 7; i++) {
        semanaTemporaria[(numListaObjetivo * 7) + i] = selecionaDiaSemana[i];
      }

      for (int i = 0; i < 4; i++) {
        horasTemporarias[(numListaObjetivo * 4) + i] = listaDeHorasIniciais[i];
      }

      //---------- salva as informações do objetivo modificado ----------

      prefs.setStringList('objetivo', objetivoTemporario);
      prefs.setStringList('data', dataTemporaria);
      prefs.setStringList('hora', horaTemporaria);
      prefs.setStringList('semana', semanaTemporaria);
      prefs.setStringList('horas', horasTemporarias);

      // verifica se a pag 2 foi chamada pelo botão de adicionar no objetivo
    } else if (selecaoBarraNavegacao == 0 &&
        (prefs.getInt('numBotaoAtual') ?? [20]) == 20) {
      // verifica se alista de objetivo esta vazia
      print((prefs.getStringList('objetivo')));
      print((prefs.getStringList('objetivo')).length);
      if ((prefs.getStringList('objetivo')).length == 0) {
        prefs.setStringList('objetivo', [conteudoObjetivo]);
        prefs.setStringList(
            'data', [DateFormat('dd/MM/yy').format(selecionaData)]);
        prefs.setStringList('hora', [
          DateFormat('kk').format(selecionaData) == "24"
              ? "00:" + DateFormat('mm').format(selecionaData)
              : DateFormat('kk:mm').format(selecionaData)
        ]);

        prefs.setStringList('semana', selecionaDiaSemana);
        prefs.setStringList('horas', listaDeHorasIniciais);

        prefs.setInt('numListAtiva', 1);
      } else {
        prefs.setStringList(
            'objetivo', prefs.getStringList('objetivo') + [conteudoObjetivo]);
        prefs.setStringList(
            'data',
            prefs.getStringList('data') +
                [DateFormat('dd/MM/yy').format(selecionaData)]);
        prefs.setStringList(
            'hora',
            prefs.getStringList('hora') +
                [
                  DateFormat('kk').format(selecionaData) == "24"
                      ? "00:" + DateFormat('mm').format(selecionaData)
                      : DateFormat('kk:mm').format(selecionaData)
                ]);
        prefs.setStringList(
            'semana', prefs.getStringList('semana') + selecionaDiaSemana);
        prefs.setStringList(
            'horas', prefs.getStringList('horas') + listaDeHorasIniciais);

        prefs.setInt('numListAtiva', (prefs.getInt('numListAtiva') ?? 0) + 1);
      }
    }
    mudaTela();
  }

  Future<void> pegarInformacao() async {
    /*---------------------------------------------------------------------- \
    |   Pega as informações do objetivo na memória                           |
    \ ----------------------------------------------------------------------*/

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // verifica se a pag 2 foi chamada pelo botão dos objetivos ja existentes
    if (jaPegouInformacao == false &&
        (prefs.getInt('numBotaoAtual') ?? [0]) != 20) {
      jaPegouInformacao = true;
      setState(() {
        // -------------- pega as informações na memória --------------

        List<String> objetivoTemporario =
            prefs.getStringList('objetivo') ?? [""];
        List<String> dataTemporaria = prefs.getStringList('data') ?? [""];
        List<String> horaTemporaria = prefs.getStringList('hora') ?? [""];
        List<String> semanaTemporaria = prefs.getStringList('semana') ?? ["0"];
        List<String> horasTemporarias =
            prefs.getStringList('horas') ?? ["00:00"];
        numListaObjetivo = prefs.getInt('numBotaoAtual') ?? [0];

        //----------- pega as informações desse objetivo da lista  -----------
        // ---------------- temporaria e converte se preciso ---------------

        conteudoObjetivo = objetivoTemporario[numListaObjetivo];
        selecionaData = DateTime.parse("20" +
            dataTemporaria[numListaObjetivo].substring(6, 8) +
            "-" +
            dataTemporaria[numListaObjetivo].substring(3, 5) +
            "-" +
            dataTemporaria[numListaObjetivo].substring(0, 2) +
            " " +
            horaTemporaria[numListaObjetivo].substring(0, 2) +
            ":" +
            horaTemporaria[numListaObjetivo].substring(3, 5) +
            ":00Z");
        selecionaHora = TimeOfDay.fromDateTime(selecionaData);

        selecionaDiaSemana = semanaTemporaria.sublist(
            (numListaObjetivo * 7), (7 * (numListaObjetivo + 1)));

        listaDeHorasIniciais = horasTemporarias.sublist(
            (numListaObjetivo * 4), (4 * (numListaObjetivo + 1)));

        if (listaDeHorasIniciais[0] != "00:00" ||
            listaDeHorasIniciais[1] != "00:00") {
          onOffPai[0] = true;
          for (int i = 0; i < 2; i++) {
            if (listaDeHorasIniciais[i] != "00:00") {
              onOffFilho[i] = true;
            }
          }
        }
        if (listaDeHorasIniciais[2] != "00:00" ||
            listaDeHorasIniciais[3] != "00:00") {
          onOffPai[1] = true;
          for (int i = 2; i < 4; i++) {
            if (listaDeHorasIniciais[i] != "00:00") {
              onOffFilho[i] = true;
            }
          }
        }
      });
    }
  }

  Future<void> deletar() async {
    /*---------------------------------------------------------------------- \
    |   deleta o objetivo inteiro da memória                                 |
    \ ----------------------------------------------------------------------*/

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // verifica se a pag 2 foi chamada pelo botão dos objetivos ja existentes
    if ((prefs.getInt('numBotaoAtual') ?? [0]) != 20) {
      // -------------- pega as informações na memória --------------
      List<String> objetivoTemporario = prefs.getStringList('objetivo') ?? [""];
      List<String> dataTemporaria = prefs.getStringList('data') ?? [""];
      List<String> horaTemporaria = prefs.getStringList('hora') ?? [""];
      List<String> semanaTemporaria = prefs.getStringList('semana') ?? ["0"];
      List<String> horasTemporarias = prefs.getStringList('horas') ?? ["00:00"];
      List<String> checkTemporario = prefs.getStringList('checkList') ?? [" "];

      // ------ remove as informações desse objetivo da lista temporaria ------

      objetivoTemporario.removeAt(numListaObjetivo);
      dataTemporaria.removeAt(numListaObjetivo);
      horaTemporaria.removeAt(numListaObjetivo);

      for (int i = 6; i > -1; i--) {
        semanaTemporaria.removeAt((numListaObjetivo * 7) + i);
      }

      for (int i = 3; i > -1; i--) {
        horasTemporarias.removeAt((numListaObjetivo * 4) + i);
      }

      checkTemporario.removeAt(numListaObjetivo);
      checkTemporario.add(' ');

      // -------- devolve as informações paa a memória, agora excluidas --------

      prefs.setStringList('objetivo', objetivoTemporario);
      prefs.setStringList('data', dataTemporaria);
      prefs.setStringList('hora', horaTemporaria);
      prefs.setStringList('semana', semanaTemporaria);
      prefs.setStringList('horas', horasTemporarias);
      prefs.setStringList('checkList', checkTemporario);
      prefs.setInt('numListAtiva', (prefs.getInt('numListAtiva') ?? 0) - 1);
    }

    mudaTela();
  }

  @override
  Widget build(BuildContext context) {
    /*---------------------------------------------------------------------- \
    |   estrutura principal da Pag2                                          |
    \ ----------------------------------------------------------------------*/

    AppConsts.setWidthSize(MediaQuery.of(context).size.width);
    AppConsts.setHightSize(MediaQuery.of(context).size.height);
    pegarInformacao();

    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            criaBotaoBarraNavegacao('Salvar', Icon(Icons.save)),
            criaBotaoBarraNavegacao('Cancelar', Icon(Icons.cancel)),
          ],
          currentIndex: selecaoBarraNavegacao,
          selectedItemColor: Colors.grey[600],
          onTap: salvaObjetivo,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 70,
                    width: setWidth(300),
                    padding: EdgeInsets.only(right: 10),
                    alignment: Alignment.center,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28.0)),
                        labelText: conteudoObjetivo,
                        labelStyle: TextStyle(fontSize: 18),
                      ),
                      onChanged: (text) {
                        conteudoObjetivo = text;
                      },
                    ),
                  ),
                  Container(
                    height: AppConsts.botaoCircular,
                    width: AppConsts.botaoCircular,
                    alignment: Alignment.center,
                    child: FloatingActionButton(
                      child: Icon(Icons.delete),
                      heroTag: "btnDeletar",
                      onPressed: () {
                        deletar();
                      },
                    ),
                  ),
                ],
              ),
              Container(
                height: 60,
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Data de Termino',
                    ),
                    Text(
                      'Tempo Limite',
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      label: Text(DateFormat('dd/MM/yy').format(selecionaData),
                          style: AppConsts.estiloTextoDataHoraFinal()),
                      elevation: AppConsts.dateAndHourElevation,
                      backgroundColor: AppConsts.corFundoDataHora,
                      heroTag: "btnData",
                      onPressed: () => selecionaDate(context),
                    ),
                    FloatingActionButton.extended(
                      label: Text(
                          DateFormat('kk').format(selecionaData) == "24"
                              ? "00:" + DateFormat('mm').format(selecionaData)
                              : DateFormat('kk:mm').format(selecionaData),
                          style: AppConsts.estiloTextoDataHoraFinal()),
                      elevation: AppConsts.dateAndHourElevation,
                      backgroundColor: AppConsts.corFundoDataHora,
                      heroTag: "btnHora",
                      onPressed: () => selecionaHoras(context),
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
                padding: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: Text(
                  'Repetir o objetivo toda semana',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  criaDiaSemana("D", 0),
                  criaDiaSemana("S", 1),
                  criaDiaSemana("T", 2),
                  criaDiaSemana("Q", 3),
                  criaDiaSemana("Q", 4),
                  criaDiaSemana("S", 5),
                  criaDiaSemana("S", 6),
                ],
              ),
              criaOnOffPai('Notificação', 0),
              criaOnOffFilho('Notificar quanto tempo antes', 0, 0),
              criaOnOffFilho('Intervalo de notificação frequente', 1, 0),
              criaOnOffPai('Alarme', 1),
              criaOnOffFilho('Alarmar quanto tempo antes', 2, 1),
              criaOnOffFilho('Intervalo de alarme frequente', 3, 1),
            ],
          ),
        ),
      ),
    );
  }
}
