# Security & Infrastructure Analiz Raporu

> **Proje:** ccplugin-jira-suite — Claude Code CLI Plugin (Jira MCP entegrasyonu)
> **Analiz tarihi:** 2026-04-05
> **Kapsam:** Token yönetimi, secret güvenliği, MCP konfigürasyonu, input validation, dependency güvenliği

---

## Mevcut Durum

### Güçlü Yanlar

- **Secret'lar repo dışında:** API token, email ve URL bilgileri kod içine gömülmemiş; `~/.claude/secrets/secrets.env` dosyasına yönlendiriliyor. Repo'da hiçbir credential yok.
- **`.gitignore` yok ama risk yok:** Proje yalnızca Markdown dosyalarından oluşuyor; binary, compiled output veya `.env` dosyası içermiyor. Bu nedenle `.gitignore` eksikliği şu an kritik değil.
- **MCP over HTTPS:** `.mcp.json` içindeki Atlassian MCP sunucusu `https://mcp.atlassian.com/v1/mcp` üzerinden bağlanıyor — plain HTTP yok, transport şifreli.
- **`mcp-remote@latest` kullanımı:** Atlassian resmi remote MCP'yi kullanıyor, kendi auth mantığını yazmıyor. Atlassian'ın OAuth/PKCE akışını devreden almıyor.
- **`allowed-tools` kısıtlaması:** Komutlar frontmatter'da `allowed-tools` ile araç kapsamını sınırlıyor (örn. `dashboard.md` yalnızca `Bash` istiyor).
- **Stale lock temizleme:** `jira-start-new-task` 15 dakika eşiğiyle eski kilitleri temizliyor — zombie agent'ların kalıcı blokaj yaratması engelleniyor.
- **Trap ile cleanup:** `trap cleanup EXIT INT TERM` paterni belgelenmiş — kilitler süreç sonunda otomatik temizleniyor.

### Puan: **5.5/10**

Temel secret izolasyonu doğru yapılmış. Ancak token'ın düz metin olarak `source ~/.claude/secrets/secrets.env` ile `curl -u` argümanına geçirilmesi, input validation eksikliği ve MCP konfigürasyonunun `@latest` pin'lemesi ciddi riskler yaratıyor.

---

## Kritik Eksikler (hemen yapılmalı)

| # | Sorun | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **`curl -u EMAIL:TOKEN` — credential process listesinde görünür** | High | `curl -u "$JIRA_AUTH"` yerine `--netrc-file` veya `Authorization: Bearer` header'ı `-H @-` ile stdin'den geç. `ps aux` ile token okunabilir. | S |
| 2 | **`mcp-remote@latest` — sabit versiyon yok** | High | `mcp-remote@0.1.x` gibi sabit versiyon pin'le. `@latest` her çalıştırmada farklı kod çekebilir — supply chain saldırısı vektörü. | S |
| 3 | **`secrets.env` dosyasının izinleri doğrulanmıyor** | High | `setup-token` akışında `chmod 600 ~/.claude/secrets/secrets.env` otomatik çalıştırılmalı. Şu an 644 olabilir — başka kullanıcılar okuyabilir. | S |
| 4 | **`PROJECT_KEY` ve `ISSUE_KEY` argümanlarına input validation yok** | High | `jira-admin.md` bash snippet'lerinde `<KEY>` ve `<ISSUE_KEY>` doğrudan URL path'ine interpolate ediliyor. `[A-Z][A-Z0-9]{1,9}` regex ile doğrulama zorunlu — path injection riski. | S |
| 5 | **`COL` değişkeni JSON string'e doğrudan interpolate ediliyor** | Med | `for COL in "${COLUMNS[@]}"` döngüsünde `'"$COL"'` JSON injection yaratabilir. Column adı `", "name": "evil` gibi bir değer içerirse yapı bozulur. `python3 -c "import json; print(json.dumps(col))"` ile escape et. | S |

---

## İyileştirme Önerileri (planlı)

