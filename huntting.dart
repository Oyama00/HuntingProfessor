import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'main.dart';

/*
class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  String _qrId = '';

  Future<void> _scanQRCode() async {
    String qrCode = await FlutterBarcodeScanner.scanBarcode(
      '#FF00FF',
      'キャンセル',
      true,
      ScanMode.QR,
    );
    setState(() {
      _qrId = qrCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page 3')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanQRCode,
              child: const Text('QRコードをスキャン'),
            ),
            const SizedBox(height: 16),
            Text('QRコード: $_qrId'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Page4(qrId: int.parse(_qrId)),
                  ),
                );
              },
              child: const Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ハンティング方法選択'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page6()),
                );
              },
              child: Text('位置情報から'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page7()),
                );
              },
              child: Text('QRコードから'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page4 extends StatelessWidget {
  final int qrId;
  const Page4({Key? key, required this.qrId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print(qrId);
    String charImg = 'lib/char' + qrId.toString() + '.jpg';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/char0.jpg'),
            //image: AssetImage(charImg),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<String>(
          future: _loadQuestion(qrId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final question = snapshot.data!;
              final questionLines = question.split('\n');
              final questionText = questionLines[0];
              final choices = questionLines[1].split(' ');
              final answerIndex = int.parse(questionLines[2]);

              return Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          questionText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...choices.map((choice) => ElevatedButton(
                          onPressed: () {
                            final isCorrect =
                                choices.indexOf(choice) == answerIndex - 1;
                            _showResultDialog(context, isCorrect);
                          },
                          child: Text(choice),
                        )),
                      ],
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  '警告：QRコードが登録されていません',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<String> _loadQuestion(int qrId) async {
    final file = File('lib/Q$qrId.txt');
    //final file = File('lib/Q0.txt');
    print('lib/Q$qrId.txt');
    //print(file.readAsString());
    return await rootBundle.loadString('lib/Q$qrId.txt');
    //return await file.readAsString();
  }

  void _showResultDialog(BuildContext context, bool isCorrect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: isCorrect
            ? const Text('Correct!')
            : const Text('Incorrect!'),
        content: isCorrect
            ? const Icon(Icons.check_circle,
            size: 100, color: Colors.green)
            : const Icon(Icons.cancel, size: 100, color: Colors.red),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Page10(
                    qrId: qrId,
                    result: isCorrect,
                  ),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class Page6 extends StatefulWidget {
  @override
  _Page6State createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  String _ipAddress = '';
  String _macAddress = '';

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
  }

  Future<void> _initNetworkInfo() async {
    final ipAddress = await NetworkInfo().getWifiIP();
    final macAddress = await NetworkInfo().getWifiBSSID();

    setState(() {
      _ipAddress = ipAddress ?? 'unknown';
      _macAddress = macAddress ?? 'unknown';
      if(_macAddress == "02:00:00:00:00:00"){
        _macAddress = "ここは自宅";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('位置情報（Wi-Fi接続）'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('IP Address: $_ipAddress'),
            SizedBox(height: 32),
            Text('MAC Address: $_macAddress'),
          ],
        ),
      ),
    );
  }
}

class Page7 extends StatefulWidget {
  const Page7({Key? key}) : super(key: key);

  @override
  _Page7State createState() => _Page7State();
}

class _Page7State extends State<Page7> {
  String _qrId = '';
  //int hoge = 0;
  int decryptionQRId = 0;

  Future<void> _scanQRCode() async {
    String qrCode = await FlutterBarcodeScanner.scanBarcode(
      '#FF00FF',
      'キャンセル',
      true,
      ScanMode.QR,
    );
    setState(() {
      _qrId = qrCode;
      decryptionQRId = int.parse(_qrId[1]) + int.parse(_qrId[4]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QRコード読み取り')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanQRCode,
              child: const Text('QRコードをスキャン'),
            ),
            const SizedBox(height: 16),
            Text('QRコード: $_qrId'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Page4(qrId: decryptionQRId),
                  ),
                );
              },
              child: const Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page9 extends StatefulWidget {
  final int qrId;
  Page9({required this.qrId});

  @override
  _Page9State createState() => _Page9State();
}

class _Page9State extends State<Page9> {
  late List<String> _questionData;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  Future<void> _loadQuestionData() async {
    try {
      // テキストファイルを読み込む
      String data = await rootBundle.loadString('assets/Q${widget.qrId}.txt');
      // 改行で区切って配列にする
      _questionData = LineSplitter().convert(data);
    } catch (e) {
      print(e);
      // ファイル読み込みに失敗した場合は、アプリを終了する
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
    setState(() {});
  }

  Widget _buildQuestion() {
    // 問題文を取得する
    String question = _questionData[0];
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(
        question,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChoice(int index) {
    // 選択肢を取得する
    String choice = _questionData[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == int.parse(_questionData[5])) {
            // 正解の選択肢を選んだ場合は赤丸を表示する
            choice = '○ ' + choice;
          } else {
            // 不正解の選択肢を選んだ場合は青×を表示する
            choice = '× ' + choice;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: (choice.startsWith('○'))
              ? Colors.red[100]
              : (choice.startsWith('×'))
              ? Colors.blue[100]
              : null,
        ),
        child: Text(
          choice,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('結果発表！'),
      ),
      body: (_questionData == null)
          ? Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildQuestion(),
          _buildChoice(1),
          _buildChoice(2),
          _buildChoice(3),
          _buildChoice(4),
        ],
      ),
    );
  }
}

class Page10 extends StatelessWidget {
  final int qrId;
  final bool result;

  const Page10({Key? key, required this.qrId, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String charImg = 'lib/char' + qrId.toString() + '.jpg';
    String message = result ? '捕獲成功！' : '捕獲失敗！';
    Color textColor = result ? Colors.green : Colors.red;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(charImg),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              _appendToFile(qrId);
            },
            child: const Text('ホームに戻る'),
          ),
        ),
      ),
    );
  }

  Future<void> _appendToFile(int qrId) async {
    final directory = await getTemporaryDirectory();
    final file = File(directory.path + '/getCharacter.txt');
    print(directory.path);
    await file.writeAsString('$qrId\n', mode: FileMode.append);
  }
}