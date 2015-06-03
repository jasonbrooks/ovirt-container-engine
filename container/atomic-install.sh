#!/usr/bin/bash

set -ex

echo "Additional args: $@"

hostdocker() { chroot /host docker $@ ; }

# Create the real Engine container
# FIXME cap-add - use fewer privileges
hostdocker create \
    --cap-add=ALL \
    -p 80:80 \
    -p 443:443 \
    -h ${FQDN} \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --name ${NAME} \
    ${IMAGE}

# Run engine-setup
hostdocker start ${NAME}
hostdocker exec ${NAME} sed -i \
    -e "s/@FQDN@/${FQDN}/g" \
    -e "s/@ADMINPASSWORD@/${ADMINPASSWORD}/g" \
    /root/complete-answers
hostdocker exec ${NAME} engine-setup --offline --config-append=/root/complete-answers

# vim: set et sts=4:
