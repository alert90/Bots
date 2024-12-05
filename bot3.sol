// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
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

contract UniswapSlippageBot {
    address public owner;
    IUniswapV2Router public uniswapRouter;
    uint256 public slippageTolerance; // in basis points, e.g., 50 = 0.5%

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _uniswapRouter) public {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router(_uniswapRouter);
        slippageTolerance = 50; // Default 0.5% tolerance
    }

    // Set slippage tolerance (in basis points, e.g., 100 = 1%)
    function setSlippageTolerance(uint256 _slippageTolerance) external onlyOwner {
        require(_slippageTolerance <= 1000, "Slippage too high"); // Max 10%
        slippageTolerance = _slippageTolerance;
    }

    // Execute a trade with slippage control
    function executeTrade(
        uint256 ethAmount,
        address tokenToBuy,
        uint256 deadline
    ) external payable onlyOwner {
        address;
        path[0] = uniswapRouter.WETH();
        path[1] = tokenToBuy;

        uint256[] memory amountsOut = uniswapRouter.getAmountsOut(ethAmount, path);
        uint256 minTokens = amountsOut[1] - ((amountsOut[1] * slippageTolerance) / 10000);

        // Perform the swap
        uniswapRouter.swapExactETHForTokens{value: ethAmount}(
            minTokens,
            path,
            address(this),
            deadline
        );
    }

    // Withdraw tokens from contract
    function withdrawTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        IERC20(token).transfer(owner, balance);
    }

    // Withdraw ETH from contract
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner).transfer(balance);
    }

    // Allow contract to receive ETH
    receive() external payable {}
}
