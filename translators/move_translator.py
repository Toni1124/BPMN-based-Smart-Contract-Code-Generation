from ir_def import *

def borrow_from_deployer(resource_name:str, member_var_name:str, mut:bool=False) -> str:
    """ Borrow resource object from module deployer account """
    res = "borrow_global"
    if mut:
        res += "_mut"
    res += f'<{resource_name}>(@deployer).{member_var_name}'

    if current_func_name in func_acquires:
        if resource_name not in func_acquires[current_func_name]:
            func_acquires[current_func_name].append(resource_name)
    else:
        func_acquires[current_func_name] = [resource_name]

    return res

def trans_DefStructAST(obj : DefStructAST, indent: str) -> str:
    var_list = []
    res = f'{indent}struct {obj.identifier} '
    for idx, ability in enumerate(obj.ability_list):
        if idx == 0:
            res += f"has {ability}"
        else:
            res += f", {ability}"
    res += " {\n"

    for idx, var_name in enumerate(obj.var_name):
        res += f'{indent}   {var_name}: '
        if obj.var_type[idx] in type_map:
            res += f"{type_map[obj.var_type[idx]]},\n"
        elif "mapping" in obj.var_type[idx]:
            res += "simple_map::SimpleMap,\n"
        else:
            res += f'{obj.var_type[idx]},\n'
        var_list.append((var_name, obj.var_type[idx]))
    res += f"{indent}}}\n"

    struct_structure_map[obj.identifier] = var_list

    if "key" in obj.ability_list:
        resource_names.add(obj.identifier)

    return res  


def trans_ArrOperationAST(obj : ArrOperationAST, indent: str) -> str:
    res = indent
    resource_name = obj.identifier.replace('_', '', 1).capitalize()
    assert(resource_name in struct_structure_map)

    if obj.operation == 'push':
        res += f'vector::push_back<{obj.obj.type}>'
        res += f'(&mut {borrow_from_deployer(resource_name, obj.identifier, True)}, '
        res += f'{move_translate(obj.obj, "")}'
        res = res[:-1]
        res += ');\n'

    elif obj.operation == 'set':
        resource_struct = struct_structure_map[resource_name]
        element_type = resource_struct[0][1]
        var_name = resource_struct[0][0]
        element_type = element_type[element_type.find('<') + 1: element_type.find('>')]
        res += f'vector::borrow_mut<{element_type}>(&mut '
        res += borrow_from_deployer(resource_name, var_name, True)
        res += f', {obj.obj}).{obj.field} = {obj.value};\n'

    elif obj.operation == 'len':
        var_type = struct_structure_map[resource_name][0][1]
        var_type = var_type[var_type.find('<') + 1 : var_type.find('>')]
        res += f'(vector::length<{var_type}>(&{borrow_from_deployer(resource_name, obj.identifier)}) as u128)'

    elif obj.operation == "read":
        resource_struct = struct_structure_map[resource_name]
        element_type = resource_struct[0][1]
        var_name = resource_struct[0][0]
        element_type = element_type[element_type.find('<') + 1: element_type.find('>')]
        res += f'vector::borrow<{element_type}>(&'
        res += borrow_from_deployer(resource_name, var_name)
        res += f', {obj.obj}).{obj.field}'

    return res


def trans_DeclLocalVarAST(obj : DeclLocalVarAST, indent: str) -> str:
    res = f'{indent}let '
    if obj.type in type_map:
        res += f'{obj.identifier}: {type_map[obj.type]}'
    else:
        res += f'{obj.identifier}: {obj.type}'
    if isinstance(obj.expr, str):
        if obj.expr != "":
            resource_name = obj.expr.replace('_', '', 1).capitalize()
            if resource_name in resource_names:
                res += f' = {borrow_from_deployer(resource_name, obj.expr, False)}'
            else:
                res += f' = {obj.expr}'
    else:
        res += f' = {move_translate(obj.expr, "")}'
    res += ';\n'

    return res


