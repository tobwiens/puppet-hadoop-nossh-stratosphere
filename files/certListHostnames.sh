#!/bin/bash -x

#get all clients
nodes=$(sudo puppet cert list -all)
master=$(wget -qO- http://instance-data/latest/meta-data/local-hostname)

hadoopConfig=/etc/puppet/modules/hadoop/manifests/params.pp

#replace master hostname
sed -i 's/master.hadoop/'"$master"'/' $hadoopConfig

while true
do
	while read  entry
	do
        	
        	if [[ $entry == +* ]]
        	then
			#Extract hostname
                	hostname=$(echo $entry |sed 's/^[^\"]*"\([^\"]*\).*/\1 /')
			
			#Check if hostname is contained
                	if ! grep -q $hostname "$hadoopConfig"
                	then
				#Add hostname to config file
                        	echo "$hostname added to $hadoopConfig"
 				sed -i 's/slave01.hadoop/'"$hostname"'","slave01.hadoop/' $hadoopConfig
                	fi
        	fi

	done < <(sudo puppet cert list -all)
	sleep 120 #Sleep for 2 minutes
done

