import json
import os

current_dir = os.path.dirname(os.path.abspath(__file__))

def load_json():
    abs_path = os.path.join(current_dir, 'bpmn.json')
    with open(abs_path, 'r', encoding='utf-8') as f:
        bpmn_types = json.load(f)

    # print(bpmn_types)
    name_to_super = {}
    for typ in bpmn_types['types']:
        if 'superClass' in typ:
            if 'prefix' in typ:
                name_to_super[typ['prefix'] + ':' + typ['name']] = typ['superClass']
            else:
                name_to_super[bpmn_types['prefix'] + ':' + typ['name']] = \
                    [bpmn_types['prefix'] + ':' + i for i in typ['superClass']]

    return name_to_super
