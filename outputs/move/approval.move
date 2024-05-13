module deployer::approval_Contract {
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

    struct Book_name has key, store {
       _book_name: string::String,
    }

    struct Book_available has key, store {
       _book_available: bool,
    }

    struct Workitems has key, store {
       workitems: vector<Workitem>
    }


    #[event]
    struct Execution_progress has drop, store {
       msg: string::String, 
    }

    #[event]
    struct Borrow_book_request_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Get_book_status_requested has drop, store {
       index: u128, 
    }

    #[event]
    struct Checkout_book_requested has drop, store {
       index: u128, 
    }



    fun init_module(account: &signer) {
        move_to(account, Workitems {workitems: vector::empty<Workitem>()});
        move_to(account, Marking{marking: 2, });
        move_to(account, Startedactivities{startedActivities: 0, });
        move_to(account, Book_available{_book_available: false, });
        move_to(account, Book_name{_book_name: string::utf8(b""), });
    }

    fun Borrow_book_request_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Borrow_book_request_requested {index: tmp1});
    }

    fun Get_book_status_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Get_book_status_requested {index: tmp1});
    }

    fun Checkout_book_start(elementIndex: u128) acquires Workitems {
        vector::push_back<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, Workitem{elementIndex: elementIndex, operated: false, });
        let tmp0: u128 = (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128);
        let tmp1: u128 = tmp0 - 1;
        event::emit (Checkout_book_requested {index: tmp1});
    }

    fun step(tmpMarking: u128, tmpStartedActivities: u128) acquires Workitems, Book_available, Marking, Startedactivities {
        loop {
            if ((2u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_0e4azt8")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpMarking;
                Borrow_book_request_start(1);
                tmpStartedActivities = (2u128) | tmpStartedActivities;
                continue
            };
            if ((4u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_007jrsk")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpMarking;
                Get_book_status_start(2);
                tmpStartedActivities = (4u128) | tmpStartedActivities;
                continue
            };
            if ((32u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Activity_1fcs2xe")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (32u128)) & tmpMarking;
                Checkout_book_start(3);
                tmpStartedActivities = (8u128) | tmpStartedActivities;
                continue
            };
            if ((8u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Gateway_1935g2m")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpMarking;
                if (borrow_global<Book_available>(@deployer)._book_available == false) {
                    tmpMarking = (16u128) | tmpMarking;
                };
                if (borrow_global<Book_available>(@deployer)._book_available == true) {
                    tmpMarking = (32u128) | tmpMarking;
                };
                continue
            };
            if ((16u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_0mipy6r")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (16u128)) & tmpMarking;
                continue
            };
            if ((64u128) & tmpMarking != 0) {
                event::emit (Execution_progress {msg: string::utf8(b"Event_1mve6j7")});
                tmpMarking = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (64u128)) & tmpMarking;
                continue
            };
            break
        };
        if (borrow_global<Marking>(@deployer).marking != 0 || borrow_global<Startedactivities>(@deployer).startedActivities != 0) {
            borrow_global_mut<Marking>(@deployer).marking = tmpMarking;
            borrow_global_mut<Startedactivities>(@deployer).startedActivities = tmpStartedActivities;
        };
    }

    public fun startExecution() acquires Marking, Startedactivities, Workitems, Book_available {
        assert!(borrow_global<Marking>(@deployer).marking == 2u128 && borrow_global<Startedactivities>(@deployer).startedActivities == 0u128, 0);
        step(2u128, 0);
    }

    fun Borrow_book_request_complete(elementIndex: u128, book_name: string::String) acquires Marking, Startedactivities, Book_name, Workitems, Book_available {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 1u128) {
            assert!((2u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Book_name>(@deployer)._book_name = book_name;
            step((4u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (2u128)) & tmpStartedActivities);
            return
        };
    }

    fun Get_book_status_complete(elementIndex: u128, book_available: bool) acquires Marking, Startedactivities, Book_available, Workitems {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 2u128) {
            assert!((4u128) & tmpStartedActivities != 0, 0);
            borrow_global_mut<Book_available>(@deployer)._book_available = book_available;
            step((8u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (4u128)) & tmpStartedActivities);
            return
        };
    }

    fun Checkout_book_complete(elementIndex: u128) acquires Marking, Startedactivities, Workitems, Book_available {
        let tmpMarking: u128 = borrow_global<Marking>(@deployer).marking;
        let tmpStartedActivities: u128 = borrow_global<Startedactivities>(@deployer).startedActivities;
        if (elementIndex == 3u128) {
            assert!((8u128) & tmpStartedActivities != 0, 0);
            step((64u128) | tmpMarking, (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFu128 ^ (8u128)) & tmpStartedActivities);
            return
        };
    }

    public fun Borrow_book_request(workitemId: u128, book_name: string::String) acquires Workitems, Marking, Startedactivities, Book_name, Book_available {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Borrow_book_request_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, book_name);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Get_book_status(workitemId: u128, book_available: bool) acquires Workitems, Marking, Startedactivities, Book_available {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Get_book_status_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex, book_available);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

    public fun Checkout_book(workitemId: u128) acquires Workitems, Marking, Startedactivities, Book_available {
        assert!(workitemId < (vector::length<Workitem>(&borrow_global<Workitems>(@deployer).workitems) as u128) && vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).operated != true, 0);
        Checkout_book_complete(vector::borrow<Workitem>(&borrow_global<Workitems>(@deployer).workitems, (workitemId as u64)).elementIndex);
        vector::borrow_mut<Workitem>(&mut borrow_global_mut<Workitems>(@deployer).workitems, (workitemId as u64)).operated = true;
    }

}

