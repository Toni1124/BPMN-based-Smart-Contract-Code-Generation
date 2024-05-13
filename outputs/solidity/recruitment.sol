// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract recruitment_Contract {
    struct Resume {
       string name;
       bytes intro;
    }
    struct Workitem {
       uint elementIndex;
       bool operated;
    }

    uint public marking = 2;
    uint public startedActivities = 0;
    Resume _candidate_resume;
    bool _interview_decision = false;
    string _rejection = "Application_rejected";
    bool _hr_interview_decision = false;
    string _hr_interview_Performance;
    string _manager_Interview_Performance;
    bool _manager_interview_decision = false;
    string _acception = "Application_accepted";
    Workitem[] private workitems;

    event Event_1rrwg49_Message(string messageText);
    event Event_09v08wj_Message(string messageText);
    event Event_1rl1pem_Message(string messageText);
    event Event_0d8unes_Message(string messageText);
    event execution_progress(string msg);
    event Submit_Application_Requested(uint index);
    event Receive_Application_Requested(uint index);
    event Schedule_Interview_Requested(uint index);
    event Attend_HR_Interview_Requested(uint index);
    event HR_Evaluate_Candidate_Requested(uint index, string hr_interview_Performance);
    event Schedule_Manager_Interview_Requested(uint index);
    event Attend_Manager_Interview_Requested(uint index);
    event Manager_Interview_Candidate_Requested(uint index, string manager_Interview_Performance);


    constructor () {
    }

    function startExecution() public {
        require(marking == uint(2) && startedActivities == uint(0));
        step(uint(2), 0);
    }

    function Submit_Application_complete(uint elementIndex, Resume memory candidate_resume) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(1)) {
            require(uint(2) & tmpStartedActivities != 0);
            _candidate_resume = candidate_resume;
            step(uint(4) | tmpMarking, ~uint(2) & tmpStartedActivities);
            return;
        }
    }

    function Receive_Application_complete(uint elementIndex, bool interview_decision) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(2)) {
            require(uint(4) & tmpStartedActivities != 0);
            _interview_decision = interview_decision;
            step(uint(8) | tmpMarking, ~uint(4) & tmpStartedActivities);
            return;
        }
    }

    function Schedule_Interview_complete(uint elementIndex) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(3)) {
            require(uint(8) & tmpStartedActivities != 0);
            step(uint(64) | tmpMarking, ~uint(8) & tmpStartedActivities);
            return;
        }
    }

    function Attend_HR_Interview_complete(uint elementIndex, string memory hr_interview_Performance) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(4)) {
            require(uint(16) & tmpStartedActivities != 0);
            _hr_interview_Performance = hr_interview_Performance;
            step(uint(128) | tmpMarking, ~uint(16) & tmpStartedActivities);
            return;
        }
    }

    function HR_Evaluate_Candidate_complete(uint elementIndex, bool hr_interview_decision) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(5)) {
            require(uint(32) & tmpStartedActivities != 0);
            _hr_interview_decision = hr_interview_decision;
            step(uint(256) | tmpMarking, ~uint(32) & tmpStartedActivities);
            return;
        }
    }

    function Schedule_Manager_Interview_complete(uint elementIndex) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(6)) {
            require(uint(64) & tmpStartedActivities != 0);
            step(uint(16384) | tmpMarking, ~uint(64) & tmpStartedActivities);
            return;
        }
    }

    function Attend_Manager_Interview_complete(uint elementIndex, string memory manager_Interview_Performance) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(7)) {
            require(uint(128) & tmpStartedActivities != 0);
            _manager_Interview_Performance = manager_Interview_Performance;
            step(uint(32768) | tmpMarking, ~uint(128) & tmpStartedActivities);
            return;
        }
    }

    function Manager_Interview_Candidate_complete(uint elementIndex, bool manager_interview_decision) internal {
        uint tmpMarking = marking;
        uint tmpStartedActivities = startedActivities;
        if (elementIndex == uint(8)) {
            require(uint(256) & tmpStartedActivities != 0);
            _manager_interview_decision = manager_interview_decision;
            step(uint(2048) | tmpMarking, ~uint(256) & tmpStartedActivities);
            return;
        }
    }

    function step(uint tmpMarking, uint tmpStartedActivities) internal {
        while(true){
            if (uint(2) & tmpMarking != 0) {
                emit execution_progress("Activity_1hlt2li");
                tmpMarking = ~uint(2) & tmpMarking;
                Submit_Application_start(1);
                tmpStartedActivities = uint(2) | tmpStartedActivities;
                continue;
            }
            if (uint(4) & tmpMarking != 0) {
                emit execution_progress("Activity_0v1du56");
                tmpMarking = ~uint(4) & tmpMarking;
                Receive_Application_start(2);
                tmpStartedActivities = uint(4) | tmpStartedActivities;
                continue;
            }
            if (uint(32) & tmpMarking != 0) {
                emit execution_progress("Activity_129h9gd");
                tmpMarking = ~uint(32) & tmpMarking;
                Schedule_Interview_start(3);
                tmpStartedActivities = uint(8) | tmpStartedActivities;
                continue;
            }
            if (uint(64) & tmpMarking != 0) {
                emit execution_progress("Activity_1amevbe");
                tmpMarking = ~uint(64) & tmpMarking;
                Attend_HR_Interview_start(4);
                tmpStartedActivities = uint(16) | tmpStartedActivities;
                continue;
            }
            if (uint(128) & tmpMarking != 0) {
                emit execution_progress("Activity_09ukh6e");
                tmpMarking = ~uint(128) & tmpMarking;
                HR_Evaluate_Candidate_start(5, _hr_interview_Performance);
                tmpStartedActivities = uint(32) | tmpStartedActivities;
                continue;
            }
            if (uint(1024) & tmpMarking != 0) {
                emit execution_progress("Activity_0i5d5oy");
                tmpMarking = ~uint(1024) & tmpMarking;
                Schedule_Manager_Interview_start(6);
                tmpStartedActivities = uint(64) | tmpStartedActivities;
                continue;
            }
            if (uint(16384) & tmpMarking != 0) {
                emit execution_progress("Activity_0gnf4by");
                tmpMarking = ~uint(16384) & tmpMarking;
                Attend_Manager_Interview_start(7);
                tmpStartedActivities = uint(128) | tmpStartedActivities;
                continue;
            }
            if (uint(32768) & tmpMarking != 0) {
                emit execution_progress("Activity_09s6ylb");
                tmpMarking = ~uint(32768) & tmpMarking;
                Manager_Interview_Candidate_start(8, _manager_Interview_Performance);
                tmpStartedActivities = uint(256) | tmpStartedActivities;
                continue;
            }
            if (uint(8) & tmpMarking != 0) {
                emit execution_progress("Gateway_0ce91bt");
                tmpMarking = ~uint(8) & tmpMarking;
                if (_interview_decision == true) {
                    tmpMarking = uint(32) | tmpMarking;
                }
                else {
                    tmpMarking = uint(16) | tmpMarking;
                }
                continue;
            }
            if (uint(16) & tmpMarking != 0) {
                emit execution_progress("Event_1rrwg49");
                tmpMarking = ~uint(16) & tmpMarking;
                emit Event_1rrwg49_Message("");
                continue;
            }
            if (uint(256) & tmpMarking != 0) {
                emit execution_progress("Gateway_0viuavz");
                tmpMarking = ~uint(256) & tmpMarking;
                if (_hr_interview_decision == true) {
                    tmpMarking = uint(1024) | tmpMarking;
                }
                else {
                    tmpMarking = uint(512) | tmpMarking;
                }
                continue;
            }
            if (uint(512) & tmpMarking != 0) {
                emit execution_progress("Event_09v08wj");
                tmpMarking = ~uint(512) & tmpMarking;
                emit Event_09v08wj_Message("Event_09v08wj");
                continue;
            }
            if (uint(2048) & tmpMarking != 0) {
                emit execution_progress("Gateway_1yz1fsn");
                tmpMarking = ~uint(2048) & tmpMarking;
                if (_manager_interview_decision == true) {
                    tmpMarking = uint(8192) | tmpMarking;
                }
                else {
                    tmpMarking = uint(4096) | tmpMarking;
                }
                continue;
            }
            if (uint(4096) & tmpMarking != 0) {
                emit execution_progress("Event_1rl1pem");
                tmpMarking = ~uint(4096) & tmpMarking;
                emit Event_1rl1pem_Message("Event_1rl1pem");
                continue;
            }
            if (uint(8192) & tmpMarking != 0) {
                emit execution_progress("Event_0d8unes");
                tmpMarking = ~uint(8192) & tmpMarking;
                emit Event_0d8unes_Message("Event_0d8unes");
                continue;
            }
            break;
        }
        if (marking != 0 || startedActivities != 0) {
            marking = tmpMarking;
            startedActivities = tmpStartedActivities;
        }
    }

    function Submit_Application_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Submit_Application_Requested(tmp1);
    }

    function Receive_Application_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Receive_Application_Requested(tmp1);
    }

    function Schedule_Interview_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Schedule_Interview_Requested(tmp1);
    }

    function Attend_HR_Interview_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Attend_HR_Interview_Requested(tmp1);
    }

    function HR_Evaluate_Candidate_start(uint elementIndex, string memory hr_interview_Performance) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit HR_Evaluate_Candidate_Requested(tmp1, hr_interview_Performance);
    }

    function Schedule_Manager_Interview_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Schedule_Manager_Interview_Requested(tmp1);
    }

    function Attend_Manager_Interview_start(uint elementIndex) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Attend_Manager_Interview_Requested(tmp1);
    }

    function Manager_Interview_Candidate_start(uint elementIndex, string memory manager_Interview_Performance) internal {
        workitems.push(Workitem(elementIndex, false));
        uint tmp0 = workitems.length;
        uint tmp1 = tmp0 - 1;
        emit Manager_Interview_Candidate_Requested(tmp1, manager_Interview_Performance);
    }

    function Submit_Application(uint workitemId, string memory candidate_resume_name, bytes memory candidate_resume_intro) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Submit_Application_complete(workitems[workitemId].elementIndex, Resume(candidate_resume_name, candidate_resume_intro));
        workitems[workitemId].operated = true;
    }

    function Receive_Application(uint workitemId, bool interview_decision) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Receive_Application_complete(workitems[workitemId].elementIndex, interview_decision);
        workitems[workitemId].operated = true;
    }

    function Schedule_Interview(uint workitemId) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Schedule_Interview_complete(workitems[workitemId].elementIndex);
        workitems[workitemId].operated = true;
    }

    function Attend_HR_Interview(uint workitemId, string memory hr_interview_Performance) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Attend_HR_Interview_complete(workitems[workitemId].elementIndex, hr_interview_Performance);
        workitems[workitemId].operated = true;
    }

    function HR_Evaluate_Candidate(uint workitemId, bool hr_interview_decision) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        HR_Evaluate_Candidate_complete(workitems[workitemId].elementIndex, hr_interview_decision);
        workitems[workitemId].operated = true;
    }

    function Schedule_Manager_Interview(uint workitemId) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Schedule_Manager_Interview_complete(workitems[workitemId].elementIndex);
        workitems[workitemId].operated = true;
    }

    function Attend_Manager_Interview(uint workitemId, string memory manager_Interview_Performance) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Attend_Manager_Interview_complete(workitems[workitemId].elementIndex, manager_Interview_Performance);
        workitems[workitemId].operated = true;
    }

    function Manager_Interview_Candidate(uint workitemId, bool manager_interview_decision) external {
        require(workitemId < workitems.length && workitems[workitemId].operated != true);
        Manager_Interview_Candidate_complete(workitems[workitemId].elementIndex, manager_interview_decision);
        workitems[workitemId].operated = true;
    }

}

