const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const charityPath = path.resolve(__dirname, 'contracts', 'Charity.sol');
const source = fs.readFileSync(charityPath, 'utf8');


var input = {
    language: 'Solidity',
    sources: {
        'Charity.sol': {
             content: source
        }
    },
    settings: {
        outputSelection: {
            '*': {
                'Charity.sol': [ 'abi', 'evm.bytecode.opcodes']
            }
        }
    }
}

const output = JSON.parse(solc.compile(JSON.stringify(input))).contracts;
console.log(output);

for (let contract in output) {
		for(let contractName in output[contract]) {
			fs.outputJsonSync(
				path.resolve(buildPath, `${contractName}.json`),
				output[contract][contractName]
			)
		}
	}
