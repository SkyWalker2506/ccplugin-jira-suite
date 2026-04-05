# Architecture & Code Quality Analiz Raporu

**Tarih:** 2026-04-05
**Proje:** ccplugin-jira-suite
**Analist:** Claude Opus 4.6

---

### Mevcut Durum

**Guclu yanlar:**

- **Temiz plugin.json yapisi:** Frontmatter metadata, commands/skills ayri dizinlerde, MCP referansi dogru.
- **Tutarli command formatlamasi:** Her `.md` dosyasi ayni YAML frontmatter sablonunu kullaniyor (name, description, allowed-tools, argument-hint). Bu Claude Code plugin standardina uygun.
- **SKILL.md routing tablosu:** Intent -> command eslestirmesi net, trigger kelimeleri kapsamli. Routing skill olarak iyi tasarlanmis.
- **Guclu domain modeli:** Loop sistemi (jira-run), cancellation (stop file), file locks (collision prevention), dashboard cache pattern — bunlar production-grade tasarim kararlari.
- **Modular command ayrimi:** 9 command birbirinden bagimsiz, her biri tek sorumluluk tasiyor. `jira-run-fast` delegasyonu (`/jira-run N 1s`'e yonlendirme) DRY prensibini uyguluyor.
- **Guvenlik:** Secrets `~/.claude/secrets/` altinda, plugin icinde hardcode yok. `allowed-tools` her command icin minimize edilmis (dashboard sadece Bash, decide MCP+Read).
- **MCP entegrasyonu:** Atlassian MCP tek bagimlilik, `.mcp.json` ile declare edilmis.

**Puan: 7/10**

Fonksiyonel olarak zengin, tutarli ve iyi organize. Ancak test yok, scripts/ klasoru eksik (dashboard.py referansi var ama dosya yok), ve bazi mimari iyilestirmeler gerekli.

---

### Kritik Eksikler (hemen yapilmali)

| # | Sorun | Etki | Cozum | Efor |
|---|-------|------|-------|------|
| 1 | `scripts/dashboard.py` referansi var ama dosya repoda yok | High | dashboard ve dashboard-sync komutlari calismiyor. `scripts/dashboard.py` olustur veya inline bash cozumu yaz | S |
| 2 | `scripts/run_task_agent.sh` referansi var (jira-start-new-task) ama dosya yok | High | Multi-agent pipeline calismiyor. Script'i olustur veya command icinde inline tanimla | M |
| 3 | `docs/CLAUDE_JIRA.md` dependency — her projede olmali ama plugin bunu enforce etmiyor | High | Plugin ilk calistiginda `docs/CLAUDE_JIRA.md` yoksa template olusturan bir `setup` / `init` komutu ekle | S |
| 4 | Hardcoded Jira transition ID'leri (11, 21, 31, 51) — her Jira instance'da farkli olabilir | High | `getTransitionsForJiraIssue` ile dinamik resolve et (decide.md'de fallback var ama diger komutlarda yok) | M |
| 5 | `docs/agent-template.md` ve `docs/LOCK_SYSTEM.md` referanslari var ama dosyalar yok | Med | Ya dosyalari olustur ya da referanslari ilgili command icine inline tasi | S |

---

### Iyilestirme Onerileri (planli)

| # | Oneri | Etki | Cozum | Efor |
|---|-------|------|-------|------|
| 1 | Error handling standardizasyonu | High | Her command icin MCP baglanti kontrolu, `docs/CLAUDE_JIRA.md` varlik kontrolu, secrets kontrolu — bunlari ortak bir "prereq check" sablonuna cek | M |
| 2 | Shared state yonetimi | Med | `.jira-state/` dizini birden fazla command tarafindan kullaniliyor (locks, stop file, cache). Bir `jira-state-schema.md` ile state dosyalarini ve formatlarini dokumante et | S |
| 3 | Column template'leri veri dosyasina tasi | Med | `jira-admin.md` icinde inline olan template'ler `templates/columns.json` gibi bir yapiya tasinabilir — boylece programatik erisim ve genisletme kolaylasir | S |
| 4 | Dashboard cache format versiyonlama | Med | `.jira_cache.json`'a `"version": 1` field'i ekle — ileride format degistiginde eski cache'i temiz handle et | S |
| 5 | Status mapping merkezilestirme | Med | "WAITING FOR APPROVAL", "In Progress" gibi status string'leri birden fazla command'da tekrarlaniyor. Tek bir referans noktasi olustur (SKILL.md veya ayri config) | M |
| 6 | jira-admin.md cok buyuk (189 satir) | Low | 4 alt-operasyonu ayri command'lara bol (`jira-admin-create-project.md`, vb.) veya mevcut haliyle birak ama ic routing'i netlestir | M |

---

### Kesin Olmali (industry standard)

1. **Referans edilen script'ler repoda olmali.** `scripts/dashboard.py` ve `scripts/run_task_agent.sh` ya repoya eklenmeli ya da command'lar self-contained olmali. Broken reference = broken plugin.

2. **Init/setup komutu.** Plugin kuruldugunda `docs/CLAUDE_JIRA.md` template'i olusturan, MCP baglantisinini dogruyan, secrets varligini kontrol eden bir `jira-init` veya `jira-setup` komutu sart.

3. **Dinamik transition ID'leri.** Hardcoded transition ID'ler sadece belirli Jira workflow'larinda calisiyor. `getTransitionsForJiraIssue` her yerde kullanilmali.

4. **README'de prerequisites net olmali.** `docs/CLAUDE_JIRA.md` formati, gerekli secrets, MCP kurulumu — bunlar adim adim dokumante edilmeli.

---

### Kesin Degismeli (mevcut sorunlar)

1. **Eksik dosya referanslari** — `scripts/dashboard.py`, `scripts/run_task_agent.sh`, `docs/agent-template.md`, `docs/LOCK_SYSTEM.md` repoda yok. Bu plugin'i klonlayan biri 4 komutun calismadigini gorecek.

2. **jira-admin.md `allowed-tools`'da MCP yok** — `["Bash", "Read", "Write", "Edit"]` tanimli ama Jira REST API'yi curl ile cagiriyor. Bu tasarim karari kabul edilebilir (MCP'nin desteklemedigi endpoint'ler icin) ama `mcp__atlassian__*` da eklenebilir — ozellikle `setup-columns`'da mevcut column'lari MCP ile okumak daha guvenilir.

3. **jira-run-fast.md tekrari** — Neredeyse tamamen `/jira-run N 1s`'e delegasyon. Ayri command yerine jira-run.md icinde "fast mode" alias olarak tanimlanabilir — ayri dosya maintenance yuku olusturuyor.

4. **`jira-cancel` sadece jira-run'i durduruyor** — `jira-start-new-task` multi-agent pipeline'ini durduracak bir mekanizma yok. `working-*.lock` dosyalarini temizlemek yeterli degil, calisan sub-agent'lari kill etmek gerekir.

---

### Nice-to-Have (diferansiasyon)

1. **Dry-run modu:** `jira-run-detailed --dry-run` — degisiklikleri uygulamadan once raporla. Kullanici onaylasin.

2. **Webhook entegrasyonu:** Jira webhook -> Claude Code notification. Polling yerine event-driven mimari.

3. **Dashboard TUI:** `scripts/dashboard.py`'yi `rich` veya `textual` ile zenginlestir — renk, progress bar, sparkline.

4. **Metric tracking:** Her jira-run calismasinin istatistikleri (kac kart islendi, kac transition yapildi) `.jira-state/metrics.jsonl`'e yazilsin. Zaman icinde trend analizi.

5. **Multi-project destek:** Tek bir jira-run ile birden fazla projeyi tarayabilme. `docs/CLAUDE_JIRA.md` yerine `docs/jira-projects/*.md` pattern'i.

6. **Plugin test framework'u:** Command'larin mock MCP ile test edilebilecegi bir framework. Ornegin `tests/test_decide.sh` — mock JQL response ile decide flow'unu dogrula.

---

### Referanslar

- **Claude Code Plugin Spec:** `.claude-plugin/plugin.json` + commands/*.md + skills/*/SKILL.md yapisi
- **Atlassian MCP:** `mcp-remote` ile cloud-hosted MCP server baglantisi
- **Jira REST API v3:** `jira-admin.md`'deki curl operasyonlari
- **Jira Agile REST API 1.0:** Board/column yonetimi
- **File-based IPC:** `.jira-state/` dizini uzerinden stop file, working lock, file lock pattern'leri — lightweight, dependency-free
