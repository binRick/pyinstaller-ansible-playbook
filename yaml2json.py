#!/usr/bin/python3
"""
Usage:
    yaml2json (--version|--help)
    yaml2json [-i <indent>] [-a] [<yaml_file>] [<json_file>]

Arguments:
    -i, --indent=INDENT  Number of spaces to indent [default: 4]
    -a, --array          Wrap the yaml documents in a JSON array
    <yaml_file>          The input file containing the YAML to convert. If not
                         specified, reads from stdin.
    <json_file>          The output file to which to write the converted JSON. If
                         not specified, writes to stdout.
"""

import sys, os, io
import json, yaml
import docopt

from collections import OrderedDict as odict
from yaml import MappingNode

__version__ = "1.2.0"

if sys.version_info >= (3, 0):
    file = io.TextIOWrapper

# Configure PyYaml to create ordered dicts
_mapping_tag = yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG

def construct_ordered_mapping(loader, node, deep=False):
    if isinstance(node, MappingNode):
        loader.flatten_mapping(node)
    return odict(loader.construct_pairs(node, deep))

def construct_yaml_ordered_map(loader, node, deep=False):
    data = odict()
    yield data
    value = construct_ordered_mapping(loader, node, deep)
    data.update(value)

yaml.add_constructor(_mapping_tag, construct_yaml_ordered_map)

def safeopen(name, mode='r', buffering=1):
    if isinstance(name, file):
        return name
    elif name == '-':
        return sys.stdin
    else:
        return open(name, mode, buffering)

# Convert from YAML to JSON
def convert(yaml_file, json_file, indent, array):
    def dump(doc):
        json.dump(doc, json_file, separators=(',',': '), indent=indent)
        json_file.write('\n')

    loaded_yaml = list(yaml.safe_load_all(yaml_file))
    if array:
        dump(list(loaded_yaml))
    else:
        for doc in loaded_yaml:
            dump(doc)

if __name__ == '__main__':
    args = docopt.docopt(
        __doc__,
        version="version "+__version__
    )

    yaml_arg   = args.get('<yaml_file>') or sys.stdin
    json_arg   = args.get('<json_file>') or sys.stdout
    indent_arg = int(args.get('--indent'))
    array_arg  = bool(args.get('--array'))

    with safeopen(yaml_arg, 'r') as yaml_file:
        with safeopen(json_arg, 'w') as json_file:
            convert(yaml_file, json_file, indent=indent_arg, array=array_arg)
