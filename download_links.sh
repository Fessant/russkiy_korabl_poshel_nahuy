 . /tmp/variables.sh
date && echo "WGET_LINK is $WGET_LINK"

convert_links_file() {
    if file $TMP_LINKS | grep CRLF; then
        echo "$TMP_LINKS contains CRLF. Converting file"
        sudo sed -i 's/\r$//' $TMP_LINKS
        sudo mv $TMP_LINKS $LINKS_FILE
    fi
}

 $LOCAL_LINKS && exit 1
    sudo wget -N $WGET_LINK -P /tmp/links_new/ &>/tmp/response
    if cat /tmp/response | grep -q 'not retrieving'; then
        echo "no new file downloaded"
        exit 1
    elif cat /tmp/response | grep -q 'Saving to'; then
        echo "new file downloaded. Prepearing and Converting"
        [[ -f $TMP_LINKS ]] && rm $TMP_LINKS
        sudo cp $NEW_LINKS $TMP_LINKS
        convert_links_file
        # sudo docker rm -f $(docker ps -q -a) #removing all working containers in case of links.txt refresh and restart loop
        export LINKS_UPDATED=true
        exit 0
    else
        echo "Something wrong happened with file downloading. Response is:"
        cat /tmp/response
        exit 1
    fi