import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//firebase_auth: "^0.18.4"

class FirestoreIslemleri extends StatefulWidget {
  @override
  _FirestoreIslemleriState createState() => _FirestoreIslemleriState();
}

class _FirestoreIslemleriState extends State<FirestoreIslemleri> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  PickedFile _secilenResim;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
            RaisedButton(
              child: Text("transaction Ekle"),
              color: Colors.red,
              onPressed: _transactionEkle,
            ),
            RaisedButton(
              child: Text("veri Sil"),
              color: Colors.yellow,
              onPressed: _veriSil,
            ),
            RaisedButton(
              child: Text("veri Oku"),
              color: Colors.purple,
              onPressed: _veriOku,
            ),
            RaisedButton(
              child: Text("veri Sorgula"),
              color: Colors.pink,
              onPressed: _veriSorgula,
            ),
            RaisedButton(
              child: Text("galeri resim Sorgula"),
              color: Colors.cyan,
              onPressed: _galeriResimUpload,
            ),
            RaisedButton(
              child: Text("kamera resim  Sorgula"),
              color: Colors.black12,
              onPressed: _kameraResimUpload,
            ),
            Expanded(
              child: _secilenResim == null
                  ? Text("Resim yok ")
                  : Image.file(File(_secilenResim.path)),
            )
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

    _firestore.doc("users/omer_ozkokeli").update({
      "ad": "omerupdate",
      "yas": "23",
      "eklenme": FieldValue.serverTimestamp(),
      "beğeni sayısı": FieldValue.increment(10)
    }).then((v) {
      debugPrint("omerupdate güncellendi");
    });
  }

  void _transactionEkle() {
    final DocumentReference omerRef = _firestore.doc("users/omer_ozkokeli");
    _firestore.runTransaction((transaction) async {
      DocumentSnapshot omerData = await omerRef.get();

      if (omerData.exists) {
        var omerinParasi = omerData.data()["para"];
        if (omerinParasi > 100) {
          await transaction.update(omerRef, {"para": (omerinParasi - 100)});
          await transaction.update(_firestore.doc("users/numan"),
              {"para": FieldValue.increment(100)});
        } else {
          debugPrint("yetersiz bakiye ");
        }
      } else {
        debugPrint("omer dökümanı yok ");
      }
    });
  }

  void _veriSil() {
    _firestore
        .doc("users/silinecek")
        .delete()
        .then((a) => debugPrint("ayse silindi"))
        .catchError((e) => debugPrint("hata alındı " + e.toString()));

    _firestore
        .doc("users/silinecek")
        .update({"ad": FieldValue.delete()})
        .then((aa) => debugPrint("ad silindi"))
        .catchError((e) => debugPrint("ad silinemedi" + e.toString()));
  }

  Future _veriOku() async {
    //tek tek döküman okuma
    DocumentSnapshot documentSnapshot =
        await _firestore.doc("users/omer_ozkokeli").get();
    debugPrint("Döküman id:" + documentSnapshot.id);
    debugPrint("Döküman var mı:" + documentSnapshot.exists.toString());
    debugPrint("Döküman string: " + documentSnapshot.toString());
    debugPrint("bekleyen yazma var mı:" +
        documentSnapshot.metadata.hasPendingWrites.toString());
    debugPrint("cacheden mi geldi:" +
        documentSnapshot.metadata.isFromCache.toString());
    debugPrint("cacheden mi geldi:" + documentSnapshot.data().toString());
    debugPrint("cacheden mi geldi:" + documentSnapshot.data()['ad']);
    debugPrint(
        "cacheden mi geldi:" + documentSnapshot.data()['para'].toString());
    documentSnapshot.data().forEach((key, deger) {
      debugPrint("key : $key deger :deger");
    });
    //koleksiyon okuma
    _firestore.collection("users").get().then((topluGetirme) {
      debugPrint("koleksiyondaki veri sayıları" + topluGetirme.docs.toString());
      for (int i = 0; i < topluGetirme.docs.length; i++) {
        debugPrint(topluGetirme.docs[i].data().toString());
      }
      //anlık değişikliklrin dinlenmesi
      var ref = _firestore.collection("users").doc("omer_ozkokeli");
      ref.snapshots().listen((degisenVeri) {
        debugPrint("anlık okunan veri " + degisenVeri.data().toString());
      });
      //uzunluğunu bulma
      _firestore.collection("users").snapshots().listen((snap) {
        debugPrint(snap.docs.length.toString());
      });
    });
  }

  void _veriSorgula() async {
    var dokumanlar = await _firestore
        .collection("users")
        .where("email", isEqualTo: "omer@omer.com")
        .get();
    for (var dokuman in dokumanlar.docs) {
      debugPrint(dokuman.data().toString());
    }

    var limitliGetir =
        await _firestore.collection("users").limit(3).getDocuments();
    for (var dokuman in limitliGetir.docs) {
      debugPrint("Limitli getirenler" + dokuman.data().toString());
    }
    var diziSorgula = await _firestore
        .collection("users")
        .where("diziler", arrayContains: 'himym')
        .get();
    for (var dokuman in diziSorgula.docs) {
      debugPrint("Diziler şartı ile getirenler" + dokuman.data.toString());
    }
    var stringSorgula = await _firestore
        .collection("users")
        .orderBy("email")
        .startAt(['emre']).endAt(['emre' + '\uf8ff']).get();
    for (var dokuman in stringSorgula.docs) {
      debugPrint("String sorgula ile getirenler" + dokuman.data.toString());
    }

    _firestore.collection("users").doc("omer_ozkokeli").get().then((docSnap) {
      debugPrint("omerin verileri" + docSnap.data().toString());

      _firestore
          .collection("users")
          .orderBy('begeni sayısı')
          .endAt([docSnap.data()['begeni sayısı']])
          .get()
          .then((querySnap) {
            if (querySnap.docs.length > 0) {
              for (var bb in querySnap.docs) {
                debugPrint("emrenin begenisinden fazla olan user:" +
                    bb.data().toString());
              }
            }
          });
    });
  }

  void _galeriResimUpload() async {
    var _picker = ImagePicker();
    var resim = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      _secilenResim = resim;
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child("user")
        .child("emre")
        .child("profil.png");
    var uploadTask = ref.putFile(File(_secilenResim.path));

    var url =
        await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
    debugPrint("upload edilen resmin urlsi : " + url);
  }

  void _kameraResimUpload() async {
    var resim = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _secilenResim = resim;
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child("user")
        .child("hasan")
        .child("profil.png");
    var uploadTask = ref.putFile(File(_secilenResim.path));

    var url =
        await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
    debugPrint("upload edilen resmin urlsi : " + url);
  }
}
