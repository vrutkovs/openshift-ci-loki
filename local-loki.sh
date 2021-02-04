#!/bin/bash
set -euo pipefail

if [ -z "$1" ]
  then
    echo "./local-loki.sh <path to loki-data.tar>"
    exit 1
fi

# Extract local-loki
rm -rf lokidata && mkdir lokidata
echo "Fetching ${1}"
curl -L ${1} | tar -xz -C ./lokidata
echo "Done"

# Start Loki container
docker rm -f loki || true
docker run -d --name=loki \
  -u 0 \
  -v $(pwd)/lokiconfig:/etc/loki \
  -v $(pwd)/lokidata/loki:/srv/loki \
  -p 3100:3100 \
  -ti docker.io/grafana/loki:2.1.0

# Start Grafana
docker rm -f grafana || true
docker run -d --name=grafana \
  -p 3000:3000 \
  -ti docker.io/grafana/grafana:7.3.0

echo "Grafana started at http://localhost:3000"
