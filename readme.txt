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