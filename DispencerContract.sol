//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { DrugStore } from "./DrugStore.sol";

contract DispencerContract {
   using Counters for Counters.Counter;
   Counters.Counter private _drugsId;

   event PrescriptionAdded(bool isAdded);
   
   
   address private _HA;
   
   //external contract declaration

     enum Diseases{
       Diabetics,
       Cancer,
       HeartDisease,
       HighBloodPressure
   }

    struct Prescription{
       DrugStore.Drugs drug;
       Diseases forDisease;
       uint issued;
       bool approval;
   }
  //this holds the mapping of approved doctors
   mapping(address => bool ) public approvedDoctors;
   //this holds the mapping of approved pharmacist
   mapping(address => bool ) public approvedPharmacist;
   //this holds an array of prescriptions for each patient
   mapping(address => Prescription[]) public prescriptions;

    //this is a modifier function meaning only doctors can execute the function
   //it is placed in
   modifier onlyDoctors {
       require(approvedDoctors[msg.sender] == true, "Only doctors");
       _;
   }

    //this is a modifier function meaning only a pharmacist can execute the function
   //it is placed in
   modifier onlyPharmacist {
       require(approvedPharmacist[msg.sender] == true, "Only pharmacist");
       _;
   }
   
   //this is a modifier function meaning only an HA can execute the function
   //it is placed in
   modifier onlyHA {
       require(_HA == msg.sender , "Only HA");
       _;
   }
    //the deployer of the contract is the HA, so he can add doctors and pharmacist to the system
    constructor( ) {
        _HA = msg.sender;
    }


    //this function is used to add doctors to the system and can only be executed by the HA
    function addToAuthorizedDoctors(address doctor) public onlyHA returns (bool) {
        return approvedDoctors[doctor] = true;
    }
    //this function is used to add pharmacist to the system and can only be executed by the HA
    function addToAuthorizedPharmacists(address pharmacist) public onlyHA returns (bool) {
       return approvedPharmacist[pharmacist] = true;
    
    }
   //this function can be used to view a patient drugs
    function viewPatientPrescription(address _patient) public view returns (Prescription[] memory) {
             Prescription [] memory _patientPrescription = prescriptions[_patient];
            return _patientPrescription;
    }

    //this function is used to approve a specific drug for a specific disease
    function approvedPatientPrescription(address _patient ) public onlyHA returns (bool) {
        Prescription[] storage _patientPrescription = prescriptions[_patient];
        for(uint i = 0; i < _patientPrescription.length; i++) {
            Prescription storage _prescription = _patientPrescription[i];
            if(_prescription.approval == false && _prescription.issued == 0) {
                _prescription.approval = true;
                emit PrescriptionAdded(true);
                return true;
            }
        }
        emit PrescriptionAdded(false);
        return false;
    }


   //this function is used to prescribe drugs to a patient
    function prescribeToPatient(DrugStore _drugStore, address _patient, uint _drugId, 
        Diseases forDisease) public onlyDoctors{
       
       //get the drug from the drug store
         DrugStore.Drugs memory _drug = _drugStore.getDrugs(_drugId);
        Prescription memory _newPrescription = Prescription({
            drug: _drug,
            forDisease: forDisease,
            issued: 0,
            approval: false
        });
        prescriptions[_patient].push(_newPrescription);
    }

    function dispenseDrugsToPatient(DrugStore _drugStore,address _patient) public onlyPharmacist returns (bool) {
        Prescription[] storage _patientPrescription = prescriptions[_patient];
        //get the patient prescriptions
        for (uint i=0; i < _patientPrescription.length; i++) {
            Prescription storage _prescription = _patientPrescription[i];
            if(_prescription.approval == true && _prescription.issued == 0) {
                _prescription.issued = 1;
                //get the drug from the drug store
                //check for availability of the drug
                require(_drugStore.viewDrugQuantity(_prescription.drug.id) > 0, "Drug not available");
                DrugStore.Drugs memory _drug = _drugStore.getDrugs(_prescription.drug.id);
                //decrease the quantity of the drug
                _drugStore.decreaseDrugsQuantity(_drug.id);
                return true;
            }
        }
                return false;
    }
        
}