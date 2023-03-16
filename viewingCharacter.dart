import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:path_provider/path_provider.dart';


class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<bool> _characterList = List.generate(12, (index) => false);

  // キャラクターデータをロードする
  Future<List<String>> _loadCharacterAsset() async {
    print('ccc');
    final directory = await getTemporaryDirectory();
    String filePath = directory.path + '/getCharacter.txt';
    File file = File(filePath);
    print(filePath);
    if (!await file.exists()) {
      await file.create();
      List<String> defaultCharacterList = List.generate(12, (index) => '0');
      await file.writeAsString(defaultCharacterList.join('\n'));
      print('create');
    }
    print(!await file.exists());
    String characterText = await rootBundle.loadString(filePath);
    List<String> characterList = characterText.split('\n');
    return characterList;
  }

  // キャラクターデータをロードして、各アイコンの表示を更新する
  void _updateCharacterList() async {
    //List<String> characterList = await _loadCharacterAsset();
    setState(() {
      //_characterList = List.generate(12, (index) => characterList.contains('$index'));
      //デバッグ用
      _characterList = List.generate(12,(index) => false);
      _characterList[0] = true;
      _characterList[1] = true;
      _characterList[2] = true;
      _characterList[3] = true;
      _characterList[4] = true;
      _characterList[5] = true;
      _characterList[6] = true;
      _characterList[7] = true;
      //_characterList[8] = true;
      _characterList[9] = true;
      //_characterList[10] = true;
      _characterList[11] = true;
      print(_characterList);
    });
  }

  @override
  void initState() {
    super.initState();
    _updateCharacterList();
  }

  // アイコンの下に名前を表示する
  //jsonファイルから読み取るように変更検討
  String _getName(int index) {
    switch (index) {
      case 0:
        return '中山';
      case 1:
        return '松前';
      case 2:
        return '上田';
      case 3:
        return '掛下';
      case 4:
        return '大月';
      case 5:
        return '福田';
      case 6:
        return '只木';
      case 7:
        return '杉町';
      case 8:
        return '木村';
      case 9:
        return '花田';
      case 10:
        return '皆本';
      case 11:
        return '大谷';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Character'),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: List.generate(12, (index) {
          return GestureDetector(
            onTap: _characterList[index]
                ? () {
              Navigator.pushNamed(context, '/page5', arguments: index);
            }
                : null,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _characterList[index] ? Colors.blue : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _getName(index),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class Page5 extends StatelessWidget {
  String photoid = '';
  String forewordid = '';
  String youtubeURL = '';
  Future<String> _loadAsset() async {
    return await rootBundle.loadString(forewordid);
  }

  @override
  Widget build(BuildContext context) {
    final int id = ModalRoute.of(context)!.settings.arguments as int;
    switch(id) {
      case 0:
        youtubeURL = 'NgGlVPGufQg';
        break;
      case 1:
        youtubeURL = 'IYC79j7k6J8';
        break;
      default:
        youtubeURL = 'M2ApQrCn_AY';
        break;
    }
    photoid = 'lib/char' + '$id' + '.jpg';
    forewordid = 'lib/foreword' + '$id' + '.txt';
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール'),
      ),
      body: Column(
        children: [
          Image.asset(photoid),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: _loadAsset(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(snapshot.data!,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Page8(videoId: youtubeURL),
                      ),
                    );
                  },
                  child: Text('紹介動画を見る'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Page8 extends StatefulWidget {
  final String videoId;

  const Page8({Key? key, required this.videoId}) : super(key: key);

  @override
  _Page8State createState() => _Page8State();
}

class _Page8State extends State<Page8> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      params: YoutubePlayerParams(
        autoPlay: true,
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('紹介映像'),
      ),
      body: Center(
        child: YoutubePlayerIFrame(
          controller: _controller,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}