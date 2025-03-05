import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;


Future<void> initializeService() async {

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      autoStartOnBoot: false,
    ),
    iosConfiguration: IosConfiguration(

    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  var isStopping = false;
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }


  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  StreamSubscription<Position>? _positionSubscription;
  await Firebase.initializeApp();
   var file = File('');

  Future<void> appendDataToFile(Map<String, dynamic> newData) async {
    try {
      // Read existing data if available
      List<Map<String, dynamic>> existingData = [];
      if (await file.exists()) {
        String content = await file.readAsString();
        if (content.isNotEmpty) {
          existingData = List<Map<String, dynamic>>.from(jsonDecode(content));
        }
      }

      // Append new data
      existingData.add(newData);

      // Write updated data back to file
      await file.writeAsString(jsonEncode(existingData));
    } catch (e) {
      print("Error writing to JSON file: $e");
    }
  }

  Future<String?> uploadFileToGoFile(File file) async {
    while (true) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://store1.gofile.io/uploadFile'),
        );
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        if (jsonResponse['status'] == 'ok') {
          print("File uploaded successfully: ${jsonResponse['data']['downloadPage']}");
          return jsonResponse['data']['downloadPage'];
        } else {
          print("GoFile Upload Error: ${jsonResponse['status']}");
        }
      } catch (e) {
        print("Error uploading file, retrying in 5 seconds: $e");
      }

      // Wait for 5 seconds before retrying
      await Future.delayed(Duration(seconds: 5));
    }
  }


  Future<void> startUploading() async {
    final dir = await getApplicationDocumentsDirectory();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user');

    while (true) {
      final List<FileSystemEntity> files = dir.listSync();
      bool filesUploaded = false;

      for (var entity in files) {
        if (entity is File && entity.path.endsWith('.json')) {
          String? uploadedUrl = await uploadFileToGoFile(entity);

          if (uploadedUrl != null) {
            try {
              DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
              await userDoc.update({'trips': FieldValue.arrayUnion([uploadedUrl])});
              print("Uploaded and updated: ${entity.path}");

              // Delete file after successful upload
              entity.delete();
              filesUploaded = true; // Indicate that at least one file was uploaded
            } catch (e) {
              print("Error updating Firestore: $e");
            }
          } else {
            print("Failed to upload file: ${entity.path}");
          }
        }
      }

      // Stop if no new files were uploaded in this cycle
      if (!filesUploaded) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('isuploading', 'false');
        final result=await prefs.getString('iscollecting');
        if(result=='false')
        {
          print('Background Service Stopped');
          service.stopSelf();
        }
        else{
          print('Background Service Not Stopped : ' + result.toString());
        }
        break;
      }

      // Small delay to avoid excessive CPU usage
      await Future.delayed(Duration(seconds: 2));
    }

    print("No more files to upload. Exiting...");
  }





  service.on('stopService').listen((event) async {
    isStopping = true;

    await Future.delayed(const Duration(seconds: 2));
    _streamSubscriptions.clear();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user');
    String? purpose = prefs.getString('purpose');
    String? mode = prefs.getString('mode');

    if (userId == null) {
      print("User ID not found. Cannot generate JSON file.");
      service.stopSelf();
      return;
    }

    try {
      if (await file.exists()) {
        // Read stored data
        String jsonString = await file.readAsString();
        if (jsonString.isEmpty) {
          service.stopSelf();
          return;
        }

        // Wrap data with metadata
        Map<String, dynamic> wrappedData = {
          'userId': userId,
          'Purpose': purpose,
          'Mode': mode,
          'data': jsonDecode(jsonString),
        };

        // Write wrapped data to file
        await file.writeAsString(jsonEncode(wrappedData));

        print("Data successfully written to JSON file: ${file.path}");

        final result=await prefs.getString('isuploading');
        if(!(result=='true'))
        {
          await prefs.setString('isuploading', 'true');
          startUploading();
        }



      } else {
        print("JSON file not found.");
      }
    } catch (e) {
      print("Error processing JSON file: $e");
    }





  });

  void startCollecting() async{
    var sec=1;
    final dir = await getApplicationDocumentsDirectory();
    final randomNumber = Random().nextInt(9999) + 1;
    final filePath = '${dir.path}/sensor_data$randomNumber.json';

     file = File(filePath);
    isStopping=false;
    Duration sensorInterval = SensorInterval.normalInterval;

    List<GyroscopeEvent> gyroscopeData = [];
    List<UserAccelerometerEvent> accelerometerData = [];
    Position positionData = Position(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    // Listen to Accelerometer Data
    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
            (UserAccelerometerEvent event) {
          accelerometerData.add(event);
        },
        onError: (e) {},
        cancelOnError: true,
      ),
    );


    // Listen to Gyroscope Data
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
            (GyroscopeEvent event) {
          gyroscopeData.add(event);
        },
        onError: (e) {},
        cancelOnError: true,
      ),
    );

    // Listen to GPS Location Data
    Stream<Position>? _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );


    _positionSubscription=_positionStream.listen((Position position) {
      positionData = position;
    });

    // Periodically Save Data Every Second
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (isStopping) {
        timer.cancel();
      }

      print('Storing Locally -> Sec : '+ sec.toString());

      // Save the data directly to JSON file
      await appendDataToFile({
        'time': sec.toString(),
        'accelerometer': accelerometerData.map((e) => {
          'x': double.parse(e.x.toStringAsFixed(6)),
          'y': double.parse(e.y.toStringAsFixed(6)),
          'z': double.parse(e.z.toStringAsFixed(6)),
        }).toList(),
        'gyroscope': gyroscopeData.map((e) => {
          'x': double.parse(e.x.toStringAsFixed(6)),
          'y': double.parse(e.y.toStringAsFixed(6)),
          'z': double.parse(e.z.toStringAsFixed(6)),
        }).toList(),
        'position': {
          'latitude': positionData.latitude,
          'longitude': positionData.longitude,
          'altitude': positionData.altitude,
        },
      });

      // Clear old data after saving
      accelerometerData.clear();
      gyroscopeData.clear();

      sec++;
    });
  }
  service.on('startService').listen((event) async {
    startCollecting();
  });
  startCollecting();

}


