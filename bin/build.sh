#!/bin/bash

# TODO: remove this once I figure how to cross-compile
if [ `uname` != "Linux" ]; then
  echo "Platform must be Linux to build deployable release not `uname`"
  exit 1
fi

MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix compile
MIX_ENV=prod mix release
