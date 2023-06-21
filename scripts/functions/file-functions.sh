#! /bin/bash
suffix=_TO_REPLACE
function file-replace-variables {
    # suffix=$(or $(SUFFIX), _TO_REPLACE)
    FILE=$1
    # find any strings in file with suffix (eg _TO_REPLACE)
    for str in $(cat $FILE | grep -Eo "\$\{[A-Za-z0-9_]*${suffix}\}|\$[A-Za-z0-9_]*${suffix}|[A-Za-z0-9_]*${suffix}" | sed 's/\$$//g' | sed 's/{//g' | sed 's/}//g' | sort | uniq); do
        # set key = to that string minus the suffix
        key=$(echo $str | sed "s/$suffix//g")
        # value=$(echo $(eval echo $key))
        # set value = the previously exported variable with the name that matches key
        eval value=\$$key
        if [ -z "$value" ]; then
          echo "WARNING: Variable $key has no value set"
        fi
        if [ -n "$value" ] ; then
          # Replace `${VARIABLE_TO_REPLACE}`
          # sed -i "s;\${$key$suffix};$value//&/\\&};g" "$FILE"
          # # Replace `$VARIABLE_TO_REPLACE`
          # sed -i "s;\$$$$key$${suffix};$value//&/\\&};g" "$FILE"
          # # Replace `VARIABLE_TO_REPLACE`
          sed -i "s;$key$suffix;$value;g" "$FILE"
        fi
    done
}

function file-replace-variables-in-dir {
    DIR=$1
    files=($(find $DIR -type f -exec grep -Il '.' {} \; | xargs -L 1 echo))
    for file in "${files[@]}"; do
      echo Replacing variables in file $file
      file-replace-variables "$file"
    done
}
