import 'package:expense_income/presentation/state_holders/add_receivable_controller.dart';
import 'package:expense_income/presentation/ui/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddReceivableScreen extends StatelessWidget {
  const AddReceivableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddReceivableController>(
      builder: (controller) {
        final size = MediaQuery.of(context).size;

        return Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildTop(size),
                  _buildAddReceivable(
                    size,
                    context,
                    controller,
                  ),
                ],
              ),
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
              'Add Receivable',
              textAlign: TextAlign.center,
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

  Widget _buildAddReceivable(
      Size size,
      BuildContext context,
      AddReceivableController controller,
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
                controller: controller.sourceTEController,
                decoration: const InputDecoration(
                  hintText: 'Source',
                  labelText: 'Source',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter source';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: controller.amountTEController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  labelText: 'Amount',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter amount';
                  }

                  if (double.tryParse(
                    value.trim(),
                  ) ==
                      null) {
                    return 'Enter valid amount';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      controller.pickExpectedDate(
                        context,
                      ),
                  child: Text(
                    controller.expectedDate == null
                        ? 'Expected Receive Date'
                        : DateFormat(
                      'dd MMM yyyy',
                    ).format(
                      controller.expectedDate!,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                controller.descriptionTEController,
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
                      : controller.saveReceivable,
                  child: controller.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Add Receivable',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}