def trans_DeclStateVarAST(obj : DeclStateVarAST, indent: str) -> str:
    resource_name = obj.identifier.replace('_', '', 1).capitalize()
    resource_names.add(resource_name)

    res = f'{indent}struct {resource_name} has key, store {{\n'
    if obj.identifier == "workitems":
        res += f'{indent}   workitems: vector<Workitem>\n'
        struct_structure_map[resource_name] = [("workitems", 'vector<Workitem>')]
    else:
        res += f'{indent}   {obj.identifier}: '
        var_type = obj.type
        if obj.type in type_map:
            var_type = type_map[obj.type]
            res += f"{type_map[obj.type]},\n"
        elif "mapping" in obj.type:
            key_val = obj.type[obj.type.find('(') + 1: obj.type.find(')')]
            key_type = key_val[:key_val.find('=')]
            val_type = key_val[key_val.find('>')+1:]
            if key_type in type_map:
                key_type = type_map[key_type]
            if val_type in type_map:
                val_type = type_map[val_type]

            mapping_structure[resource_name] = [key_type, val_type]
            res += "simple_map::SimpleMap<"
            res += f'{key_type}, {val_type}>,\n'
        else:
            res += f'{obj.type},\n'
        struct_structure_map[resource_name] = [(obj.identifier, var_type)]
    res += f'{indent}}}\n'

    # 初始化在init module里做
    if obj.expr != "":
        resource_init_map[resource_name] = [obj.expr]
    res += '\n'

    return res


def trans_DeclEventAST(obj : DeclEventAST, indent: str) -> str:
    var_list = []
    res = f'{indent}#[event]\n'
    res += f'{indent}struct {obj.identifier.capitalize()} has drop, store {{\n'
    for idx, var_type in enumerate(obj.param_type):
        res += f'{indent}   {obj.param_ident[idx]}: '
        if var_type in type_map:
            res += f"{type_map[var_type]}, \n"
        elif "mapping" in var_type:
            res += "simple_map::SimpleMap,\n"
        else:
            res += f'{var_type}, \n'
        var_list.append((obj.param_ident[idx], var_type))
    res += f"{indent}}}\n\n"

    struct_structure_map[obj.identifier.capitalize()] = var_list
    return res


def trans_AssignAST(obj : AssignAST, indent: str) -> str:
    res = indent
    resource_name = obj.identifier.replace('_', '', 1).capitalize()
    if resource_name in resource_names:
        res += borrow_from_deployer(resource_name, obj.identifier, True)
        res += f' = {obj.expr};\n'
    else:
        res += f'{obj.identifier} = '
        if isinstance(obj.expr, str):
            res += obj.expr
        else:
            res += f'{move_translate(obj.expr, "")}'
        res += ';\n'

    return res


def trans_CastAST(obj : CastAST, indent: str) -> str:
    res = f'{indent}{obj.num}'
    if obj.type == "uint":
        res += 'u128'
    else:
        raise TypeError

    return res


def trans_BitwiseOpAST(obj : BitwiseOpAST, indent: str) -> str:
    res = indent
    if obj.right_expr == None:
        if obj.operator == '~':
            res += '0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ '
        else:
            res += obj.operator + ' '
    else:
        if isinstance(obj.right_expr, str):
            res += obj.right_expr
        else:
            res += f'({move_translate(obj.right_expr, "")})'
        res += f' {obj.operator} '

    if isinstance(obj.left_expr, str):
        res += obj.left_expr
    else:
        res += f'({move_translate(obj.left_expr, "")})'
    return res


def trans_BoolExprAST(obj : BoolExprAST, indent: str) -> str:
    res = indent
    if isinstance(obj.left_expr, str):
        resource_name = obj.left_expr.replace('_', '', 1).capitalize()
        if resource_name.find('[') != -1:
            resource_name = resource_name[:resource_name.find('[')]

        if resource_name in resource_names:
            if resource_name in mapping_structure:
                map_structure = mapping_structure[resource_name]
                key_val = obj.left_expr[obj.left_expr.find('[') + 1: obj.left_expr.find(']')]
                res += f'simple_map::borrow<{map_structure[0]}, {map_structure[1]}>(&'
                res += borrow_from_deployer(resource_name, obj.left_expr[:obj.left_expr.find('[')])
                key_name = key_val.replace('_', '', 1).capitalize()
                if key_name in resource_names:
                    res += f', &{borrow_from_deployer(key_name, key_val)})'
                else:
                    res += f', {key_val})'
            else:
                res += borrow_from_deployer(resource_name, obj.left_expr)
        else:
            res += obj.left_expr
        if obj.operator is None:
            assert(resource_name in struct_structure_map)
            var_type = struct_structure_map[resource_name][0][1]
            if '=>' in var_type:
                var_type = var_type[var_type.find('>'):]
            if var_type.find('bool') == -1:
                res += ' != 0'
            elif res.endswith(')'):
                res = res[:len(indent)] + '*' + res[len(indent):]

    else:
        res += move_translate(obj.left_expr, indent)

    if obj.operator is not None:
        res += ' ' + obj.operator

    if isinstance(obj.right_expr, str):
        expr_name = obj.right_expr.replace('_', '', 1).capitalize()
        if expr_name in resource_names:
            res += borrow_from_deployer(expr_name, obj.right_expr)
        else:
            res += ' ' + obj.right_expr
    elif obj.right_expr is not None:
        res += ' ' + move_translate(obj.right_expr, indent)
    
    return res


