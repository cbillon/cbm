#!/bin/bash
# jq -r '[.versions[]| {(.version) : (.supportedmoodles[].release)}]' tmp.json | grep  4.0 | sort -nr | grep -E -o  "([0-9]{10})" | cut -f 1 -d "
# "
# jq -r '.versions[] | select(.version == "2022040100")|.downloadurl' tmp.json

# # filter plugins
# jq -r '.plugins[]|.component' pluglist.json | grep -E mod | sort

# \$plugin\->version += +([0-9]{10});
version="2018072708"
> ~/cbm/plugins.txt
cd modules/block_gps
git checkout master --quiet
git log | grep "commit"|cut -d " " -f 2 > ~/cbm/plugins.txt
while IFS= read -r line; do
    echo "Commit: $line"
    git checkout "$line" --quiet
    ok=$(cat version.php | grep -E "plugin.+version"| grep "$version")
    echo ? $ok 
    # if [[ ! -z $ok ]]; then
    #  echo Bingo ! "$line" "$version"
    # fi
    # if [[ $test =~  ]]; then
    #   echo on y passe
    #   version=${BASH_REMATCH[0]}
    #   echo version "$version"
    # fi

   # process as before

done < ~/cbm/plugins.txt
#echo plugins | grep "commit"|cut -d " " -f 2

exit 

## loop through above array
# for i in "${arr[@]}"
# do
#    echo "$i"
#    # or do whatever with individual element of array
# done

# You can access them using echo "${arr[0]}", "${arr[1]}" 

#strings=("$plugins")
for i in "${plugins[@]}"; do
    echo sha1 "$i" 
done