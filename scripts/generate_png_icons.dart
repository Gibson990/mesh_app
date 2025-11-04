import 'dart:io';
import 'dart:developer' as developer;
import '../lib/utils/generate_icon_png.dart';

void main() async {
  developer.log('🎨 Generating PNG icons from code...');
  developer.log('');
  
  try {
    await IconGenerator.generateIcons();
    developer.log('');
    developer.log('✅ Done! PNG files created in:');
    developer.log('   - assets/icon/app_icon.png');
    developer.log('   - assets/splash/splash_icon.png');
    developer.log('');
    developer.log('Next steps:');
    developer.log('1. flutter pub run flutter_launcher_icons');
    developer.log('2. flutter pub run flutter_native_splash:create');
    developer.log('3. flutter run');
  } catch (e) {
    developer.log('❌ Error: $e');
    exit(1);
  }
}
