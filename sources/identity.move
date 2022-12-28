module filament::identity {
    use sui::object::{Self, UID};
    use sui::dynamic_field as field;
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    use filament::nft;

    struct Identity has key, store {
        id: UID,
        platform: String,
        size: u64,
    }

    const IDENTITY_KEY: vector<u8> = b"id_";

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

    public entry fun add_identity(identity: &mut Identity, value: vector<u8>, logo: vector<u8>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        assert!(!contains<address>(identity, sender), EIdentityAlreadyExists);

        let value_str = string::utf8(value);
        let key = string::utf8(IDENTITY_KEY);
        string::append(&mut key, value_str);

        add<address, String>(identity, sender, value_str);
        add<String, address>(identity, key, sender);

        let id_nft = nft::create_nft(value_str, logo, identity.platform, ctx);
        transfer::transfer(id_nft, sender);
    }


    fun contains<K: copy + drop + store>(identity: &Identity, key: K): bool {
        field::exists_(&identity.id, key)
    }

    fun add<K: copy + drop + store, V: store>(identity: &mut Identity, key: K, value: V) {
        field::add(&mut identity.id, key, value);
        identity.size = identity.size + 1;
    }
}