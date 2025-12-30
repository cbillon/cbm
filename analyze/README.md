# Analyze

L'application Code Base Manager utilise un ensemble de fonctions qui sont contenues dans **includes/functions.cfg**.

L'outil d'analyse permet l'exploration de l'ensemble de ces fonctions. 

L'analyse nécessite 2 étapes :

- ./build.sh construction de deux tableaux
- ./view.sh permet l'analyse

## Liste des fonctions disponibles

La commande view a les options suivantes :

  - a analyse
  - c cas d'emploi
  - d mode debug
  - l liste de l'ensemble des fonctions
  - u fonctions non utilisées (mais utiles !)

  -f désigne la fonction sur laquelle porte l'analyse 
  -v nom de variable definition et cas d'utilisation

### Build

Lancement: **./build.sh**

La fonction construit deux tableaux :

- fonction.sh contient l'ensemble des fonctions.
- code.sh contient le code de chaque fonction.

Le tableau fonction.sh comporte le no de ligne de l'emplacement de la fonction dans functions.cfg

### View

Permet l'exploration de l'ensemble de fonctions.

Lancement: **./view.sh**

Pour obtenir de l'aide ./view.sh -h

### Analyse

L'analyse  liste les fonctions appelées par une fonction

  **./view.sh -a -f xx**  xx étant le no de la fonction.

### Cas d'emploi

Le cas d'emploi liste les fonctions qui appelle cette fonction

  **./view.sh -c -f xx**  xx étant le no de la fonction.

### Code source

Affichage du code source de la fonction : **./view.sh -s -f xx**  xx étant le no de la fonction.

### List all

Liste l'ensemble des fonctions :  **./view.sh -l**
comprend :
- le numéro de la fonction qui sera utilisée dans les différents appels (-a, -c, -u)
- le no de ligne de l'emplacement de la fonction dans functions.cfg

### Fonctions non utilisées

Liste les fonctions non utilisées : **./view.sh -u**

Cela correspond aux fonctions point d'entrée du menu et aux fonctions réellement non utilisées.

### Variable

correspond à l'option **-v var**

Liste la fonction où la variable est définie et dans quelle(s) fonction(s) elle est utilisée.