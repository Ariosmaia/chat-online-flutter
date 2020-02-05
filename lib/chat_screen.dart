import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();

    // Sempre que a autenticação mudar
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      // Login no Google
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      // Transformar login do Google em um Login do Firebase
      // Tem um token e um token de acesso
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      // Credeciais do Firebase
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Login no Firebase
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Pegar usuario do Firebase
      final FirebaseUser user = authResult.user;

      return user;
    } catch (e) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Não foi possível fazer o login. Tente novamente!'),
          backgroundColor: Colors.red,
        ),
      );
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "sendName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now()
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(
            DateTime.now().millisecondsSinceEpoch.toString(),
          )
          .putFile(imgFile);

      setState(() {
        _isloading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState(() {
        _isloading = false;
      });
    }

    if (text != null) data['text'] = text;

    Firestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser.displayName}'
            : 'Chat App'),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('Você saiu com sucesso'),
                      ),
                    );
                  })
              : Container(),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('messages')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: ChatMessage(
                              data: documents[index].data,
                              mine: documents[index].data['uid'] ==
                                  _currentUser?.uid),
                        );
                      },
                    );
                }
              },
            ),
          ),
          _isloading ? LinearProgressIndicator() : Container(),
          TextComposer(sendMessage: _sendMessage),
        ],
      ),
    );
  }
}
