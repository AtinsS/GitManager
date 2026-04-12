# 🚀 Git Manager

> A simple tool for managing multiple Git repositories without unnecessary commands

**Platform:** Windows  
**Language:** Batch Script

---

[Russian REDME](https://github.com/AtinsS/GitManager/blob/main/README.ru.md)
## 💭 Why did I build this?
I have multiple repositories and got tired of typing the same Git commands over and over:
```
git add .
git commit -m "fix"
git push origin main
```

I wanted something simple: open it, pick an action, and it just works.
That's how **🚀 Git Manager** was born.

---
### 🧑‍💻 This is for you if:

- 📦 you juggle multiple repositories  
- 😵 you're sick of typing the same Git commands  
- ⚡ you want to commit + push in one click  
- 🔘 you need to quickly update all your projects  

---
## 🧰 Features

- 📁 Manage multiple repositories
- 📦 Organize projects into groups
- ⬆️ Commit + Push in one action
- ⬇️ Mass-update all repositories with a single button
- 📊 Repository status right in the menu
- 🌿 Branch management
- 🔄 Clone / Pull / Push without CLI
- 📜 View commit history (git log)
- 🤖 Auto-commits on timer
- 🌐 Multi-language support with auto-detection at launch (RU / EN)

---

## ⚙️ Quick Start

1. Install [Git](https://git-scm.com/)
    
2. Download the project or clone the repository
    
3. Run: `GIT-MANAGER.BAT`

4. Enjoy 🚀

---

## 🖥️ Interface

### Main Menu

```batch
════════════════════════════════════════════════════════════
                        GIT MANAGER  🚀
                         by AtinsS
════════════════════════════════════════════════════════════

▸ No repositories added

════════════════════════════════════════════════════════════
▸ ACTIONS
    [C] Clone         [A] Add         [U] Update all
    [G] Groups        [D] Delete      [S] Settings
    [X] Exit
════════════════════════════════════════════════════════════

  →

```

---

### Working with Repositories

```batch
════════════════════════════════════════════════════════════
                        GIT MANAGER  🚀
                         by AtinsS
════════════════════════════════════════════════════════════

▸ Group: Group1
  1. Repo1  [dev] ● clean

▸ Group: Group2
  2. Repo2  [main] ● changes
  3. Repo3  [main] ● clean

════════════════════════════════════════════════════════════
▸ ACTIONS
    [C] Clone         [A] Add         [U] Update all
    [G] Groups        [D] Delete      [S] Settings
    [X] Exit
════════════════════════════════════════════════════════════

  →

```

---

### Repository Actions Menu

```batch
  ════════════════════════════════════════════════════════════
  Repository: Repo1  Branch: dev
  Status: ✅ clean
  ════════════════════════════════════════════════════════════

  1. Git status (check current state)
  2. Git pull (fetch updates)
  3. Git add + commit + push (with message)
  4. Open undo/rollback menu
  5. View history (git log)
  6. Git merge (merge branches)
  7. Git merge --abort (cancel merge)
  8. Show available branches for merge
  9. Create new branch
  10. Switch branch
  11. Auto-commits (every N minutes)
  12. Back to main menu

 →
```

---

### ❓ Why Batch Script?
- no installation required
- works out of the box
- lightweight and fast

___
## ☕ Support the Developer

If **Git Manager** saved you time or turned out to be useful, 
and you'd like to support my work:

- ⭐ Star the repository
- ☕ [Buy me a coffee](https://pay.cloudtips.ru/p/cbaa3c81) 

Any support = more motivation to keep building and improving projects.
