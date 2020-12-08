import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//firebase_auth: "^0.18.4"

class FirestoreIslemleri extends StatefulWidget {
  @override
  _FirestoreIslemleriState createState() => _FirestoreIslemleriState();
}

class _FirestoreIslemleriState extends State<FirestoreIslemleri> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore İşlemleri"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Veri ekle"),
              color: Colors.green,
              onPressed: _veriEkle,
            ),
          ],
        ),
      ),
    );
  }

  void _veriEkle() {
    Map<String, dynamic> omerEkle = Map();
    omerEkle["ad"] = "omer";
    omerEkle["lisansMezunu"] = true;

    _firestore
        .collection("users")
        .doc("omer_ozkokeli")
        .set(omerEkle, SetOptions(merge: true))
        .then((v) => debugPrint("omer eklendi"));
    _firestore
        .collection("users")
        .doc("omer_oz")
        .set({"ad": "ozommer", "cinsiyet": "erkek"}).whenComplete(
            () => debugPrint("ozomer eklendi"));
    _firestore.doc("users/numan").set({"ad": "numanımsı", "il": "houston"});
    _firestore
        .collection("users")
        .add({"ad": "omer", "gideceği yer ": "kanadainş"});

    String yeniKullaniciID = _firestore.collection("users").doc().id;
    debugPrint("yeni kullanıcı idsi : $yeniKullaniciID");
    _firestore
        .doc("users/$yeniKullaniciID")
        .set({"ad": "yeniid", "yeni id": "$yeniKullaniciID"});
  }
}
