//  Written & created by Shivaji Basu
//  Copyright & Disclaimer www.shivbasu.com
//  Use this script at your own risk
//  For further info, contact info@shivbasu.com
//  To use his script, you MUST leave this disclaimer & credit as it is

function cOn(tr){
  if(document.getElementById||(document.all && !(document.getElementById))){
    tr.style.backgroundColor="#9CD810";
  }
}

function cOut(tr, colour){
  if(document.getElementById||(document.all && !(document.getElementById))){
    tr.style.backgroundColor=colour;
  }
}
