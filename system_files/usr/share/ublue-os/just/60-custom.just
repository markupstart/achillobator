install-system-flatpaks:
    #!/usr/bin/env bash
    flatpak remote-add --system flathub https://flathub.org/repo/flathub.flatpakrepo
    xargs flatpak --system -y install --or-update < /etc/ublue-os/system-flatpaks.list

bluefin-cli:
    /usr/libexec/ublue-bling
