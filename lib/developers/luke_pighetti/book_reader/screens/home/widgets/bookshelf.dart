import 'dart:math';

import 'package:developers/TrendingMasterObject.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launch;
import 'package:meet_network_image/meet_network_image.dart';
import '../../../../../../emoji.dart';
import '../../../../../../radio.dart';
import '../../../../../../radio_yes_no.dart';
import '../../../../../../rate.dart';
import '../../../../../../yesnomaybe.dart';
import '../bloc.dart';
import '../models.dart';

class Bookshelf extends StatefulWidget {
  @override
  _BookshelfState createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  PageController _pageController;

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
      curve: Curves.easeIn,
    );

    _pageController = PageController(
      viewportFraction: 0.9,
    );
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of(context).hasOnboarded.listen((hasOnboarded) {
      if (hasOnboarded)
        _controller.forward();
      else
        _controller.reverse();
    });

    /// scroll position
    _pageController.addListener(() {
      BlocProvider.of(context).setScrollPosition(
        _pageController.offset / _pageController.position.maxScrollExtent,
      );
    });

    return Container(
      alignment: Alignment.bottomRight,
      child: SizeTransition(
        sizeFactor: _animation,
        axis: Axis.horizontal,
        axisAlignment: -1.0,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(top: 36.0, bottom: 28.0),
            //Card Sizes where main`display is set
            height: MediaQuery.of(context).size.height * .78,
            child: StreamBuilder(
              stream: BlocProvider.of(context).trendings,
              initialData: <TrendingList>[],
              builder: (context, AsyncSnapshot<List<TrendingList>> snapshot) {
                /// update on scroll
                _pageController.addListener(() {
                  if (snapshot.data.isNotEmpty)
                    BlocProvider.of(context).setColor(
                      ColorTransition(
                        colors:
                            snapshot.data.map((trendings) => trendings.color).toList(),
                        offset: _pageController.offset,
                        maxExtent: _pageController.position.maxScrollExtent,
                      ),
                    );
                });

                return PageView(
                  controller: _pageController,
                  children:
                      snapshot.data.map((trend) => MyBook(trend: trend)).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
    _pageController.dispose();
  }
}

class MyBook extends StatelessWidget {
  final TrendingList trend;
  MyBook({this.trend});
  String uuid;
  initState() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uuid=user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey[600],
            blurRadius: 12.0,
            spreadRadius: -2.0,
            offset: Offset(0.0, 5.0),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            // 352.6 is iPhone 8+ width
            // 417.9 is iPhone 8+ height for this widget
            final scale = constraints.maxHeight / 417.9;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              MeetNetworkImage(
              height: MediaQuery.of(context).size.height /2.4,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
//              color: Colors.blue,
//              colorBlendMode: BlendMode.difference,
              imageUrl:
              trend.mainDisplay,
              loadingBuilder: (context) => Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, e) => Center(
                child: Text('Error appear!'),
              ),
            ),

//            SizedBox(height: 1.0 ),
                Container(
//                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      voterFactory(trend.voteBy)
//                      Text(
//                        trend.title,
//                        style: TextStyle(
//                            fontSize: 12.0 * scale,
//                            fontWeight: FontWeight.w500),
//                      ),
//                      SizedBox(height: 18.0 * scale),
//                      Text(
//                        'By ${trend.title}',
//                        style: TextStyle(
//                            fontSize: 16.0 * scale,
//                            fontWeight: FontWeight.w500),
//                      ),
//                      SizedBox(height: 18.0 * scale),
//                      RaisedButton(
//                        padding: EdgeInsets.symmetric(
//                            vertical: 14.0 * scale, horizontal: 32.0),
//                        onPressed: () => launch("https://pighetti.design"),
//                        color: trend.color,
//                        child: Text(
//                          "READ BOOK",
//                          style: TextStyle(color: Colors.white),
//                        ),
//                        shape: RoundedRectangleBorder(
//                          borderRadius: BorderRadius.circular(99.9),
//                        ),
//                      ),

                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget voterFactory(int voteBy){
    if (voteBy == 4) {
      return Container(
          height: 65,
          child: new StarRatings(
            trend.id,
            uuid,
          ));
    }
    if (voteBy == 5) {
      return Container(
        height: 70,
        child: CustomRadio(trend.id, uuid),
      );
    }

    if (voteBy == 6) {
      return
        Container(
            height: 115,
            child: Emoji(trend.id, uuid));
    }
    if (voteBy == 7) {
      return
        Container(
            height: 60,
            child: new YesNoMaybe(trend.id, uuid));
    }
    if (voteBy == 8) {
      return
        Container(
            height: 85,
            child: new LikeDisLike(trend.id, uuid));
    }
    else{
     return IconButton(
        icon: Image.asset(
          "images/cast.png",
          width: 22.0,
          height: 22.0,
        ),
        onPressed: () {

        },
      );
    }
  }
}
