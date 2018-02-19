#!/usr/bin/env python3

import subprocess
import time

subprocess.run(["make"], stdout = subprocess.PIPE)
time.sleep(2)
subprocess.run(["./ICG"])

