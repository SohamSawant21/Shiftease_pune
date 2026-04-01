import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/request_provider.dart';
import '../../models/request.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _paymentController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _helpersCount = 2;

  String get _formattedDateTime {
    if (_selectedDate == null || _selectedTime == null) return "Select Date & Time";
    final dt = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dt);
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  void _submit() {
    // Null-safe check — currentState can theoretically be null during hot-reload
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date & Time')),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    final req = Request(
      id: 'SH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      dateTime: dateTime,
      duration: int.tryParse(_durationController.text.trim()) ?? 1,
      helpers: _helpersCount,
      payment: double.tryParse(_paymentController.text.trim()) ?? 0.0,
    );

    if (!mounted) return;
    Provider.of<RequestProvider>(context, listen: false).addRequest(req);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Create Request', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post a New Job',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tell us what you need moved. We'll connect you with the best local helpers in Pune within minutes.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Contact Information', Icons.person),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Name',
                        controller: _nameController,
                        hint: 'e.g. Rahul Sharma',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Mobile Number',
                        controller: _phoneController,
                        hint: '+91 00000 00000',
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid number' : null,
                      ),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('Shift Details', Icons.local_shipping),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Location',
                        controller: _locationController,
                        hint: 'Area, Landmark, or Society Name',
                        prefixIcon: Icons.location_on,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter location' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Date & Time'),
                      InkWell(
                        onTap: _pickDateTime,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppTheme.outline),
                              const SizedBox(width: 12),
                              Text(
                                _formattedDateTime,
                                style: TextStyle(
                                  color: _selectedDate == null ? AppTheme.outline : AppTheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Duration (in hours)',
                        controller: _durationController,
                        hint: '2',
                        prefixIcon: Icons.timer,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter duration' : null,
                      ),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('Requirement & Payment', Icons.group_add),
                      const SizedBox(height: 16),
                      _buildLabel('Number of Helpers'),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: AppTheme.primary),
                              onPressed: () {
                                if (_helpersCount > 1) setState(() => _helpersCount--);
                              },
                            ),
                            Text('$_helpersCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.add, color: AppTheme.primary),
                              onPressed: () {
                                setState(() => _helpersCount++);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Offered Payment (₹)',
                        controller: _paymentController,
                        hint: '1500',
                        prefixText: '₹ ',
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter amount' : null,
                      ),
                      
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Post Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(width: 12),
                              Icon(Icons.send),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'SAFE & SECURE PAYMENT VIA SHIFTEASE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppTheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.outline),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.outline) : null,
            prefixText: prefixText,
            prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface, fontSize: 16),
            filled: true,
            fillColor: AppTheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          ),
        ),
      ],
    );
  }
}
