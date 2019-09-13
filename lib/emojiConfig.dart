library emoji_feedback;

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:simple_countdown/simple_countdown.dart';
import 'package:sqflite/sqflite.dart';

class EmojiModel {
  final String label;
  final String src;
  final String activeSrc;

  const EmojiModel({this.src, this.activeSrc, this.label});
}

final List<EmojiModel> reactions = <EmojiModel>[
  EmojiModel(
      label: 'Terrible',
      src: 'assets/worried.png',
      activeSrc: 'assets/worried_big.png'),
  EmojiModel(
      label: 'Bad', src: 'assets/sad.png', activeSrc: 'assets/sad_big.png'),
  EmojiModel(
      label: 'OK',
      src: 'assets/ambitious.png',
      activeSrc: 'assets/ambitious_big.png'),
  EmojiModel(
      label: 'Good',
      src: 'assets/smile.png',
      activeSrc: 'assets/smile_big.png'),
  EmojiModel(
      label: 'Awesome',
      src: 'assets/surprised.png',
      activeSrc: 'assets/surprised_big.png'),
].toList();

const EmojiSize = 28.0;
const EmojiRadius = EmojiSize / 2.0;
const ActiveEmojiSize = EmojiSize * 1.3;
const ActiveEmojiRadius = ActiveEmojiSize / 2.0;
const HalfDiffSize = (ActiveEmojiSize - EmojiSize) / 2.0;

class EmojiFeedback extends StatefulWidget {
  String voteID, memberID;
  double currentIndex;
  final Function onChange;
  final num availableWidth;
  double castedVoteNumber;

  EmojiFeedback(
      {Key key,
      this.currentIndex,
      this.onChange,
      this.availableWidth = 350.0,
      this.voteID,
      this.memberID})
      : super(key: key);

  @override
  EmojiFeedbackState createState() {
    return new EmojiFeedbackState(double.parse(currentIndex.toString()),
        double.parse(currentIndex.toString()), voteID, memberID);
  }
}

class EmojiFeedbackState extends State<EmojiFeedback>
    with SingleTickerProviderStateMixin {
  String voteID, memberID;

  AnimationController controller;
  Animation<double> animation;
  double pos;

  double castedVoteNumber;

  EmojiFeedbackState(this.pos, this.castedVoteNumber, this.voteID,
      this.memberID); // should be between [0, 4]

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
  }

  void moveTo(int index) {
    if (castedVoteNumber == 5) {
      animation = Tween<double>(
        begin: pos,
        end: index.toDouble(),
      ).chain(CurveTween(curve: Curves.linear)).animate(controller)
        ..addListener(() {
          setState(() {
            pos = animation.value;
          });
        });
      controller.forward(from: 0.0);
      if (widget.onChange is Function) {
        widget.onChange(index);
      }
    } else {
      // _showSnackBar(context,"maximum votes for this poll have already been reached.");

    }
  }

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

  @override
  Widget build(BuildContext context) {
    final posTween =
        Tween<double>(begin: 0, end: widget.availableWidth - ActiveEmojiSize);
    List<_EmojiButton> emojiButtons = [];
    List<Widget> activeEmojis = [];
    for (var i = 0; i < reactions.length; i++) {
      final distanceTo = posTween.transform((i - pos).abs() / 4);
      var scale = 1.0;
      if (distanceTo < ActiveEmojiRadius) {
        scale = 0.0;
      } else {
        scale =
            min<double>((distanceTo - ActiveEmojiRadius) / EmojiRadius, 1.0);
      }
      emojiButtons.add(_EmojiButton(
        scale: scale,
        label: reactions[i].label,
        src: reactions[i].src,
        onPressed: () {
          moveTo(i);
        },
      ));
      activeEmojis.add(
        Positioned(
          child: Opacity(
            opacity: 1.0 - scale,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    reactions[i].activeSrc,
                    package: 'emoji_feedback',
                  ),
                ),
                borderRadius: BorderRadius.circular(ActiveEmojiSize),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
        width: widget.availableWidth,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Positioned(
                  top: ActiveEmojiRadius,
                  left: ActiveEmojiRadius,
                  right: ActiveEmojiRadius,
                  child: Container(
                    height: 1.0,
                    color: Colors.blueGrey,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: emojiButtons,
                  ),
                ),
                Positioned(
                  left: posTween.transform(pos / 4),
                  child: Container(
                    width: ActiveEmojiSize,
                    height: ActiveEmojiSize,
                    child: Stack(
                      children: activeEmojis,
                    ),
                  ),
                ),
              ],
            ),
            castedVoteNumber == 5 && pos != 5
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
                              castedVoteNumber = pos;
                              CollectionReference collectionReference =
                                  Firestore.instance.collection('casted_votes');
                              DocumentReference docReferancew =
                                  collectionReference.document();
                              docReferancew.setData({
                                "vote_id": voteID,
                                'member_id': memberID,
                                'vote_number': pos,
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
                Container(
                    color: Colors.white,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance
                          .collection('votes').document(voteID).snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        try {
                          if (snapshot.hasData) {
                            //  _getPopular(snapshot.data.documents,document);
                            if(snapshot.data['popularRate']!=-1) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '🔥 popular: ️',
                                        style: TextStyle(color: Colors.black, fontSize: 11),
                                      ),
                                      snapshot.data['popularRate']!=-1? Container(
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                reactions[snapshot.data['popularRate']].activeSrc,
                                                package: 'emoji_feedback',
                                                height: 20,
                                                width: 20,
                                              ),
                                              Text(
                                                ' ' + reactions[snapshot.data['popularRate']].label,
                                                style:
                                                TextStyle(color: Colors.black, fontSize: 8),
                                              ),
                                            ],
                                          )):Text(''),Text(
                                                                                  '   🔢 ' +
                                            snapshot.data['voteNumber'].toString() +
                                            ' votes',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 11),
                                      )
                                    ],
                                  )
                                ],
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
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '🗳 total polls: ️',
                      style: TextStyle(color: Colors.black, fontSize: 11),
                    ),
                    Container(
                        color: Colors.white,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance
                              .collection('casted_votes')
                              .where('vote_id', isEqualTo: voteID)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            try {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data.documents.length.toString(),
                                  style: TextStyle(fontSize: 11),
                                );
                              } else if (snapshot.hasError) {
                                return Text('0');
                              }
                            } catch (e) {
                              return Text('0');
                            }
                          },
                        )),
                    Text('  ')
                  ],
                )
              ],
            ),
          ],
        ));
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _EmojiButton extends StatelessWidget {
  final VoidCallback onPressed;
  final num scale;
  final String label;
  final String src;

  const _EmojiButton({
    Key key,
    @required this.onPressed,
    this.scale,
    @required this.label,
    @required this.src,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(scale >= 0 && scale <= 1);
    final offsetTop = Tween<double>(begin: 16.0, end: 6.0).transform(scale);
    final realScale = Tween<double>(begin: 0.25, end: 1.0).transform(scale);
    final color =
        ColorTween(begin: Colors.teal, end: Colors.grey).transform(scale);
    return Container(
      width: ActiveEmojiSize,
      padding: EdgeInsets.only(top: HalfDiffSize),
      child: Column(
        children: <Widget>[
          Transform.scale(
            scale: realScale,
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: onPressed,
              child: Container(
                width: EmojiSize,
                height: EmojiSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(src, package: 'emoji_feedback'),
                  ),
                  borderRadius: BorderRadius.circular(EmojiSize),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: offsetTop),
            child: Text(
              label,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
