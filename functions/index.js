const functions = require('firebase-functions')
const admin = require('firebase-admin');
const { DataSnapshot } = require('firebase-functions/lib/providers/database');
admin.initializeApp()
const firestore = admin.firestore()


//push通知実行メソッド
const pushMessage = (fcmToken, text) => ({
  notification: {
      title: '新しいオファーを受信しました。',
      body:  `${text}`,
  },
  apns: {
      headers: {
          'apns-priority': '10'
      },
      payload: {
          aps: {
              badge: 9999,
              sound: 'default'
          }
      }
  },
  data: {
      data: 'test',
  },
  token: fcmToken
});



///関数
exports.mySendMessages = functions.region('asia-northeast1')
  .runWith({ memory: '512MB' })
  .pubsub.schedule('every 3 minutes')//関数を実行する時間間隔が設定できる
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {

    // 秒を切り捨てた現在時刻
    const now = (() => {
      let s = admin.firestore.Timestamp.now().seconds
      s = s - s % 60
      return new admin.firestore.Timestamp(s, 0)
    })()

    //秒を切り捨てた昨日の時刻（マイナス１２時間）
    const yesterday = (() => {
      let s = admin.firestore.Timestamp.now().seconds
      s = s - 86400
      return new admin.firestore.Timestamp(s, 0)
    })()

    //秒を切り捨てた明日の時刻（プラス１２時間）
    const tomorrow = (() => {
      let s = admin.firestore.Timestamp.now().seconds
      s = s + 43200
      return new admin.firestore.Timestamp(s, 0)
    })()


    ///時刻の確認
    console.log('now', now.toDate())
    console.log('yesterday', yesterday.toDate())
    console.log('tomorrow', tomorrow.toDate())
    
    
    //try（うまくデータが取れた！）
    const pushDataRef = firestore.collection('pushData');
    const snapshot = await pushDataRef.where('postAt', '>=', yesterday).where('postAt', '<=', tomorrow).get();
    if (snapshot.empty) {
      console.log('No matching documents.');
      return;
    }
    snapshot.forEach(doc => {
      console.log(doc.id, '=>', doc.data());
      console.log(doc.data()['postAt']);
      //通知送信
      const token = doc.data()['fcmToken']
      const title = doc.data()['title']
      admin.messaging().send(pushMessage(token, title))
    });
    

      // firestoreのタイムスタンプデータ確認用
      // const pushDataRef = firestore.collection('pushData').doc('test');
      // const documentSnapshot = await pushDataRef.get();
      // if (documentSnapshot.empty) {
      //   console.log('No matching documents.');
      //   return;
      // }
      // console.log(documentSnapshot.data());
      // console.log(documentSnapshot.data()['postAt'].toDate())        
      
  })//.onRun



  // //↓memo
      // var receiversData;
      // //firestore.collection('pushData').doc('test').get()
      // await firestore.collection('pushData').where('postAt', '>=', yesterday).where('postAt', '<=', tomorrow).get()
      //   .then((doc) => {    //collectionでgetしているので、map処理しなければいけない。
      //     if (doc.exists) {
      //       console.log("Document data:", doc.data());
      //       //receiversData = doc.data();//dataが一つしかない時はこれでOK？
      //       receiversData = doc.forEach(element => {
      //         element.data()
      //       });
      //     }
      //   }).then(() => {
      //     console.log(receiversData);
      //     const token = receiversData['fcmToken']
      //     const title = receiversData['title']
      //     admin.messaging().send(pushMessage(token, title))
      //       .then((response) => { console.log('Successfully sent message:', response) })
      //       .catch((e) => { console.log('Error sending message:', e) })
      //   }).catch(function (error) {
      //     console.log("Error getting document:", error);
      //   });