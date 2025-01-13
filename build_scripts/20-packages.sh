#!/bin/bash

set -xeuo pipefail

MAJOR_VERSION="$(sh -c '. /usr/lib/os-release ; echo $VERSION_ID')"

dnf -y remove \
	subscription-manager

dnf -y install \
	-x gnome-extensions-app \
	gnome-shell-extension-{appindicator,dash-to-dock,blur-my-shell} \
	distrobox \
	tuned-ppd \
	fpaste \
	distribution-gpg-keys \
	fastfetch \
	just

# Everything that depends on external repositories should be after this.
# Make sure to set them as disabled and enable them only when you are going to use their packages.
# We do, however, leave crb and EPEL enabled by default.

dnf config-manager --add-repo "https://pkgs.tailscale.com/stable/centos/${MAJOR_VERSION}/tailscale.repo"
dnf config-manager --set-disabled tailscale-stable
dnf -y --enablerepo tailscale-stable install \
	tailscale

dnf config-manager --add-repo "https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/centos-stream-$MAJOR_VERSION/ublue-os-staging-centos-stream-$MAJOR_VERSION.repo"
dnf config-manager --set-disabled "copr:copr.fedorainfracloud.org:ublue-os:staging"
dnf -y --enablerepo copr:copr.fedorainfracloud.org:ublue-os:staging install \
	-x bluefin-logos \
	fzf \
	glow \
	wl-clipboard \
	gnome-shell-extension-logo-menu \
	gum \
	jetbrains-mono-fonts-all \
	ublue-motd \
	ublue-fastfetch \
	ublue-brew \
	ublue-bling \
	bluefin-*

dnf -y --enablerepo "copr:copr.fedorainfracloud.org:ublue-os:staging" install uupd &&
	dnf -y install systemd-container
 
dnf -y --enablerepo "copr:copr.fedorainfracloud.org/coprs/yalter/niri-git/repo/epel-10/yalter-niri-git-epel-10.repo"" install niri
dnf -y --enablerepo "copr:copr.fedorainfracloud.org:ublue-os:staging" install ublue-setup-services &&
	systemctl enable check-sb-key.service

dnf -y --enablerepo copr:copr.fedorainfracloud.org:ublue-os:staging swap \
	centos-logos bluefin-logos

cp -r /usr/share/ublue-os/just /tmp/just
# Focefully install ujust without powerstat while we don't have it on EPEL
rpm -ivh /tmp/rpms/ublue-os-just.noarch.rpm --nodeps --force
mv /tmp/just/* /usr/share/ublue-os/just

dnf config-manager --add-repo "https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/centos-stream-${MAJOR_VERSION}/che-nerd-fonts-centos-stream-${MAJOR_VERSION}.repo"
dnf config-manager --set-disabled copr:copr.fedorainfracloud.org:che:nerd-fonts
dnf -y --enablerepo copr:copr.fedorainfracloud.org:che:nerd-fonts install \
	nerd-fonts

# This is required so homebrew works indefinitely.
# Symlinking it makes it so whenever another GCC version gets released it will break if the user has updated it without-
# the homebrew package getting updated through our builds.
# We could get some kind of static binary for GCC but this is the cleanest and most tested alternative. This Sucks.
dnf -y --setopt=install_weak_deps=False install gcc
