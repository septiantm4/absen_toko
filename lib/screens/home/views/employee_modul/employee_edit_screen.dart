import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:absen_toko/components/my_text_field.dart';

class EditEmployeeScreen extends StatefulWidget {
  final DocumentSnapshot employeeDoc;

  const EditEmployeeScreen({Key? key, required this.employeeDoc})
      : super(key: key);

  @override
  _EditEmployeeScreenState createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
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
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  void _loadEmployeeData() {
    var data = widget.employeeDoc.data() as Map<String, dynamic>;
    _firstNameController.text = data['first_name'];
    _lastNameController.text = data['last_name'];
    _selectedDate = (data['date_of_birth'] as Timestamp).toDate();
    _emailController.text = data['email'];
    _phoneController.text = data['phone_number'];
    _streetAddressController.text = data['street_address'];
    _cityController.text = data['city'];
    _stateController.text = data['state'];
    _zipCodeController.text = data['zip_code'];
    _positionController.text = data['position'];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('employees')
            .doc(widget.employeeDoc.id)
            .update({
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

        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Employee Updated'),
              content: const Text(
                  'Employee details have been successfully updated.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Close the edit screen
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error updating document: $e');
      } finally {
        setState(() {
          _isLoading = false;
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
        title: const Text('Edit Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBorderedTextField(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBorderedTextField(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBorderedTextField(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBorderedTextField(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBorderedTextField(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBorderedTextField(
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBorderedTextField(
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
                            onPressed: _submitForm,
                            child: const Text(
                              'Update',
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
