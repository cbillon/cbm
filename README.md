# Codebase Manager 

CodeBase Manager est un outil en ligne de commande pour installer les plugins Moodle via Git (sans utiliser les commades git submodules).
Il s'agit de construire une base de code à partir d'une version de Moodle et d'y intégrer une liste de plugins.
L'outil est un script bash qui fonctionne dans un environnement Linux.

Vous décrivez la configuration souhaitée dans un fichier au format yaml:

```bash

  moodle:
    version: 4.5+

  plugins:
    moodle-report_benchmark:
      source: https://github.com/mikasmart/moodle-report_benchmark
      branch: master        
    moodle-filter_filtercodes:
      source: https://github.com/michael-milette/moodle-filter_filtercodes
      branch: master
      version: v2.6.1

```    
Ce fichier définit l'état de la base de code .

![Boucle de controle](./docs/pictures/Reconcialiation.png) 

Le script construit pour chaque projet une base de code conforme à l'état demandé.
En cas de modifications (mise à jour de Moodle, ajout d'un nouveau plugin, mise à jour d'un plugin,.. ) le script met à jour la base de code à jour pour obtenir le nouvel état demandé. 

L'utilisation de git permet de gérer un historique de la base de code :
- son état initial
- son évolution (historique des versions)

Cela permet de recréer à l'identique un état antérieur de la base de code.

Pour démarrer un tutoriel se trouve [ici](docs/tutorials/Getting-started.md) 

# Organisation du projet

## La documentation se trouve dans le répertoire **docs** :

- tutorials : pour démarrer
- how-to-guides: comment faire 
- reference : document de référence sur les paramètres
- explanations: documents sur des sujets relatifs au projet