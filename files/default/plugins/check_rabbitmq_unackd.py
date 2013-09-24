#!/usr/bin/python
import os
import sys
import re
from optparse import OptionParser

RABBITMQCTL = "/usr/sbin/rabbitmqctl"
NAME = "name"

parser = OptionParser()
parser.add_option("-w", "--warning", dest="warn", metavar="INT", type="int", default=100, help="Default: 100")
parser.add_option("-W", "--Warning", dest="warnack", metavar="INT", type="int", default=1000, help="Default: 1000")
parser.add_option("-c", "--critical", dest="crit", metavar="INT", type="int", default=200, help="Default: 200")
parser.add_option("-k", "--kritical", dest="critack", metavar="INT", type="int", default=2000, help="Default: 2000")
parser.add_option("-v", "--vhost", dest="vhost", metavar="VIRTUAL_HOST", type="string", default="/", help="Default \"/\"")
parser.add_option("-q", "--queue", dest="queue", metavar="QUEUE", type="string", default=None, help="Default: all")
parser.add_option("-i", "--info", dest="info", metavar="INFO", type="string", default="messages_unacknowledged", help="Default: messages_unacknowledged")
(options, args) = parser.parse_args()

CRITACK = int(options.critack)
WARNACK = int(options.warnack)

GET_VHOSTS = "%s -q list_vhosts" % (RABBITMQCTL)
sys.stdout.write("Get Vhosts command: %s\n\n" % (GET_VHOSTS))
vhostdata = os.popen(GET_VHOSTS).read().strip()
sys.stdout.write("VHOSTS are:\n%s\n\n" % (vhostdata))

for vhost in vhostdata.split("\n"):
    if vhostdata is not None:

        COMMAND2 = ""
        COMMAND2 = "%s -q list_queues -p %s %s %s" % (RABBITMQCTL, vhost, NAME, options.info)
        QUEUE = ""
        QUEUE = "%s -q list_queues -p %s %s" % (RABBITMQCTL, vhost, NAME)
        UNAKD = ""
        UNAKD = "%s -q list_queues -p %s %s" % (RABBITMQCTL, vhost, options.info)

        if not os.path.exists(RABBITMQCTL):
            print "%s does not exist" % RABBITMQCTL
            sys.exit(3)

        if WARNACK > CRITACK:
            print "Warning value cannot be greater than critical value"
            sys.exit(3)

        data2 = ""
        data2 = os.popen(COMMAND2).read().strip()
        queue = ""
        queue = os.popen(QUEUE).read().strip()
        unakd = ""
        unakd = os.popen(UNAKD).read().strip()

        sys.stdout.write("Current VHOST is: %s\n" % (vhost))

        if not data2:
            sys.stdout.write("No queues found on VHOST %s\n\n\n" % (vhost))
        else:
            sys.stdout.write("Found queues in %s:\n%s\n\n\n" % (vhost, data2))

        is_warnack = False
        is_critack = False
        output = ""
        perf = ""

        def check_line2(result):
            result = int(result)
            globals()['output'] += "%s" % (result)
            #sys.stdout.write("Result is %s, and CRITACK is %s\n" % (result, CRITACK))
            
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
                sys.stdout.write("No queues found on VHOST %s\n\n\n" % (vhost))
            else:         
                check_line2(results)

    else:
        sys.stdout.write("There seems to be no VHOSTS on this machine.\n")
        sys.exit(2)

sys.stdout.write("UNAKD MESSAGE OK - %s|%s\n" % (output, perf))
sys.exit(0)
