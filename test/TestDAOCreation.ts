// Framework
import { ethers } from "hardhat";

// Tests
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

// Utils

// Types

// Other
import { deployAragonDAO } from "../deployments/deploy_AragonDAO";

describe("DAO contract", function () {
  it("DAO deploy", async function () {
    const DAO = await loadFixture(deployAragonDAO);
    expect(await DAO.daoURI()).to.be.equal("https://plopmenz.com");

    // var DAOFactoryWrapperContract = await ethers.getContractFactory("DAOFactoryWrapper");
    // var DAOFactoryWrapper = await DAOFactoryWrapperContract.deploy(DAOFactory.address);

    // var testDAO = await DAOFactoryWrapper.createDao(DAOSettings, [PluginSettings]);
    // console.log(testDAO);
    // var receipt  = await testDAO.wait();
    // console.log(receipt);

    // var Action = {
    //     to: "", //address
    //     value: "", //uint256
    //     data: "" //bytes
    // };

    // var PartialVote = {
    //     option: 0, //None, Abstain, Yes, No
    //     amount: 0 //uint
    // };

    // var proposalData = {
    //     _metadata: toBytes("Insert metadata"), //bytes
    //     _actions: [], //IDAO.Action[]
    //     _allowFailureMap: 0, //uint256
    //     _startDate: 0, //uint64
    //     _endDate: 0, //uint64
    //     _voteData: PartialVote, //PartialVote
    //     _tryEarlyExecution: true //bool
    // }
    // var proposalTx = testDAO.createProposal(proposalData._metadata, proposalData._actions, proposalData._allowFailureMap, proposalData._startDate, 
    //     proposalData._endDate, proposalData._voteData, proposalData._tryEarlyExecution);
    // var rc = await proposalTx;
    // console.log(rc);
  });
});