#!/usr/bin/env bash
# Branch the Claude Code or Codex session running in the current herdr pane
# into a new tab or a new split pane. Usage: branch-session.sh [tab|pane]
set -euo pipefail

mode="${1:?usage: branch-session.sh [tab|pane]}"

agent_info=$(herdr agent get "$HERDR_ACTIVE_PANE_ID")
agent=$(jq -r '.result.agent.agent' <<<"$agent_info")
session_id=$(jq -r '.result.agent.agent_session.value' <<<"$agent_info")

if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
  echo "branch-session: no agent session detected in pane $HERDR_ACTIVE_PANE_ID" >&2
  exit 1
fi

case "$agent" in
  claude) fork_command=(claude --resume "$session_id" --fork-session) ;;
  codex) fork_command=(codex fork "$session_id") ;;
  *)
    echo "branch-session: unsupported agent '$agent' in pane $HERDR_ACTIVE_PANE_ID" >&2
    exit 1
    ;;
esac

if [ "$mode" = "tab" ]; then
  target=$(herdr tab create --cwd "$HERDR_ACTIVE_PANE_CWD" --label "branch" --focus \
    | jq -r '.result.root_pane.pane_id')
else
  target=$(herdr pane split --pane "$HERDR_ACTIVE_PANE_ID" --direction right --cwd "$HERDR_ACTIVE_PANE_CWD" --focus \
    | jq -r '.result.pane.pane_id')
fi

herdr pane run "$target" "${fork_command[@]}"
