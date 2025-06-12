# Configuration environement du script

Le fichier **env.cnf** se trouve à la racine du produit

```bash
  
# Update and save file

RACINE="${PWD}"
PROJECTS_PATH="${RACINE}/projects"
DEPOT_MODULES="${RACINE}/modules"
MOODLE_SRC="${RACINE}/moodle"
MOODLE_HQ=https://github.com/moodle/moodle.git
MOODLE_DEPOT="$MOODLE_HQ"
#MOODLE_FORK=git@github.com:cbillon/moodle-hq.git
MOODLE_VERSION_DEFAULT="5.0+"
#MOODLE_UPDATE_ORIGIN=
LANG=fr
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

Pour exécuter le script en mode debug  au lancement ./cbm -d

## MOODLE_DEPTH

si MOODLE_DEPTH=1 l'historique des commits n'est pas recopié
pro: taille réduite du dépot
cons: 
- l'option MOODLE_VERSION doit etre de la forme 4.5+
- ne permet pas d'avoir d'autres branches 
- ne permet de faire une copie du depot (git clone)

## MOODLE_HQ

Dépôt Moodle HQ à partir duquel le dépôt local est créé

## MOODLE_VERSION

Valeur par défaut pour la création d'un nouvel environnement
Peut être changé au moment de la création
Les différentes valeurs possibles sont décrites [ici](conf.md)

## DIFF_DAYS

Pour mettre à jour le cache des plugins (commande import plugin) le script utilise le fichier issu du répertoire officiel maintenu par Moodle HQ; le paramètre indique la fréquence de rafraichissement du fichier.

## MOODLE_UPDATE_ORIGIN
Valeur par défaut : non definie  pas de mise à jour distante

si = url dépôt github accessible en écriture 
Lors de la livraison d'une nouvelle version de la base de code, le depot distant est synchroniser avec le depot local.

Pour activer l'option se synchronisation :
- de commenter la ligne 
- renseignée l'url du depot distant

Le script effectue simplement une commande git push origin <nom du projet>

Pour effectuer manuellement l'opération :
Exemple d'un dépot remote sur github
 
- créer un projet pour avoir le dépot Moodle présent en local   
- créer le dépot sur github, noter l'url du dépot
