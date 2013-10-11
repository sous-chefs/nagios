#!/usr/bin/python
import os
import sys
import re
from optparse import OptionParser

RABBITMQCTL = "/usr/sbin/rabbitmqctl"
NAME = "name"

parser = OptionParser()
parser.add_option("-W", "--Warning", dest="warnack", metavar="INT", type="int", default=1000, help="Default: 1000")
parser.add_option("-k", "--kritical", dest="critack", metavar="INT", type="int", default=2000, help="Default: 2000")
parser.add_option("-v", "--vhost", dest="vhost", metavar="VIRTUAL_HOST", type="string", default="/", help="Default \"/\"")
parser.add_option("-i", "--info", dest="info", metavar="INFO", type="string", default="messages_unacknowledged", help="Default: messages_unacknowledged")
(options, args) = parser.parse_args()

CRITACK = int(options.critack)
WARNACK = int(options.warnack)

GET_VHOSTS = "%s -q list_vhosts" % (RABBITMQCTL)
vhostdata = os.popen(GET_VHOSTS).read().strip()

for vhost in vhostdata.split("\n"):
    if vhostdata is not None:

        UNAKD = ""
        UNAKD = "%s -q list_queues -p %s %s" % (RABBITMQCTL, vhost, options.info)

        if not os.path.exists(RABBITMQCTL):
            print "%s does not exist" % RABBITMQCTL
            sys.exit(3)

        if WARNACK > CRITACK:
            print "Warning value cannot be greater than critical value"
            sys.exit(3)

        unakd = ""
        unakd = os.popen(UNAKD).read().strip()

        is_warnack = False
        is_critack = False
        output = ""
        perf = ""

        def check_line2(result):
            result = int(result)
            globals()['output'] += "%s" % (result)
            
            globals()['perf'] += "unacknowledged=%sITEMS;%s;%s;; " % (result, WARNACK, CRITACK)
            if result > CRITACK:
                globals()['is_critack'] = True
            if result > WARNACK:
                if is_critack is not True:
                    globals()['is_warnack'] = True

                if is_critack is True:
                    sys.stdout.write("UNAKD MESSAGE CRITICAL FOR VHOST %s - %s|%s\n" % (vhost, output, perf))
                    sys.exit(2)

                if is_warnack is True:
                    sys.stdout.write("UNAKD MESSAGE WARNING FOR VHOST %s - %s|%s\n" % (vhost, output, perf))
                    sys.exit(1)

        for results in unakd.split("\n"):
            if not results:
                no_results = True
            else:         
                check_line2(results)

    else:
        sys.stdout.write("There seems to be no VHOSTS on this machine.\n")
        sys.exit(2)

sys.stdout.write("UNAKD MESSAGE OK - %s|%s\n" % (output, perf))
sys.exit(0)
