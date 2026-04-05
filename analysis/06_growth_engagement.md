# Growth & User Engagement Analiz Raporu
## jira-suite — Claude Code Plugin

---

## Mevcut Durum

### Güçlü Yanlar
- **Marketplace başarılı kurulum**: `.claude-plugin/plugin.json` + komut dosyaları doğru yapıda, Atlassian MCP entegrasyonu kurulu
- **Komut spektrumu geniş**: 9 komut (jira-run, dashboard, decide, admin vb.) özel kullanım durumlarını kapsıyor
- **Teknik belgelendirme yeterli**: Komut dosyaları (`.md`) ayrıntılı trigger, argüman, davranış kuralları içeriyor — yeni kullanıcılar bunu okursa öğrenebilir
- **Kritik özellikleri var**: Döngü (jira-run), karar verme (decide), kod pipeline (jira-start-new-task) — Jira+Claude özel iş akışlarını gerçekten destekliyor
- **Athor güvenirliği**: LinkedIn + GitHub, "Multi-Agent OS" bağlantısı kurumsal bağlam sağlıyor

### Puan: **5.5/10**

Marketplace'te keşfedilebilir, kurulabilir, yapısal olarak doğru — ancak **büyüme motorları eksik**, **onboarding zayıf**, **değer açıklaması muğlak**.

---

## Kritik Eksikler (hemen yapılmalı)

| # | Sorun | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| **1** | **README < 50 satır, "quickstart" yok** | Yeni kullanıcı 30s içinde "ne işe yarar" anlamıyor → direkt yükleme olmaz | "Quick start" bölümü: `1) Install → 2) 30s setup → 3) /jira-run result example` | S |
| **2** | **Tek market listing = keşfedilememe** | Marketplace discovery: jira-suite sadece official'da yok (SkyWalker2506 marketplace kendi repo) | Plugin Marketplace'e submit (anthropics/claude-plugins-official) | M |
| **3** | **Keywords/tags eksik** | plugin.json'da category=productivity, 8 keyword — ama "dashboard", "automation", "agile" gibi yüksek trafik kelimeler yok | Keywords genişlet: jira, sprint, agile, dashboard, automation, kanban, team-management, ci-cd | S |
| **4** | **"Why jira-suite?" açıklaması yok** | Rakip plugins: jira-server, jira-connector — neden bu? → README'de 3 cümle ile différenciation | "Value proposition": Jira+Claude'u döngülerde, karar verme + otomatik kod pipeline ile birleştiriyor (tekil) | S |
| **5** | **Setup doc eksik** | MCP + cloudId + JQL setup → 5 adım, ancak README'de sadece "docs/CLAUDE_JIRA.md" yazıyor. Örnek dosya yok | `docs/CLAUDE_JIRA.example.md` + kurulum video (2min) veya GIF | M |
| **6** | **Demo/onboarding döngüsü yok** | Kullanıcı yükler → "/jira-run" → ??(boş cache/MCP hatası) → kafa karışık | Demo klasörü: `.demo/` → demo-project.json + sample-output.json → `/jira-run .demo` test | M |

---

## İyileştirme Önerileri (planlı)

| # | Öneri | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| **7** | **GitHub SEO / Topic tags** | Marketplace search rankingleri + GitHub discovery | github.com repo'da 5-7 topic ekle (jira, claude-code, agent, automation, productivity) + ⭐ badge README'de | S |
| **8** | **"Use cases" dokümantasyon** | 80% kullanıcı "bunu ben nasıl kullansam?" sorusundan vazgeçer | Docs/use-cases.md: (1) Oğlan/kız takımları, (2) On-call rotası, (3) Sprint planlama pipeline | M |
| **9** | **Inline command örnekleri** | Komut dosyalarındaki "argument-hint" yeterli değil; real çıkış örneği yok | Her komut .md'ye örnek output (ANSI renkleri ile terminal screenshot) ekle | M |
| **10** | **First-time user happiness metrik** | "Başarılı kurulum" = MCP ok + first dashboard rendering | Kurulum sonrası telemetri veya başarı mesajı: "Setup basarili! `/dashboard-sync` calistir" | M |
| **11** | **Onboarding video (YouTube/Loom)** | 2 min video: yükle → setup → ilk loop → göster | Loom: "jira-suite with Claude Code in 2 minutes" | L |
| **12** | **Variant plugins (lightweight)** | Şu an 9 komut = karmaşık; bazı kullanıcı sadece "dashboard" istiyor | jira-suite-lite: sadece dashboard + decide (subskill olarak veya separate plugin) | L |
| **13** | **Changelog + Release notes** | Versiyon görünürlüğü yok → kullanıcı güncelleme faydası görmez | `.changelog/` veya RELEASES.md: v1.0.0 → v1.1.0 → v2.0.0 ve ne değişti | S |
| **14** | **Community feedback loop** | Tek yön (plugin) → kullanıcı; geri dönüş mekanizması yok | GitHub Discussions veya plugin issues template + biweekly digest | M |

