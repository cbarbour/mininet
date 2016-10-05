#!/bin/bash

packer build -var-file=latest.json $@ template.json
