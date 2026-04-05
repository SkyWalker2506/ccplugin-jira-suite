#!/usr/bin/env python3
"""Render Jira dashboard from .jira_cache.json — zero API calls."""

import json
import sys
from pathlib import Path

CACHE_FILE = Path(".jira_cache.json")

def colorize(text, code):
    return f"\033[{code}m{text}\033[0m"

def render_dashboard(data):
    summary = data.get("summary", {})
    updated = data.get("updated", "unknown")

    print(colorize(f"\n{'=' * 60}", "1"))
    print(colorize("  JIRA DASHBOARD", "1;36"))
    print(colorize(f"  Updated: {updated}", "2"))
    print(colorize(f"{'=' * 60}", "1"))

    # Summary counts
    total = summary.get("total", 0)
    todo = summary.get("todo", 0)
    ip = summary.get("in_progress", 0)
    waiting = summary.get("waiting", 0)
    blocked = summary.get("blocked", 0)
    backlog = summary.get("backlog", 0)
    done = summary.get("done", 0)

    print(f"\n  Total: {colorize(total, '1')}  |  "
          f"To Do: {colorize(todo, '33')}  |  "
          f"IP: {colorize(ip, '36')}  |  "
          f"Waiting: {colorize(waiting, '35')}  |  "
          f"Blocked: {colorize(blocked, '31')}  |  "
          f"Backlog: {colorize(backlog, '2')}  |  "
          f"Done: {colorize(done, '32')}")

    # Sections
    sections = [
        ("IN PROGRESS", "in_progress", "36"),
        ("BLOCKED", "blocked", "31"),
        ("WAITING", "waiting", "35"),
        ("TO DO", "todo", "33"),
    ]

    for title, key, color in sections:
        items = data.get(key, [])
        if not items:
            continue
        print(colorize(f"\n  --- {title} ({len(items)}) ---", f"1;{color}"))
        for item in items:
            k = item.get("key", "?")
            s = item.get("summary", "")[:50]
            p = item.get("priority", "")
            labels = " ".join(f"#{l}" for l in item.get("labels", []))
            print(f"  {colorize(k, '1')}  {s:<50}  {p:<6}  {labels}")

    # Done recent
    done_items = data.get("done_recent", [])
    if done_items:
        print(colorize(f"\n  --- DONE (recent {len(done_items)}) ---", "1;32"))
        for item in done_items:
            k = item.get("key", "?")
            s = item.get("summary", "")[:50]
            print(f"  {colorize(k, '2')}  {s}")

    print(colorize(f"\n{'=' * 60}\n", "1"))


def main():
    if not CACHE_FILE.exists():
        print("No cache found. Run `/dashboard-sync` first.")
        sys.exit(1)

    try:
        data = json.loads(CACHE_FILE.read_text())
    except (json.JSONDecodeError, OSError) as e:
        print(f"Error reading cache: {e}")
        sys.exit(1)

    render_dashboard(data)


if __name__ == "__main__":
    main()
