# Setup Email Notifications per Aggiornamenti

## Configurazione ssmtp in WSL per Gmail

1. **Installa ssmtp:**
```bash
sudo apt-get update
sudo apt-get install ssmtp mailutils
```

2. **Configura ssmtp:** `/etc/ssmtp/ssmtp.conf`
```
root=tua-email@gmail.com
mailhub=smtp.gmail.com:587
AuthUser=tua-email@gmail.com
AuthPass=tua-app-password  # Usa App Password, non la password normale
UseSTARTTLS=YES
FromLineOverride=YES
```

3. **Crea App Password per Gmail:**
   - Vai su https://myaccount.google.com/security
   - Attiva autenticazione a 2 fattori
   - Genera "App Password" per "Mail"

4. **Test invio email:**
```bash
echo "Test email" | mail -s "Test Subject" tua-email@gmail.com
```

## Alternativa: Usa webhook con IFTTT

1. Crea account su [IFTTT](https://ifttt.com/)
2. Crea applet: "If Webhook then Email"
3. Modifica lo script per chiamare webhook invece di mail:

```bash
# Invece di mail command
curl -X POST https://maker.ifttt.com/trigger/faststone_update/with/key/TUA_KEY \
  -H "Content-Type: application/json" \
  -d "{\"value1\":\"$NEW_VERSION\",\"value2\":\"$CACHED_VERSION\"}"
```

## Utilizzo GitHub Actions (Consigliato)

Il workflow GitHub Actions creato (`.github/workflows/check-updates.yml`) è la soluzione più semplice:

1. Si attiva automaticamente ogni giorno
2. Crea un Issue su GitHub quando trova aggiornamenti
3. GitHub ti invia email per nuovo Issue
4. Non richiede configurazione email locale

Per attivarlo:
```bash
git add .github/workflows/check-updates.yml
git commit -m "Add automated update checker workflow"
git push origin main
```

Poi vai su GitHub → Settings → Notifications e assicurati di ricevere email per Issues.