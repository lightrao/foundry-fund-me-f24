foundry fund me

1.setup
mkdir foundry-fund-me-f24
cd foundry-fund-me-f24
code .
forge init

2.create FundMe.sol, PriceConverter.sol in src folder

3.install dependency without committing the changes to your Git repository
run:
forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit

4.remapping
change foundry.toml file, add line:
remappings = [
    '@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/',
]
then run:
forge build

5.Tests
create and edit ./test/FundMeTest.t.sol file 
run:
forge test 
forge test -vvv # specifies visibility of three logging

6.Debugging Tests I
add:
function testOwnerIsMsgSender() public
to 
FundMeTest.t.sol file 
in 
FundMeTest contract 

7.Advanced Deploy Scripts I
create and edit DeployFundMe.s.sol file in script folder 
run:
forge script script/DeployFundMe.s.sol 

8.Forked Tests
add function testPriceFeedVersionIsAccurate() public to FundMeTest contract
run:
forge test --match-test testPriceFeedVersionIsAccurate -vvv
meet problem:
Running 1 test for test/FundMeTest.t.sol:FundMeTest
[FAIL. Reason: EvmError: Revert] testPriceFeedVersionIsAccurate() (gas: 10157)
Traces:
  [10157] FundMeTest::testPriceFeedVersionIsAccurate()
    ├─ [5121] FundMe::getVersion() [staticcall]
    │   ├─ [0] 0x694AA1769357215DE4FAC081bf1f309aDC325306::version() [staticcall]
    │   │   └─ ← ()
    │   └─ ← EvmError: Revert
    └─ ← EvmError: Revert

reason:
we are calling a contract address that do not exist,
when we run forge test without rpc-url, it's going to spin up a new blank Anvil Chain,
and run our test.

what can we do to work out with addresses outside our system?
Unit: testing a specific part of our system 
Integration: testing how our code works with other part of our code 
Forked: test our code on a simulated real environment
Staging: test our code in a real environment that is not prod 

one we we can do is: 
create and edit .env file 
we will spin up Anvil, but it'll simulate all transactions as if they're running on the sepolia chain, by running:
source .env 
echo $SEPOLIA_RPC_URL
# `--fork-url $SEPOLIA_RPC_URL` using a local fork of the Sepolia testnet to simulate a real Ethereum blockchain environment.
# `-vvvvv` is another option that sets the verbosity level of the output. The more vs, the more detailed the output will be. 
forge test --match-test testPriceFeedVersionIsAccurate -vvvvv --fork-url $SEPOLIA_RPC_URL
forge coverage --fork-url $SEPOLIA_RPC_URL

9.Refactoring I: Testing Deploy Scripts
refactor FundMe.sol, PriceConverter.sol, DeployFundMe.s.sol, FundMeTest.t.sol four files. 
make them modular deployments and modular testing.
run:
source .env 
forge test -vvvvv --fork-url $SEPOLIA_RPC_URL
forge test --match-test testOwnerIsMsgSender -vvvvv --fork-url $SEPOLIA_RPC_URL


10.Refactoring II: Helper Config
we want to be able to do everything locally for as long as possible, and want to test on different chains.
create and edit HelperConfig.s.sol file.
edit DeployFundMe.s.sol file so we are not hardcode address.
run:
forge test --fork-url $SEPOLIA_RPC_URL

edit .env file add MAINNET_RPC_URL from alchemy and run:
source .env 
forge test --fork-url $MAINNET_RPC_URL

11.Refactoring III: Mocking
create ./test/mocks/MockV3Aggregator.sol file.
deal with Anvil config in HelperConfig.s.sol file.
run:
source .env 
forge test -vvvvv --fork-url $SEPOLIA_RPC_URL
forge test -vvvvv --fork-url $MAINNET_RPC_URL
forge test -vvvvv

we can see contract calling chain:
FundMeTest -> DeployFundMe -> HelperConfig -> MockV3Aggregator

12.More Cheatcodes
run: forge coverage
now coverage percentile is low, so we need to add more test.
edit FundMeTest and run: 
forge test --match-test testFundFailsWithoutEnoughETH
add some test and run:
forge test --match-test testFundUpdatesFundedDataStructure
forge coverage

13.More Coverage
add test code to FundMeTest.
run:
forge test --match-test testAddsFunderToArrayOfFunders
forge test --match-test testOnlyOwnerCanWithdraw
forge test --match-test testWithdrawWithASingleFunder
forge test --match-test testWithdrawFromMultipleFunders
forge coverage 

14.Chisel
run: chisel
open Chisel an advanced Solidity REPL shipped with Foundry.
experiment chisel run:
➜ !help 
➜ uint256 cat = 1;
➜ cat
Type: uint256
├ Hex: 0x0000000000000000000000000000000000000000000000000000000000000001
├ Hex (full word): 0x0000000000000000000000000000000000000000000000000000000000000001
└ Decimal: 1
➜ uint256 catAndThree = cat + 3;
➜ catAndThree
Type: uint256
├ Hex: 0x0000000000000000000000000000000000000000000000000000000000000004
├ Hex (full word): 0x0000000000000000000000000000000000000000000000000000000000000004
└ Decimal: 4
ctrl + c quit REPL 

15. Gas: Cheaper Withdraw
view etherscan:
Transaction Fee == Gas Usage by Txn * Gas Price
Gas Price == Base Gas Fee + Max Priority Gas Fee
Burnt Fee == Base Gas Fee * Gas Usage by Txn
Txn Savings Fee == (Max Gas Fee - Gas Price) * Gas Usage by Txn

how do we know how much gas will spend to call a function?
run:
forge snapshot --match-test testWithdrawFromMultipleFunders
will create .gas-snapshot file and you can check it. 
edit FundMeTest set gas price, for anvil gas price defaults to zero.
run:
forge test --match-test testWithdrawWithASingleFunder -vvv

16.Storage
storage variables (global variables, state variables) take up spot in storgae.
global number just take up a slot in storage, but global array and mapping need several sequential slots in storage 
and should use hash function to map slots which store datas.
constant and immutable variables do not take up storage slot, they are part of the bytecode of the contract.
variables inside of function only exist the duration of the function, they add in memory but not storage, they are not persist or permanent.
array and mapping need `memory` keyword to illustrate whether it in storage or memory location.
string is dynamically sized array, so it need `memory` key word describe whether it in memory or storage location.

add FunWithStorage.sol and DeployStorageFun.s.sol to the project.
run:
anvil 
forge script script/DeployStorageFun.s.sol --rpc-url <anvil's rpc url> --private-key <anvil's account private key> --broadcast
or run:
forge inspect FunWithStorage storageLayout

we can check FundMe contract storage.
run:
forge inspect FundMe storageLayout
or open different terminal run:
anvil 
forge script script/DeployFundMe.s.sol --rpc-url <anvil's rpc url> --private-key <anvil's account private key> --broadcast
cast storage <contract address> <storage slot index>
or connet to ethersan, just run:
cast storage <contract address>

17.Gas: Cheaper Withdraw (continued)


