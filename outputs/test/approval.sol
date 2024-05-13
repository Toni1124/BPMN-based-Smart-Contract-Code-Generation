// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract approval_Contract {
    struct Workitem {
       uint elementIndex;
       bool operated;
    }

    uint public marking = 2;
    uint public startedActivities = 0;
    string _book_name;
    bool _book_available;
    Workitem[] private workitems;

    event execution_progress(string msg);
    event Borrow_book_request_Requested(uint index);
    event Get_book_status_Requested(uint index);
    event Checkout_book_Requested(uint index);


    constructor () {
    }

    function startExecution() public {
        require(marking == uint(2) && startedActivities == uint(0));
        step(uint(2), 0);
    }

    function Borrow_book_request_complete(uint elementIndex, string memory book_name) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(1)) {
            require(uint(2) & tmpStartedActivities != 0);
            _book_name = book_name;
            step(uint(4) | tmpMarking, ~uint(2) & tmpStartedActivities);
            return;
        }
    }

    function Get_book_status_complete(uint elementIndex, bool book_available) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(2)) {
            require(uint(4) & tmpStartedActivities != 0);
            _book_available = book_available;
            step(uint(8) | tmpMarking, ~uint(4) & tmpStartedActivities);
            return;
        }
    }

    function Checkout_book_complete(uint elementIndex) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(3)) {
            require(uint(8) & tmpStartedActivities != 0);
            step(uint(64) | tmpMarking, ~uint(8) & tmpStartedActivities);
            return;
        }
    }

    function step(uint tmpMarking, uint tmpStartedActivities) internal {
        while(true){
            if (uint(2) & tmpMarking != 0) {
                emit execution_progress("Activity_0e4azt8");
                tmpMarking = ~uint(2) & tmpMarking;
                Borrow_book_request_start(1);
                tmpStartedActivities = uint(2) | tmpStartedActivities;
                continue;
            }
            if (uint(4) & tmpMarking != 0) {
                emit execution_progress("Activity_007jrsk");
                tmpMarking = ~uint(4) & tmpMarking;
                Get_book_status_start(2);
                tmpStartedActivities = uint(4) | tmpStartedActivities;
                continue;
            }
            if (uint(32) & tmpMarking != 0) {
                emit execution_progress("Activity_1fcs2xe");
                tmpMarking = ~uint(32) & tmpMarking;
                Checkout_book_start(3);
                tmpStartedActivities = uint(8) | tmpStartedActivities;
                continue;
            }
            if (uint(8) & tmpMarking != 0) {
                emit execution_progress("Gateway_1935g2m");
                tmpMarking = ~uint(8) & tmpMarking;
                if (_book_available == false) {
                    tmpMarking = uint(16) | tmpMarking;
                }
                if (_book_available == true) {
                    tmpMarking = uint(32) | tmpMarking;
                }
                continue;
            }
            if (uint(16) & tmpMarking != 0) {
                emit execution_progress("Event_0mipy6r");
                tmpMarking = ~uint(16) & tmpMarking;
                continue;
            }
            if (uint(64) & tmpMarking != 0) {
                emit execution_progress("Event_1mve6j7");
                tmpMarking = ~uint(64) & tmpMarking;
                continue;
            }
            break;
        }
        if (marking != 0 || startedActivities != 0) {
            marking = tmpMarking;
            startedActivities = tmpStartedActivities;
        }
    }

    function Borrow_book_request_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Borrow_book_request_Requested(tmp1);
    }

    function Get_book_status_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Get_book_status_Requested(tmp1);
    }

    function Checkout_book_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Checkout_book_Requested(tmp1);
    }

    function Borrow_book_request(uint workitemId, string memory book_name) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Borrow_book_request_complete(workitems[workitemId].elementIndex, book_name);
        workitems[workitemId].operated = true;
    }

    function Get_book_status(uint workitemId, bool book_available) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Get_book_status_complete(workitems[workitemId].elementIndex, book_available);
        workitems[workitemId].operated = true;
    }

    function Checkout_book(uint workitemId) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Checkout_book_complete(workitems[workitemId].elementIndex);
        workitems[workitemId].operated = true;
    }

}

