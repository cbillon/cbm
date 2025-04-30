#!/bin/bash

source fonction.sh
#declare -a fonc=($(cat fonc.txt))
n=${#fonc[@]}
n=$((n-1))
if [[ -z "$1" ]];
then
  echo Liste des fonctions:    
  for i in $(seq 0 $n);
  do
    echo $i ${fonc[$i]}
  done
else
  
  func=${fonc["$1"]}
  [[ -z "$func" ]] && echo valeur incorrecte "$1" && exit 1
  echo Analyze: "$1" "$func"
  source code.sh 

  # cas d'emploi
  echo "Cas d'emploi:"
  emploi=()
  j=0
  for i in $(seq 0 $n);
  do
    s="${fonc[$i]}"    
    if [[ "$s" != "$func" ]] && [[ "${code[$s]}" =~ "$func" ]];
    then
      j=$((j+1))
      echo "$j" "$s"
    fi
  done
  
  s="${fonc[$1]}"
  echo Decomposition
  j=0
  decomp=()
  for i in $(seq 0 $n);
  do
    if [[ "${code[$s]}" =~ "${fonc[$i]}" ]];
    then
      j=$((j+1))
      echo "$j" "${fonc[$i]}"     
    fi
  done 
fi
echo "That's All!"
