#!/bin/bash

DEFAULT_ARTIST="Youtube";

OUTPUT_DIR="export"
[ ! -d "${OUTPUT_DIR}" ] && mkdir "${OUTPUT_DIR}"

main() {
	local _url=$1 \
		  _meta=$(tempfile --prefix 'youtube-album-' --suffix '.json') \
		  _thumbnail=$(tempfile --prefix 'youtube-album-' --suffix '.jpg') \
		  _album \
		  _albumdir \
		  _title \
		  _start \
		  _stop \
		  _time \
		  _filename \
		  _cmd

	youtube-dl -x -f m4a $_url
	_dl=`pwd`"/"$(youtube-dl -q --get-filename -x -f m4a $_url);

	youtube-dl -j --skip-download $_url > $_meta

	_album=$(cat "${_meta}" | jq -r .title);
	_albumdir="${OUTPUT_DIR}/$(echo "${_album}" | sed -e 's/[^A-Za-z0-9._-\ ]/_/g')";
	[ ! -d "${_albumdir}" ] && mkdir "${_albumdir}";

	wget -O "${_thumbnail}" $(cat "${_meta}" | jq -r .thumbnail); 

	total=0
	IFS=$'\n';
	for track in $(cat "${_meta}" | jq .description | xargs printf | egrep '^[0-9:]+ '); do
		_time=$(echo $track | egrep -o '^[0-9:]+');
		if [ ! -z "${_start}" ]; then
			# _start and _title hold info for the previous track. Use current _time as stop time, and run ffmpeg
			_stop=$(duration_to_seconds "${_time}");
			echo "Track # ${total} time:${_start} stop:${_stop} title:${_title} output: ${_filename}"

			ffmpeg -loglevel 8 -y -ss $_start -i "${_dl}" -t $_stop -vn -c:a copy \
				 -metadata artist="${DEFAULT_ARTIST}" -metadata album="${_album}" -metadata title="${_title}" \
				 "${_filename}"

			[ $? -ne 0 ] && exit "ffmpeg failed to cut stream." && exit 1

			eyeD3 --to-v2.3 --artist="${DEFAULT_ARTIST}" --album="${_album}" --title="${_title}" --track="${total}" --add-image="${_thumbnail}:FRONT_COVER" "${_filename}" 2>/dev/null 1>/dev/null

			[ $? -ne 0 ] && exit "eyeD3 failed to add id3v2 tagging" && exit 1			
		fi;
		((total++))
		_title=$(echo $track | cut -d ' ' -f2-);
		_start=$(duration_to_seconds "${_time}");
		_filename="${_albumdir}/"`printf "%02d" $total`" - "$(echo "${_title}" | sed -e 's/[^A-Za-z0-9._-\ ]/_/g')".m4a";

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





main "$*"


