module deployer::recruitment_Contract {
    use std::string;
    use std::bit_vector;
    use std::vector;
    use aptos_std::simple_map;
    use aptos_framework::event;

    struct Resume has store, copy, drop {
       name: string::String,
       intro: bit_vector::BitVector,
    }
    struct Workitem has store {
       elementIndex: u128,
       operated: bool,
    }

    struct Marking has key, store {
       marking: u128,
    }

    struct Startedactivities has key, store {
       startedActivities: u128,
    }

    struct Candidate_resume has key, store {
       _candidate_resume: Resume,
    }

    struct Interview_decision has key, store {
       _interview_decision: bool,
    }

    struct Rejection has key, store {
       _rejection: string::String,
    }

    struct Hr_interview_decision has key, store {
       _hr_interview_decision: bool,
    }

    struct Hr_interview_performance has key, store {
       _hr_interview_Performance: string::String,
    }

    struct Manager_interview_performance has key, store {
       _manager_Interview_Performance: string::String,
    }

    struct Manager_interview_decision has key, store {
       _manager_interview_decision: bool,
    }

    struct Acception has key, store {
       _acception: string::String,
    }

    struct Workitems has key, store {
       workitems: vector<Workitem>
    }


    #[event]
    struct Event_1rrwg49_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Event_09v08wj_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Event_1rl1pem_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Event_0d8unes_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Execution_progress has drop, store {
       msg: string::String, 
    }

    #[event]
    struct Submit_application_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Receive_application_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Schedule_interview_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Attend_hr_interview_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Hr_evaluate_candidate_requested has drop, store {
       index: u128, 
       hr_interview_Performance: string::String, 
    }

    #[event]
    struct Schedule_manager_interview_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Attend_manager_interview_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Manager_interview_candidate_requested has drop, store {
       index: u128, 
       manager_Interview_Performance: string::String, 
    }



    fun init_module(account: &signer) {
        move_to(account, Workitems {workitems: vector::empty<Workitem>()});
        move_to(account, Marking{marking: 2, });
        move_to(account, Startedactivities{startedActivities: 0, });
        move_to(account, Interview_decision{_interview_decision: false, });
        move_to(account, Rejection{_rejection: string::utf8(b"Application_rejected"), });
        move_to(account, Hr_interview_decision{_hr_interview_decision: false, });
        move_to(account, Manager_interview_decision{_manager_interview_decision: false, });
        move_to(account, Acception{_acception: string::utf8(b"Application_accepted"), });
        move_to(account, Hr_interview_performance{_hr_interview_Performance: string::utf8(b""), });
        move_to(account, Candidate_resume{_candidate_resume: Resume{name: string::utf8(b""), intro: bit_vector::new(8), }, });
        move_to(account, Manager_interview_performance{_manager_Interview_Performance: string::utf8(b""), });
    }

