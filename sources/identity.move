module filament::identity {
    use sui::object::{Self, UID};
    use sui::dynamic_field as field;
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::vector;

    use filament::nft;

    struct Identity has key, store {
        id: UID,
        platform: String,
        size: u64,
    }

    const USERNAME_KEY: vector<u8> = b"uk_";
    const DEFAULT_KEY: vector<u8> = b"dk_";

    const EIdentityAlreadyExists: u64 = 0;

    public entry fun new(platform: vector<u8>, ctx: &mut TxContext) {
        let identity = create_identity(platform, ctx);
        transfer::share_object(identity);
    }

    fun create_identity(platform: vector<u8>, ctx: &mut TxContext): Identity {
        Identity { 
            id: object::new(ctx), 
            platform: string::utf8(platform),
            size: 0,
        }
    }

    public entry fun link_identity(identity: &mut Identity, value: vector<u8>, logo: vector<u8>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        // assert!(!contains<address>(identity, sender), EIdentityAlreadyExists);

    
        let value_str = string::utf8(value);
        let key = string::utf8(USERNAME_KEY);
        string::append(&mut key, value_str);

        
        if(contains<address, vector<String>>(identity, sender)) {
            let usernames = get_mut(identity, sender);
            vector::push_back(usernames, value_str);

            add<address, vector<String>>(identity, sender, *usernames);
        } else {
            let usernames = vector::empty<String>();
            vector::push_back(&mut usernames, value_str);

            add<address, vector<String>>(identity, sender, usernames);
        };

        add<String, address>(identity, key, sender);

        let id_nft = nft::create_nft(value_str, logo, identity.platform, ctx);
        transfer::transfer(id_nft, sender);
    }


    // dynamic object interaction functions

    fun contains<K: copy + drop + store, V: store>(identity: &Identity, key: K): bool {
        field::exists_(&identity.id, key)
    }

    fun add<K: copy + drop + store, V: store>(identity: &mut Identity, key: K, value: V) {
        field::add(&mut identity.id, key, value);
        identity.size = identity.size + 1;
    }

    fun get<K: copy + drop + store, V: store>(identity: &Identity, key: K): &V {
        field::borrow(&identity.id, key)
    }

    fun get_mut<K: copy + drop + store, V: store>(identity: &mut Identity, key: K): &mut V {
        field::borrow_mut(&mut identity.id, key)
    }
}