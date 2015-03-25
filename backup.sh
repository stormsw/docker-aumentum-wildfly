#!/bin/sh
ID=$(docker run -d aumentum-wildfly /bin/bash)
(docker export $ID | gzip -c > image.tgz)
gzip -dc image.tgz | docker import - aumentum-wildfly-flat