def trans_RequireAST(obj : RequireAST, indent: str) -> str:
    res = f"{indent}assert!("
    res += move_translate(obj.bool_expression, "")
    res += ", 0);\n"

    return res


def trans_IfAST(obj : IfAST, indent: str) -> str:
    res = ""
    for cond, stmts in obj.cond_stmt.items():
        if cond is not None:
            res += f"{indent}if ("
            res += move_translate(cond, "")
            res += ") {\n"

            for stmt in stmts:
                if stmt is not None:
                    res += move_translate(stmt, indent + "    ")

            res += f"{indent}}}"
            if None in obj.cond_stmt:
                res += '\n'
            else:
                res += ';\n'

    if None in obj.cond_stmt:
        res += f"{indent}else {{\n"

        for stmt in obj.cond_stmt[None]:
            res += move_translate(stmt, indent + "    ")

        res += f"{indent}}};\n"
    
    return res


def trans_WhileAST(obj : WhileAST, indent: str) -> str:
    res = f"{indent}loop {{\n"
    for stmt in obj.stmt:
        res += move_translate(stmt, indent + "    ")
    res += f"{indent}}};\n"

    return res


def trans_ContinueAST(obj : ContinueAST, indent: str) -> str:
    return f"{indent}continue\n"


def trans_BreakAST(obj : BreakAST, indent: str) -> str:
    return f"{indent}break\n"


def trans_EmitEventAST(obj : EmitEventAST, indent: str) -> str:
    resource_name = obj.identifier.capitalize()    # event无需替换
    res = f"{indent}event::emit ({resource_name} {{"
    struct_def = struct_structure_map[resource_name]
    for idx, arg in enumerate(obj.arg_list):
        if idx != 0:
            res += ", "
        res += f'{struct_def[idx][0]}: '

        if isinstance(arg, str):
            func_params = func_signature_map[current_func_name]
            is_param = False
            for param in func_params:
                if arg == param[0]:
                    is_param = True
                    break

            if is_param:
                res += arg
                continue

        if struct_def[idx][1] in instance_map:
            res += instance_map[struct_def[idx][1]][0]
            if arg.startswith('_'):
                arg_name = arg.replace('_', '', 1).capitalize()
                if arg_name in resource_names:
                    res += f'{borrow_from_deployer(arg_name, arg)}'
            else:
                res += f'{arg}'
            res += instance_map[struct_def[idx][1]][1]
        else:
            res += f'{arg}'
    res += "});\n"
    return res


def trans_ReturnAST(obj : ReturnAST, indent: str) -> str:
    res = f"{indent}return"
    arg_str = ""
    for idx, val in enumerate(obj.ret_list):
        if idx != 0:
            arg_str += ", "
        arg_str += val
    if obj.ret_list:
        res += f"({arg_str})"
    res += "\n"
    return res


def trans_FuncCallAST(obj : FuncCallAST, indent: str) -> str:
    # 需要将callee的acquires增添到当前函数的acquires
    if current_func_name not in func_acquires:
        func_acquires[current_func_name] = []

    assert(obj.identifier in func_acquires)
    for resource in func_acquires[obj.identifier]:
        if resource not in func_acquires[current_func_name]:
            func_acquires[current_func_name].append(resource)

    res = f"{indent}{obj.identifier}("
    for idx, arg in enumerate(obj.arg_list):
        if idx != 0:
            res += ", "

        if isinstance(arg, str):
            resource_name = arg.replace('_', '', 1).capitalize()
            func_params = func_signature_map[current_func_name]
            is_param = False
            for param in func_params:
                if arg == param[0]:
                    is_param = True
                    break

            if not is_param and resource_name in resource_names:
                res += f'{borrow_from_deployer(resource_name, arg, False)}'
            else:
                res += arg
        else:
            code = move_translate(arg, "")
            res += code[:-1] if code.endswith(';') else code

    res += ");\n"
    return res


