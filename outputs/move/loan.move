module deployer::loan_Contract {
    use std::string;
    use std::bit_vector;
    use std::vector;
    use aptos_std::simple_map;
    use aptos_framework::event;

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

    struct Fraud_history has key, store {
       _fraud_history: bool,
    }

    struct Credit_score has key, store {
       _credit_score: u128,
    }

    struct Workitems has key, store {
       workitems: vector<Workitem>
    }


    #[event]
    struct Execution_progress has drop, store {
       msg: string::String, 
    }

    #[event]
    struct Activity_1blnahy_message_approve_loan has drop, store {
    }

    #[event]
    struct Activity_1hetxbf_message_deny_loan has drop, store {
    }

    #[event]
    struct Perform_fraud_check_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Get_credit_score_requested has drop, store {
       index: u128, 
    }



    fun init_module(account: &signer) {
        move_to(account, Workitems {workitems: vector::empty<Workitem>()});
        move_to(account, Marking{marking: 2, });
        move_to(account, Startedactivities{startedActivities: 0, });
        move_to(account, Fraud_history{_fraud_history: false, });
        move_to(account, Credit_score{_credit_score: 0, });
    }

    fun Perform_Fraud_Check_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Perform_fraud_check_requested {index: tmp1});
    }

    fun Get_Credit_Score_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Get_credit_score_requested {index: tmp1});
    }

    fun step(tmpMarking: u128, tmpStartedActivities: u128) acquires Workitems, Fraud_history, Credit_score, Marking, Startedactivities {
        loop {
            if ((2u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1ki3swt")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpMarking;
                Perform_Fraud_Check_start(1);
                tmpStartedActivities = (2u128) | tmpStartedActivities;
                continue
            };
            if ((8u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_15ynia4")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpMarking;
                Get_Credit_Score_start(2);
                tmpStartedActivities = (4u128) | tmpStartedActivities;
                continue
            };
            if ((4u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_04z6kpv")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpMarking;
                if (borrow_global<Fraud_history>(@deployer)._fraud_history == false) {
                    tmpMarking = (8u128) | tmpMarking;
                }
                else {
                    tmpMarking = (512u128) | tmpMarking;
                };
                continue
            };
            if ((16u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1gc0mzu")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16u128)) & tmpMarking;
                if (borrow_global<Credit_score>(@deployer)._credit_score >= 90) {
                    tmpMarking = (32u128) | tmpMarking;
                }
                else {
                    tmpMarking = (128u128) | tmpMarking;
                };
                continue
            };
            if ((32u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1blnahy")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (32u128)) & tmpMarking;
                event::emit (Activity_1blnahy_message_approve_loan {});
                tmpMarking = (64u128) | tmpMarking;
                continue
            };
            if ((64u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_06sr5v4")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (64u128)) & tmpMarking;
                continue
            };
            if ((640u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1hetxbf")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (640u128)) & tmpMarking;
                event::emit (Activity_1hetxbf_message_deny_loan {});
                tmpMarking = (256u128) | tmpMarking;
                continue
            };
            if ((256u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_17ki8gw")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (256u128)) & tmpMarking;
                continue
            };
            break
        };
        if (borrow_global<Marking>(@deployer).marking != 0 || borrow_global<Startedactivities>(@deployer).startedActivities != 0) {
            borrow_global_mut<Marking>(@deployer).marking = tmpMarking;
            borrow_global_mut<Startedactivities>(@deployer).startedActivities = tmpStartedActivities;
        };
    }

    public fun startExecution() acquires Marking, Startedactivities, Workitems, Fraud_history, Credit_score {
        assert!(borrow_global<Marking>(@deployer).marking == 2u128 && borrow_global<Startedactivities>(@deployer).startedActivities == 0u128, 0);
        step(2u128, 0);
    }

    fun Perform_Fraud_Check_complete(elementIndex: u128, fraud_history: bool) acquires Marking, Startedactivities, Fraud_history, Workitems, Credit_score {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 1u128) {
            assert!((2u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Fraud_history>(@deployer)._fraud_history = fraud_history;
            step((4u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpStartedActivities);
            return
        };
    }

    fun Get_Credit_Score_complete(elementIndex: u128, credit_score: u128) acquires Marking, Startedactivities, Credit_score, Workitems, Fraud_history {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 2u128) {
            assert!((4u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Credit_score>(@deployer)._credit_score = credit_score;
            step((16u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpStartedActivities);
            return
        };
    }

    public fun Perform_Fraud_Check(workitemId: u128, fraud_history: bool) acquires Workitems, Marking, Startedactivities, Fraud_history, Credit_score {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Perform_Fraud_Check_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, fraud_history);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Get_Credit_Score(workitemId: u128, credit_score: u128) acquires Workitems, Marking, Startedactivities, Credit_score, Fraud_history {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Get_Credit_Score_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, credit_score);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

}

