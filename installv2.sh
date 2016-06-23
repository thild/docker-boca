#!/bin/bash
# ////////////////////////////////////////////////////////////////////////////////
# //BOCA Online Contest Administrator
# //    Copyright (C) 2003-2014 by BOCA Development Team (bocasystem@gmail.com)
# //
# //    This program is free software: you can redistribute it and/or modify
# //    it under the terms of the GNU General Public License as published by
# //    the Free Software Foundation, either version 3 of the License, or
# //    (at your option) any later version.
# //
# //    This program is distributed in the hope that it will be useful,
# //    but WITHOUT ANY WARRANTY; without even the implied warranty of
# //    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# //    GNU General Public License for more details.
# //    You should have received a copy of the GNU General Public License
# //    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ////////////////////////////////////////////////////////////////////////////////
# // Last modified 26/Aug/2015 by cassio@ime.usp.br
#///////////////////////////////////////////////////////////////////////////////////////////
echo "#############################################################"
echo "### $0 by cassio@ime.usp.br for Ubuntu 14.04.3 ###"
echo "#############################################################"

if [ "`id -u`" != "0" ]; then
  echo "Must be run as root"
  exit 1
fi

apt-get -y install python-software-properties 2>/dev/null

for i in id chown chmod cut awk tail grep cat sed mkdir rm mv sleep apt-get add-apt-repository update-alternatives; do
  p=`which $i`
  if [ -x "$p" ]; then
    echo -n ""
  else
    echo command "$i" not found
    exit 1
  fi
done
sleep 2

echo "$0" | grep -q "install.*sh"
if [ $? != 0 ]; then
  echo "Make the install script executable (using chmod) and run it directly, like ./install.sh"
else  

if [ ! -r /etc/lsb-release ]; then
  echo "File /etc/lsb-release not found. Is this a ubuntu or debian-like distro?"
  exit 1
fi
. /etc/lsb-release

echo "=============================================================="
echo "============== CHECKING FOR OTHER APT SERVERS  ==============="
echo "=============================================================="
echo "============== CHECKING FOR canonical.com APT SERVER  ========"
cd 
grep -q "^[^\#]*deb http://archive.canonical.com.* $DISTRIB_CODENAME .*partner" /etc/apt/sources.list
if [ $? != 0 ]; then
  add-apt-repository "deb http://archive.canonical.com/ubuntu $DISTRIB_CODENAME partner"
fi

apt-get -y update
apt-get -y upgrade

libCppdev=`apt-cache search libstdc++ | grep "libstdc++6-.*-dev " | sort | tail -n1 | cut -d' ' -f1`
if [ "$libCppdev" == "" ]; then
  echo "libstdc++6-*-dev not found"
  exit 1
fi
libCppdbg=`apt-cache search libstdc++ | grep "libstdc++6-.*-dbg " | sort | tail -n1 | cut -d' ' -f1`
if [ "$libCppdbg" == "" ]; then
  echo "libstdc++6-*-dbg not found"
  exit 1
fi
libCppdoc=`apt-cache search libstdc++ | grep "libstdc++6-.*-doc " | sort | tail -n1 | cut -d' ' -f1`
if [ "$libCppdoc" == "" ]; then
  echo "libstdc++6-*-doc not found"
  exit 1
fi

for i in makepasswd useradd update-rc.d; do
  p=`which $i`
  if [ -x "$p" ]; then
    echo -n ""
  else
    echo command "$i" not found
    exit 1
  fi
done

grep -q icpcadmin /etc/ssh/sshd_config
if [ "$?" != "0" ]; then
	echo "DenyUsers icpc icpcadmin" >> /etc/ssh/sshd_config
	ps auxw |grep sshd|grep -vq grep
	if [ "$?" == "0" ]; then
		service ssh reload
	fi
fi

pass=`echo -n icpc | makepasswd --clearfrom - --crypt-md5 | cut -d'$' -f2-`
pass=\$`echo $pass`
id -u icpc >/dev/null 2>/dev/null
if [ $? != 0 ]; then
 useradd -d /home/icpc -k /etc/skel -m -p "$pass" -s /bin/bash -g users icpc
else
 usermod -d /home/icpc -p "$pass" -s /bin/bash -g users icpc
 echo "user icpc already exists"
fi

echo "====================================================================="
echo "================= installing packages needed by BOCA  ==============="
echo "====================================================================="

#apt-get -y install wget quota postgresql postgresql-contrib postgresql-client apache2 libapache2-mod-php5 php5 php5-cli php5-cgi php5-gd php5-mcrypt php5-pgsql

