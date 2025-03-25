import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncentiveScreen extends StatefulWidget {
  final Map<String, dynamic> formData;

  const IncentiveScreen({Key? key, required this.formData}) : super(key: key);

  @override
  _IncentiveScreenState createState() => _IncentiveScreenState();
}

class _IncentiveScreenState extends State<IncentiveScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _showEmailField = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitToFirebase({bool withEmail = false}) async {
    setState(() => _isLoading = true);

    try {
      String docId = '';
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference users = firestore.collection('users');
      DocumentReference counterRef = firestore.collection('counters').doc('users');

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot counterSnapshot = await transaction.get(counterRef);
        int newId = 1;

        if (counterSnapshot.exists) {
          newId = (counterSnapshot.get('count') as int) + 1;
        }

        docId = 'USER${newId.toString().padLeft(4, '0')}';

        // Create a copy of the form data
        Map<String, dynamic> userData = Map.from(widget.formData);

        // Add email if provided
        if (withEmail && _emailController.text.isNotEmpty) {
          userData['email'] = _emailController.text;
        }

        userData['createdAt'] = FieldValue.serverTimestamp();

        transaction.set(users.doc(docId), userData);
        transaction.set(counterRef, {'count': newId});
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', docId);

      Navigator.pushNamed(context, '/thankyouSplash');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 64,
                          color: Colors.blueGrey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Get Rewarded!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Would you like to receive incentives for participating in our survey?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 30),

                        // Show email field only if user wants incentives
                        if (_showEmailField) ...[
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blueGrey),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () {
                                if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please enter a valid email address'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                _submitToFirebase(withEmail: true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                elevation: 3,
                                shadowColor: Colors.blueGrey.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Text(
                                'SUBMIT WITH EMAIL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Column(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _isLoading ? null : () {
                                  setState(() {
                                    _showEmailField = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                ),
                                child: Text(
                                  'Yes, I want rewards',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: _isLoading ? null : () {
                                  _submitToFirebase(withEmail: false);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blueGrey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                ),
                                child: Text(
                                  'No thanks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}