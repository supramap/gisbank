// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function showHideSpinner() {
    var divstyle = new String();
    divstyle = document.getElementById("spinner").style.visibility;
    if(divstyle.toLowerCase()=="visible" || divstyle == "")
    {
        document.getElementById("spinner").style.visibility = "hidden";
    }
    else
    {
        document.getElementById("spinner").style.visibility = "visible";
    }
}