import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'form_screen_3.dart';

class FormScreen2 extends StatefulWidget {
  final String selectedGender;
  final String age;
  final String city;
  final String residentialArea;
  final String familyMembers;

  FormScreen2({
    required this.selectedGender,
    required this.age,
    required this.city,
    required this.residentialArea,
    required this.familyMembers,
  });

  @override
  _FormScreen2State createState() => _FormScreen2State();
}

class _FormScreen2State extends State<FormScreen2> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _salaryController = TextEditingController();
  int _selectedCars = 0;
  int _selectedBikes = 0;// Add this in your state
  List<String> _dailyTransport = [];
  bool _isLoading = false;
  String salary='';

  final List<String> _transportOptions = [
    "Walk",
    "Cycle",
    "Own Bike",
    "Uber/InDrive/Careem/Yango/Bykea",
    "Own Car",
    "Speedo Bus",
    "Orange Line",
    "Metro Bus",
    "Local Bus/Van",
    "Rickshaw",
    "Chingchi"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Vehicle Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter Your Salary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: null, // Initially null or set a default value
            decoration: InputDecoration(
              labelText: "Salary",
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.blueGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: Icon(Icons.account_balance_wallet, color: Colors.blueGrey),
            ),
            items: [
              '0 - 25,000',
              '25,001 - 50,000',
              '50,001 - 75,000',
              '75,001 - 100,000',
              '100,001 - 150,000',
              '150,001 - 200,000',
              '200,001+',
            ].map((String salaryBand) {
              return DropdownMenuItem<String>(
                value: salaryBand,
                child: Text(salaryBand),
              );
            }).toList(),
            onChanged: (String? newValue) {
              salary = newValue ?? "This is new value";
            },
            validator: (value) => value == null ? 'Please select your Salary' : null,
          ),
              SizedBox(height: 16),
              Text(
                "Number of Cars Owned",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCars = index;
                              });
                            },
                            child: Container(

                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedCars == index
                                    ? Colors.blueGrey
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${index}',
                                  style: TextStyle(
                                    color: _selectedCars == index
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Number of Bikes Owned",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedBikes = index;
                              });
                            },
                            child: Container(

                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedBikes == index
                                    ? Colors.blueGrey
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${index }',
                                  style: TextStyle(
                                    color: _selectedBikes == index
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Mode of Transport for Daily Trips ",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                " (Select top 2 uses)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _transportOptions.map((option) => _buildCheckbox(option)).toList(),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (_formKey.currentState!.validate() && _dailyTransport.length <= 2) {
                        setState(() {
                          _isLoading = true;
                        });

                        // Prepare all form data
                        Map<String, dynamic> formData = {
                          'gender': widget.selectedGender,
                          'age': widget.age,
                          'city': widget.city,
                          'residentialArea': widget.residentialArea,
                          'familyMembers': widget.familyMembers,
                          'salary': salary,
                          'cars': _selectedCars,
                          'bikes': _selectedBikes,
                          'dailyTransport': _dailyTransport,
                        };

                        // Navigate to incentive screen with all form data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IncentiveScreen(formData: formData),
                          ),
                        ).then((_) {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      } else if (_dailyTransport.length > 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select only top 2 transport modes")),
                        );
                      }
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: _isLoading
                      ? Row(
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
                        'Processing...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildCheckbox(String option) {
    return FilterChip(
      label: Text(option),
      selected: _dailyTransport.contains(option),
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            if (_dailyTransport.length < 2) {
              _dailyTransport.add(option);
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You can only select 2 transport modes")),
              );
            }
          } else {
            _dailyTransport.remove(option);

          }
        });
      },
      selectedColor: Colors.indigo.shade200,
    );
  }
}
