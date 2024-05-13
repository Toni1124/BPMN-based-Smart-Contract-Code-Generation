from ir_def import *

def trans_DefStructAST(obj : DefStructAST, indent: str) -> str:
    res = f'{indent}struct {obj.identifier} {{\n'
    for idx, var_name in enumerate(obj.var_name):
        res += f'{indent}   {obj.var_type[idx]} {var_name};\n'
    res += f"{indent}}}\n"
    return res    


def trans_ArrOperationAST(obj : ArrOperationAST, indent: str) -> str:
    res = indent
    if isinstance(obj.obj, str) and 'as u' in obj.obj:
        idx = obj.obj[1 : obj.obj.find('as ')].strip()
    if obj.operation == "push":
        res += f"{obj.identifier}.{obj.operation}("
        res += sol_translate(obj.obj, "")
        # delete last ;\n in the res
        res = res[:-2]
        res += ");\n"
    elif obj.operation == "set":
        res += f'{obj.identifier}[{idx}].{obj.field} = {obj.value};\n'
    elif obj.operation == "len":   # get length of the array
        res += f'{obj.identifier}.length'
    elif obj.operation == "read":
        res += f'{obj.identifier}[{idx}].{obj.field}'

    return res


def trans_DeclLocalVarAST(obj : DeclLocalVarAST, indent: str) -> str:
    res = indent + obj.type
    res += f' {obj.identifier}'
    if isinstance(obj.expr, str):
        if obj.expr != '':
            res += f' = {obj.expr}'
    else:
        res += f' = {sol_translate(obj.expr, "")}'
    res += ';\n'
    return res


def trans_DeclStateVarAST(obj : DeclStateVarAST, indent: str) -> str:
    res = indent + obj.type
    if obj.visibility != "":
        res += f' {obj.visibility}'
    res += f' {obj.identifier}'
    if obj.expr != "":
        res += f' = {obj.expr}'
    res += ';\n'

    return res


def trans_DeclEventAST(obj : DeclEventAST, indent: str) -> str:
    res = f"{indent}event {obj.identifier}("
    for idx, param_name in enumerate(obj.param_ident):
        if idx != 0:
            res += ', '
        res += f'{obj.param_type[idx]} {param_name}'
    res += ');\n'
    return res


def trans_AssignAST(obj : AssignAST, indent: str) -> str:
    res = f'{indent}{obj.identifier} = {obj.expr if isinstance(obj.expr, str) else sol_translate(obj.expr, "")};\n'
    return res


def trans_CastAST(obj : CastAST, indent: str) -> str:
    res = f'{indent}{obj.type}({obj.num})'
    return res


def trans_BitwiseOpAST(obj : BitwiseOpAST, indent: str) -> str:
    res = indent
    """ Generate Solidity code, 结尾没有分号 """
    if obj.right_expr == None:
        res += obj.operator
    else:
        if isinstance(obj.right_expr, str):
            res += obj.right_expr
        else:
            res += sol_translate(obj.right_expr, "")
        res += f' {obj.operator} '

    if isinstance(obj.left_expr, str):
        res += obj.left_expr
    else:
        res += sol_translate(obj.left_expr, "")
    return res


def trans_BoolExprAST(obj : BoolExprAST, indent: str) -> str:
    res = indent
    if isinstance(obj.left_expr, str):
        if 'as u' in obj.left_expr:
            res += obj.left_expr[1 : obj.left_expr.find('as ')].strip()
        else:
            res += obj.left_expr
    else:
        res += sol_translate(obj.left_expr, indent)

    if obj.operator is not None:
        res += ' ' + obj.operator

    if isinstance(obj.right_expr, str):
        res += ' ' + obj.right_expr
    elif obj.right_expr is not None:
        res += ' ' + sol_translate(obj.right_expr, indent)

    return res


def trans_RequireAST(obj : RequireAST, indent: str) -> str:
    res = f"{indent}require("
    res += sol_translate(obj.bool_expression, "")
    res += ");\n"
    return res


