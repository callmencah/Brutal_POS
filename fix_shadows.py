import glob

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if 'boxShadow:' in content and 'Colors.black' in content:
        content = content.replace('color: Colors.black', 'color: AppColors.shadow')
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
            print(f'Updated {filepath}')
