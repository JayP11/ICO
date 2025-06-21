// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract SpaceCoin is ERC20 {
    uint256 public constant MAX_SUPPLY = 500000 * 1e18;
    address public immutable owner;
    address public immutable treasury;
    bool public isTaxEnabled = false;
    uint256 constant transferTax = 2;

    constructor(
        address _treasury,
        address _icoContract
    ) ERC20("SpaceCoin", "SPC") {
        require(_icoContract != address(0), "_icoContract Zero address");
        require(_treasury != address(0), "_treasury Zero address");

        owner = msg.sender;
        treasury = _treasury;

        uint256 icoAmount = 150000 * 1e18;
        uint256 treasuryAmount = 350_000 * 1e18;
        require(
            icoAmount + treasuryAmount == MAX_SUPPLY,
            "Incorrect Supply Amount"
        );

        _mint(_icoContract, icoAmount);
        _mint(_treasury, treasuryAmount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an Owner");
        _;
    }

    function setTaxEnabled(bool _isTaxEnabled) external onlyOwner {
        isTaxEnabled = _isTaxEnabled;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (isTaxEnabled) {
            uint256 tax = (amount * transferTax) / 100;
            super._transfer(from, treasury, tax);
            amount -= tax;
        }
        super._transfer(from, to, amount);
    }
}
