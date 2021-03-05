#!/bin/bash
ENV=/root/.bashrc

DAY=$(date +%e)
echo "$DAY"
if [ $DAY = "5" ]; then
	 echo "hello!"
else
	 echo "no("
fi