---

## Kesin Olmalı (industry standard)

| Standart | Durum | Puan |
|----------|-------|------|
| **Plugin.json schema compliance** | ✅ Doğru (name, version, description, author, category, keywords, commands, skills, mcp) | 10/10 |
| **Marketplace.json ready** | ✅ (Jira-suite repo kendisi marketplace) | 9/10 |
| **MCP configuration** | ✅ `.mcp.json` Atlassian endpoint konfigüre | 10/10 |
| **MIT License** | ✅ LICENSE dosyası var | 10/10 |
| **README exists** | ✅ Ama çok kısa (quickstart yok) | 4/10 |
| **Command documentation** | ✅ Her komut .md'de detailed (jira-run 86 satır) | 8/10 |
| **Skill trigger definition** | ✅ SKILL.md triggers + routing kuralları | 8/10 |
| **GitHub repo structure** | ✅ Clean: commands/, skills/, .claude-plugin/, .mcp.json | 9/10 |

---

## Kesin Değişmeli (mevcut sorunlar)

| Problem | Priority | Çözüm |
|---------|----------|-------|
| **README < 50 satır — quickstart yok** | 🔴 **CRITICAL** | Section: "Quick Start" (5-7 satır) ekle |
| **Keywords eksik (8 tane, 20 olabilir)** | 🔴 **CRITICAL** | plugin.json keywords array genişlet |
| **Value proposition + differentiation açık değil** | 🔴 **CRITICAL** | README 1. paragraf: "neden jira-suite?" netleştir |
| **Setup doc (CLAUDE_JIRA.md) örneğsiz** | 🟠 **HIGH** | docs/CLAUDE_JIRA.example.md ekle |
| **Official marketplace'te yok** | 🟠 **HIGH** | anthropics/claude-plugins-official PR açma adımları dokümante et |

---

## Nice-to-Have (diferansiasyon)

| Özellik | Taşıdığı Değer | Efor |
|---------|---|-----|
| Jira project template + setup wizard (jira-admin başlangıcı) | Onboarding hızı 10x↑ | L |
| Slack/Discord webhook (notif entegrasyonu) | Döngü → team bilgi akışı | M |
| Şablon projeler (Scrum, Kanban, custom) | Marketplace showcase + adoption | M |
| Claude Code plugin marketplace directory badge | Trust signal | S |
| Performance benchmark: "100 tasks/min dashboard" | Tech credibility | M |

---

## Keşfedilebilirlik Stratejisi (Growth Roadmap)

### 1. **İçerik optimizasyonu (Hafta 1-2)**

**README expansion:**
```markdown
# jira-suite — Claude Code Plugin

Jira + Claude entegrasyonu: döngüler, karar verme, otomatik kod pipeline.

## Quick Start
1. `/plugin install jira-suite@musabkara-claude-marketplace`
2. Set CLAUDE_JIRA.md (docs/example.md bak)
3. `/jira-run 5 10s` → ilk loop
4. `/dashboard` → sonuçları gör

## Why jira-suite?
- **Döngü automation**: 50 round × 1s interval = sprint 24/7 görünürlük
- **Karar verme pipeline**: WAITING cards → `/decide` → Opus review
- **Kod + review çiftleri**: Sonnet code + Opus review (branch → PR → merge)

## Use Cases
- On-call rotası + IP management
- Sprint planlama + karar verme
- Agile reporting dashboard
```

**Keywords (20 tane):**
jira, sprint, dashboard, agile, scrum, kanban, task-management, automation, claude-code, project-management, team-collaboration, ci-cd, workflow, decision-making, monitoring, loop, board-view, velocity, backlog, developer-tools

**GitHub topics (7 tane):**
jira, claude-code, agile, automation, developer-tools, kanban, team-management

### 2. **Marketplace distribution (Hafta 2-3)**

