// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console2} from "forge-std/Script.sol";
import {TodoContract} from "src/TodoContract.sol";

contract DeployToken is Script {
    function run() external returns (TodoContract) {
        vm.startBroadcast();
        TodoContract todoContract = new TodoContract(msg.sender);
        vm.stopBroadcast();

        return todoContract;
    }
}
