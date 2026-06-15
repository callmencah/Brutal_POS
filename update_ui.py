import os
import re

# 1. Update products_screen.dart to enlarge the Cart Icon
file_products = r'lib\features\products\products_screen.dart'
with open(file_products, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the Cart stack
old_cart = """              return Stack(
                children: [
                  IconButton(
                    onPressed: () => context.push('/cart'),
                    icon: Icon(Icons.shopping_cart_rounded,
                        color: AppColors.textPrimary, size: 28),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              );"""

new_cart = """              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    iconSize: 42,
                    padding: const EdgeInsets.all(12),
                    onPressed: () => context.push('/cart'),
                    icon: Icon(Icons.shopping_cart_rounded,
                        color: AppColors.textPrimary),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border: Border.all(color: Colors.black, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );"""

content = content.replace(old_cart, new_cart)

# Add width to the SizedBox at the end of actions
content = content.replace("          const SizedBox(width: 8),\n        ],", "          const SizedBox(width: 16),\n        ],")

with open(file_products, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated products_screen.dart")

# 2. Update product_grid_item.dart to make the card look professional
file_grid_item = r'lib\features\products\widgets\product_grid_item.dart'
with open(file_grid_item, 'r', encoding='utf-8') as f:
    content = f.read()

old_card = """              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  Text(
                    product.imageIcon ?? '🍽️',
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 1),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      border: Border(
                        top: BorderSide(color: AppColors.border, width: 2),
                      ),
                    ),
                    child: Text(
                      AppConstants.formatCurrency(product.price),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),"""

new_card = """              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(bottom: BorderSide(color: AppColors.border, width: 3)),
                      ),
                      child: Center(
                        child: Text(
                          product.imageIcon ?? '🍽️',
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.formatCurrency(product.price),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),"""

content = content.replace(old_card, new_card)

with open(file_grid_item, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated product_grid_item.dart")

