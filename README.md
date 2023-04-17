# Cassandra Migrate Keyspace

Cet outil vous permet de migrer un keyspace et ses données d'un nœud Cassandra à un autre en utilisant DataStax Bulk Loader (dsbulk).

## Prérequis

- DataStax Bulk Loader (dsbulk) 1.8.0 doit être installé et placé dans le répertoire racine `/dsbulk-1.8.0/`
- Guide d'installation : https://docs.datastax.com/en/dsbulk/doc/dsbulk/install/dsbulkInstall.html

## Utilisation

Le script `cassandra_migration.sh` permet d'exporter et d'importer des données. Les options suivantes sont disponibles :

- `operation` : "export" ou "import"
- `keyspace_n` : Nom du keyspace ou fichier tar.gz lors de l'importation
- `user_auth` : Nom d'utilisateur Cassandra
- `pass_auth` : Mot de passe de l'utilisateur Cassandra
- `bkp_name` : Nom du dossier de sauvegarde

### Exportation des données

Exemple :

```bash
./cassandra_migration.sh export keyspace1 cassandra cassandra bkp_1
```

Résultat : `bkp_1.tar.gz`

Le fichier `bkp_1.tar.gz` sera utilisé pour restaurer les données dans un autre nœud.

### Importation des données

Exemple :

```bash
./cassandra_migration.sh import keyspace1.tar.gz cassandra cassandra bkp_1
```

Résultat : Les données seront importées directement dans la base de données.

## Notes importantes

Pour importer des données dans un nœud, assurez-vous que la base de données ne contient pas de keyspace du même nom. Si c'est le cas, supprimez l'ancien keyspace en utilisant :

```cql
cqlsh -u user -p password -e "drop keyspace keyspacename;"
```

Supprimez également le dossier du keyspace dans :

```bash
rm -rf /cassandra/data/data/keyspacename
```

