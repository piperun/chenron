# Theme System Scalability Roadmap

## Current Approach (Phase 1)

**What we're using now:**

- **Static registration** - All themes registered at app startup
- **In-memory registry** - Themes stored in a Map
- **Always-on validation** - Validates during development
- **Bundled themes** - 5-10 developer-created themes compiled into app

**Best for:** Initial implementation, trusted themes only

**Scalability limit:** 10-20 themes before startup time becomes noticeable

---

## Near Future (Phase 2) - **Recommended Next Step**

**What we should use:**

- **Lazy registration** - Themes loaded on first access, not at startup
- **Metadata-only loading** - Only theme names/descriptions loaded initially
- **On-demand instantiation** - Full theme built when user selects it
- **Still bundled** - All themes are trusted Dart code

**Benefits:**
- Fast startup (<5ms for 100+ themes)
- Memory efficient (only active themes in memory)
- Still type-safe (all Dart code)
- No security concerns (trusted code only)

**Best for:** 20-200 built-in themes

**When to implement:** When you have 15-20+ themes

---

## Distant Future (Phase 3) - **User-Generated Themes**

**What we'll eventually need:**

- **Database storage** for user-created themes
- **Hybrid approach**: Built-in themes (Dart code) + User themes (database)
- **Sandboxed generation**: User themes restricted to seed-based color generation only
- **TOML import/export** for portability and sharing

**Why database over files (JSON/TOML)?**

| Concern | File-Based (JSON/TOML) | Database |
|---------|------------------------|----------|
| **Collision prevention** | ❌ Manual filename checking | ✅ UNIQUE constraints enforce |
| **Type safety** | ⚠️ Must parse and validate | ✅ Schema enforces types |
| **Malicious data** | ❌ Can inject bad values | ✅ CHECK constraints prevent |
| **Validation** | ⚠️ Manual (easy to forget) | ✅ Automatic via schema |
| **Portability** | ✅ Easy to share files | ✅ Export to TOML |
| **Security** | ⚠️ File system access | ✅ Sandboxed queries |

**Architecture:**
```
Built-in themes (Dart code, trusted)
    ↓
  Lazy Registry
    ↓
  Theme Engine
    ↓
  Database (user themes, validated)
    ↓
  TOML Export (for sharing)
```

**Key principle:** 
- Database = storage (secure, validated)
- TOML = transport (portable, shareable)
- Never load themes directly from files into app

**Best for:** Unlimited user-generated themes with public marketplace

**When to implement:** When users request theme creation feature

---

## Summary

| Phase | Themes | When | Storage | Security |
|-------|--------|------|---------|----------|
| **Phase 1** (now) | 10-20 | Initial release | In-memory | Trusted code |
| **Phase 2** (near) | 100-200 | 15+ themes | Lazy-loaded | Trusted code |
| **Phase 3** (distant) | Unlimited | User creation | Database + Dart | Sandboxed |

**The path forward:** Start simple (Phase 1), add lazy loading when needed (Phase 2), add database when users want to create themes (Phase 3).
