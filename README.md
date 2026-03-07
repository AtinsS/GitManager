# 🚀 Git Repository Manager by AtinsS

**Version:** 1.0  
**Platform:** Windows  
**Language:** Batch Script

A convenient console manager for those tired of typing Git commands manually. Easily manage multiple repositories through a simple menu. **WINDOWS ONLY!**

## 📋 Features

### Main Functions:
- 📁 Repository list management (add, delete, edit)
- 🔄 Bulk update all repositories
- 🌐 Clone new repositories
- 📊 View Git status
- ⬇️ Git pull (update)
- ⬆️ Git push (upload)
- 📝 Commit with message
- ⚡ Quick commit + push with auto-message
- 📜 View history (git log)
- 🌿 Create and switch branches
- 🤖 Scheduled automatic commits

### Additional Features:
- 🎨 Colorful interface
- 💾 Save repository list to config file
- 🔍 Git installation check
- 🛡️ Error handling and warnings
- 👅 Bilingual system auto-detects language at startup

## 📦 Requirements

- Windows 10/11 (with ANSI color support)
- Git for Windows ([download](https://git-scm.com/download/win))
- Windows Terminal (recommended) or any modern terminal

## 🔧 Installation & Usage

1. **Git is required**
2. Download and run
```batch
GIT-MANAGER.BAT
```

### Main Menu:
```
╔══════════════════════════════════════════════════════════╗
║                GIT REPOSITORY MANAGER                    ║
╚══════════════════════════════════════════════════════════╝

Saved Repositories:
------------------------
1. my-project - C:\Projects\my-project (will be empty until repo is created)
2. work-repo - D:\Work\repository

Actions:
========
Enter repository number (1-2)
C. Clone new repository
A. Add existing local repository
U. Update all repositories
D. Delete repository from list
S. Settings
X. Exit
```

### Repository Menu:
```
════════════════════════════════════════════════════════════
      Repository: my-project
      Path: C:\Projects\my-project
════════════════════════════════════════════════════════════

1. Git status (check state)
2. Git pull (update)
3. Git add + commit (with message)
4. Git push (upload)
5. Quick commit + push (auto-message)
6. View history (git log)
7. Create branch
8. Switch branch
9. Auto-commits (every N minutes)
0. Back to main menu
```

## 📁 File Structure

### `git-manager.bat`
Main manager file with interface and logic

### `git_repos.cfg`
Configuration file with repository list in format:
```
repository_name;full_path_to_repository
```

### `git-scripts/` folder
Contains individual scripts for each Git operation:

| File | Description |
|------|-------------|
| `01-git-status.bat` | Shows repository status |
| `02-git-pull.bat` | Updates repository |
| `03-git-commit.bat` | Creates commit with custom message |
| `04-git-push.bat` | Pushes changes |
| `05-git-quick-push.bat` | Quick commit with auto-message + push |
| `06-git-log.bat` | Shows commit history |
| `07-git-create-branch.bat` | Creates new branch |
| `08-git-switch-branch.bat` | Switches branches |
| `09-git-auto-commit.bat` | Scheduled automatic commits |

## 💡 Usage Examples

### Adding a New Repository:
1. Select `C` to clone or `A` to add existing
2. Enter repository name
3. Specify URL (for cloning) or path (for existing)
4. Repository appears in the list

### Quick Commit + Push:
1. Select repository from list
2. Press `5`
3. Changes are automatically committed with message "Quick update YYYY-MM-DD HH:MM" and pushed

### Automatic Commits:
1. Select repository
2. Press `9`
3. Specify interval in minutes
4. Script will automatically commit changes every N minutes

## ⚠️ Common Issues & Solutions

### Colors Not Working:
- Use Windows Terminal instead of standard console
- Or enable ANSI support in registry

### Git Not Found:
- Install Git for Windows
- Add Git to PATH environment variable

### "Folder not found" Error:
- Check path in config file
- Use "Specify new path" option

## 📝 License

Free to use, modify, and distribute

---

# **Happy coding!** 🤗