pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BPoolsReferral is AccessControl {
  ERC20 public immutable _BUSD = ERC20(0x96e60D5F2aEc16352164f83d004085Ed4079D2aE);

  bytes32 public constant ADMIN = keccak256("ADMIN");
  bytes32 public constant SIGNER = keccak256("SIGNER");

  address public _treasuryAddress;
  uint public _pointAmountPerToken = 1;
  uint public _minSwapPointAmount = 10;
  mapping(address => uint) public nonces;

  // event
  event Claim(address indexed requester, uint pointAmount, uint timestamp);

  // Constructor
  constructor(uint pointAmountPerToken, uint minSwapPointAmount, address signer) {
    _treasuryAddress = msg.sender;
    _pointAmountPerToken = pointAmountPerToken;
    _minSwapPointAmount = minSwapPointAmount;
    _grantRole(ADMIN, msg.sender);
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(SIGNER, signer);
  }

  function setTreasuryAddress(
    address treasuryAddress
  ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
    _treasuryAddress = treasuryAddress;
    return true;
  }

  function setPointAmountPerToken(
    uint pointAmountPerToken
  ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
    _pointAmountPerToken = pointAmountPerToken;
    return true;
  }

  function setMinSwapPointAmount(
    uint minSwapPointAmount
  ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
    _minSwapPointAmount = minSwapPointAmount;
    return true;
  }

  function ClaimReferral(
    uint pointAmount,
    uint blockNumber,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external payable returns (uint) {
    require(pointAmount > 0, "Point amount have to greater than 0 !");
    require(block.number <= blockNumber, "Message is expired !");
    require(verifyMessage(msg.sender, pointAmount, blockNumber, _v, _r, _s), "Invalid token");
    require(
      pointAmount >= _minSwapPointAmount * 1e18,
      "Point amount have to greater than or equal min swap point"
    );

    uint tokenAmount = pointAmount / _pointAmountPerToken;

    _BUSD.transferFrom(_treasuryAddress, msg.sender, tokenAmount);

    emit Claim(msg.sender, pointAmount, block.timestamp);
    return tokenAmount;
  }

  function verifyMessage(
    address user,
    uint amount,
    uint blockNumber,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) internal returns (bool) {
    bytes memory ethPrefix = "\x19Ethereum Signed Message:\n32";

    bytes32 hash = keccak256(abi.encode(user, amount, nonces[user]++, blockNumber));
    bytes32 fullHash = keccak256(abi.encodePacked(ethPrefix, hash));
    address signer = ecrecover(fullHash, _v, _r, _s);

    return hasRole(SIGNER, signer);
  }
}
