// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

////////////////////////////////////////////////////
// AUTOGENERATED - DO NOT EDIT THIS FILE DIRECTLY //
////////////////////////////////////////////////////

import "forge-std/Script.sol";

import "contracts/consensus/zkEVM/PolygonZkEVMEtrog.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "@openzeppelin/contracts5/proxy/transparent/TransparentUpgradeableProxy.sol";

abstract contract PolygonZkEVMEtrogDeployer is Script {
    PolygonZkEVMEtrog internal polygonZkEVMEtrog;
    ProxyAdmin internal polygonZkEVMEtrogProxyAdmin;
    address internal polygonZkEVMEtrogImplementation;

    function deployPolygonZkEVMEtrogTransparent(
        address proxyAdminOwner,
        IPolygonZkEVMGlobalExitRootV2 _globalExitRootManager,
        IERC20Upgradeable _pol,
        IPolygonZkEVMBridgeV2 _bridgeAddress,
        PolygonRollupManager _rollupManager,
        address _admin,
        address sequencer,
        uint32 networkID,
        address _gasTokenAddress,
        string memory sequencerURL,
        string memory _networkName
    )
        internal
        returns (address implementation, address proxyAdmin, address proxy)
    {
        bytes memory initData = abi.encodeWithSignature(
            "initialize(address,address,uint32,address,string,string)",
            _admin,
            sequencer,
            networkID,
            _gasTokenAddress,
            sequencerURL,
            _networkName
        );

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        polygonZkEVMEtrogImplementation = address(
            new PolygonZkEVMEtrog(
                _globalExitRootManager,
                _pol,
                _bridgeAddress,
                _rollupManager
            )
        );
        vm.stopBroadcast();

        // two step deployment as rollupManager is required for initialization
        vm.startBroadcast(address(_rollupManager));
        polygonZkEVMEtrog = PolygonZkEVMEtrog(
            address(
                new TransparentUpgradeableProxy(
                    polygonZkEVMEtrogImplementation,
                    proxyAdminOwner,
                    initData
                )
            )
        );
        vm.stopBroadcast();

        polygonZkEVMEtrogProxyAdmin = ProxyAdmin(
            address(
                uint160(
                    uint256(
                        vm.load(
                            address(polygonZkEVMEtrog),
                            hex"b53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103"
                        )
                    )
                )
            )
        );

        return (
            polygonZkEVMEtrogImplementation,
            address(polygonZkEVMEtrogProxyAdmin),
            address(polygonZkEVMEtrog)
        );
    }

    function deployPolygonZkEVMEtrogImplementation(
        IPolygonZkEVMGlobalExitRootV2 _globalExitRootManager,
        IERC20Upgradeable _pol,
        IPolygonZkEVMBridgeV2 _bridgeAddress,
        PolygonRollupManager _rollupManager
    ) internal returns (address implementation) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        implementation = address(
            new PolygonZkEVMEtrog(
                _globalExitRootManager,
                _pol,
                _bridgeAddress,
                _rollupManager
            )
        );
        vm.stopBroadcast();
    }
}
