import json
from typing import Union, Dict
import antlr4
import os

from ir_def import *
from definitions import *
from utils.load_json import load_json
from translators.solidity_translator import sol_translate
from translators.move_translator import move_translate

ALL_EVENTS = True  # 用于控制是否给执行完每一个bpmn块都报出一个event，用于前端同步进度
name_to_super = load_json()

globalNodeMap: Dict[str, Any] = {}
globalNodeIndexMap: Dict[str, int] = {}
globalEdgeIndexMap: Dict[str, int] = {}
globalControlFlowInfo: List[ControlFlowInfo] = []
globalControlFlowInfoMap = {}
globalDataNames = []
globalStructDef = {}


def set_first_upper(s) -> str:
    """ Set the first letter of a string to uppercase """
    return s[0].upper() + s[1:] if len(s) > 0 else s

def is_instance(target, goal) -> bool:
    """ If an element is the goal class instance """
    if target == goal:
        return True

    if target not in name_to_super:
        return False

    for super_cls in name_to_super[target]:
        return is_instance(super_cls, goal)


def collect_control_flow_info(proc, globalNodeMap, globalControlFlowInfo):
    """ Collect process control flow information """
    node_list = []
    edge_list = []
    boundary_events = []

    # Do NOT support some BPMN elements
    for _ in filter(lambda e: is_instance(e["$type"], "bpmn:SubProcess"), \
        proc['flowElements']):
        raise NotImplementedError("Subprocesses are not supported yet")
    for _ in filter(lambda e: is_instance(e["$type"], "bpmn:BoundaryEvent"), \
        proc['flowElements']):
        raise NotImplementedError("Boundary events are not supported yet")
    for _ in filter(lambda e: is_instance(e['$type'], 'bpmn:CallActivity'), \
        proc['flowElements']):
        raise NotImplementedError("Call activity are not supported yet")

    for node in filter(lambda e: is_instance(e["$type"], "bpmn:FlowNode"), proc['flowElements']):
        node_list.append(node["id"])
        globalNodeMap[node["id"]] = node

    sources = node_list.copy()

    for flow_edge in filter(lambda e: is_instance(e["$type"], "bpmn:SequenceFlow"),\
        proc['flowElements']):
        if flow_edge['targetRef']['id'] in sources:
            sources.remove(flow_edge['targetRef']['id'])
        edge_list.append(flow_edge['id'])

    node_list = [node for node in node_list if node not in sources]

    data_objects = []
    for data_obj in filter(lambda e: is_instance(e["$type"], "bpmn:DataObjectReference"),\
        proc['flowElements']):
        data_objects.append(data_obj)

    controlFlowInfo = ControlFlowInfo(
        proc,
        node_list,
        edge_list,
        sources,
        data_objects,
        boundary_events
    )
    globalControlFlowInfo.append(controlFlowInfo)

    if 'documentation' in proc and len(proc['documentation']) > 0 \
        and 'text' in proc['documentation'][0]:
        controlFlowInfo.globalParameters = proc['documentation'][0]['text']

    if 'authGlobal' in proc and len(proc['authGlobal']) > 0:
        controlFlowInfo.authGlobal = proc['authGlobal']

    # Do not support some BPMN elements
    for node_id in controlFlowInfo.sources:
        if 'triggeredByEvent' in globalNodeMap[node_id]:
            raise NotImplementedError("Do not support trigger by event yet")

    for node_id in controlFlowInfo.nodeList:
        e = globalNodeMap.get(node_id)
        if is_instance(e['$type'], 'bpmn:Task') and \
            ('loopCharacteristics' in e) and e['loopCharacteristics']['$type'] \
                == "bpmn:MultiInstanceLoopCharacteristics":
            raise NotImplementedError("Do not support multi instance activities yet")


def has_external_call(node_id):
    """ Whether the node need to interact with external environment """
    node = globalNodeMap[node_id]
    return (is_instance(node['$type'], "bpmn:UserTask") or
            is_instance(node['$type'], "bpmn:ServiceTask") or
            is_instance(node['$type'], "bpmn:ReceiveTask"))


def get_node_name(node):
    """ Get node name or its node ID by node object """
    return node['name'].replace(' ', '_') if 'name' in node else node['id']


def generate_array_type(obj):
    """ Get Array type, eg. uint[] """
    if 'arrayLength' in obj and len(obj['arrayLength']):
        return obj['elementType'] + '[' + obj['arrayLength'] + ']'
    else:
        return obj['elementType'] + '[]'


def get_struct_name(obj):
    """ Get the name of struct data object  """
    if 'structType' in obj and len(obj['structType']):
        return obj['structType']
    else:
        return set_first_upper(obj['name'])


