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
create DeployFundMe.s.sol file in script folder 
run:
forge script script/DeployFundMe.s.sol 

