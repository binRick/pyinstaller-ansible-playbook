#!/usr/bin/python3
"""
Usage:
    json2yaml (--version|--help)
    json2yaml [<json_file>] [<yaml_file>]

Arguments:
    <json_file>    The input file containing the JSON to convert. If not
                   specified, reads from stdin.
    <yaml_file>    The output file to which to write the converted YAML. If
                   not specified, writes to stdout.
"""

import sys, os, io
import collections
import json, pyaml
import docopt

__version__ = "1.2.0"

if sys.version_info >= (3, 0):
    file = io.TextIOWrapper

def safeopen(name, mode='r', buffering=1):
    if isinstance(name, file):
        return name
    elif name == '-':
        return sys.stdin
    else:
        return open(name, mode, buffering)

def convert(json_file, yaml_file):
    loaded_json = json.load(json_file, object_pairs_hook=collections.OrderedDict)
    pyaml.dump(loaded_json, yaml_file, safe=True)

if __name__ == '__main__':
    args = docopt.docopt(
        __doc__,
        version="version "+__version__
    )

    json_arg = args.get('<json_file>') or sys.stdin
    yaml_arg = args.get('<yaml_file>') or sys.stdout

    with safeopen(json_arg, 'r') as json_file:
        with safeopen(yaml_arg, 'w') as yaml_file:
            convert(json_file, yaml_file)
