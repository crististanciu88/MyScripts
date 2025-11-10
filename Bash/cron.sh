
SCRIPT="$(readlink -f "${BASH_SOURCE[0]:-$0}")"
LOG="/var/log/$(basename "$SCRIPT").log"
MARKER="/var/run/$(basename "$SCRIPT").done"
CRON_TAG="#bootstrap-retry-$(basename "$SCRIPT")"
CRON_ENTRY="@reboot [ ! -f $MARKER ] && $SCRIPT >> $LOG 2>&1 $CRON_TAG"

# add crontab entry if not already present
if ! crontab -l 2>/dev/null | grep -Fq "$CRON_TAG"; then
  (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
fi

And at the end of the script (after successful completion) remove the crontab entry and create the marker so it won't be re-run on reboot:

touch "$MARKER"
crontab -l 2>/dev/null | grep -vF "$CRON_TAG" | crontab -
