
window.addEventListener('load',init);

function init(){
    body.classList.add('js');
    addCloser();
    addLinkListeners();
    addRefToggles();
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
    document.querySelectorAll('.poem a').forEach(function(a){
        a.addEventListener('mouseenter', select);
        a.addEventListener('mouseleave', deselect);
        a.addEventListener('click', function(e){
            e.preventDefault();
            toggleInline.call(a);
            if (window.matchMedia('(max-width: 600px)')){
                toggleModal();
            };
        });
    }); 
}


function toggleModal(){
    var aside = document.getElementById('aside');
    if (aside.classList.contains('gpi-modal')){
        aside.classList.remove('gpi-modal');
    } else {
        aside.classList.add('gpi-modal');
    }
    
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
       targBtn.click();
       return;
    } else {
        
       targBtn.click();
       
       
       // Now remove all of the active states on the objects (this is only)
       // really necessary for mobile popups, but rather than detect device
       // size here, we'll just do it always
       document.querySelectorAll('.object.active').forEach(function(o){
           o.classList.remove('active');
       });
       obj.classList.add('active');
       
       
       // If the object isn't visible, scroll to it
       if (!inViewport(obj)){
          //Note that we can't use .scrollTo() here
          // since we're scrolling the object's parent
          obj.parentNode.scrollTop = obj.offsetTop;
       }
   /*    toggleBtns.forEach(function(btn){
        if (btn.getAttribute('aria-pressed') == 'true' && (!(btn.getAttribute('id') == ref))){
            btn.click();
      }});*/
    }
    
   
     
 
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




