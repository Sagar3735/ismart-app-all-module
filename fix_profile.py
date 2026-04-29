import os

file_path = 'c:/Users/sagar/Desktop/flutter programm/ismart_app/lib/screens/personal/my_profile_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('AppColors.divider', 'AppColors.border')
content = content.replace('AppTextStyles.subtitle1', 'AppTextStyles.subtitle')
content = content.replace('AppTextStyles.bodySmall', 'AppTextStyles.caption')
content = content.replace('activeColor: AppColors.primary', 'activeThumbColor: AppColors.primary')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed my_profile_screen.dart!')
