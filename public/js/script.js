
// const containerDiv = document.querySelector('.main-container');

// if (window.location.href.includes('register')) {
//     containerDiv.innerHTML =  `
//         <div class="container">
//              <%= yield%>
//         <div`
// }

const inputBoxLabel = document.querySelector('.insign-input-label');

const inputBoxLabelContainer = document.querySelector('.insign-input-label');
const inputBoxLabelText = document.querySelector('.insign-input-label-text');

const insignInput = document.querySelector('.insign-textinput');
const passwordLabelText = document.querySelector('.insign-passwordlabel');


const insignGreyCardContainer = document.querySelector('.inner-signin-container');

const inSignXButton = document.querySelector('.insign-xsvgbutton');

const inSignLoginButton = document.querySelector('.insign-nextbutton');

// explore page elements


inSignXButton.addEventListener('click', () => {
    window.location.href = "/";
});

inputBoxLabelText.addEventListener('click', () => {
    insignInput.focus();
});

insignInput.addEventListener('focus', () => {
    inputBoxLabelContainer.className = "insign-input-label-focused";
    inputBoxLabelText.className = "insign-input-label-text-focused";
});

insignInput.addEventListener('blur', () => {

    if (insignInput.value === '') {
        inputBoxLabelContainer.className = "insign-input-label";
        inputBoxLabelText.className = "insign-input-label-text";
    }
});

insignGreyCardContainer.addEventListener('mouseleave', () => {
    console.log("We are mouse overing something");
    insignInput.blur();
});

inSignLoginButton.addEventListener('click', () => {
    window.location.href = "/innersigninpost?username=" + document.getElementsByClassName("insign-textinput")[0].value + "&password=" + document.getElementsByClassName("insign-textinput")[1].value;
});





