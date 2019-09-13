import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:developers/start_rating.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:simple_countdown/simple_countdown.dart';

class StarRatings extends StatelessWidget {
  final String voteID, memberID;
  int castedVoteNumber;

  StarRatings(this.voteID, this.memberID);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('casted_votes')
              .where('vote_id', isEqualTo: voteID)
              .where('member_id', isEqualTo: memberID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            try {
              if (snapshot.hasData) {
                return MyHomePage(
                  castedVoteNumber: double.parse(snapshot.data.documents
                      .elementAt(0)['vote_number']
                      .toString()),
                  voteID: voteID,
                  memberID: memberID,
                  voteNumber: 1,
                );
              } else if (snapshot.hasError) {}
            } catch (e) {
              return MyHomePage(
                title: 'Star Rating Demo Home Page',
                castedVoteNumber: 0.0,
                voteID: voteID,
                memberID: memberID,
                voteNumber: 0,
              );
            }
          },
        ));
  }
}

class MyHomePage extends StatefulWidget {
  double castedVoteNumber;
  String voteID, memberID;
  int voteNumber;

  MyHomePage(
      {Key key,
      this.title,
      this.castedVoteNumber,
      this.voteID,
      this.memberID,
      this.voteNumber})
      : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(
      castedVoteNumber, castedVoteNumber, voteID, memberID, voteNumber);
}

class _MyHomePageState extends State<MyHomePage> {
  double castedVoteNumber;
  AnimationController _controller;
  String voteID, memberID;
  int voteNumber;
  final int starLength = 5;
  double _rating;

  _MyHomePageState(this._rating, this.castedVoteNumber, this.voteID,
      this.memberID, this.voteNumber);

  int countDownValue = 15;

  void _incrementHalfStar() {
    if (voteNumber != 1) {
      setState(() {
        countDownValue = 5;
        _rating += 0.5;
        if (_rating > starLength) {
          _rating = starLength.toDouble();
        }
      });
    } else {
//      _showSnackBar(context, "maximum votes for this poll have already been reached.");
    }
  }

  /// This will show snackbar at bottom when user tap on Grid item
  _showSnackBar(BuildContext context, String item) {
    final SnackBar objSnackbar = new SnackBar(
      content: new Text(
        item,
        style: TextStyle(fontSize: 11),
      ),
      backgroundColor: Colors.blueGrey,
    );

    Scaffold.of(context).showSnackBar(objSnackbar);
  }

