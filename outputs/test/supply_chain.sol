// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract supply_chain_Contract {
    struct Order_table {
       string good_name;
       uint quantity;
    }
    struct Workitem {
       uint elementIndex;
       bool operated;
    }

    uint public marking = 2;
    uint public startedActivities = 0;
    Order_table _order_info;
    bool _approve = true;
    bool _pay = true;
    Workitem[] private workitems;

    event Event_07dwn0z_Message(string messageText);
    event Event_1svc6nt_Message(string messageText);
    event Event_1yeq6m2_Message(string messageText);
    event Event_0k174q2_Message(string messageText);
    event execution_progress(string msg);
    event Order_Goods_Requested(uint index);
    event Approve_order_Requested(uint index);
    event Pay_for_goods_Requested(uint index);


    constructor () {
    }

    function startExecution() public {
        require(marking == uint(2) && startedActivities == uint(0));
        step(uint(2), 0);
    }

    function Order_Goods_complete(uint elementIndex, Order_table memory order_info) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(1)) {
            require(uint(2) & tmpStartedActivities != 0);
            _order_info = order_info;
            step(uint(8) | tmpMarking, ~uint(2) & tmpStartedActivities);
            return;
        }
    }

    function Approve_order_complete(uint elementIndex, bool approve) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(2)) {
            require(uint(4) & tmpStartedActivities != 0);
            _approve = approve;
            step(uint(16) | tmpMarking, ~uint(4) & tmpStartedActivities);
            return;
        }
    }

    function Pay_for_goods_complete(uint elementIndex, bool pay) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(3)) {
            require(uint(8) & tmpStartedActivities != 0);
            _pay = pay;
            step(uint(4096) | tmpMarking, ~uint(8) & tmpStartedActivities);
            return;
        }
    }

    function step(uint tmpMarking, uint tmpStartedActivities) internal {
        while(true){
            if (uint(2) & tmpMarking != 0) {
                emit execution_progress("Activity_0va6hm7");
                tmpMarking = ~uint(2) & tmpMarking;
                Order_Goods_start(1);
                tmpStartedActivities = uint(2) | tmpStartedActivities;
                continue;
            }
            if (uint(4) & tmpMarking != 0) {
                emit execution_progress("Activity_042ok61");
                tmpMarking = ~uint(4) & tmpMarking;
                Approve_order_start(2);
                tmpStartedActivities = uint(4) | tmpStartedActivities;
                continue;
            }
            if (uint(2048) & tmpMarking != 0) {
                emit execution_progress("Activity_07gia3i");
                tmpMarking = ~uint(2048) & tmpMarking;
                Pay_for_goods_start(3);
                tmpStartedActivities = uint(8) | tmpStartedActivities;
                continue;
            }
            if (uint(8) & tmpMarking == uint(8)) {
                emit execution_progress("Gateway_1xvyoq4");
                tmpMarking = ~uint(8) & tmpMarking;
                tmpMarking = uint(2176) | tmpMarking;
                continue;
            }
            if (uint(32) & tmpMarking != 0) {
                emit execution_progress("Event_07dwn0z");
                tmpMarking = ~uint(32) & tmpMarking;
                emit Event_07dwn0z_Message("Order_approved");
                tmpMarking = uint(256) | tmpMarking;
                continue;
            }
            if (uint(16) & tmpMarking != 0) {
                emit execution_progress("Gateway_1buqfsf");
                tmpMarking = ~uint(16) & tmpMarking;
                if (_approve == true) {
                    tmpMarking = uint(32) | tmpMarking;
                }
                else {
                    tmpMarking = uint(64) | tmpMarking;
                }
                continue;
            }
            if (uint(128) & tmpMarking != 0) {
                emit execution_progress("Event_0ma3mbe");
                tmpMarking = ~uint(128) & tmpMarking;
                tmpMarking = uint(4) | tmpMarking;
                continue;
            }
            if (uint(33280) & tmpMarking == uint(33280)) {
                emit execution_progress("Gateway_1a8afmy");
                tmpMarking = ~uint(33280) & tmpMarking;
                tmpMarking = uint(1024) | tmpMarking;
                continue;
            }
            if (uint(256) & tmpMarking != 0) {
                emit execution_progress("Activity_1h6uj8j");
                tmpMarking = ~uint(256) & tmpMarking;
                tmpMarking = uint(512) | tmpMarking;
                continue;
            }
            if (uint(64) & tmpMarking != 0) {
                emit execution_progress("Event_1svc6nt");
                tmpMarking = ~uint(64) & tmpMarking;
                emit Event_1svc6nt_Message("Order_declined");
                continue;
            }
            if (uint(4096) & tmpMarking != 0) {
                emit execution_progress("Gateway_1nu9dol");
                tmpMarking = ~uint(4096) & tmpMarking;
                if (_pay == true) {
                    tmpMarking = uint(16384) | tmpMarking;
                }
                else {
                    tmpMarking = uint(8192) | tmpMarking;
                }
                continue;
            }
            if (uint(8192) & tmpMarking != 0) {
                emit execution_progress("Event_1yeq6m2");
                tmpMarking = ~uint(8192) & tmpMarking;
                emit Event_1yeq6m2_Message("Order_declined");
                continue;
            }
            if (uint(16384) & tmpMarking != 0) {
                emit execution_progress("Event_1hsvm4c");
                tmpMarking = ~uint(16384) & tmpMarking;
                tmpMarking = uint(32768) | tmpMarking;
                continue;
            }
            if (uint(1024) & tmpMarking != 0) {
                emit execution_progress("Event_0k174q2");
                tmpMarking = ~uint(1024) & tmpMarking;
                emit Event_0k174q2_Message("Received_goods");
                continue;
            }
            break;
        }
        if (marking != 0 || startedActivities != 0) {
            marking = tmpMarking;
            startedActivities = tmpStartedActivities;
        }
    }

    function Order_Goods_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Order_Goods_Requested(tmp1);
    }

    function Approve_order_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Approve_order_Requested(tmp1);
    }

    function Pay_for_goods_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Pay_for_goods_Requested(tmp1);
    }

    function Order_Goods(uint workitemId, string memory order_info_good_name, uint order_info_quantity) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Order_Goods_complete(workitems[workitemId].elementIndex, Order_table(order_info_good_name, order_info_quantity));
        workitems[workitemId].operated = true;
    }

    function Approve_order(uint workitemId, bool approve) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Approve_order_complete(workitems[workitemId].elementIndex, approve);
        workitems[workitemId].operated = true;
    }

    function Pay_for_goods(uint workitemId, bool pay) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Pay_for_goods_complete(workitems[workitemId].elementIndex, pay);
        workitems[workitemId].operated = true;
    }

}

