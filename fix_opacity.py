import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace .withOpacity(x) with .withValues(alpha: x)
    # Using regex to match .withOpacity(...) where ... is any number or variable
    new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
    
    # Also fix activeColor to activeThumbColor in Switch
    new_content = re.sub(r'activeColor:', 'activeThumbColor:', new_content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for root, dirs, files in os.walk('lib/screens/attendance'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
