// Zentrale Links für mapaluto.de – hier anpassen
window.MAPALUTO_LINKS = {
  ubuntuAgentUrl: "https://cursor.com/agents/bc-06981860-e00f-4262-a344-41c9d6c6fce1",
  ubuntuCursorDeeplink:
    "cursor://anysphere.cursor-deeplink/background-agent?bcId=bc-06981860-e00f-4262-a344-41c9d6c6fce1",
  kiloclawUrl: "/agent",
  openclawUrl: "/agent",
  // HTTPS-Proxy statt blockierter Ports 8080/8765 (OpenClaw + Sandbox-Chrome)
  tomsMalAppUrl: "https://app.mapaluto.de/toms-mal-app/",
  festungUrl: "https://app.mapaluto.de/festung/",
};

window.MAPALUTO_CARDS = [
  {
    section: "Hetzner Apps",
    cards: [
      { title: "Dashboard FH", desc: "Orchester · Pyragogie · Behörden-Assistent", url: "/dashboard-fh", icon: "📊" },
      { title: "KI Orchester Minimal", desc: "4 Agenten + Judge · n8n Multi-LLM", url: "/orchester", icon: "🎼" },
      { title: "n8n Editor", desc: "Workflows bearbeiten", url: "/n8n", icon: "⚙️" },
      { title: "Khoj", desc: "Second Brain · Wissenssuche", url: "/khoj", icon: "🧠" },
      { title: "WebUI öffnen", desc: "KI-Chat im Browser", url: "/webui", icon: "💬" },
      { title: "LibreChat", desc: "Multi-Modell-Chat", url: "/librechat", icon: "🤖" },
      { title: "Server-Ping", desc: "Webhook-Erreichbarkeit testen", url: "/ping", icon: "📡" },
    ],
  },
  {
    section: "OpenClaw / Sandbox",
    cards: [
      { title: "Tom's Mal App", desc: "Webchat · Port 8080 via HTTPS-Proxy", urlKey: "tomsMalAppUrl", icon: "🦞", external: true },
      { title: "Festung", desc: "PyMuPDF-Tools · Port 8765 via HTTPS-Proxy", urlKey: "festungUrl", icon: "🏰", external: true },
      { title: "OpenClaw Agent", desc: "KI-Assistent · nach Cloudflare-Login", urlKey: "openclawUrl", icon: "🤖" },
    ],
  },
  {
    section: "Sandkasten",
    cards: [
      { title: "Ubuntu starten", desc: "Cursor Cloud-Sandbox · danach Cloud Desktop", urlKey: "ubuntuAgentUrl", icon: "🟠", accent: "#e95420", external: true },
      { title: "Kiloclaw starten", desc: "OpenClaw Agent · KI-Assistent", urlKey: "kiloclawUrl", icon: "🦞", accent: "#7c3aed" },
    ],
  },
  {
    section: "Zweites Gehirn",
    cards: [
      { title: "Khoj", desc: "Dokumente · Chat · Suche", url: "/khoj", icon: "🧠" },
      { title: "WebUI öffnen", desc: "Modelle im Browser", url: "/webui", icon: "💬" },
      { title: "LibreChat", desc: "Claude · GPT · Zwillinge", url: "/librechat", icon: "🤖" },
    ],
  },
  {
    section: "PDF (Heim-PC)",
    cards: [
      { title: "PyMuPDF-Tools", desc: "11 PDF-Werkzeuge · über app.mapaluto.de/festung/", urlKey: "festungUrl", icon: "📄", external: true },
      { title: "Festung direkt", desc: "HTTPS-Proxy statt localhost:8765", urlKey: "festungUrl", icon: "🔗", external: true },
    ],
  },
  {
    section: "Links",
    cards: [
      { title: "PC-Tools", desc: "Alle lokalen BATs · TOOLS_OEFFNEN.bat (:9123)", url: "http://localhost:9123", icon: "🖥️", external: true },
      { title: "Hetzner-Konsole", desc: "Serververwaltung", url: "https://console.hetzner.cloud", icon: "☁️", external: true },
      { title: "Cloudflare", desc: "DNS · Tunnel · Zero Trust", url: "https://dash.cloudflare.com", icon: "🛡️", external: true },
    ],
  },
];
