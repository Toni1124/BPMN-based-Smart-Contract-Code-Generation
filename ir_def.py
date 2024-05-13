""" Definitions for AST Class. """
from typing import Union, Dict

struct_structure_map = {}
""" struct structure map, record field in each struct
    key: struct name
    value: list[(var_name_0, var_type_0), (var_name_1, var_type_1)...] """

resource_init_map = {}
""" Resource init map, do this in fun init_module
    key: resource name
    value: list[init_value_0, init_value_1...] """

func_signature_map = {}
""" function signature map, record function signature
    key: function name
    value: list[(param_name_0, param_type_0), (param_name_1, param_type_1)...] """

resource_names = set()
""" Resource structure names """

type_map = {
    "uint": "u128",
    "string": "string::String",
    "string memory": "string::String",
    "bytes": "bit_vector::BitVector",
    "bytes memory": "bit_vector::BitVector",
    "uint64" : "u64",
}
""" Type map """

instance_map = {
    "string": ["string::utf8(b", ")"],
    "string::String" : ["string::utf8(b", ")"],
    "bytes": ["", ""],
}
""" Instantiation map """

mapping_structure = {}
""" map name: [key type, val type] """

initial_values = {
    "u128": "0",
    "bool": "false",
    "bit_vector::BitVector": "bit_vector::new(8)",
    "string": 'string::utf8(b"")',
    "uint": "0",
    "string::String": 'string::utf8(b"")',
    "bytes": "bit_vector::new(8)",
}
""" Initial value for primitive types """

func_acquires = {}
""" Function resource acquires """

current_func_name = ""
""" Current handled function name """

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


class DefStructAST:
    """ AST for statement that define a struct """
    def __init__(self, ident:str) -> None:
        self.identifier : str = ident
        self.var_name : list[str] = []
        self.var_type : list[str] = []
        self.ability_list : list[str] = []

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f'{indent}struct {self.identifier} {{\n'
        for idx, var_name in enumerate(self.var_name):
            res += f'{indent}   {self.var_type[idx]} {var_name};\n'
        res += f"{indent}}}\n"

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        var_list = []
        res = f'{indent}struct {self.identifier} '
        for idx, ability in enumerate(self.ability_list):
            if idx == 0:
                res += f"has {ability}"
            else:
                res += f", {ability}"
        res += " {\n"

        for idx, var_name in enumerate(self.var_name):
            res += f'{indent}   {var_name}: '
            if self.var_type[idx] in type_map:
                res += f"{type_map[self.var_type[idx]]},\n"
            elif "mapping" in self.var_type[idx]:
                res += "simple_map::SimpleMap,\n"
            else:
                res += f'{self.var_type[idx]},\n'
            var_list.append((var_name, self.var_type[idx]))
        res += f"{indent}}}\n"

        struct_structure_map[self.identifier] = var_list

        if "key" in self.ability_list:
            resource_names.add(self.identifier)

        return res


