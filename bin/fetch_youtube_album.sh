#!/bin/bash
# Rip a youtube FULL ALBUM link to tracks using the Comments Description for track seperators

DEFAULT_ARTIST="Youtube";

OUTPUT_DIR="export"
[ ! -d "${OUTPUT_DIR}" ] && mkdir "${OUTPUT_DIR}"

main() {
        local _url=$1 \
                  _meta=$(mktemp youtube-album-XXXXXXXXXXX.json) \
                  _thumbnail=$(mktemp youtube-album-XXXXXXXXXXX.jpg) \
                  _title \
                  _artist \
                  _album \
                  _albumdir \
                  _thumbnail_url \
                  _title \
                  _start \
                  _stop \
                  _time \
                  _filename \
                  _cmd \
                  _trackno \
                  _trackname \
                  _tracktime


        youtube-dl -x -f m4a $_url
        #_dl=`pwd`$(youtube-dl --skip-download -q --get-filename -x -f m4a $_url);
        _dl=$(youtube-dl --skip-download -q --get-filename -x -f m4a $_url);

        
        youtube-dl --get-title --get-thumbnail --get-description --skip-download $_url > "${_meta}"
        _title=$(tail -n +1 $_meta | head -1); 
        _thumbnail_url=$(tail -n +2 $_meta | head -1);

        _artist=$(echo "$_title" | cut -d '-' -f1);
        _album=$(echo "$_title" | cut -d '-' -f2 | sed 's/^ *//g');

        
        _albumdir="${OUTPUT_DIR}/$(echo "${_title}" | sed -e 's/[^A-Za-z0-9.\_\-\ ]/_/g')";
        [ ! -d "${_albumdir}" ] && mkdir "${_albumdir}";

        wget -O "${_thumbnail}" "${_thumbnail_url}";
        
        total=0
        IFS=$'\n';
        #for track in $(cat "${_meta}" | jq .description | xargs printf | egrep '^[0-9:]+ '); do
        for track in $(tail -n +3 "${_meta}"); do
                IFS=' '; 
                _trackname="";
                _tracktime="";
                _trackno="";
                _track=$(echo "${track}" | tr -d "\n" | tr -d "\r");
                for v in $_track; do
                  if [[ "$v" =~ ^[0-9.]*$ ]]; then _trackno="${v//./}"; 
                  elif [[ "$v" =~ ^[0-9]+:[0-9]+:?[0-9]?[0-9]?$ ]]; then _tracktime=$v; 
                  else _trackname="${_trackname} ${v/ /}";
                  fi
                done;

                if [[ -z "$_tracktime" ]]; then continue; fi

                _trackname="${_trackname/# /}"
                echo "Number: ${_trackno} Time: ${_tracktime} Name: ${_trackname}";
                IFS=$'\n';
                _time="${_tracktime}";

                if [ ! -z "${_start}" ]; then
                        # _start and _title hold info for the previous track. Use current _time as stop time, and run ffmpeg
                        _stop=$(duration_to_seconds "${_time}");
                        _duration=$(($_stop-$_start))

                        echo "Track # ${total} time:${_start} stop:${_stop} title:${_title} output: ${_filename}"

                        ffmpeg -loglevel 8 -stats -y -ss $_start -i "${_dl}" -t $_duration -vn -qscale:a 0 \
                                 -metadata track="${total}" -metadata artist="${_artist}" -metadata album="${_album}" -metadata title="${_trackname}" \
                                 "${_filename}"
                fi;
                ((total++))
                _start=$(duration_to_seconds "${_time}");
                _filename="${_albumdir}/"`printf "%02d" $total`" - "$(echo "${_trackname}" | sed -e 's/[^A-Za-z0-9.\_\-\ ]/_/g')".m4a";

        done
        ((total--));

        echo "Total tracks: $total";

        rm "${_dl}";
        rm "${_meta}";
        rm "${_thumbnail}";

}

###
# Convert a duration like HH:MM:SS (or MM:SS) to seconds
###
duration_to_seconds() {
        local _time=$1, _res
        _res=$(echo $1 | awk -F':' '{if (NF == 2) {print $1 * 60 + $2} else {print $1 * 60 * 60 + $2 * 60 + $3}}');
        echo $_res;
}


for u in "$@"; do 
  #main "$*"
  main "$u"
done;


