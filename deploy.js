#!/usr/bin/env node

/**
 * Simple deployment helper script
 * This script helps you prepare your app for free hosting deployment
 */

const fs = require('fs');
const path = require('path');

console.log('🚀 Supermarket List - Deployment Helper\n');

// Check if we're in the right directory
if (!fs.existsSync('package.json')) {
    console.error('❌ Error: package.json not found. Make sure you\'re in the project directory.');
    process.exit(1);
}

// Check if git is initialized
if (!fs.existsSync('.git')) {
    console.log('📦 Initializing Git repository...');
    console.log('Run these commands:');
    console.log('  git init');
    console.log('  git add .');
    console.log('  git commit -m "Initial commit"');
    console.log('  git branch -M main');
    console.log('  git remote add origin YOUR_GITHUB_REPO_URL');
    console.log('  git push -u origin main\n');
}

// Check if all required files exist
const requiredFiles = [
    'index.js',
    'package.json',
    'public/index.html',
    'railway.json',
    'Dockerfile'
];

console.log('📋 Checking deployment files...');
let allFilesExist = true;

requiredFiles.forEach(file => {
    if (fs.existsSync(file)) {
        console.log(`  ✅ ${file}`);
    } else {
        console.log(`  ❌ ${file} - Missing!`);
        allFilesExist = false;
    }
});

if (allFilesExist) {
    console.log('\n🎉 All deployment files are ready!');
    console.log('\n📱 Next steps:');
    console.log('1. Push to GitHub:');
    console.log('   git add .');
    console.log('   git commit -m "Ready for deployment"');
    console.log('   git push origin main');
    console.log('\n2. Deploy on Railway:');
    console.log('   - Go to https://railway.app');
    console.log('   - Sign up with GitHub');
    console.log('   - Deploy from GitHub repo');
    console.log('   - Get your public URL!');
    console.log('\n3. Access from anywhere:');
    console.log('   - Use the URL on your Android device');
    console.log('   - Works from any network worldwide');
    console.log('   - Real-time sync across all devices');
} else {
    console.log('\n❌ Some files are missing. Please check the deployment guide.');
}

console.log('\n📖 For detailed instructions, see: FREE_DEPLOYMENT_GUIDE.md');
console.log('🌐 Your app will be accessible from anywhere in the world!');
