#!/usr/bin/env python3
__author__ = 'kamilion@gmail.com'
from flask import Flask, Response, jsonify
import unicodedata
import glob
# import subprocess32 as sp  # uncomment for python2 compatibility
import subprocess as sp  # uncomment for python3 compatibility

def clean_filename(filename):
    validchars = "abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789"
    if (not isinstance(filename, str)) and (sys.version_info.major != 2):
        filename = unicodedata.normalize('NFKD', filename).encode('ASCII', 'ignore')
    return str(''.join(c for c in filename if c in validchars))

def run_cmd(cmd=["xl", "list", "-l"]):  # This one wants a list
    p = sp.Popen(cmd,
                 stdout=sp.PIPE,
                 stderr=sp.PIPE,
                 stdin=sp.PIPE)
    return p.communicate()[0]

# Both of these lists should match element indexes!
xen_configs = glob.glob('/vms/active/*/xen.conf')
xen_vms = [x.replace('/vms/active/', '').replace('/xen.conf', '') for x in xen_configs]

flask_core = Flask(__name__)
#flask_core.debug = True

@flask_core.route("/running")
def list_running():
    return Response(status=200, mimetype="application/json",
                    response=run_cmd(["get-running-vms-json"]))

@flask_core.route("/available")
def list_available():
    return jsonify({'kind': "vmlist", 'items': xen_vms, 'totalItems': len(xen_vms)})

@flask_core.route("/")
def index():
    return jsonify({'kind': 'empty', 'items': [], 'itemCount': 0})

if __name__ == "__main__":
    flask_core.run(host='0.0.0.0')
