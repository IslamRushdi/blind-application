import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_app/utils/tts.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class TextRecognition extends StatefulWidget {
  TextRecognition({
    Key? key,
  }) : super(key: key);

  @override
  State<TextRecognition> createState() => _TextRecognitionState();
}

class _TextRecognitionState extends State<TextRecognition> {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  final textDetector = GoogleMlKit.vision.textDetector();
  Socket? socket;
  // TextEditingController _itemNameController = TextEditingController();

  Timer? timer;
  TTS? tts;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    initializeSocket();
    initializeTTS();
  }

  void emitImage() async {
    var xFile = await _controller!.takePicture();
    final Uint8List bytes = await xFile.readAsBytes();
    String img64 = base64Encode(bytes);

    socket?.emit("my event", {"data": img64});
    socket?.on("my response", (res) => print(res));
  }

  void initializeSocket() {
    socket = IO.io(
        'http://192.168.1.7:5000/',
        OptionBuilder().setTransports([
          "websocket",
        ]).build());
    socket?.onConnect((data) {
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
    double scale = 0.0;
    if (_controller != null)
      scale = 1 / (_controller!.value.aspectRatio * size.aspectRatio);

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: SafeArea(
          child: Stack(
            children: [
              if (_controller != null)
                Transform.scale(
                    scale: scale, child: CameraPreview(_controller!)),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 100.0),
              //   child: Align(
              //     alignment: FractionalOffset.bottomCenter,
              //     child: TextField(
              //       controller: _itemNameController,
              //       decoration: InputDecoration(
              //         contentPadding:
              //             const EdgeInsets.symmetric(horizontal: 20.0),
              //         fillColor: Colors.white10,
              //         filled: true,
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: IconButton(
                    onPressed: () async {
                      var xFile = await _controller!.takePicture();
                      final Uint8List bytes = await xFile.readAsBytes();
                      String img64 = base64Encode(bytes);

                      socket?.emit(
                        "client:read a text",
                        {
                          // "item_name": _itemNameController.text,
                          "image_base64": img64,
                        },
                      );
                      print("send");
                      socket?.on("text Detection Server: Response", (res) {
                        print("received");
                        setState(() {
                          tts?.speak(res);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
