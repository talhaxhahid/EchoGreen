import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'background_service.dart';
import 'location_service.dart';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isCollecting=false;
  bool isRunning=false;

  @override
  void initState() {
    checkBackground();
    super.initState();
    _requestLocation();
  }
  Future<void> checkBackground() async {
    final service = FlutterBackgroundService();
    isRunning=  await  service.isRunning();
    final prefs = await SharedPreferences.getInstance();
    final result=await prefs.getString('iscollecting');
    if(result=='true' && isRunning)
      {
        isCollecting=true;
      }
    else{
        isCollecting=false;
    }
    setState(() {
    });

  }
  void startDataCollection() async {
    bool hasFullLocationPermission = await LocationService.checkLocationPermission();
    if(hasFullLocationPermission) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('purpose', tripPurpose);
      await prefs.setString('mode', travelMode);
      if (tripPurpose != '' && travelMode != '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data collection started')),

        );
        await prefs.setString('iscollecting', 'true');
        final service = FlutterBackgroundService();
        isRunning = await service.isRunning();
        if (!isRunning) {
          initializeService();
        }
        else {
          FlutterBackgroundService().invoke('startService');
        }
        setState(() {
          isCollecting = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select trip purpose and travel mode')),
        );
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kindly Enable Location Permission in the Apps Settings')),
      );
    }
  }
  void stopDataCollection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('iscollecting', 'false');
    FlutterBackgroundService().invoke('stopService');
    setState(() {
      isCollecting=false;
    });

  }

  Future<void> _requestLocation() async {
    await LocationService.requestLocationPermission();

  }

  final _formKey = GlobalKey<FormState>();
  String tripPurpose='';
  String travelMode='';

  List<String> tripPurposes = [
    'Work', 'Leisure', 'Errand', 'Exercise', 'Shopping', 'School', 'Medical', 'Visiting', 'Tourism'
  ];
  List<String> travelModes = [
    'Car', 'Bike', 'Bus', 'Walk', 'Train', 'Scooter', 'Taxi', 'Subway', 'Plane'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Safar', style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold)),
            InkWell( onTap: (){
              Navigator.pushNamed(context, '/settings');
            }, child: Icon(Icons.settings_rounded, color: Colors.white)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Lottie.asset(
                'Assets/register.json',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Start Your Trip',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey.shade200),
              ),
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Trip Purpose',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.blueGrey)
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: tripPurposes.map((purpose) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ChoiceChip(
                            label: Text(purpose),
                            selected: tripPurpose == purpose,
                            onSelected: (selected) {
                              setState(() {
                                tripPurpose = purpose;
                              });
                            },
                            selectedColor: Colors.blueGrey,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: tripPurpose == purpose ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Mode of Travel',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.blueGrey)
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: travelModes.map((mode) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ChoiceChip(
                            label: Text(mode),
                            selected: travelMode == mode,
                            onSelected: (selected) {
                              setState(() {
                                travelMode = mode;
                              });
                            },
                            selectedColor: Colors.blueGrey,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: travelMode == mode ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: isCollecting
                  ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                    onPressed: stopDataCollection,
                    child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Stop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                                    ],
                                  ),
                  )
                  :ElevatedButton(
                onPressed: startDataCollection,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Start',style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
