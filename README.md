# POZOS — Docker Infrastructure POC

Projet réalisé par **Dakin Blair** dans le cadre d'un examen pratique sur la gestion d'infrastructure Docker.

## Contexte

POZOS est une entreprise fictive qui développe des logiciels pour les lycées. L'objectif était de dockeriser une application existante (student_list) composée d'une API Flask et d'un site PHP, d'orchestrer le tout avec docker-compose, et de déployer un registre Docker privé.

```
Navigateur ──▶ website (php:apache, :80) ──▶ api (Flask, :5000)
                        │                          │
                        └──────── pozos-network ────┘

docker push/pull ──▶ registry (:5001) ◀── registry-ui (:8081)
```

## Ma démarche et les obstacles rencontrés

J'ai d'abord voulu travailler avec une VM Ubuntu provisionnée via **Vagrant et VirtualBox** (Vagrantfile et provision.sh), comme le suggérait l'énoncé. J'ai réussi à créer la VM, installer Docker dedans et builder l'API, mais j'ai rencontré une série de blocages que je n'ai pas pu résoudre moi-même :

- **Conflit avec Hyper-V** : mon Surface Laptop 5 est un "Secured-core PC" avec Hyper-V actif par défaut, ce qui faisait planter le noyau Linux de la VM (erreur rcu_sched self-detected stall on CPU).
- **Memory Integrity (Core Isolation)** : désactiver Hyper-V via bcdedit n'a pas suffi, Windows réactivait la virtualisation via cette protection.
- **VBS imposée par politique d'entreprise** : même après ces désactivations, msinfo32 montrait toujours que la virtualization-based security était active. Ma machine (Surface Laptop 5 for Business, avec App Control for Business imposé) est gérée par une politique MDM qui réimpose ces protections — je n'avais pas les droits pour la désactiver durablement.
- **Guest Additions manquantes** après un changement de box Vagrant, cassant le dossier partagé /vagrant (corrigé en réinstallant les paquets virtualbox-guest-utils et dkms).

Après ces blocages indépendants de ma volonté, j'ai basculé sur **Docker Desktop avec WSL2**, déjà installé sur ma machine. L'énoncé demande une seule machine avec Docker installé, ce que WSL2 remplit sans entrer en conflit avec la virtualisation Windows. J'ai refait tous mes tests et déploiements finaux depuis cet environnement.

## 1. Build and test — API

Dans mon Dockerfile (dossier simple_api), je pars de l'image python:3.11-slim, j'installe les dépendances système nécessaires à la compilation de flask_simpleldap (gcc, build-essential, libldap2-dev, libsasl2-dev, libssl-dev), et je monte student_age.json en volume plutôt que de le copier dans l'image.

![Build et test de l'API](images/01-build-api.png)

Commande de test :

```bash
curl -u toto:python -X GET http://localhost:5000/pozos/api/v1.0/get_student_ages
```

## 2. Infrastructure as Code — docker-compose

Mon docker-compose.yml orchestre les services api et website sur un réseau dédié (pozos-network), ce qui permet au site d'joindre l'API via son nom de service plutôt que par IP.

![Site web avec liste des étudiants](images/02-website-list.png)

## 3. Docker Registry

J'ai ajouté un registre privé (image registry:2) et son interface web (joxit/docker-registry-ui). J'ai dû configurer des en-têtes CORS sur le service registry pour que l'interface, exécutée dans le navigateur, puisse interroger le registre sans être bloquée.

```bash
docker tag student-list-api localhost:5001/student-list-api
docker push localhost:5001/student-list-api
```

![Push de l'image](images/03-docker-push.png)

![Interface du registre](images/04-registry-ui.png)

## Structure du dépôt

```
pozos/
├── README.md
├── docker-compose.yml
├── simple_api/
│   ├── Dockerfile
│   ├── student_age.py
│   ├── requirements.txt
│   └── student_age.json
├── website/
│   └── index.php
├── Vagrantfile
├── provision.sh
└── images/
```

## Lancer le projet

```bash
docker build -t student-list-api ./simple_api
docker compose up -d
```

- Site web : http://localhost:80
- API : http://localhost:5000/pozos/api/v1.0/get_student_ages
- Registre : http://localhost:5001/v2/_catalog
- Interface registre : http://localhost:8081