def trans_IfAST(obj : IfAST, indent: str) -> str:
    """ Generate Solidity code, note that if there's no statement following
        a if condition, it won't generate this if condition (including the condition) """
    res = ""
    for cond, stmts in obj.cond_stmt.items():
        if cond is not None:
            res += f"{indent}if ("
            res += sol_translate(cond, "")
            res += ") {\n"

            for stmt in stmts:
                if stmt is not None:
                    res += sol_translate(stmt, indent + "    ")

            res += f"{indent}}}\n"

    if None in obj.cond_stmt:
        res += f"{indent}else {{\n"

        for stmt in obj.cond_stmt[None]:
            res += sol_translate(stmt, indent + "    ")

        res += f"{indent}}}\n"

    return res


def trans_WhileAST(obj : WhileAST, indent: str) -> str:
    res = f"{indent}while("
    res += sol_translate(obj.cond, "")
    res += "){\n"
    for stmt in obj.stmt:
        res += sol_translate(stmt, indent + "    ")
    res += f"{indent}}}\n"
    return res


def trans_ContinueAST(obj : ContinueAST, indent: str) -> str:
    return f"{indent}continue;\n"


def trans_BreakAST(obj : BreakAST, indent: str) -> str:
    return f"{indent}break;\n"


def trans_EmitEventAST(obj : EmitEventAST, indent: str) -> str:
    res = f"{indent}emit {obj.identifier}("
    for idx, arg in enumerate(obj.arg_list):
        if idx != 0:
            res += ", "
        if 'as u' in arg:
            arg = arg[1 : arg.find('as')].strip()
        res += arg
    res += ");\n"
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
    res += ";\n"
    return res


def trans_FuncCallAST(obj : FuncCallAST, indent: str) -> str:
    res = f"{indent}{obj.identifier}("
    for idx, arg in enumerate(obj.arg_list):
        if idx != 0:
            res += ", "

        if isinstance(arg, str):
            res += arg
        else:
            code = sol_translate(arg, "")
            res += code[:-2] if code.endswith(';\n') else code

    res += ");\n"
    return res


def trans_InstantiateAST(obj : InstantiateAST, indent: str) -> str:
    res = f"{indent}{obj.type}("
    for idx, arg in enumerate(obj.arg_list):
        if idx != 0:
            res += ", "

        if isinstance(arg, str):
            res += arg
        else:
            res += sol_translate(arg, "")

    res += ")"

    if obj.func_call:
        res += "."
        for func_call in obj.func_call:
            res += sol_translate(func_call, "")

    if not obj.func_call:
        res += ";\n"

    return res


def trans_FuncDefAST(obj : FuncDefAST, indent: str) -> str:    
    res = ""
    if obj.identifier == "constructor":
        res += f'{indent}constructor ('
    else:
        res += f'{indent}function {obj.identifier}('

    for idx, param_name in enumerate(obj.input_param_ident):
        if idx != 0:
            res += ', '
        res += f'{obj.input_param_type[idx]} {param_name}'
    res += ')'
    if obj.visibility != "":
        res += f' {obj.visibility}'
    res += " {\n"
    for stmt in obj.func_body:
        res += sol_translate(stmt, indent + "    ")
    res += f"{indent}}}\n"
    return res
    
    
def trans_CodeSnippetAST(obj : CodeSnippetAST, indent: str) -> str:
    if obj.code[-1] not in ('}', ';'):
        obj.code += ';'
    return indent + obj.code + '\n'


def trans_MapOpAST(obj : MapOpAST, indent: str) -> str:
    res = f'{indent}{obj.map_name}[{obj.key_value}] = {obj.val_value};'
    return res


def trans_ContractAST(obj : ContractAST, indent: str) -> str:
    res = f"{indent}contract {obj.identifier} {{\n"
    for struct in obj.struct_list:
        res += sol_translate(struct, indent + "    ")
    res += "\n"

    for var in obj.var_list:
        res += sol_translate(var, indent + "    ")
    res += "\n"

    for event in obj.event_list:
        res += sol_translate(event, indent + "    ")
    res += "\n"

    for code in obj.code_snippet_list:
        res += sol_translate(code, indent + "    ")
    res += "\n"

    for func in obj.func_list:
        res += sol_translate(func, indent + "    ")
        res += "\n"
    res += "}\n"
    return res


def trans_ProgramAST(obj : ProgramAST) -> str:
    code = '// SPDX-License-Identifier: MIT\n'
    code += 'pragma solidity ^0.8.0;\n'
    code += 'pragma abicoder v2;\n\n'
    
    for contract in obj.contract_list:
        code += sol_translate(contract, "")
        code += "\n"
    return code


def sol_translate(obj, indent: str = "") -> str:
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

