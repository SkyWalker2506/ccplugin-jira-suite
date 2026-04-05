# Architecture & Code Quality Analiz Raporu
> ccplugin-jira-suite v1.5.0 | Tarih: 2026-04-05

---

## Mevcut Durum

Plugin, 14 komut (commands/*.md), 10 script (scripts/), 1 SKILL.md router, shared state (.jira-state/) ve zero-token dashboard cache (.jira_cache.json) ile CLI/terminal bazli bir Jira yonetim araci. Komutlar Markdown tabanli "prompt-as-code" yaklasimi ile tanimlanmis — Claude Code'un native command formatini kullaniyor. Script'ler Bash (8) ve Python (2) karisimi. Multi-agent lock sistemi, exponential backoff retry, log rotation, dynamic transition lookup ve column templates mevcut.

**Mimari stili:** Prompt-driven architecture — komutlar executable kod degil, LLM'in runtime'da yorumladigi deklaratif talimatlar. Script'ler sadece yardimci (dashboard render, retry, prereq check vb.).

---

## Mimari Guclu Yanlar

1. **Prompt-as-Code tutarliligi:** 14 komut ayni frontmatter yapisi (name, description, allowed-tools, argument-hint) ile standart. Plugin.json ile commands/skills dogru eslesmis.

2. **Dynamic transition lookup:** Hicbir yerde hardcoded transition ID yok. Her komut `getTransitionsForJiraIssue` kullanarak gercek Jira workflow'una uyum sagliyor — farkli Jira projelerinde bozulmaz.

3. **Zero-token dashboard:** `.jira_cache.json` ile API cagirisi yapmadan board gorunumu saglayan akilli bir optimizasyon. Dashboard.py tamamen offline calisir.

4. **Status map centralization (status_map.py):** Tek bir yerde tanimlanan STATUS_MAP, REVERSE_MAP, SECTION_ORDER. Dashboard.py bunu import ediyor.

5. **Multi-agent lock sistemi:** File-level (.jira-state/file-locks/) ve task-level (.jira-state/working-*.lock) iki katmanli lock yapisi. TTL, stale detection, trap cleanup mevcut. Dokumanlar (LOCK_SYSTEM.md, STATE_SCHEMA.md) acik.

6. **Shared script library:** colors.sh, prereq-check.sh, retry.sh, log-rotate.sh, audit-log.sh — source edilerek kullanilan modular yardimcilar.

7. **Column templates:** templates/columns.json ile 8 farkli proje tipi icin hazir board sablonlari.

8. **Guvenlik bilincliligi:** Header-based auth (ps aux'ta token gorunmez), chmod 600, input validation (regex), secrets izolasyonu.

9. **Dry-run modu:** jira-run'da `--dry-run` flag'i ile risk-free test imkani.

10. **Multi-project switch:** jira-switch ile CLAUDE_JIRA.{KEY}.md pattern'i uzerinden proje gecisi.

---

## Kritik Eksikler (hemen yapilmali)

| # | Sorun | Etki | Cozum | Efor |
|---|-------|------|-------|------|
| 1 | **status_map.py ile commands/*.md arasinda status mapping tekrari** — dashboard-sync.md satirlari 62-68'de ayni mapping tekrar yazilmis, status_map.py'deki SOURCE_OF_TRUTH ile senkron kaybedebilir | High | dashboard-sync.md'deki hardcoded mapping'i kaldir, "Use `scripts/status_map.py` for mapping" referansi birak | S |
| 2 | **columns.json'da Review/Testing status'lari status_map.py'de tanimsiz** — columns.json'da "Review", "Testing", "Released", "Beta", "Model Training", "Staging", "Deploying" var ama STATUS_MAP bunlari tanimiyor. Fallback (`lower().replace(" ","_")`) calisiyor ama dashboard'da bu kolonlar goruntulenemez | High | status_map.py'ye tum column template status'larini ekle veya dynamic mapping yap | S |
| 3 | **prereq-check.sh `grep -oP` kullanir — macOS'ta calismaz** (`scripts/prereq-check.sh:28`: `grep -oP '(?<=\*\*Key:\*\* )\S+'`). macOS default grep PCRE desteklemiyor | High | `grep -oE` ile yeniden yaz veya `sed`/`awk` kullan. Alternatif: `python3 -c` one-liner | S |
| 4 | **jira-switch.md'de de `grep -oP` kullanilmis** (`commands/jira-switch.md` satir ~40) — ayni macOS uyumsuzlugu | High | Ayni fix | S |
| 5 | **run_task_agent.sh bir stub** — "This script is a launcher stub" diyor, gercek implementasyon yok. Pipeline tamamen LLM prompt'a bagimli, script hicbir is yapmiyor | Med | Ya script'i gercek bir launcher yap (claude CLI cagirisi, log redirect) ya da kaldir ve komut icinde inline tanimla | M |
| 6 | **sprint-detect.sh sadece JQL string donduruyor** — `detect_sprint()` fonksiyonu bir JQL yazdiriyor ama MCP cagirisi yapmiyor, sprint bilgisini parse etmiyor. Islevi tamamen eksik | Med | Ya gercek sprint detection implement et ya da script'i kaldir (zaten dashboard-sync.md icinde bu islem MCP ile yapiliyor) | S |
| 7 | **Hata yonetimi tutarsiz** — retry.sh mevcut ama komutlarin cogu retry stratejisi tanimlamiyor. Sadece jira-run.md error recovery tanimlamis | Med | Her komutta hata durumu ve retry/fallback tanimla | M |

---

## Iyilestirme Onerileri (planli)

| # | Oneri | Etki | Cozum | Efor |
|---|-------|------|-------|------|
| 1 | **Komut basina test/validation yok** — 14 komutun hicbirinin otomatik testi yok. Prompt degisince regresyon farkedilmez | High | Her komut icin smoke test: expected input -> expected MCP call sequence -> expected output. Bash ile basit assertion'lar | L |
| 2 | **Cache versiyonlama zayif** — `.jira_cache.json` version:2 var ama schema validation yok. Eski format ile yeni dashboard.py crash edebilir | Med | dashboard.py'ye JSON schema validation ekle (jsonschema veya manual key check). Version mismatch'te "Run /dashboard-sync" uyarisi zaten var ama graceful degrade yok | S |
| 3 | **Plugin.json version 1.0.0 ama proje v1.5.0** — versiyon uyumsuzlugu. plugin.json marketplace icin kritik | Med | plugin.json version'i proje versiyonu ile senkron tut, CI/release script'inde kontrol et | S |
| 4 | **allowed-tools wildcard kullanimi** — `mcp__atlassian__*` cogu komutta tum Atlassian araclarina erisim veriyor. Least-privilege prensibi ihlali | Low | Her komutu sadece ihtiyaci olan MCP tool'lari ile kisitla (jira-link.md bunu zaten dogru yapiyor) | M |
| 5 | **Log dosyasi formati belirsiz** — jira_loop_log.md'nin icerigi hicbir yerde sema olarak tanimlanmamis. STATE_SCHEMA.md'de eksik | Low | Log format semasini STATE_SCHEMA.md'ye ekle | S |
| 6 | **dashboard.py'de status_map.py import path'i fragile** — `try/except ImportError` ile fallback var ama CWD'ye bagimli. Farkli dizinden calistirilirsa import basarisiz | Med | `sys.path.insert(0, os.path.dirname(__file__))` ekle veya absolute path kullan | S |
| 7 | **audit-log.sh export -f tasinabilirlik** — `export -f` zsh'de calismaz, sadece bash | Low | Fonksiyonu source eden script'in bash oldugunu garanti et veya export -f kullanma | S |
| 8 | **Komut dokumantasyonlarinda Turkce/Ingilizce karisiklik** — Bazi komutlar "kolon ekle" gibi Turkce terimler kullaniyor. Marketplace icin tutarli Ingilizce olmali | Low | Tum commands/*.md'yi Ingilizce standardize et | M |

---

## Kesin Olmali

1. **Prompt-as-Code yaklasimi** — Claude Code plugin ekosistemi icin dogru mimari secim. Komutlar deklaratif, LLM-native.
2. **Dynamic transition lookup** — Jira workflow diversity'si icin zorunlu. Hardcoded ID'ler projeyi kirar.
3. **Zero-token dashboard cache** — Token maliyetini dramatik dusuruyor. Akilli optimizasyon.
4. **Shared state directory (.jira-state/)** — Multi-agent koordinasyonu icin gerekli.
5. **Input validation** — Regex-based key validation her yerde tutarli.
6. **SKILL.md routing** — Dogru intent detection + menu fallback pattern'i.

---

## Kesin Degismeli

1. **`grep -oP` kullanimi** — macOS'ta calismaz. `scripts/prereq-check.sh:28` ve `commands/jira-switch.md` icinde. PCRE yerine POSIX uyumlu regex veya python one-liner kullanilmali.

2. **Stub script'ler (run_task_agent.sh, sprint-detect.sh)** — Ya tamamlanmali ya da kaldirilip komut icinde inline yapilmali. Mevcut haliyle yaniltici.

3. **Status mapping tekrari** — `commands/dashboard-sync.md` icindeki hardcoded mapping, `scripts/status_map.py` ile tutarsizlik riski yaratir. Single source of truth olmali.

4. **Plugin.json version uyumsuzlugu** — `1.0.0` vs proje `v1.5.0`. Marketplace'te yanlis versiyon gosterir.

5. **dashboard.py import path fragility** — CWD bagimli import. Baska dizinden calisinca kirilir.

---

## Nice-to-Have (diferansiasyon)

1. **`/jira-health` komutu** — Tek komutla: MCP baglantisi, token suresi, cache freshness, lock durumu, config validity kontrol. Debugging icin cok degerli.

2. **Webhook/event-driven mode** — Polling yerine Jira webhook'lari ile tetiklenen komutlar. Gercek zamanli board takibi.

3. **Template marketplace** — Column template'lerini community'nin paylasabilecegi bir format. `templates/` dizini zaten altyapiyi sagliyor.

4. **Komut zamanlama** — `/jira-run` icin cron-style scheduling. "Her sabah 09:00'da dashboard-sync calistir" gibi.

5. **Offline-first cache stratejisi** — Cache'in TTL'si yok. "Cache 1 saatten eskiyse uyar" gibi freshness indicator eklenebilir.

6. **Metrics toplama** — Her komut calismasini logla: sure, basari/basarisizlik, API call sayisi. Zaman icinde plugin performansini olc.

7. **Interactive board view** — Terminal'de navigable board (arrow keys ile card secimi, space ile transition). `blessed` veya `textual` (Python TUI) ile mumkun.

---

## Refactor Oncelikleri

### Oncelik 1 — Platform uyumlulugu (1-2 gun)
- `grep -oP` -> POSIX uyumlu alternatiflere gecis (`scripts/prereq-check.sh`, `commands/jira-switch.md`)
- `export -f` -> zsh uyumlu pattern (`scripts/audit-log.sh`, `scripts/token-check.sh`, `scripts/sprint-detect.sh`)
- Test: macOS + Linux'ta her script'i calistir

### Oncelik 2 — DRY & Single Source of Truth (1 gun)
- `commands/dashboard-sync.md`'deki status mapping'i kaldir, `scripts/status_map.py` referansi birak
- `scripts/status_map.py` STATUS_MAP'i `templates/columns.json`'daki tum status'lari kapsayacak sekilde genislet
- `.claude-plugin/plugin.json` version'i proje versiyonu ile esle

### Oncelik 3 — Stub temizligi (1 gun)
- `scripts/run_task_agent.sh`: ya gercek launcher yap ya da kaldir
- `scripts/sprint-detect.sh`: ya MCP entegrasyonu yap ya da kaldir
- Her script'in basina "USAGE" ve "DEPENDS ON" dokumantasyonu ekle

### Oncelik 4 — Error handling standardizasyonu (2 gun)
- Her komuta hata senaryolari ekle
- `scripts/retry.sh` kullanimini yayginlastir
- Graceful degradation: MCP baglantisi kesildiginde cache'ten oku

### Oncelik 5 — Test altyapisi (3-5 gun)
- Asagidaki "Test Stratejisi" bolumune bak

---

## Test Stratejisi

### Katman 1 — Script unit test'leri (oncelikli)
```bash
# test/test_prereq_check.sh
# Mock CLAUDE_JIRA.md, test PROJECT_KEY extraction
# Test invalid key format rejection
# Test missing dependency warning
```
Hedef: `scripts/` altindaki 10 dosyanin her biri icin en az 3 test case.

### Katman 2 — Status map dogruluk testi
```python
# test/test_status_map.py
# columns.json'daki her status, status_map.py'de tanimli mi?
# map_status() case-insensitive fallback dogru calisiyor mu?
# SECTION_ORDER tum dashboard section'larini kapsiyor mu?
```

### Katman 3 — Cache schema validation
```python
# test/test_cache_schema.py
# .jira_cache.json ornegini yukle (.demo/sample_cache.json)
# Zorunlu key'ler var mi? (version, updated, summary, section arrays)
# Version < 2 uyarisi calisiyor mu?
```

### Katman 4 — Komut smoke test'leri
```bash
# test/test_commands_smoke.sh
# Her komutun frontmatter'i gecerli mi? (name, description, allowed-tools)
# allowed-tools listesinde gecersiz tool var mi?
# argument-hint tanimli mi?
# plugin.json'daki commands listesi ile commands/ dizini eslesiyor mu?
```

### Katman 5 — Integration (MCP mock ile)
- Mock MCP server olustur (basit JSON response'lar)
- dashboard-sync -> cache write -> dashboard render pipeline'ini test et
- jira-run single round'u dry-run modunda test et

---

## Referanslar

| Kaynak | Aciklama |
|--------|----------|
| `commands/*.md` | 14 komut tanimlamasi — prompt-as-code |
| `scripts/` | 10 yardimci script (8 Bash, 2 Python) |
| `skills/jira-suite/SKILL.md` | Intent routing ve menu tanimlamasi |
| `.claude-plugin/plugin.json` | Marketplace manifest |
| `templates/columns.json` | 8 board template |
| `docs/LOCK_SYSTEM.md` | Multi-agent lock dokumantasyonu |
| `docs/STATE_SCHEMA.md` | Shared state sema dokumantasyonu |
| `docs/agent-template.md` | Task pipeline agent sablonu |
| [ShellCheck](https://www.shellcheck.net/) | Bash script kalite standartlari |
| [Jira REST API v3](https://developer.atlassian.com/cloud/jira/platform/rest/v3/) | Jira API referansi |
