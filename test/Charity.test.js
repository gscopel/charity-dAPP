const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledFactory = require('../ethereum/build/CharityFactory.json');
const compiledCharity = require('../ethereum/build/Charity.json');

let accounts;
let factory;
let charityAddress;
let charity;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  factory = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
    .deploy({ data: compiledFactory.bytecode })
    .send({ from: accounts[0], gas: '1000000' });

  await factory.methods.createCharity('100').send({
    from: accounts[0],
    gas: '1000000'
  });

  [charityAddress] = await factory.methods.getDeployedCharities().call();
    charity = await new web3.eth.Contract(
      JSON.parse(compiledCharity.interface),
      charityAddress
    );
});

describe('Charities', () => {
  it('deploys a factory and a charity', () => {
    assert.ok(factory.options.address);
    assert.ok(charity.options.address);
  });
});
