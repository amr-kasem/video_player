// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is used to extract code samples for the README.md file.
// Run update-excerpts if you modify this file.

// ignore_for_file: library_private_types_in_public_api, public_member_api_docs

// #docregion basic-example

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoApp());

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  int x = 0;
  String subtitle = '';
  String duration = '';
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'http://tvwerk.live:8080/movie/qWgNq3XJ0b/cA9rAJJ8be/832949.mkv'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        final x = Stream.periodic(Duration(seconds: 1));
        x.listen((event) async {
          subtitle = await _controller.currentSubtitleText ?? '';
          duration =
              '${await _controller.position} / ${await _controller.value.duration}';
          setState(() {});
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    children: [
                      VideoPlayer(_controller),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            backgroundColor: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ),
        floatingActionButton: Row(
          children: [
            SizedBox(width: 20),
            Text(duration),
            TextButton(
                onPressed: () async {
                  _controller.seekTo(
                    (await _controller.position ?? Duration.zero) +
                        Duration(minutes: 5),
                  );
                },
                child: Text('Move')),
            TextButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                  if (!_controller.value.isPlaying) {
                    _controller.getTracks().then((value) {
                      final groups = value?.groups ?? [];
                      x = (x + 1) % groups.length;
                      print(groups.length);
                      groups[x]?.formats.forEach((format) {
                        log('${format.label}[${format.language}]');
                      });
                      _controller.setTrack(groupIndex: x, formatIndex: 0);
                    });
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ],
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
// #enddocregion basic-example
