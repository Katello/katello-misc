#!/usr/bin/env bash
# Script for signing fake manifest with fake CA

set -exo pipefail

MANIFEST_FILE=$1
TMP_DIR=$MANIFEST_FILE.tmp

unzip $MANIFEST_FILE -d $TMP_DIR

openssl dgst -sha256 -sign fake_key.pem -out $TMP_DIR/signature $TMP_DIR/consumer_export.zip

rm $MANIFEST_FILE
zip -j $MANIFEST_FILE $TMP_DIR/*
rm -rf $TMP_DIR
