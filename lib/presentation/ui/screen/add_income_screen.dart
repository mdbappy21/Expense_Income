import 'package:expense_income/data/database_helper.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final GlobalKey<FormState>_formKey=GlobalKey<FormState>();
  DateTime? selectedDate;

  final TextEditingController _categoryTEController = TextEditingController();
  final TextEditingController _amountTEController = TextEditingController();
  final TextEditingController _descriptionTEController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _categoryTEController.dispose();
    _amountTEController.dispose();
    _descriptionTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: size.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildTop(size),
                    _buildAddIncome(size),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildTop(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * .28,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.themeColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(300, 70),
          bottomRight: Radius.elliptical(300, 70),
        ),
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          IconButton(onPressed: () {
            Get.back();
          }, icon: Icon(Icons.navigate_before),),
          Expanded(
            child: Text('Add Income',
              style: TextStyle(
                fontSize: 18,
                fontWeight: .w500,
              ),
              softWrap: true,
              maxLines: 2,
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAddIncome(Size size) {
    return Positioned(
      left: 24,
      right: 24,
      top: size.height * .18,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24)
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryTEController,
                decoration: const InputDecoration(
                  hintText: 'Salary',
                  labelText: 'Category',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountTEController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  labelText: 'Amount',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter amount';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => pickDate(context),
                child: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('dd MMM yyyy').format(selectedDate!),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionTEController,
                maxLines: 2,
                maxLength: 120,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveIncome,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      Get.snackbar('Error', 'Please select date');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await DatabaseHelper.instance.insertIncome(
      category: _categoryTEController.text.trim(),
      amount: double.parse(_amountTEController.text.trim()),
      date: selectedDate!,
      description: _descriptionTEController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    Get.snackbar('Success', 'Income added successfully');
    Get.back();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      currentDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select income date',
      confirmText: 'Select',
      cancelText: 'Cancel',
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}
