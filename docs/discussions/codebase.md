# Base de code (Code base)

## Définition

Le terme codebase, ou code base est utilisé en développement de logiciel pour désigner l'ensemble du code source utilisé pour construire un logiciel ou un composant. 
Dans notre cas cela comprend les sources de Moodle , avec les plugins tiers installés.
Les sources sont disponibles sous format de fichier zip ou depuis un depot git.
Les sources sont versionnés grâce à git système de gestion de versions le plus courramment utilisé.
La base de code Moodle comprend :
- les sources Moodle
- les sources des plugins

Il y a une base de code par projet, mais il y aura plusieurs déploiements de l’application dans différents environnements. 
Un déploiement est une instance en fonctionnement de l’application. C’est, par exemple, le site en production, ou bien un ou plusieurs sites de validation. 
La gestion des sources sous git permet d'avoir un historique des versions sucessives, et de reconstruire un état antérieur.

## Dépendances

La version d'un plugin à installer dépend de la version de Moodle
Ces dépendances sont décrites explicitement dans le fichier de configuration.

Le fichier de configuration définit un état des ressources
- Moodle
- les plugins

Le rôle du script est d'amener la code base à l'état demandé.

## Multi instances

Le script permet de gérer plusieurs instances de base de code d'une même version Moodle ou d'une version différente, avec pour chaque instance sa propre liste de plugins.

L'utilisation de git permet de factoriser les sources
- un depot Moodle
- un dépot de chaque plugin

## Déploiement

Le déploiement doit prendre en compte tout ce qui est spécifique et susceptible de varier entre les déploiements :
cela concerne par exemple :
- la configuration de librairies de test 
- les OS / Linux, Mac,Windows
- le type de base de données : Mysql versus Postgres
- ... 

dans le cas de Moodle ces informations sont définies par le fichier configuration config.php

En résumé le deploiement est un ensemble base de code du projet + config.php correspondant à l'environnement.
