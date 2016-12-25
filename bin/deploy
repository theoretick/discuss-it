#!/bin/bash

APP_VERSION=`grep 'version' mix.exs | cut -d \" -f 2`
RELEASE_TARBALL=./rel/discuss_it/releases/${APP_VERSION}/discuss_it.tar.gz

if [ -f $RELEASE_TARBALL ]; then
  scp $RELEASE_TARBALL \
    theoretick@discussitapp.com:/var/www/discuss_it/otp_releases
else
  echo "No release found for version ${APP_VERSION}"
fi
