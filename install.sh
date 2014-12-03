#############################################################################
#    kamailio - Kamailio SIP server                                         #
#    kamdbctl - script to create and manage the Databases                   #
#    kamctl - script to manage and control Kamailio SIP server              #
#    sercmd - CLI - command line tool to interface with Kamailio SIP server #
#############################################################################
# Kamailio (OpenSER) modules are installed in:
#
#  /usr/local/lib/kamailio/modules/
#
# Note: On 64 bit systems, /usr/local/lib64 may be used.
#
# The documentation and readme files are installed in:
#
#  /usr/local/share/doc/kamailio/
#
# The man pages are installed in:
#
#  /usr/local/share/man/man5/
#  /usr/local/share/man/man8/
#
# The configuration file was installed in:
#
#  /usr/local/etc/kamailio/kamailio.cfg
kmlo = kamailio
Last = 4.2
KPATH=$KPATH:/usr/local/src/kamailio
mkdir -p /usr/local/src/$kmlo
cd $KPATH
git clone --depth 1 --no-single-branch git://git.sip-router.org/$kmlo $kmlo
cd $kmlo
git checkout -b $Last origin/$Last
make cfg
?nano -w modules.lst
?include_modules= db_mysql
make
make Q=0 all
make install
PATH=$PATH:/usr/local/sbin
export PATH
##To create the MySQL database, you have to use the database setup script.
##First edit kamctlrc file to set the database server type:
?nano -w /usr/local/etc/kamailio/kamctlrc
##Locate DBENGINE variable and set it to MYSQL:
?DBENGINE=MYSQL
##You can change other values in kamctlrc file, at least it is recommended to
##change the default passwords for the users to be created to connect to database.
/usr/local/sbin/kamdbctl create
##The script will add two users in MySQL:
##- kamailio - (with default password 'kamailiorw') - user which has full access rights to 'kamailio' database
##- kamailioro - (with default password 'kamailioro') - user which has read-only access rights to 'kamailio' database 
##Do change the passwords for these two users to something different that
##the default values that come with sources.
?/usr/local/etc/kamailio/kamailio.cfg
#To fit your requirements for the VoIP platform, you have to edit the configuration file
#!define WITH_MYSQL
#!define WITH_AUTH
#!define WITH_USRLOCDB
##If you changed the password for the 'kamailio' user of MySQL
##you have to update the value for 'db_url' parameters.
## Init Script
## /usr/local/src/kamailio/kamailio/pkg/kamailio/deb/debian/kamailio.init
cp $KPATH/kamailio/pkg/kamailio/deb/debian/kamailio.init /etc/init.d/kamailio
chmod 755 /etc/init.d/kamailio
##then edit the file updating the $DAEMON and $CFGFILE values:
DAEMON=/usr/local/sbin/kamailio
CFGFILE=/usr/local/etc/kamailio/kamailio.cfg
##You need also setup a configuration file in the /etc/default/ directory. This file can be found at:
##/usr/local/src/kamailio/kamailio/pkg/kamailio/deb/debian/kamailio.default
##RUN_KAMAILIO=yes
cd /usr/local/src/kamailio/kamailio/pkg/kamailio/deb/debian/
mv kamailio.default kamailio
cd $kPATH
mkdir -p /var/run/kamailio
adduser --quiet --system --group --disabled-password \
        --shell /bin/false --gecos "Kamailio" \
        --home /var/run/kamailio kamailio
# set ownership to /var/run/kamailio
chown kamailio:kamailio /var/run/kamailio
##Then you can start/stop Kamailio using the following commands:
## Start | Stop | Restart
/etc/init.d/kamailio start
/etc/init.d/kamailio stop
/etc/init.d/kamailio restart
