//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/Counters.sol";
import { DrugStore } from "./DrugStore.sol";


//this contract is a factory contract that will be used to create the drug store
//the created drugstore will be saved in the blockchain

contract DrugStoreFactory {
    using Counters for Counters.Counter;
    Counters.Counter private _storeId;
    event DrugStoreCreated(address indexed storeAddress);
    event DrugsAddedEvent( DrugStore indexed drugStore);

    mapping(uint => address ) public drugStoreUintToAddress;
    address[] public deployedDrugStoreAddress;
    uint256 public lastDrugIndex;

    address private _HA;

    constructor() {
        _HA = msg.sender;
    }

    modifier onlyHA {
        require(_HA == msg.sender , "Only HA");
        _;
    }


    function createDrugStore() public onlyHA returns (address) {
        _storeId.increment();
        address _newDrugStoreAddress = address (new DrugStore());
        deployedDrugStoreAddress.push(_newDrugStoreAddress);
        drugStoreUintToAddress[_storeId.current()] = _newDrugStoreAddress;
        emit DrugStoreCreated(_newDrugStoreAddress);
        return _newDrugStoreAddress;
    }

  


    function getDrugStoreDetails( DrugStore _drugStoreAddress, uint _drugID ) 
       public view returns ( DrugStore.Drugs memory ) {
        return _drugStoreAddress.getDrugs(_drugID);
    }

     function addDrugs(DrugStore _drugStore ,string memory _drugName, 
                      string memory _description, 
                      string memory _dosage) public onlyHA returns  (uint) {
        uint _drugID = _drugStore.addDrugs(_drugName, _description, _dosage);
        lastDrugIndex = _drugID;
        emit DrugsAddedEvent(_drugStore);
        return lastDrugIndex;
    }



    function getDrugs(DrugStore _drugStore, uint _id) external view returns (DrugStore.Drugs memory) {
        return _drugStore.getDrugs(_id);
    }

   function increaseDrugsQuantity(DrugStore _drugStore,uint _id) public onlyHA {
       _drugStore.increaseDrugsQuantity(_id);
    }

   function decreaseDrugsQuantity(DrugStore _drugStore,uint _id) external {
        _drugStore.decreaseDrugsQuantity(_id);
   }

    function viewDrugQuantity(DrugStore _drugStore, uint _id) external view returns (uint) {
       uint drugQuantity = _drugStore.viewDrugQuantity(_id);
       return drugQuantity;
    }

    
}