import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());

  // Escrever ou ler
  Firestore.instance
      // Qual coleção viu usar
      .collection('mensagens')
      // Qual o documento
      // Deixar vazio cria um id unico
      .document('ble7RdMCzl7se8Mjagu3')
      // Qual dados vou colocar
      .setData({"texto": "Td bem?", "from": "Marcelo", "read": false});

  // Para atualizar só um dado posso usar o updateData ao invés de setData
  Firestore.instance
      .collection('mensagens')
      .document('ble7RdMCzl7se8Mjagu3')
      .updateData({"read": true});

  // Subcoleções
  Firestore.instance
      .collection('mensagens')
      .document('ble7RdMCzl7se8Mjagu3')
      .collection('arquivos')
      .document()
      .setData({"arqname": 'foto.png'});
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(),
    );
  }
}
