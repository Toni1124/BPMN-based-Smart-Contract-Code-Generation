module deployer::supply_chain_Contract {
    use std::string;
    use std::bit_vector;
    use std::vector;
    use aptos_std::simple_map;
    use aptos_framework::event;

    struct Order_table has store, copy, drop {
       good_name: string::String,
       quantity: u128,
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

    struct Order_info has key, store {
       _order_info: Order_table,
    }

    struct Approve has key, store {
       _approve: bool,
    }

    struct Pay has key, store {
       _pay: bool,
    }

    struct Workitems has key, store {
       workitems: vector<Workitem>
    }


    #[event]
    struct Event_07dwn0z_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Event_1svc6nt_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Event_1yeq6m2_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Event_0k174q2_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Execution_progress has drop, store {
       msg: string::String, 
    }

    #[event]
    struct Order_goods_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Approve_order_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Pay_for_goods_requested has drop, store {
       index: u128, 
    }



    fun init_module(account: &signer) {
        move_to(account, Workitems {workitems: vector::empty<Workitem>()});
        move_to(account, Marking{marking: 2, });
        move_to(account, Startedactivities{startedActivities: 0, });
        move_to(account, Approve{_approve: true, });
        move_to(account, Pay{_pay: true, });
        move_to(account, Order_info{_order_info: Order_table{good_name: string::utf8(b""), quantity: 0, }, });
    }

    fun Order_Goods_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Order_goods_requested {index: tmp1});
    }

    fun Approve_order_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Approve_order_requested {index: tmp1});
    }

    fun Pay_for_goods_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Pay_for_goods_requested {index: tmp1});
    }

    fun step(tmpMarking: u128, tmpStartedActivities: u128) acquires Workitems, Approve, Pay, Marking, Startedactivities {
        loop {
            if ((2u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0va6hm7")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpMarking;
                Order_Goods_start(1);
                tmpStartedActivities = (2u128) | tmpStartedActivities;
                continue
            };
            if ((4u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_042ok61")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpMarking;
                Approve_order_start(2);
                tmpStartedActivities = (4u128) | tmpStartedActivities;
                continue
            };
            if ((2048u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_07gia3i")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2048u128)) & tmpMarking;
                Pay_for_goods_start(3);
                tmpStartedActivities = (8u128) | tmpStartedActivities;
                continue
            };
            if ((8u128) & tmpMarking == 8u128) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1xvyoq4")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpMarking;
                tmpMarking = (2176u128) | tmpMarking;
                continue
            };
            if ((32u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_07dwn0z")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (32u128)) & tmpMarking;
                event::emit (Event_07dwn0z_message {messageText: string::utf8(b"Order_approved")});
                tmpMarking = (256u128) | tmpMarking;
                continue
            };
            if ((16u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1buqfsf")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16u128)) & tmpMarking;
                if (borrow_global<Approve>(@deployer)._approve == true) {
                    tmpMarking = (32u128) | tmpMarking;
                }
                else {
                    tmpMarking = (64u128) | tmpMarking;
                };
                continue
            };
            if ((128u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_0ma3mbe")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (128u128)) & tmpMarking;
                tmpMarking = (4u128) | tmpMarking;
                continue
            };
            if ((33280u128) & tmpMarking == 33280u128) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1a8afmy")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (33280u128)) & tmpMarking;
                tmpMarking = (1024u128) | tmpMarking;
                continue
            };
            if ((256u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1h6uj8j")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (256u128)) & tmpMarking;
                tmpMarking = (512u128) | tmpMarking;
                continue
            };
            if ((64u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_1svc6nt")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (64u128)) & tmpMarking;
                event::emit (Event_1svc6nt_message {messageText: string::utf8(b"Order_declined")});
                continue
            };
            if ((4096u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1nu9dol")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4096u128)) & tmpMarking;
                if (borrow_global<Pay>(@deployer)._pay == true) {
                    tmpMarking = (16384u128) | tmpMarking;
                }
                else {
                    tmpMarking = (8192u128) | tmpMarking;
                };
                continue
            };
            if ((8192u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_1yeq6m2")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8192u128)) & tmpMarking;
                event::emit (Event_1yeq6m2_message {messageText: string::utf8(b"Order_declined")});
                continue
            };
            if ((16384u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_1hsvm4c")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16384u128)) & tmpMarking;
                tmpMarking = (32768u128) | tmpMarking;
                continue
            };
            if ((1024u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_0k174q2")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (1024u128)) & tmpMarking;
                event::emit (Event_0k174q2_message {messageText: string::utf8(b"Received_goods")});
                continue
            };
            break
        };
        if (borrow_global<Marking>(@deployer).marking != 0 || borrow_global<Startedactivities>(@deployer).startedActivities != 0) {
            borrow_global_mut<Marking>(@deployer).marking = tmpMarking;
            borrow_global_mut<Startedactivities>(@deployer).startedActivities = tmpStartedActivities;
        };
    }

    public fun startExecution() acquires Marking, Startedactivities, Workitems, Approve, Pay {
        assert!(borrow_global<Marking>(@deployer).marking == 2u128 && borrow_global<Startedactivities>(@deployer).startedActivities == 0u128, 0);
        step(2u128, 0);
    }

    fun Order_Goods_complete(elementIndex: u128, order_info: Order_table) acquires Marking, Startedactivities, Order_info, Workitems, Approve, Pay {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 1u128) {
            assert!((2u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Order_info>(@deployer)._order_info = order_info;
            step((8u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpStartedActivities);
            return
        };
    }

    fun Approve_order_complete(elementIndex: u128, approve: bool) acquires Marking, Startedactivities, Approve, Workitems, Pay {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 2u128) {
            assert!((4u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Approve>(@deployer)._approve = approve;
            step((16u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpStartedActivities);
            return
        };
    }

    fun Pay_for_goods_complete(elementIndex: u128, pay: bool) acquires Marking, Startedactivities, Pay, Workitems, Approve {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 3u128) {
            assert!((8u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Pay>(@deployer)._pay = pay;
            step((4096u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpStartedActivities);
            return
        };
    }

    public fun Order_Goods(workitemId: u128, order_info_good_name: string::String, order_info_quantity: u128) acquires Workitems, Marking, Startedactivities, Order_info, Approve, Pay {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Order_Goods_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, Order_table{good_name: order_info_good_name, quantity: order_info_quantity, });
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Approve_order(workitemId: u128, approve: bool) acquires Workitems, Marking, Startedactivities, Approve, Pay {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Approve_order_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, approve);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Pay_for_goods(workitemId: u128, pay: bool) acquires Workitems, Marking, Startedactivities, Pay, Approve {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Pay_for_goods_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, pay);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

}

