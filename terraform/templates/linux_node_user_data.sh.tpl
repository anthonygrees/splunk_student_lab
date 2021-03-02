install_splunk() {
    echo "
    ____           __        ____   _____       __            __      
   /  _/___  _____/ /_____ _/ / /  / ___/____  / /_  ______  / /__    
   / // __ \/ ___/ __/ __ `/ / /   \__ \/ __ \/ / / / / __ \/ //_/    
 _/ // / / (__  ) /_/ /_/ / / /   ___/ / /_/ / / /_/ / / / / ,<       
/___/_/ /_/____/\__/\__,_/_/_/   /____/ .___/_/\__,_/_/ /_/_/|_|      
                                     /_/                              
"
    cd /opt
    sudo mkdir splunk 
    cd /opt/splunk
    sudo wget -O splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.7&product=splunk&filename=splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb&wget=true' /opt/splunk
    sudo dpkg -i /opt/splunk/splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb
    sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${splunk_password}
}

install_event_gen() {
    echo "
    ____                 ______                 __  ______         
   / __ \__  ______     / ____/   _____  ____  / /_/ ____/__  ____ 
  / /_/ / / / / __ \   / __/ | | / / _ \/ __ \/ __/ / __/ _ \/ __ \
 / _, _/ /_/ / / / /  / /___ | |/ /  __/ / / / /_/ /_/ /  __/ / / /
/_/ |_|\__,_/_/ /_/  /_____/ |___/\___/_/ /_/\__/\____/\___/_/ /_/ 
                                                                   
    "
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
    echo "
    ____           __        ____   _____       __            __   ____                     ___                    
   /  _/___  _____/ /_____ _/ / /  / ___/____  / /_  ______  / /__/ __ )____ _________     /   |  ____  ____  _____
   / // __ \/ ___/ __/ __ `/ / /   \__ \/ __ \/ / / / / __ \/ //_/ __  / __ `/ ___/ _ \   / /| | / __ \/ __ \/ ___/
 _/ // / / (__  ) /_/ /_/ / / /   ___/ / /_/ / / /_/ / / / / ,< / /_/ / /_/ (__  )  __/  / ___ |/ /_/ / /_/ (__  ) 
/___/_/ /_/____/\__/\__,_/_/_/   /____/ .___/_/\__,_/_/ /_/_/|_/_____/\__,_/____/\___/  /_/  |_/ .___/ .___/____/  
                                     /_/                                                      /_/   /_/            
    "
    sudo /opt/splunk/bin/splunk install app /tmp/splunk-app-for-amazon-connect_003.tgz -auth admin:${splunk_password}
}

load_data() {
    echo "
   ____            _____ __          __     ____        __           __                    __
  / __ \____  ___ / ___// /_  ____  / /_   / __ \____ _/ /_____ _   / /   ____  ____ _____/ /
 / / / / __ \/ _ \\__ \/ __ \/ __ \/ __/  / / / / __ `/ __/ __ `/  / /   / __ \/ __ `/ __  / 
/ /_/ / / / /  __/__/ / / / / /_/ / /_   / /_/ / /_/ / /_/ /_/ /  / /___/ /_/ / /_/ / /_/ /  
\____/_/ /_/\___/____/_/ /_/\____/\__/  /_____/\__,_/\__/\__,_/  /_____/\____/\__,_/\__,_/   
                                                                                             
    "
    sudo /opt/splunk/bin/splunk add oneshot /tmp/db_audit_30DAY.csv -index main -sourcetype audit -auth admin:${splunk_password}
    for i in {1..4}
    do           
        sudo /opt/splunk/bin/splunk add oneshot /tmp/cloudtrail/cloudtrail$i.json -index main -sourcetype cloudtrail -auth admin:${splunk_password}
    done
}

install_splunk
install_apps
load_data
install_event_gen