class ArrOperationAST:
    """ AST for doing array operations """
    def __init__(self, ident:str, op:str, obj='', field='', val='') -> None:
        self.identifier : str = ident   # the array variable name
        self.operation : str = op       # push, set, len, read
        self.obj : Union[InstantiateAST, str] = obj     # object or element index
        self.field : str = field
        self.value : str = val

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = indent
        if isinstance(self.obj, str) and 'as u' in self.obj:
            idx = self.obj[1 : self.obj.find('as ')].strip()
        if self.operation == "push":
            res += f"{self.identifier}.{self.operation}("
            res += self.obj.solidity_ver("")
            # delete last ;\n in the res
            res = res[:-2]
            res += ");\n"
        elif self.operation == "set":
            res += f'{self.identifier}[{idx}].{self.field} = {self.value};\n'
        elif self.operation == "len":   # get length of the array
            res += f'{self.identifier}.length'
        elif self.operation == "read":
            res += f'{self.identifier}[{idx}].{self.field}'

        return res

    def move_ver(self, indent:str) -> str:
        res = indent
        resource_name = self.identifier.replace('_', '', 1).capitalize()
        assert(resource_name in struct_structure_map)

        if self.operation == 'push':
            res += f'vector::push_back<{self.obj.type}>'
            res += f'(&mut {borrow_from_deployer(resource_name, self.identifier, True)}, '
            res += f'{self.obj.move_ver("")}'
            res = res[:-1]
            res += ');\n'

        elif self.operation == 'set':
            resource_struct = struct_structure_map[resource_name]
            element_type = resource_struct[0][1]
            var_name = resource_struct[0][0]
            element_type = element_type[element_type.find('<') + 1: element_type.find('>')]
            res += f'vector::borrow_mut<{element_type}>(&mut '
            res += borrow_from_deployer(resource_name, var_name, True)
            res += f', {self.obj}).{self.field} = {self.value};\n'

        elif self.operation == 'len':
            var_type = struct_structure_map[resource_name][0][1]
            var_type = var_type[var_type.find('<') + 1 : var_type.find('>')]
            res += f'(vector::length<{var_type}>(&{borrow_from_deployer(resource_name, self.identifier)}) as u128)'

        elif self.operation == "read":
            resource_struct = struct_structure_map[resource_name]
            element_type = resource_struct[0][1]
            var_name = resource_struct[0][0]
            element_type = element_type[element_type.find('<') + 1: element_type.find('>')]
            res += f'vector::borrow<{element_type}>(&'
            res += borrow_from_deployer(resource_name, var_name)
            res += f', {self.obj}).{self.field}'

        return res


class DeclLocalVarAST:
    """ AST for statement that declare a local variable """
    def __init__(self, var_type:str, ident:str, \
                 vis="", expr="") -> None:
        self.type : str = var_type
        self.identifier : str = ident
        self.expr = expr

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = indent + self.type
        res += f' {self.identifier}'
        if isinstance(self.expr, str):
            if self.expr != '':
                res += f' = {self.expr}'
        else:
            res += f' = {self.expr.solidity_ver("")}'
        res += ';\n'

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = f'{indent}let '
        if self.type in type_map:
            res += f'{self.identifier}: {type_map[self.type]}'
        else:
            res += f'{self.identifier}: {self.type}'
        if isinstance(self.expr, str):
            if self.expr != "":
                resource_name = self.expr.replace('_', '', 1).capitalize()
                if resource_name in resource_names:
                    res += f' = {borrow_from_deployer(resource_name, self.expr, False)}'
                else:
                    res += f' = {self.expr}'
        else:
            res += f' = {self.expr.move_ver("")}'
        res += ';\n'

        return res


class DeclStateVarAST:
    """ AST for statement that declare a state variable,
        wrapper for state variables which are basic types """
    def __init__(self, var_type:str, ident:str, \
                 vis="", expr="") -> None:
        self.type : str = var_type
        self.identifier : str = ident
        self.visibility : str = vis
        self.expr : str = expr

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = indent + self.type
        if self.visibility != "":
            res += f' {self.visibility}'
        res += f' {self.identifier}'
        if self.expr != "":
            res += f' = {self.expr}'
        res += ';\n'

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        resource_name = self.identifier.replace('_', '', 1).capitalize()
        resource_names.add(resource_name)

        res = f'{indent}struct {resource_name} has key, store {{\n'
        if self.identifier == "workitems":
            res += f'{indent}   workitems: vector<Workitem>\n'
            struct_structure_map[resource_name] = [("workitems", 'vector<Workitem>')]
        else:
            res += f'{indent}   {self.identifier}: '
            var_type = self.type
            if self.type in type_map:
                var_type = type_map[self.type]
                res += f"{type_map[self.type]},\n"
            elif "mapping" in self.type:
                key_val = self.type[self.type.find('(') + 1: self.type.find(')')]
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
                res += f'{self.type},\n'
            struct_structure_map[resource_name] = [(self.identifier, var_type)]
        res += f'{indent}}}\n'

        # 初始化在init module里做
        if self.expr != "":
            resource_init_map[resource_name] = [self.expr]
        res += '\n'

        return res