| # | Öneri | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 6 | **Token rotasyonu hatırlatıcısı yok** | Med | Atlassian artık token'ları varsayılan olarak 1 yılda expire ediyor (Aralık 2024 sonrası). `setup-token --verify` akışına token oluşturma tarihi sorgusu + `days_until_expiry < 30` uyarısı ekle. | M |
| 7 | **`.jira_cache.json` içinde hassas veri olabilir** | Med | Cache dosyası issue summary, label ve priority içeriyor. Repo'ya commit edilmemesi için `.gitignore` oluştur (`**/.jira_cache.json`, `**/.jira-state/`, `**/tmp/`). | S |
| 8 | **`python3` ve `curl` dependency'leri doğrulanmıyor** | Med | Startup'ta `command -v python3 curl > /dev/null 2>&1 || { echo "Error: python3 and curl required"; exit 1; }` kontrolü ekle. Yoksa şifreli hata mesajları üretiliyor. | S |
| 9 | **`http_code` hatası sessizce geçiliyor** | Med | `create-project` akışında `HTTP_CODE != 201` durumunda `BODY` parse edilip hata mesajı gösterilmeli. Şu an başarısız istek sonraki adımlara boş `PROJECT_ID` ile devam ediyor. | S |
| 10 | **MCP bağlantı durumu doğrulanmıyor (dashboard-sync)** | Med | `dashboard-sync` MCP erişimi olmadan çalışmaya başlıyor; `jira-run` bunu round 1'de yakalıyor ama `dashboard-sync` sessizce boş cache yazıyor. MCP ping kontrolü ekle. | S |
| 11 | **`jira-run` log dosyası (`docs/jira_loop_log.md`) büyüyebilir** | Low | Log rotasyonu yok. `tail -n 500 docs/jira_loop_log.md > /tmp/jira_log_tmp && mv /tmp/jira_log_tmp docs/jira_loop_log.md` ile max 500 satır tut. | S |
| 12 | **`/tmp/jira_run_status.json` temizlenmiyor** | Low | Watchdog dosyası process sonrası `/tmp`'de kalıyor. `trap`'e `rm -f /tmp/jira_run_status.json` ekle. | S |

---

## Kesin Olmalı (industry standard)

1. **Credential'lar asla process argümanında olmamalı** — `curl -u user:pass` yerine header veya netrc.
2. **Dependency pin'leme** — `npx mcp-remote@latest` production için kabul edilemez; sabit versiyon + lock file.
3. **Secret dosyası izinleri** — `~/.claude/secrets/secrets.env` `chmod 600` olmalı; setup akışı bunu garantilemeli.
4. **Input sanitization** — URL path'ine giren her dış veri regex ile doğrulanmalı.
5. **`.gitignore`** — Cache, state ve log dosyaları commit edilmemeli.

---

## Kesin Değişmeli (mevcut sorunlar)

1. **`curl -u "$JIRA_AUTH"` → `curl -H "Authorization: Basic $(echo -n "$JIRA_AUTH" | base64)"` veya `--netrc-file`** — Bu değişiklik process listesinden token'ı gizler.
2. **`mcp-remote@latest` → `mcp-remote@0.x.x`** — Hangi versiyon kullanılıyorsa `npx mcp-remote@0.x.x` olarak pin'le, `package-lock.json` veya equivalenti ekle.
3. **`chmod 600 ~/.claude/secrets/secrets.env`** — `setup-token` akışına `touch` sonrası otomatik olarak ekle.
4. **Column adı ve issue key injection koruması** — `'"$COL"'` → `$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$COL")`.

---

## Nice-to-Have (diferansiasyon)

1. **Token şifreleme (keychain entegrasyonu):** macOS Keychain veya `pass` (Unix password manager) ile token'ları `secrets.env` yerine sistem keystore'unda sakla. `setup-token` bunu opsiyonel sunarsa güvenlik katmanı artar.
2. **Audit log:** Hangi Jira admin komutunun çalıştırıldığını, hangi projeye dokunulduğunu `~/.claude/logs/jira-audit.log`'a yaz. Forensics için değerli.
3. **Rate limiting koruması:** `curl` döngülerinde (özellikle `setup-columns`) Jira API rate limit'ine çarpılabilir. `--retry 3 --retry-delay 2` ekle veya HTTP 429'u yakala.
4. **MCP scope minimizasyonu:** `.mcp.json`'da Atlassian MCP'ye yalnızca gerekli Jira scope'larını ver — Confluence okuma gereksizse scope dışında bırak.
5. **`jira-start-new-task` max N = 20 güvenlik sınırı belgelenmeli:** Neden 20 olduğu (memory/CPU) belgelenmiş, ancak bu sayı yapılandırılabilir olmalı; farklı ortamlarda 20 paralel agent CPU spike yaratabilir.

---

## Referanslar

- [Atlassian API Token Yönetimi](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/) — Token expiration politikası, scope yönetimi
- [Atlassian Connect Güvenlik Dokümantasyonu](https://developer.atlassian.com/cloud/jira/platform/security-for-connect-apps/) — JWT doğrulama, secret şifreleme
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) — Env var vs dosya karşılaştırması, rotasyon stratejileri
- [MCP Remote GitHub](https://github.com/modelcontextprotocol/mcp-remote) — Versiyon pin'leme için
