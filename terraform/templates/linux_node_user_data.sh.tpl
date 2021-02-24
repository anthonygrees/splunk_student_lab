install_splunk() {
    echo "xxxxx Install Splunk xxxxx"
    cd /opt
    sudo mkdir splunk 
    cd /opt/splunk
    sudo wget -O splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.7&product=splunk&filename=splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb&wget=true' /opt/splunk
    sudo dpkg -i /opt/splunk/splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb
    sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${splunk_password}
}

install_event_gen() {
    git clone https://github.com/anthonygrees/splunk_eventgen /tmp/splunk-eventgen-guide
    sudo cp -r /tmp/splunk-eventgen-guide/tutorial/ /opt/splunk/etc/apps/
    sudo tar -xvf /tmp/splunk-eventgen-guide/eventgen_632.tgz -C /opt/splunk/etc/apps/
    sudo sed -i 's/disabled = true/disabled = false/g' /opt/splunk/etc/apps/SA-Eventgen/default/inputs.conf
    sudo /opt/splunk/bin/splunk stop
    sudo systemctl stop Splunkd
    sudo cd /tmp/
    sudo chown -Rh splunk:splunk /opt/splunk/
    sudo /opt/splunk/bin/splunk enable boot-start -user splunk
    ## sudo echo 'splunk ALL=(root) NOPASSWD: /usr/bin/systemctl restart Splunkd.service' >> /etc/sudoers
    ## sudo echo 'splunk ALL=(root) NOPASSWD: /usr/bin/systemctl stop Splunkd.service' >> /etc/sudoers
    ## sudo echo 'splunk ALL=(root) NOPASSWD: /usr/bin/systemctl start Splunkd.service' >> /etc/sudoers
    ## sudo echo 'splunk ALL=(root) NOPASSWD: /usr/bin/systemctl status Splunkd.service' >> /etc/sudoers
    ## reboot
}

load_data() {
    sudo /opt/splunk/bin/splunk add oneshot /tmp/db_audit_30DAY.csv -index main -sourcetype audit -auth admin:${splunk_password}
    for i in {1..4}
    do           
        sudo /opt/splunk/bin/splunk add oneshot /tmp/cloudtrail/cloudtrail$i.json -index main -sourcetype cloudtrail -auth admin:${splunk_password}
    done
}

install_splunk
load_data
install_event_gen