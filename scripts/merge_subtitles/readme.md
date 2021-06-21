# merge_subtitles.sh
Scan a video directory for subtitle files and use MKVMerge to merge them into a single container. Usefull when you download subtitles with Kodi and want them embedded into the MKV file.

## Exmaple cron entry
```
1 10 * * * /root/scripts/merge_subtitles.sh > /dev/null 2>&1
```
