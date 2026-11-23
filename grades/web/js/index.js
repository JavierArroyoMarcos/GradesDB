"use strict";

import { sessionManager } from './utils/session.js';

import { employeesAPI_auto } from '/js/api/_employees.js';
import { departmentsAPI_auto } from '/js/api/_departments.js';

import { employeeRenderer } from '/js/renderers/employees.js';
import { departmentRenderer } from '/js/renderers/departments.js';
import { messageRenderer } from '/js/renderers/messages.js';

// DOM elements that we will use
const employeesCont = document.getElementById("employees");
const departmentsCont = document.getElementById("departments");
const newDpmtButton = document.getElementById("new-dpmt-button");

// Main function that will run when the page is ready
function main() {
    // Hide the options that shouldnt be available for not logged users
    setLoggedOptions();

    // Load the employees
    loadEmployees();
    
    // Load the departments
    loadDepartments();
    
}

document.addEventListener("DOMContentLoaded", function () {
    main();
});

///////////
async function loadEmployees(){
    let employees;
    try{
        employees = await employeesAPI_auto.getAll()
    }catch (e){
        messageRenderer.showErrorAsAlert("Error retrieving employees", e)
    }

    let table = employeeRenderer.asTable(employees);
    employeesCont.appendChild(table);
}

async function loadDepartments(){
    let departments;
    try{
        departments = await departmentsAPI_auto.getAll()
    }catch(e){
        messageRenderer.showErrorAsAlert("Error retrieving departments", e)
    }

    let badgeGroup = departmentRenderer.asBadgeGroup(departments);
    departmentsCont.appendChild(badgeGroup);
}

function setLoggedOptions() {
    // Hide the things that shouldnt be available for non authenticated users
    if (!sessionManager.isLogged()) {
        newDpmtButton.style.display = "none";
    }
}