def generate_local_params(node, is_input, with_prefix):
    """ 
    Generate node local params according to its data associations,
    return a list like [type, name, type, name...]
    """
    local_params = []
    if (is_input and 'dataInputAssociations' in node) or \
            (not is_input and 'dataOutputAssociations' in node):
        if is_input:
            for ass in node['dataInputAssociations']:
                if ass['sourceRef'][0]['$type'] == 'bpmn:DataObjectReference':
                    if 'dataType' in ass['sourceRef'][0]:
                        if ass['sourceRef'][0]['dataType'] == 'array':
                            local_params += [generate_array_type(ass['sourceRef'][0]),
                                ('_' if with_prefix else '') + ass['sourceRef'][0]['name']]
                        else:
                            local_params += [ass['sourceRef'][0]['dataType'],
                                ('_' if with_prefix else '') + ass['sourceRef'][0]['name']]
                    elif 'collectionList' in ass['sourceRef'][0]:
                        local_params += [get_struct_name(ass['sourceRef'][0]),
                                         ('_' if with_prefix else '') + ass['sourceRef'][0]['name']]
                    else:
                        raise KeyError
        else:
            for ass in node['dataOutputAssociations']:
                if ass['targetRef']['$type'] == 'bpmn:DataObjectReference':
                    if 'dataType' in ass['targetRef']:
                        if ass['targetRef']['dataType'] == 'array':
                            local_params += [generate_array_type(ass['targetRef']),
                                ('_' if with_prefix else '') + ass['targetRef']['name']]
                        else:
                            local_params += [ass['targetRef']['dataType'],
                                ('_' if with_prefix else '') + ass['targetRef']['name']]
                    elif 'collectionList' in ass['targetRef']:
                        local_params += [get_struct_name(ass['targetRef']),
                                         ('_' if with_prefix else '') + ass['targetRef']['name']]
                    else:
                        raise KeyError

    return local_params


def nodeName(node_id):
    """ Get node name by node ID """
    return get_node_name(globalNodeMap.get(node_id))


def get_process_id(controlFlowInfo):
    """ Get process ID of current current """
    return controlFlowInfo.proc['id']


def subprocessStartMarking(subprocessId, controlFlowInfo):
    """ Get start marking for an process """
    toSearch = globalNodeMap.get(subprocessId)
    bitarray = [0 for _ in range(len(controlFlowInfo.edgeIndexMap) + 1)]
    result = "0b"

    for node in filter(
        lambda e: is_instance(e['$type'], "bpmn:FlowNode") and \
            is_instance(e['$type'], "bpmn:StartEvent"),
        toSearch['flowElements']):

        if node['$parent']['id'] == subprocessId:
            if 'outgoing' in node:
                for outgoing in node['outgoing']:
                    bitarray[controlFlowInfo.edgeIndexMap.get(outgoing['id'])] = 1

    for i in range(len(bitarray) - 1, -1, -1):
        result += "1" if bitarray[i] else "0"

    return str(int(result, 2))


def get_throwing_messages(controlFlowInfo):
    """ Get node that may throw a event, return node IDs """
    res = []
    for node_id in controlFlowInfo.nodeList:
        node = globalNodeMap.get(node_id)
        if ((is_instance(node['$type'], "bpmn:EndEvent") or
                is_instance(node['$type'], "bpmn:IntermediateThrowEvent")) and
                'eventDefinitions' in node and
                len(node['eventDefinitions']) and
                is_instance(node['eventDefinitions'][0]['$type'], "bpmn:MessageEventDefinition")):
            res.append(node_id)
    return res


def globalDeclarations(controlFlowInfo, contract:ContractAST) -> list:
    """ Add global declarations to contract """
    added = set()
    assign_list = []  # initialize global initialization, element is AssignAST

    if len(controlFlowInfo.globalParameters) > 0:
        global_params = controlFlowInfo.globalParameters.split(';')
        for param in global_params:
            param = param.strip()
            if len(param) == 0:
                continue
            # example: uint a = 100
            before_equal = param.split('=')[0].strip()  # type identifier
            space_index = before_equal.index(' ')
            param_name = before_equal[space_index + 1:] # identifier

            if param_name not in added:
                added.add(param_name)
                globalDataNames.append(param_name)
                contract.add2list(
                    DeclStateVarAST(
                        before_equal[:space_index],
                        '_' + param[space_index + 1:],
                        "",
                        param.split('=')[1].strip())
                )

    for data_obj in controlFlowInfo.dataObjects:
        if 'dataType' in data_obj:
            if data_obj['name'] not in added:
                added.add(data_obj['name'])
                globalDataNames.append(data_obj['name'])

                if data_obj['dataType'] == 'mapping':
                    data_type = f'mapping({data_obj["elementType"].replace(",", "=>")})'
                    contract.add2list(
                        DeclStateVarAST(
                            data_type,
                            '_' + data_obj['name'],
                            "",
                            "")
                    )
                    # Initialize in contract constructor
                    if 'mappingData' in data_obj:
                        for kv in data_obj['mappingData']:
                            assign_list.append(
                                MapOpAST(f'_{data_obj["name"]}', f'{kv["keyDefault"]}', f'{kv["valueDefault"]}')
                            )
                            # assign_list.append(AssignAST(f'_{data_obj["name"]}[{kv["keyDefault"]}]',
                            #                              f'{kv["valueDefault"]}'))

                else:
                    if data_obj['dataType'] == 'array':
                        data_type = generate_array_type(data_obj)
                    else:
                        data_type = data_obj['dataType']

                    if 'defaultValue' in data_obj and len(data_obj['defaultValue']):
                        contract.add2list(
                            DeclStateVarAST(
                                data_type,
                                '_' + data_obj['name'],
                                "",
                                data_obj['defaultValue'])
                        )
                    else:
                        contract.add2list(
                            DeclStateVarAST(
                                data_type,
                                '_' + data_obj['name'],
                                "",
                                "")
                        )

        elif 'collectionList' in data_obj:
            if data_obj['name'] not in added:
                added.add(data_obj['name'])

                if not ('definedStruct' in data_obj and data_obj['definedStruct'] == 'true'):
                    struct_def = DefStructAST(f"{get_struct_name(data_obj)}")
                    struct_def.ability_list.append("store")
                    struct_def.ability_list.append("copy")
                    struct_def.ability_list.append("drop")
                    for var in data_obj['collectionList']:
                        var_type = var["dataType"] if var['dataType'] != 'array' else generate_array_type(var)
                        struct_def.var_name.append(f'{var["dataName"]}')
                        struct_def.var_type.append(var_type)
                    contract.add2list(struct_def)

                # resource_names.add(get_struct_name(data_obj))
                globalDataNames.append(data_obj['name'])
                globalStructDef[get_struct_name(data_obj)] = data_obj['collectionList']
                contract.add2list(DeclStateVarAST(get_struct_name(data_obj), '_'+data_obj['name']))

        else:
            raise TypeError

    return assign_list


