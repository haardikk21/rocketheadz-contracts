import { constants } from "ethers";

export const PROVENANCE_HASH = "";
export const MERKLE_ROOT = constants.HashZero;

export const FX_PORTAL = {
  mainnet: {
    checkpointManager: "0x86e4dc95c7fbdbf52e33d563bbdb00823894c287",
    fxRoot: "0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2",
  },
  goerli: {
    checkpointManager: "0x2890bA17EfE978480615e330ecB65333b880928e",
    fxRoot: "0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA",
  },
  mumbai: {
    fxChild: "0xCf73231F28B7331BBe3124B907840A94851f9f11",
  },
  matic: {
    fxChild: "0x8397259c983751DAf40400790063935a11afa28a",
  },
};
