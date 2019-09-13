import 'dart:ui';

class TrendingMasterObject {
  List<TrendingList> trendingList;

  TrendingMasterObject({this.trendingList});

  TrendingMasterObject.fromJson(Map<String, dynamic> json) {
    if (json['trendingList'] != null) {
      trendingList = new List<TrendingList>();
      json['trendingList'].forEach((v) {
        trendingList.add(new TrendingList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.trendingList != null) {
      data['trendingList'] = this.trendingList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TrendingList {
  String profilePic;
  String title;
  String owner;
  String description;
  int descriptionType;
  String time;
  String mainDisplay;
  int voteType;
  int voteBy;
  int voteId;
  int votesCasted;
  int allowedVoteNumber;
  Color color;
  String id;

  TrendingList(
      {this.profilePic,
        this.title,
        this.owner,
        this.description,
        this.descriptionType,
        this.time,
        this.mainDisplay,
        this.voteType,
        this.voteBy,
        this.voteId,
        this.votesCasted,
        this.allowedVoteNumber,
      this.color,
      this.id});

  TrendingList.fromJson(Map<String, dynamic> json) {
    profilePic = json['profilePic'];
    title = json['title'];
    owner = json['owner'];
    description = json['description'];
    descriptionType = json['descriptionType'];
    time = json['time'];
    mainDisplay = json['mainDisplay'];
    voteType = json['voteType'];
    voteBy = json['voteBy'];
    voteId = json['voteId'];
    votesCasted = json['votesCasted'];
    allowedVoteNumber = json['allowedVoteNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profilePic'] = this.profilePic;
    data['title'] = this.title;
    data['owner'] = this.owner;
    data['description'] = this.description;
    data['descriptionType'] = this.descriptionType;
    data['time'] = this.time;
    data['mainDisplay'] = this.mainDisplay;
    data['voteType'] = this.voteType;
    data['voteBy'] = this.voteBy;
    data['voteId'] = this.voteId;
    data['votesCasted'] = this.votesCasted;
    data['allowedVoteNumber'] = this.allowedVoteNumber;
    return data;
  }
}
