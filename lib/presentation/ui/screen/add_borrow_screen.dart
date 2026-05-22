import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddBorrowScreen extends StatefulWidget {
  const AddBorrowScreen({super.key});

  @override
  State<AddBorrowScreen> createState() => _AddBorrowScreenState();
}

class _AddBorrowScreenState extends State<AddBorrowScreen> {
  final GlobalKey<FormState>_formKey=GlobalKey<FormState>();
  DateTime? borrowDate;
  DateTime? returnDate;


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
            child: Text('Borrow',
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
                decoration: InputDecoration(
                    hintText: 'Name',
                    labelText: 'Name'
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Amount',
                    labelText: 'Amount'
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => pickBorrowDate(context),
                child: Text(
                  borrowDate == null
                      ? 'Borrow Date'
                      : DateFormat('dd MMM yyyy').format(borrowDate!),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => pickReturnDate(context),
                child: Text(
                  returnDate == null
                      ? 'Return Date'
                      : DateFormat('dd MMM yyyy').format(returnDate!),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 2,
                maxLength: 120,
                decoration: InputDecoration(
                  hintText: 'Description',
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: (){}, child: Text('Add'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickBorrowDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: borrowDate ?? now,
      currentDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select borrow date',
    );

    if (pickedDate != null) {
      setState(() {
        borrowDate = pickedDate;
      });
    }
  }

  Future<void> pickReturnDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: returnDate ?? now,
      currentDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      helpText: 'Select return date',
    );

    if (pickedDate != null) {
      setState(() {
        returnDate = pickedDate;
      });
    }
  }
}
