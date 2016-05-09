#!/bin/bash

# restart esp
sudo initctl stop datacloud-eventstream_processor
sudo initctl start datacloud-eventstream_processor
sudo service jetty stop
sudo service jetty start
