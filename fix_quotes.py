import os

base_dir = 'c:/Users/sagar/Desktop/flutter programm/ismart_app/lib/screens'
for root, dirs, files in os.walk(base_dir):
    for file in files:
        if file.endswith('.dart') and file != 'home_screen.dart':
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            if "\\'" in content:
                content = content.replace("\\'", "'")
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
print('Fixed quotes in dart files!')
