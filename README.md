# 🚀 Git Repository Manager by AtinsS

**Version:** 1.1.1
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
🚀 GIT MANAGER - Repository Management
═══════════════════ By AtinsS ═══════════════════

    Repository list:

    📁 Group:JS
    1.  JS-Learn
    2.  JS-FINAL
    3.  Crop-IMG

    📁 Group: OTHER
    4.  GIT-MANAGER

    📁 Group: Vault
    5.  Vault

    Action menu:
    1-5: Select repository by number
    C: Clone new repository
    A: Add existing local repository
    U: Update all repositories
    G: Manage groups
    D: Delete repository from list
    S: Settings
    X: Exit

    ⚡ Your choice:
```

### Repository Menu:
```
 ════════════════════════════════════════════════════════════
    Repository: JS-Learn    Branch: dev
    Status: ✅ clean
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
    0. Return to main menu

    ⚡ Choose action:

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
