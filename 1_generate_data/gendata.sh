#!/bin/bash

if [[ -f websites-out.dat ]]
then
    rm websites-out.dat
    echo websites-out.dat found and deleted
fi

n=1
for i in $(awk -F ' ' '{print $2}' websites-in.dat | tr '\n' ' ')
do
    # Find the IP addresses associated with the ith website:
    digs=$(dig $i | sed -n '/^;; ANSWER SECTION:/,/^$/p' | grep -v CNAME \
        | sed '1d' | tr -s '[:blank:]' | awk -F ' ' '{print $5}' \
        | tr '\n' ' ')
    
    # For each IP address, find the geographical location
    # and the number of hops:
    for j in $digs
    do
        nhops=$(tcptraceroute $j | grep -v '*' | sed '1d' | wc -l)
        
        if [[ -n $(whois $j | grep '^City\|^city') ]]
        then
            City=$(whois $j | grep '^City\|^city' | head -1 \
                | awk '{for (i=2; i<=NF; i++) print $i}')
        else
            City='NoData'
        fi
        
        if [[ -n $(whois $j | grep '^Country\|^country') ]]
        then
            Country=$(whois $j | grep '^Country\|^country' | head -1 \
                | awk -F ' ' '{print $2}')
        else
            Country='NoData'
        fi
        
        echo $i' '$j' '$nhops' '$City' '$Country >> websites-out.dat
    done
    echo $n
    n=$(($n + 1))
done
