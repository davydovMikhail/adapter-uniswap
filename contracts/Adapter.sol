//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Adapter {
    using SafeERC20 for IERC20;

    address router;
    address public WETH;

    constructor(address _router, address _WETH) {
        router = _router;
        WETH = _WETH;
    }

    function addLiquidityOrCreate(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        IERC20(_tokenA).safeTransferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).safeTransferFrom(msg.sender, address(this), _amountB);
        IERC20(_tokenA).safeApprove(router, _amountA);
        IERC20(_tokenB).safeApprove(router, _amountB);
        (amountA, amountB, liquidity) = IUniswapV2Router02(router).addLiquidity(
            _tokenA,
            _tokenB,
            _amountA,
            _amountB,
            (_amountA * 9) / 10,
            (_amountB * 9) / 10,
            msg.sender,
            block.timestamp + 30
        );
    }

    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        address _lpToken,
        uint256 _liquidity,
        uint256 _amountA,
        uint256 _amountB
    ) external returns (uint256 amountA, uint256 amountB) {
        IERC20(_lpToken).safeTransferFrom(msg.sender, address(this), _liquidity);
        IERC20(_lpToken).safeApprove(router, _liquidity);
        (amountA, amountB) = IUniswapV2Router02(router).removeLiquidity(
            _tokenA,
            _tokenB,
            _liquidity,
            _amountA,
            _amountB,
            msg.sender,
            block.timestamp + 30
        );
    }

    function getPriceForAmount(uint256 _amountIn, address[] memory _path)
        external
        view
        returns (uint256[] memory amounts)
    {
        amounts = IUniswapV2Router02(router).getAmountsOut(_amountIn, _path);
    }

    function exhangesTokens(uint256 _in, uint256 _minOut, address[] calldata _path) external returns (uint[] memory amounts) {
        IERC20(_path[0]).safeTransferFrom(msg.sender, address(this), _in);
        IERC20(_path[0]).safeApprove(router, _in);
        amounts = IUniswapV2Router02(router).swapExactTokensForTokens(
            _in,
            _minOut,
            _path,
            msg.sender,
            block.timestamp + 30
        );
    }
}
