"use strict";
const btn = document.getElementById("buttonStartSpel");
const btnYes = document.getElementById("yes");
const btnNo = document.getElementById("no");
let randomNumber = Math.random();
let counter = 0;
let counter2 = 0;
let streak = 0;

let porDraakNiet = function () {
  changeParagraph("The dragon remains asleep, you are still safe.");
  setTimeout(askParagraph, 5000);
};

let porDraakWel = function () {
  counter++;
  counter2++;
  let s = "";
  if (counter > 1) {
    s = "s";
  }
  changeParagraph(
    `You poke the dragon, it makes a weird sound. But remains asleep 'phew'. U've poked the dragon ${counter} time${s}, ${
      5 - counter
    } more to go!`
  );
  disableButtons();
  if (counter2 === 1) {
    setTimeout(askParagraph, 8000);
    setTimeout(enableButtons, 8000);
  } else {
    setTimeout(askParagraph, 2500);
    setTimeout(enableButtons, 2500);
  }
};

function changeParagraph(text) {
  var paragraph = document.getElementById("text");
  paragraph.innerHTML = `${text}`;
}

function changeWinStreak(streak) {
  var paragraph = document.getElementById("winStreak");
  paragraph.innerHTML = `Your current winning streak: ${streak}`;
}

function resetParagraph() {
  var paragraph = document.getElementById("text");
  paragraph.innerHTML =
    "Would you like to poke the dragon? It's very tempting.";
}

function askParagraph() {
  let opnieuw = "";
  if (counter > 0) {
    opnieuw = " again";
  }
  var paragraph = document.getElementById("text");
  paragraph.innerHTML = `Would you like to poke the dragon${opnieuw}?`;
}

function spelVerloren() {
  changeParagraph(
    "The dragon is waking up! RUNNNNNNNN<br>U've been eaten :(, wait a few seconds to try again!"
  );
  streak = 0;
  changeWinStreak(0);
  disableButtons();
  setTimeout(resetGame, 10000);
}

function spelGewonnen() {
  changeParagraph(
    "Congratulations! U've poked the dragon 5 times! Now ur life feels a little more succesfull!<br>Wait a few seconds to restart!"
  );
  streak++;
  changeWinStreak(streak);
  disableButtons();
  setTimeout(resetGame, 10000);
}

function disableButtons() {
  btnYes.disabled = true;
  btnNo.disabled = true;
}

function enableButtons() {
  btnYes.disabled = false;
  btnNo.disabled = false;
}

let porDraak = function () {
  if (randomNumber <= 0.2) {
    spelVerloren();
  } else if (counter === 4) {
    spelGewonnen();
  } else {
    porDraakWel();
  }
  randomNumber = Math.random();
};

function toggleVisibilityOn() {
  var choice = document.getElementById("choice");
  var text = document.getElementById("text");
  var styleChoice = window.getComputedStyle(choice);
  var styleText = window.getComputedStyle(text);
  if (styleChoice.display === "none") {
    choice.style.display = "block";
  }
  if (styleText.display === "none") {
    text.style.display = "block";
  }
  btn.disabled = true;
}

function resetGame() {
  randomNumber = Math.random();
  counter = 0;
  resetParagraph();
  enableButtons();
}

btn.addEventListener("click", toggleVisibilityOn);
btnYes.addEventListener("click", porDraak);
btnNo.addEventListener("click", porDraakNiet);
