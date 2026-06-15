import os
import glob

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    
    if 'const BoxDecoration(' in content:
        content = content.replace('const BoxDecoration(', 'BoxDecoration(')
        modified = True
        
    if 'const EdgeInsets' in content:
        # EdgeInsets is fine if its arguments are numbers, but let's be careful.
        pass
        
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated BoxDecoration in {filepath}")
