install_splunk() {
    echo "xxxxx Install Splunk xxxxx"
    cd /opt
    sudo mkdir splunk 
    cd /opt/splunk
    sudo wget -O splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.7&product=splunk&filename=splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb&wget=true' /opt/splunk
    sudo dpkg -i /opt/splunk/splunk-8.0.7-cbe73339abca-linux-2.6-amd64.deb
    sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${splunk_password}
}

install_splunk