class DeclEventAST:
    """ AST for statement that define an event """
    def __init__(self, ident:str) -> None:
        self.identifier : str = ident
        self.param_type : list = []
        self.param_ident : list = []

    def set_param(self, param_type:str, param_ident:str):
        """ Set event parameter information, add one parameter each call, 
            call multiple time if necessary
        """
        self.param_type.append(param_type)
        self.param_ident.append(param_ident)

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f"{indent}event {self.identifier}("
        for idx, param_name in enumerate(self.param_ident):
            if idx != 0:
                res += ', '
            res += f'{self.param_type[idx]} {param_name}'
        res += ');\n'

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        var_list = []
        res = f'{indent}#[event]\n'
        res += f'{indent}struct {self.identifier.capitalize()} has drop, store {{\n'
        for idx, var_type in enumerate(self.param_type):
            res += f'{indent}   {self.param_ident[idx]}: '
            if var_type in type_map:
                res += f"{type_map[var_type]}, \n"
            elif "mapping" in var_type:
                res += "simple_map::SimpleMap,\n"
            else:
                res += f'{var_type}, \n'
            var_list.append((self.param_ident[idx], var_type))
        res += f"{indent}}}\n\n"

        struct_structure_map[self.identifier.capitalize()] = var_list
        return res


class AssignAST:
    """ Assign statement AST """
    def __init__(self, ident:str, expr:Union[str, 'BitwiseOpAST']) -> None:
        self.identifier : str = ident
        self.expr : str = expr

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f'{indent}{self.identifier} = {self.expr if isinstance(self.expr, str) else self.expr.solidity_ver("")};\n'

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = indent
        resource_name = self.identifier.replace('_', '', 1).capitalize()
        if resource_name in resource_names:
            res += borrow_from_deployer(resource_name, self.identifier, True)
            res += f' = {self.expr};\n'
        else:
            res += f'{self.identifier} = '
            if isinstance(self.expr, str):
                res += self.expr
            else:
                res += f'{self.expr.move_ver("")}'
            res += ';\n'

        return res

class CastAST:
    """ Cast a literal integer to specific type. """
    def __init__(self, num:int, type:str) -> None:
        self.num = num
        self.type = type  # integer type (uint / u128)

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code, 结尾没有分号 """
        res = f'{indent}{self.type}({self.num})'
        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code, 结尾没有分号 """
        res = f'{indent}{self.num}'
        if self.type == "uint":
            res += 'u128'
        else:
            raise TypeError

        return res


