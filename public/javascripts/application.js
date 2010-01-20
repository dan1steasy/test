// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// executes an onchange function after a specified delay
function onChange(code) {
  delay = 750;
  window.clearTimeout(soc_id);
  soc_id = window.setTimeout(code, delay);
} 
// global timer ID for the onChange function.
var soc_id = null;

function toggleExpiry() {
  if($('licence_no_expiry').checked) {
    $("licence_expires_on_1i").disabled = true;
    $("licence_expires_on_2i").disabled = true;
    $("licence_expires_on_3i").disabled = true;
  }
  else {
    $("licence_expires_on_1i").disabled = false;
    $("licence_expires_on_2i").disabled = false;
    $("licence_expires_on_3i").disabled = false;
  }
}

function toggleIpCompany() {
  if($('ip_address_no_company').checked) {
    $('ip_address_company_id').disabled = true;
  }
  else {
    $('ip_address_company_id').disabled = false;
  }
}

function toggleIpHardware() {
  if($('ip_address_no_hardware').checked) {
    $('ip_address_hardware_id').disabled = true;
  }
  else {
    $('ip_address_hardware_id').disabled = false;
  }
}

// function for hideable DIVS        
function toggleHide( divName ) {
    // function to toggle the display properties of a hideable div/span
    hideableDiv = document.getElementById( divName );
    if(hideableDiv.style.display == "inline") {
        hideableDiv.style.display = "none";
    }
    else {
        hideableDiv.style.display = "inline";
    }
}

function imgSwap( imageName ) {
    var moreImg = "/images/more.gif";
    var lessImg = "/images/less.gif";
    
    imageobj = document.getElementById( imageName );
    
    if(imageobj.src.match(moreImg) ) {
	   imageobj.src = lessImg;
	}
	else {
		imageobj.src = moreImg;
	}
}
