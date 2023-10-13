trait IExample<TContractState> {
    fn store_name(ref self: TContractState, _name: felt252);
    fn get_name(self: @TContractState, _address: ContractAddress) -> felt252;
}


#[starknet::contract]
mod exam_verifier {
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        names: LegacyMap::<ContractAddress, felt252>, 
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StoredName: StoredName, 
    }

    #[derive(Drop, starknet::Event)]
    struct StoredName {
        caller: ContractAddress,
        name: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState, _name: felt252, _address: ContractAddress) {
        self.names.write(_address, _name);
    }

    #[external(v0)]
    impl Example of super::IExample<ContractState> {
        fn store_name(ref self: ContractState, _name: felt252) {
            let _caller = get_caller_address();
            self.names.write(_caller, _name);
            self.emit(Event::StoredName(StoredName { caller: _caller, name: _name }));
        }

        fn get_name(self: @ContractState, _address: ContractAddress) -> felt252 {
            let name = self.names.read(_address);
            name
        }
    }
}