import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/camera_bloc.dart';

extension EButton on VoidCallback {
  Widget button({required Color color, required String text}) {
    return ElevatedButton(
      onPressed: this, // 'this' is the function (cubit.openCamera)
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraCubit(),
      child: MaterialApp(
        title: 'Flutter App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 0, 0),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 0, 0),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // @override
  // void initState() {
  //   super.initState();

  //   // Run immediately on app start
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   if (currentState is InitApp) {
  //     cameracubit.loadKey;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var cameracubit = BlocProvider.of<CameraCubit>(context);
    var camerastate = context.watch<CameraCubit>().state;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text('Flutter App', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  cameracubit.openCamera.button(
                    color: Colors.blue,
                    text: "Camera",
                  ),
                  cameracubit.opengallery.button(
                    color: Colors.red,
                    text: "Gallery",
                  ),
                  if (camerastate is CameraCapturedState)
                    cameracubit.uploxad.button(
                      color: Colors.green,
                      text: camerastate.uploadStatus == UploadStatus.done
                          ? "Done!"
                          : "Upload",
                    ),

                  const SizedBox(height: 15),
                ],
              ),
              const SizedBox(height: 15),
              BlocBuilder<CameraCubit, CameraState>(
                bloc: cameracubit,
                builder: (context, state) {
                  if (state is CameraPreviewState) {
                    return Column(
                      children: [
                        CameraPreview(cameracubit.controller!),
                        cameracubit.captureImage.button(
                          color: Colors.blue,
                          text: "Take",
                        ),
                      ],
                    );
                  }

                  if (state is CameraCapturedState) {
                    if (state.encryptStatus != EncStatus.done) {
                      cameracubit.encrypt();
                    }
                    if (!kIsWeb) {
                      return Image.file(File(state.image.path));
                    } else {
                      return Image.memory(state.byteImage);
                    }
                  }

                  if (state is CameraErrorState) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  if (state is CameraErrorState) {
                    return Center(child: Text(" ${state.message}"));
                  }
                  return const SizedBox(height: 15);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
