#!/usr/bin/env bash
# Hook PreToolUse: Prevención de fuga de secretos y certificados
# Recibe el contexto de Antigravity por stdin (JSON)

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolCall.name // empty')

is_secret() {
  local target="$1"
  # Permitir archivos de plantilla o ejemplo
  if [[ "$target" =~ \.env\.example ]]; then
    return 1
  fi
  # Bloquear .env, .certs o .npmrc (.npmrc.auth)
  if [[ "$target" =~ (\.env|\.certs|\.npmrc) ]]; then
    return 0
  fi
  return 1
}

# 1. Inspeccionar herramientas de archivo (read_file, edit_file, write_file)
if [[ "$TOOL_NAME" =~ ^(read_file|edit_file|write_file)$ ]]; then
  TARGET=$(echo "$INPUT" | jq -r '.toolCall.args.Path // empty')
  if [[ -n "$TARGET" ]] && is_secret "$TARGET"; then
    cat <<EOF
{
  "decision": "deny",
  "reason": "POLÍTICA DE SEGURIDAD (PreToolUse): El archivo '$TARGET' contiene secretos o certificados protegidos (.env, .certs, .npmrc). Operación denegada."
}
EOF
    exit 0
  fi
fi

# 2. Inspeccionar herramientas de comandos terminal (run_command)
if [[ "$TOOL_NAME" == "run_command" ]]; then
  COMMAND=$(echo "$INPUT" | jq -r '.toolCall.args.CommandLine // empty')
  if is_secret "$COMMAND"; then
    cat <<EOF
{
  "decision": "deny",
  "reason": "POLÍTICA DE SEGURIDAD (PreToolUse): El comando intenta acceder o exponer archivos sensibles (.env, .certs, .npmrc). Operación denegada."
}
EOF
    exit 0
  fi
fi

# Permitir cualquier otra operación
echo '{"decision": "allow"}'
