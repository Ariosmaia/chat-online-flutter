import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());

  // Ler somente uma vez
  QuerySnapshot snapshot =
      await Firestore.instance.collection('mensagens').getDocuments();
  snapshot.documents.forEach((d) {
    print(d.data);

    // Ler pelo ID do documento
    print(d.documentID);

    // Atualizar cada um dos documentos
    d.reference.updateData({'read': true});
  });

  // Dados de uma imagem em especifico
  DocumentSnapshot snapshotDoc = await Firestore.instance
      .collection('mensagens')
      .document('XYyfrLKPzQcH1YNRT6vi')
      .get();
  print(snapshotDoc.data);

  // Atualizações em tempo real coleções
  Firestore.instance.collection('mensagens').snapshots().listen((dado) {
    dado.documents.forEach((d) {
      print(d.data);
    });
  });

  // Atualizações em tempo real documentos
  Firestore.instance
      .collection('mensagens')
      .document('XYyfrLKPzQcH1YNRT6vi')
      .snapshots()
      .listen((dado) {
    print(dado.data);
  });
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
