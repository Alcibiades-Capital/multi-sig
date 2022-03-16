// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {Multicall} from './utils/Multicall.sol';

import {IClub} from './interfaces/IClub.sol';

import {KaliClubSig} from './KaliClubSig.sol';
import {ClubLoot} from './ClubLoot.sol';

import {ClonesWithImmutableArgs} from './libraries/ClonesWithImmutableArgs.sol';

/// @notice Kali ClubSig Contract Factory
contract KaliClubSigFactory is Multicall, IClub {
    /// -----------------------------------------------------------------------
    /// Library Usage
    /// -----------------------------------------------------------------------

    using ClonesWithImmutableArgs for address;

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event SigDeployed(
        ClubSig indexed clubSig,
        ClubLoot indexed loot,
        Club[] club_,
        uint256 quorum,
        uint256 redemptionStart,
        bytes32 name,
        bytes32 symbol,
        bool lootPaused,
        bool signerPaused,
        string baseURI,
        string docs
    );

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error NullDeploy();

    /// -----------------------------------------------------------------------
    /// Immutable Parameters
    /// -----------------------------------------------------------------------
  
    KaliClubSig internal immutable clubMaster;
    ClubLoot internal immutable lootMaster;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(KaliClubSig clubMaster_, ClubLoot lootMaster_) {
        clubMaster = clubMaster_;
        lootMaster = lootMaster_;
    }

    /// -----------------------------------------------------------------------
    /// Deployment
    /// -----------------------------------------------------------------------
    
    function deployClubSig(
        Club[] calldata club_,
        uint256 quorum_,
        uint256 redemptionStart_,
        bytes32 name_,
        bytes32 symbol_,
        bool lootPaused_,
        bool signerPaused_,
        string memory baseURI_,
        string memory docs_
    ) external payable returns (KaliClubSig clubSig, ClubLoot loot) {
        KaliClubSig = ClubSig(address(clubMaster).clone(abi.encodePacked(name_, symbol_)));

        loot = ClubLoot(address(lootMaster).clone(abi.encodePacked(name_, symbol_)));
        
        clubSig.init{value: msg.value}(
            address(loot),
            club_,
            quorum_,
            redemptionStart_,
            signerPaused_,
            baseURI_,
            docs_
        );
        
        loot.init(
            club_,
            lootPaused_,
            address(clubSig)
        );
        
        emit SigDeployed(clubSig, loot, club_, quorum_, redemptionStart_, name_, symbol_, lootPaused_, signerPaused_, baseURI_, docs_);
    }
}