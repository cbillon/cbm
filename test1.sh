#!/bin/bash
# ----------------------------------------------
nomlogiciel=`basename "$0"`	
# FONCTION :	apprendre les scripts et zenity
VERSION="alpha"
# NOTES DE VERSIONS
echo "
--------------------------------------------------------------
ce script crée un fichier journal avec un .log
les fonction _journal et journal
un appel de journal fonctionnera comme echo

_initialisation porte bien son nom
il est lancé avant main

_main
la boucle permet de relancer l'interface principale 
chaque fois qu'une action est terminée

frm_principale
lance zenity et retournera le numéro de ligne sélectionnée

frm_principale_parser
effectuera une action selon la réponse donnée par frm_principale

_quitter
permet de fermer plus proprement son application
--------------------------------------------------------------
"
# ----------------------------------------------
# à mettre au début d'un fichier bash
# pas encore géré
PID=$$
FIFO=/tmp/FIFO${PID}
mkfifo ${FIFO}
# ----------------------------------------------
echo "lancement $nomlogiciel..."

function _journal {
	fichier_log="$nomlogiciel.log"

	if [ -f "$fichier_log" ];
	then
		echo "..."
	else
		echo "Création du fichier de log : $fichier_log"
		touch "$fichier_log";
	fi
	# tail 
}
echo "ouverture du journal"
_journal

function journal {
	echo "$@" >> $fichier_log	
	# echo "$@"
}

function _initialisation {
journal "*******************initialisation*******************"
journal "VARIABLES PERMANENTES"


journal "VARIABLES TEMP"

}

function _quitter {
journal "_quitter"
# mettre ici tout ce qui sera nescessaire à la bonne fermeture

	exit 0
}

function frm_principale {
journal "*******************frm_principale*******************"

LAQUESTION="
---------------------------------------------------------------------
Ce module crée une liste de choix

Tout à faire - <b>pas encore codé</b>"

	local KA="Choix 1"
	local KB="Choix 2"
	local KC="Choix 3"
	local KD="Choix 4"
	local KE="Choix 5"
	local KF="Choix 6"
	local KG="Choix 7"
	local KH="Choix 8"
	local KI="Choix 9"

	local VA="Valeur 1"
	local VB="Valeur 2"
	local VC="Valeur 3"
	local VD="Valeur 4"
	local VE="Valeur 5"
	local VF="Valeur 6"
	local VG="Valeur 7"
	local VH="Valeur 8"
	local VI="Valeur 9"
	
	echo `zenity --list --width=600 --height=450 --text="$LAQUESTION" \
	--ok-label="Sélectionner" \
	--cancel-label="quitter" \
	--hide-column 1 --column "" --column "choix" --column "Valeur" \
	1 "$KA" "$VA" \
	2 "$KB" "$VB" \
	0 "" "on peut facilement mettre des blancs" \
	3 "$KC" "$VC" \
	4 "$KD" "$VD" \
	5 "$KE" "$VE" \
	6 "$KF" "$VF" \
	7 "$KG" "$VG" \
	0 "" "" \
	8 "$KH" "$VH" \
	9 "$KI" "$VI" \
	`
}

function frm_principale_parser {
journal "*******************frm_principale_parser*******************"
journal "frm_principale_parser : $1"

	case $1 in	
		1) action 1 ;;
		2) action 2 ;;
		3) action 3 ;;
		4) action 4 ;;
		5) action 5 ;;
		6) action 6 ;;
		7) action 7 ;;
		8) action 8 ;;
		9) 
			fonction_test
			;;
		0) 
			echo ""
			;;
		
		*) 
			quitter="1"
			_quitter ;;
	esac

}

function action {
	zenity --info --text="vous avez choisi action $1 \n ... choisissez le 9 !"
}

function fonction_test {
	message="$(date)
	On peut mettre ce que l'on veut ici"
	echo "$message"
	zenity --info --text="$message"
}

function _main {
journal "_main"	
	menuchoice=$(frm_principale);	
	frm_principale_parser ${menuchoice%|*} # pour corriger le 1|1
	
	if [ $quitter!="1" ] ; then
		# on boucle tant que quitter est différent de 1
		# pas de else car pas nescessaire ;°)
		_main
	fi
}

#-initialisation
_initialisation
_main

exit 0