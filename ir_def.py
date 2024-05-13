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

class DefStructAST:
    """ AST for statement that define a struct """
    def __init__(self, ident:str) -> None:
        self.identifier : str = ident
        self.var_name : list[str] = []
        self.var_type : list[str] = []
        self.ability_list : list[str] = []


class ArrOperationAST:
    """ AST for doing array operations """
    def __init__(self, ident:str, op:str, obj='', field='', val='') -> None:
        self.identifier : str = ident   # the array variable name
        self.operation : str = op       # push, set, len, read
        self.obj : Union[InstantiateAST, str] = obj     # object or element index
        self.field : str = field
        self.value : str = val


class DeclLocalVarAST:
    """ AST for statement that declare a local variable """
    def __init__(self, var_type:str, ident:str, \
                 vis="", expr="") -> None:
        self.type : str = var_type
        self.identifier : str = ident
        self.expr = expr


class DeclStateVarAST:
    """ AST for statement that declare a state variable,
        wrapper for state variables which are basic types """
    def __init__(self, var_type:str, ident:str, \
                 vis="", expr="") -> None:
        self.type : str = var_type
        self.identifier : str = ident
        self.visibility : str = vis
        self.expr : str = expr


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


class AssignAST:
    """ Assign statement AST """
    def __init__(self, ident:str, expr:Union[str, 'BitwiseOpAST']) -> None:
        self.identifier : str = ident
        self.expr : str = expr


class CastAST:
    """ Cast a literal integer to specific type. """
    def __init__(self, num:int, type:str) -> None:
        self.num = num
        self.type = type


class BitwiseOpAST:
    """ Bitwise Operation AST """
    def __init__(self, lexpr:Union[str, 'BitwiseOpAST', CastAST], op:str,
                 rexpr:Union[None, str, 'BitwiseOpAST', CastAST]=None) -> None:
        self.left_expr = lexpr
        self.operator = op
        self.right_expr = rexpr


class BoolExprAST:
    """ Boolean expression AST """
    # example: a == b, boolexpr && boolexpr, boolvar
    def __init__(self, lexpr:Union['BoolExprAST', str, CastAST, BitwiseOpAST], op:Union[None, str]=None,
                 rexpr:Union[None, str, 'BoolExprAST', CastAST, BitwiseOpAST]=None) -> None:
        self.left_expr = lexpr
        self.operator = op
        self.right_expr = rexpr


class RequireAST:
    """ Require statement AST """
    def __init__(self, bexpr:BoolExprAST) -> None:
        self.bool_expression : BoolExprAST = bexpr


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


class WhileAST:
    """ While structure AST """
    def __init__(self, cond:BoolExprAST) -> None:
        self.cond : BoolExprAST = cond
        self.stmt : list = []


class ContinueAST:
    """ Continue AST """
    def __init__(self) -> None:
        return


class BreakAST:
    """ Break AST """
    def __init__(self) -> None:
        return


class EmitEventAST:
    """ Emitting event AST """
    def __init__(self, event_name:str) -> None:
        self.identifier : str = event_name
        self.arg_list : list = []

    def add_arg(self, arg):
        """ Add function call argument """
        self.arg_list.append(arg)


class ReturnAST:
    """ Return statement AST """
    def __init__(self) -> None:
        self.ret_list : list = []   # return parameter list

    def add_ret_value(self, value:str) -> None:
        """ Add return value / variable, add one each time,
            call mutiple times if necessary
        """
        self.ret_list.append(value)


class FuncCallAST:
    """ Function Call AST """
    def __init__(self, ident:str, cross=False) -> None:
        self.identifier : str = ident       # callee identifier
        self.arg_list : list = []           # argument list
        self.cross_contract : bool = cross

    def add_arg(self, arg):
        """ Add function call argument """
        self.arg_list.append(arg)


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


class CodeSnippetAST:
    """ Pure code snippet, can be directlt add to generated contract """
    def __init__(self, code:str) -> None:
        self.code = code


class MapOpAST:
    """ AST for map operation structure """
    def __init__(self, map_name: str, key:str, value:str) -> None:
        self.map_name = map_name
        self.key_value = key
        self.val_value = value


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


class ProgramAST:
    """ AST for whole Solidity program """
    def __init__(self) -> None:
        self.code : str = ""
        self.contract_list : list[ContractAST] = []