class BitwiseOpAST:
    """ Bitwise Operation AST """
    def __init__(self, lexpr:Union[str, 'BitwiseOpAST', CastAST], op:str,
                 rexpr:Union[None, str, 'BitwiseOpAST', CastAST]=None) -> None:
        self.left_expr = lexpr
        self.operator = op
        self.right_expr = rexpr

    def solidity_ver(self, indent:str) -> str:
        res = indent
        """ Generate Solidity code, 结尾没有分号 """
        if self.right_expr == None:
            res += self.operator
        else:
            if isinstance(self.right_expr, str):
                res += self.right_expr
            else:
                res += self.right_expr.solidity_ver("")
            res += f' {self.operator} '

        if isinstance(self.left_expr, str):
            res += self.left_expr
        else:
            res += self.left_expr.solidity_ver("")
        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code, 结尾没有分号 """
        res = indent
        if self.right_expr == None:
            if self.operator == '~':
                res += '0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ '
            else:
                res += self.operator + ' '
        else:
            if isinstance(self.right_expr, str):
                res += self.right_expr
            else:
                res += f'({self.right_expr.move_ver("")})'
            res += f' {self.operator} '

        if isinstance(self.left_expr, str):
            res += self.left_expr
        else:
            res += f'({self.left_expr.move_ver("")})'
        return res


class BoolExprAST:
    """ Boolean expression AST """
    # example: a == b, boolexpr && boolexpr, boolvar
    def __init__(self, lexpr:Union['BoolExprAST', str, CastAST, BitwiseOpAST], op:Union[None, str]=None,
                 rexpr:Union[None, str, 'BoolExprAST', CastAST, BitwiseOpAST]=None) -> None:
        self.left_expr = lexpr
        self.operator = op
        self.right_expr = rexpr

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = indent
        if isinstance(self.left_expr, str):
            if 'as u' in self.left_expr:
                res += self.left_expr[1 : self.left_expr.find('as ')].strip()
            else:
                res += self.left_expr
        else:
            res += self.left_expr.solidity_ver(indent)

        if self.operator is not None:
            res += ' ' + self.operator

        if isinstance(self.right_expr, str):
            res += ' ' + self.right_expr
        elif self.right_expr is not None:
            res += ' ' + self.right_expr.solidity_ver(indent)

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = indent
        if isinstance(self.left_expr, str):
            resource_name = self.left_expr.replace('_', '', 1).capitalize()
            if resource_name.find('[') != -1:
                resource_name = resource_name[:resource_name.find('[')]

            if resource_name in resource_names:
                if resource_name in mapping_structure:
                    map_structure = mapping_structure[resource_name]
                    key_val = self.left_expr[self.left_expr.find('[') + 1: self.left_expr.find(']')]
                    res += f'simple_map::borrow<{map_structure[0]}, {map_structure[1]}>(&'
                    res += borrow_from_deployer(resource_name, self.left_expr[:self.left_expr.find('[')])
                    key_name = key_val.replace('_', '', 1).capitalize()
                    if key_name in resource_names:
                        res += f', &{borrow_from_deployer(key_name, key_val)})'
                    else:
                        res += f', {key_val})'
                else:
                    res += borrow_from_deployer(resource_name, self.left_expr)
            else:
                res += self.left_expr
            if self.operator is None:
                assert(resource_name in struct_structure_map)
                var_type = struct_structure_map[resource_name][0][1]
                if '=>' in var_type:
                    var_type = var_type[var_type.find('>'):]
                if var_type.find('bool') == -1:
                    res += ' != 0'
                elif res.endswith(')'):
                    res = res[:len(indent)] + '*' + res[len(indent):]

        else:
            res += self.left_expr.move_ver(indent)

        if self.operator is not None:
            res += ' ' + self.operator

        if isinstance(self.right_expr, str):
            expr_name = self.right_expr.replace('_', '', 1).capitalize()
            if expr_name in resource_names:
                res += borrow_from_deployer(expr_name, self.right_expr)
            else:
                res += ' ' + self.right_expr
        elif self.right_expr is not None:
            res += ' ' + self.right_expr.move_ver(indent)
        
        return res


class RequireAST:
    """ Require statement AST """
    def __init__(self, bexpr:BoolExprAST) -> None:
        self.bool_expression : BoolExprAST = bexpr

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f"{indent}require("
        res += self.bool_expression.solidity_ver("")
        res += ");\n"

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = f"{indent}assert!("
        res += self.bool_expression.move_ver("")
        res += ", 0);\n"

        return res

class IfAST:
    """ If structure AST, {else  stmt} is optional """
    def __init__(self) -> None:
        self.cond_stmt : Dict[Union[BoolExprAST, None], list] = {}

    def add_cond_stmt(self, cond:Union[BoolExprAST, None], stmt=None):
        """ Add boolean condition-statement """
        if self.cond_stmt.get(cond) is None:
            self.cond_stmt[cond] = []
        if stmt is not None:
            self.cond_stmt[cond].append(stmt)

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code, note that if there's no statement following
            a if condition, it won't generate this if condition (including the condition) """
        res = ""
        for cond, stmts in self.cond_stmt.items():
            if cond is not None:
                res += f"{indent}if ("
                res += cond.solidity_ver("")
                res += ") {\n"

                for stmt in stmts:
                    if stmt is not None:
                        res += stmt.solidity_ver(indent + "    ")

                res += f"{indent}}}\n"

        if None in self.cond_stmt:
            res += f"{indent}else {{\n"

            for stmt in self.cond_stmt[None]:
                res += stmt.solidity_ver(indent + "    ")

            res += f"{indent}}}\n"

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = ""
        for cond, stmts in self.cond_stmt.items():
            if cond is not None:
                res += f"{indent}if ("
                res += cond.move_ver("")
                res += ") {\n"

                for stmt in stmts:
                    if stmt is not None:
                        res += stmt.move_ver(indent + "    ")

                res += f"{indent}}}"
                if None in self.cond_stmt:
                    res += '\n'
                else:
                    res += ';\n'

        if None in self.cond_stmt:
            res += f"{indent}else {{\n"

            for stmt in self.cond_stmt[None]:
                res += stmt.move_ver(indent + "    ")

            res += f"{indent}}};\n"
        
        return res