def trans_InstantiateAST(obj : InstantiateAST, indent: str) -> str:
    res = f"{indent}{obj.type}{{"
    struct_def = struct_structure_map[obj.type]
    for idx, arg in enumerate(obj.arg_list):
        res += f'{struct_def[idx][0]}: '
        if struct_def[idx][0] in instance_map:
            res += instance_map[struct_def[idx][0]][0]
        if isinstance(arg, str):
            res += f'{arg}, '
        else:
            res += f'{arg.solidity_ver("")}, '
        if struct_def[idx][0] in instance_map:
            res += instance_map[struct_def[idx][0]][1]

    res += "};"
    return res


def trans_FuncDefAST(obj : FuncDefAST, indent: str) -> str:    
    res = indent
    param_list = []
    global current_func_name
    current_func_name = obj.identifier
    index = 0       # place to insert `acquires`
    if obj.identifier == "constructor":
        res += f'fun init_module(account: &signer)'
        index = len(res)
        res += f' {{\n{indent}    move_to(account, Workitems {{workitems: vector::empty<Workitem>()}});\n'
        for resource, init_val in resource_init_map.items():
            res += f'{indent}    move_to(account, {resource}{{'
            resource_struct = struct_structure_map[resource]
            for idx, var in enumerate(resource_struct):
                init_val_idx = init_val[idx]
                if var[1] in instance_map:
                    init_val_idx = instance_map[var[1]][0] + init_val_idx
                    init_val_idx += instance_map[var[1]][1]
                res += f'{var[0]}: {init_val_idx}, '
            res += '});\n'
        for resource in resource_names:
            if resource in resource_init_map or resource == "Workitems":
                continue
                
            res += f'{indent}    move_to(account, {resource}{{'
            resource_struct = struct_structure_map[resource]
            for var in resource_struct:
                if var[1] in initial_values:
                    res += f'{var[0]}: {initial_values[var[1]]}, '
                elif "mapping" in var[1]:
                    key_val = var[1][var[1].find('(') + 1: var[1].find(')')]
                    key_type = key_val[:key_val.find('=')]
                    val_type = key_val[key_val.find('>')+1:]
                    if key_type in type_map:
                        key_type = type_map[key_type]
                    if val_type in type_map:
                        val_type = type_map[val_type]

                    if resource not in mapping_structure:
                        mapping_structure[resource] = [key_type, val_type]
                    res += f'{var[0]}: simple_map::new<{key_type}, {val_type}>(), '
                elif var[1] in struct_structure_map:        # struct
                    struct_instance = InstantiateAST(var[1])
                    for sub_var in struct_structure_map[var[1]]:
                        struct_instance.add_arg(initial_values[sub_var[1]])
                    res += f'{var[0]}: {move_translate(struct_instance, "")[:-1]}, '
            res += '});\n'
    else:
        if obj.visibility in ("public", "external"):
            res += "public "
        res += f'fun {obj.identifier}('

        for idx, param_name in enumerate(obj.input_param_ident):
            if idx != 0:
                res += ', '
            res += f'{param_name}: '
            param_type = obj.input_param_type[idx].replace('memory', '').strip()
            if param_type in type_map:
                res += type_map[param_type]
            elif "mapping" in param_type:
                res += "simple_map::SimpleMap,\n"
            else:
                res += param_type
            param_list.append((param_name, param_type))

        res += ')'
        index = len(res)
        res += ' {\n'
    func_signature_map[obj.identifier] = param_list

    for stmt in obj.func_body:
        res += move_translate(stmt, indent + "    ")
    res += f"{indent}}}\n"

    acquires_stmt = ""
    if obj.identifier not in func_acquires:
        func_acquires[obj.identifier] = []
    for idx, resource in enumerate(func_acquires[obj.identifier]):
        if idx == 0:
            acquires_stmt += f' acquires {resource}'
        else:
            acquires_stmt += f', {resource}'

    res = res[:index] + acquires_stmt + res[index:]
    return res
    
    
def trans_CodeSnippetAST(obj : CodeSnippetAST, indent: str) -> str:
    if obj.code[-1] not in ('}', ';'):
        obj.code += ';'
    return indent + obj.code + '\n'


def trans_MapOpAST(obj : MapOpAST, indent: str) -> str:
    res = indent
    resource_name = obj.map_name.replace('_', '', 1).capitalize()
    key_type = mapping_structure[resource_name][0]
    val_type = mapping_structure[resource_name][1]
    res += f'simple_map::add<{key_type}, {val_type}>(&mut '
    res += borrow_from_deployer(resource_name, obj.map_name, True)
    res += f', {obj.key_value}, {obj.val_value});\n'
    return res


