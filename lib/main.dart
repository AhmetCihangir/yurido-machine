import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBmbHu2nx5UJ98650gElwH4Lbh8QZl_WVw",
      appId: "1:709192516020:web:c08b30015a9bcf02f8f2e1",
      messagingSenderId: "709192516020",
      projectId: "hackathon-warn",
      authDomain: "hackathon-warn.firebaseapp.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QrContainer(),
    );
  }
}

class QrContainer extends StatefulWidget {
  const QrContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<QrContainer> createState() => _QrContainerState();
}

class _QrContainerState extends State<QrContainer> {
  double price = 1.0;
  String uudi = Uuid().v4();

  @override
  void initState() { 
    super.initState();
    // catchTransactions();
  }

  void resetQr(){
    setState(() {
      uudi = Uuid().v4();
    });
  }

  void catchTransactions(){
    final Query _transactionsStream = FirebaseFirestore.instance.collection("transactions").where("uuid", isEqualTo: uudi);

    _transactionsStream.snapshots().listen((event) { 
      event.docChanges.forEach((element) { 
        setState(() {
          price += (element.doc.data()! as Map<String, dynamic>)["price"] / 100;
        });
       });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("${price.toStringAsFixed(2)}"),
          QrImage(
            data: uudi,
            size: 300,
          ),
          SizedBox(
            height: 200,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("transactions").where("uid", isEqualTo: uudi).snapshots(),
              builder: ( context, AsyncSnapshot<QuerySnapshot> streamSnapshot ){
                if(streamSnapshot.connectionState == ConnectionState.waiting){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (ctx, index){

                    double number = price + streamSnapshot.data!.docs[index]["price"];

                    return Container(height: 50,width : 50,child: (Text(number.toStringAsFixed(2))));
                    // return Container(height: 50,width : 50,child: (Text(streamSnapshot.data!.docs[index]["price"].toString())));
                  } ,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

