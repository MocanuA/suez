Déploiement et Surveillance avec Terraform, CLI Python & Power BI

Encore merci :) / J'ai 75% du total car je l'ai fait en 7h je suis actuellement en free lance cette semaine j'ai réalisé cela le soir (Avec plus de temps je peux vous faire une configuration bien plus avancée :) et surtout j'ai une envie de progresser inimaginable surtout côté automatisation et graphiques <3)

VPS :
193.70.2.61
USERNAME: ubuntu
MDP : B6D@y_cRBmR9@g-Nmpub

ssh : ssh ubuntu@193.70.2.61

Zabbix:

http://193.70.2.61/zabbix

ID: Admin
MDP: oY266QWNQY9J8wM@gM6jyC

1️⃣ Déploiement du Serveur Zabbix avec Terraform sur OVH

🔹 Prérequis

Un compte OVH avec accès API

Terraform installé sur votre machine📌 Installation de Terraform

Clé SSH pour accéder au serveur

Un projet API OVH avec App Key, App Secret, Consumer Key📌 Créer une application OVH

🚀 1. Déploiement du VPS et de Zabbix via Terraform

📂 Fichiers Terraform expliqués

main.tf → Définit le provider OVH et configure le VPS

variables.tf → Contient les variables API (clé OVH, IP VPS, etc.)

install_zabbix.tf → Automatisation de l'installation de Zabbix via SSH

🔹 Explication du code Terraform (install_zabbix.tf)

Ce fichier installe automatiquement Zabbix après la création du VPS.

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

🎯 Ce que ce script fait :

✅ Met à jour le serveur✅ Installe le serveur Zabbix et la base de données MySQL✅ Configure les accès à MySQL pour Zabbix✅ Initialise la base de données avec les scripts officiels✅ Active et démarre les services Zabbix

🚀 2. Développement du CLI Python pour Zabbix

📂 Fichiers Python expliqués (dans suez.zip) :

zabbix_cli.py → CLI pour interagir avec Zabbix (ajout, suppression, mise à jour de hosts)

requirements.txt → Contient les dépendances suivantes :

requests
argparse

Installation :

pip install -r requirements.txt

📌 Explication du fichier zabbix_cli.py

Ce script permet d'ajouter, de récupérer et de supprimer des machines depuis Zabbix.

🔹 Authentification via l'API

def get_auth_token():
    payload = {
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
            "username": ZABBIX_USER,
            "password": ZABBIX_PASSWORD
        },
        "id": 1,
        "auth": None
    }
    response = requests.post(ZABBIX_URL, json=payload)
    return response.json().get("result")

✅ Se connecte à l'API✅ Récupère le token de session

🚀 3. Intégration des Données Zabbix avec Power BI

🔹 Objectif

Connecter Power BI aux données Zabbix via l’API.

📌 Étapes

1️⃣ Connexion API REST à Power BI

Ouvrir Power BI

Obtenir des données → Requête Web

Entrer l’URL de l’API Zabbix http://193.70.2.61/zabbix/api_jsonrpc.php

Ajouter le token d’authentification: Content Type : application/JSON

Dans l'éditeur avancé insérer : 
let
    url = "http://193.70.2.61/zabbix/api_jsonrpc.php",
    body = "{""jsonrpc"": ""2.0"", ""method"": ""host.get"", ""params"": {""output"": [""hostid"", ""host"", ""status""]}, ""auth"": ""7cababc690268f3ab21fa79e1e39b807"", ""id"": 1}",
    headers = [#"Content-Type"="application/json"],
    Source = Web.Contents(url, [Headers=headers, Content=Text.ToBinary(body)]),
    JsonData = Json.Document(Source),
    result = JsonData[result],
    Table = Table.FromList(result, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
    Table


2️⃣ Exploration des données

Récupération des métriques Zabbix

Filtrage et transformation des données

📌 Remarque : Nous avons pas fait de graphiques pour alléger les temps de travail (car occupé en freelance actuellement).

📌 Résumé du Projet

1️⃣ Déploiement automatique d’un serveur Zabbix via Terraform2️⃣ Création d’un CLI Python pour gérer les hosts3️⃣ Connexion Power BI à l’API Zabbix

🙏 Remerciements

Merci à Martin et à Suez pour l'opportunité ! 🎉

Liens (et captures :)

https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash

https://developer.hashicorp.com/terraform/install

https://phoenixnap.com/kb/how-to-install-terraform

https://help.ovhcloud.com/csm/fr-vps-getting-started?id=kb_article_view&sysparm_article=KB0047736#se-connecter-a-votre-vps

https://help.ovhcloud.com/csm/fr-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042789

https://www.ovh.com/auth/api/createToken
