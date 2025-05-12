#!/bin/bash

declare -A a
declare -A code

str=$(cat ../includes/functions.cfg)
#str='  function toto () { echo Coucou } '
l=${#str}
echo length : $l
fonc=()
regexp='^.*function +(.*) +\(\) +\{ *(.*)\}.*$'
cond=true
n=0
while [ $cond = 'true' ];
do
  if [[ ${str:0:$l} =~ $regexp ]];
  then
    fonc=${BASH_REMATCH[1]}
    a["$n"]="$fonc"
    code[$fonc]="${BASH_REMATCH[2]}"
    n=$((n+1))
    
    search="function ${BASH_REMATCH[1]}"
    prefix=${str%%$search*}
    l=${#prefix}
  else
    cond=false
  fi
done
fonc=( $( for x in ${a[@]}; do echo $x; done | sort ) )
nb=${#fonc[@]}
nb=$((nb-1))
for i in $(seq 0 $nb);
do
  echo $i ${fonc[$i]}
done

#echo ${fonc[@]} > fonc.txt
declare -p fonc > fonction.sh

echo nb: ${#code[@]}
declare -p code > code.sh

echo "That's All!"
