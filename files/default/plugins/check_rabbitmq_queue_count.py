#!/usr/bin/env python

import json
import sys
from pprint import pprint

#my_data = json.loads(open("/tmp/queues.json").read())
my_data = json.loads(open(sys.argv[1]).read())

with open(sys.argv[1], 'wt') as out:
    pprint(my_data, stream=out)
