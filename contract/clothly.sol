// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Clothly {
    // length of clothes on this contract
    uint internal clothesLength = 0;

    //    Address of the cusd token
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address[] public cartAddresses;
    address[] empty;


    //    structure for each Cloth
    struct Cloth {
        address payable owner;
        string name;
        string image;
        string description;
        string collection;
        uint price;
        uint sold;
    }


    //    mapping of an id to a clothe
    mapping (uint => Cloth) internal clothes;


    //    Mapping of the an address to his/her purchase history
    mapping (address => uint[]) internal history;


    //    create a clothe and add to the blockchain
    function writeCloth(
        string memory _name,
        string memory _image,
        string memory _description,
        string memory _collection,
        uint _price
    ) public {
        uint _sold = 0;
        clothes[clothesLength] = Cloth(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _collection,
            _price,
            _sold
        );
        clothesLength++;
    }

    //    fetch a clothe
    function readCloth(uint _index) public view returns (
        address payable,
        string memory,
        string memory,
        string memory,
        string memory,
        uint,
        uint
    ) {
        return (
        clothes[_index].owner,
        clothes[_index].name,
        clothes[_index].image,
        clothes[_index].description,
        clothes[_index].collection,
        clothes[_index].price,
        clothes[_index].sold
        );
    }

    //    buy a clothe and pay the price

    function buyCloth(uint _index) public payable  {
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                clothes[_index].owner,
                clothes[_index].price
            ),
            "Transfer failed."
        );
        clothes[_index].sold++;
        //        save the transaction to the history mapping
        history[msg.sender].push(_index);
    }

    function addCartAddress(address sellerAdd) public returns (address[] memory){
        cartAddresses.push(sellerAdd);
        return (cartAddresses);
    }

    function clearCartAddress() public returns (uint256){
        cartAddresses = empty;
        return (cartAddresses.length);
    }

    function buyCart(uint totalSumPrice) public payable {
        for (uint i = 0; i < cartAddresses.length; i++) {
            payable(cartAddresses[i]).transfer(totalSumPrice);
        }
    }

    function getClothesLength() public view returns (uint) {
        return (clothesLength);
    }


    //    return a history of a user's purchase
    function getPurchaseHistory() public view returns (uint[] memory){

        return history[msg.sender];
    }

    //    return a history of purchases of a different user
    function getUserPurchaseHistory(address _address) public view returns (uint[] memory){

        return history[_address];
    }
}