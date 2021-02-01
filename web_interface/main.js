//Multiplication (https://stackoverflow.com/questions/21223164/multiplying-two-inputs-with-javascript-displaying-in-text-box)
function calculate() {
	var myBox1 = document.getElementById('box1').value;
	var myBox2 = document.getElementById('box2').value;
	var result = document.getElementById('result');
	var myResult = myBox1 * myBox2;
	document.getElementById('result').value = myResult/1000000;

}

window.onscroll = function() {myFunction()};
var navbar = document.getElementById("nav");
var sticky = navbar.offsetTop;

function myFunction() {
  if (window.pageYOffset >= sticky) {
    navbar.classList.add("sticky")
  } else {
    navbar.classList.remove("sticky");
  }
}

var is_test = window.location.pathname.includes("test");
var title = "CLAS12 Monte-Carlo Job Submission Portal";
if (is_test){
	title = title + " (Test Version)";
}
document.getElementById('title').innerHTML = title;

function genSelected(val) {
	var generator = document.getElementById("generator").value;
	if (generator == "clasdis") {
		document.getElementById("generatorLink").getElementsByTagName('a')[0].href='https://github.com/JeffersonLab/clasdis-nocernlib/blob/master/README.md';
		document.getElementById("generatorLink").getElementsByTagName('a')[0].innerHTML='clasdis options';
	} else if (generator == "dvcsgen") {
		document.getElementById("generatorLink").getElementsByTagName('a')[0].href='https://github.com/JeffersonLab/dvcsgen/blob/master/README.md';
		document.getElementById("generatorLink").getElementsByTagName('a')[0].innerHTML='dvcsgen options';

	} else if (generator == "disrad") {
		document.getElementById("generatorLink").getElementsByTagName('a')[0].href='https://github.com/JeffersonLab/inclusive-dis-rad/blob/master/README.md';
		document.getElementById("generatorLink").getElementsByTagName('a')[0].innerHTML='disrad options';

	} else if (generator == "genKYandOnePion") {
		document.getElementById("generatorLink").getElementsByTagName('a')[0].href='https://github.com/ValeriiKlimenko/genKYandOnePion';
		document.getElementById("generatorLink").getElementsByTagName('a')[0].innerHTML='genKYandOnePion options';

	} else if (generator == "gemc") {
		document.getElementById("generatorLink").getElementsByTagName('a')[0].href='https://gemc.jlab.org/gemc/html/documentation/generator/internal.html';
		document.getElementById("generatorLink").getElementsByTagName('a')[0].innerHTML='gemc generator options';

	}
}

function configurationSelected(){
	var text = "<option selected hidden value=\"\"></option>";
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		  if (this.readyState == 4 && this.status == 200) {
			var myObj = JSON.parse(this.responseText);
			for (experiments in myObj){
				text += "<option value=\""+experiments+"\">"+experiments+"</option>";
			}
			document.getElementById("configuration").innerHTML= text;
		}
	};
	xmlhttp.open("GET", "data/xrootd.json", true);
	xmlhttp.send();
}

function fieldSelected() {
	var experiments = document.getElementById("configuration").value;
	var text = "<option selected hidden value=\"\"></option>";
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		  if (this.readyState == 4 && this.status == 200) {
			var myObj = JSON.parse(this.responseText);
			if (experiments in myObj){
				var keys_field = Object.keys(myObj[experiments]);
				for (key in keys_field){
					text += "<option value=\""+keys_field[key]+"\">"+keys_field[key]+"</option>";
				}
			}
			document.getElementById("fields").innerHTML= text;
		}
	};
	xmlhttp.open("GET", "data/xrootd.json", true);
	xmlhttp.send();

}

function bkmergingSelected() {
	var experiments = document.getElementById("configuration").value;
	var fields = document.getElementById("fields").value;
	var text = "";
	text += "<option selected  value=\"no\"> Not Available </option>"
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		  if (this.readyState == 4 && this.status == 200) {
			var myObj = JSON.parse(this.responseText);
			if (experiments in myObj){
				var vals  = myObj[experiments][fields];
				for (val in vals){
					if (vals[val] != "") text += "<option value=\""+vals[val]+"\">"+vals[val]+"</option>";
				}
			}
			document.getElementById("bkmerging").innerHTML= text;
		}
	};
	xmlhttp.open("GET", "data/xrootd.json", true);
	xmlhttp.send();
}

function osgLogtoTable() {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
		  if (this.readyState == 4 && this.status == 200) {
		    var myObj = JSON.parse(this.responseText);
		    //set up table
		    var txt = "<table align=\"center\" style=\"width:100%;text-align:center\"><caption align=\"bottom\">"
		    //bottom caption from metadata
		    var meta = myObj.metadata;
		    txt+= meta["footer"];
		    txt+= "</caption><tr>";
		    // first row from keys
   		    var keys = Object.keys(myObj.user_data[0]);
		    for (i=0; i<keys.length; i++){
		    	txt+="<th>";
		    	txt+=keys[i];
		    	txt+="</th>";
		    }
		    // data rows
		    for (rows=0; rows<myObj.user_data.length;rows++){
		    	txt+="</tr><tr>";
		    	var val = myObj.user_data[rows];
			    for (var newkeys in val){
			    	txt+="<td>";
			    	txt+=val[newkeys];
			    	txt+="</td>";
			    }
//			    if (val.username == username){
//			    	txt+="<td>yours</td>"
//			    }
		    }
		    txt+="</tr></table>";
		    document.getElementById("osgLog").innerHTML = txt;
		  }
		};
		xmlhttp.open("GET", "data/osgLog.json", true);
		xmlhttp.send();
}

function diskUsagetoTable() {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
		  if (this.readyState == 4 && this.status == 200) {
		    var myObj = JSON.parse(this.responseText);
		    //set up table
		    var txt = "<table align=\"center\" style=\"width:60%;text-align:center\"><tr><th>Name</th><th>Disk Usage</th></tr>";
   		    for (var user in myObj){
   		    	txt+="<tr><td>"+user+"</td>";
   		    	txt+="<td>"+myObj[user].total_size+"</td>"
                        if(user==username){
                                txt+="<td><details><summary>details</summary>";
                                txt+="<div class=\"w3-center\"><form action=\"condorrm.php\" method=\"POST\">";
                                for (var index in myObj[username]["sub_directories"]){
                                        var nameandsize = myObj[username]["sub_directories"][index];
                                        for (var keys in nameandsize){
                                                if (keys=="name"){
                                                        txt+="<input type=\"checkbox\" name=\""+nameandsize[keys]+"\">";
                                                }
                                                txt+=keys+": "+nameandsize[keys]+"  ";
                                        }
                                        txt+="<br>";
                                }
	                        txt+="<input type=\"submit\" value=\"cancel\">";
	                        txt+="</form>";
	                        txt+="</div></details></td>";
	                        txt+="</tr>";
                        }
                    }
                    txt+="</table>";
		    document.getElementById("du").innerHTML = txt;
		  }
		};
		xmlhttp.open("GET", "data/disk.json", true);
		xmlhttp.send();
}


function max_events(checkboxElem) {
	var jobs = document.getElementById('box1');
	if(document.getElementById('gemcEvioOUT').checked || document.getElementById('generatorOUT').checked || document.getElementById('gemcHipoOUT').checked || document.getElementById('reconstructionOUT').checked)
		jobs.max = "100";
	else jobs.removeAttribute('max')
			}
