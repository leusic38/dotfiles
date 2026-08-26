#!/usr/bin/env bash
# Installe l'automontage MTP du téléphone Android dans /run/media/$USER/.
# Idempotent : relançable sans risque.
#
#   sudo ~/dotfiles/system/install-android-mtp.sh
#
# Pour désinstaller :
#   sudo ~/dotfiles/system/install-android-mtp.sh --uninstall

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIT=android-mtp-automount@.service
RULE=99-android-mtp-automount.rules

[[ $EUID -eq 0 ]] || { echo "À lancer en root : sudo $0" >&2; exit 1; }

if [[ ${1-} == --uninstall ]]; then
    systemctl stop 'android-mtp-automount@Galaxy.service' 2>/dev/null || true
    rm -fv "/etc/systemd/system/$UNIT" "/etc/udev/rules.d/$RULE"
    systemctl daemon-reload
    udevadm control --reload
    echo "Désinstallé. Le paquet android-file-transfer est conservé."
    exit 0
fi

echo "==> Paquet android-file-transfer (fournit aft-mtp-mount)"
if command -v aft-mtp-mount >/dev/null; then
    echo "    déjà installé"
else
    pacman -S --needed --noconfirm android-file-transfer
fi

echo "==> Contrôle de disponibilité"
install -m 0755 "$SRC/usr/local/bin/android-mtp-ready" /usr/local/bin/android-mtp-ready

echo "==> Unité systemd"
install -m 0644 "$SRC/etc/systemd/system/$UNIT" "/etc/systemd/system/$UNIT"

echo "==> Règle udev"
install -m 0644 "$SRC/etc/udev/rules.d/$RULE" "/etc/udev/rules.d/$RULE"

# Optionnel : remontage sans mot de passe (voir --with-sudoers).
# Non installé par défaut, c'est un assouplissement des droits : à toi de
# décider. Portée du fichier : start/stop/restart de cette seule unité.
if [[ ${1-} == --with-sudoers ]]; then
    echo "==> Règle sudoers (remontage sans mot de passe)"
    visudo -cqf "$SRC/etc/sudoers.d/android-mtp"
    install -m 0440 -o root -g root "$SRC/etc/sudoers.d/android-mtp" /etc/sudoers.d/android-mtp
fi

echo "==> Rechargement"
systemctl daemon-reload
udevadm control --reload

echo
echo "Terminé. Débranche puis rebranche le téléphone : il apparaîtra dans"
echo "  /run/media/${SUDO_USER:-$USER}/Galaxy"
echo
echo "Diagnostic si besoin :"
echo "  systemctl status android-mtp-automount@Galaxy.service"
echo "  journalctl -u android-mtp-automount@Galaxy.service -b"
