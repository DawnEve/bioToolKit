##1
usr=$1
if [ "$1" == "" ]
then
  echo "You must input a username"
  exit
fi
echo "add new user: "$usr

##2
pass=$2
if [ "$2" == "" ]
then
  pass=`date|md5sum |head -c 10`
fi
echo "password: "$pass

##3
useradd -s /bin/bash -d /home/${usr} -m ${usr}
mkdir /data/${usr}
chown ${usr} /data/${usr}
chgrp ${usr} /data/${usr}

ln -s /data/${usr} /home/${usr}/data
##4
#echo $pass | passwd  $usr --stdin
echo "${usr}:${pass}" >${pass}.log
chpasswd < ${pass}.log
rm ${pass}.log

echo "done!"
