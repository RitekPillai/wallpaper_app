import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapp/apikey.dart';
import 'package:wallpaperapp/fullscreen.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

List photos = [];
List info = [];
int page = Random().nextInt(300);

class _MainpageState extends State<Mainpage> {
  ScrollController _scrollController = ScrollController();
  imageApi() async {
    try {
      final response = await http.get(
          Uri.parse("https://api.pexels.com/v1/curated?per_page=20&page=$page"),
          headers: {
            'Authorization': apikey,
          });

      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);
        setState(() {
          info = result['photos'];
          photos = result['photos'];
        });
        //      print(info);
      } else {
        print('Failed to load photos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  void initState() {
    imageApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (page == 0) {
      page = 1;
      imageApi();
    }
    return Scaffold(
      backgroundColor: Color(0xff180026),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Text('Wallpapers',
                style: TextStyle(fontSize: 30, color: Color(0xff80ffdb))),
            SizedBox(
              height: 1500,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 300,
                  childAspectRatio: 2,
                ),
                scrollDirection: Axis.vertical,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Fullscreen(
                                    photos: photos,
                                    index: index,
                                  )));
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          height: photos[index]['height'],
                          width: photos[index]['width'],
                          photos[index]['src']['medium'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      page = Random().nextInt(300);
                      imageApi();
                      _scrollController.jumpTo(0);
                      print(page);
                    });
                  },
                  child: Text('Next',
                      style: TextStyle(
                          color: Color(0xff5e60ce),
                          fontSize: 30,
                          fontWeight: FontWeight.bold))),
            ),
          ],
        ),
      ),
    );
  }
}
