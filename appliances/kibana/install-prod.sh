#!/usr/bin/env bash

rm -f templates/secret.yaml
./generate_secret.sh
helm package .
helm serve &
helm install local/kibana --name=kibana --namespace=logging