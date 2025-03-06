# Moodle version

Les sources Moodle sont disponibles soit comme archive .tar.gz soit à partir d'un dépot git.
Nous n'utiliserons que les dépots git [voir choix_architecture](choix_architecture.md)

Chaque version de Moodle comporte 3 nombres: par exemple 4.5.1

Moodle suit à sa maniere les régles de [versionnage semantique](versionnage_semantique.md)
Les 2 premiers nombres d'une version correspondent à une version majeure.

Lors d'une nouvelle version majeure il y a probablement des modifications non retro compatibles :
- changement d'API
- modification du schema de la base de données
- versions de php supportées
- ...

Une version majeure est associée à une branche du dépôt source : 4.5.x -> MOODLE_405_STABLE
Les versions mineures n'introduisent pas de rupture de compatibilité.
dans notre cas, un plugin fonctionnant avec une version de Moodle doit fonctionner avec toutes les version mineures successives.

[voir article de Michael Milette](https://www.tngconsulting.ca/should-i-upgrade-update-moodle/
)

A partir d'Avril 2025, l'introduction de la notion de **series** va conforter tout cela ; voir [Matt Porrit](https://moodle.org/mod/forum/discuss.php?d=457946)