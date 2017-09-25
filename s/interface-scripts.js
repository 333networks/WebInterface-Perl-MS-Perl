/* * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * 333networks site                                    *
 * Written by Darkelarious                             *
 * Please see http://git.333networks.com/ for          *
 * questions and copyright.                            *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * */

function DOMLoad(y){var d=0;var f=function(){if(d++)return;y()};if(document.addEventListener)document.addEventListener("DOMCont"+"entLoaded",f,false);document.write("<script id=_ie defer src="+"javascript:void(0)><\/script>");document.getElementById('_ie').onreadystatechange=function(){if(this.readyState=="complete")f()};if(/WebKit/i.test(navigator.userAgent))var t=setInterval(function(){if(/loaded|complete/.test(document.readyState)){clearInterval(t);f()}},10);window.onload=f;}

// spam protection on all forms
setTimeout(function() {
  for(i=0; i<document.forms.length; i++)
    document.forms[i].action = document.forms[i].action.replace(/\/nospam\?/,'');
}, 500);

function x(y){return document.getElementById(y)}

// show/hide scripts for big blocks of code
function show(x){
  var xdiv = document.getElementById(x);
  xdiv.style.display = (xdiv.style.display == 'block') ? 'none' : 'block';
}

// IV script by YorHel
var ivL=[];
function ivInit() {
  var l=document.getElementsByTagName('a');
  for(i=0;i<l.length;i++)
    if(l[i].rel && l[i].rel.indexOf('iv:')==0) {
      l[i].onclick=ivView;
      ivL[ivL.length] = l[i];
    }

  var d = document.createElement('div');
  d.id = 'ivview';
  d.innerHTML = '<b id="ivimg"></b><br />'
    +'<a href="#" id="ivfull">&nbsp;</a>'
    +'<a href="#" onclick="return ivClose()" id="ivclose">close</a>'
    +'<a href="#" onclick="return ivView(this)" id="ivprev">&laquo; previous</a>'
    +'<a href="#" onclick="return ivView(this)" id="ivnext">next &raquo;</a>';
  document.body.appendChild(d);
  d = document.createElement('b');
  d.id = 'ivimgload';
  d.innerHTML = 'Loading...';
  document.body.appendChild(d);
}
function ivView(what) {
  what = what && what.rel ? what : this;
  var u=what.href;
  var r=what.rel;
  d = x('ivview');

 // fix prev/next links (if any)
  for(var i=0;i<ivL.length;i++)
    if(ivL[i].href == u) {
      x('ivnext').style.visibility = ivL[i+1] ? 'visible' : 'hidden';
      x('ivnext').href = ivL[i+1] ? ivL[i+1].href : '#';
      x('ivnext').rel = ivL[i+1] ? ivL[i+1].rel : '';
      x('ivprev').style.visibility = ivL[i-1] ? 'visible' : 'hidden';
      x('ivprev').href = ivL[i-1] ? ivL[i-1].href : '#';
      x('ivprev').rel = ivL[i-1] ? ivL[i-1].rel : '';
    }

 // calculate dimensions
  r = r.substring(3);
  var w = Math.floor(r.split('x')[0]);
  var h = Math.floor(r.split('x')[1]);
  var ww = typeof(window.innerWidth) == 'number' ? window.innerWidth : document.documentElement.clientWidth;
  var wh = typeof(window.innerHeight) == 'number' ? window.innerHeight : document.documentElement.clientHeight;
  var st = typeof(window.pageYOffset) == 'number' ? window.pageYOffset : document.body && document.body.scrollTop ? document.body.scrollTop : document.documentElement.scrollTop;
  if(w+100 > ww || h+70 > wh) {
    x('ivfull').href = u;
    x('ivfull').innerHTML = w+'x'+h;
    x('ivfull').style.visibility = 'visible';
    if(w/h > ww/wh) { // width++
      h *= (ww-100)/w;
      w = ww-100;
    } else { // height++
      w *= (wh-70)/h;
      h = wh-70;
    }
  } else
    x('ivfull').style.visibility = 'hidden';
  var dw = w;
  var dh = h+20;
  dw = dw < 200 ? 200 : dw;

 // update document
  d.style.display = 'block';
  x('ivimg').innerHTML = '<img src="'+u+'" onclick="ivClose()" onload="document.getElementById(\'ivimgload\').style.top=\'-400px\'" style="width: '+w+'px; height: '+h+'px" />';
  d.style.width = dw+'px';
  d.style.height = dh+'px';
  d.style.left = ((ww - dw) / 2 - 10)+'px';
  d.style.top = ((wh - dh) / 2 + st - 20)+'px';
  x('ivimgload').style.left = ((ww - 100) / 2 - 10)+'px';
  x('ivimgload').style.top = ((wh - 20) / 2 + st)+'px';
  return false;
}
function ivClose() {
  x('ivview').style.display = 'none';
  x('ivview').style.top = '-5000px';
  x('ivimg').innerHTML = '';
  return false;
}

// create new server entry page
var t;
function QueryLink()
{
  clearTimeout(t);
  t = setTimeout("QueryServer()", 2000);
  
  var newlink = x("newlink");
  newlink.innerHTML   = "Typing...";
  newlink.style.color = "#aaa";
}


// create new server entry page
function QueryServer() {
  var ip       = x("ip");
  var port     = x("port");

  var newlink = x("newlink");
  var validate = x("validate");

  var ValAddress = "/new/"+ip.value+":"+port.value+"/"+(Math.floor(Math.random()*999)+1);

  newlink.innerHTML   = "Checking...";
  newlink.style.color = "#aa5";

  var check = (window.ActiveXObject) ? new ActiveXObject('Microsoft.XMLHTTP') : new XMLHttpRequest();

  check.onreadystatechange = function (){
    if (check.readyState==4 && check.status==200){
      var rx = check.responseText;
      if (rx == "invalid"){
        newlink.innerHTML = "This server appears to be offline, unreachable or is not supported. Please check your values and try again.";
        newlink.style.color = "#a55";
        validate.style.display = "none";
      }else{
        newlink.innerHTML = "<a href=\"/ut/"+ip.value+":"+port.value+"\">Success! Click here to view your server in our database!</a>";
        validate.innerHTML = rx;
        validate.style.display = "block";
      }
    }else if (check.status==500){
        newlink.innerHTML = "An error occurred while processing the response. Please check your values and try again.";
        newlink.style.color = "#a55";
        validate.style.display = "none";    
    }
  }

	check.open("GET", ValAddress, true);
	check.send(null);
}


/*  O N L O A D  */
DOMLoad(function(){
  ivInit();
});
