# Security & Infrastructure Analiz Raporu
> ccplugin-jira-suite v1.5.0 | Tarih: 2026-04-05

**Kapsam:** Token yönetimi, secret güvenliği, MCP konfigürasyonu, input validation, bash injection, dependency güvenliği, lock sistemi, log yönetimi.

---

## Mevcut Durum

### Sprint 1 Sonrası Güçlü Yanlar

- **Secret izolasyonu:** API token, email ve URL bilgileri repo içinde yok. `~/.claude/secrets/secrets.env` dosyasına yönlendirilmiş, `chmod 600` `setup-token` akışına eklenmiş.
- **Header-based auth:** `jira-admin.md` `curl -u` yerine `Authorization: Basic $(... | base64)` header yöntemi kullanıyor — token `ps aux`'ta görünmüyor.
- **Input validation regex:** `validate_project_key()` ve `validate_issue_key()` fonksiyonları `jira-admin.md`'ye eklenmiş; `run_task_agent.sh`'de de aynı regex doğrulaması var.
- **mcp-remote sabit versiyon:** `.mcp.json`'da `mcp-remote@0.1.38` pin'lenmiş — supply chain riski giderildi.
- **`.gitignore` güncellenmiş:** `.jira_cache.json`, `.jira-state/`, `tmp/` dışarıda bırakılmış.
- **Transport şifreli:** MCP bağlantısı `https://mcp.atlassian.com/v1/mcp` üzerinden — plain HTTP yok.
- **`allowed-tools` kısıtlaması:** Komutlar frontmatter'da araç kapsamını sınırlıyor.
- **Lock sistemi:** TTL-tabanlı file lock + working lock + `trap cleanup EXIT INT TERM` — multi-agent çakışması önleniyor.
- **Token yaşı kontrolü:** `token-check.sh` 335 günde uyarı, 365 günde hata veriyor.
- **Log rotasyonu:** `log-rotate.sh` 500 satır limiti uygulayabiliyor.

### Kalan Riskler

- `retry.sh` içindeki `eval "$cmd"` — arbitrary code execution vektörü.
- Column adı JSON injection koruması eksik.
- `sprint-detect.sh` stub durumunda — JQL injection koruması henüz gerçek implementasyonda test edilmedi.
- `secrets.env` izinleri setup akışında garanti altına alınıyor ancak mevcut kurulumlar kontrol edilmiyor.
- `eval` kullanımı `retry_cmd`'de içe aktarılan komutların güvenilirliğine dayanıyor.

### Puan: **6.5/10**

Sprint 1 fix'leri beş kritik açığı kapattı. Puanı 5.5'ten 6.5'e taşıdı. Kalan riskler `eval` injection, column name sanitization ve MCP scope kontrolü başlıklarında yoğunlaşıyor.

---

## Kritik Eksikler (hemen yapılmalı)

| # | Sorun | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **`retry.sh`'de `eval "$cmd"` kullanımı** | High | `retry_cmd` fonksiyonu string olarak gelen komutu `eval` ile çalıştırıyor. Çağıran kod kötü hazırlanmış bir string geçirirse arbitrary command execution olur. `eval` kaldırılmalı; komut dizi olarak alınmalı: `retry_cmd 3 curl -s -H ...` → `"$@"` ile çalıştır. | S |
| 2 | **Column adı JSON'a doğrudan interpolate ediliyor** | High | `jira-admin.md`'de `'"$COL"'` ile JSON string oluşturuluyor. `COL` değeri `", "name": "injected` içerirse JSON yapısı bozulur / başka field enjekte edilir. `python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$COL"` ile escape zorunlu. | S |
| 3 | **`secrets.env` mevcut kurulumların izni doğrulanmıyor** | Med | `setup-token` yeni kurulumda `chmod 600` uyguluyor ancak önceden kurulmuş sistemlerde bu garantisi yok. `prereq-check.sh` başlangıcında `stat -c %a ~/.claude/secrets/secrets.env` ile izin kontrolü ekle; 600 değilse uyar. | S |
| 4 | **`sprint-detect.sh` stub — injection güvenli implementasyon eksik** | Med | `detect_sprint` fonksiyonu JQL string üretiyor ama gerçek MCP çağrısı yapmıyor; tam implementasyon yazıldığında `project_key` değişkeninin JQL injection'a karşı korunması gözden kaçabilir. Implementasyon öncesi `[A-Z][A-Z0-9]{1,9}` doğrulaması zorunlu kılınmalı. | S |

---

## İyileştirme Önerileri (planlı)

