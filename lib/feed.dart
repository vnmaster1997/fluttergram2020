import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'image_post.dart';
import 'dart:async';
import 'main.dart';
// import 'dart:io';
// import 'dart:html';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:universal_io/io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Feed extends StatefulWidget {
  _Feed createState() => _Feed();
}

class _Feed extends State<Feed> with AutomaticKeepAliveClientMixin<Feed> {
  List<ImagePost> feedData;

  @override
  void initState() {
    super.initState();
    this._loadFeed();
  }

  buildFeed() {
    if (feedData != null) {
      return ListView(
        children: feedData,
      );
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluttergram',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: buildFeed(),
      ),
    );
  }

  Future<Null> _refresh() async {
    await _getFeed();

    setState(() {});

    return;
  }

  _loadFeed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("feed");

    if (json != null) {
      List<Map<String, dynamic>> data =
          jsonDecode(json).cast<Map<String, dynamic>>();
      List<ImagePost> listOfPosts = _generateFeed(data);
      setState(() {
        feedData = listOfPosts;
      });
    } else {
      _getFeed();
    }
  }

  _getFeed() async {
    print("Staring getFeed");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = googleSignIn.currentUser.id.toString();
    var url =
        'https://us-central1-fluttergram-6e725.cloudfunctions.net/getFeed?uid=' + userId;
        // var url = 'https://localhost:3000/users/insta-a-feed?uid='+userId;
    // var httpClient = new HttpClient();
    var httpClient = new http.Client(); 

    List<ImagePost> listOfPosts;
    String result;
    try {
      http.get(url)
        .then((response) {
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          prefs.setString("feed", response.body);
          List<Map<String, dynamic>> data =
            jsonDecode(response.body).cast<Map<String, dynamic>>();
          listOfPosts = _generateFeed(data);
          result = "Success in http request for feed";
        });
      // var request = await httpClient.getUrl(Uri.parse(url));
      // var response = await request.close();
      // var response = await httpClient.get(url);
      // if (response.statusCode == HttpStatus.ok) {
      //   String json = await response.transform(utf8.decoder).join();
      //   prefs.setString("feed", json);
      //   List<Map<String, dynamic>> data =
      //       jsonDecode(json).cast<Map<String, dynamic>>();
      //   listOfPosts = _generateFeed(data);
      //   result = "Success in http request for feed";
      // } else {
      //   result =
      //       'Error getting a feed: Http status ${response.statusCode} | userId $userId';
      // }
      
    } catch (exception) {
      result = 'Failed invoking the getFeed function. Exception: $exception';
    }
    print(result);

    setState(() {
      feedData = listOfPosts;
    });
  }

  List<ImagePost> _generateFeed(List<Map<String, dynamic>> feedData) {
    List<ImagePost> listOfPosts = [];

    for (var postData in feedData) {
      listOfPosts.add(ImagePost.fromJSON(postData));
    }

    return listOfPosts;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}
