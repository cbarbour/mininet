# Packer templates for Mininet

## Overview

These [Packer](https://www.packer.io) templates can be used to quickly and easily build AMIs for use in AWS.

## Usage

In most cases, an AMI can be built simply by invoking `build.sh`. Build supplies a sane set of arguments to Packer.

The currently checked out branch will be copied to the AMI, and the mininet installer will be invoked automatically. In order to build an AMI with a specific version of Mininet, first check out the appropriate branch or tag of the mininet repository.

In order to build an AMI, you will need to have configured your AWS authentication credentials, and you must have approprivate priveleges within the account.

See the AWS Command Line Interface documentation for additional information on [how to configure access credentials](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-files).

## Advanced usage

### Build options

The `build.sh` script will pass any supplied arguments directly to packer. You can use this to pass account specific settings to the build script that you might not want to hard code into your configuration.

For example, if your account does not have a default VPC, you may pass your VPC ID and Subnet ID like this:

```
./build.sh -var 'vpc_id=vpc-1234abcd' -var 'subnet_id=subnet-567890ef'
```

### Building old releases

Releases of mininet prior to the introduction of this template will not contain the template as part of a normal checkout. You can build older releases by checking the packer templates from the master branch into the current working tree.

For example:

```
git checkout 2.2.1
git checkout master /util/packer
```

This will place the packer templates from the master branch into the 2.2.1 working tree. You can then proceed to build an AMI normally.


## Issues / Enhancements

Currently, these templates only build AMIs. It would be fairly straightforward to support other providers or platforms in the future. The Mininet repository includes seperate automation for VM creation.

The template does not provide a way to build a VM without a full local copy of the repository. The actual installer automation scripts do offer this ability.
