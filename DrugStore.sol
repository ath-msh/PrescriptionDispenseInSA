//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/Counters.sol";


contract DrugStore {
    using Counters for Counters.Counter;
    Counters.Counter private _drugsId;

    mapping(uint => Drugs ) public drugs;
    mapping(uint => uint) public drugsQuantity;
    event DrugsAddedEvent( uint256 drugIndex);

    address private _HA;

    struct Drugs {
        string name;
        string description;
        string dosage;
        uint id;
    }


    modifier onlyHA {
        require(_HA == msg.sender , "Only HA");
        _;
    }

    constructor () {
        _HA = msg.sender;
        for (uint i = 0; i < 5; i++) {
            if ( i == 0 ){
                uint _id = _drugsId.current();
                drugs[i] = Drugs({
                name: "Cancer drug",
                description: "Description ",
                dosage: "Twice daily",
                id: _id
            });
             drugsQuantity[i] = 10;
             _drugsId.increment();
            }
            if ( i == 1 ){
                 uint _id = _drugsId.current();
                drugs[i] = Drugs({
                name: "Diabetics drug",
                description: "Description",
                dosage: "Twice daily",
                id: _id
            });
             drugsQuantity[i] = 10;
             _drugsId.increment();
            }
            if ( i == 2 ){
                 uint _id = _drugsId.current();
                drugs[i] = Drugs({
                name: "Polimate drug",
                description: "Description ",
                dosage: "Twice daily",
                id: _id
            });
             drugsQuantity[i] = 10;
             _drugsId.increment();
            }
            if ( i == 3 ){
                 uint _id = _drugsId.current();
                drugs[i] = Drugs({
                name: "Flanning drug",
                description: "Description ",
                dosage: "Twice daily",
                id: _id
            });
             drugsQuantity[i] = 10;
             _drugsId.increment();
            }
            if ( i == 4 ){
                 uint _id = _drugsId.current();
                drugs[i] = Drugs({
                name: "Bonner drug",
                description: "Description ",
                dosage: "Once daily",
                id: _id
            });
             drugsQuantity[i] = 10;
             _drugsId.increment();
            }
        }
    }


    function addDrugs(string memory _drugName, 
                      string memory _description, 
                      string memory _dosage) public onlyHA returns (uint) {
        _drugsId.increment();
        uint _id = _drugsId.current();
        drugs[_id] = Drugs({
            name: _drugName,
            description: _description,
            dosage: _dosage,
            id: _id
        });
        
        emit DrugsAddedEvent(_id);
        return _id;
        
    }

  
    function getDrugs(uint _id) external view returns (Drugs memory) {
        return drugs[_id];
    }

    function increaseDrugsQuantity(uint _id) public onlyHA {
        drugsQuantity[_id] = drugsQuantity[_id] + 1;
    }

    function decreaseDrugsQuantity(uint _id) external {
        drugsQuantity[_id] = drugsQuantity[_id] - 1;
    }

     function viewDrugQuantity(uint _id) external view returns (uint) {
        return drugsQuantity[_id];
    }
}