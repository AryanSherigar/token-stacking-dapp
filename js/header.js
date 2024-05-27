const _NETWORK_ID = 80001;
let SELECT_CONTRACT ={};

SELECT_CONTRACT[_NETWORK_ID] = {
    network_name: "Polygon Mumbai",
    explorer_url: "https://mumbai.polygonscan.com/",
    STACKING: {

        sevenDays: {
            address: "0x51168d2D1B935932959Bd7617892a5C1DB7Fb0AA"
        },
        tenDays: {
            address: ""
        },
        thirtyTwoDays: {
            address: ""
        }, 
        ninetyDays: {
            address: ""
        },
        abi: [],
    },

    TOKEN: {
        symbol: "MTK",
        address: "",
        abi: []
    },
};

/* countdown global*/
let countDownGlobal;

/* wallet connection */

let web3;

let oContractToken;

let contractCall = "sevenDays";

let currentAddress;

let web3Main = new Web3("https://rpc.ankr.com/polygon_mumbai");

// Create an instance of Notyf
var notyf = new Notyf({
    duration: 3000,
    position: { x : "right", y: "bottom"}
});