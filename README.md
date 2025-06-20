# Codebase Manager 

**CodeBase Manager** est un outil en ligne de commande pour gérer un projet Moodle avec Git.

L'outil est un script qui fonctionne dans un environnement Linux.

Vous décrivez la configuration souhaitée dans un fichier au format yaml:

```
  project:
    name: demo
    branch: demo

  moodle:
    version: 4.5+

  plugins:
    moodle-filter_filtercodes:      

    moodle-mod_attendance:

```    
## Principe de fonctionnement 

Le fichier de configuration définit l'état demandé de la base de code.
Les informations concernant le dépôt des sources, la version des plugins sont récupérées depuis le
[répertoire officiel des plugins](https://moodle.org/plugins).
L'outil sélectionne une version du plugin compatible avec la version de Moodle.

### Fonctionnement 

Un fichier unique de configuration définit l'***état demandé***

![Boucle de controle](./docs/pictures/Boucle_de_controle.png) 

Le script observe l'***état courant*** et si il est différent de l'***état demandé***, il y a génèration d'une nouvelle base de code. 

### Git 

Le fait de tout gérer sous git présente plusieurs avantages :

- automatisation des tâches : installation des plugins, des montées de version mineures de Moodle 
- conservation d'un historique des mises à jour:
  - documentation automatique de ce qui est installé
  - possibilité de restoration d'un état antérieur

Nota: pour faire simple, on n'utilise pas les fonctions git submodules. 

## Pour démarrer

Les informations nécessaires pour démarrer se trouvent [ici](docs/tutorials/Getting-started.md) 

La documentation se trouve dans le répertoire **docs** :

- tutorials : pour démarrer
- how-to-guides: comment faire 
- reference : document de référence sur les commandes
- discussions: documents sur des sujets relatifs au projet