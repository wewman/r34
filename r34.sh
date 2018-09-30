#!/bin/bash

################### USAGE #################
##                                       ##
##   sh r34.sh tag1 tag2  ...            ##
##                                       ##
###########################################

################### NOTES #################
##                                       ##
##        Note that Paheal's tags are    ##
##                                       ##
##                 U G H                 ##
##                                       ##
###########################################


# Take every parameter
input="$@"

# Replace spaces with + to fit the URL
tags="${input// /\%20}"

# Appropriate directory
#   though, if you put the tags in
#   a different way, it will probably
#   re-download the same stuff but in
#   a different directory
mkdir -p "$input"

echo Leeching everything with: "$tags"
echo Prepare yourself.

# Page number
pid=1

# Loop forever until break
while true; do

    # Display current page number
    #   but will get lost due to wget output
    echo -n "$pid" ' '

    # What it does:
    #  1 Gets the XML document with the given tags
    #  2 Greps out the line with file_url with its random
    #     numbers and directories so there are no duplicates
    #  3 Cuts the file_url=" from the beginning of every line
    #  4 Appends https: in the beginning of every line
    #  5 Put everything to a file so wget can download them
    #     NOTE Every file has 100 links
    #       due to Gelbooru's max limit being 100
    #       so, every 10 files is 1000 images downloaded
    #get=$(curl -s "https://rule34.paheal.net/rss/images/$tags/$pid" \
    #    | grep -ioE "http:\/\/[a-z]+\.paheal\.net\/_images\/.{32}\/.+" \
    #    | rev \
    #    | cut -c 4- \
    #    | rev \
    #    | tee "$input"/image_"$pid".files)
#        | sed -e "s/^/https:/" \

    # Utilizing regex to its extent can save you so much piping.
    get=$(curl -s "https://rule34.paheal.net/rss/images/$tags/$pid" \
        | grep -ioE "(https:\/\/[a-z]+\.paheal\.net\/\_images\/.{32}\/.+\.(?:png|jpg|jpeg|gif|webm))" \
        | tee "$input"/image_"$pid".files)


    # Check if the output is alive.
    if [[ ! ${get} ]]; then
        # If the output is empty (empty string)
        #   it will clean and break
        echo Done, no more files
        #echo Cleaning...
        #rm image_*
        break;
    else
        # Downloads the files to an appropriate directory
        wget=$(wget -i "$input"/image_"$pid".files -nc -P "$input" -c)
        printf "%02d\033[K\r $wget"

        # Increment and continue
        (( pid++ ))
        continue;
    fi

done
