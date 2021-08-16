import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';

class AddPush extends StatelessWidget {
  const AddPush({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context,
        T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
      final model = watch(mainModelPageProvider);
      return Scaffold(
        appBar: AppBar(
          title: Text('通知したい'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            model.add();///firestoreにデータをアップロードする
          },
          child: Icon(Icons.add),
        ),
        body: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                  labelText: '通知に表示させるテキストを入力', hintText: '例：つよぴの誕生日'),
              onChanged: (text) {
                model.remind = text;
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'いつ通知を送りますか', hintText: '2021-08-10'
              ),
              onChanged: (date){
                model.postdate = Timestamp.fromDate(DateTime.parse(date));
              },
            ),
            SizedBox(
              height: 12,
            ),
          ],
        ),
      );
    });
  }
}
