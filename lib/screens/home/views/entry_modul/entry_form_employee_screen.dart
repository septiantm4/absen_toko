import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:absen_toko/components/my_text_field.dart';

class EntryFormEmployeeScreen extends StatefulWidget {
  const EntryFormEmployeeScreen({Key? key}) : super(key: key);

  @override
  _EntryFormEmployeeScreenState createState() =>
      _EntryFormEmployeeScreenState();
}

class _EntryFormEmployeeScreenState extends State<EntryFormEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _selectedDate;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  String? _errorMsg;
  bool _isLoading = false; // Track loading state

  bool _isFormEmpty() {
    return _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _selectedDate == null ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _streetAddressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _zipCodeController.text.isEmpty ||
        _positionController.text.isEmpty;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading state to true
      });

      try {
        // Generate a unique employee ID based on first name initials and a random number
        String employeeID =
            '${_firstNameController.text.trim()[0]}${_lastNameController.text.trim()[0]}${Random().nextInt(999)}';

        // Access Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Create a new document reference in 'employees' collection
        DocumentReference docRef = await firestore.collection('employees').add({
          'employeeID': employeeID,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'date_of_birth': _selectedDate,
          'email': _emailController.text,
          'phone_number': _phoneController.text,
          'street_address': _streetAddressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zip_code': _zipCodeController.text,
          'position': _positionController.text,
        });

        // Show popup confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Employee Added'),
              content: Text(
                  'Employee has been successfully added with ID: $employeeID'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );

        // Clear all text fields after successful submission
        _firstNameController.clear();
        _lastNameController.clear();
        _selectedDate = null;
        _emailController.clear();
        _phoneController.clear();
        _streetAddressController.clear();
        _cityController.clear();
        _stateController.clear();
        _zipCodeController.clear();
        _positionController.clear();
      } catch (e) {
        print('Error adding document: $e');
        // Handle error as needed
      } finally {
        setState(() {
          _isLoading = false; // Set loading state to false after processing
        });
      }
    }
  }

  Widget _buildBorderedTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required TextInputType keyboardType,
    required String? errorMsg,
    required String? Function(String?)? validator,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          errorText: errorMsg,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Form Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: _buildBorderedTextField(
                        controller: _firstNameController,
                        hintText: 'First Name',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        errorMsg: _errorMsg,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please fill in this field';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBorderedTextField(
                        controller: _lastNameController,
                        hintText: 'Last Name',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        errorMsg: _errorMsg,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please fill in this field';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildBorderedTextField(
                      controller: TextEditingController(
                          text: _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : ''),
                      hintText: 'Date of Birth',
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      errorMsg: _errorMsg,
                      validator: (val) {
                        if (_selectedDate == null) {
                          return 'Please select your date of birth';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBorderedTextField(
                  controller: _emailController,
                  hintText: 'E-Mail',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildBorderedTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildBorderedTextField(
                  controller: _streetAddressController,
                  hintText: 'Street',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildBorderedTextField(
                  controller: _cityController,
                  hintText: 'City',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildBorderedTextField(
                  controller: _stateController,
                  hintText: 'State',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildBorderedTextField(
                  controller: _zipCodeController,
                  hintText: 'Zip Code',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildBorderedTextField(
                  controller: _positionController,
                  hintText: 'Position',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          height: 50,
                          width: 400,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            onPressed: _isFormEmpty() ? null : _submitForm,
                            child: const Text(
                              'Submit',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
