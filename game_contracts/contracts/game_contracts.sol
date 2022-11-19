// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ERC20Token {
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract JuicyGame {
    ERC20Token public BUSD;
    ERC20Token public IGToken;
    ERC20Token public ENTRToken;

    address admin = 0xc84577ac220DC5977186b6B690469F4b75358E4E;
    mapping(address => uint256) public playerTimesDeposited;
    address[] public allPlayers;
    mapping(address => uint256) public depositedBalance;

    constructor() public {
        BUSD = ERC20Token(0xbCe98d116cA02A87a2E6c8EDf9597CEd50f3B0a2);
        IGToken = ERC20Token(0x5f310227dd9a9e65DaEb9d92282E27DD0eFcA02E);
        ENTRToken = ERC20Token(0xBB7DFc1aBbd94d53648e9DF1F7584B898b1D57C2);
    }

    function depositTokens(uint256 amount) public {
        // To be able to call this function, testBUSd needs to be approved as well as the Smart Contract needs to have some ENTR tokens
        uint256 playersUsdcBalance = BUSD.balanceOf(address(msg.sender));
        require(amount > 0);
        //Checking whether the wallet has enough tokens
        require(playersUsdcBalance >= amount * 10**18);

        //BUSD get transferred to the contract, while ENTRToken gets transferred from contract to player
        BUSD.transferFrom(msg.sender, address(this), amount * 10**18);
        ENTRToken.transfer(msg.sender, amount * 10**18);

        // update staking balance
        depositedBalance[msg.sender] =
            depositedBalance[msg.sender] +
            amount *
            10**18;

        // Here the total amount of times a wallet has called the deposit function is tracked
        // And the player is added to the total players list, but only when he plays for his first time
        uint256 result = timesDeposited(msg.sender) + 1;
        playerTimesDeposited[msg.sender] = result;
        if (result == 1) {
            allPlayers.push(msg.sender);
        }
    }

    function withdrawalPlayers(uint256 _amount) public {
        uint256 dexBalance = BUSD.balanceOf(address(this));
        uint256 playersBalance = IGToken.balanceOf(address(msg.sender));

        require(playersBalance >= _amount, "You are trying to scam us!!");
        require(_amount <= dexBalance, "Not enough tokens in the reserve");

        BUSD.transfer(msg.sender, _amount);
        //BUSD is sent back to msg.sender

        // While both the ENTRToken and IGToken get transferred back to its prior addresses
        ENTRToken.transferFrom(msg.sender, address(this), _amount);
        IGToken.transferFrom(msg.sender, admin, _amount);

        depositedBalance[msg.sender] = 0;
    }

    // Function that checks how many times a wallet has played, needed for the tracking functionality
    function timesDeposited(address _address) public view returns (uint256) {
        return playerTimesDeposited[_address];
    }
}