def preMarking(controlFlowInfo, node_id):
    """ Get edge marking before a node """
    node = globalNodeMap.get(node_id)
    bitarray = [0 for _ in range(len(controlFlowInfo.edgeIndexMap) + 1)]
    if 'incoming' in node:
        for incoming in node['incoming']:
            bitarray[controlFlowInfo.edgeIndexMap.get(incoming['id'])] = 1
    else:
        bitarray[0] = 1
    result = '0b'
    for i in range(len(bitarray) - 1, -1, -1):
        result += '1' if bitarray[i] else '0'
    return str(int(result, 2))


def postMarking(controlFlowInfo, node_id):
    """ Get edge marking after a node """
    node = globalNodeMap.get(node_id)
    bitarray = [0 for _ in range(len(controlFlowInfo.edgeIndexMap) + 1)]
    result = '0b'
    if 'outgoing' in node:
        for outgoing in node['outgoing']:
            bitarray[controlFlowInfo.edgeIndexMap.get(outgoing['id'])] = 1
    else:
        result = '0'
    for i in range(len(bitarray) - 1, -1, -1):
        result += '1' if bitarray[i] else '0'
    return str(int(result, 2))


def flowNodeIndex(flownode_id):
    """ Get node marking representing its global node index """
    bitarray = [0 for _ in range(globalNodeIndexMap.get(flownode_id) + 1)]
    bitarray[globalNodeIndexMap.get(flownode_id)] = 1
    result = "0b"
    for i in range(len(bitarray) - 1, -1, -1):
        result += "1" if bitarray[i] else "0"
    return int(result, 2)


def eventType(node_id):
    """ Get event type, can be either Message or Default """
    node = globalNodeMap.get(node_id)
    if 'eventDefinitions' in node and len(node['eventDefinitions']) > 0:
        cad = node['eventDefinitions'][0]['$type']
        return cad[5:len(cad) - 15]
    return 'Default'


def should_memory(param):
    """ string, bytes, array, struct should has memory keyword """
    return param == 'string' or param == 'bytes' or param[0].isupper() \
        or ('[' in param and ']' in param)


def get_work_items_group_by_parameters(controlFlowInfo):
    name2ids = {}
    for node_id in controlFlowInfo.nodeList:
        node = globalNodeMap.get(node_id)
        if is_instance(node['$type'], 'bpmn:UserTask') or \
                is_instance(node['$type'], 'bpmn:ServiceTask') or \
                is_instance(node['$type'], 'bpmn:ReceiveTask') :
            params = ""
            if 'documentation' in node and 'text' in node['documentation'][0] and \
                    len(node['documentation'][0]['text']):
                raise NotImplementedError

            name = get_node_name(globalNodeMap.get(node_id)) + params
            if name not in name2ids:
                name2ids[name] = []
            name2ids[name].append(node_id)

    return name2ids


def nodeFunctionBody(node_id) -> Union[CodeSnippetAST, None]:
    """ Add code snippet in JSON to generated contract """
    node = globalNodeMap.get(node_id)
    if 'script' in node:
        # 可能几个global data name有相同的部分
        script = node['script'].split('->')[0]
        if script in ("", "\n"):
            return None
        script_copy = script
        for name in sorted(globalDataNames, key=len, reverse=True):
            if name in script_copy:
                script_copy = script_copy.replace(name, ' ')
                script = script.replace(name, '_' + name)
        return CodeSnippetAST(script)

    return None


def getCondition(flowEdge) -> Union[BoolExprAST, None]:
    """ Get flow edge condition """
    op_list = ["<=", ">=", "==", "<", ">", "!="]
    if 'conditionExpression' in flowEdge:
        body = flowEdge['conditionExpression']['body'].strip()
        for op in op_list:
            op_position = body.find(op)
            left_expr = body[:op_position].strip()
            right_expr = body[op_position + len(op):].strip()
            for name in globalDataNames:
                if left_expr == name:
                    left_expr = left_expr.replace(name, '_' + name)
                if right_expr == name:
                    right_expr = right_expr.replace(name, '_' + name)
            if op_position != -1:
                return BoolExprAST(
                    left_expr,
                    op,
                    right_expr
                )

        if body != "":
            return BoolExprAST(body)

    return None


def flowEdgeIndex(flowEdgeId):
    """ Get edge marking representing global edge index """
    bitarray = [0 for _ in range(globalEdgeIndexMap.get(flowEdgeId) + 1)]
    bitarray[globalEdgeIndexMap.get(flowEdgeId)] = 1
    result = "0b"
    for i in range(len(bitarray) - 1, -1, -1):
        result += "1" if bitarray[i] else "0"
    return int(result, 2)


