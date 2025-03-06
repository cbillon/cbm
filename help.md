
Le fichier de configuration comprend 2 parties:

1. la version de Moodle
2. la liste des plugins

## Version Moodle

La version de Moodle est composée de 3 chiffres: par exemple 4.4.1

Les 2 premiers chiffres indiquent la version majeure.
A chaque version majeure correspond une branche git spécifique
Les versions majeures peuvent comprendre des pre requis techniques qui ont chnage par rapport aux versions précédentes (version minimum de php par exemple).
Les versions majeures peuvent comporter des modifications d'API Moodle et/ou de structure des taables de la base données , qui peuvent empecher un plugin de s'éxécuter.
Les versions mineures peuvent des modififications (nouvelles fonctions pr exemple) mais ne comportent pas de modification qui introduire des rupture de fonctionnement des plugins 
A chaque livraison d'une version mineure le dernier chiffre est incrementé: 4.4.1, 4.4.2, ...
des corrections sont livrées chaque semaine; mais des tests globaux de non régression sont seulement effectués lors des livraisons de versions mineures.   
Le paramétre version est renseigné de la façon suivante:

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

par défaut on récupere la derniere version commitée dans la branche indiquée.
si on souhaite une version spécifique on l'indique avec le parametre version suivi d'un tag ou d'un hash   

- localdev

permet de gérer en local une version personnalisée du plugin avec une branche locale 

## Ordre de priorité de prise en compte des parametres de version

 1. localdev
 2. version
 3. branch

Les options du Menu


