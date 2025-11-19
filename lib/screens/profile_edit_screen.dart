import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedUniversity = 'Vinoba Bhave University Hazaribagh';
  String _selectedCollege = 'Annada College Hazaribagh';
  String _selectedSemester = '1';
  bool _isOtherCollege = false;
  final _otherCollegeController = TextEditingController();

  final List<String> _universities = [
    'Vinoba Bhave University Hazaribagh',
  ];

  final List<String> _colleges = [
    'Annada College Hazaribagh',
    'St. Columbus College Hazaribagh',
    'Markham College Hazaribagh',
    'Chatra College',
    'Ramgarh College',
    'KB Women\'s College',
    'University Department of Computer Applications VBU',
    'Other',
  ];

  final List<String> _semesters = ['1', '2', '3', '4', '5', '6'];

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userModel = authProvider.userModel;
      
      if (userModel != null) {
        _nameController.text = userModel.name;
        
        // Remove +91 prefix if present for display
        if (userModel.phone != null) {
          String phone = userModel.phone!;
          if (phone.startsWith('+91')) {
            phone = phone.substring(3).trim();
          }
          _phoneController.text = phone;
        }
        
        _selectedSemester = userModel.semester;
        
        if (userModel.university != null && _universities.contains(userModel.university)) {
          _selectedUniversity = userModel.university!;
        }
        
        if (_colleges.contains(userModel.collegeName)) {
          _selectedCollege = userModel.collegeName;
        } else {
          _selectedCollege = 'Other';
          _isOtherCollege = true;
          _otherCollegeController.text = userModel.collegeName;
        }
        
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otherCollegeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.edit_rounded,
                  size: 80,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Update Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep your information up to date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedUniversity,
                  decoration: InputDecoration(
                    labelText: 'University',
                    prefixIcon: const Icon(Icons.account_balance),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  isExpanded: true,
                  items: _universities.map((university) {
                    return DropdownMenuItem(
                      value: university,
                      child: Text(
                        university,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUniversity = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCollege,
                  decoration: InputDecoration(
                    labelText: 'College Name',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  isExpanded: true,
                  items: _colleges.map((college) {
                    return DropdownMenuItem(
                      value: college,
                      child: Text(
                        college,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCollege = value!;
                      _isOtherCollege = value == 'Other';
                      if (!_isOtherCollege) {
                        _otherCollegeController.clear();
                      }
                    });
                  },
                ),
                if (_isOtherCollege) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _otherCollegeController,
                    decoration: InputDecoration(
                      labelText: 'Enter Your College Name',
                      prefixIcon: const Icon(Icons.edit),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Type your college name',
                    ),
                    validator: (value) {
                      if (_isOtherCollege && (value == null || value.trim().isEmpty)) {
                        return 'Please enter your college name';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  decoration: InputDecoration(
                    labelText: 'Semester',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _semesters.map((semester) {
                    return DropdownMenuItem(
                      value: semester,
                      child: Text('Semester $semester'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSemester = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    prefixIcon: const Icon(Icons.phone),
                    prefixText: '+91 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'XXXXX XXXXX',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 40),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final collegeName = _isOtherCollege 
                                    ? _otherCollegeController.text.trim()
                                    : _selectedCollege;
                                
                                final phoneNumber = _phoneController.text.trim().isEmpty 
                                    ? null 
                                    : '+91${_phoneController.text.trim()}';
                                    
                                final success = await authProvider.updateProfile(
                                  name: _nameController.text.trim(),
                                  collegeName: collegeName,
                                  semester: _selectedSemester,
                                  university: _selectedUniversity,
                                  phone: phoneNumber,
                                );
                                
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profile updated successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to update profile'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