    fun Submit_Application_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Submit_application_requested {index: tmp1});
    }

    fun Receive_Application_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Receive_application_requested {index: tmp1});
    }

    fun Schedule_Interview_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Schedule_interview_requested {index: tmp1});
    }

    fun Attend_HR_Interview_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Attend_hr_interview_requested {index: tmp1});
    }

    fun HR_Evaluate_Candidate_start(elementIndex: u128, hr_interview_Performance: string::String) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Hr_evaluate_candidate_requested {index: tmp1, hr_interview_Performance: hr_interview_Performance});
    }

    fun Schedule_Manager_Interview_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Schedule_manager_interview_requested {index: tmp1});
    }

    fun Attend_Manager_Interview_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Attend_manager_interview_requested {index: tmp1});
    }

    fun Manager_Interview_Candidate_start(elementIndex: u128, manager_Interview_Performance: string::String) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Manager_interview_candidate_requested {index: tmp1, manager_Interview_Performance: manager_Interview_Performance});
    }

    fun step(tmpMarking: u128, tmpStartedActivities: u128) acquires Workitems, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision, Marking, Startedactivities {
        loop {
            if ((2u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1hlt2li")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpMarking;
                Submit_Application_start(1);
                tmpStartedActivities = (2u128) | tmpStartedActivities;
                continue
            };
            if ((4u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0v1du56")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpMarking;
                Receive_Application_start(2);
                tmpStartedActivities = (4u128) | tmpStartedActivities;
                continue
            };
            if ((32u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_129h9gd")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (32u128)) & tmpMarking;
                Schedule_Interview_start(3);
                tmpStartedActivities = (8u128) | tmpStartedActivities;
                continue
            };
            if ((64u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1amevbe")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (64u128)) & tmpMarking;
                Attend_HR_Interview_start(4);
                tmpStartedActivities = (16u128) | tmpStartedActivities;
                continue
            };
            if ((128u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_09ukh6e")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (128u128)) & tmpMarking;
                HR_Evaluate_Candidate_start(5, borrow_global<Hr_interview_performance>(@deployer)._hr_interview_Performance);
                tmpStartedActivities = (32u128) | tmpStartedActivities;
                continue
            };
            if ((1024u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0i5d5oy")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (1024u128)) & tmpMarking;
                Schedule_Manager_Interview_start(6);
                tmpStartedActivities = (64u128) | tmpStartedActivities;
                continue
            };
            if ((16384u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0gnf4by")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16384u128)) & tmpMarking;
                Attend_Manager_Interview_start(7);
                tmpStartedActivities = (128u128) | tmpStartedActivities;
                continue
            };
            if ((32768u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_09s6ylb")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (32768u128)) & tmpMarking;
                Manager_Interview_Candidate_start(8, borrow_global<Manager_interview_performance>(@deployer)._manager_Interview_Performance);
                tmpStartedActivities = (256u128) | tmpStartedActivities;
                continue
            };
            if ((8u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_0ce91bt")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpMarking;
                if (borrow_global<Interview_decision>(@deployer)._interview_decision == true) {
                    tmpMarking = (32u128) | tmpMarking;
                }
                else {
                    tmpMarking = (16u128) | tmpMarking;
                };
                continue
            };
            if ((16u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_1rrwg49")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16u128)) & tmpMarking;
                event::emit (Event_1rrwg49_message {messageText: string::utf8(b"")});
                continue
            };
            if ((256u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_0viuavz")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (256u128)) & tmpMarking;
                if (borrow_global<Hr_interview_decision>(@deployer)._hr_interview_decision == true) {
                    tmpMarking = (1024u128) | tmpMarking;
                }
                else {
                    tmpMarking = (512u128) | tmpMarking;
                };
                continue
            };
            if ((512u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_09v08wj")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (512u128)) & tmpMarking;
                event::emit (Event_09v08wj_message {messageText: string::utf8(b"Event_09v08wj")});
                continue
            };
            if ((2048u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1yz1fsn")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2048u128)) & tmpMarking;
                if (borrow_global<Manager_interview_decision>(@deployer)._manager_interview_decision == true) {
                    tmpMarking = (8192u128) | tmpMarking;
                }
                else {
                    tmpMarking = (4096u128) | tmpMarking;
                };
                continue
            };
            if ((4096u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_1rl1pem")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4096u128)) & tmpMarking;
                event::emit (Event_1rl1pem_message {messageText: string::utf8(b"Event_1rl1pem")});
                continue
            };
            if ((8192u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_0d8unes")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8192u128)) & tmpMarking;
                event::emit (Event_0d8unes_message {messageText: string::utf8(b"Event_0d8unes")});
                continue
            };
            break
        };
        if (borrow_global<Marking>(@deployer).marking != 0 || borrow_global<Startedactivities>(@deployer).startedActivities != 0) {
            borrow_global_mut<Marking>(@deployer).marking = tmpMarking;
            borrow_global_mut<Startedactivities>(@deployer).startedActivities = tmpStartedActivities;
        };
    }

    public fun startExecution() acquires Marking, Startedactivities, Workitems, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        assert!(borrow_global<Marking>(@deployer).marking == 2u128 && borrow_global<Startedactivities>(@deployer).startedActivities == 0u128, 0);
        step(2u128, 0);
    }

    fun Submit_Application_complete(elementIndex: u128, candidate_resume: Resume) acquires Marking, Startedactivities, Candidate_resume, Workitems, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 1u128) {
            assert!((2u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Candidate_resume>(@deployer)._candidate_resume = candidate_resume;
            step((4u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpStartedActivities);
            return
        };
    }

    fun Receive_Application_complete(elementIndex: u128, interview_decision: bool) acquires Marking, Startedactivities, Interview_decision, Workitems, Hr_interview_performance, Manager_interview_performance, Hr_interview_decision, Manager_interview_decision {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 2u128) {
            assert!((4u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Interview_decision>(@deployer)._interview_decision = interview_decision;
            step((8u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpStartedActivities);
            return
        };
    }

    fun Schedule_Interview_complete(elementIndex: u128) acquires Marking, Startedactivities, Workitems, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 3u128) {
            assert!((8u128) & tmpStartedActivities != 0, 0);
            step((64u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpStartedActivities);
            return
        };
    }

    fun Attend_HR_Interview_complete(elementIndex: u128, hr_interview_Performance: string::String) acquires Marking, Startedactivities, Hr_interview_performance, Workitems, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 4u128) {
            assert!((16u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Hr_interview_performance>(@deployer)._hr_interview_Performance = hr_interview_Performance;
            step((128u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16u128)) & tmpStartedActivities);
            return
        };
    }

    fun HR_Evaluate_Candidate_complete(elementIndex: u128, hr_interview_decision: bool) acquires Marking, Startedactivities, Hr_interview_decision, Workitems, Hr_interview_performance, Manager_interview_performance, Interview_decision, Manager_interview_decision {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 5u128) {
            assert!((32u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Hr_interview_decision>(@deployer)._hr_interview_decision = hr_interview_decision;
            step((256u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (32u128)) & tmpStartedActivities);
            return
        };
    }

    fun Schedule_Manager_Interview_complete(elementIndex: u128) acquires Marking, Startedactivities, Workitems, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 6u128) {
            assert!((64u128) & tmpStartedActivities != 0, 0);
            step((16384u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (64u128)) & tmpStartedActivities);
            return
        };
    }

    fun Attend_Manager_Interview_complete(elementIndex: u128, manager_Interview_Performance: string::String) acquires Marking, Startedactivities, Manager_interview_performance, Workitems, Hr_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 7u128) {
            assert!((128u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Manager_interview_performance>(@deployer)._manager_Interview_Performance = manager_Interview_Performance;
            step((32768u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (128u128)) & tmpStartedActivities);
            return
        };
    }

    fun Manager_Interview_Candidate_complete(elementIndex: u128, manager_interview_decision: bool) acquires Marking, Startedactivities, Manager_interview_decision, Workitems, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 8u128) {
            assert!((256u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Manager_interview_decision>(@deployer)._manager_interview_decision = manager_interview_decision;
            step((2048u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (256u128)) & tmpStartedActivities);
            return
        };
    }

    public fun Submit_Application(workitemId: u128, candidate_resume_name: string::String, candidate_resume_intro: bit_vector::BitVector) acquires Workitems, Marking, Startedactivities, Candidate_resume, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Submit_Application_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, Resume{name: candidate_resume_name, intro: candidate_resume_intro, });
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Receive_Application(workitemId: u128, interview_decision: bool) acquires Workitems, Marking, Startedactivities, Interview_decision, Hr_interview_performance, Manager_interview_performance, Hr_interview_decision, Manager_interview_decision {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Receive_Application_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, interview_decision);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Schedule_Interview(workitemId: u128) acquires Workitems, Marking, Startedactivities, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Schedule_Interview_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Attend_HR_Interview(workitemId: u128, hr_interview_Performance: string::String) acquires Workitems, Marking, Startedactivities, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Attend_HR_Interview_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, hr_interview_Performance);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun HR_Evaluate_Candidate(workitemId: u128, hr_interview_decision: bool) acquires Workitems, Marking, Startedactivities, Hr_interview_decision, Hr_interview_performance, Manager_interview_performance, Interview_decision, Manager_interview_decision {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        HR_Evaluate_Candidate_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, hr_interview_decision);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Schedule_Manager_Interview(workitemId: u128) acquires Workitems, Marking, Startedactivities, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Schedule_Manager_Interview_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Attend_Manager_Interview(workitemId: u128, manager_Interview_Performance: string::String) acquires Workitems, Marking, Startedactivities, Manager_interview_performance, Hr_interview_performance, Interview_decision, Hr_interview_decision, Manager_interview_decision {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Attend_Manager_Interview_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, manager_Interview_Performance);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Manager_Interview_Candidate(workitemId: u128, manager_interview_decision: bool) acquires Workitems, Marking, Startedactivities, Manager_interview_decision, Hr_interview_performance, Manager_interview_performance, Interview_decision, Hr_interview_decision {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Manager_Interview_Candidate_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, manager_interview_decision);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

}

