#!/bin/bash

if [[ $(uname) == "Darwin" ]]; then
  echo "macOS doesn't support statically linked binaries, skipping."
  exit 0
fi

echo "checking $1"

# We can't rely on the exit code alone, since ldd fails for statically linked binaries.
DYNLIBS=$(ldd "$1" 2>&1) || {
  if [[ ! "${DYNLIBS}" =~ 'not a dynamic executable' ]]; then
      echo "${DYNLIBS}"
      exit 1
  fi
}

if [[ "${DYNLIBS}" =~ libc\+\+ ]]; then
  echo "libc++ is dynamically linked:"
  echo "${DYNLIBS}"
  exit 1
elif [[ "${DYNLIBS}" =~ libstdc\+\+ || "${DYNLIBS}" =~ libgcc ]]; then
  echo "libstdc++ and/or libgcc are dynamically linked:"
  echo "${DYNLIBS}"
  exit 1
fi

echo "success"