**Adım A:** anthropics/claude-plugins-official'a submit
- [Plugin submission form](https://clau.de/plugin-directory-submission) → açık form
- Quality checklist:
  - ✅ plugin.json schema
  - ✅ README + quickstart
  - ✅ Install command doğru
  - ✅ MCP dependency açık

**Adım B:** Alternative marketplace listings
- [BuildWithClaude](https://buildwithclaude.com/) browse/submit
- [Claude Code Directory](https://claudemarketplaces.com/)

### 3. **User onboarding (Hafta 3-4)**

**Setup experience improvement:**
- `.demo/` klasörü: test MCP + cache ohne real Jira
- `docs/CLAUDE_JIRA.example.md`: cloudId, JQL examples
- Quick troubleshooting guide: "cache yok?" → "/dashboard-sync" → "MCP down?" → checklist

**First-time success metric:**
```
Success = user önce 60s içinde `/dashboard` 
         tesadüfi bir output görmek
→ cache seed veya demo mode ile guarantee et
```

### 4. **Community & feedback (Aylar 2+)**

- GitHub Discussions: "Share your jira-suite setups"
- Monthly digest: top issues + feature requests
- Showcase: "spotlight project" (weekly)

---

## Adoption Metrikleri (ölçüm yapısı)

### Primary Metrics
| Metrik | Hedef | Current (tahmin) |
|--------|-------|------------------|
| **Install count (marketplace)** | 100+ | ~10-20 |
| **First-time success rate** | 80% (user ≥1 command çalıştırıyor) | ~40% |
| **Churn (30d inactive)** | <20% | ~50% |
| **Feature adoption** | Avg 3+ commands per user | ~1.5 |

### Secondary Metrics
- **README read completion**: Scroll depth analytics (GitHub raw log)
- **Setup time**: CLAUDE_JIRA.md örnek ile <10min
- **First loop time**: MCP check + first jira-run duration
- **Issue report rate**: "MCP down" vs "working" ratio

### Tracking (low-touch)
- GitHub releases changelog (version adoption)
- Marketplace review/rating system (future)
- Opt-in telemetry: `.jira-state/usage.json` — user consent ile

---

## Implementasyon Timeline

```
Hafta 1: README quickstart + keywords (S effort)
Hafta 2: Setup doc + example (M effort)
Hafta 2: Official marketplace submission (M effort - PR review bekle)
Hafta 3: Demo mode / first-time onboarding (M effort)
Hafta 4: GitHub SEO / topics (S effort)
Ay 2:   Onboarding video + use cases (L effort)
Ay 2+:  Community feedback loop (M effort, recurring)
```

---

## Rakip Analiz

**Jira integrations in Claude Code:**
- jira-connector (generic API wrapper)
- jira-server (self-hosted focus)
- jira-suite (ours) — **loop automation + karar verme + code pipeline → unique**

**Diferansiasyon açığı:** README'de "neden değişik?" açıklanmıyor → SEO ve adoption penaltısı.

---

## Referanslar

### Dokümantasyon
- [Create and Distribute Plugin Marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
- [Plugin Discovery Best Practices](https://code.claude.com/docs/en/discover-plugins)
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)

### Growth Strategy
- [14 User Adoption Strategies](https://userpilot.com/blog/user-adoption-strategies/)
- [README SEO Best Practices](https://mattcromwell.com/wordpress-plugin-readme-optimization/)
- [Feature Adoption Metrics](https://mixpanel.com/blog/product-adoption/)
- [Product Engagement & Time to Value](https://whatfix.com/blog/product-adoption-metrics/)

### Plugin Discovery
- [GitHub SEO Guide 2025](https://www.gitdevtool.com/blog/github-seo)
- [ClaudeMarketplaces Directory](https://claudemarketplaces.com/)
- [BuildWithClaude Platform](https://buildwithclaude.com/)

---

## Özet: Eylem Listesi (Yakın-Orta Vadeli)

### 🔴 KRITIK (Hafta 1-2)
1. README: quickstart bölümü ekle (5 satır)
2. plugin.json keywords: 20'ye çıkar
3. Value prop: README 1. paragraf'a "neden jira-suite?" (2-3 cümle)

### 🟠 YÜKSEK (Hafta 3-4)
4. docs/CLAUDE_JIRA.example.md: tam örnek config
5. Official marketplace submission: PR açma rehberi
6. Setup troubleshooting doc: common issues

### 🟡 ORTA (Ay 2)
7. GitHub SEO: 7 topic + "See also" links README'de
8. Command examples: her komut .md'ye terminal output
9. Use cases doc: 3 senaryoyla detaylı walkthrough

### 🟢 NICE-TO-HAVE (Ay 2+)
10. Onboarding video: 2 min Loom/YouTube
11. .demo/ klasörü: sandbox MCP test
12. Community forum: GitHub Discussions setup

---

**Rapor tarihi:** 2026-04-05  
**Analiz kapsamı:** Marketplace discovery, onboarding UX, adoption metrics, growth strategy
