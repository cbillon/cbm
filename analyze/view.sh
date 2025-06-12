#!/bin/bash

source fonction.sh
source code.sh 
function_file='../includes/functions.cfg'

n=${#fonc[@]}
n=$((n-1))
if [[ -z "$1" ]];
then
  echo List of functions:    
  for i in $(seq 0 $n);
  do
    f=${fonc[$i]}
    echo "$i" "$f" $(grep -n "$f ()" "$function_file" | head -n 1 | cut -d: -f1)
  done
  echo ' '
  echo Functions not used:
  echo ' '
  for i in $(seq 0 $n);
  do
    func=${fonc[$i]}
    f="$func"
    #echo func: "$func"
    k=0
    for j in $(seq 0 $n);
    do
      s="${fonc[$j]}"    
      [[ "$s" != "$func" ]] && [[ "${code[$s]}" =~ "$func" ]] && k=$((k+1))  
    done
    [ "$k" -eq 0 ] && echo "   $f"
    
  done

else
  
  func=${fonc["$1"]}
  [[ -z "$func" ]] && echo valeur incorrecte "$1" && exit 1
  echo Analyze: "$1" "$func"
  
  # cas d'emploi
  echo
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
  [ "$j" -eq 0 ] && echo function "$func" not used 
 
  s="${fonc[$1]}"
  echo
  echo Decomposition
  j=0
  decomp=()
  for i in $(seq 0 $n);
  do
    if [[ "$func" != "${fonc[$i]}" ]] && [[ "${code[$s]}" =~ "${fonc[$i]}" ]];
    then
      j=$((j+1))
      echo "$j" "${fonc[$i]}"     
    fi
  done 
  
  echo ' '
  func=${fonc["$1"]}
  echo Source "$func"
  echo "${code[$func]}"

fi
echo ''
echo "That's All!"
