# CodeBase Composer

CodeBase Composer est outil en ligne de commande pour déployer Moodle avec une liste de plugins via git (mais sans utiliser git submodules)

## why?

Actuellement :
- mise à jour manuelle de Moodle fastidieuse
- pas de possibilité d'installer facilement une liste de plugins
- difficile de gérer plusieurs projets en partageant les sources (factorisation du code) 

## how ?

En mode déclaratif,
en utilisant un unique fichier de configuration.

Le fichier de configuration décrit l'**état demandé** de la base de code :
- version Moodle
- la liste de plugins

L'outil a pour fonction de réconcilier l'**état observé** de la base de code avec l'**état demandé** en générant si nécessaire une nouvelle version.

L'outils comprend 2 parties:
- une mise en cache des sources de Moodle et des plugins
- la génération d'une base de code

## utilisation de git

Utilisation de git comme source de vérité pour Moodle et pour les plugins
Git nous fournit un moyen simple pour :
- définir un état du code source : branche, tag, commit
- tracer les changements
- revenir à un état antérieur 

L'usage de git pour les mises à jour réduit le temps des opérations d'heures en minutes.

## Cas d'usage :






 









