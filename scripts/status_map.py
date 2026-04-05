#!/usr/bin/env python3
"""Centralized Jira status mapping for jira-suite."""

# Jira status name -> internal key
STATUS_MAP = {
    "To Do": "todo",
    "In Progress": "in_progress",
    "WAITING FOR APPROVAL": "waiting",
    "BLOCKED": "blocked",
    "BACKLOG": "backlog",
    "Done": "done",
}

# Reverse: internal key -> Jira status name
REVERSE_MAP = {v: k for k, v in STATUS_MAP.items()}

# Dashboard section order
SECTION_ORDER = ["in_progress", "blocked", "waiting", "todo", "backlog"]


def map_status(jira_status: str) -> str:
    """Map Jira status string to internal key. Case-insensitive fallback."""
    if jira_status in STATUS_MAP:
        return STATUS_MAP[jira_status]
    # Case-insensitive fallback
    lower = jira_status.lower()
    for k, v in STATUS_MAP.items():
        if k.lower() == lower:
            return v
    return jira_status.lower().replace(" ", "_")


def get_jira_status(internal_key: str) -> str:
    """Get Jira status name from internal key."""
    return REVERSE_MAP.get(internal_key, internal_key)