def nodeRealIndex(node_id):
    return globalNodeIndexMap.get(node_id)


def subprocessFullMarking(controlFlowInfo, subproc_id):
    bitarray = [0 for _ in range(len(controlFlowInfo.edgeIndexMap) + 1)]
    result = "0b"
    children = [subproc_id]

    for subprocess_id in children:
        local_info = globalControlFlowInfoMap.get(subprocess_id)
        for edge_id in local_info.edgeList:
            bitarray[controlFlowInfo.edgeIndexMap.get(edge_id)] = 1

    for i in range(len(bitarray) - 1, -1, -1):
        result += "1" if bitarray[i] else "0"

    return format(int(result, 2), ".0f")


def subprocessNodeMarking(subprocessId):
    bitarray = [0 for _ in range(1 + len(globalNodeIndexMap))]

    for node in globalNodeMap.values():
        if node["$parent"] and node["$parent"]["id"] == subprocessId:
            if is_instance(node["$type"], "bpmn:Task"):
                bitarray[globalNodeIndexMap[node["id"]]] = 1

    result = "0b" if any(bitarray) else "0"
    for i in range(len(bitarray) - 1, -1, -1):
        result += "1" if bitarray[i] else "0"

    return format(int(result, 2), '.0f')


def worklist_nodeName(node_id):
    """ Get node name by node ID """
    return get_node_name(globalNodeMap.get(node_id))


def get_worklist_param(controlFlowInfo, parameterInfo, node_id, isInput, hasType, 
                       hasPrevious, obj=None, has_memory=True) -> list:
    """ Generate arguments for worklist contract, return argument list """
    def is_struct(param):
        return param[0].isupper()

    def create_obj(s):
        """ Create struct object (also initialize it) """
        # eg. struct Apply {uint id; string data;};
        # Apply applyInfo;
        # generate [applyInfo_id, applyInfo_data]
        variables = [f"{s['name']}_{i['dataName']}" for i in globalStructDef[s['type']]]
        # for obj in controlFlowInfo.dataObjects:
        #     if obj['name'] == s['name'] and 'definedStruct' in obj \
        #             and obj['definedStruct'] == 'true':
        #         return f'{s["type"]}({variables})'
        struct_instance = InstantiateAST(s["type"])
        for var in variables:
            struct_instance.add_arg(var)
        # return f'{s["type"]}({variables})'
        return struct_instance

    res = []
    if node_id in parameterInfo:
        local_params = parameterInfo[node_id]["input" if isInput else "output"]

        expand_params : list[ParameterInfo] = []
        for p in local_params:
            if is_struct(p['type']) and obj == 'split':
                # 将结构体中的成员拆分出来为若干单独的变量
                for i in globalStructDef[p['type']]:
                    if i['dataType'] == 'array':
                        expand_params.append(ParameterInfo(generate_array_type(i),
                                                           f"{p['name']}_{i['dataName']}"))
                    else:
                        expand_params.append(ParameterInfo(i['dataType'],
                                                           f"{p['name']}_{i['dataName']}"))
            elif is_struct(p['type']) and obj == 'detail':
                # 以点的形式引用结构体中的变量
                for i in globalStructDef[p['type']]:
                    expand_params.append(ParameterInfo(i['dataType'],
                                                       f"{p['name']}.{i['dataName']}"))
            else:
                expand_params.append(p)

        if len(expand_params) > 0:
            if hasType:
                for i in expand_params:
                    # 对于结构体，要引用主合约中定义的结构体
                    para_type = f'{i["type"]}' if is_struct(i["type"]) else f'{i["type"]}'
                    para_type += f'{" memory" if should_memory(i["type"]) and has_memory else ""}'
                    res.append(para_type)
                    res.append(f'{i["name"]}')

            elif obj == 'create':
                # create用于调用函数时填写变量，所以不需要写变量的类型
                res = []
                for i in expand_params:
                    if is_struct(i['type']):
                        res.append(create_obj(i))
                    else:
                        res.append(i['name'])
                # res = [create_obj(i) if is_struct(i['type']) else i['name'] for i in expand_params]
            else:
                res = [i["name"] for i in expand_params]

    return res


