# syntax=docker/dockerfile:1

##
## Stage 1 - render the SVG sources to JPG and PNG
## Uses the same base image as .github/workflows/generate-images.yml
##
FROM linuxserver/inkscape:1.4.2 AS builder

RUN apk add --no-cache bash imagemagick exiftool

WORKDIR /build
COPY conversion-script.sh ./
COPY pictures-svg/ ./pictures-svg/

# inkscape needs a writable HOME for its profile directory
ENV HOME=/tmp
RUN ./conversion-script.sh

##
## Stage 2 - serve pictures-svg / pictures-jpg / pictures-png over HTTP
##
FROM nginx:1.27-alpine AS runtime

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# COPY keeps the version-alias symlinks intact (nginx serves them by default)
COPY --from=builder /build/pictures-svg/ /usr/share/nginx/html/pictures-svg/
COPY --from=builder /build/pictures-png/ /usr/share/nginx/html/pictures-png/
COPY --from=builder /build/pictures-jpg/ /usr/share/nginx/html/pictures-jpg/
COPY README.md /usr/share/nginx/html/README.md

HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -q -O /dev/null http://localhost/healthz || exit 1

EXPOSE 80
