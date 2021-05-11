import 'package:agenda/CardDate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/utils/common.dart';
import 'package:agenda/utils/consts.dart';
import 'package:agenda/Pag2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:core';

/*  ------------------------ PÁGINA INICIAL DA AGENDA -------------------------

 *  Contem o botão de adicionar um novo objetivo.
 
 *  Os retangulos com o nome do objetivo, a data de conclusão, o dia da semana
    que esse objetivo encerra e começa a denovo ate a data da conclusão 
    e a hora da conclusão.

 *  CheckList para selecionar os objetivos concluidos.
 
 *  Quando é selecionado o checkList para um objetivo que não se repete toda
    semana, ele é excluido no dia seguinte.

 *  Quando é selecionado o checkList para um objetivo que se repete toda semana,
    ele só sera excluido um dia após a data final.

 *  Quando o objetivo não é cumprido, ele é excluido um dia após a data final.
 
 *  Quando é selecionado o checkList para um objetivo que se repete toda semana,
    após um dia do dia da semana selecionada para a arepetição, o checkListe
    será deselecionado sozinho para recomeçar o ciclo.

 *  Quando faltar uma hora para o termino do objetivo, seu retangulo ficará
    vermelho.

 *  Quando passar da hora do termino do objetivo, seu retangulo ficará escuro
    com letra vermelha.

 *  Quando for selecionado o checkList no objetivo, seu retangulo ficará branco.
*/

class Pag1 extends StatefulWidget {
  Pag1({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Pag1> {

  CardDate dados = CardDate(
      /*"a",
      DateTime.now(),
      ["a", "b", "c", "d", "e", "f", "g"],
      [DateTime.now(), DateTime.now(), DateTime.now(), DateTime.now()]*/);


  // ------------------------- variaveis ---------------------------

  bool jaPegouInformacao = false; // ve se o app ja pegou as novas informações

  var checkList = [false]; // ve se os quadradinhos de selecionar esta ativo

  List<String> objetivo = [""]; // conteudo do campo objetivo

  List<String> data = [""]; // conteudo da data final

  List<String> hora = [""]; // conteudo da hora maxima

  List<String> semana = [
    ""
  ]; // dias da semana selecionado ["0", "0", "1", "0", "1", "0", "0"]

  int numListAtiva = 0; // a quantidade de objetivos criados no momento

  // -----------------------------------------------------------------

  Future<void> salvarCheckList() async {
    /*---------------------------------------------------------------------- \
    |   Quando for selecionado ou deselecionado o checkList este metodo irá  |
    |   salvar a data em que isso ocorreu.                                   |
    \ ----------------------------------------------------------------------*/

    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> checkListTemporario = [];

    for (int i = 0; i < 20; i++) {
      checkListTemporario.add(checkList[i] == false
          ? " "
          : DateFormat('dd/MM/yy').format(DateTime.now()));
    }

    prefs.setStringList('checkList', checkListTemporario);
  }

  Future<void> pegarInfomacao() async {
    /*---------------------------------------------------------------------- \
    |   Este metodo pega as informações salvas na memoria e coloca nas       |
    |   variaveis que seram usadas para construir os objetivos.              |
    \ ----------------------------------------------------------------------*/

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.getStringList('objetivo') != null) {
        objetivo = prefs.getStringList('objetivo') ?? [""];
        data = prefs.getStringList('data') ?? [""];
        hora = prefs.getStringList('hora') ?? [""];
        numListAtiva = prefs.getInt('numListAtiva') ?? 0;
        semana = prefs.getStringList('semana') ?? ["0"];

        //ve se é a primeira vez que esta pegando o checklist

        if (prefs.getStringList('checkList') == null) {
          prefs.setStringList('checkList', [
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " ",
            " "
          ]);
        }

        // ------- desfaz checkliste apos o dia da semana selecionado -------
        desfazCheckList();
      }
    });
  }

