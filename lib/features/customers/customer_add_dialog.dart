import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/customer.dart';
import 'bloc/customer_cubit.dart';

Future<void> showCustomerAddDialog(
  BuildContext context, {
  Customer? existingCustomer,
}) async {
  final nameController =
      TextEditingController(text: existingCustomer?.name ?? '');
  final phoneController =
      TextEditingController(text: existingCustomer?.phone ?? '');
  final isEditing = existingCustomer != null;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 3),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shadow, offset: Offset(6, 6), blurRadius: 0),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'EDIT CUSTOMER' : 'ADD CUSTOMER',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 60, height: 3, color: AppColors.primary),
              const SizedBox(height: 24),
              // Name
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 3),
                ),
                child: TextField(
                  controller: nameController,
                  style: GoogleFonts.inter(
                      fontSize: 16, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Customer Name *',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 16, color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.person_rounded,
                        color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Phone
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 3),
                ),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                      fontSize: 16, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Phone (optional)',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 16, color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.phone_rounded,
                        color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          border: Border.all(color: AppColors.border, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (nameController.text.trim().isNotEmpty) {
                          final phone = phoneController.text.trim().isEmpty
                              ? null
                              : phoneController.text.trim();
                          if (isEditing) {
                            context.read<CustomerCubit>().updateCustomer(
                                  existingCustomer.id!,
                                  nameController.text.trim(),
                                  phone,
                                );
                          } else {
                            context.read<CustomerCubit>().addCustomer(
                                  nameController.text.trim(),
                                  phone,
                                );
                          }
                          Navigator.pop(dialogContext);
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border: Border.all(color: AppColors.shadow, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(3, 3),
                                blurRadius: 0),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'SAVE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  nameController.dispose();
  phoneController.dispose();
}

