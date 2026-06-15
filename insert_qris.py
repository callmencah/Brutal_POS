import os

filepath = r'lib\features\payment\payment_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

method_code = """
  Widget _buildQrisSuccessView(BuildContext context, PaymentState state) {
    final formatCurrency = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.primary, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        offset: const Offset(8, 8),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SCAN TO PAY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: 250,
                        height: 250,
                        color: AppColors.textPrimary,
                        child: Center(
                          child: Icon(Icons.qr_code_2, size: 200, color: AppColors.surface),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'TOTAL AMOUNT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency.format(state.totalAmount),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 400,
                  child: BrutalButton(
                    text: 'BACK TO HOME',
                    icon: Icons.home,
                    onPressed: () {
                      RefreshNotifier.notifyRefresh();
                      context.read<CartCubit>().clearCart();
                      context.go('/home');
                    },
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
"""

content = content.replace("  }\n}\n\nclass _MethodInfo {", method_code + "\nclass _MethodInfo {")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated payment_screen.dart")
