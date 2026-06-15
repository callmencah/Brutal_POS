import os

filepath = r'lib\features\payment\payment_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the missing brace before _buildQrisSuccessView
content = content.replace("      },\n    );\n\n  Widget _buildQrisSuccessView(", "      },\n    );\n  }\n\n  Widget _buildQrisSuccessView(")

# Fix the extra brace at the end
content = content.replace("  }\n}\n}\n\nclass _MethodInfo {", "  }\n}\n\nclass _MethodInfo {")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Fixed syntax in payment_screen.dart")
