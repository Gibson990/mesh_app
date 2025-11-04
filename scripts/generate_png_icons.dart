import 'dart:io';
import 'lib/utils/generate_icon_png.dart';

void main() async {
  print('🎨 Generating PNG icons from code...');
  print('');
  
  try {
    await IconGenerator.generateIcons();
    print('');
    print('✅ Done! PNG files created in:');
    print('   - assets/icon/app_icon.png');
    print('   - assets/splash/splash_icon.png');
    print('');
    print('Next steps:');
    print('1. flutter pub run flutter_launcher_icons');
    print('2. flutter pub run flutter_native_splash:create');
    print('3. flutter run');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