class WhileAST:
    """ While structure AST """
    def __init__(self, cond:BoolExprAST) -> None:
        self.cond : BoolExprAST = cond
        self.stmt : list = []

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f"{indent}while("
        res += self.cond.solidity_ver("")
        res += "){\n"
        for stmt in self.stmt:
            res += stmt.solidity_ver(indent + "    ")
        res += f"{indent}}}\n"

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code, actually it is infinite loop """
        res = f"{indent}loop {{\n"
        for stmt in self.stmt:
            res += stmt.move_ver(indent + "    ")
        res += f"{indent}}};\n"

        return res


class ContinueAST:
    """ Continue AST """
    def __init__(self) -> None:
        return

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        return f"{indent}continue;\n"

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        return f"{indent}continue\n"


class BreakAST:
    """ Break AST """
    def __init__(self) -> None:
        return

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        return f"{indent}break;\n"

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        return f"{indent}break\n"


class EmitEventAST:
    """ Emitting event AST """
    def __init__(self, event_name:str) -> None:
        self.identifier : str = event_name
        self.arg_list : list = []

    def add_arg(self, arg):
        """ Add function call argument """
        self.arg_list.append(arg)

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f"{indent}emit {self.identifier}("
        for idx, arg in enumerate(self.arg_list):
            if idx != 0:
                res += ", "
            if 'as u' in arg:
                arg = arg[1 : arg.find('as')].strip()
            res += arg
        res += ");\n"
        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        resource_name = self.identifier.capitalize()    # event无需替换
        res = f"{indent}event::emit ({resource_name} {{"
        struct_def = struct_structure_map[resource_name]
        for idx, arg in enumerate(self.arg_list):
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


class ReturnAST:
    """ Return statement AST """
    def __init__(self) -> None:
        self.ret_list : list = []   # return parameter list

    def add_ret_value(self, value:str) -> None:
        """ Add return value / variable, add one each time,
            call mutiple times if necessary
        """
        self.ret_list.append(value)

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f"{indent}return"
        arg_str = ""
        for idx, val in enumerate(self.ret_list):
            if idx != 0:
                arg_str += ", "
            arg_str += val
        if self.ret_list:
            res += f"({arg_str})"
        res += ";\n"
        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = f"{indent}return"
        arg_str = ""
        for idx, val in enumerate(self.ret_list):
            if idx != 0:
                arg_str += ", "
            arg_str += val
        if self.ret_list:
            res += f"({arg_str})"
        res += "\n"
        return res


class FuncCallAST:
    """ Function Call AST """
    def __init__(self, ident:str, cross=False) -> None:
        self.identifier : str = ident       # callee identifier
        self.arg_list : list = []           # argument list
        self.cross_contract : bool = cross

    def add_arg(self, arg):
        """ Add function call argument """
        self.arg_list.append(arg)

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """        
        res = f"{indent}{self.identifier}("
        for idx, arg in enumerate(self.arg_list):
            if idx != 0:
                res += ", "

            if isinstance(arg, str):
                res += arg
            else:
                code = arg.solidity_ver("")
                res += code[:-2] if code.endswith(';\n') else code

        res += ");\n"

        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        # 需要将callee的acquires增添到当前函数的acquires
        if current_func_name not in func_acquires:
            func_acquires[current_func_name] = []

        assert(self.identifier in func_acquires)
        for resource in func_acquires[self.identifier]:
            if resource not in func_acquires[current_func_name]:
                func_acquires[current_func_name].append(resource)

        res = f"{indent}{self.identifier}("
        for idx, arg in enumerate(self.arg_list):
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
                code = arg.move_ver("")
                res += code[:-1] if code.endswith(';') else code

        res += ");\n"
        return res


