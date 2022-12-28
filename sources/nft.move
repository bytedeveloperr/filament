module filament::nft {
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::tx_context::{TxContext};

    use filament::base64;
    friend filament::identity;

    struct Metadata has store {
        platform: String,
        username: String
    }

    struct Nft has key, store {
        id: UID,
        name: String,
        description: String,
        url: String,
        metadata: Metadata
    }

    const URL_HEADER: vector<u8> = b"data:image/svg+xml;base64,";
    const SVG_FIRST_PART: vector<u8> = b"<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='200' height='100'><rect width='200' height='100' fill='#1d1e24' rx='5' ry='5' /><circle r='5' cx='95%' cy='10' fill='white' />";
    const SVG_SECOND_PART: vector<u8> = b"<text font-family='sans-serif' x='50%' y='50%' fill='white' dominant-baseline='middle' text-anchor='middle'>";
    const SVG_THIRD_PART: vector<u8> =b"</text></svg>";

    public(friend) fun create_nft(value: String, logo: vector<u8>, platform: String, ctx: &mut TxContext): Nft {
        let nft_info = value;
        string::append_utf8(&mut nft_info, b"'s identity NFT");


        let svg = string::utf8(SVG_FIRST_PART);
        string::append_utf8(&mut svg, logo);
        string::append_utf8(&mut svg, SVG_SECOND_PART);
        string::append(&mut svg, value);
        string::append_utf8(&mut svg, SVG_THIRD_PART);

        let nft_url = string::utf8(URL_HEADER);
        let encoded_svg = base64::encode(string::bytes(&svg));
        string::append(&mut nft_url, string::utf8(encoded_svg));

        Nft {
            id: object::new(ctx),
            name: nft_info,
            url: nft_url,
            description: nft_info,
            metadata: Metadata {
                platform,
                username: value
            }
        }
    }
}