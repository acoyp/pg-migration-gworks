#!/bin/bash

input='delta.sql'
prefix="-- "
i=0
l=0
while read -r line
do 
  if [[ "$line" == *match ]]
  then
    ((i=i+1))
    #echo "$line"
  fi
  if [[ "$line" == "$prefix"* ]]
  then
    ((l=l+1))
    #echo "$line"
  fi
done < "$input"
if ((l - i == 0)); then
  echo 'YES'
else
  echo 'NO'
fi

