import os

filepath = r'lib\features\payment\payment_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the missing imports
if "package:intl/intl.dart" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:intl/intl.dart';")

# Fix the RefreshNotifier method
content = content.replace("RefreshNotifier.notifyRefresh()", "triggerGlobalRefresh()")

# Add the missing closing brace for the state class
content = content.replace("\nclass _MethodInfo {", "}\n\nclass _MethodInfo {")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Fixed payment_screen.dart")
