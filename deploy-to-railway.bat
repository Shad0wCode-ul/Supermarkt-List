@echo off
echo ========================================
echo    Deploy to Railway (Free Hosting)
echo ========================================
echo.

echo This will help you deploy your shopping list app to Railway
echo for a free public URL that works from anywhere!
echo.

echo Steps to deploy:
echo.
echo 1. Make sure your code is pushed to GitHub:
echo    - Run setup-and-update.bat first
echo    - Or run update-repo.bat if already set up
echo.
echo 2. Go to Railway:
echo    - Open: https://railway.app
echo    - Sign up with GitHub
echo    - Click "New Project"
echo    - Select "Deploy from GitHub repo"
echo    - Choose your repository
echo    - Railway will auto-deploy!
echo.
echo 3. Get your public URL:
echo    - Railway will give you a URL like: https://your-app.railway.app
echo    - This works from anywhere in the world!
echo.
echo 4. Test on your Android:
echo    - Open the URL in your phone's browser
echo    - Bookmark it for easy access
echo    - Add to home screen for app-like experience
echo.

set /p continue="Have you pushed your code to GitHub? (y/n): "
if /i "%continue%"=="y" (
    echo.
    echo Opening Railway in your browser...
    start https://railway.app
    echo.
    echo Railway should open in your browser.
    echo Follow the steps above to deploy your app!
) else (
    echo.
    echo Please run setup-and-update.bat first to push your code to GitHub.
    echo Then come back and run this script again.
)

echo.
pause
