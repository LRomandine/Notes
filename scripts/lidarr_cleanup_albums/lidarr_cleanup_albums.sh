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

echo "Listing albums per artist..."
while read line; do
  echo "    Checking artist ID ${line}"
  curl -s -X 'GET' \
  "http://localhost:8686/api/v1/album?artistId=${line}&includeAllArtistAlbums=true&apikey=${LIDARR_API_KEY}" \
  -H 'accept: text/json' > lidarr_temp_album.txt
  cat lidarr_temp_album.txt | jq -cr ".[] | [.id, .statistics.trackCount]"|sed 's/\[\|\]//g' > lidarr_temp_album_ids.txt
  while read line2; do
    if [[ $(echo "${line2}"|tail -c 3) == ",0" ]];then
      ALBUM_ID=$(echo "${line2}"|awk -F',' '{print $1}')
      curl -s -X 'DELETE' \
      "http://localhost:8686/api/v1/album/${ALBUM_ID}?deleteFiles=false&addImportListExclusion=true&apikey=${LIDARR_API_KEY}" \
      -H 'accept: */*'
      echo "        Deleted album ID ${ALBUM_ID}"
    fi
  done < lidarr_temp_album_ids.txt
done < lidarr_artist_id.txt

rm lidarr.txt 2>/dev/null
rm lidarr_temp_album.txt 2>/dev/null
rm lidarr_temp_album_ids.txt 2>/dev/null
rm lidarr_artist_id.txt 2>/dev/null
