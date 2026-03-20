# Architekturentscheidungen

## 2026-03-20: Produktions-Hardening für Single-VM-Deploy auf Hetzner

Für den ersten produktionsnahen Deploy auf einer einzelnen Hetzner-VM gelten folgende Architekturentscheidungen:

1. **Einheitliche Service-Namen über Compose, Env und Deploy-Skripte.**
   - Compose verwendet `frontend`, `backend` und `postgres`.
   - Deploy- und Backup-Skripte referenzieren dieselben Namen standardmässig.

2. **Django läuft in Produktion via Gunicorn statt `runserver`.**
   - Migrationen werden nicht implizit im Container-Start ausgeführt.
   - Migrationen und `collectstatic` laufen explizit im Deploy-Skript.

3. **Frontend wird als statischer Build ausgeliefert.**
   - Vite baut zur Image-Build-Zeit.
   - Ein Nginx-Container liefert das resultierende Frontend aus.

4. **Frontend und Backend laufen im Browser unter derselben Origin.**
   - Nginx im Frontend-Container proxyt `/api/*` intern an das Backend.
   - Dadurch ist für das Produktionssetup kein separates CORS-Handling nötig.

5. **Security-Defaults werden für Produktion gehärtet.**
   - `DEBUG` ist standardmässig deaktiviert.
   - `ALLOWED_HOSTS` und `CSRF_TRUSTED_ORIGINS` werden aus der Umgebung gesetzt.
   - Wichtige Security-Header und sichere Cookies werden im Nicht-Debug-Modus aktiviert.

6. **Das Produktionssetup bleibt bewusst einfach.**
   - Ziel ist eine einzelne Hetzner-VM mit Docker Compose.
   - TLS-Termination oder ein externer Reverse Proxy können später ergänzt werden, sind aber nicht Teil dieses ersten Produktions-Hardening-Schritts.