class InstantiateAST:
    """ Instantiate an object """
    def __init__(self, ident:str) -> None:
        self.type : str = ident       # Type of the object
        self.arg_list : list = []
        self.func_call : list[FuncCallAST] = []

    def add_arg(self, arg) -> None:
        """ Add arguments used to do instantiation """
        self.arg_list.append(arg)

    def add_func_call(self, func_call:FuncCallAST):
        """ Call member function after instantiation """
        self.func_call.append(func_call)

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f"{indent}{self.type}("
        for idx, arg in enumerate(self.arg_list):
            if idx != 0:
                res += ", "

            if isinstance(arg, str):
                res += arg
            else:
                res += arg.solidity_ver("")

        res += ")"

        if self.func_call:
            res += "."
            for func_call in self.func_call:
                res += func_call.solidity_ver("")

        if not self.func_call:
            res += ";\n"
        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = f"{indent}{self.type}{{"
        struct_def = struct_structure_map[self.type]
        for idx, arg in enumerate(self.arg_list):
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


class FuncDefAST:
    """ Function definition AST """
    def __init__(self, ident:str, vis="") -> None:
        self.identifier : str = ident
        self.visibility : str = vis
        self.input_param_type : list[str] = []
        self.input_param_ident : list[str] = []
        self.ret_param_type : list[str] = []
        self.ret_param_ident : list[str] = []
        self.func_body : list = []

    def set_param(self, param_type:str, param_ident:str, is_input=True) -> None:
        """ Set parameter information,
            call multiple time if necessary
        """
        if is_input:
            self.input_param_type.append(param_type)
            self.input_param_ident.append(param_ident)
        else:
            self.ret_param_type.append(param_type)
            self.ret_param_ident.append(param_ident)

    def set_funcbody(self, stmt) -> None:
        """ Set function body by adding one statement,
            call multiple time if necessary
        """
        self.func_body.append(stmt)

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = ""
        if self.identifier == "constructor":
            res += f'{indent}constructor ('
        else:
            res += f'{indent}function {self.identifier}('

        for idx, param_name in enumerate(self.input_param_ident):
            if idx != 0:
                res += ', '
            res += f'{self.input_param_type[idx]} {param_name}'
        res += ')'
        if self.visibility != "":
            res += f' {self.visibility}'
        res += " {\n"
        for stmt in self.func_body:
            res += stmt.solidity_ver(indent + "    ")
        res += f"{indent}}}\n"
        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = indent
        param_list = []
        global current_func_name
        current_func_name = self.identifier
        index = 0       # place to insert `acquires`
        if self.identifier == "constructor":
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
                        res += f'{var[0]}: {struct_instance.move_ver("")[:-1]}, '
                res += '});\n'
        else:
            if self.visibility in ("public", "external"):
                res += "public "
            res += f'fun {self.identifier}('

            for idx, param_name in enumerate(self.input_param_ident):
                if idx != 0:
                    res += ', '
                res += f'{param_name}: '
                param_type = self.input_param_type[idx].replace('memory', '').strip()
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
        func_signature_map[self.identifier] = param_list

        for stmt in self.func_body:
            res += stmt.move_ver(indent + "    ")
        res += f"{indent}}}\n"

        acquires_stmt = ""
        if self.identifier not in func_acquires:
            func_acquires[self.identifier] = []
        for idx, resource in enumerate(func_acquires[self.identifier]):
            if idx == 0:
                acquires_stmt += f' acquires {resource}'
            else:
                acquires_stmt += f', {resource}'

        res = res[:index] + acquires_stmt + res[index:]
        return res


class CodeSnippetAST:
    """ Pure code snippet, can be directlt add to generated contract """
    def __init__(self, code:str) -> None:
        self.code = code

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        if self.code[-1] not in ('}', ';'):
            self.code += ';'
        return indent + self.code + '\n'

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        if self.code[-1] not in ('}', ';'):
            self.code += ';'
        return indent + self.code + '\n'

