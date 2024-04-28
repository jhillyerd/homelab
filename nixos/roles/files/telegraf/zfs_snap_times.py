#!/usr/bin/env python3

import subprocess
import time
import re

cmd = [ "zfs", "list", "-H", "-p", "-t", "snapshot", "-o", "name,creation", "-S", "creation" ]

def sanitize_tag(value):
    return re.sub(r"([,= ])", r"\\\1", value)

result = subprocess.run(cmd, capture_output=True)
now_ns = time.time_ns()
now_s = int(time.time())

# Loop over snapshots, fmt: "<zpool>/<volume>@<snapshot> <timestamp>"
for line in result.stdout.decode("utf-8").split("\n"):
    if line == "":
        continue
    (fullname, created) = line.split("\t")
    (volume, name) = fullname.split("@")

    created_s = int(created)
    age_s = now_s - created_s

    creator = "other"
    if name.startswith("sanoid"):
        creator = "sanoid"
    elif name.startswith("syncoid"):
        creator = "syncoid"

    # Output metric in influx format.
    print('zfs.snapshot,volume=%s,creator=%s created=%su,age_seconds=%du %d' % (
        sanitize_tag(volume), creator, created, age_s, now_ns))
