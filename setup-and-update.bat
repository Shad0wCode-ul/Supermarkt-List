@echo off
echo ========================================
echo  Supermarket List - Setup & Auto Update
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

echo [1/6] Checking repository status...
git status --porcelain >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Not a git repository
    echo Please run this from your project directory
    pause
    exit /b 1
)

REM Check if remote is configured
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo    GitHub Repository Setup Required
    echo ========================================
    echo.
    echo No remote repository configured.
    echo You need to set up your GitHub repository first.
    echo.
    echo Steps:
    echo 1. Go to https://github.com
    echo 2. Create a new repository named "Supermarkt-List"
    echo 3. Make it PUBLIC (required for free hosting)
    echo 4. Don't initialize with README
    echo 5. Copy the repository URL
    echo.
    set /p repo_url="Enter your GitHub repository URL: "
    if "%repo_url%"=="" (
        echo ERROR: No repository URL provided
        pause
        exit /b 1
    )
    
    echo.
    echo [Setup] Adding remote repository...
    git remote add origin %repo_url%
    if %errorlevel% neq 0 (
        echo ERROR: Failed to add remote repository
        echo Please check your repository URL
        pause
        exit /b 1
    )
    
    echo [Setup] Setting up main branch...
    git branch -M main
    
    echo [Setup] Pushing initial code...
    git push -u origin main
    if %errorlevel% neq 0 (
        echo ERROR: Failed to push to GitHub
        echo Please check your repository URL and permissions
        pause
        exit /b 1
    )
    
    echo.
    echo ========================================
    echo    GitHub Repository Setup Complete!
    echo ========================================
    echo.
    echo Your repository is now connected to GitHub.
    echo You can now use update-repo.bat for future updates.
    echo.
    echo Next steps:
    echo 1. Deploy on Railway: https://railway.app
    echo 2. Or deploy on Render: https://render.com
    echo 3. Get your free public URL!
    echo.
    pause
    exit /b 0
)

echo [2/6] Adding all changes to staging...
git add .
if %errorlevel% neq 0 (
    echo ERROR: Failed to add files to staging
    pause
    exit /b 1
)

echo [3/6] Checking for changes...
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo No changes to commit (repository is up to date)
    echo.
    echo Current status:
    git status --short
    echo.
    pause
    exit /b 0
)

echo [4/6] Committing changes...
set timestamp=%date% %time%
git commit -m "Auto-update: %timestamp%"
if %errorlevel% neq 0 (
    echo ERROR: Failed to commit changes
    pause
    exit /b 1
)

echo [5/6] Pushing to remote repository...
git push origin main
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to push to remote repository
    echo.
    echo Possible solutions:
    echo 1. Check your internet connection
    echo 2. Verify your GitHub repository URL is correct
    echo 3. Make sure you have push permissions
    echo 4. Try: git pull origin main (to sync first)
    echo.
    pause
    exit /b 1
)

echo [6/6] Verifying push...
git status
if %errorlevel% neq 0 (
    echo WARNING: Could not verify push status
)

echo.
echo ========================================
echo    SUCCESS! Repository updated!
echo ========================================
echo.
echo Your changes have been:
echo ✓ Added to staging
echo ✓ Committed with timestamp: %timestamp%
echo ✓ Pushed to GitHub
echo.
echo Repository URL: 
git remote get-url origin
echo.
echo Next steps:
echo 1. Deploy on Railway: https://railway.app
echo 2. Or deploy on Render: https://render.com
echo 3. Get your free public URL!
echo.
pause
