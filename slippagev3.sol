// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

// Interface for ERC20 tokens (including WETH)
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// Interface for Uniswap Router
interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract UniswapSlippageBot {
    address public owner;
    IUniswapV2Router public uniswapRouter;
    address public wethAddress;

    uint256 public slippageTolerance; // in basis points (e.g., 50 = 0.5%)

    // Address of the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Constructor sets the Uniswap router address and WETH address
    constructor(address _uniswapRouter) public {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router(_uniswapRouter);
        wethAddress = uniswapRouter.WETH();  // Set WETH contract address
        slippageTolerance = 50; // Default 0.5% slippage tolerance
    }

    // Function to set slippage tolerance (in basis points, e.g., 100 = 1%)
    function setSlippageTolerance(uint256 _slippageTolerance) external onlyOwner {
        require(_slippageTolerance <= 1000, "Slippage too high");
        slippageTolerance = _slippageTolerance;
    }

    // Function to check the price of a token relative to ETH using Uniswap
    function getExpectedTokenAmount(uint256 ethAmount, address token) external view returns (uint256) {
        address;
        path[0] = wethAddress; // Start with WETH
        path[1] = token; // Target token

        uint256[] memory amountsOut = uniswapRouter.getAmountsOut(ethAmount, path);
        return amountsOut[1]; // Return the expected token amount
    }

    // Execute trade on Uniswap with slippage control
    function executeTrade(uint256 ethAmount, address tokenToBuy, uint256 deadline) external payable onlyOwner {
        require(msg.value == ethAmount, "Incorrect ETH amount sent");

        address;
        path[0] = wethAddress;
        path[1] = tokenToBuy;

        uint256[] memory amountsOut = uniswapRouter.getAmountsOut(ethAmount, path);
        uint256 minTokens = amountsOut[1] - (amountsOut[1] * slippageTolerance) / 10000;

        // Perform the swap
        uniswapRouter.swapExactETHForTokens{value: ethAmount}(
            minTokens,
            path,
            address(this),
            deadline
        );
    }

    // Function to withdraw tokens
    function withdrawTokens(address token) external onlyOwner {
        IERC20 tokenContract = IERC20(token);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        tokenContract.transfer(owner, balance);
    }

    // Function to withdraw ETH
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner).transfer(balance);
    }

    // Function to receive ETH
    receive() external payable {}
}
