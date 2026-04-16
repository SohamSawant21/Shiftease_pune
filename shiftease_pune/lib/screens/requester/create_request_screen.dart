import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/request_provider.dart';
import '../../models/request.dart';
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

    final selectedDate = _selectedDate;
    final selectedTime = _selectedTime;

    if (selectedDate == null || selectedTime == null) return;

    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
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
      status: 'Pending',
    );

    if (!mounted) return;
    Provider.of<RequestProvider>(context, listen: false).addRequest(req);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Header Section
              const Text(
                'Post a New Job',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tell us what you need moved. We'll connect you with the best local helpers in Pune within minutes.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Contact Information Section
              const Text(
                'Contact Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Rahul Sharma',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '+91 00000 00000',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid number' : null,
              ),
              const SizedBox(height: 32),

              // Shift Details Section
              const Text(
                'Shift Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Area, Landmark, or Society Name',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter location' : null,
              ),
              const SizedBox(height: 16),
              
              // Standard Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formattedDateTime,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDateTime,
                    child: const Text('Select Date & Time'),
                  ),
                ],
              ),
              
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (in hours)',
                  hintText: '2',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter duration' : null,
              ),
              const SizedBox(height: 32),

              // Requirement & Payment Section
              const Text(
                'Requirement & Payment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Number of Helpers:', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_helpersCount > 1) {
                        setState(() => _helpersCount--);
                      }
                    },
                  ),
                  Text(
                    '$_helpersCount',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _helpersCount++);
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: _paymentController,
                decoration: const InputDecoration(
                  labelText: 'Offered Payment (₹)',
                  hintText: '1500',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter amount' : null,
              ),
              const SizedBox(height: 32),

              // Basic Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Post Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}