@echo off
echo ========================================
echo    Supermarket List - Auto Update
echo ========================================
echo.

REM Check if git is available
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git is not installed. Attempting to install automatically...
    echo.
    
    REM Check if winget is available
    winget --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo Installing Git using winget...
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
        if %errorlevel% equ 0 (
            echo Git installed successfully!
            echo Refreshing environment variables...
            call refreshenv >nul 2>&1
            echo.
            echo Please restart this script to continue.
            pause
            exit /b 0
        ) else (
            echo Failed to install Git using winget.
            echo.
        )
    ) else (
        echo winget is not available.
        echo.
    )
    
    REM Check if chocolatey is available
    choco --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo Installing Git using Chocolatey...
        choco install git -y
        if %errorlevel% equ 0 (
            echo Git installed successfully!
            echo Refreshing environment variables...
            call refreshenv >nul 2>&1
            echo.
            echo Please restart this script to continue.
            pause
            exit /b 0
        ) else (
            echo Failed to install Git using Chocolatey.
            echo.
        )
    ) else (
        echo Chocolatey is not available.
        echo.
    )
    
    echo Automatic Git installation failed.
    echo Please install Git manually:
    echo 1. Go to: https://git-scm.com/downloads
    echo 2. Download and install Git for Windows
    echo 3. Restart this script after installation
    echo.
    echo Opening Git download page...
    start https://git-scm.com/downloads
    pause
    exit /b 1
)

echo [1/4] Checking repository status...
git status --porcelain >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Not a git repository
    echo Please run this from your project directory
    pause
    exit /b 1
)

echo [2/4] Adding all changes to staging...
git add .
if %errorlevel% neq 0 (
    echo ERROR: Failed to add files to staging
    pause
    exit /b 1
)

echo [3/4] Committing changes...
set timestamp=%date% %time%
git commit -m "Auto-update: %timestamp%"
if %errorlevel% neq 0 (
    echo WARNING: No changes to commit (repository is up to date)
    echo.
)

echo [4/4] Pushing to remote repository...
git push origin main
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to push to remote repository
    echo.
    echo Possible solutions:
    echo 1. Check your internet connection
    echo 2. Verify your GitHub repository URL is correct
    echo 3. Make sure you have push permissions
    echo 4. Check if remote repository exists
    echo.
    echo To set up remote repository, run:
    echo   git remote add origin YOUR_GITHUB_REPO_URL
    echo   git push -u origin main
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo    SUCCESS! Repository updated!
echo ========================================
echo.
echo Your changes have been:
echo ✓ Added to staging
echo ✓ Committed with timestamp
echo ✓ Pushed to GitHub
echo.
echo Next steps:
echo 1. Deploy on Railway: https://railway.app
echo 2. Or deploy on Render: https://render.com
echo 3. Get your free public URL!
echo.
pause
