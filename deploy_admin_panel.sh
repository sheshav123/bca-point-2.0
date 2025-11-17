#!/bin/bash

# BCA Point 2.0 - Admin Panel Deployment Script
# This script deploys your admin panel to GitHub Pages

echo "🚀 BCA Point 2.0 - Admin Panel Deployment"
echo "=========================================="
echo ""

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: GitHub username is required"
    exit 1
fi

# Get repository name
read -p "Enter repository name (default: bca-point-admin): " REPO_NAME
REPO_NAME=${REPO_NAME:-bca-point-admin}

echo ""
echo "📋 Configuration:"
echo "   GitHub Username: $GITHUB_USERNAME"
echo "   Repository Name: $REPO_NAME"
echo "   URL will be: https://$GITHUB_USERNAME.github.io/$REPO_NAME/"
echo ""

read -p "Continue? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "❌ Deployment cancelled"
    exit 0
fi

echo ""
echo "📦 Step 1: Creating deployment directory..."

# Create temp directory
DEPLOY_DIR="$HOME/Desktop/${REPO_NAME}-deploy"
mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR"

echo "✅ Created: $DEPLOY_DIR"

echo ""
echo "📂 Step 2: Copying admin panel files..."

# Copy admin panel files
cp -r "$HOME/fluttersheshav/sdk/2025 projects/Bca_Point/admin_panel/"* .

echo "✅ Files copied"

echo ""
echo "📝 Step 3: Creating .gitignore..."

# Create .gitignore
cat > .gitignore << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Editor
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
EOF

echo "✅ .gitignore created"

echo ""
echo "🔧 Step 4: Initializing git repository..."

# Initialize git
git init
git add .
git commit -m "Initial commit: BCA Point 2.0 Admin Panel"

echo "✅ Git initialized and files committed"

echo ""
echo "🌐 Step 5: Adding GitHub remote..."

# Add remote
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
git branch -M main

echo "✅ Remote added"

echo ""
echo "⚠️  IMPORTANT: Before pushing, make sure you have:"
echo "   1. Created the repository on GitHub: https://github.com/new"
echo "   2. Repository name: $REPO_NAME"
echo "   3. Set as PUBLIC (required for free GitHub Pages)"
echo "   4. DO NOT initialize with README"
echo ""

read -p "Have you created the repository? (y/n): " REPO_CREATED
if [ "$REPO_CREATED" != "y" ]; then
    echo ""
    echo "📌 Next steps:"
    echo "   1. Go to: https://github.com/new"
    echo "   2. Create repository: $REPO_NAME"
    echo "   3. Run this command to push:"
    echo "      cd $DEPLOY_DIR && git push -u origin main"
    echo ""
    echo "   4. Then enable GitHub Pages:"
    echo "      - Go to repository Settings → Pages"
    echo "      - Source: main branch, / (root)"
    echo "      - Save"
    exit 0
fi

echo ""
echo "🚀 Step 6: Pushing to GitHub..."

# Push to GitHub
if git push -u origin main; then
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🎉 Deployment Complete!"
    echo ""
    echo "📌 Final Steps:"
    echo "   1. Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/pages"
    echo "   2. Under 'Source', select:"
    echo "      - Branch: main"
    echo "      - Folder: / (root)"
    echo "   3. Click 'Save'"
    echo "   4. Wait 1-2 minutes"
    echo ""
    echo "🌐 Your admin panel will be live at:"
    echo "   https://$GITHUB_USERNAME.github.io/$REPO_NAME/"
    echo ""
    echo "🔑 Default password: admin123"
    echo "   (Change it in index.html before sharing!)"
    echo ""
else
    echo "❌ Error: Failed to push to GitHub"
    echo ""
    echo "Possible reasons:"
    echo "   1. Repository doesn't exist on GitHub"
    echo "   2. You don't have push access"
    echo "   3. Authentication failed"
    echo ""
    echo "📌 Manual push:"
    echo "   cd $DEPLOY_DIR"
    echo "   git push -u origin main"
    exit 1
fi