class MapOpAST:
    """ AST for map operation structure """
    def __init__(self, map_name: str, key:str, value:str) -> None:
        self.map_name = map_name
        self.key_value = key
        self.val_value = value

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f'{indent}{self.map_name}[{self.key_value}] = {self.val_value};'
        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Move code """
        res = indent
        resource_name = self.map_name.replace('_', '', 1).capitalize()
        key_type = mapping_structure[resource_name][0]
        val_type = mapping_structure[resource_name][1]
        res += f'simple_map::add<{key_type}, {val_type}>(&mut '
        res += borrow_from_deployer(resource_name, self.map_name, True)
        res += f', {self.key_value}, {self.val_value});\n'
        return res


class ContractAST:
    """ Contract AST """
    def __init__(self, ident:str) -> None:
        self.identifier : str = ident
        self.var_list : list[DeclStateVarAST] = []
        self.struct_list : list[DefStructAST] = []
        self.event_list : list[DeclEventAST] = []
        self.func_list : list[FuncDefAST] = []
        self.code_snippet_list : list[CodeSnippetAST] = []

    def add2list(self, ast) -> None:
        """ Add components to contract AST """
        if isinstance(ast, DeclStateVarAST):
            self.var_list.append(ast)
        elif isinstance(ast, DeclEventAST):
            self.event_list.append(ast)
        elif isinstance(ast, FuncDefAST):
            self.func_list.append(ast)
        elif isinstance(ast, DefStructAST):
            self.struct_list.append(ast)
        elif isinstance(ast, CodeSnippetAST):
            self.code_snippet_list.append(ast)
        else:
            raise ValueError

    def solidity_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f"{indent}contract {self.identifier} {{\n"
        for struct in self.struct_list:
            res += struct.solidity_ver(indent + "    ")
        res += "\n"
        for var in self.var_list:
            res += var.solidity_ver(indent + "    ")
        res += "\n"
        for event in self.event_list:
            res += event.solidity_ver(indent + "    ")
        res += "\n"
        for code in self.code_snippet_list:
            res += code.solidity_ver(indent + "    ")
        res += "\n"
        for func in self.func_list:
            res += func.solidity_ver(indent + "    ")
            res += "\n"
        res += "}\n"
        return res

    def move_ver(self, indent:str) -> str:
        """ Generate Solidity code """
        res = f"{indent}module deployer::{self.identifier} {{\n"
        res += '    use std::string;\n'
        res += '    use std::bit_vector;\n'
        # res += '    use std::signer;\n'
        res += '    use std::vector;\n'
        res += '    use aptos_std::simple_map;\n'
        res += '    use aptos_framework::event;\n\n'
        for struct in self.struct_list:
            res += struct.move_ver(indent + "    ")
        res += "\n"
        for var in self.var_list:
            res += var.move_ver(indent + "    ")
        res += "\n"
        for event in self.event_list:
            res += event.move_ver(indent + "    ")
        res += "\n"
        for code in self.code_snippet_list:
            res += code.move_ver(indent + "    ")
        res += "\n"

        # 实际顺序：init, start_execution, xxxx_complete, step, xxxx_start, xxxx
        # 理想顺序：init, xxxx_start, step, start_execution, xxxx_complete, xxxx
        complete_idx, complete_len = 0, 0
        start_idx, start_len = 0, 0
        for idx, func in enumerate(self.func_list):
            if '_complete' in func.identifier:
                if complete_idx == 0:
                    complete_idx = idx
                complete_len += 1
            if '_start' in func.identifier:
                if start_idx == 0:
                    start_idx = idx
                start_len += 1

        sorted_func_list = [self.func_list[0]]
        sorted_func_list.extend(self.func_list[start_idx : start_idx + start_len])
        sorted_func_list.append(self.func_list[start_idx - 1])
        sorted_func_list.append(self.func_list[1])
        sorted_func_list.extend(self.func_list[complete_idx : complete_idx + complete_len])
        sorted_func_list.extend(self.func_list[start_idx + start_len :])

        assert(len(sorted_func_list) == len(self.func_list))

        for func in sorted_func_list:
            res += func.move_ver(indent + "    ")
            res += "\n"
        res += "}\n"
        return res

class ProgramAST:
    """ AST for whole Solidity program """
    def __init__(self) -> None:
        self.code : str = ""
        self.contract_list : list[ContractAST] = []

    def solidity_ver(self) -> str:
        """ Generate Solidity code """
        self.code = '// SPDX-License-Identifier: MIT\n'
        self.code += 'pragma solidity ^0.8.0;\n'
        self.code += 'pragma abicoder v2;\n\n'
        res = self.code
        for contract in self.contract_list:
            res += contract.solidity_ver("")
            res += "\n"

        return res

    def move_ver(self) -> str:
        """ Generate Solidity code """
        self.code = ''
        res = self.code
        for contract in self.contract_list:
            res += contract.move_ver("")
            res += "\n"
        
        return res
