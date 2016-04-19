#!/bin/bash

cat << MSG
This script will unbind the http_requests_queue and purge the contents.

MSG

# delete binding
rabbitmqadmin --vhost=/server2server --username=admin --password="toor4cars9window14five." delete binding source=events destination=http_requests_queue destination_type=queue properties_key=*.*.*.S.#
# purge queue
rabbitmqadmin --vhost=/server2server --username=admin --password="toor4cars9window14five." purge queue name=http_requests_queue
#delete queue
rabbitmqadmin --vhost=/server2server --username=admin --password="toor4cars9window14five." delete queue name=http_requests_queue