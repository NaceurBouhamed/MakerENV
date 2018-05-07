// Set `boxes[SAI_TUB]` and so on to addresses from the environment.
let boxes = (
  "GEM GOV PIP PEP PIT ADM SAI SIN SKR DAD MOM VOX TUB TAP TOP".split(" ")
).reduce((o, x) => Object.assign(o, { [x] : process.env[`SAI_${x}`] }), {})

// Use the environment's testnet RPC URL
let Web3 = require("web3")
let web3 = new Web3(
  new Web3.providers.HttpProvider(process.env["ETH_RPC_URL"])
)

// How to instantiate ABIs into Web3 contracts (this is for Web3 1.0, oops)
let abi = (box, addr) => new web3.eth.Contract(
  JSON.parse(require("fs").readFileSync(`sai/out/${box}.abi`)),
  addr
)

// Parse some of the Sai system contracts
let sys = {
  tub: abi("SaiTub", boxes.TUB),
  gem: abi("DSToken", boxes.GEM),
  skr: abi("DSToken", boxes.SKR),
  sai: abi("DSToken", boxes.SAI),
}

let assert = require("assert")

// Do stuff using nice await syntax for blocking on promises
async function start () {
  assert.equal(
    await sys.sai.methods.totalSupply().call(),
    0,
    "Initial SAI supply should be zero"
  )
}

start()
process.stdin.resume();