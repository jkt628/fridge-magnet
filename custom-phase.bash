#!/usr/bin/env bash

function loadparams() {
    local mpt=''
    [ "$SDMNSPAWN" == "Phase0" ] && mpt=$SDMPT
    # shellcheck disable=SC1091
    source "$mpt/etc/sdm/sdm-readparams"
}

pfx=$(basename "$0")
loadparams

phase0() {
  logtoboth "* $pfx install overlay"
  mapfile -d '' files < <(cd rootfs && find . -print0 \( -type f -o -type l \))
	for file in "${files[@]}"; do
    local args=()
    case "$file" in
      */home/jkt/*) args=(--owner=1000 --group=1000);;&
      */etc/ssh/*) args=(--mode=600);;&
      */.gitignore) install -d "${args[@]}" "${file%/.gitignore}";;
      *) install "${args[@]}" -D "rootfs/$file" "$SDMPT/$file";;
    esac
  done
}

phase1() {
  logtoboth "* $pfx disable dtoverlay"
  sed -i -e '/vc4-kms-v3d/s/^/#/' /boot/config.txt
	apt -y remove --purge nano
}

postinstall() {
	find / -mount -type f -name regenerate_ssh_host_keys\* -exec rm {} +
}

case "$1" in
  0) phase0;;
  1) phase1;;
  *) postinstall;;
esac
