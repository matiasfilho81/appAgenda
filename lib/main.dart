import 'package:flutter/material.dart';
import 'dart:core';

import 'package:agenda/Pag1.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// ---------------- map para personalizar a primarySwatch --------------

Map<int, Color> tonsCorPersonalizada = {
  50: Color.fromRGBO(95, 141, 241, .1),
  100: Color.fromRGBO(95, 141, 241, .2),
  200: Color.fromRGBO(95, 141, 241, .3),
  300: Color.fromRGBO(95, 141, 241, .4),
  400: Color.fromRGBO(95, 141, 241, .5),
  500: Color.fromRGBO(95, 141, 241, 1),
  600: Color.fromRGBO(95, 141, 241, .7),
  700: Color.fromRGBO(95, 141, 241, .8),
  800: Color.fromRGBO(95, 141, 241, .9),
  900: Color.fromRGBO(95, 141, 241, 1),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MaterialColor corPrimariaPersonalizada =
        MaterialColor(0xFF5F8DF1, tonsCorPersonalizada);

    return MaterialApp(
      title: 'Agenda',
      theme: ThemeData(
        primarySwatch: corPrimariaPersonalizada,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Pag1(title: 'Agenda'),
    );
  }
}
