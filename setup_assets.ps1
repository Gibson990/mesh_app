# PowerShell script to set up app icon and splash screen
Write-Host "🎨 Setting up Mesh App Icon and Splash Screen..." -ForegroundColor Cyan
Write-Host ""

# Check if we need to convert SVG to PNG
$iconPngExists = Test-Path "assets/icon/app_icon.png"
$splashPngExists = Test-Path "assets/splash/splash_icon.png"

if (-not $iconPngExists -or -not $splashPngExists) {
    Write-Host "⚠️  PNG files not found. You need to convert SVG to PNG first." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Quick Steps:" -ForegroundColor Cyan
    Write-Host "1. Go to: https://svgtopng.com/" -ForegroundColor White
    Write-Host "2. Upload: assets/icon/app_icon.svg" -ForegroundColor White
    Write-Host "3. Set size: 1024x1024px" -ForegroundColor White
    Write-Host "4. Download and save as: assets/icon/app_icon.png" -ForegroundColor White
    Write-Host ""
    Write-Host "5. Upload again with size: 512x512px" -ForegroundColor White
    Write-Host "6. Download and save as: assets/splash/splash_icon.png" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "✅ PNG files found!" -ForegroundColor Green
Write-Host ""

# Run flutter pub get
Write-Host "📦 Getting dependencies..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "🎨 Generating app icons..." -ForegroundColor Cyan
flutter pub run flutter_launcher_icons

Write-Host ""
Write-Host "🖼️  Generating splash screens..." -ForegroundColor Cyan
flutter pub run flutter_native_splash:create

Write-Host ""
Write-Host "✅ Done! Your app now has:" -ForegroundColor Green
Write-Host "  ✅ Custom app icon" -ForegroundColor White
Write-Host "  ✅ Custom splash screen" -ForegroundColor White
Write-Host "  ✅ All platform sizes generated" -ForegroundColor White
Write-Host ""
Write-Host "Next: Run 'flutter run' to see your new icon and splash!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
