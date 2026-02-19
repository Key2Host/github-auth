#!/bin/bash

# Default
CREDENTIAL_DIR="$HOME"

# Argumente parsen
for arg in "$@"; do
  case $arg in
    -o=*|--out=*)
      CREDENTIAL_DIR="${arg#*=}"
      shift
      ;;
    *)
      ;;
  esac
done

# Ordner erstellen falls nicht vorhanden
mkdir -p "$CREDENTIAL_DIR"

CREDENTIAL_FILE="${CREDENTIAL_DIR}/.github_credentials"

# Funktion zum Speichern der Zugangsdaten
save_credentials() {
  read -p "GitHub Username: " GITHUB_USER
  read -s -p "GitHub Token (not shown): " GITHUB_TOKEN
  echo
  echo "${GITHUB_USER}:${GITHUB_TOKEN}" | base64 > "$CREDENTIAL_FILE"
  chmod 600 "$CREDENTIAL_FILE"
  echo "Credentials saved in $CREDENTIAL_FILE"
}

load_credentials() {
  if [ ! -f "$CREDENTIAL_FILE" ]; then
    echo "No credentials found."
    save_credentials
  fi
  CREDS=$(base64 -d "$CREDENTIAL_FILE")
  GITHUB_USER=$(echo "$CREDS" | cut -d: -f1)
  GITHUB_TOKEN=$(echo "$CREDS" | cut -d: -f2-)
}

clone_repo() {
  read -p "Organisation/Repo (e.g. mycompany/project): " REPO
  load_credentials
  git clone "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${REPO}.git"
}

echo "GitHub Auth Script"
echo "Credential location: $CREDENTIAL_FILE"

select choice in "Save login" "Clone repo" "Exit"; do
  case $choice in
    "Save login") save_credentials ;;
    "Clone repo") clone_repo ;;
    "Exit") exit ;;
    *) echo "Unknown choice" ;;
  esac
done
