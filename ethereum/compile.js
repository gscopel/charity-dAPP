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
                '*': [ '*' ]
            }
        }
    }
}

const output = JSON.parse(solc.compile(JSON.stringify(input)));

if(output.errors) {
    output.errors.forEach(err => {
        console.log(err.formattedMessage);
    });
} else {
    const contracts = output.contracts["Charity.sol"];
    fs.mkdirSync(buildPath);
    for (let contractName in contracts) {
        const contract = contracts[contractName];
        fs.writeFileSync(path.resolve(buildPath, `${contractName}.json`), JSON.stringify(contract.abi, null, 2), 'utf8');
    }
}
