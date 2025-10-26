# PowerShell script to generate icons from SVG
# This script helps convert SVG to PNG if you have the tools installed

Write-Host "🎨 Mesh App Icon Generator" -ForegroundColor Cyan
Write-Host ""

# Check if ImageMagick is installed
$imageMagickPath = Get-Command magick -ErrorAction SilentlyContinue

if ($imageMagickPath) {
    Write-Host "✅ ImageMagick found! Generating PNGs..." -ForegroundColor Green
    
    # Generate app icon (1024x1024)
    magick convert -density 300 -background none "assets/icon/app_icon.svg" -resize 1024x1024 "assets/icon/app_icon.png"
    Write-Host "✅ Generated: assets/icon/app_icon.png" -ForegroundColor Green
    
    # Generate splash icon (512x512)
    magick convert -density 300 -background none "assets/icon/app_icon.svg" -resize 512x512 "assets/splash/splash_icon.png"
    Write-Host "✅ Generated: assets/splash/splash_icon.png" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "✅ PNG files generated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. flutter pub get" -ForegroundColor White
    Write-Host "2. flutter pub run flutter_launcher_icons" -ForegroundColor White
    Write-Host "3. flutter pub run flutter_native_splash:create" -ForegroundColor White
    
} else {
    Write-Host "❌ ImageMagick not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please convert SVG to PNG manually:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1: Online Converter (Easiest)" -ForegroundColor Cyan
    Write-Host "  1. Go to: https://svgtopng.com/" -ForegroundColor White
    Write-Host "  2. Upload: assets/icon/app_icon.svg" -ForegroundColor White
    Write-Host "  3. Size: 1024x1024px" -ForegroundColor White
    Write-Host "  4. Save as: assets/icon/app_icon.png" -ForegroundColor White
    Write-Host ""
    Write-Host "  5. Upload again with size: 512x512px" -ForegroundColor White
    Write-Host "  6. Save as: assets/splash/splash_icon.png" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2: Install ImageMagick" -ForegroundColor Cyan
    Write-Host "  Download from: https://imagemagick.org/script/download.php" -ForegroundColor White
    Write-Host "  Then run this script again" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
