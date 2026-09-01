# Device Pictures

This repository contains vector graphics of routers used in the [Gluon-Firmware-Selector](https://github.com/freifunk-darmstadt/gluon-firmware-selector) and in the [Meshviewer](https://github.com/freifunk/meshviewer).
It can be equally used for OpenWRT Firmware selectors and the like.

This unifies the valuable work started by [Daniel Krah](https://github.com/Moorviper/Freifunk-Router-Anleitungen), [Julian Labus](https://github.com/belzebub40k/router-pics), [Jan Alexander](https://github.com/nalxnet/freifunk-device-images) and [freifunkstuff](https://github.com/freifunkstuff/meshviewer-hwimages).

The pictures are available under [CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/), with exceptions.
Any such exception is marked with a `cc:License` or `cc:license` tag within the respective SVG file or as metadata within the PNG or JPG files.

## Creating JPG and PNG

To create jpg and png files, you need to have imagemagick, exiftool and `inkscape` installed. Run

`./conversion-script.sh <optional file path>`

Output is written to `pictures-png` and `pictures-jpg` respectively.  
Giving a folder as file path does currently not work.

## Symlinks

This repository symlinks version aliases instead of creating additional files.
Initially this was checked using `fdupes`.

The Gluon Autoupdater looks for the Model Name in the manifest (except for raspberry pi, where the board name is used).
The meshviewer receives the data from respondd through an aggregator like yanic, and therefore needs the whole Model Name too.

The firmware selector does cut off version related parts and looks for a picture without versions specified to show.
Therefore, multiple symlinks are created in the `conversion-script.sh` which take care of this.

For some devices, the Model name has been corrected in Openwrt throughout releases, which introduced a change and requires to keep an alias for the new name, as both versions may appear on a meshviewer (one with more recent firmware and one with less recent firmware).

## Installation

After creating the `pictures-jpg` and `pictures-svg` folder with symlinks, you can serve them through http to your liking.

In [meshviewer](https://github.com/freifunk/meshviewer) you can add hwImages to your config.json:

```
    "hwImg": "https://map.aachen.freifunk.net/pictures-svg/{MODEL_NORMALIZED}.svg",
```

In the [firmware-selector](https://github.com/freifunk-darmstadt/gluon-firmware-selector) you can add

```
  preview_pictures: 'https://map.aachen.freifunk.net/pictures-jpg/',
```

to use the updated central source of jpg files.

## Container image

A ready-to-serve container image is published to the GitHub Container Registry.
It renders the SVG sources to JPG/PNG at build time and serves `pictures-svg/`,
`pictures-jpg/` and `pictures-png/` (including the version-alias symlinks) via
nginx on port 80. `Access-Control-Allow-Origin: *` is set so meshviewer and
firmware-selector can fetch the images cross-origin.

```
docker run --rm -p 8080:80 ghcr.io/freifunkchemnitz/device-pictures:latest
```

The images are then available under
`http://localhost:8080/pictures-svg/{MODEL_NORMALIZED}.svg` and
`http://localhost:8080/pictures-jpg/`. A health endpoint is exposed at `/healthz`.

Build it locally with `docker build -t device-pictures .`.

### Versioning

Every push to `main` that touches the pictures or the build (see the `paths:`
filter in `.github/workflows/docker-publish.yml`) automatically:

1. increases the **minor** version of the latest `vX.Y.Z` git tag
   (first release is `v1.0.0`),
2. creates and pushes that tag,
3. builds and pushes the image as `:X.Y.Z`, `:X.Y`, `:X` and `:latest`,
4. creates a GitHub release with auto-generated notes.

Run the workflow manually (*Actions → Build and Publish Container → Run
workflow*) to pick a `major` or `patch` bump instead. Pull requests only build
the image (tagged `:pr-<number>`) without pushing or tagging.
