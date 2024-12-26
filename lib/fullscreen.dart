import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

import 'package:wallpaperapp/apikey.dart';
import 'package:wallpaperapp/mainpage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Fullscreen extends StatefulWidget {
  List photos;

  int index;
  Fullscreen({super.key, required this.index, required this.photos});

  @override
  State<Fullscreen> createState() => _FullscreenState();
}

List photoss = [];

class _FullscreenState extends State<Fullscreen> {
  choosedevice(String imageUrl) {
    return showDialog(
      context: context,
      builder: (context) {
        String result;
        return AlertDialog(
            title: Text('Choose Device'),
            content:
                Text('Choose the device where you want to set the wallpaper'),
            actions: [
              TextButton(
                onPressed: () async {
                  final device = await WallpaperManagerFlutter.HOME_SCREEN;
                  setwall(imageUrl, device);
                  Navigator.pop(context);
                },
                child: Text('HomeScreen'),
              ),
              TextButton(
                onPressed: () async {
                  final device = await WallpaperManagerFlutter.LOCK_SCREEN;
                  setwall(imageUrl, device);
                  Navigator.pop(context);
                },
                child: Text('LockScreen'),
              ),
              TextButton(
                  onPressed: () async {
                    final device = await WallpaperManagerFlutter.BOTH_SCREENS;
                    setwall(imageUrl, device);
                    Navigator.pop(context);
                  },
                  child: Text('Both'))
            ]);
      },
    );
  }

  Future<void> setwall(String imageUrl, device) async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    try {
      WallpaperManagerFlutter().setwallpaperfromFile(
          file, device); // Wrap with try catch for error management.
    } catch (e) {
      print('Error: $e');
    }
  }

  morephoto() async {
    int page1 = Random().nextInt(300);
    try {
      final response = await http.get(
          Uri.parse(
              "https://api.pexels.com/v1/curated?per_page=10&page=$page1"),
          headers: {
            'Authorization': apikey,
          });

      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);
        setState(() {
          photoss = result['photos'];
        });
        print(photoss);
      } else {
        print('Failed to load photos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  void initState() {
    morephoto();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color _hexToColor(String hexColor) {
      final buffer = StringBuffer();
      if (hexColor.length == 6 || hexColor.length == 7) {
        buffer.write('FF');
      }
      buffer.write(hexColor.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    var color = widget.photos[widget.index]['avg_color'];
    Color backgroundColor;

    if (color is String) {
      backgroundColor = _hexToColor(color);
    } else if (color is int) {
      backgroundColor = Color(color);
    } else {
      backgroundColor = Colors.white;
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: 500,
              width: double.infinity,
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.photos[widget.index]['src']['large2x'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.photos[widget.index]['photographer'],
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.photos[widget.index]['alt'] ?? '',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20)))),
                              backgroundColor:
                                  WidgetStatePropertyAll(Color(0xff7400B8))),
                          onPressed: () {
                            choosedevice(
                                photoss[widget.index]['src']['large2x']);
                          },
                          child: const Text(
                            'Set',
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          )),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'More',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1500,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 300,
                        childAspectRatio: 2,
                      ),
                      scrollDirection: Axis.vertical,
                      itemCount: photoss.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Fullscreen(
                                          photos: photoss,
                                          index: index,
                                        )));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              child: Image.network(
                                photoss[index]['src']['medium'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget icontext(String txt, icon) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        Icon(
          icon,
          size: 30,
        ),
        Text(
          txt,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}
