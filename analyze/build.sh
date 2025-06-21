#!/bin/bash

declare -A a
declare -A code
function_file='../includes/functions.cfg'
debug="${1:-}"
regexp='^.*function +(.*) +\(\) +\{.*$'
str=$(cat "$function_file")
end=${#str}
cond=true
n=0
[ "$debug" = true ] && echo ' '>trace.txt
while [ $cond = 'true' ];
do
  if [[ ${str:0:$end} =~ $regexp ]];
  then
    n=$((n+1))
    fn=${BASH_REMATCH[1]}  
    [ "$debug" = true ] && echo debug n:"$n" "$fn"  
    a["$n"]="$fn"          
    search="function $fn "
    prefix=${str%%$search*}
    start=${#prefix}
    ln=$(($end-$start))
    a["$n"]="$fn"       
    code[$fn]="${str:$start:$ln}"
    [ "$debug" = true ] && echo debug n:"$n" "$fn" "$start" : "$end" "$ln" >>trace.txt
    #echo "  ${code[$fn]}" 
    end="$start"
    #echo nouveau prefix: "$end"
  else
    cond=false
  fi
done

fonc=( $( for x in ${a[@]}; do echo $x; done | sort ) )
nb=${#fonc[@]}
nb=$((${#fonc[@]}-1))
for i in $(seq 0 $nb);
do
  echo $i ${fonc[$i]} $(grep -n "${fonc[$i]} ()" "$function_file" | head -n 1 | cut -d: -f1)
done

declare -p fonc > fonction.sh
declare -p code > code.sh

echo "That's All!"