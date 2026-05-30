import 'package:expense_income/presentation/state_holders/add_income_controller.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddIncomeController>(
      builder: (controller) {
        final Size size = MediaQuery.of(context).size;

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildTop(size),
                      _buildAddIncome(size, context, controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.navigate_before),
          ),
          const Expanded(
            child: Text(
              'Add Income',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAddIncome(
      Size size,
      BuildContext context,
      AddIncomeController controller,
      ) {
    return Positioned(
      left: 24,
      right: 24,
      top: size.height * .18,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.categoryTEController,
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
                controller: controller.amountTEController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.pickDate(context),
                  child: Text(
                    controller.selectedDate == null
                        ? 'Select Date'
                        : DateFormat(
                      'dd MMM yyyy',
                    ).format(controller.selectedDate!),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: controller.descriptionTEController,
                maxLines: 2,
                maxLength: 120,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  labelText: 'Description',
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : controller.saveIncome,
                  child: controller.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}