import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main.dart';

///別のページでメインモデルを使うには以下をconsumer(_, watch, _)のwatchに入れる
final mainModelPageProvider =
    ChangeNotifierProvider.autoDispose((ref) => Models());

class Models extends ChangeNotifier {
  final firestore = FirebaseFirestore.instance;
  String remind = '';
  Timestamp postdate = Timestamp.now();
  String? _serchToken;

  Future add() async {
    _serchToken = exportedToken;
    print('$_serchToken');

    ///①_serchToken == null　トークンが取得できなかった→　エラーを知らせる
    ///②下記”doc”は今までなかった（新しい端末）→UserコレクションにドキュメントIDは（_serchToken）を新しく作る（/Users/_serchToken/pushData/自動ID/{title, postAt, fcmToken}）
    ///③下記”doc”はすでにドキュメントに存在する（既存の端末）→/Users/_serchToken/pushData配下に新しいドキュメントとフィールド（/Users/_serchTokenpushData/自動ID/{title, postAt, fcmToken}）を追加する

    ///コレクションは名前を指定する必要がある
    //1
    if (_serchToken!.isEmpty) {
      print('isEmpty');
      return;
    }

    ///(.add  .doc().set())
    //2,3
    await firestore
        // .collection('Users')
        // .doc(_serchToken)
        .collection('pushData')
        .add(
      {
        'title': remind,
        //TODO: 指定できるようにする
        'postAt': postdate, //Timestamp.now(),
        'fcmToken': _serchToken,
      },
    );
  }
}
