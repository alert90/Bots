// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Router {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);
}

contract SnipingBot {
    address public owner;
    IUniswapV2Router public uniswapRouter;
    address public tokenToSnipe;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _uniswapRouter, address _tokenToSnipe) public {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router(_uniswapRouter);
        tokenToSnipe = _tokenToSnipe;
    }

    // Function to execute a trade if conditions are met
    function executeSnipe(uint256 ethAmount, uint256 minTokenAmount) external payable onlyOwner {
        address;
        path[0] = uniswapRouter.WETH();
        path[1] = tokenToSnipe;

        // Swap ETH for tokens
        uniswapRouter.swapExactETHForTokens{value: ethAmount}(
            minTokenAmount,
            path,
            address(this),
            block.timestamp + 300
        );
    }

    // Check price of token
    function checkPrice(uint256 ethAmount) external view returns (uint256) {
        address;
        path[0] = uniswapRouter.WETH();
        path[1] = tokenToSnipe;

        uint[] memory amounts = uniswapRouter.getAmountsOut(ethAmount, path);
        return amounts[1];
    }

    // Withdraw tokens or ETH
    function withdraw(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner, balance), "Transfer failed");
    }

    function withdrawETH() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    // Allow contract to receive ETH
    receive() external payable {}
}
