import os

with open('lib/features/shell/main_shell.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if "import '../../core/theme/app_theme.dart';" not in content:
    content = "import '../../core/theme/app_theme.dart';\n" + content

with open('lib/features/shell/main_shell.dart', 'w', encoding='utf-8') as f:
    f.write(content)
