import 'dart:async' show Stream;
import 'dart:io';
import 'dart:math';
import 'package:developers/TrendingMasterObject.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart' show BehaviorSubject;
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';
import 'mock.dart' as Mocks;

class HomeBloc {
  /// onboarding
  final _subject = BehaviorSubject<bool>(seedValue: false);
  Stream<bool> get hasOnboarded => _subject.stream;
  void onboarded(bool boolean) => _subject.add(boolean);

  Future<FirebaseStorage> initialize() async {
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
    final FirebaseStorage storage = FirebaseStorage(app: app, storageBucket: 'gs://polls-223422.appspot.com');
  }

  /// books
  final _booksSubject = BehaviorSubject<List<Book>>(seedValue: Mocks.books);
  Stream<List<Book>> get books => _booksSubject.stream;

  final trending = BehaviorSubject<List<TrendingList>>(seedValue: trendingMasterObject());
  Stream<List<TrendingList>> get trendings => trending.stream;

  /// scroll position
  final _scrollSubject = BehaviorSubject<double>(seedValue: 0.0);
  Stream<double> get scrollPosition => _scrollSubject.stream;
  void setScrollPosition(double value) => _scrollSubject.add(value);

  /// color
  final _colorSubject = BehaviorSubject<Color>(seedValue: Color(0xFF323CCE));
  Stream<Color> get currentColor => _colorSubject.stream;
  void setColor(ColorTransition _transition) =>
      _colorSubject.add(_transition.blendedColor);
  static List<TrendingList> trendingMasterObject() {
     List<TrendingList> trendingList1=new List();

    Firestore.instance.collection('votes').orderBy(
        'creationDateTime', descending: true).snapshots()
        .listen((data) =>
        data.documents.forEach((doc) =>trendingList1.add(trend(doc)),

        ));
    return trendingList1;
  }

  static TrendingList trend(DocumentSnapshot doc){
    TrendingList trending1 =new TrendingList();
    trending1.mainDisplay=doc['postPath'];
    trending1.description=doc['description'];
    trending1.allowedVoteNumber=doc['allowedVoteNumber'];
//    trending1.descriptionType=doc[''];
    trending1.owner=doc['owner'];
    trending1.profilePic=doc['profile_pic'];
    trending1.title=doc['title'];
    trending1.time=doc['time'];
    trending1.voteBy=doc['voteBy'];
    trending1.voteId=doc['vote_id'];
    trending1.votesCasted=doc['casted_votes'];
    trending1.voteType=doc['voteType'];
    trending1.color= Colors.primaries[Random().nextInt(Colors.primaries.length)];
    trending1.id=doc.documentID;
    return trending1;
  }

}

///
/// provider
///
class BlocProvider extends InheritedWidget {
  final HomeBloc homeBloc;

  BlocProvider({
    Key key,
    HomeBloc homeBloc,
    Widget child,
  })  : homeBloc = homeBloc ?? HomeBloc(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static HomeBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider)
          .homeBloc;
}
