import 'dart:io';

import 'package:flutter/material.dart';

import '../bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
const assetsPath = "assets/developers/luke_pighetti/book_reader";

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      lowerBound: 0.37,
      upperBound: 1.0,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of(context).hasOnboarded.listen((hasOnboarded) {
      if (hasOnboarded)
        _controller.reverse();
      else
        _controller.forward();
    });

    final mainContainer = Container(
      alignment: Alignment.topCenter,
      child: SizeTransition(
        sizeFactor: _animation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Icon(),
            Text(
              "Discover. Learn. Elevate.",
              style: TextStyle(fontSize: 24.0, color: Colors.white),
            ),
            SizedBox(height: 36.0),
            _Button(),
          ],
        ),
      ),
    );

    return SafeArea(
      child: Stack(
        children: <Widget>[
          mainContainer,
          BackButton(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Icon extends StatefulWidget {
  @override
  __IconState createState() => __IconState();
}

class __IconState extends State<_Icon> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      lowerBound: 0.6,
      upperBound: 1.0,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);

    bloc.hasOnboarded.listen((hasOnboarded) {
      if (hasOnboarded)
        _controller.reverse();
      else
        _controller.forward();
    });

    return ScaleTransition(
      alignment: Alignment.bottomCenter,
      scale: _animation,
      child: Container(
        padding: EdgeInsets.only(bottom: 36.0),
        child: Image.asset(
          "$assetsPath/logo.png",
          width: 90.0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Button extends StatefulWidget {
  @override
  __ButtonState createState() => __ButtonState();
}

class __ButtonState extends State<_Button> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

//  var twitterLogin = new TwitterLogin(
//    consumerKey: 'k8n2hJMd1rYj8Xt0Sq1JdgMZa',
//    consumerSecret: '5kHYsJ6XoHmpG37kA4pg1HY0xGHnpaeX6NjqvL1Rt3TV46uTW3',
//  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);

    bloc.hasOnboarded.listen((hasOnboarded) {
      if (hasOnboarded)
        _controller.reverse();
      else
        _controller.forward();
    });


    return FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.hasData) {
            FirebaseUser user = snapshot.data; // this is your user instance
            /// is because there is user already logged
            bloc.onboarded(true);
          }

          /// other way there is no user logged.
          return FadeTransition(
              opacity: _animation,
              child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SignInButton(
                      Buttons.Twitter,
                      mini: false,
                      onPressed: () async {
//                        final TwitterLoginResult result = await twitterLogin
//                            .authorize();
//
//                        switch (result.status) {
//                          case TwitterLoginStatus.loggedIn:
//                            final AuthCredential credential = TwitterAuthProvider
//                                .getCredential(
//                                authToken: result.session.token,
//                                authTokenSecret: result.session.secret);
//                            final FirebaseUser user =
//                                (await _auth.signInWithCredential(credential))
//                                    .user;
//                            bloc.onboarded(true);
//                            break;
//                          case TwitterLoginStatus.cancelledByUser:
//                            break;
//                          case TwitterLoginStatus.error:
//                            break;
//                        }
                      },
                    ),
                    SignInButton(
                      Buttons.Google,
                      mini: false,
                      onPressed: () {
                       _handleSignIn();
                        if(_googleSignIn.isSignedIn() != null){
                          bloc.onboarded(true);
                        }
                      },
                    ),
                    SignInButton(
                      Buttons.Facebook,
                      mini: false,
                      onPressed: () async {
                        final facebookLogin = FacebookLogin();
                        final result =
                        await facebookLogin.logInWithReadPermissions(['email']);

                        switch (result.status) {
                          case FacebookLoginStatus.loggedIn:
                            final AuthCredential credential =
                            FacebookAuthProvider.getCredential(
                                accessToken: result.accessToken.token);
                            final FirebaseUser user =
                                (await _auth.signInWithCredential(credential)).user;
                            print("facebook loggedin:: " + result.accessToken.userId);
                            bloc.onboarded(true);

//                  Navigator.push(
//                      context,
//                      new MaterialPageRoute(
//                          builder: (context) =>
//                              MyApp()
//
////              new Image.network(
////                document['postPath'],
////                fit: BoxFit.none,
//////                height: MediaQuery.of(context).size.width,
//////                width: MediaQuery.of(context).size.width,
////                alignment: Alignment.center,
////              ),
//                      ));
                            break;
                          case FacebookLoginStatus.cancelledByUser:
//                  _showCancelledMessage();
                            break;
                          case FacebookLoginStatus.error:
//                  _showErrorOnUI(result.errorMessage);
                            break;
                        }
                      },
                    ),
                    SignInButton(
                      Buttons.Email,
                      mini: false,
                      onPressed: () {

                      },
                    ),
                    SignInButton(
                      Buttons.LinkedIn,
                      mini: false,
                      onPressed: () {

                      },
                    ),
                  ])
                ,)
//      Center(
//        child: RaisedButton(
//          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
//          onPressed: () => bloc.onboarded(true),
//          child: Text(
//            "START EXPLORING",
//            style: TextStyle(fontWeight: FontWeight.bold),
//          ),
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(99.9),
//          ),
//        ),
//      ),
          );
        }
    );


//    Future<bool> user=checkLoginStatus();

  }



  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  Future<bool> checkLoginStatus() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'test',
      options: FirebaseOptions(
        googleAppID: Platform.isIOS
            ? '1:886993795008:ios:d682d7e2aee1bf4a'
            : '1:886993795008:android:d682d7e2aee1bf4a',
//      gcmSenderID: '159623150305',
        apiKey: 'AIzaSyDYE13jkl283raYvE0MfmZfZOVwCsmHd70',
        projectID: 'polls-223422',
      ),
    );
    final FirebaseStorage storage =
    FirebaseStorage(app: app, storageBucket: 'gs://polls-223422.appspot.com');
    bool loggedIn = false;
    String userUID;
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user != null) {
        loggedIn = true;
        userUID = user.uid;
      }
    });

    if (loggedIn) {
      //bloc.onboarded(true);
    } else {}
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }
}

class BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(18),
      icon: Icon(Icons.arrow_back_ios),
      color: Colors.white,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
