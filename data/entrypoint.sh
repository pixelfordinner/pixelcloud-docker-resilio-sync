#!/bin/sh

# This script will use LOCAL_USER_NAME and LOCAL_USER_ID
# as well as LOCAL_GROUP_NAME and LOCAL_GROUP_ID from env
# and create the user and group if they don't exist
# and then use them to start resilio sync with.
# If absent, will use resilio sync's alpine default config: resilio sync:resilio sync
# Not setting any env var will result in default image behaviour.

USER_NAME=${LOCAL_USER_NAME:-'www-data'}
GROUP_NAME=${LOCAL_GROUP_NAME:-'www-data'}
UMASK=${LOCAL_UMASK:-'002'}

echo "Starting run_sync as ${USER_NAME}:${GROUP_NAME}"

if [ $(grep -c "^${GROUP_NAME}:" /etc/group) == 0 ]; then
  echo "Creating group $GROUP_NAME"
  addgroup -S -g $LOCAL_GROUP_ID $GROUP_NAME
else
  echo "Group $GROUP_NAME already exists"
fi

if [ $(grep -c "^${USER_NAME}:" /etc/passwd) == 0 ]; then
  echo "Creating user $USER_NAME"
  adduser -S -H -s /sbin/nologin -u $LOCAL_USER_ID $USER_NAME $GROUP_NAME
else
  echo "User $USER_NAME already exists"
fi

umask $UMASK

mkdir -p /mnt/sync/folders
mkdir -p /mnt/sync/config

if ! [ -f /mnt/sync/sync.conf ]; then
    cp /etc/sync.conf.default /mnt/sync/sync.conf;
fi

chown -R $USER_NAME:$GROUP_NAME /mnt/sync

exec su-exec $USER_NAME:$GROUP_NAME /usr/bin/rslsync --nodaemon --config "/mnt/sync/sync.conf"
