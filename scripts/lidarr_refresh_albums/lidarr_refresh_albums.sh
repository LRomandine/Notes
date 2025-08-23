#!/bin/bash

rm lidarr.txt 2>/dev/null
rm lidarr_temp_album.txt 2>/dev/null
rm lidarr_temp_album_ids.txt 2>/dev/null
rm lidarr_artist_id.txt 2>/dev/null

LIDARR_API_KEY="REPLACE_ME"

echo "Listing artists..."
curl -s -X 'GET' \
  "http://localhost:8686/api/v1/artist?apikey=${LIDARR_API_KEY}" \
  -H 'accept: application/json' > lidarr.txt

cat lidarr.txt |grep artistId|grep -v url|awk '{print $2}'|sed 's/,//g' > lidarr_artist_id.txt
ARTIST_COUNT=$(cat lidarr_artist_id.txt|wc -l)
COUNTER=0

echo "Listing albums per artist..."
while read line; do
  COUNTER=$((COUNTER+1))
  echo "    Checking artist ID ${line} (${COUNTER} of ${ARTIST_COUNT})"
  curl -s -X 'GET' \
  "http://localhost:8686/api/v1/album?artistId=${line}&includeAllArtistAlbums=true&apikey=${LIDARR_API_KEY}" \
  -H 'accept: text/json' > lidarr_temp_album.txt
  cat lidarr_temp_album.txt | jq -cr ".[] | .id" > lidarr_temp_album_ids.txt
  while read line2; do
    echo "        Checking album ${line2}"
    sed -i 's/Error/Eror/g' /var/lib/lidarr/logs/lidarr.txt
    curl -s -X 'POST' \
      "http://localhost:8686/api/v1/command?apikey=${LIDARR_API_KEY}" \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -d "{\"name\": \"RefreshAlbum\", \"albumId\": ${line2}}" >/dev/null 2>&1

    sleep 3
    LOOP="True"
    while [[ $LOOP == "True" ]];do
      if [[ $(tail -n 100 /var/lib/lidarr/logs/lidarr.txt|grep Error) != "" ]];then
        echo "            Error, retrying..."
        sed -i 's/Error/Eror/g' /var/lib/lidarr/logs/lidarr.txt
        sleep 10
        curl -s -X 'POST' \
          "http://localhost:8686/api/v1/command?apikey=${LIDARR_API_KEY}" \
          -H 'accept: application/json' \
          -H 'Content-Type: application/json' \
          -d "{\"name\": \"RefreshAlbum\", \"albumId\": ${line2}}" >/dev/null 2>&1
      else
        LOOP="False"
      fi
    done
  done < lidarr_temp_album_ids.txt
done < lidarr_artist_id.txt

rm lidarr.txt 2>/dev/null
rm lidarr_temp_album.txt 2>/dev/null
rm lidarr_temp_album_ids.txt 2>/dev/null
rm lidarr_artist_id.txt 2>/dev/null
