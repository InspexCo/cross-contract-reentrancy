//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IRouter {
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract Vault is ERC20, ReentrancyGuard {
    using SafeERC20 for ERC20;

    ERC20 public baseToken;
    IRouter public router;

    constructor(ERC20 _baseToken, IRouter _router) ERC20("VaultToken", "VT") public {
        baseToken = _baseToken;
        router = _router;
    }

    function shareToAmount(uint256 _share) view public returns (uint256) {
        return _share * baseToken.balanceOf(address(this)) / totalSupply();
    }

    function amountToShare(uint256 _amount) view public returns (uint256) {
        return  _amount * totalSupply() / baseToken.balanceOf(address(this));
    }

    // Deposit tokens into the vault and get shares ($VT)
    function deposit(uint256 _amount) external nonReentrant {
        uint256 total = baseToken.balanceOf(address(this));
        uint256 share = total == 0 ? _amount : amountToShare(_amount);
        _mint(msg.sender, share);
        baseToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    // Deposit any token and swap it to the base token for depositing to vault
    function swapAndDeposit(uint256 _amount, ERC20 _srcToken, uint256 amountOutMin) external nonReentrant {
        uint256 beforeTransfer = baseToken.balanceOf(address(this));
        _srcToken.safeTransferFrom(msg.sender, address(this), _amount);
        address[] memory path = new address[](2);
        path[0] = address(_srcToken);
        path[1] = address(baseToken);
        // Approve token for swapping
        _srcToken.approve(address(router), _amount);
        router.swapExactTokensForTokens(_amount, amountOutMin, path, address(this), block.timestamp);
        // Reset token approval
        _srcToken.approve(address(router), 0);
        uint256 baseTokenAmount = baseToken.balanceOf(address(this)) - beforeTransfer;
        uint256 share =  baseTokenAmount * totalSupply() / beforeTransfer;
        _mint(msg.sender, share);
    }

    // Withdraw tokens from the vault by burning shares ($VT)
    function withdraw(uint256 _share) external nonReentrant {
        uint256 amount = shareToAmount(_share);
        _burn(msg.sender, _share);
        baseToken.safeTransfer(msg.sender, amount);
    }

    // Withdraw tokens from the vault by burning shares ($VT) and swap to any token
    function withdrawAndSwap(uint256 _share, ERC20 _destToken, uint256 amountOutMin) external nonReentrant {
        uint256 amount = shareToAmount(_share);
        address[] memory path = new address[](2);
        path[0] = address(baseToken);
        path[1] = address(_destToken);
        // Approve token for swapping
        baseToken.approve(address(router), amount);
        router.swapExactTokensForTokens(amount, amountOutMin, path, address(msg.sender), block.timestamp);
        // Reset token approval
        baseToken.approve(address(router), 0);
        _burn(msg.sender, _share);
    }

    // Send money somewhere to gain profit
    function work() external nonReentrant {}

    // Harvest profit and swap to baseToken
    function harvest() external nonReentrant {}
}