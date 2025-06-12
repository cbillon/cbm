# CodeBase Manager

CodeBase Manager est outil en ligne de commande pour déployer Moodle avec une liste de plugins via git (mais sans utiliser git submodules)

## why?

Actuellement :
- mise à jour manuelle de Moodle fastidieuse 
- pas de possibilité d'installer une liste de plugins
- difficile de gérer plusieurs projets en partageant les sources (factorisation du code) 
- manque un historique des mises à jour
- difficile de retrouver un état antérieur

## how ?

En mode déclaratif,
en utilisant un unique fichier de configuration.

Le fichier de configuration décrit l'**état demandé** de la base de code :
- version Moodle
- des plugins

L'outil a pour fonction de réconcilier l'**état observé** de la base de code avec l'**état demandé** en générant, si nécessaire une nouvelle version.

L'outil comprend 2 parties :
- une mise en cache des sources de Moodle et des plugins
- la génération d'une base de code

## utilisation de git

Utilisation de git comme source de vérité pour Moodle et pour les plugins
Git nous fournit un moyen simple pour :
- définir un état du code source grâce aux notions de branche, tag, ou commit
- tracer les changements
- revenir à un état antérieur 

L'usage de git pour les mises à jour réduit le temps des opérations de mises à jour d'heures en minutes.

## Cas d'usage :

Les principaux cas d'usage: 

- installation d'une liste de plugins
- mise à jour suite à une nouvelle version de Moodle
- mise à jour suite à une nouvelle version d'un plugin

### Installation d'une liste de plugins

le tutorial reprend ce cas d'usage  [voir](../tutorials/Getting-started)





 









