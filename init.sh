#!/bin/bash

if ! grep -q bdserver=$DBHOST /etc/boca.conf; then

  touch ~/.pgpass
  echo $DBHOST:5432:*:bocauser:$DBPASS > ~/.pgpass
  chmod 600 ~/.pgpass

  until psql -h "$DBHOST" -U "bocauser" -c '\l'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
  done

  bdservernew=$DBHOST

  . /etc/boca.conf

  echo "bdserver=$bdservernew" >> /etc/boca.conf
  bdserver=$bdservernew

  privatedir=$bocadir/src/private

  OK=n
  PASS=$DBPASS
  PASSK=`makepasswd --chars 20`
  awk -v boca="$bdserver" -v pass="$PASS" -v passk="$PASSK" '{ if(index($0,"[\"dbpass\"]")>0) \
    print "$conf[\"dbpass\"]=\"" pass "\";"; \
    else if(index($0,"[\"dbhost\"]")>0) print "$conf[\"dbhost\"]=\"" boca "\";"; \
    else if(index($0,"[\"dbsuperpass\"]")>0) print "$conf[\"dbsuperpass\"]=\"" pass "\";"; \
    else if(index($0,"[\"key\"]")>0) print "$conf[\"key\"]=\"" passk "\";"; else print $0; }' \
    < $privatedir/conf.php > $privatedir/conf.php1
  mv -f $privatedir/conf.php1 $privatedir/conf.php

  php ${bocadir}/src/private/createdb.php <<< $(echo YES)

  echo 'bdcreated=y' >> /etc/boca.conf

fi

boca-createjail
boca-autojudge & 

# Run the apache process in the foreground as in the php image
echo "[Boca startup] Starting apache..."
apache2-foreground
