import os
import glob
import re

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    
    # regex to replace 'const [' with '[' if it contains 'AppColors.shadow'
    # Actually, a simpler way is just to replace 'const [' with '[' anywhere near 'boxShadow:'
    # Or just replace 'boxShadow: const [' with 'boxShadow: ['
    
    if 'boxShadow: const [' in content:
        content = content.replace('boxShadow: const [', 'boxShadow: [')
        modified = True
        
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")
