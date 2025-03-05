import 'package:flutter/material.dart';


import 'form_screen_2.dart';
class FormScreen1 extends StatefulWidget {
  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<FormScreen1> {
  final _formKey = GlobalKey<FormState>();
  bool _isPrivacyPolicyChecked = false;
  bool _isTermsChecked = false;
  String? _selectedGender="Male";
  String age='';
  String? _selectedCity;
  int _selectedIndex = 0; // Add this in your state
  List<String> Gender =["Male" ,"Female","Other"];

  TextEditingController _residentialAreaController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _familyMembersController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(10.0),
        child: AppBar(
          backgroundColor : Colors.white,
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(

        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('Assets/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              )
              ,
                  SizedBox(height: 16),
                  Text(
                    "REGISTER",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey,
                      letterSpacing: 1.5,
                      fontFamily: 'Roboto',
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black12,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  )
                  ,
                  SizedBox(height: 16),


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
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          child: Container(

                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedIndex == index
                                  ? Colors.blueGrey
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                '${Gender[index]}',
                                style: TextStyle(
                                  color: _selectedIndex == index
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 15,
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

                  SizedBox(height: 26),
              DropdownButtonFormField<String>(
                value: null, // Set to null initially or use a default value
                decoration: InputDecoration(
                  labelText: "Age",
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
                ),
                items: [
                  '18 - 20',
                  '21 - 25',
                  '26 - 30',
                  '31 - 35',
                  '36 - 40',
                  '41 - 45',
                  '46 - 50',
                  '51+',
                ].map((String ageBand) {
                  return DropdownMenuItem<String>(
                    value: ageBand,
                    child: Text(ageBand),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  age=newValue ?? 'No Age specified';
                },
                validator: (value) => value == null ? 'Please select your Age' : null,
              )

              ,
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "City",
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
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.location_city, color: Colors.blueGrey),
                    iconSize: 24,
                    value: _selectedCity,
                    items: ["Karachi", "Lahore", "Islamabad", "Rawalpindi", "Faisalabad", "Multan", "Peshawar", "Quetta", "Sialkot", "Gujranwala"]
                        .map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(
                        city,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a city' : null,
                  )
                  ,
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _residentialAreaController,
                    decoration: InputDecoration(
                      labelText: "Residential Area",
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
                      suffixIcon: Icon(Icons.home, color: Colors.blueGrey),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter residential area' : null,
                  )
                  ,
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _familyMembersController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Number of Family Members",
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
                      suffixIcon: Icon(Icons.group, color: Colors.blueGrey),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter number of family members' : null,
                  )
                  ,
                  SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _isPrivacyPolicyChecked,
                            activeColor: Colors.blueGrey,
                            onChanged: (value) {
                              setState(() {
                                _isPrivacyPolicyChecked = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: "I agree to the ",
                                style: TextStyle(color: Colors.black87),
                                children: [
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      decoration: TextDecoration.underline,
                                    ),
                                    // Add onTap functionality if needed
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isTermsChecked,
                            activeColor: Colors.blueGrey,
                            onChanged: (value) {
                              setState(() {
                                _isTermsChecked = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: "I agree to the ",
                                style: TextStyle(color: Colors.black87),
                                children: [
                                  TextSpan(
                                    text: "Terms & Conditions",
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      decoration: TextDecoration.underline,
                                    ),
                                    // Add onTap functionality if needed
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  )
                  ,
                  SizedBox(

                    child: InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          if(_isPrivacyPolicyChecked && _isTermsChecked){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormScreen2(
                                  selectedGender: Gender[_selectedIndex],
                                  age: age,
                                  city: _selectedCity!,
                                  residentialArea: _residentialAreaController.text,
                                  familyMembers: _familyMembersController.text,
                                ),
                              ),
                            );
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Kindly Agree to Privacy Policy and Terms & Conditions")),
                            );
                          }

                        }
                      },

                      child: Container(
                        width: 120,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(30), // 50% border radius
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    ,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
