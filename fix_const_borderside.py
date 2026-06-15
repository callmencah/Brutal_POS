import os
import glob
import re

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    
    if 'const BorderSide(' in content:
        content = content.replace('const BorderSide(', 'BorderSide(')
        modified = True
        
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated BorderSide in {filepath}")
