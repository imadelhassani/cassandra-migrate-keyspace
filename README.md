# cassandra-migrate-keyspace
use it to migrate keyspace and his data from a node to another node













**Requirements :** 

dsbulk 1.8.0 (should be placed in the root directory /dsbulk1.8.0/)
Installation guide : https://docs.datastax.com/en/dsbulk/doc/dsbulk/install/dsbulkInstall.html














**Data exportation for cassandra node :** 


use the script dsbulk_export with the follow options: 
./dsbulk_export keyspacename user password backupname
example : 
./dsbulk_export keyspace1 cassandra cassandra bkp_1
result: bkp_1.tar.gz
the file bkp_1.tar.gz will be used to restore data in another node















**Data importation for cassandra node :** 

use the script dsbulk_import with the follow options: 
./dsbulk_export tarfile.tar.gz user password backupname
./import_dsbulk tarfile user password backupname
example : 
./dsbulk_import keyspace1.tar.gz cassandra cassandra bkp_1
result: the data will be imported directly to the database














**important:** 

to import data in a node make sure the database doesn't have a keyspace within the same name if it the case delete the old keyspace by using

cqlsh -u user -p password -e "drop keyspace keyspacename;”

delete the data in : 
rm -rf /bitnami/cassandra/data/data/keyspacename
