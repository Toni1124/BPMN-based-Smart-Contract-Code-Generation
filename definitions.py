from typing import Any, Dict, List, Optional


class ModelInfo:
    def __init__(self) -> None:
        self.name: str
        self.bpmn: str
        self.solidity: str
        self.controlFlowInfoMap: Dict[str, ControlFlowInfo]
        self.entryContractName: str
        self.contracts: Any


class ParameterInfo:
    def __init__(self, type: str, name: str, definedStruct=False) -> None:
        self.type: str = type
        self.name: str = name
        self.definedStruct = definedStruct

    def __getitem__(self, key: str):
        if key == 'type':
            return self.type
        elif key == 'name':
            return self.name
        elif key == 'definedStruct':
            return self.definedStruct
        else:
            raise KeyError(f"'{key}' is not a valid key for ParameterInfo")


class ControlFlowInfo:
    def __init__(self,
                 proc,
                 nodeList: List[str],
                 edgeList: List[str],
                 sources: List[str],
                 dataObjects: List[Dict],
                 boundaryEvents: List[str]) -> None:
        self.proc = proc
        self.boundaryEvents = boundaryEvents
        self.sources = sources
        self.edgeList = edgeList
        self.nodeList = nodeList
        self.dataObjects = dataObjects
        self.parent: Optional[ControlFlowInfo] = None
        self.isEmbedded: bool = False
        self.nodeNameMap: Dict[str, str] = {}
        self.nodeIndexMap: Dict[str, int] = {}
        self.edgeIndexMap: Dict[str, int] = {}
        self.multiinstanceActivities: Dict[str, str] = {}
        self.nonInterruptingEvents: Dict[str, str] = {}
        self.callActivities: Dict[str, str] = {}
        self.childSubprocesses: Dict[str, str] = {}
        self.activeMessages: List[str] = []
        self.globalParameters: str = ""
        self.authGlobal: str = ""
        self.localParameters = {}
