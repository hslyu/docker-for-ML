#!/usr/bin/bash

for ID in $(cat /etc/passwd | grep /home | cut -d ':' -f1)
do
	sudo usermod -aG docker $ID
done
