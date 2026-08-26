#!/usr/bin/env bash
# Branch the Claude Code session running in the current herdr pane into a
# new tab or a new split pane. Usage: branch-session.sh [tab|pane]
set -euo pipefail

mode="${1:?usage: branch-session.sh [tab|pane]}"

session_id=$(herdr agent get "$HERDR_ACTIVE_PANE_ID" | jq -r '.result.agent.agent_session.value')

if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
  echo "branch-session: no Claude session detected in pane $HERDR_ACTIVE_PANE_ID" >&2
  exit 1
fi

if [ "$mode" = "tab" ]; then
  target=$(herdr tab create --cwd "$HERDR_ACTIVE_PANE_CWD" --label "branch" --focus \
    | jq -r '.result.root_pane.pane_id')
else
  target=$(herdr pane split --pane "$HERDR_ACTIVE_PANE_ID" --direction right --cwd "$HERDR_ACTIVE_PANE_CWD" --focus \
    | jq -r '.result.pane.pane_id')
fi

herdr pane run "$target" claude --resume "$session_id" --fork-session