  Future<void> desfazCheckList() async {
    /*---------------------------------------------------------------------- \
    |   Este metodo desfaz checkliste apos o dia da semana selecionado       |
    \ ----------------------------------------------------------------------*/

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      List<String>
          checkListTemporario; // cria um checklist temporario para poder
      // fazer a conversão de string para bool

      checkListTemporario = prefs.getStringList('checkList') ?? [" "];

      checkList.removeAt(0); // é meio q obrigatório ter uma informação inicial
      // no checklist pro codigo nao gerar erro, aqui essa informação é apagada

      int a = 0; // contador

      // ---------- desfaz checkliste apos o dia da semana selecionado ----------

      for (; a < objetivo.length; a++) {
        checkList.add(checkListTemporario[a] == " " ? false : true);

        if (semana.length > 1) {
          List<String> parteDaSemana = semana.sublist((a * 7), (7 * (a + 1)));

          for (int b = 0; b < 7; b++) {
            if (parteDaSemana.indexOf("1") != -1 &&
                checkListTemporario[a] != " ") {
              int diaObj = parteDaSemana.indexOf("1"); // primeiro dia d lista
              int diaAtu = DateTime.now().weekday; // dia da semana atual
              int diaCheck = DateTime.parse("20" +
                      checkListTemporario[a].substring(6, 8) +
                      "-" +
                      checkListTemporario[a].substring(3, 5) +
                      "-" +
                      checkListTemporario[a].substring(0, 2) +
                      " 00:00:00Z")
                  .weekday; // dia q foi dado o check

              if (diaAtu > diaObj && (diaObj > diaCheck || diaAtu < diaCheck)) {
                checkList[a] = false;
                checkListTemporario[a] = " ";
              }
              parteDaSemana[diaObj] = "0";
            }
          }
        }
      }

      // preenche o checklist
      for (; a < 20; a++) {
        checkList.add(checkListTemporario[a] == " " ? false : true);
      }

      // insere as novas informações do checklist na memoria
      prefs.setStringList('checkList', checkListTemporario);

      // --------------- removendo objetivos ultrapassados ----------------
      removerInfoVencido();
    });
  }

  Future<void> removerInfoVencido() async {
    /*---------------------------------------------------------------------- \
    |   Este metodo remove as informações dos objetivos que ja passaram da   |
    |   data de termino.                                                     |
    \ ----------------------------------------------------------------------*/

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // --------------- removendo objetivos ultrapassados ----------------

      List<String> checkListTemporario;
      // cria um checklist temporario para poder
      // fazer a conversão de string para bool

      checkListTemporario = prefs.getStringList('checkList') ?? [" "];

      List<String> horas = prefs.getStringList('horas') ?? ["00:00"];

      for (int i = 0; i < data.length; i++) {
        // recebe o trexo da informação que se refere a semana do objetivo
        // ( nao consegui criar matriz, entao vai list mesmo)
        if (semana.length > 1) {
          List<String> semanaTemporario =
              semana.sublist((i * 7), (7 * (i + 1)));

          // transforma a string que contem a data final do objetivo em DateTime
          DateTime dataObjetivo = DateTime.parse("20" +
              data[i].substring(6, 8) +
              "-" +
              data[i].substring(3, 5) +
              "-" +
              data[i].substring(0, 2) +
              " 10:00:00Z");

          // verifica se a data do objetivo ja vençeu ou se o checkliste foi
          //  selecionado a pelomenos um dia

          if ((dataObjetivo.add(const Duration(days: 1))).isAfter(
                      DateTime.parse("20" +
                          DateFormat('yy-MM-dd').format(DateTime.now()) +
                          " 10:00:00Z")) ==
                  false ||
              DateFormat('yy-MM-dd')
                      .format(dataObjetivo.add(const Duration(days: 1))) ==
                  (DateFormat('yy-MM-dd').format(DateTime.now())) ||
              (checkListTemporario[i] !=
                      DateFormat('dd/MM/yy').format(DateTime.now()) &&
                  checkListTemporario[i] != " " &&
                  semanaTemporario.indexOf("1") == -1)) {
            // --------------- remove ---------------------
            objetivo.removeAt(i);
            data.removeAt(i);
            hora.removeAt(i);
            checkList.removeAt(i);
            checkList.add(false);
            checkListTemporario.removeAt(i);
            checkListTemporario.add(" ");

            for (int a = 6; a > -1; a--) {
              semana.removeAt((i * 7) + a);
            }

            for (int a = 3; a > -1; a--) {
              horas.removeAt((i * 4) + a);
            }

            // ------------------- insere ---------------------
            prefs.setStringList('objetivo', objetivo);
            prefs.setStringList('data', data);
            prefs.setStringList('hora', hora);
            prefs.setStringList('semana', semana);
            prefs.setStringList('horas', horas);

            for (int a = 0; a < 20; a++) {
              checkListTemporario[a] =
                  checkList[a] == false ? " " : checkListTemporario[a];
            }

            prefs.setStringList('checkList', checkListTemporario);
            prefs.setInt(
                'numListAtiva', (prefs.getInt('numListAtiva') ?? 0) - 1);
            numListAtiva = prefs.getInt('numListAtiva');
            i--;
          }
        }
      }

      // completa a lista ate 20 casas
      for (int cont = (prefs.getStringList('objetivo')).length;
          cont < 20;
          cont++) {
        objetivo.add("");
        data.add("");
        hora.add("");
      }
    });
  }

  void pegarInfo() {
    // antes tinha mais coisa mas como dava dando erro de q metodo era lido primeiro tive q mudar
    if (jaPegouInformacao == false) {
      // garante q o app vai pegar só uma vez as informações
      jaPegouInformacao = true;

      setState(() {
        // ------------- Pega as informações da memória -----------------
        pegarInfomacao();
      });
    }
  }

  Future<void> gravarNumBotao(int num) async {
    /*---------------------------------------------------------------------- \
    |   Quando for precionado o botão do objetivo para entrar em sua         |
    |   configuração este metodo salvara qual botão foi apertado             |
    \ ----------------------------------------------------------------------*/

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('numBotaoAtual', num);
  }

  String pegarDiaSemanaSelecionado(int num, int dia) {
    /*---------------------------------------------------------------------- \
    |   Esta função verifica se o dia da semana enviado foi selecionado.     |
    |   Caso for, ele retorna a letra do dia da semana, caso não, retorna _  |
    \ ----------------------------------------------------------------------*/

    String letra = "_";

    if (semana.length > 1 && semana[num * 7 + dia] == "1") {
      switch (dia) {
        case 0:
          letra = "D";
          break;
        case 1:
          letra = "S";
          break;
        case 2:
          letra = "T";
          break;
        case 3:
          letra = "Q";
          break;
        case 4:
          letra = "Q";
          break;
        case 5:
          letra = "S";
          break;
        case 6:
          letra = "S";
          break;
      }
    }

    return letra;
  }

  Container criarObjetivo(int num) {
    /*---------------------------------------------------------------------- \
    |   Esta função cria toda a estrutura do objetivo que aparece na tela,   |
    |   caso o objetivo nao existir ainda, ele retornara uma estrutura vazia.|
    \ ----------------------------------------------------------------------*/

    if (num < numListAtiva) {
      return Container(
        color: AppConsts.corContainerObjetivo,
        alignment: Alignment.centerRight,
        padding: AppConsts.margemContainerObjetive,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Checkbox(
              value: checkList[num],
              onChanged: (bool value) {
                setState(() {
                  checkList[num] = value;
                  salvarCheckList();
                });
              },
            ),
            new ConstrainedBox(
              constraints: new BoxConstraints(minHeight: 70),
              child: SizedBox(
                width: setWidth(320),
                child: ElevatedButton(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "  " + objetivo[num] + "  ",
                        style: TextStyle(
                            fontSize: 20,
                            color: AppConsts.corLetraBotaoObjetivo(
                                checkList[num], data[num], hora[num]),
                            decoration: AppConsts.riscarLetraBotaoObjetivo(
                                checkList[num]),
                            decorationThickness: 2),
                      ), // 32
                      Text(
                          (data[num] == null ? "" : data[num]) +
                              "       " +
                              pegarDiaSemanaSelecionado(num, 0) +
                              " " +
                              pegarDiaSemanaSelecionado(num, 1) +
                              " " +
                              pegarDiaSemanaSelecionado(num, 2) +
                              " " +
                              pegarDiaSemanaSelecionado(num, 3) +
                              " " +
                              pegarDiaSemanaSelecionado(num, 4) +
                              " " +
                              pegarDiaSemanaSelecionado(num, 5) +
                              " " +
                              pegarDiaSemanaSelecionado(num, 6) +
                              "        " +
                              (hora[num] == null ? "" : hora[num]) +
                              "  ",
                          style: TextStyle(
                              fontSize: 14,
                              color: AppConsts.corLetraBotaoObjetivo(
                                  checkList[num], data[num], hora[num]))),
                    ],
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          AppConsts.corFundoBotaoObjetivo(
                              checkList[num], data[num], hora[num]))),
                  onPressed: () {
                    gravarNumBotao(num);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Pag2()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.transparent,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(bottom: 2, top: 2, right: 5),
      );
    }
  }

  @override
  void initState() {
    dados.firebase();
  }

  @override
  Widget build(BuildContext context) {
    /*---------------------------------------------------------------------- \
    |   O limite de objetivos que se pode criar é 20, se o objetivo existir  |
    |   ele chama a função criarObjetivo(), se não existir ele exibe uma     |
    |   mensagem instruindo a apertar o botao para criar um objetivo.        |
    \ ----------------------------------------------------------------------*/

    AppConsts.setWidthSize(MediaQuery.of(context).size.width);
    AppConsts.setHightSize(MediaQuery.of(context).size.height);
    pegarInfo();

    if (numListAtiva == 0) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '       Aperte o botão para\nadicionar um novo objetivo',
                style: TextStyle(fontSize: 18, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "bnt+",
          onPressed: () {
            gravarNumBotao(20);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Pag2()),
            );
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: ListView(
            children: <Widget>[
              criarObjetivo(0),
              criarObjetivo(1),
              criarObjetivo(2),
              criarObjetivo(3),
              criarObjetivo(4),
              criarObjetivo(5),
              criarObjetivo(6),
              criarObjetivo(7),
              criarObjetivo(8),
              criarObjetivo(9),
              criarObjetivo(10),
              criarObjetivo(11),
              criarObjetivo(12),
              criarObjetivo(13),
              criarObjetivo(14),
              criarObjetivo(15),
              criarObjetivo(16),
              criarObjetivo(17),
              criarObjetivo(18),
              criarObjetivo(19),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "bnt+",
          onPressed: () {
            gravarNumBotao(20);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Pag2()),
            );
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      );
    }
  }
}
