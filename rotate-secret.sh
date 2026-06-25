#!/usr/bin/env bash
#
# Script de rotation semi-automatique d'un secret dans HashiCorp Vault
# Usage : ./rotate-secret.sh
#
set -euo pipefail

# --- Configuration ---
VAULT_PATH="secret/wrongsecrets"   # emplacement du secret dans Vault
SECRET_KEY="db_password"           # cle du secret a faire tourner

echo "==> Rotation du secret '$SECRET_KEY' dans '$VAULT_PATH'"

# 1. Generer un nouveau mot de passe aleatoire et robuste (32 caracteres)
NEW_SECRET=$(openssl rand -base64 24)
echo "==> Nouveau secret genere (non affiche pour des raisons de securite)."

# 2. Recuperer les autres cles existantes pour ne pas les ecraser
CH41=$(vault kv get -field=challenge41password "$VAULT_PATH" 2>/dev/null || echo "")
CH59=$(vault kv get -field=challenge59_slack_webhook_url "$VAULT_PATH" 2>/dev/null || echo "")

# 3. Ecrire la nouvelle valeur dans Vault (cree une nouvelle version)
vault kv put "$VAULT_PATH" \
  "$SECRET_KEY=$NEW_SECRET" \
  challenge41password="$CH41" \
  challenge59_slack_webhook_url="$CH59" > /dev/null

# 4. Afficher la nouvelle version et tracer l'operation
NEW_VERSION=$(vault kv metadata get -format=json "$VAULT_PATH" | grep -o '"current_version":[0-9]*' | cut -d: -f2)
echo "==> Rotation reussie. Nouvelle version du secret : $NEW_VERSION"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Rotation de '$SECRET_KEY' -> version $NEW_VERSION" >> ../reports/rotation-log.txt
echo "==> Operation enregistree dans reports/rotation-log.txt"
