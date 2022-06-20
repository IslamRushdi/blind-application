import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_app/utils/tts.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  final textDetector = GoogleMlKit.vision.textDetector();
  late IO.Socket socket;
  Timer? timer;
  late TTS tts;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    initializeSocket();
    initializeTTS();

    // timer = Timer.periodic(Duration(seconds: 1), (Timer t) => emitImage());
  }

  void emitImage() async {
    var xFile = await _controller!.takePicture();
    final Uint8List bytes = await xFile.readAsBytes();
    String img64 = base64Encode(bytes);

    socket.emit("my event", {"data": img64});
    socket.on("my response", (res) => print(res));
  }

  void initializeSocket() {
    socket = IO.io(
        // 'https://ad30-41-234-2-218.ngrok.io:5000/',
        'ws://localhost:5000/',
        OptionBuilder().setTransports([
          "websocket",
          // "polling",
        ]) // for Flutter or Dart VM
            .build());
    socket.onConnect((data) {
      print('connected');
    });
    print(socket);
  }

  void initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();

    initializeCameraController();
  }

  void initializeTTS() {
    tts = TTS();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void initializeCameraController() {
    _controller = CameraController(_cameras![0], ResolutionPreset.max);
    _controller!.initialize().then((_) {
      if (!mounted) {
        _controller!.setFocusMode(FocusMode.locked);
        _controller!.setFlashMode(FlashMode.off);
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final scale = 1 / (_controller!.value.aspectRatio * size.aspectRatio);

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: SafeArea(
          child: Stack(
            children: [
              Transform.scale(scale: scale, child: CameraPreview(_controller!)),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: IconButton(
                    onPressed: () async {
                      print("capturing");
                      var xFile = await _controller!.takePicture();
                      final Uint8List bytes = await xFile.readAsBytes();
                      String img64 = base64Encode(bytes);

                      socket.emit("client:my event", {"data": img64});
                      print("send");
                      socket.on("my response", (res) {
                        print("received");
                        setState(() {
                          tts.speak(res);
                        });
                        print(res);
                      });

                      // final RecognisedText recognisedText = await textDetector
                      //     .processImage(InputImage.fromFile(File(xFile.path)));

                      // print(recognisedText.text);
                    },
                    icon: Icon(Icons.camera),
                    iconSize: 60.0,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
