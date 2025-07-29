#!/bin/bash
ssh-keygen -b 4096 -t rsa -f ./cloudgoat -q -N ""
cp cloudgoat.pub terraform/cloudgoat.pub