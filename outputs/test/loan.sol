// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract loan_Contract {
    struct Workitem {
       uint elementIndex;
       bool operated;
    }

    uint public marking = 2;
    uint public startedActivities = 0;
    bool _fraud_history = false;
    uint _credit_score = 0;
    Workitem[] private workitems;

    event execution_progress(string msg);
    event Activity_1blnahy_Message_Approve_Loan();
    event Activity_1hetxbf_Message_Deny_Loan();
    event Perform_Fraud_Check_Requested(uint index);
    event Get_Credit_Score_Requested(uint index);


    constructor () {
    }

    function startExecution() public {
        require(marking == uint(2) && startedActivities == uint(0));
        step(uint(2), 0);
    }

    function Perform_Fraud_Check_complete(uint elementIndex, bool fraud_history) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(1)) {
            require(uint(2) & tmpStartedActivities != 0);
            _fraud_history = fraud_history;
            step(uint(4) | tmpMarking, ~uint(2) & tmpStartedActivities);
            return;
        }
    }

    function Get_Credit_Score_complete(uint elementIndex, uint credit_score) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(2)) {
            require(uint(4) & tmpStartedActivities != 0);
            _credit_score = credit_score;
            step(uint(16) | tmpMarking, ~uint(4) & tmpStartedActivities);
            return;
        }
    }

    function step(uint tmpMarking, uint tmpStartedActivities) internal {
        while(true){
            if (uint(2) & tmpMarking != 0) {
                emit execution_progress("Activity_1ki3swt");
                tmpMarking = ~uint(2) & tmpMarking;
                Perform_Fraud_Check_start(1);
                tmpStartedActivities = uint(2) | tmpStartedActivities;
                continue;
            }
            if (uint(8) & tmpMarking != 0) {
                emit execution_progress("Activity_15ynia4");
                tmpMarking = ~uint(8) & tmpMarking;
                Get_Credit_Score_start(2);
                tmpStartedActivities = uint(4) | tmpStartedActivities;
                continue;
            }
            if (uint(4) & tmpMarking != 0) {
                emit execution_progress("Gateway_04z6kpv");
                tmpMarking = ~uint(4) & tmpMarking;
                if (_fraud_history == false) {
                    tmpMarking = uint(8) | tmpMarking;
                }
                else {
                    tmpMarking = uint(512) | tmpMarking;
                }
                continue;
            }
            if (uint(16) & tmpMarking != 0) {
                emit execution_progress("Gateway_1gc0mzu");
                tmpMarking = ~uint(16) & tmpMarking;
                if (_credit_score >= 90) {
                    tmpMarking = uint(32) | tmpMarking;
                }
                else {
                    tmpMarking = uint(128) | tmpMarking;
                }
                continue;
            }
            if (uint(32) & tmpMarking != 0) {
                emit execution_progress("Activity_1blnahy");
                tmpMarking = ~uint(32) & tmpMarking;
                emit Activity_1blnahy_Message_Approve_Loan();
                tmpMarking = uint(64) | tmpMarking;
                continue;
            }
            if (uint(64) & tmpMarking != 0) {
                emit execution_progress("Event_06sr5v4");
                tmpMarking = ~uint(64) & tmpMarking;
                continue;
            }
            if (uint(640) & tmpMarking != 0) {
                emit execution_progress("Activity_1hetxbf");
                tmpMarking = ~uint(640) & tmpMarking;
                emit Activity_1hetxbf_Message_Deny_Loan();
                tmpMarking = uint(256) | tmpMarking;
                continue;
            }
            if (uint(256) & tmpMarking != 0) {
                emit execution_progress("Event_17ki8gw");
                tmpMarking = ~uint(256) & tmpMarking;
                continue;
            }
            break;
        }
        if (marking != 0 || startedActivities != 0) {
            marking = tmpMarking;
            startedActivities = tmpStartedActivities;
        }
    }

    function Perform_Fraud_Check_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Perform_Fraud_Check_Requested(tmp1);
    }

    function Get_Credit_Score_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Get_Credit_Score_Requested(tmp1);
    }

    function Perform_Fraud_Check(uint workitemId, bool fraud_history) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Perform_Fraud_Check_complete(workitems[workitemId].elementIndex, fraud_history);
        workitems[workitemId].operated = true;
    }

    function Get_Credit_Score(uint workitemId, uint credit_score) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Get_Credit_Score_complete(workitems[workitemId].elementIndex, credit_score);
        workitems[workitemId].operated = true;
    }

}

