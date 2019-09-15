import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'emojiConfig.dart';
//import 'package:emoji_feedback/emoji_feedback.dart';


class Emoji extends StatelessWidget {
  final String voteID, memberID;
  Emoji(this.voteID,this.memberID);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(voteID,memberID),
    );
  }
}

class HomePage extends StatelessWidget {
  String voteID, memberID;

  HomePage(this.voteID,this.memberID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.transparent,
      body: Container(
//        padding: EdgeInsets.only(top: 48.0, left: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
//            Container(
//              height: 2,
//            ),
            Container(
                color: Colors.transparent,
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('casted_votes')
                      .where('vote_id', isEqualTo: voteID)
                      .where('member_id', isEqualTo: memberID)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    try {
                      if (snapshot.hasData) {
                        return EmojiFeedback(
                          currentIndex: snapshot.data.documents.elementAt(0)['vote_number'],
                          onChange: (index) {
                            print(index);
                          },
                          voteID: voteID,
                          memberID: memberID,
                        );
                      } else if (snapshot.hasError) {
                        return Text("");
                      }
//                  return Text("");
                    }
                    catch(e){

                      return EmojiFeedback(
                        currentIndex: 5,
                        onChange: (index) {
                          print(index);
                        },
                        voteID: voteID,
                        memberID: memberID,
                      );

                    }
                  },
                )),

            Container(
              height: 5,
            ),


          ],
        ),
      ),
    );
  }
}