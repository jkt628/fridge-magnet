# install fridge-magnet with [sdm](https://github.com/gitbls/sdm)

## download an image from the [Raspberry Pi OS downloads](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-32-bit)

```bash
IMG=$(basename $(echo ~/Downloads/*-raspios-*.img* | tail -1) .xz)
xz -d -c <~/Downloads/$IMG.xz >$IMG
```

## customize and burn with sdm

```bash
mkdir -p secrets
envsubst <rootfs/etc/wpa_supplicant/wpa_supplicant.conf >secrets/wpa_supplicant.conf
sudo sdm --customize --L10n --restart --batch \
  --wpa secrets/wpa_supplicant.conf --wifi-country us \
  --user jkt --password-user $JKT_PASSWORD --autologin --redact \
  --hdmi-force-hotplug --hdmi-ignore-edid --hdmigroup 2 --hdmimode 87 --bootconfig 'hdmi_drive:2' --bootadd 'hdmi_cvt:1024 600 60 6 0 0 0' \
  --ssh socket \
  --cscript custom-phase.bash \
  --poptions xapps --xapps barrier \
  $IMG
rm secrets/wpa_supplicant.conf
sudo sdm --burn /dev/sda --host fridge-magnet --expand-root $IMG
```
