import requests
import json
import sys

# Configuration de l'API Zabbix
ZABBIX_URL = "http://193.70.2.61/zabbix/api_jsonrpc.php"
ZABBIX_USER = "Admin"
ZABBIX_PASSWORD = "oY266QWNQY9J8wM@gM6jyC"

HEADERS = {"Content-Type": "application/json"}

# Fonction pour récupérer le token d'authentification
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
    
    try:
        response = requests.post(ZABBIX_URL, json=payload, headers=HEADERS)
        response_data = response.json()

        if "result" in response_data:
            return response_data["result"]
        else:
            print(f"Erreur d'authentification: {response_data.get('error', 'Réponse inconnue')}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Erreur réseau : {e}")
        return None

AUTH_TOKEN = get_auth_token()

if not AUTH_TOKEN:
    print("Impossible d'obtenir le token d'authentification.")
    sys.exit(1)

# Fonction pour créer un host (ton PC)
def create_host(hostname, ip, group_id="2", template_id="10001"):
    payload = {
        "jsonrpc": "2.0",
        "method": "host.create",
        "params": {
            "host": hostname,
            "interfaces": [{
                "type": 1, 
                "main": 1,
                "useip": 1,
                "ip": ip,
                "dns": "",
                "port": "10050"
            }],
            "groups": [{"groupid": group_id}],
            "templates": [{"templateid": template_id}]
        },
        "auth": AUTH_TOKEN,
        "id": 2
    }
    
    return send_request(payload, "Host créé avec succès!")

# Fonction pour récupérer tous les hosts
def get_hosts():
    payload = {
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
            "output": ["hostid", "host", "status"]
        },
        "auth": AUTH_TOKEN,
        "id": 3
    }
    
    return send_request(payload, "Liste des hosts:")

# Fonction pour mettre à jour un host
def update_host(host_id, new_name):
    payload = {
        "jsonrpc": "2.0",
        "method": "host.update",
        "params": {
            "hostid": host_id,
            "host": new_name
        },
        "auth": AUTH_TOKEN,
        "id": 4
    }
    
    return send_request(payload, "Host mis à jour avec succès!")

# Fonction pour supprimer un host
def delete_host(host_id):
    payload = {
        "jsonrpc": "2.0",
        "method": "host.delete",
        "params": [host_id],
        "auth": AUTH_TOKEN,
        "id": 5
    }
    
    return send_request(payload, "Host supprimé avec succès!")

# Fonction générique pour envoyer une requête à Zabbix
def send_request(payload, success_message):
    try:
        response = requests.post(ZABBIX_URL, json=payload, headers=HEADERS)
        response_data = response.json()
        
        if "result" in response_data:
            print(f"{success_message}")
            return response_data["result"]
        else:
            print(f"Erreur API: {response_data.get('error', 'Réponse inconnue')}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Erreur réseau : {e}")
        return None

# Fonction pour gérer l'interface CLI
def main():
    while True:
        print("\n=== CLI Zabbix ===")
        print("1. Ajouter un host")
        print("2. Lister les hosts")
        print("3. Mettre à jour un host")
        print("4. Supprimer un host")
        print("5. Quitter")
        
        choice = input("Choix : ")

        if choice == "1":
            hostname = input("Nom du host : ")
            ip = input("Adresse IP du host : ")
            result = create_host(hostname, ip)
            print("Résultat :", result)

        elif choice == "2":
            hosts = get_hosts()
            if hosts:
                for host in hosts:
                    print(f"🖥️ ID: {host['hostid']}, Nom: {host['host']}, Status: {host['status']}")

        elif choice == "3":
            host_id = input("ID du host à mettre à jour : ")
            new_name = input("Nouveau nom du host : ")
            result = update_host(host_id, new_name)
            print("Résultat :", result)

        elif choice == "4":
            host_id = input("ID du host à supprimer : ")
            result = delete_host(host_id)
            print("Résultat :", result)

        elif choice == "5":
            print("Fermeture du CLI.")
            break

        else:
            print("Choix invalide, réessaie.")

if __name__ == "__main__":
    main()
