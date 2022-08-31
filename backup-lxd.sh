#!/usr/bin/bash
# Shell script to backup required LXD parts ##

## Backup and restore LXD config ##
## Today's date ##
NOW=$(date +'%Y-%m-%d')
DELBAK=$(date +%Y-%m-%d -d "10day ago")

backupdir=/mnt/nfs/lxd-backup/$NOW
mkdir $backupdir
 
## Dump LXD server config ##
echo "Dumping LXD server config"
/snap/bin/lxd init --dump > "${backupdir}/lxd.config"

## Dump all instances list ##
echo "Dump all instances list"
/snap/bin/lxc list > "${backupdir}/lxd.instances.list"
 
## Make sure we know LXD version too ##
echo "Getting LXD version"
snap list lxd >"${backupdir}/lxd-version"
 
#Shutdown running instances and back them up to NFS server
/snap/bin/lxc list --format=json | /usr/bin/jq -r '.[] | select(.state.status == "Running") | .name' > t.txt
for i in $(cat t.txt)
  do
    echo "Stopping running instance $i"
    /snap/bin/lxc stop $i
    echo "Making backup of $i ..."
    /snap/bin/lxc export "${i}" "${backupdir}/${i}.tar.gz"
    echo "Starting instance $i"
    /snap/bin/lxc start $i
    sleep 20
  done

#Backup instances that are not running to NFS server
/snap/bin/lxc list --format=json | /usr/bin/jq -r '.[] | select(.state.status == "Stopped") | .name' > t.txt
for i in $(cat t.txt)
  do
    echo "Making backup of offline instance $i ..."
    /snap/bin/lxc export "${i}" "${backupdir}/${i}.tar.gz"
  done
echo ""
echo ""
echo "Backup Complete"
rm t.txt
rm -rf /mnt/nfs/lxd-backup/$DELBAK
