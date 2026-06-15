import glob
import re
import os

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    
    if 'AppColors' in content and 'app_theme.dart' not in content:
        parts = filepath.replace('\\\\', '/').split('/')
        depth = len(parts) - 2
        rel_path = '../' * depth + 'core/theme/app_theme.dart'
        
        import_stmt = f"import '{rel_path}';\n"
        content = import_stmt + content
        modified = True
        print(f'Added import to {filepath}')
    
    # regex for 'const <Widget>(...AppColors...)' is too hard, but we can look for 'const ' on the same line as AppColors
    # Actually, we can just run flutter analyze and parse the output to fix any const errors.
    
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
