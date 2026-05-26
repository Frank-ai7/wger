#!/bin/bash
# Pyragogy Behörden-Assistent — Test-Script
# Nach dem Setup ausführen um den ersten echten Test zu senden

N8N_DOMAIN="${1:-DEINE-N8N-DOMAIN}"
N8N_URL="https://$N8N_DOMAIN"

echo "Test-Aufruf an: $N8N_URL/webhook/pyragogy/behoerde"
echo ""

curl -s -X POST "$N8N_URL/webhook/pyragogy/behoerde" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Widerspruch GdB-Feststellung — Erhöhung von 30 auf 50",
    "initial_text": "Ich lege Widerspruch ein gegen den Bescheid vom [DATUM] des Versorgungsamts [ORT], Aktenzeichen [AZ]. In dem Bescheid wurde mein Grad der Behinderung mit 30 festgestellt. Dies entspricht nicht meinem tatsächlichen Gesundheitszustand. Ich leide unter chronischen Rückenschmerzen (Bandscheibenvorfall L4/L5), Bluthochdruck und einer depressiven Störung. Mein behandelnder Arzt Dr. [NAME] bestätigt eine erhebliche Einschränkung der Gehfähigkeit und der Alltagsaktivitäten. Die vorliegenden Befunde rechtfertigen eine deutliche Höherbewertung. Ich beantrage die Erhöhung des GdB auf mindestens 50 sowie die Prüfung auf Merkzeichen G (erhebliche Gehbehinderung).",
    "tags": "gdb,widerspruch,sgb9,versorgungsamt,merkzeichen-g,bandscheibe,depression"
  }' | python3 -m json.tool 2>/dev/null || echo "(Antwort nicht als JSON parseable — Workflow evtl. noch nicht aktiv)"

echo ""
echo "Erwartetes Ergebnis:"
echo "  - Du erhältst eine E-Mail mit dem fertigen Widerspruchsschreiben"
echo "  - Zwei Buttons: FREIGEBEN / ABLEHNEN"
echo "  - Nach Freigabe: in Supabase gespeichert"
echo ""
echo "Verwendung: bash test_pyragogy.sh [deine-n8n-domain.de]"
