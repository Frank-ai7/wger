#!/usr/bin/env python3
"""Create n8n credentials from credentials.env and wire them into the Jackie workflow."""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ENV_FILE = SCRIPT_DIR / "credentials.env"
N8N_URL = os.environ.get("N8N_URL", "http://localhost:5678")
WORKFLOW_NAME = "Personal Life Manager (Jackie)"

NODE_CREDENTIAL_MAP = {
    "telegramApi": ["Listen for incoming events", "Telegram", "Get Voice File"],
    "openRouterApi": ["OpenRouter"],
    "openAiApi": ["Transcribe a recording"],
}


def load_env(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.exists():
        raise SystemExit(f"Missing {path}. Copy credentials.env.example first.")
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


class N8nClient:
    def __init__(self, base_url: str) -> None:
        self.base_url = base_url.rstrip("/")
        self.auth_cookie = ""

    def request(self, method: str, path: str, payload: dict | None = None) -> dict:
        headers = {}
        if payload is not None:
            headers["Content-Type"] = "application/json"
        if self.auth_cookie:
            headers["Cookie"] = f"n8n-auth={self.auth_cookie}"

        data = None if payload is None else json.dumps(payload).encode()
        req = urllib.request.Request(
            f"{self.base_url}{path}",
            data=data,
            method=method,
            headers=headers,
        )
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode()
            return json.loads(body) if body else {}

    def login(self, email: str, password: str) -> None:
        data = None
        req = urllib.request.Request(
            f"{self.base_url}/rest/login",
            data=json.dumps({"emailOrLdapLoginId": email, "password": password}).encode(),
            method="POST",
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req) as resp:
            cookie_header = resp.headers.get("Set-Cookie", "")
            for part in cookie_header.split(";"):
                if part.strip().startswith("n8n-auth="):
                    self.auth_cookie = part.strip().split("=", 1)[1]
                    break
        if not self.auth_cookie:
            raise SystemExit("Login succeeded but n8n-auth cookie was not returned.")

    def create_credential(self, name: str, cred_type: str, data: dict[str, str]) -> str:
        response = self.request("POST", "/rest/credentials", {"name": name, "type": cred_type, "data": data})
        return response["data"]["id"]

    def get_workflow_by_name(self, name: str) -> dict:
        response = self.request("GET", "/rest/workflows")
        for workflow in response["data"]:
            if workflow["name"] == name:
                detail = self.request("GET", f"/rest/workflows/{workflow['id']}")
                return detail["data"]
        raise SystemExit(f"Workflow not found: {name}")

    def save_workflow(self, workflow: dict) -> None:
        workflow_id = workflow["id"]
        self.request("PATCH", f"/rest/workflows/{workflow_id}", workflow)


def main() -> None:
    env = load_env(ENV_FILE)
    client = N8nClient(N8N_URL)

    email = env.get("N8N_OWNER_EMAIL", "admin@local.dev")
    password = env.get("N8N_OWNER_PASSWORD", "Admin1234!")
    client.login(email, password)

    created: dict[str, str] = {}

    if token := env.get("TELEGRAM_BOT_TOKEN"):
        created["telegramApi"] = client.create_credential("Telegram Bot", "telegramApi", {"accessToken": token})
        print(f"Telegram credential: {created['telegramApi']}")

    if key := env.get("OPENROUTER_API_KEY"):
        created["openRouterApi"] = client.create_credential("OpenRouter", "openRouterApi", {"apiKey": key})
        print(f"OpenRouter credential: {created['openRouterApi']}")

    if key := env.get("OPENAI_API_KEY"):
        created["openAiApi"] = client.create_credential("OpenAI", "openAiApi", {"apiKey": key})
        print(f"OpenAI credential: {created['openAiApi']}")

    if not created:
        raise SystemExit("No API keys in credentials.env. Add TELEGRAM_BOT_TOKEN, OPENROUTER_API_KEY, and/or OPENAI_API_KEY.")

    workflow = client.get_workflow_by_name(WORKFLOW_NAME)

    for node in workflow["nodes"]:
        for cred_type, node_names in NODE_CREDENTIAL_MAP.items():
            if node["name"] in node_names and cred_type in created:
                node["credentials"] = {
                    cred_type: {
                        "id": created[cred_type],
                        "name": cred_type,
                    }
                }
        if node["name"] == "Google Calendar" and (calendar_email := env.get("GOOGLE_CALENDAR_EMAIL")):
            node.setdefault("parameters", {}).setdefault("calendar", {})["value"] = calendar_email

    client.save_workflow(workflow)
    print(f"Workflow '{WORKFLOW_NAME}' updated.")


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as exc:
        print(exc.read().decode(), file=sys.stderr)
        raise SystemExit(1) from exc
