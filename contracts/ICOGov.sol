//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./GOVToken.sol";
import "./Vault.sol";

contract ICOGov is ReentrancyGuard {

    GOVToken public newToken;
    Vault public vault;
    address treasury;
    uint256 public tokenPrice;

    constructor(GOVToken _newToken, Vault _vault, address _treasury, uint256 _tokenPricePerToken) {
        newToken = _newToken;
        vault = _vault;
        treasury = _treasury;
        tokenPrice = _tokenPricePerToken; // price / token
    }

    function buyToken(uint256 _vaultTokenAmount) external nonReentrant {
        // Get token value from share
        uint256 value = vault.shareToAmount(_vaultTokenAmount);
        // Get number of token from value
        uint256 tokenAmount = value / tokenPrice;
        vault.transferFrom(msg.sender, treasury, _vaultTokenAmount);
        newToken.mint(msg.sender, tokenAmount);
    }
}