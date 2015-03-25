#!/bin/sh
ID=$(docker run -d aumentum-wildfly /bin/bash)
docker export $ID | docker import – aumentum-wildfly-flat
