#!/bin/bash -eu

#######################################################
# Library geneis downloader
# This will download books using the Libgen.pw site. 
# *Most* of the books are available on libgen.pw instead of libgen.io
# Libgen.io is constantly timing out, maybe will eventually
# @todo update this to pull from libgen.io
# 
# Requires aria2c -- only to get proper file name, probably some way to do it w/ wget
#
# Process is this: URLs passed as arguments: 
# - http://gen.lib.rus.ec/book/index.php?md5=<MD5HASH> 
# - Get this page (above) and find this link: 
# - http://libgen.pw/item/detail/id/[0-9]* 
# - Get that page and find the URI: 
# - /item/adv/[0-9a-z]* -- prefix with https://libgen.pw 
# - Get that page then find this URI:
# - /download/book/[0-9a-z]* -- prefix with https://libgen.pw
# - This is now the final download page, pass it to aria2c
# - Careful not to download multiple files, or connections at once
#######################################################

main() {
	local _url=$1; 
	local _libgenurl=$_url; 

	echo -n "Fetching book overview page...";
	_url=$(wget -q -O - "${_url}" | egrep -m 1 -o 'http://libgen.pw/item/detail/id/[0-9]*'); 

	echo "done. ${_url}"; 

	echo -n "Fetching libgen.pw result page..."; 
	_url="https://libgen.pw"$(wget -q -O - "${_url}" | egrep -m 1 -o '/item/adv/[0-9a-z]*'); 

	echo "done. ${_url}"; 
	echo -n "Fetching libgen.pw book overview page..."; 
  
	_url="https://libgen.pw"$(wget -q -O - "${_url}" | egrep -m 1 -o '/download/book/[0-9a-z]*'); 

	echo "done. ${_url}"; 
	echo "Starting aria2c..."; 
	
	aria2c \
		--max-concurrent-downloads=1 \
		--max-connection-per-server=1 \
		--split=1 \
		--max-tries=20 \
		--continue=true \
		"${_url}"
}


main $1
