#!/bin/bash
echo param: "$1"
source fonction.sh
#declare -a fonc=($(cat fonc.txt))
n=${#fonc[@]}
n=$((n-1))
echo n: $n
for i in $(seq 0 $n);
do
  echo $i ${fonc[$i]}
done

func=${fonc["$1"]}
echo Cas d emploi Param: "$1" $func

source code.sh

# cas d'emploi
emploi=()
for i in $(seq 0 $n);
do
  s="${fonc[$i]}"
  if [[ "$s" != "$func" ]] && [[ "${code[$s]}" =~ "$func" ]];
  then
    emploi+=("$s")
  fi
done

echo "Cas d'emploi:"

n="${#emploi[@]}"
n=$((n-1))
for i in $(seq 0 "$n");
do
  echo "$i" "${emploi[$i]}"
done

s="${fonc[$1]}"
echo decomposition Param : "$1" "$s"
decomp=()
for i in $(seq 0 $n);
do
  if [[ "${code[$s]}" =~ "${fonc[$i]}" ]];
  then
    decomp+=("${fonc[$i]}")
  fi
done

echo Decomposition: 

n="${#decomp[@]}"
n=$((n-1))
for i in $(seq 0 "$n");
do
   echo "$i" "${decomp[$i]}"
done 

echo "That's All!"
