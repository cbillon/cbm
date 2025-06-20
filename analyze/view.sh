#!/bin/bash

source fonction.sh
source code.sh 

function help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
	cat > /dev/stdout <<- END
		${0} [-a] [-c] [-d] -f: [-h] [-l] [-u]
    
		REQUIRED ARGS
    -f : function number required if -a, -c, -u
    -v : variable 
		OPTIONAL ARGS:
		
    -a  analyse decomposition function
    -c  cas d emploi	
    -d  debug default false	
		    -h  show help
    -l  list all functions
    -u  list unused functions

		EXAMPLES
    - cd analyze
		- ./view -f 10 -c
END
}

function list_all () {
  
  local i j k
  echo List of functions:    
  for i in $(seq 0 $n); do
    echo "$i" "${fonc[$i]}" $(grep -n "${fonc[$i]} ()" "$function_file" | head -n 1 | cut -d: -f1)
  done
}  

function list_unused () {
  
  echo ' '
  echo Functions not used:
  echo ' '
    
  for i in $(seq 0 $n); do
    func=${fonc[$i]}
    f="$func"
    #echo func: "$func"
    k=0
    for j in $(seq 0 $n); do
      s="${fonc[$j]}"    
      [[ "$s" != "$func" ]] && [[ "${code[$s]}" =~ "$func" ]] && k=$((k+1))  
    done
    [ "$k" -eq 0 ] && echo "$i    $f"
  done

}

function decomp () {
  local i j fn
  fn="${fonc[$1]}"  
  j=0
  for i in $(seq 0 $n);
  do
    if [[ "$fn" != "${fonc[$i]}" ]] && [[ "${code[$fn]}" =~ "${fonc[$i]}" ]];
    then
      j=$((j+1))
      echo "$j" "$i" "${fonc[$i]}" $(grep -n "${fonc[$i]} ()" "$function_file" | head -n 1 | cut -d: -f1)    
    fi
  done 
}

function cas_emploi () {

  # cas d'emploi
  echo
  echo "Cas d'emploi:" "$1" "${fonc[$1]}"
  local i j
  j=0
  for i in $(seq 0 $n);
  do      
    if [[ "$i" -ne "$1" ]] && [[ "${code["${fonc[$i]}"]}" =~ "${fonc[$1]}" ]]; then
      j=$((j+1))
      echo "$j" "$i" "${fonc[$i]}"
    fi
  done
  [ "$j" -eq 0 ] && echo function "${fonc[$1]}" not used 
}

function var_def () {
 
  local i j
  j=0
  for i in $(seq 0 $n);
  do      
    if [[ "${code["${fonc[$i]}"]}" =~ "$var"= ]]; then
      j=$((j+1))
      echo "$j" defined in "$i" "${fonc[$i]}" $(grep -n "${fonc[$i]} ()" "$function_file" | head -n 1 | cut -d: -f1)
    fi
  done
  echo ''
  for i in $(seq 0 $n);
  do      
    if [[ "${code["${fonc[$i]}"]}" =~ "$var" ]]; then
      j=$((j+1))
      echo "$j" used by "$i" "${fonc[$i]}" $(grep -n "${fonc[$i]} ()" "$function_file" | head -n 1 | cut -d: -f1)
    fi
  done
  
  [ "$j" -eq 0 ] && echo var "${var}" not used 

}

# while loop, and getopts
DEBUG=false
ia=false
ic=false
if=0
source=false
list_all=false
list_unused=false
function_file='../includes/functions.cfg'

while getopts "h?acdf:lsuv:" opt
do
	# case statement
	case "${opt}" in
	  h|\?)
		  help
		  exit 0 ;;
    a) ia=true ;;
    c) ic=true ;;
	  d) DEBUG=true ;;
	  f) ifn=${OPTARG} ;;
    l) list_all=true ;;
    s) source=true ;;
    u) list_unused=true ;;
    v) var=${OPTARG} ;;
	esac
done


# number of function in array
n=$((${#fonc[@]}-1))
[[ -z "${fonc["$ifn"]}" ]] && echo valeur incorrecte "$ifn" && exit 1

msg=''
if [ -n "$ifn" ]; then
  msg+="$ifn" 
  msg+=" ${fonc[$ifn]} "
  msg+=$(grep -n "${fonc[$ifn]} ()" $function_file | head -n 1 | cut -d: -f1)
fi
[ "$ia" = true ] && msg+=" -a: Analyze"
[ "$ic" = true ] && msg+=" -c: Cas d'emploi"
[ "$DEBUG" = true ] && msg+=" -d: debug"
[ "$list_all" = true ] && msg+=" -l: List all functions"
[ "$source" = true ] && msg+=" -s: Source"
[ "$list_unused" = true ] && msg+=" -u: List unused functions"
[ -n "$var" ] && msg+=" -v $var"

echo "$msg"
echo
[ "$source" = true ] && echo "${code[${fonc["$ifn"]}]}"
[ "$ia" = true ] && decomp "$ifn"
[ "$ic" = true ] && cas_emploi "$ifn"
[ "$list_all" = true ] && list_all
[ "$list_unused" = true ] && list_unused
[ -n "$var" ] && var_def
echo ''
echo "That's All!"