module.exports = {
  networks: {
    local_etherium: {
      network_id: "*",
      port: 6969,
      host: "127.0.0.1"
    }
  },
  mocha: {},
  compilers: {
    solc: {
      version: "0.8.17"
    }
  }
};
