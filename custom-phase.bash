#!/usr/bin/env bash

function loadparams() {
    local mpt=''
    [ "$SDMNSPAWN" == "Phase0" ] && mpt=$SDMPT
    # shellcheck disable=SC1091
    source "$mpt/etc/sdm/sdm-readparams"
}

pfx=$(basename "$0")
loadparams

chpi() {
  rmdir "/home/$myuser"
  groupmod --new-name "$myuser" pi
  usermod --login "$myuser" pi
  usermod --home "/home/$myuser" --move-home --append --groups ssh "$myuser"
}

phase0() {
  logtoboth "* $pfx rename user pi"
  export myuser passworduser
  export -f chpi
  chroot "$SDMPT" bash -vxc chpi
  logtoboth "* $pfx install overlay"
  mapfile -d '' files < <(cd rootfs && find . -print0 \( -type f -o -type l \))
  for ((i=${#files[@]}; --i>=0; )); do
    local args=() file="${files[$i]}"
    case "$file" in
      *wpa_supplicant*) continue;;
      */home/jkt/*) args=(--owner=1000 --group=1000);;&
      */.gitignore) install -d "${args[@]}" "${file%/.gitignore}"; continue;;
      *) install "${args[@]}" -D "rootfs/$file" "$SDMPT/$file";;
    esac
  done
}

phase1() {
  logtoboth "* $pfx disable dtoverlay"
  sed -i -e '/vc4-kms-v3d/s/^/#/' /boot/config.txt
}

postinstall() {
  pip install bleak construct
}

case "$1" in
  0) phase0;;
  1) phase1;;
  *) postinstall;;
esac
