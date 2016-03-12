#!/usr/bin/env bash

# Setup fcron
echo "root" > /etc/fcron/fcron.allow
chmod 644 /etc/fcron/fcron.conf /etc/fcron/fcron.allow /etc/fcron/fcron.deny
[ ! -f /run/fcron.pid ] || rm /run/fcron.pid
exec /usr/sbin/fcron

while [ ! -f /run/fcron.pid ]
do
    echo "Waiting for fcron"
    sleep 1
done

# Re-setup the fcrontab file daily.
while true
do
    containers=$(env | grep "CONTAINER_.*=" | cut -d= -f1 | tr '\n' ' ')

    # Clear the cron file.
    [ ! -f /tmp/cron.tmp ] || rm /tmp/cron.tmp

    for container_env in $containers
    do
      # Get the name and schedule of this container.
      container=$(echo $container_env | cut -c11-)
      container_schedule=${!container_env}

      # Add entry to the cron file.
cat <<EOF >> /tmp/cron.tmp
${container_schedule} curl --unix-socket /var/run/docker.sock -X POST http:/containers/${container}/start
EOF

    done

    echo "Installing new crontab"
    cat /tmp/cron.tmp

    fcrontab /tmp/cron.tmp
    sleep 86400
done
