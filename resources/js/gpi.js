
window.addEventListener('load',init);

const urlParams = new URLSearchParams(window.location.search);
const object = urlParams.get('object');

function init(){
    body.classList.add('js');
  
    addCloser();
    addMenuBurger();
    addObjectCloser();
    addLinkListeners();
    addRefToggles();
    if (object !== null && (!isSmol)){
        var firstRef = document.querySelectorAll("a[href='#" + object + "']")[0];
        
        firstRef.click();
        
    }
}

function addRefToggles(){
    var toggles = document.querySelectorAll('button.refToggle');
    toggles.forEach(function(btn){
       var ref = btn.getAttribute('data-ref');
       btn.addEventListener('click', function(e){
           e.preventDefault();
           var pressed = btn.getAttribute('aria-pressed');
            if (pressed == 'true'){
                btn.setAttribute('aria-pressed','false');
            } else {
                btn.setAttribute('aria-pressed', 'true');
            }
           toggleTogglers(ref);
       })
    });
}

function toggleTogglers(ref){
    var active = document.querySelectorAll("a[href='#" + ref +"']");
    active.forEach(function(a){
        if (a.classList.contains('clicked')){
            a.classList.remove('clicked');
            a.classList.add('deselected');
        } else {
            a.classList.add('clicked');
            a.classList.remove('selected');
            a.classList.remove('deselected');
        }
    });
}

function addLinkListeners(){
    document.querySelectorAll('.poem a:not(.linenum)').forEach(function(a){
        a.addEventListener('mouseenter', select);
        a.addEventListener('mouseleave', deselect);
        a.addEventListener('click', function(e){
            e.preventDefault();
            toggleInline.call(a);
        });
    }); 
}



function toggleInline(){
    var ref = this.getAttribute('href').substring(1);
    var obj = document.getElementById(ref);
    var toggleBtns = document.querySelectorAll('.refToggle[aria-pressed="true"]');
    var targBtn = document.getElementById('toggle_' + ref);
    var aside = document.getElementById('aside');

    
    if (aside.getAttribute('aria-expanded') == 'false'){
        document.getElementById('aside-toggle').click();
    }
    
    if (this.classList.contains('clicked')){
    
       obj.classList.remove('active');
        if (isSmol){
            aside.classList.remove('gpi-modal');
        }
       targBtn.click();
       return;
    } else {

       targBtn.click();
       
       
       // Now remove all of the active states on the objects (this is only)
       // really necessary for mobile popups, but rather than detect device
       // size here, we'll just do it always
       removeActiveObj();

       obj.classList.add('active');
       if (isSmol){
           aside.setAttribute('class','gpi-modal');
           document.body.classList.add('modal-on');
        }
       
       // If the object isn't visible, scroll to it
       if (!inViewport(obj) && (!isSmol)){
          //Note that we can't use .scrollTo() here
          // since we're scrolling the object's parent
          obj.parentNode.scrollTop = obj.offsetTop;
       }
    }
    
   
     
 
}

var isSmol = function(){
   const vw = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
   return (vw < 768); 
    
} 

function removeActiveObj(){
document.querySelectorAll('.object.active').forEach(function(o){
           o.classList.remove('active');
       });
}
function inViewport (elem) {
    var bounding = elem.getBoundingClientRect();
    return (
        bounding.top >= 0 &&
        bounding.left >= 0 &&
        bounding.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        bounding.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
};


function addCloser(){
    var closer = document.getElementById('aside-toggle');
    if (closer){
            closer.addEventListener('click', toggleAside);
    }

}

function addMenuBurger(){
    var menuBurger = document.querySelectorAll('nav.navbar > .hamburger')[0];
    menuBurger.addEventListener('click',toggleNav);
}

function toggleNav(){
    var nav = document.querySelectorAll('body > nav')[0];
    
    if (nav.getAttribute('aria-open') == 'true'){
        nav.setAttribute('aria-open', 'false');
        document.body.classList.remove('gpi-modal');
        this.classList.remove('is-active');
    } else {
        nav.setAttribute('aria-open', 'true');
        document.body.classList.add('gpi-modal');
        this.classList.add('is-active');
    }
}

function addObjectCloser(){
    var objectClosers = document.querySelectorAll('.objectCloser');
    var aside = document.getElementById('aside');
    objectClosers.forEach(function(closer){
        closer.addEventListener('click', function(e){
            removeActiveObj();
            var btn = closer.parentNode.querySelectorAll('.refToggle')[0];
            btn.click();
            document.body.classList.remove('modal-on');
            aside.classList.remove('gpi-modal');
        });
    });
}


function select(){
    if (!this.classList.contains('clicked')){
     var refs = document.querySelectorAll("a[href='" + this.getAttribute('href') + "']");
     refs.forEach(function(ref){
         ref.classList.remove('deselected');
         ref.classList.add('selected');
     });
  }

}

function deselect(){
  if (!this.classList.contains('clicked')){
     var refs = document.querySelectorAll("a[href='" + this.getAttribute('href') + "']");
     refs.forEach(function(ref){
         ref.classList.remove('selected');
         ref.classList.add('deselected');
     });
  }

}


function toggleAside(){
    var aside = document.getElementById('aside');
    var main = document.getElementsByTagName('main')[0];
    var expanded = aside.getAttribute('aria-expanded');
    if (expanded == 'true'){
        aside.setAttribute('aria-expanded','false');
        this.classList.remove('is-active');
        main.classList.add('aside-hidden');
       
    } else {
        aside.setAttribute('aria-expanded', 'true');
        this.classList.add('is-active');
                main.classList.remove('aside-hidden');
    }
  
}