#if [ $? != 0 ]; then
#  echo ""
#  echo "ERROR running the apt-get -- must check if all needed packages are available"
#  exit 1
#fi
#apt-get -y autoremove
#apt-get -y clean

#for i in update-rc.d; do
#  p=`which $i`
#  if [ -x "$p" ]; then
#    echo -n ""
#  else
#    echo command "$i" not found
#    exit 1
#  fi
#done


echo "=============================================================="
echo "============= INSTALLING SCRIPTS at /etc/icpc  ==============="
echo "=============================================================="
mkdir -p /etc/icpc
chown root.root /etc/icpc
chmod 755 /etc/icpc
cat <<EOF > /etc/icpc/installscripts.sh
#!/bin/bash
echo "================================================================================"
echo "========== downloading config files from www.ime.usp.br/~cassio/boca  =========="
echo "================================================================================"
#iptables -F
wget -O /tmp/.boca.tmp "http://www.ime.usp.br/~cassio/boca/icpc.etc.date.txt"
echo ">>>>>>>>>>"
echo ">>>>>>>>>> Downloading scripts release \`cat /tmp/.boca.tmp\`"
echo ">>>>>>>>>>"

if [ "\$1" == "" ]; then
wget -O /tmp/.boca.tmp "http://www.ime.usp.br/~cassio/boca/icpc.etc.ver.txt"
icpcver=\`cat /tmp/.boca.tmp\`
else
icpcver=\$1
fi
echo "Looking for version \$icpcver from http://www.ime.usp.br/~cassio/boca/"

rm -f /tmp/icpc.etc.tgz
wget -O /tmp/icpc.etc.tgz "http://www.ime.usp.br/~cassio/boca/download.php?filename=icpc-\$icpcver.etc.tgz"
if [ "\$?" != "0" -o ! -f /tmp/icpc.etc.tgz ]; then
  echo "ERROR downloading file icpc-\$icpcver.etc.tgz. Aborting *****************"
  exit 1
fi
grep -qi "bad parameters" /tmp/icpc.etc.tgz
if [ "\$?" == "0" ]; then
  echo "ERROR downloading file icpc-\$icpcver.etc.tgz. Aborting *****************"
  exit 1
fi

cd /etc
di=\`date +%s\`

echo "=============================================================="
echo "====================== BACKUPING CONFIG FILES ==============="

for i in \`tar tvzf /tmp/icpc.etc.tgz | awk '{ print \$6; }'\`; do
  if [ -f "\$i" ]; then
    bn=\`basename \$i\`
    dn=\`dirname \$i\`
    mv \$i \$dn/.\$bn.bkp.\$di
    chmod 600 \$dn/.\$bn.bkp.\$di
  fi
done

echo "=============================================================="
echo "====================== EXTRACTING CONFIG FILES ==============="
tar -xkvzf /tmp/icpc.etc.tgz
for i in \`tar tvzf /tmp/icpc.etc.tgz | awk '{ print \$6; }'\`; do
  chown root.root \$i
  chmod o-w,u+rx \$i
done
EOF
chmod 750 /etc/icpc/installscripts.sh
/etc/icpc/installscripts.sh $3

service procps start

grep -q "quota" /etc/fstab
if [ $? != 0 ]; then
  cp -f /etc/fstab /etc/fstab.bkp.$di
  sed "s/relatime/quota,relatime/" < /etc/fstab.bkp.$di > /etc/fstab.bkp.$di.1
  sed "s/errors=remount-ro/quota,errors=remount-ro/" < /etc/fstab.bkp.$di.1 > /etc/fstab
fi

echo "=============================================================="
echo "================= UPDATING rc.local symlinks   ==============="
echo "=============================================================="


#echo "=============================================================="
#echo "====================== SETTING UP IPs and PASSWORDs (server config follows)  ==============="
#
/etc/icpc/restart.sh
#/etc/icpc/setup.sh

#if [ -f /etc/icpc/createbocajail.sh ]; then
#	chmod 750 /etc/icpc/createbocajail.sh
#	if [ "$2" != "notbuildjail" ]; then
#		/etc/icpc/createbocajail.sh
#	fi
#else
#	echo "************** SCRIPT TO CREATE BOCAJAIL NOT FOUND -- SOMETHING LOOKS WRONG ***************"
#fi

# BOCA CONFIG
if [ -f /etc/icpc/installboca.sh ]; then
	chmod 750 /etc/icpc/installboca.sh
    #/sbin/iptables -F
	/etc/icpc/installboca.sh "$3" "$4" << EOF
y
y
y
y
YES
EOF
else
	echo "************* SCRIPT TO INSTALL BOCA NOT FOUND -- SOMETHING IS WRONG -- I CANT INSTALL BOCA **************"
fi

fi
