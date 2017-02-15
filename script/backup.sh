TIMESTAMP=$(date -u "+%Y-%m-%d-%H.%M.%S")
BACKUPDIR=/tmp/backups/mongodb
BACKUPFILE="mongo-backup-$TIMESTAMP.tar.gz"
S3PATH="s3://sfmongobackup/linode_backups/$BACKUPFILE"

mkdir -p $BACKUPDIR

mongodump -o $BACKUPDIR -h mongodb.scoutforce.com
cd $BACKUPDIR
tar -czf $BACKUPFILE .
s3cmd put $BACKUPFILE $S3PATH
cd

rm -rf $BACKUPDIR
