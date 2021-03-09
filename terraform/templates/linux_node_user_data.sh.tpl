install_splunk() {
    echo " ************************"
    echo " **** Install Splunk ****"
    echo " ************************"
    cd /opt
    sudo mkdir splunk 
    cd /opt/splunk
    sudo wget -O splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.7&product=splunk&filename=splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb&wget=true' /opt/splunk
    sudo dpkg -i /opt/splunk/splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb
    sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${splunk_password}
}

install_event_gen() {
    echo " ************************"
    echo " ****    EventGen    ****"
    echo " ************************"
    git clone https://github.com/anthonygrees/splunk_eventgen /tmp/splunk-eventgen-guide
    sudo cp -r /tmp/splunk-eventgen-guide/tutorial/ /opt/splunk/etc/apps/
    sudo tar -xvf /tmp/splunk-eventgen-guide/eventgen_632.tgz -C /opt/splunk/etc/apps/
    sudo sed -i 's/disabled = true/disabled = false/g' /opt/splunk/etc/apps/SA-Eventgen/default/inputs.conf
    sudo /opt/splunk/bin/splunk stop
    sudo systemctl stop Splunkd
    sudo cd /tmp/
    sudo chown -Rh splunk:splunk /opt/splunk/
    sudo /opt/splunk/bin/splunk enable boot-start -user splunk
}

install_apps() {
    echo " ********************************"
    echo " **** Install SplunkBaseApps ****"
    echo " ********************************"
    sudo /opt/splunk/bin/splunk install app /tmp/splunk-app-for-amazon-connect_003.tgz -auth admin:${splunk_password}
    sudo /opt/splunk/bin/splunk install app /tmp/event-timeline-viz_150.tgz -auth admin:${splunk_password}
    sudo /opt/splunk/bin/splunk install app /tmp/splunk-timeline-custom-visualization_150.tgz -auth admin:${splunk_password}
    if [[ ${load_awscodecommit} = y ]] ; then
    sudo /opt/splunk/bin/splunk install app /tmp/awscodecommit.tgz -auth admin:${splunk_password}
    fi
}

load_data() {
    echo " ***************************"
    echo " **** OneShot Data Load ****"
    echo " ***************************"
    sudo /opt/splunk/bin/splunk add oneshot /tmp/db_audit_30DAY.csv -index main -sourcetype audit -auth admin:${splunk_password}
    for i in {1..4}
    do           
        sudo /opt/splunk/bin/splunk add oneshot /tmp/cloudtrail/cloudtrail$i.json -index main -sourcetype cloudtrail -auth admin:${splunk_password}
    done
}

create_http_event_collector() {
    echo " *************************************"
    echo " **** Create HTTP Event Collector ****"
    echo " *************************************"
    sudo /opt/splunk/bin/splunk http-event-collector create new-token -uri https://localhost:8089 -description "this is a new token" -disabled 1 -index main -indexes main -auth admin:${splunk_password}
    sudo /opt/splunk/bin/splunk http-event-collector enable -name new-token -uri https://localhost:8089 -auth admin:${splunk_password}
}

install_splunk
install_apps
##create_http_event_collector
load_data
install_event_gen