  void _decrementHalfStar() {
    if (voteNumber != 1) {
      setState(() {
        countDownValue = 5;
        _rating -= 0.5;
        if (_rating < 0.0) {
          _rating = 0.0;
        }
      });
    } else {
//      _showSnackBar(context, "maximum votes for this poll have already been reached.");
    }
  }
  String popularRating='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomPadding: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 1,
          ),
          Row(
            children: <Widget>[
              StarRating(
                color: Colors.amber,
                mainAxisAlignment: MainAxisAlignment.start,
                length: starLength,
                rating: _rating,
                between: 5.0,
                starSize: 25.0,
                onRaitingTap: (rating) {
                  if (voteNumber != 1) {
                    setState(() {
                      _rating = rating;
                    });
                  } else {
                    _showSnackBar(context,
                        "maximum votes for this poll have already been reached.");
                  }
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 20,
                  ),
                  Container(
                    height: 28,
                    width: 28,
                    child: FloatingActionButton(
                      onPressed: _decrementHalfStar,
                      heroTag: "Decrement",
                      tooltip: 'Decrement',
                      backgroundColor: Colors.blueGrey,
                      mini: true,
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    height: 28,
                    width: 28,
                    child: FloatingActionButton(
                      heroTag: "increment",
                      onPressed: _incrementHalfStar,
                      backgroundColor: Colors.blueGrey,
                      tooltip: 'Increment',
                      mini: true,
                      child: Icon(Icons.arrow_drop_up),
                    ),
                  )
                ],
              )
            ],
          ),
          castedVoteNumber == 0 && _rating != 0
              ? Row(
                  //  crossAxisAlignment: CrossAxisAlignment.b,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('poll lock-down in:  ',
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                    Center(
                      child: Countdown(
                        seconds: 15,
                        onFinish: () {
                          setState(() {
                            castedVoteNumber = _rating;
                            voteNumber = 1;
                            CollectionReference collectionReference =
                                Firestore.instance.collection('casted_votes');
                            DocumentReference docReferancew =
                                collectionReference.document();
                            docReferancew.setData({
                              "vote_id": voteID,
                              'member_id': memberID,
                              'vote_number': _rating,
                            });
                          });
                        },
                        textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              : Text(''),
          Row(
            //  crossAxisAlignment: CrossAxisAlignment.b,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                children: <Widget>[    Container(
                    color: Colors.transparent,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance
                          .collection('votes').document(voteID).snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        try {
                          if (snapshot.hasData) {
                            //  _getPopular(snapshot.data.documents,document);
                            if(snapshot.data['popularRate']!=-1) {
                              return Text(
                                '🔥 popular: ️' +
                                    snapshot.data['popularRate'].toString() +
                                    '   🔢 ' +
                                    snapshot.data['voteNumber'].toString() +
                                    ' votes',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 11),
                              );
                            }
                            else{
                              return Text('');
                            }
                          } else if (snapshot.hasError) {
                            return Text('');
                          }
                        } catch (e) {
                          return Text('');
                        }
                      },
                    ))

              ],),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: <Widget>[     Text(
                '🗳 total polls: ️',
                style: TextStyle(color: Colors.black, fontSize: 11),
              ),
              Container(
                  color: Colors.transparent,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('casted_votes')
                        .where('vote_id', isEqualTo: voteID)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      try {
                        if (snapshot.hasData) {
                          return Text(snapshot.data.documents.length.toString(),style: TextStyle(fontSize: 11),);
                        } else if (snapshot.hasError) {
                          return Text('0');
                        }
                      } catch (e) {
                        return Text('0');
                      }
                    },
                  )),Text('  ')],)
            ],
          ),
          Container(
            height: 3,
          ),
        ],
      ),
    );
  }

//  _getPopular(List<DocumentSnapshot> documents ,String voteID) async {
//    String voteIDRefactored=voteID.replaceAll('-', '');
//
//    var databasesPath = await getDatabasesPath();
//    String path = join(databasesPath, voteIDRefactored);
//    // open the database
//    Database database = await openDatabase(path, version: 1,
//        onCreate: (Database db, int version) async {
//          // When creating the db, create the table
//          await db.execute(
//              'CREATE TABLE '+voteIDRefactored+' (popular TEXT)');
//        });
//
//
//    for (DocumentSnapshot query in documents) {
//      // Insert some records in a transaction
//      String insertQuery='INSERT INTO '+voteIDRefactored+'(popular) VALUES('+query['vote_number'].toString()+')';
//      await database.transaction((txn) async {
//       await txn.rawInsert(insertQuery);
//      });
//    }
//    String popularRate='SELECT `popular` FROM `'+voteIDRefactored+'` GROUP BY `popular` ORDER BY COUNT(*) DESC LIMIT 1;';
//
//    await database.transaction((txn) async {
//      var count= await txn.rawQuery(popularRate);
//
//      setState(() {
//        popularRating= count.elementAt(0)['popular'].toString();
//      });
//    });
//
//// Close the database
//    await database.close();
//  }

  _onPressCountDown(AnimationController ctr) {
    if (ctr.isAnimating) {
      return Future.value(false);
    }
    // todo: something
    return Future.value(true);
  }

  _countDownStatusListener(AnimationStatus state) {
    if (state == AnimationStatus.forward) {
      _controller?.stop(canceled: true);
    }
  }
}
