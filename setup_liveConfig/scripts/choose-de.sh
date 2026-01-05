#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="${SCRIPT_DIR}/setup.sh"

# ────────────────────────────────
# Ensure setup.sh exists
# ────────────────────────────────
if [[ ! -f "$SETUP_SCRIPT" ]]; then
  echo "Error: setup.sh not found at $SETUP_SCRIPT"
  exit 1
fi

# ────────────────────────────────
# Ask for dry-run mode
# ────────────────────────────────
echo "Would you like to perform a dry run first?"
select dry_choice in "Yes" "No"; do
  case "$dry_choice" in
    Yes) DRY_FLAG="--dry-run"; break ;;
    No) DRY_FLAG="--no-dry-run"; break ;;
    *) echo "Invalid choice. Please select 1 or 2." ;;
  esac
done

# ────────────────────────────────
# Ask which desktop to install
# ────────────────────────────────
echo
echo "Which desktop environment do you want to install?"
select desktop_choice in "hypr" "ml4w"; do
  case "$desktop_choice" in
    hypr|ml4w)
      DESKTOP="$desktop_choice"
      break
      ;;
    *)
      echo "Invalid choice. Please select 1 or 2."
      ;;
  esac
done

# ────────────────────────────────
# Confirm and run
# ────────────────────────────────
echo
echo "You selected:"
echo "  Dry run:  $DRY_FLAG"
echo "  Desktop:  $DESKTOP"
echo

read -rp "Run setup with these options? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# ────────────────────────────────
# Execute setup.sh with selected options
# ────────────────────────────────
exec "$SETUP_SCRIPT" "$DRY_FLAG" "$DESKTOP"