def trans_ContractAST(obj : ContractAST, indent: str) -> str:
    res = f"{indent}module deployer::{obj.identifier} {{\n"
    res += '    use std::string;\n'
    res += '    use std::bit_vector;\n'
    res += '    use std::vector;\n'
    res += '    use aptos_std::simple_map;\n'
    res += '    use aptos_framework::event;\n\n'
    for struct in obj.struct_list:
        res += move_translate(struct, indent + "    ")
    res += "\n"
    for var in obj.var_list:
        res += move_translate(var, indent + "    ")
    res += "\n"
    for event in obj.event_list:
        res += move_translate(event, indent + "    ")
    res += "\n"
    for code in obj.code_snippet_list:
        res += move_translate(code, indent + "    ")
    res += "\n"

    complete_idx, complete_len = 0, 0
    start_idx, start_len = 0, 0
    for idx, func in enumerate(obj.func_list):
        if '_complete' in func.identifier:
            if complete_idx == 0:
                complete_idx = idx
            complete_len += 1
        if '_start' in func.identifier:
            if start_idx == 0:
                start_idx = idx
            start_len += 1

    sorted_func_list = [obj.func_list[0]]
    sorted_func_list.extend(obj.func_list[start_idx : start_idx + start_len])
    sorted_func_list.append(obj.func_list[start_idx - 1])
    sorted_func_list.append(obj.func_list[1])
    sorted_func_list.extend(obj.func_list[complete_idx : complete_idx + complete_len])
    sorted_func_list.extend(obj.func_list[start_idx + start_len :])

    assert(len(sorted_func_list) == len(obj.func_list))

    for func in sorted_func_list:
        res += move_translate(func, indent + "    ")
        res += "\n"
    res += "}\n"
    return res


def trans_ProgramAST(obj : ProgramAST) -> str:
    obj.code = ''
    res = obj.code
    for contract in obj.contract_list:
        res += move_translate(contract, "")
        res += "\n"
    
    return res


def move_translate(obj, indent: str = "") -> str:
    code = ""
    if isinstance(obj, ProgramAST):
        code = trans_ProgramAST(obj)
    elif isinstance(obj, ContractAST):
        code = trans_ContractAST(obj, indent)
    elif isinstance(obj, DefStructAST):
        code = trans_DefStructAST(obj, indent)
    elif isinstance(obj, ArrOperationAST):
        code = trans_ArrOperationAST(obj, indent)
    elif isinstance(obj, DeclLocalVarAST):
        code = trans_DeclLocalVarAST(obj, indent)
    elif isinstance(obj, DeclStateVarAST):
        code = trans_DeclStateVarAST(obj, indent)
    elif isinstance(obj, DeclEventAST):
        code = trans_DeclEventAST(obj, indent)
    elif isinstance(obj, AssignAST):
        code = trans_AssignAST(obj, indent)
    elif isinstance(obj, CastAST):
        code = trans_CastAST(obj, indent)
    elif isinstance(obj, BitwiseOpAST):
        code = trans_BitwiseOpAST(obj, indent)
    elif isinstance(obj, BoolExprAST):
        code = trans_BoolExprAST(obj, indent)
    elif isinstance(obj, RequireAST):
        code = trans_RequireAST(obj, indent)
    elif isinstance(obj, IfAST):
        code = trans_IfAST(obj, indent)
    elif isinstance(obj, WhileAST):
        code = trans_WhileAST(obj, indent)
    elif isinstance(obj, ContinueAST):
        code = trans_ContinueAST(obj, indent)
    elif isinstance(obj, BreakAST):
        code = trans_BreakAST(obj, indent)
    elif isinstance(obj, EmitEventAST):
        code = trans_EmitEventAST(obj, indent)
    elif isinstance(obj, ReturnAST):
        code = trans_ReturnAST(obj, indent)
    elif isinstance(obj, FuncCallAST):
        code = trans_FuncCallAST(obj, indent)
    elif isinstance(obj, InstantiateAST):
        code = trans_InstantiateAST(obj, indent)
    elif isinstance(obj, FuncDefAST):
        code = trans_FuncDefAST(obj, indent)
    elif isinstance(obj, CodeSnippetAST):
        code = trans_CodeSnippetAST(obj, indent)
    elif isinstance(obj, MapOpAST):
        code = trans_MapOpAST(obj, indent)

    return code

