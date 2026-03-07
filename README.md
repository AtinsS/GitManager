# 🚀 Git Repository Manager by AtinsS

**Version:** 1.1  
**Platform:** Windows  
**Language:** Batch Script

A convenient console manager for those tired of typing Git commands manually.  
Easily manage multiple repositories through a simple menu. **WINDOWS ONLY!**

## 📋 Features

### Main Functions:
- 📁 Repository list management
    - Adding, Deleting, Group distribution
- 🔄 Mass update of all repositories
- 🌐 Clone new repositories
- 📊 View Git status
- ⬇️ Git pull
- ⬆️ Git push
- 📝 Commit with comment
- ⚡ Quick commit + push with auto-comment
- 📜 View history (git log)
- 🌿 Create and switch branches
- 🤖 Automatic scheduled commits

### Additional Features:
- 💾 Save repository list to config file
- 🔍 Git availability check
- 🛡️ Error and warning handling
- 👅 Bilingual system - automatically detects language on startup

## 📦 Requirements

- Windows 10/11 (with ANSI color support)
- Git for Windows ([download](https://git-scm.com/download/win))
- Windows Terminal (recommended) or any modern terminal

## 🔧 Installation and Usage

1. **You need Git**
2. Download the archive and run
```batch
GIT-MANAGER.BAT
```

### Main Menu:
```
╔══════════════════════════════════════════════════════════╗
║              GIT REPOSITORY MANAGER                      ║
╚══════════════════════════════════════════════════════════╝
=====================By AtinsS==============================

Saved Repositories:
------------------------

[Group: newGroup]
 1. NewRepo - D:\Dev\MyProgects\MyProj NameRepo
 2. NewRepo2 - D:\Dev\MyProgects2\MyProj2 NameRepo2
    
[Group: newGroupSecond]
 1. NewRepoSec - D:\Dev\MyProgectsSec\MyProjSec NameRepo
 2. NewRepoSec2 - D:\Dev\MyProgectsSec2\MyProjSec2 NameRepoSec2

Actions:
========
Enter repository number (1-1)
C. Clone new repository
A. Add existing local repository
U. Update all repositories
G. Manage groups
D. Delete repository from list
S. Settings
X. Exit

Your choice:
```

### Repository Menu:
```
════════════════════════════════════════════════════════════
      Repository: NewRepo
      Path: D:\Dev\MyProgects\MyProj NameRepo
      Branch: main  Status: changes detected
════════════════════════════════════════════════════════════

1. Git status (check state)
2. Git pull (update)
3. Git add + commit (with comment)
4. Git push (send)
5. Quick commit + push (auto-comment)
6. View history (git log)
7. Create branch
8. Switch branch
9. Auto-commits (every N minutes)
10. Return to main menu

Select action:
```

___

## ⚠️ Possible Issues and Solutions

### Colors not working:
- Use Windows Terminal instead of standard console
- Or enable ANSI support in registry

### Git not found:
- Install Git for Windows
- Add Git to PATH variable

### Error "Folder not found":
- Check path in config file
- Use "Specify new path" option

___

## 📝 License

Free use, modification and distribution

---

# **Happy coding!** 🤗