#!/bin/bash

OLD_IFS="${IFS}"
IFS=$'\n'
for SUBTITLE_FILE in `find /Storage/Videos/ -name '*.srt'` ; do
    echo "Subtitle file is ${SUBTITLE_FILE}"
    # Verify is english
    if [[ `echo "${SUBTITLE_FILE}" | grep '.en.srt'` == "" ]];then
        echo "Non english subtitle file, deleting."
        rm "${SUBTITLE_FILE}"
        continue
    fi
    VIDEO_FILE=$(find "${SUBTITLE_FILE%???????}"* -name '*.mkv' -or -name '*.mp4')
    echo "Video File is    ${VIDEO_FILE}"

    # mkvmerge cannot perform an in place add so we must copy into a temp file
    echo "Merging..."
    mkvmerge -o "${VIDEO_FILE}".TEMP "${VIDEO_FILE}" --language 0:eng "${SUBTITLE_FILE}"
    if [[ $? == 0 ]];then
        echo "Merege was successful, cleaning up..."
        rm "${VIDEO_FILE}"
        rm "${SUBTITLE_FILE}"
        mv "${VIDEO_FILE}".TEMP "${VIDEO_FILE}"
    else
        echo "There was an error!"
        continue
    fi
    echo "Finished loop."
done
IFS="${OLD_IFS}"
echo "All done, exiting."
