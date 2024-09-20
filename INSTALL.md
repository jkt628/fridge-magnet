# install fridge-magnet with [sdm](https://github.com/gitbls/sdm)

## download an image from the [Raspberry Pi OS downloads](https://www.raspberrypi.com/software/operating-systems)

```bash
IMG=$(basename -s .xz $(ls ~/Downloads/*-raspios-*arm64.img* | tail -1))
xz -d -c <~/Downloads/$IMG.xz >$IMG
```

## customize and burn with sdm

```bash
mkdir -p secrets
envsubst <fridge-magnet.conf >secrets/fridge-magnet.conf
sudo sdm --customize --restart --batch \
  --extend --xmb 512 \
  --autologin \
  --cscript custom-phase.bash \
  --plugins @secrets/fridge-magnet.conf \
  $IMG
rm secrets/fridge-magnet.conf
sudo sdm --burn ${SDCARD:-/dev/sda} --host fridge-magnet --expand-root $IMG
```
