#!/bin/bash

version=""
while read -r line
do
	version=${line: -6};
done < $1/scripts/build-stamp.txt

echo $version
