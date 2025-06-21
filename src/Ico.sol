// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./SpaceCoin.sol";

contract ICO {
    SpaceCoin public immutable spaceCoin;
    address public immutable OWNER;
    address public immutable treasury;
    uint256 public constant GOAL = 30000 ether;

    uint256 public constant SEED_LIMIT = 15000 ether;
    uint256 public constant IND_SEED_LIMIT = 1500 ether;

    uint256 public constant GENERAL_LIMIT = 30000 ether;
    uint256 public constant IND_GENERAL_LIMIT = 1000 ether;

    uint256 public constant OPEN_LIMIT = 30000 ether;
    address public immutable SPC_TOKEN;

    bool public fundRaisingPaused = false;
    bool public redemptionPaused = false;

    mapping(address => bool) allowList;  
    mapping(address => uint256) contributions;
    uint256 public totalRaised;

    enum Phase {
        SEED,
        GENERAL,
        OPEN
    }
    Phase public phase;

    modifier onlyOwner() {
        require(msg.sender == OWNER, "Not an Owner");
        _;
    }

    modifier fundraisingActive() {
        require(!fundRaisingPaused, "Fundraising paused");
        _;
    }

    modifier redemptionActive() {
        require(!redemptionPaused, "Redemption paused");
        _;
    }

    event ContributorAdded(address _ContributorInSeed);
    event TokenRedeemed(address indexed to, uint256 amount);

    constructor(address _treasury) {
        require(_treasury != address(0), "Treasury cannot be zero");
        OWNER = msg.sender;
        treasury = _treasury;
        spaceCoin = new SpaceCoin(_treasury, address(this));
        SPC_TOKEN = address(spaceCoin);
        phase = Phase.SEED;
    }

    function setPauseStatus(
        bool _status
    ) external onlyOwner fundraisingActive redemptionActive {
        fundRaisingPaused = _status;
        redemptionPaused = _status;
    }

    function advancePhase() external onlyOwner {
        require(phase != Phase.OPEN, "Open phase");
        phase = Phase(uint8(phase) + 1);
    }

    function addPrivateContributor(address _contributor) external onlyOwner {
        allowList[_contributor] = true;
        emit ContributorAdded(_contributor);
    }

    function contribute() external payable fundraisingActive {
        uint256 newTotal = totalRaised + msg.value;
        if (phase == Phase.SEED) {
            require(allowList[msg.sender], "Not in allowlist");
            require(
                contributions[msg.sender] + msg.value <= IND_SEED_LIMIT,
                "Individual SEED limit exceeding"
            );
            require(newTotal <= SEED_LIMIT, "SEED limit exceeding");
        }
        if (phase == Phase.GENERAL) {
            require(
                contributions[msg.sender] + msg.value <= IND_GENERAL_LIMIT,
                "Individual GENERAL limit exceeding"
            );
            require(newTotal <= GENERAL_LIMIT, "GENERAL limit exceeding");
        }
        if (phase == Phase.OPEN) {
            require(newTotal <= OPEN_LIMIT, "OPEN limit exceeding");
        }
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
    }

    function redemption() external redemptionActive {
        require(phase == Phase.OPEN, "Phase not OPEN");
        require(
            contributions[msg.sender] > 0,
            "0 contribution"
        );
        uint256 tokenAmount = contributions[msg.sender] * 5;
        bool success = spaceCoin.transfer(msg.sender, tokenAmount);
        require(success, "Failed");
        contributions[msg.sender] = 0;
        emit TokenRedeemed(msg.sender, tokenAmount);
    }
}
