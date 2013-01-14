#!/usr/bin/python
import os
import re
import shlex
import sys

cmd = os.environ.get('SSH_ORIGINAL_COMMAND')
if not cmd:
    print 'No command given'
    sys.exit(1)

if re.match(r'^rsync --server --sender -vlogDtprRe.iLsf --numeric-ids . [a-zA-Z0-9_/-]+$', cmd):
    cmd_args = shlex.split(cmd)
    os.execv('/usr/bin/rsync', cmd_args)
else:
    print 'Command %r unnacceptable'%cmd
    sys.exit(1)