def convert_one(controlFlowInfo, filename, lang, save_as_sol):
    """ Convert BPMN to Intermediate Representation """

    for node_id in controlFlowInfo.sources:
        start = globalNodeMap.get(node_id)
        if 'eventDefinitions' in start and \
                len(start['eventDefinitions']) > 0 and \
                is_instance(start['eventDefinitions'][0]['$type'], 'bpmn:MessageEventDefinition') \
                and node_id not in controlFlowInfo.nodeList:
            controlFlowInfo.nodeList.append(node_id)

    part1 = []  # node with external call
    part2 = []  # node without external call

    for node_id in controlFlowInfo.nodeList:
        if has_external_call(node_id):
            part1.append(node_id)
        else:
            part2.append(node_id)

    controlFlowInfo.nodeList = part1 + part2

    for index, node_id in enumerate(controlFlowInfo.nodeList):
        node = globalNodeMap.get(node_id)
        controlFlowInfo.nodeIndexMap[node_id] = index + 1
        globalNodeIndexMap[node_id] = index + 1
        controlFlowInfo.nodeNameMap[node_id] = get_node_name(node)

        inParameters = []
        outParameters = []

        toIterate = generate_local_params(node, True, False)
        for i in range(0, len(toIterate), 2):
            inParameters.append(ParameterInfo(toIterate[i], toIterate[i + 1]))
        toIterate = generate_local_params(node, False, False)
        for i in range(0, len(toIterate), 2):
            outParameters.append(ParameterInfo(toIterate[i], toIterate[i + 1]))

        # Here, the 'input' or 'output' means in/output for BPMN nodes,
        # for function xxxxx_complete, the function input should be 'output'
        parameters = {'input': inParameters, 'output': outParameters}
        controlFlowInfo.localParameters[node_id] = parameters

    for index, edgeId in enumerate(controlFlowInfo.edgeList):
        controlFlowInfo.edgeIndexMap[edgeId] = index + 1
        globalEdgeIndexMap[edgeId] = index + 1

    # Global inits
    program_ast = ProgramAST()

    #######################################################
    #
    # Process Contract
    #
    #######################################################
    process_contract = ContractAST(filename + "_Contract")

    # declare state variables
    process_contract.add2list(
        DeclStateVarAST(
            "uint", 
            "marking", 
            "public", 
            subprocessStartMarking(get_process_id(controlFlowInfo), controlFlowInfo))
    )
    process_contract.add2list(
        DeclStateVarAST("uint", "startedActivities", "public", "0")
    )

    # declare events
    messages_nodes = get_throwing_messages(controlFlowInfo)
    for node_id in messages_nodes:
        event = DeclEventAST(node_id + "_Message")
        event.set_param("string", "messageText")
        process_contract.add2list(event)

    if ALL_EVENTS:
        event = DeclEventAST("execution_progress")
        event.set_param("string", "msg")
        process_contract.add2list(event)

    # declare global variables, get mapping assign list as return value
    assign_list = globalDeclarations(controlFlowInfo, process_contract)

    # define contract constructor, initialize mapping assign statement here
    constructor_func = FuncDefAST("constructor", "")
    process_contract.add2list(constructor_func)
    for assign in assign_list:
        constructor_func.set_funcbody(assign)

    # define function startExecution
    start_marking = subprocessStartMarking(get_process_id(controlFlowInfo), controlFlowInfo)
    func = FuncDefAST("startExecution", "public")
    bool_expr1 = BoolExprAST("marking", "==", CastAST(start_marking, "uint"))
    bool_expr2 = BoolExprAST("startedActivities", "==", CastAST(0, "uint"))
    req_expr = BoolExprAST(bool_expr1, "&&", bool_expr2)
    func.set_funcbody(RequireAST(req_expr))
    func_call = FuncCallAST("step", cross=False)
    func_call.add_arg(CastAST(start_marking, "uint"))
    func_call.add_arg("0")
    func.set_funcbody(func_call)
    process_contract.add2list(func)

    # define function xxxxx_complete(<Data_to_import>)
    grouped_ids = get_work_items_group_by_parameters(controlFlowInfo)
    for id_group in grouped_ids.values():
        func = FuncDefAST(f"{nodeName(id_group[0])}_complete", "internal")
        func.set_param("uint", "elementIndex", is_input=True)
        for arg in controlFlowInfo.localParameters[id_group[0]]['output']:
            arg_type = arg.type
            if should_memory(arg.type):
                arg_type += " memory"
            func.set_param(arg_type, arg.name, is_input=True)

        func.set_funcbody(DeclLocalVarAST("uint", "tmpMarking", "", "marking"))
        func.set_funcbody(DeclLocalVarAST("uint", "tmpStartedActivities", "", "startedActivities"))

        node = globalNodeMap.get(id_group[0])

        for node_id in id_group:
            if_ast = IfAST()
            # elementIndex is used to identifies the element in the process contract
            bool_expr = BoolExprAST("elementIndex", "==", CastAST(nodeRealIndex(node_id), "uint"))
            if_ast.add_cond_stmt(bool_expr)
            if_ast.cond_stmt[bool_expr].append(
                RequireAST(
                    BoolExprAST(
                        BitwiseOpAST('tmpStartedActivities', '&', CastAST(flowNodeIndex(node_id), "uint")),
                        "!=",
                        "0"
                    )
                )
            )

            code_snippet = nodeFunctionBody(node_id)
            if code_snippet is not None:
                if_ast.cond_stmt[bool_expr].append(code_snippet)

            if 'dataOutputAssociations' in node:
                for ass in node['dataOutputAssociations']:
                    if_ast.cond_stmt[bool_expr].append(
                        AssignAST(f'_{ass["targetRef"]["name"]}',
                                  f'{ass["targetRef"]["name"]}'))

            func_call = FuncCallAST("step", False)
            func_call.add_arg(
                BitwiseOpAST('tmpMarking', '|', CastAST(postMarking(controlFlowInfo, node_id), "uint"))
            )
            func_call.add_arg(
                BitwiseOpAST('tmpStartedActivities', '&',
                             BitwiseOpAST(CastAST(flowNodeIndex(node_id), "uint"), '~'))
            )
            if_ast.cond_stmt[bool_expr].append(func_call)

            if_ast.cond_stmt[bool_expr].append(ReturnAST())
            func.set_funcbody(if_ast)

        process_contract.add2list(func)


    # step function
    func = FuncDefAST("step", "internal")
    func.set_param("uint", "tmpMarking")
    func.set_param("uint", "tmpStartedActivities")

    while_ast = WhileAST(BoolExprAST("true"))
    for node_id in controlFlowInfo.nodeList:
        node = globalNodeMap.get(node_id)
        nodePreMarking = preMarking(controlFlowInfo, node_id)
        nodePostMarking = postMarking(controlFlowInfo, node_id)

        if_ast = IfAST()
        bool_expr : BoolExprAST
        if is_instance(node['$type'], 'bpmn:ParallelGateway') or \
                is_instance(node['$type'], 'bpmn:EventBasedGateway'):
            bool_expr = BoolExprAST(
                BitwiseOpAST('tmpMarking', '&', CastAST(nodePreMarking, "uint")),
                "==",
                CastAST(nodePreMarking, "uint")
            )
        else:
            bool_expr = BoolExprAST(
                    BitwiseOpAST('tmpMarking', '&', CastAST(nodePreMarking, "uint")),
                    "!=",
                    "0"
            )
        if_ast.add_cond_stmt(bool_expr)

        if ALL_EVENTS:
            emit_event = EmitEventAST("execution_progress")
            emit_event.add_arg(f'"{node_id}"')
            if_ast.cond_stmt[bool_expr].append(emit_event)

        if_ast.cond_stmt[bool_expr].append(
            AssignAST("tmpMarking",
                      BitwiseOpAST('tmpMarking', '&', BitwiseOpAST(CastAST(nodePreMarking, "uint"), '~')))
        )

        # Exclusive Gateway
        if is_instance(node['$type'], 'bpmn:ExclusiveGateway'):
            if "outgoing" in node and len(node["outgoing"]) > 1:
                inner_if_ast = IfAST()
                for outgoing in sorted(node['outgoing'], key=lambda x: 'conditionExpression' in x,
                                       reverse=True):
                    inner_bool_expr = getCondition(outgoing)
                    inner_if_ast.add_cond_stmt(
                        inner_bool_expr,
                        AssignAST("tmpMarking",
                                  BitwiseOpAST('tmpMarking', '|', CastAST(flowEdgeIndex(outgoing["id"]), "uint")))
                    )
                if_ast.cond_stmt[bool_expr].append(inner_if_ast)
            else:
                if_ast.cond_stmt[bool_expr].append(
                    AssignAST("tmpMarking",
                              BitwiseOpAST('tmpMarking', '|', CastAST(nodePostMarking, "uint")))
                )

        # Parallel Gateway | Event-based Gateway
        elif is_instance(node['$type'], 'bpmn:ParallelGateway') or \
                is_instance(node['$type'], 'bpmn:EventBasedGateway'):
            if_ast.cond_stmt[bool_expr].append(
                    AssignAST("tmpMarking",
                              BitwiseOpAST('tmpMarking', '|', CastAST(nodePostMarking, "uint")))
            )

        # Tasks
        elif (is_instance(node['$type'], 'bpmn:Task') or \
              is_instance(node['$type'], 'bpmn:DiyTask')):

            # User Task / Service Task / Diy Task
            if  (is_instance(node['$type'], 'bpmn:UserTask') or \
                 is_instance(node['$type'], 'bpmn:ServiceTask')):

                inner_func_call = FuncCallAST(f"{nodeName(node_id)}_start", cross=True)
                inner_func_call.add_arg(f"{nodeRealIndex(node_id)}")
                for arg in controlFlowInfo.localParameters[node_id]['input']:
                    inner_func_call.add_arg('_' + arg.name)
                if_ast.cond_stmt[bool_expr].append(inner_func_call)

                if_ast.cond_stmt[bool_expr].append(
                    AssignAST("tmpStartedActivities",
                              BitwiseOpAST('tmpStartedActivities', '|',
                                           CastAST(flowNodeIndex(node["id"]), "uint")))
                )
                # 不需要加 tmpMarking |= uint({nodePostMarking})，因为这个外部任务只是开启了
                # 但没有完成，edge并不能向前推进edge

            # Script Task
            elif is_instance(node['$type'], 'bpmn:ScriptTask'):
                code_snippet = nodeFunctionBody(node_id)
                if code_snippet is not None:
                    if_ast.cond_stmt[bool_expr].append(code_snippet)
                if_ast.cond_stmt[bool_expr].append(
                    AssignAST("tmpMarking",
                              BitwiseOpAST('tmpMarking', '|', CastAST(nodePostMarking, "uint")))
                )
                # script可以自动完成，所以推进 tmpMarking

            # Send Task
            elif is_instance(node['$type'], 'bpmn:SendTask'):
                emit_event = EmitEventAST(f'{node_id}_Message_{node["name"]}')
                for arg in controlFlowInfo.localParameters[node_id]['input']:
                    # event_arg = '_' + arg.name
                    # emit_event.add_arg(f'"{event_arg}"')
                    emit_event.add_arg('_' + arg.name)
                if_ast.cond_stmt[bool_expr].append(emit_event)

                event = DeclEventAST(f'{node_id}_Message_{node["name"]}')
                for arg in controlFlowInfo.localParameters[node_id]['input']:
                    event.set_param(arg.type, arg.name)

                process_contract.add2list(event)
                if_ast.cond_stmt[bool_expr].append(
                    AssignAST("tmpMarking",
                              BitwiseOpAST('tmpMarking', '|', CastAST(nodePostMarking, "uint"))
                    )
                )

            else:
                if_ast.cond_stmt[bool_expr].append(
                    AssignAST("tmpMarking",
                              BitwiseOpAST('tmpMarking', '|', CastAST(nodePostMarking, "uint"))
                    )
                )

        # End Event
        elif is_instance(node['$type'], 'bpmn:EndEvent'):
            evtType = eventType(node_id)
            if evtType in ("Default", "Message"):
                if evtType == "Message":
                    emit_event = EmitEventAST(f'{node_id}_Message')
                    emit_event.add_arg(f'"{nodeName(node_id)}"')
                    if_ast.cond_stmt[bool_expr].append(emit_event)

                inner_if_ast = IfAST()
                inner_bool_expr = BoolExprAST(
                    BoolExprAST(
                        BitwiseOpAST('tmpMarking', '&',
                            CastAST(subprocessFullMarking(controlFlowInfo, node["$parent"]["id"]), "uint")),
                        "==", 
                        "0"
                    ),
                    "&&",
                    BoolExprAST(
                        BitwiseOpAST('tmpStartedActivities', '&', 
                            CastAST(subprocessNodeMarking(node["$parent"]["id"]), "uint")),
                        "==",
                        "0"
                    )
                )

                if node["$parent"]["id"] == get_process_id(controlFlowInfo):
                    if 'triggerByEvent' in globalNodeMap.get(node["$parent"]["id"]):
                        inner_if_ast.cond_stmt[inner_bool_expr].append(
                            AssignAST(
                                "tmpStartedActivities",
                                BitwiseOpAST('tmpStartedActivities', '&', 
                                    BitwiseOpAST(str(flowNodeIndex(node["$parent"]["id"])), "~"))
                            )
                        )
                else:
                    inner_if_ast.cond_stmt[inner_bool_expr].append(
                        AssignAST(
                            "tmpStartedActivities", 
                            BitwiseOpAST('tmpStartedActivities', '&', 
                                BitwiseOpAST(str(flowNodeIndex(node["$parent"]["id"])), "~"))
                        )
                    )
                    inner_if_ast.cond_stmt[inner_bool_expr].append(
                        AssignAST(
                            "tmpMarking",
                            BitwiseOpAST('tmpMarking', '|',
                                         CastAST(postMarking(controlFlowInfo, node["$parent"]["id"]), "uint"))
                        )
                    )

                if_ast.cond_stmt[bool_expr].append(inner_if_ast)

        # Intermediate Throw Event
        elif is_instance(node['$type'], 'bpmn:IntermediateThrowEvent'):
            evtType = eventType(node_id)

            if evtType == 'Message':
                emit_event = EmitEventAST(f'{node_id}_Message')
                emit_event.add_arg(f'"{nodeName(node_id)}"')
                if_ast.cond_stmt[bool_expr].append(emit_event)

            if_ast.cond_stmt[bool_expr].append(
                AssignAST("tmpMarking", BitwiseOpAST('tmpMarking', '|', CastAST(nodePostMarking, "uint")))
            )

        # Unsupported BPMN elements
        else:
            raise NotImplementedError("Unsupported BPMN element")

        if_ast.cond_stmt[bool_expr].append(ContinueAST())
        while_ast.stmt.append(if_ast)

    while_ast.stmt.append(BreakAST())
    func.set_funcbody(while_ast)


    if_ast = IfAST()
    bool_expr = BoolExprAST(
        BoolExprAST("marking", "!=", "0"),
        "||",
        BoolExprAST("startedActivities", "!=", "0")
    )
    if_ast.add_cond_stmt(bool_expr)
    if_ast.cond_stmt[bool_expr].append(
        AssignAST("marking", "tmpMarking")
    )
    if_ast.cond_stmt[bool_expr].append(
        AssignAST("startedActivities", "tmpStartedActivities")
    )

    func.set_funcbody(if_ast)
    process_contract.add2list(func)
    program_ast.contract_list.append(process_contract)


    userTaskList = {}       # node that need to interact with external resources
    parameterInfo = {}      # dict[node_id] = input/output Parameter
    for node_id in controlFlowInfo.nodeList:
        node = globalNodeMap.get(node_id)
        if is_instance(node['$type'], 'bpmn:UserTask') or \
                is_instance(node['$type'], 'bpmn:ServiceTask') or \
                is_instance(node['$type'], 'bpmn:ReceiveTask'):
            userTaskList[node_id] = node['$type']
            if node_id in controlFlowInfo.localParameters and \
                    (len(controlFlowInfo.localParameters.get(node_id).get('input')) or
                     len(controlFlowInfo.localParameters.get(node_id).get('output'))):
                parameterInfo[node_id] = controlFlowInfo.localParameters.get(node_id)


    struct_def = DefStructAST("Workitem")
    struct_def.ability_list.append("store")
    struct_def.var_name.append("elementIndex")
    struct_def.var_type.append("uint")
    struct_def.var_name.append("operated")
    struct_def.var_type.append("bool")
    process_contract.add2list(struct_def)

    state_var = DeclStateVarAST("Workitem[]", "workitems", "private")
    process_contract.add2list(state_var)

    grouped_ids = get_work_items_group_by_parameters(controlFlowInfo)
    for id_group in grouped_ids.values():
        node_id = id_group[0]
        event = DeclEventAST(f"{worklist_nodeName(node_id)}_Requested")
        event.set_param("uint", "index")


        # worklist_args: [type, name, type, name ....]
        worklist_args = get_worklist_param(controlFlowInfo, parameterInfo, node_id,
                                            True, True, True, obj="split", has_memory=False)
        for idx in range(0, len(worklist_args), 2):
            event.set_param(worklist_args[idx], worklist_args[idx + 1])

        process_contract.add2list(event)


    # function xxxxx_start
    for id_group in grouped_ids.values():
        node_id = id_group[0]

        func = FuncDefAST(f"{worklist_nodeName(node_id)}_start", "internal")
        func.set_param("uint", "elementIndex")

        worklist_args = get_worklist_param(controlFlowInfo, parameterInfo, node_id,
                                           True, True, True)
        for idx in range(0, len(worklist_args), 2):
            func.set_param(worklist_args[idx], worklist_args[idx + 1])

        workitem_instance = InstantiateAST("Workitem")
        workitem_instance.add_arg("elementIndex")
        workitem_instance.add_arg("false")
        func.set_funcbody(
            ArrOperationAST("workitems", "push", workitem_instance))

        if userTaskList[node_id] == 'bpmn:UserTask':
            local_var0 = DeclLocalVarAST('uint', 'tmp0', expr=ArrOperationAST('workitems', 'len'))
            func.set_funcbody(local_var0)
            local_var1 = DeclLocalVarAST('uint', 'tmp1', expr='tmp0 - 1')
            func.set_funcbody(local_var1)
            emit_event = EmitEventAST(f'{worklist_nodeName(node_id)}_Requested')
            emit_event.add_arg("tmp1")
            worklist_args = get_worklist_param(controlFlowInfo, parameterInfo, node_id,
                                               True, False, True, obj="detail")
            for arg in worklist_args:
                emit_event.add_arg(str(arg))

            func.set_funcbody(emit_event)

        elif userTaskList[node_id] == 'bpmn:ServiceTask':
            local_var0 = DeclLocalVarAST('uint', 'tmp0', expr=ArrOperationAST('workitems', 'len'))
            func.set_funcbody(local_var0)
            local_var1 = DeclLocalVarAST('uint', 'tmp1', expr='tmp0 - 1')
            func.set_funcbody(local_var1)
            emit_event = EmitEventAST(f'{worklist_nodeName(node_id)}_Requested')
            emit_event.add_arg("tmp1")
            node = globalNodeMap.get(node_id)

            if 'dataInputAssociations' in node:
                for association in node['dataInputAssociations']:
                    if is_instance(association['sourceRef'][0]['$type'], 'bpmn:DataStoreReference')\
                            and 'storeType' in association['sourceRef'][0]:
                        emit_event.add_arg('"outsideFlag"')
                        emit_event.add_arg(f'"{association["sourceRef"][0]["storeType"]}"')

            worklist_args = get_worklist_param(controlFlowInfo, parameterInfo, node_id,
                                               True, False, True)
            for arg in worklist_args:
                emit_event.add_arg(str(arg))

            func.set_funcbody(emit_event)

        process_contract.add2list(func)

    # function xxxxxx
    grouped_ids = get_work_items_group_by_parameters(controlFlowInfo)
    for id_group in grouped_ids.values():
        node_id = id_group[0]

        func = FuncDefAST(f"{worklist_nodeName(node_id)}", "external")
        func.set_param("uint", "workitemId")

        worklist_args = get_worklist_param(controlFlowInfo, parameterInfo, node_id,
                                           False, True, True, obj="split")
        for idx in range(0, len(worklist_args), 2):
            func.set_param(worklist_args[idx], worklist_args[idx + 1])

        node = globalNodeMap.get(node_id)


        func.set_funcbody(
            RequireAST(
                BoolExprAST(
                    BoolExprAST("workitemId", "<", ArrOperationAST('workitems', 'len')),
                    "&&",
                    BoolExprAST(
                        ArrOperationAST('workitems', 'read', '(workitemId as u64)', 'operated'),
                        "!=",
                        "true")
                )
            )
        )


        func_call = FuncCallAST(f'{worklist_nodeName(node_id)}_complete')
        func_call.add_arg(ArrOperationAST('workitems', 'read', '(workitemId as u64)', 'elementIndex'))
        worklist_args = get_worklist_param(controlFlowInfo, parameterInfo, node_id,
                                           False, False, True, obj="create")
        for arg in worklist_args:
            func_call.add_arg(arg)

        func.set_funcbody(func_call)

        func.set_funcbody(
            ArrOperationAST('workitems', 'set', '(workitemId as u64)', 'operated', 'true')
        )
        process_contract.add2list(func)


    if save_as_sol:
        assert(lang in ('solidity', 'move'))
        if lang == 'solidity':
            # program_code = program_ast.solidity_ver()
            program_code = sol_translate(program_ast, "")
        elif lang == 'move':
            program_code = program_ast.move_ver()
        else:
            assert(False)
        current_dir = os.path.dirname(os.path.abspath(__file__))
        if lang == 'solidity':
            output_path = f'./outputs/test/{filename}.sol'
        elif lang == 'move':
            output_path = f'./outputs/move/{filename}.move'

        abs_path = os.path.join(current_dir, output_path)
        with open(abs_path, 'w') as f:
            f.write(program_code)
        # print(program_code)


def convert_bpmn_to_sol(proc, filename, lang, save_as_sol):
    globalNodeMap[proc["id"]] = proc
    collect_control_flow_info(proc, globalNodeMap, globalControlFlowInfo)

    # 若不考虑子进程调用，则通常只有一个controlFlowInfo
    for controlFlowInfo in globalControlFlowInfo:
        globalControlFlowInfoMap[controlFlowInfo.proc['id']] = controlFlowInfo

    for controlFlowInfo in globalControlFlowInfo:
        convert_one(controlFlowInfo, filename, lang, save_as_sol)

