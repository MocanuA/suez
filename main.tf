terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = ">= 0.35.0"
    }
  }
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}


resource "null_resource" "install_zabbix" {
  connection {
    type     = "ssh"
    host     = var.vps_ip
    user     = var.ssh_user
    password = var.ssh_password
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade -y",
      "wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu22.04_all.deb",
      "sudo dpkg -i zabbix-release_latest_7.0+ubuntu22.04_all.deb",
      "sudo apt update",
      "sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent2",
      "sudo apt install -y mysql-server",
      "sudo mysql -uroot -e \"CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;\"",
      "sudo mysql -uroot -e \"CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';\"",
      "sudo mysql -uroot -e \"GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';\"",
      "sudo mysql -uroot -e \"SET GLOBAL log_bin_trust_function_creators = 1;\"",
      "zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -uzabbix -pzabbix zabbix",
      "sudo mysql -uroot -e \"SET GLOBAL log_bin_trust_function_creators = 0;\"",
      "sudo sed -i \"s/# DBPassword=/DBPassword=zabbix/g\" /etc/zabbix/zabbix_server.conf",
      "sudo systemctl restart zabbix-server zabbix-agent2 apache2",
      "sudo systemctl enable zabbix-server zabbix-agent2 apache2"
    ]
  }
}

output "zabbix_url" {
  value = "http://${var.vps_ip}/zabbix"
}
