import os

base_dir = 'c:/Users/sagar/Desktop/flutter programm/ismart_app/lib/screens'
for root, dirs, files in os.walk(base_dir):
    for file in files:
        if file.endswith('.dart'):
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            new_lines = [line for line in lines if "import '../../theme/app_text_styles.dart';" not in line]
            
            if len(new_lines) != len(lines):
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(new_lines)
print('Removed unused imports!')
