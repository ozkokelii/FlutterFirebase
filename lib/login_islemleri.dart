import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class LoginIslemleri extends StatefulWidget {
  @override
  _LoginIslemleriState createState() => _LoginIslemleriState();
}

class _LoginIslemleriState extends State<LoginIslemleri> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('oturumu kapattı ');
      } else {
        print('oturumunu açtı ');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login İşlemleri"),
      ),
      body: Center(
        child: Column(
          children: [
            RaisedButton(
              child: Text("Email/Sifre User account"),
              color: Colors.blueAccent,
              onPressed: _emailSifreKullaniciOlustur,
            ),
            RaisedButton(
              child: Text("Email/Sifre User login"),
              color: Colors.green,
              onPressed: _emailSifreKullaniciGirisYapti,
            ),
            RaisedButton(
              child: Text("Email/Sifre Password forget"),
              color: Colors.red,
              onPressed: _resetPassword,
            ),
            RaisedButton(
              child: Text("Sifre update"),
              color: Colors.pink,
              onPressed: _updatePassword,
            ),
            RaisedButton(
              child: Text("Email Güncelle"),
              color: Colors.brown,
              onPressed: _updateEmail,
            ),
            RaisedButton(
              child: Text("Gmail ile Giriş"),
              color: Colors.tealAccent,
              onPressed: _googleIleGiris,
            ),
            RaisedButton(
              child: Text("Telefon No ile Giriş"),
              color: Colors.lightGreen,
              onPressed: _telNoGiris,
            ),
            RaisedButton(
              child: Text("Email/Sifre User out"),
              color: Colors.transparent,
              onPressed: _cikisYap,
            ),
          ],
        ),
      ),
    );
  }

  void _emailSifreKullaniciOlustur() async {
    String _email = "flutterdeneme@mail.com.tr";
    String _password = "password";
    try {
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      User _yeniUser = _credential.user;
      await _yeniUser.sendEmailVerification();
      if (_auth.currentUser != null) {
        debugPrint("size mail attık bak bi");
        await _auth.signOut();
        debugPrint("kullanıcıyi sistemdn attım ");
      }
      debugPrint(_yeniUser.toString());
    } catch (e) {
      debugPrint("**************HATA VAR ");
      debugPrint(e.toString());
    }
  }

  void _emailSifreKullaniciGirisYapti() async {
    String _email = "flutterdeneme@mail.com.tr";
    String _password = "passwordd";
    try {
      if (_auth.currentUser == null) {
        User _oturumAcanUser = (await _auth.signInWithEmailAndPassword(
                email: _email, password: _password))
            .user;
        if (_oturumAcanUser.emailVerified) {
          debugPrint("mail onayalı thanks");
        } else {
          debugPrint("mail onayalyıp tekrar giriş yapınız");
          _auth.signOut();
        }
      } else {
        debugPrint("oturum açmış kullanıcı var ");
      }
    } catch (e) {
      debugPrint("****************HATA VAR");
      debugPrint(e.toString());
    }
  }

  void _cikisYap() async {
    if (_auth.currentUser != null) {
      await _auth.signOut();
    } else {
      debugPrint("zaten oturum açmış kullanıcı yok");
    }
  }

  void _resetPassword() async {
    String _email = "flutterdeneme@mail.com.tr";
    try {
      await _auth.sendPasswordResetEmail(email: _email);
      debugPrint("resetleme maili gönderildi");
    } catch (e) {
      debugPrint("şifre sıfırlanırken hata oluştu: $e ");
    }
  }

  void _updatePassword() async {
    try {
      await _auth.currentUser.updatePassword("passwordd");
      debugPrint("şifreniz güncellendi");
    } catch (e) {
      try {
        String email = 'flutterdenem@mail.com.tr';
        String password = 'passwordd';
        EmailAuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await FirebaseAuth.instance.currentUser
            .reauthenticateWithCredential(credential);
        debugPrint("girilen eski email şifre bilgisi doğru ");
        await _auth.currentUser.updatePassword("passwordd");
        debugPrint("oturum yeniden açıldı ve şifrede güncellendi ");
      } catch (e) {
        debugPrint("şifre güncellenriken hata çıktı $e");
      }
    }
  }

  void _updateEmail() async {
    try {
      await _auth.currentUser.updateEmail("emrealtunbilek06@gmail.com");
      debugPrint("Enailiniz güncellendi");
    } on FirebaseAuthException catch (e) {
      try {
        //kullanıcıdan eski oturum bilgileri girmesi istenir
        String email = 'emrealtunbilek06@gmail.com';
        String password = 'password2';

        EmailAuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await FirebaseAuth.instance.currentUser
            .reauthenticateWithCredential(credential);

        //güncel email ve şifre bilgisi dogruysa eski şifresi yenisiyle güncellenir.
        debugPrint("Girilen eski email şifre bilgisi dogru");
        await _auth.currentUser.updateEmail("emre@emre.com");
        debugPrint("Auth yeniden saglandı, mail de güncellendi");
      } catch (e) {
        debugPrint("hata çıktı $e");
      }

      debugPrint("Email güncellenirken hata çıktı $e");
    }
  }

  Future<UserCredential> _googleIleGiris() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("gmail girişi hata $e");
    }
  }

  void _telNoGiris() async {
    //+90 554 712 66 33
    // 987654
    await _auth.verifyPhoneNumber(
      phoneNumber: '+90 554 712 66 33',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("verfication failed hata : $e");
      },
      codeSent: (String verificationId, int resendToken) async {
        debugPrint("kod yollandı");

        try {
          String smsCode = '987654';

          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential phoneAuthCredential =
              PhoneAuthProvider.credential(
                  verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await _auth.signInWithCredential(phoneAuthCredential);
        } catch (e) {
          debugPrint("kod hata : $e");
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint("timeouta düştü");
      },
    );
  }
}
