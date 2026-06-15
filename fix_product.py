import os

path = 'lib/features/products/product_manage_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the hint text
content = content.replace("iconCtrl.text.isEmpty ? 'Pilih icon' : 'Icon dipilih'", "iconCtrl.text.isEmpty ? 'Pilih Emoji dari Grid Bawah' : 'Emoji Terpilih'")
content = content.replace("iconCtrl.text.isEmpty ? '🍽️' : iconCtrl.text", "iconCtrl.text.isEmpty ? '🍔' : iconCtrl.text")

# Add a text hint above the emoji grid
emoji_grid_hint = """                          Text(
                            'Pilih Icon (Emoji)',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Emoji grid"""

content = content.replace('                          // Emoji grid', emoji_grid_hint)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
