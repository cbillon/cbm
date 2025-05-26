
Le fichier de configuration comprend 3 parties:
1. le nom du projet
2. la version de Moodle
3. la liste des plugins

## Nom du projet
La plateforme peut gérer plusieurs instances de base de code 
Le nom du projet est unique.

## Version Moodle

La version de Moodle est composée de 2 ou 3 chiffres : par exemple 4.4.1

Les 2 premiers chiffres indiquent la version majeure.
A chaque version majeure correspond une branche git spécifique.
Les versions majeures peuvent comprendre des pre requis techniques qui ont changé par rapport aux versions précédentes (version minimum de php par exemple).
Les versions majeures peuvent comporter des modifications d'API Moodle et/ou de structure des tables de la base données, qui peuvent empêcher un plugin de s'exécuter.
Les versions mineures peuvent des modifications (nouvelles fonctions pr exemple) mais ne comportent pas de modifications qui introduisent des ruptures de fonctionnement. 
A chaque livraison d'une version mineure le dernier chiffre est incrementé: 4.4.1, 4.4.2, ...
des corrections sont livrées chaque semaine par Moodle HQ, mais des tests globaux de non régression sont seulement effectués lors des livraisons de nouvelles versions mineures.   

Le paramètre version est renseigné de la façon suivante:

| Version         | Source obtenu                                     
| --------------- | --------------------------------------------- 
| `4.4`           | derniere version  releasée dans la branche  (ici 4.4)
| `4.4+`          | derniere mise à jour de la barnche : derniere release + fixes
| `4.4.3`         | version spécifique       
| `v4.4.4.2`      | version spécifique : tag                      
| `b097840`       | version spéfique : hash            

## Version des plugins 

Les parametres suivants sont  obligatoires :

```
moodle-filter_filtercodes: <-  nom du plugin
    source: url du depot git du plugin 
    branch: master         <-  branche du dépot

```

***Attention à respecter l'indentation***

Le nom du plugin à indiquer est le nom complet selon la régle [franken style](https://moodle.org/mod/glossary/showentry.php?eid=10113&displayformat=dictionary)

### les parametres optionnels:

- version

par défaut on récupère la dernière version commitée dans la branche indiquée.
si on souhaite une version spécifique on l'indique avec le paramètre version suivi d'un tag ou d'un hash   

- localdev

permet de gérer en local une version personnalisée du plugin avec une branche locale 

## Ordre de priorité de prise en compte des parametres de version

 1. localdev
 2. version
 3. branch
