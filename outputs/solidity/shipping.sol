// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract shipping_Contract {
    struct Workitem {
       uint elementIndex;
       bool operated;
    }

    uint public marking = 2;
    uint public startedActivities = 0;
    bool _warehouse_available;
    bool _customs_passed;
    Workitem[] private workitems;

    event Event_0os0wzu_Message(string messageText);
    event Event_1sooxn7_Message(string messageText);
    event execution_progress(string msg);
    event Activity_17kev5e_Message_Pack_products();
    event Initiate_shipping_Requested(uint index);
    event Prepare_products_Requested(uint index);
    event Outgoing_customs_procedures_Requested(uint index);
    event Book_for_shipmen_Requested(uint index);
    event Check_warehouse_status_Requested(uint index);
    event Arrange_deliver_time_Requested(uint index);
    event Receiver_received_Requested(uint index);


    constructor () {
    }

    function startExecution() public {
        require(marking == uint(2) && startedActivities == uint(0));
        step(uint(2), 0);
    }

    function Initiate_shipping_complete(uint elementIndex) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(1)) {
            require(uint(2) & tmpStartedActivities != 0);
            step(uint(4) | tmpMarking, ~uint(2) & tmpStartedActivities);
            return;
        }
    }

    function Prepare_products_complete(uint elementIndex) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(2)) {
            require(uint(4) & tmpStartedActivities != 0);
            step(uint(128) | tmpMarking, ~uint(4) & tmpStartedActivities);
            return;
        }
    }

    function Outgoing_customs_procedures_complete(uint elementIndex, bool customs_passed) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(3)) {
            require(uint(8) & tmpStartedActivities != 0);
            _customs_passed = customs_passed;
            step(uint(268435456) | tmpMarking, ~uint(8) & tmpStartedActivities);
            return;
        }
    }

    function Book_for_shipmen_complete(uint elementIndex) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(4)) {
            require(uint(16) & tmpStartedActivities != 0);
            step(uint(64) | tmpMarking, ~uint(16) & tmpStartedActivities);
            return;
        }
    }

    function Check_warehouse_status_complete(uint elementIndex, bool warehouse_available) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(5)) {
            require(uint(32) & tmpStartedActivities != 0);
            _warehouse_available = warehouse_available;
            step(uint(256) | tmpMarking, ~uint(32) & tmpStartedActivities);
            return;
        }
    }

    function Arrange_deliver_time_complete(uint elementIndex) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(6)) {
            require(uint(64) & tmpStartedActivities != 0);
            step(uint(1048576) | tmpMarking, ~uint(64) & tmpStartedActivities);
            return;
        }
    }

    function Receiver_received_complete(uint elementIndex) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(7)) {
            require(uint(128) & tmpStartedActivities != 0);
            step(uint(67108864) | tmpMarking, ~uint(128) & tmpStartedActivities);
            return;
        }
    }

    function step(uint tmpMarking, uint tmpStartedActivities) internal {
        while(true){
            if (uint(2) & tmpMarking != 0) {
                emit execution_progress("Activity_0v5c77r");
                tmpMarking = ~uint(2) & tmpMarking;
                Initiate_shipping_start(1);
                tmpStartedActivities = uint(2) | tmpStartedActivities;
                continue;
            }
            if (uint(16) & tmpMarking != 0) {
                emit execution_progress("Activity_0t3c564");
                tmpMarking = ~uint(16) & tmpMarking;
                Prepare_products_start(2);
                tmpStartedActivities = uint(4) | tmpStartedActivities;
                continue;
            }
            if (uint(8) & tmpMarking != 0) {
                emit execution_progress("Activity_14ye2uu");
                tmpMarking = ~uint(8) & tmpMarking;
                Outgoing_customs_procedures_start(3);
                tmpStartedActivities = uint(8) | tmpStartedActivities;
                continue;
            }
            if (uint(32) & tmpMarking != 0) {
                emit execution_progress("Activity_1mdtd7d");
                tmpMarking = ~uint(32) & tmpMarking;
                Book_for_shipmen_start(4);
                tmpStartedActivities = uint(16) | tmpStartedActivities;
                continue;
            }
            if (uint(262144) & tmpMarking != 0) {
                emit execution_progress("Activity_090z4s4");
                tmpMarking = ~uint(262144) & tmpMarking;
                Check_warehouse_status_start(5);
                tmpStartedActivities = uint(32) | tmpStartedActivities;
                continue;
            }
            if (uint(65536) & tmpMarking != 0) {
                emit execution_progress("Activity_0trcxgm");
                tmpMarking = ~uint(65536) & tmpMarking;
                Arrange_deliver_time_start(6);
                tmpStartedActivities = uint(64) | tmpStartedActivities;
                continue;
            }
            if (uint(33554432) & tmpMarking != 0) {
                emit execution_progress("Activity_0sltmku");
                tmpMarking = ~uint(33554432) & tmpMarking;
                Receiver_received_start(7);
                tmpStartedActivities = uint(128) | tmpStartedActivities;
                continue;
            }
            if (uint(4) & tmpMarking == uint(4)) {
                emit execution_progress("Gateway_00gpgwc");
                tmpMarking = ~uint(4) & tmpMarking;
                tmpMarking = uint(56) | tmpMarking;
                continue;
            }
            if (uint(64) & tmpMarking == uint(64)) {
                emit execution_progress("Gateway_1mhy99q");
                tmpMarking = ~uint(64) & tmpMarking;
                tmpMarking = uint(196608) | tmpMarking;
                continue;
            }
            if (uint(8320) & tmpMarking == uint(8320)) {
                emit execution_progress("Gateway_0g0k9va");
                tmpMarking = ~uint(8320) & tmpMarking;
                tmpMarking = uint(16384) | tmpMarking;
                continue;
            }
            if (uint(131072) & tmpMarking != 0) {
                emit execution_progress("Activity_15w24qv");
                tmpMarking = ~uint(131072) & tmpMarking;
                tmpMarking = uint(262144) | tmpMarking;
                continue;
            }
            if (uint(256) & tmpMarking != 0) {
                emit execution_progress("Gateway_0qctgii");
                tmpMarking = ~uint(256) & tmpMarking;
                if (_warehouse_available == true) {
                    tmpMarking = uint(1024) | tmpMarking;
                }
                else {
                    tmpMarking = uint(512) | tmpMarking;
                }
                continue;
            }
            if (uint(512) & tmpMarking != 0) {
                emit execution_progress("Activity_0ksu04d");
                tmpMarking = ~uint(512) & tmpMarking;
                tmpMarking = uint(2048) | tmpMarking;
                continue;
            }
            if (uint(3072) & tmpMarking != 0) {
                emit execution_progress("Gateway_02byf3s");
                tmpMarking = ~uint(3072) & tmpMarking;
                tmpMarking = uint(4096) | tmpMarking;
                continue;
            }
            if (uint(4096) & tmpMarking != 0) {
                emit execution_progress("Event_12ox46m");
                tmpMarking = ~uint(4096) & tmpMarking;
                tmpMarking = uint(8192) | tmpMarking;
                continue;
            }
            if (uint(16384) & tmpMarking != 0) {
                emit execution_progress("Activity_17kev5e");
                tmpMarking = ~uint(16384) & tmpMarking;
                emit Activity_17kev5e_Message_Pack_products();
                tmpMarking = uint(524288) | tmpMarking;
                continue;
            }
            if (uint(2129920) & tmpMarking == uint(2129920)) {
                emit execution_progress("Gateway_114lea0");
                tmpMarking = ~uint(2129920) & tmpMarking;
                tmpMarking = uint(4194304) | tmpMarking;
                continue;
            }
            if (uint(1572864) & tmpMarking == uint(1572864)) {
                emit execution_progress("Gateway_1mty1l6");
                tmpMarking = ~uint(1572864) & tmpMarking;
                tmpMarking = uint(2097152) | tmpMarking;
                continue;
            }
            if (uint(134217728) & tmpMarking != 0) {
                emit execution_progress("Event_0os0wzu");
                tmpMarking = ~uint(134217728) & tmpMarking;
                emit Event_0os0wzu_Message("Shipment_failed");
                continue;
            }
            if (uint(4194304) & tmpMarking != 0) {
                emit execution_progress("Event_1sooxn7");
                tmpMarking = ~uint(4194304) & tmpMarking;
                emit Event_1sooxn7_Message("Products_on_ship");
                tmpMarking = uint(8388608) | tmpMarking;
                continue;
            }
            if (uint(8388608) & tmpMarking != 0) {
                emit execution_progress("Activity_1qb30d6");
                tmpMarking = ~uint(8388608) & tmpMarking;
                tmpMarking = uint(16777216) | tmpMarking;
                continue;
            }
            if (uint(16777216) & tmpMarking != 0) {
                emit execution_progress("Activity_19dokas");
                tmpMarking = ~uint(16777216) & tmpMarking;
                tmpMarking = uint(33554432) | tmpMarking;
                continue;
            }
            if (uint(67108864) & tmpMarking != 0) {
                emit execution_progress("Event_17m30y1");
                tmpMarking = ~uint(67108864) & tmpMarking;
                continue;
            }
            if (uint(268435456) & tmpMarking != 0) {
                emit execution_progress("Gateway_0052v9k");
                tmpMarking = ~uint(268435456) & tmpMarking;
                if (_customs_passed == true) {
                    tmpMarking = uint(32768) | tmpMarking;
                }
                else {
                    tmpMarking = uint(134217728) | tmpMarking;
                }
                continue;
            }
            break;
        }
        if (marking != 0 || startedActivities != 0) {
            marking = tmpMarking;
            startedActivities = tmpStartedActivities;
        }
    }

    function Initiate_shipping_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Initiate_shipping_Requested(tmp1);
    }

    function Prepare_products_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Prepare_products_Requested(tmp1);
    }

    function Outgoing_customs_procedures_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Outgoing_customs_procedures_Requested(tmp1);
    }

    function Book_for_shipmen_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Book_for_shipmen_Requested(tmp1);
    }

    function Check_warehouse_status_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Check_warehouse_status_Requested(tmp1);
    }

    function Arrange_deliver_time_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Arrange_deliver_time_Requested(tmp1);
    }

    function Receiver_received_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Receiver_received_Requested(tmp1);
    }

    function Initiate_shipping(uint workitemId) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Initiate_shipping_complete(workitems[workitemId].elementIndex);
        workitems[workitemId].operated = true;
    }

    function Prepare_products(uint workitemId) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Prepare_products_complete(workitems[workitemId].elementIndex);
        workitems[workitemId].operated = true;
    }

    function Outgoing_customs_procedures(uint workitemId, bool customs_passed) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Outgoing_customs_procedures_complete(workitems[workitemId].elementIndex, customs_passed);
        workitems[workitemId].operated = true;
    }

    function Book_for_shipmen(uint workitemId) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Book_for_shipmen_complete(workitems[workitemId].elementIndex);
        workitems[workitemId].operated = true;
    }

    function Check_warehouse_status(uint workitemId, bool warehouse_available) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Check_warehouse_status_complete(workitems[workitemId].elementIndex, warehouse_available);
        workitems[workitemId].operated = true;
    }

    function Arrange_deliver_time(uint workitemId) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Arrange_deliver_time_complete(workitems[workitemId].elementIndex);
        workitems[workitemId].operated = true;
    }

    function Receiver_received(uint workitemId) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Receiver_received_complete(workitems[workitemId].elementIndex);
        workitems[workitemId].operated = true;
    }

}

