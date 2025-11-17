# Quick Admin Panel Guide

## 🔑 Login
- Open `admin_panel/index.html`
- Password: `admin123`
- Change password in `app.js` → `ADMIN_PASSWORD`

## 📁 Creating Content

### Categories (Top Level)
1. Go to **Categories** tab
2. Enter title, description, order
3. Click "Add Category"

### Subcategories (Any Level)
1. Go to **Subcategories** tab
2. Select parent:
   - 📁 Category (for first level)
   - 📂 Subcategory (for nested levels)
3. Enter title, description, order
4. Click "Add Subcategory"

### Study Materials
1. Go to **Study Materials** tab
2. Select subcategory (any level)
3. Enter title, description, order
4. Choose PDF file
5. Click "Upload Material"

## ✏️ Editing
- Click blue **Edit** button next to any item
- Update title, description, or order
- Changes save automatically

## 🗑️ Deleting
- Click red **Delete** button
- Confirm deletion
- Note: Deleting a category/subcategory removes all nested content

## 🌳 Example Structure
```
📁 Computer Science (Category)
  📂 Programming (Subcategory)
    📂 Python (Sub-subcategory)
      📂 Advanced Topics (Sub-sub-subcategory)
        📄 Python OOP.pdf
        📄 Python Decorators.pdf
      📄 Python Basics.pdf
    📂 Java (Sub-subcategory)
      📄 Java Fundamentals.pdf
  📂 Data Structures (Subcategory)
    📄 Arrays and Lists.pdf
```

## 💡 Tips
- Use **order** numbers to control sorting (0, 1, 2, 3...)
- Lower numbers appear first
- Descriptions are optional but helpful
- You can nest as deep as you want!

## 🔒 Security
- Keep your password secure
- Don't share the admin panel URL publicly
- Update Firebase rules for production use
