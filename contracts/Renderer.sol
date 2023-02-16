//SPDX-License-Identifier: MIT
pragma solidity >=0.8.16;

import './SVG.sol';
import './Utils.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {IJBProjectHandles} from '@jbx-protocol/project-handles/contracts/interfaces/IJBProjectHandles.sol';
import {IJBSingleTokenPaymentTerminal} from '@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBSingleTokenPaymentTerminal.sol';
import {IJBSingleTokenPaymentTerminalStore} from '@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBSingleTokenPaymentTerminalStore.sol';
import {IJBPaymentTerminal} from '@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBPaymentTerminal.sol';
import {IJBDirectory} from '@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBDirectory.sol';

contract Renderer {
    using Strings for uint256;
    IJBDirectory directory =
        IJBDirectory(0x65572FB928b46f9aDB7cfe5A4c41226F636161ea);
    IJBSingleTokenPaymentTerminalStore terminalStore =
        IJBSingleTokenPaymentTerminalStore(
            0xdF7Ca703225c5da79A86E08E03A206c267B7470C
        );
    IJBSingleTokenPaymentTerminal terminal;
    IJBProjectHandles public projectHandles =
        IJBProjectHandles(0xE3c01E9Fd2a1dCC6edF0b1058B5757138EF9FfB6);

    function render(uint256 _tokenId) public view returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" style="background:#000">',
                svg.text(
                    string.concat(
                        svg.prop('x', '20'),
                        svg.prop('y', '40'),
                        svg.prop('font-size', '22'),
                        svg.prop('fill', 'orange')
                    ),
                    string.concat(svg.cdata(getProjectHandle(_tokenId)))
                ),
                svg.rect(
                    string.concat(
                        svg.prop('fill', 'orange'),
                        svg.prop('x', '20'),
                        svg.prop('y', '50'),
                        svg.prop('width', utils.uint2str(160)),
                        svg.prop('height', utils.uint2str(10))
                    ),
                    utils.NULL
                ),
                svg.text(
                    string.concat(
                        svg.prop('x', '20'),
                        svg.prop('y', '80'),
                        svg.prop('font-size', '22'),
                        svg.prop('fill', 'green')
                    ),
                    string.concat('balance: ', svg.cdata(getJBProjectBalance(_tokenId)))
                ),
                '</svg>'
            );
    }

    function getProjectHandle(uint256 projectId)
        internal
        view
        returns (string memory projectName)
    {
        projectName = projectHandles.handleOf(projectId);
        if (
            keccak256(bytes(string.concat(projectName))) ==
            keccak256(bytes(string.concat('')))
        ) {
            projectName = string.concat('Project #', projectId.toString()); // If no handle is set, return the project id #
        }
        return projectName;
    }

    function getJBProjectBalance(uint256 projectId)
        internal
        view
        returns (string memory balance)
    {
        IJBPaymentTerminal primaryEthPaymentTerminal = directory
            .primaryTerminalOf(
                projectId,
                address(0x000000000000000000000000000000000000EEEe)
            );
        uint256 bal = terminalStore.balanceOf(
            IJBSingleTokenPaymentTerminal(address(primaryEthPaymentTerminal)),
            projectId
        ) / 10**18;
        return bal.toString();
    }

    function example() external view returns (string memory) {
        return render(1);
    }
}