| # | Öneri | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 5 | **`mcp-remote` versiyonu otomatik yükseltme mekanizması yok** | Med | `@0.1.38` pin doğru ama güvenlik yamasını almak için manuel güncelleme gerekiyor. `scripts/prereq-check.sh`'e `npx mcp-remote@0.1.38 --version` ile versiyon kontrolü + güncel versiyon uyarısı ekle. | M |
| 6 | **Token yaşı proxy tabanlı — gerçek expiration tarihi bilinmiyor** | Med | `token-check.sh` dosya mtime'ını kullanıyor; token yenilendiğinde dosya değişse bile mtime güncellenmeyebilir. Atlassian API `/rest/api/3/myself` çağrısına token metadata sorgusu ekle (mevcut API destekliyorsa). | M |
| 7 | **HTTP 429 (rate limit) yakalanmıyor** | Med | `setup-columns` döngüsünde birden fazla column create isteği gönderiliyor; Jira API rate limit'e çarpıldığında sessizce başarısız oluyor. `curl` çıktısında 429 kontrolü + `sleep 2` retry ekle. | S |
| 8 | **MCP scope minimizasyonu yapılmamış** | Low | `.mcp.json` Atlassian MCP'ye tam erişim veriyor; Confluence scope'ları bu plugin için gereksiz. Atlassian OAuth scope'ları minimize edilmeli (yalnızca `read:jira-work write:jira-work`). | M |
| 9 | **Audit log yalnızca `jira-admin` için var** | Low | `docs/audit_log.md` admin operasyonlarını kaydediyor ama `jira-run` transition'larını kaydetmiyor. Otomatik transition ve durum değişikliklerini de log'lamak forensics değeri taşır. | M |
| 10 | **`/tmp/jira_run_status.json` cleanup eksik** | Low | `run_task_agent.sh` trap'inde `/tmp/jira_run_status.json` temizleniyor (satır 29) ama jira-run loop'unun kendi watchdog dosyası için aynı garanti yok. | S |

---

## Kesin Olmalı

1. **`eval` yok** — `retry.sh`'de `eval "$cmd"` kaldırılmalı; fonksiyon imzası dizi argümanı alacak şekilde değiştirilmeli.
2. **JSON injection koruması** — Kullanıcıdan veya Jira API'den gelen her string JSON'a eklemeden önce `json.dumps()` ile escape edilmeli.
3. **Transport şifreli** — MCP bağlantısı HTTPS üzerinden (mevcut, doğru).
4. **Secret'lar repo dışında** — `~/.claude/secrets/` altında, `chmod 600`, `gitignore`'da (mevcut, doğru).
5. **Input validation** — URL path'ine veya API'ye giden tüm dış girdiler regex ile doğrulanmalı (kısmen mevcut, eksikler var).

---

## Kesin Değişmeli

1. **`retry.sh` — `eval` → `"$@"`:**
   ```bash
   # Eski (tehlikeli):
   retry_cmd() { local cmd="$*"; eval "$cmd"; }
   
   # Yeni (güvenli):
   retry_cmd() {
     local max_retries="${1:?}"; shift
     local attempt=0 delay=2
     while [ $attempt -lt $max_retries ]; do
       if "$@"; then return 0; fi
       attempt=$((attempt + 1))
       [ $attempt -lt $max_retries ] && sleep $delay && delay=$((delay * 2))
     done
     return 1
   }
   ```

2. **`jira-admin.md` column escape:**
   ```bash
   # Eski (tehlikeli):
   ESCAPED=$(python3 -c "import json; print(json.dumps('$COL'))")
   
   # Yeni (güvenli — $COL shell injection'dan da korumalı):
   ESCAPED=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$COL")
   ```

3. **`prereq-check.sh` — secrets izin kontrolü:**
   ```bash
   SECRETS_FILE="$HOME/.claude/secrets/secrets.env"
   if [[ -f "$SECRETS_FILE" ]]; then
     perms=$(stat -f %Lp "$SECRETS_FILE" 2>/dev/null || stat -c %a "$SECRETS_FILE")
     [[ "$perms" != "600" ]] && warn "secrets.env izni $perms (600 olmalı) — chmod 600 $SECRETS_FILE"
   fi
   ```

---

## Nice-to-Have

1. **macOS Keychain entegrasyonu:** `security add-generic-password` ile token'ı Keychain'de sakla; `setup-token` bunu opsiyonel sun. `secrets.env` yerine `security find-generic-password -s jira-suite -w` ile runtime'da çek.
2. **`mcp-remote` versiyon bildirimi:** Plugin README veya `prereq-check.sh` çıktısında kullanılan `mcp-remote` versiyonunu göster; yeni güvenlik yamaları için kontrol noktası oluştur.
3. **Jira run transition audit:** Her status değişikliğini `docs/jira_loop_log.md`'ye ek olarak yapılandırılmış JSON formatında `docs/transition_audit.jsonl`'e yaz — arama ve filtreleme kolaylığı.
4. **`max_agents` yapılandırılabilir:** `jira-start-new-task`'ta N=20 sabit; `JIRA_MAX_AGENTS` env değişkeni ile override edilebilir olmalı.
5. **`curl` timeout:** Tüm `curl` çağrılarına `--max-time 30 --connect-timeout 10` ekle; cevap vermeyen Jira instance'ı script'i sonsuza sarkıtabilir.

---

## Referanslar

- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [Bash Injection Prevention — OWASP](https://owasp.org/www-community/attacks/Command_Injection)
- [Atlassian API Token Yönetimi](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/)
- [MCP Remote GitHub — versiyon geçmişi](https://github.com/modelcontextprotocol/mcp-remote/releases)
- [Atlassian OAuth 2.0 Scopes](https://developer.atlassian.com/cloud/jira/platform/oauth-2-3lo-apps/#what-are-scopes-)
- [CWE-78: OS Command Injection](https://cwe.mitre.org/data/definitions/78.html) — `eval` riski referansı
