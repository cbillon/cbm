# Configuration environement du script

Le fichier **env.cnf** se trouve à la racine

```bash
  
  RACINE="${PWD}"
  PROJECTS_PATH="${RACINE}/projects"
  DEPOT_MODULES="${RACINE}/modules"
  MOODLE_SRC="${RACINE}/moodle"
  DEBUG=false
  MOODLE_HQ=https://github.com/moodle/moodle.git
  #MOODLE_FORK=git@github.com:cbillon/moodle-hq.git
  MOODLE_VERSION="4.5+"
  MOODLE_DEPTH=1
  MOODLE_UPDATE_ORIGIN=N
  PLUGIN_UPGRADE_AUTO=true
  DIFF_DAYS=1
  DEPLOYMENT_ENV=dev

```

## description du paramétrage

Les répertoires sources : 
- **PROJECT_PATH** contient la description des différents projets
  
  notamment le fichier de configuration du projet **nom-du-projet.yml**
- **DEPOT_MODULES** contient l'ensemble des dépots des plugins en cache
- **MOODLE_SRC** contient le dépôt git de Moodle  

## DEBUG

Pour exécuter le script en mode debug  changer DEBUG=true

## MOODLE_HQ

Dépôt Moodle HQ à partir duquel le dépôt local est créé

## MOODLE_VERSION

Valeur par défaut pour la création d'un nouvel environnement
Peut être changé au moment de la création
Les différentes valeurs possibles sont décrites [ici](conf.md)

## MODDLE_DEPTH

Lors de la création du clone du dépot Moodle cette option permet d'avoir une version limitée de l'historique et donc d'occuper un espace disque limité.

## DIFF_DAYS

Pour mettre à jour le cache des plugins (commande import plugin) le script utilise le fichier issu du répertoire officiel maintenu par Moodle HQ; le paramètre indique la fréquence de rafraichissement du fichier.

## MOODLE_UPDATE_ORIGIN
Valeur par défaut = N pas de mise à jour distante

si = Y  permet de synchroniser un dépot remote lors de la génération d 'une nouvelle version de la base de code
Le script effectue simplement une commande git push origin <nom du projet>
Il faut donc mettre à jour la configuration git du dépot Moodle

Exemple d'un dépot remote sur github
 
- créer un projet pour avoir le dépot Moodle présent en local   
- créer le dépot sur github, noter l'url du dépot
- exécuter le commandes:
  - cd cbm/moodle
  - git remote add origin <url du dépot>
  - git branch -M <nom du projet> 
  - git push -u origin <nom du projet> 





