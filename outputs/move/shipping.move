module deployer::shipping_Contract {
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

    struct Warehouse_available has key, store {
       _warehouse_available: bool,
    }

    struct Customs_passed has key, store {
       _customs_passed: bool,
    }

    struct Workitems has key, store {
       workitems: vector<Workitem>
    }


    #[event]
    struct Event_0os0wzu_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Event_1sooxn7_message has drop, store {
       messageText: string::String, 
    }

    #[event]
    struct Execution_progress has drop, store {
       msg: string::String, 
    }

    #[event]
    struct Activity_17kev5e_message_pack_products has drop, store {
    }

    #[event]
    struct Initiate_shipping_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Prepare_products_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Outgoing_customs_procedures_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Book_for_shipmen_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Check_warehouse_status_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Arrange_deliver_time_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Receiver_received_requested has drop, store {
       index: u128, 
    }



    fun init_module(account: &signer) {
        move_to(account, Workitems {workitems: vector::empty<Workitem>()});
        move_to(account, Marking{marking: 2, });
        move_to(account, Startedactivities{startedActivities: 0, });
        move_to(account, Customs_passed{_customs_passed: false, });
        move_to(account, Warehouse_available{_warehouse_available: false, });
    }

    fun Initiate_shipping_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Initiate_shipping_requested {index: tmp1});
    }

    fun Prepare_products_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Prepare_products_requested {index: tmp1});
    }

    fun Outgoing_customs_procedures_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Outgoing_customs_procedures_requested {index: tmp1});
    }

    fun Book_for_shipmen_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Book_for_shipmen_requested {index: tmp1});
    }

    fun Check_warehouse_status_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Check_warehouse_status_requested {index: tmp1});
    }

    fun Arrange_deliver_time_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Arrange_deliver_time_requested {index: tmp1});
    }

    fun Receiver_received_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Receiver_received_requested {index: tmp1});
    }

    fun step(tmpMarking: u128, tmpStartedActivities: u128) acquires Workitems, Warehouse_available, Customs_passed, Marking, Startedactivities {
        loop {
            if ((2u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0v5c77r")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpMarking;
                Initiate_shipping_start(1);
                tmpStartedActivities = (2u128) | tmpStartedActivities;
                continue
            };
            if ((16u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0t3c564")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16u128)) & tmpMarking;
                Prepare_products_start(2);
                tmpStartedActivities = (4u128) | tmpStartedActivities;
                continue
            };
            if ((8u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_14ye2uu")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpMarking;
                Outgoing_customs_procedures_start(3);
                tmpStartedActivities = (8u128) | tmpStartedActivities;
                continue
            };
            if ((32u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1mdtd7d")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (32u128)) & tmpMarking;
                Book_for_shipmen_start(4);
                tmpStartedActivities = (16u128) | tmpStartedActivities;
                continue
            };
            if ((262144u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_090z4s4")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (262144u128)) & tmpMarking;
                Check_warehouse_status_start(5);
                tmpStartedActivities = (32u128) | tmpStartedActivities;
                continue
            };
            if ((65536u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0trcxgm")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (65536u128)) & tmpMarking;
                Arrange_deliver_time_start(6);
                tmpStartedActivities = (64u128) | tmpStartedActivities;
                continue
            };
            if ((33554432u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0sltmku")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (33554432u128)) & tmpMarking;
                Receiver_received_start(7);
                tmpStartedActivities = (128u128) | tmpStartedActivities;
                continue
            };
            if ((4u128) & tmpMarking == 4u128) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_00gpgwc")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpMarking;
                tmpMarking = (56u128) | tmpMarking;
                continue
            };
            if ((64u128) & tmpMarking == 64u128) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1mhy99q")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (64u128)) & tmpMarking;
                tmpMarking = (196608u128) | tmpMarking;
                continue
            };
            if ((8320u128) & tmpMarking == 8320u128) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_0g0k9va")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8320u128)) & tmpMarking;
                tmpMarking = (16384u128) | tmpMarking;
                continue
            };
            if ((131072u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_15w24qv")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (131072u128)) & tmpMarking;
                tmpMarking = (262144u128) | tmpMarking;
                continue
            };
            if ((256u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_0qctgii")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (256u128)) & tmpMarking;
                if (borrow_global<Warehouse_available>(@deployer)._warehouse_available == true) {
                    tmpMarking = (1024u128) | tmpMarking;
                }
                else {
                    tmpMarking = (512u128) | tmpMarking;
                };
                continue
            };
            if ((512u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0ksu04d")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (512u128)) & tmpMarking;
                tmpMarking = (2048u128) | tmpMarking;
                continue
            };
            if ((3072u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_02byf3s")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (3072u128)) & tmpMarking;
                tmpMarking = (4096u128) | tmpMarking;
                continue
            };
            if ((4096u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_12ox46m")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4096u128)) & tmpMarking;
                tmpMarking = (8192u128) | tmpMarking;
                continue
            };
            if ((16384u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_17kev5e")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16384u128)) & tmpMarking;
                event::emit (Activity_17kev5e_message_pack_products {});
                tmpMarking = (524288u128) | tmpMarking;
                continue
            };
            if ((2129920u128) & tmpMarking == 2129920u128) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_114lea0")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2129920u128)) & tmpMarking;
                tmpMarking = (4194304u128) | tmpMarking;
                continue
            };
            if ((1572864u128) & tmpMarking == 1572864u128) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1mty1l6")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (1572864u128)) & tmpMarking;
                tmpMarking = (2097152u128) | tmpMarking;
                continue
            };
            if ((134217728u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_0os0wzu")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (134217728u128)) & tmpMarking;
                event::emit (Event_0os0wzu_message {messageText: string::utf8(b"Shipment_failed")});
                continue
            };
            if ((4194304u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_1sooxn7")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4194304u128)) & tmpMarking;
                event::emit (Event_1sooxn7_message {messageText: string::utf8(b"Products_on_ship")});
                tmpMarking = (8388608u128) | tmpMarking;
                continue
            };
            if ((8388608u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1qb30d6")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8388608u128)) & tmpMarking;
                tmpMarking = (16777216u128) | tmpMarking;
                continue
            };
            if ((16777216u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_19dokas")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16777216u128)) & tmpMarking;
                tmpMarking = (33554432u128) | tmpMarking;
                continue
            };
            if ((67108864u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_17m30y1")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (67108864u128)) & tmpMarking;
                continue
            };
            if ((268435456u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_0052v9k")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (268435456u128)) & tmpMarking;
                if (borrow_global<Customs_passed>(@deployer)._customs_passed == true) {
                    tmpMarking = (32768u128) | tmpMarking;
                }
                else {
                    tmpMarking = (134217728u128) | tmpMarking;
                };
                continue
            };
            break
        };
        if (borrow_global<Marking>(@deployer).marking != 0 || borrow_global<Startedactivities>(@deployer).startedActivities != 0) {
            borrow_global_mut<Marking>(@deployer).marking = tmpMarking;
            borrow_global_mut<Startedactivities>(@deployer).startedActivities = tmpStartedActivities;
        };
    }

    public fun startExecution() acquires Marking, Startedactivities, Workitems, Warehouse_available, Customs_passed {
        assert!(borrow_global<Marking>(@deployer).marking == 2u128 && borrow_global<Startedactivities>(@deployer).startedActivities == 0u128, 0);
        step(2u128, 0);
    }

    fun Initiate_shipping_complete(elementIndex: u128) acquires Marking, Startedactivities, Workitems, Warehouse_available, Customs_passed {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 1u128) {
            assert!((2u128) & tmpStartedActivities != 0, 0);
            step((4u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpStartedActivities);
            return
        };
    }

    fun Prepare_products_complete(elementIndex: u128) acquires Marking, Startedactivities, Workitems, Warehouse_available, Customs_passed {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 2u128) {
            assert!((4u128) & tmpStartedActivities != 0, 0);
            step((128u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpStartedActivities);
            return
        };
    }

    fun Outgoing_customs_procedures_complete(elementIndex: u128, customs_passed: bool) acquires Marking, Startedactivities, Customs_passed, Workitems, Warehouse_available {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 3u128) {
            assert!((8u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Customs_passed>(@deployer)._customs_passed = customs_passed;
            step((268435456u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpStartedActivities);
            return
        };
    }

    fun Book_for_shipmen_complete(elementIndex: u128) acquires Marking, Startedactivities, Workitems, Warehouse_available, Customs_passed {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 4u128) {
            assert!((16u128) & tmpStartedActivities != 0, 0);
            step((64u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16u128)) & tmpStartedActivities);
            return
        };
    }

    fun Check_warehouse_status_complete(elementIndex: u128, warehouse_available: bool) acquires Marking, Startedactivities, Warehouse_available, Workitems, Customs_passed {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 5u128) {
            assert!((32u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Warehouse_available>(@deployer)._warehouse_available = warehouse_available;
            step((256u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (32u128)) & tmpStartedActivities);
            return
        };
    }

    fun Arrange_deliver_time_complete(elementIndex: u128) acquires Marking, Startedactivities, Workitems, Warehouse_available, Customs_passed {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 6u128) {
            assert!((64u128) & tmpStartedActivities != 0, 0);
            step((1048576u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (64u128)) & tmpStartedActivities);
            return
        };
    }

    fun Receiver_received_complete(elementIndex: u128) acquires Marking, Startedactivities, Workitems, Warehouse_available, Customs_passed {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 7u128) {
            assert!((128u128) & tmpStartedActivities != 0, 0);
            step((67108864u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (128u128)) & tmpStartedActivities);
            return
        };
    }

    public fun Initiate_shipping(workitemId: u128) acquires Workitems, Marking, Startedactivities, Warehouse_available, Customs_passed {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Initiate_shipping_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Prepare_products(workitemId: u128) acquires Workitems, Marking, Startedactivities, Warehouse_available, Customs_passed {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Prepare_products_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Outgoing_customs_procedures(workitemId: u128, customs_passed: bool) acquires Workitems, Marking, Startedactivities, Customs_passed, Warehouse_available {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Outgoing_customs_procedures_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, customs_passed);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Book_for_shipmen(workitemId: u128) acquires Workitems, Marking, Startedactivities, Warehouse_available, Customs_passed {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Book_for_shipmen_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Check_warehouse_status(workitemId: u128, warehouse_available: bool) acquires Workitems, Marking, Startedactivities, Warehouse_available, Customs_passed {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Check_warehouse_status_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, warehouse_available);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Arrange_deliver_time(workitemId: u128) acquires Workitems, Marking, Startedactivities, Warehouse_available, Customs_passed {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Arrange_deliver_time_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Receiver_received(workitemId: u128) acquires Workitems, Marking, Startedactivities, Warehouse_available, Customs_passed {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Receiver_received_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

}

