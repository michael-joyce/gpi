/**
 * Main Javascript file for the Gendered Personifications Index Project
 * (PI: Rawia Inaim). 
 * 
 * @author Joey Takeda
 * @author Michael Joyce
 * @author Digital Humanities Innovation Lab
 * 
 */


/**
 * Calls the initialization function on page load
 * 
 */
window.addEventListener('load',init);

/**
 * The URL parameters
 * 
 */
const urlParams = new URLSearchParams(window.location.search);

/**
 * The object string from the url parameters
 * 
 */
const object = urlParams.get('object');

/**
 * Initialization function, which calls the rest
 * of the functions
 * 
 */
function init(){
    /** First, add the .js class to the body for CSS purposes */
    body.classList.add('js');
    /** Call the various functions for setting up event listeners */
    addCloser();
    addMenuBurger();
    addObjectCloser();
    addLinkListeners();
    addRefToggles();
    
    /** 
     * If the object param is present
     * and the screen width is large enough, then click the first
     * reference to the desired object
     * 
     */
    if (object !== null && !(isSmol())){
        var firstRef = document.querySelectorAll("a[href='#" + object + "']")[0];
        firstRef.click();
    }
}

/**
 * Adds the click event for the toggles on
 * a poem aside
 * 
 */
function addRefToggles(){
    var toggles = document.querySelectorAll('button.refToggle');
    /** For each toggle button */
    toggles.forEach(function(btn){
       var ref = btn.getAttribute('data-ref');
       /** Add a click event listener */
       btn.addEventListener('click', function(e){
       /** Prevent default operation */
           e.preventDefault();
           
           /** Check to see if it's already pressed or not
            * and toggle that state */
           var pressed = btn.getAttribute('aria-pressed');
            if (pressed == 'true'){
                btn.setAttribute('aria-pressed','false');
            } else {
                btn.setAttribute('aria-pressed', 'true');
            }
            
            /** And then toggle the inline references (as per the
             * @data-ref attribute */
           toggleTogglers(ref);
       })
    });
}


/**
 * Toggles all of the references in a poem
 * that have a particular ref
 * 
 * @param {string} ref - The object reference id
 */
function toggleTogglers(ref){
    var active = document.querySelectorAll("a[href='#" + ref +"']");
    active.forEach(function(a){
       /* Simply toggle the clicked class */
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

/**
 * Adds the the click and hover listeners to references
 * in a poem
 * 
 */
function addLinkListeners(){
    document.querySelectorAll('.poem a:not(.linenum)').forEach(function(a){
        a.addEventListener('mouseenter', select);
        a.addEventListener('mouseleave', deselect);
        a.addEventListener('click', function(e){
            e.preventDefault();
            /** When clicked, a reference should call the toggleInline function */
            toggleInline.call(a);
        });
    }); 
}



/**
 * Toggles in the inline references
 * 
 */
function toggleInline(){
    var ref = this.getAttribute('href').substring(1);
    var obj = document.getElementById(ref);
    var toggleBtns = document.querySelectorAll('.refToggle[aria-pressed="true"]');
    var targBtn = document.getElementById('toggle_' + ref);
    var aside = document.getElementById('aside');
    
    /** If the aside is closed, then open it first */
    if (aside.getAttribute('aria-expanded') == 'false'){
        document.getElementById('aside-toggle').click();
    }
    
    /** If the reference is already clicked */
    if (this.classList.contains('clicked')){
    /** Then remove the active class from the object */
       obj.classList.remove('active');
       
       /** If the screen is small, then remove the gpi-modal */
        if (isSmol()){
            aside.classList.remove('gpi-modal');
        }
        
       /** Now click the target button (i.e. the object toggle) */ 
       targBtn.click();
       return;
    } else {
      /** Else  click the target button */
       targBtn.click();
       
       
       // Now remove all of the active states on the objects (this is only)
       // really necessary for mobile popups, but rather than detect device
       // size here, we'll just do it always
       removeActiveObj();
       
       /* Add the active class */
       obj.classList.add('active');
       
       /* Turn the modal on, if necessary */
       if (isSmol()){
           aside.setAttribute('class','gpi-modal');
           document.body.classList.add('modal-on');
        }
       
       // If the object isn't visible, scroll to it
       if (!inViewport(obj)){
          //Note that we can't use .scrollTo() here
          // since we're scrolling the object's parent
          obj.parentNode.scrollTop = obj.offsetTop;
       }
    }
    
   
     
 
}

/**
 * Determines whether or not the screen width is below 768px
 * 
 */
function isSmol(){
   const vw = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
   return (vw < 768); 
} 

/** 
 * Clear all of the active objects
 */
function removeActiveObj(){
    document.querySelectorAll('.object.active').forEach(function(o){
           o.classList.remove('active');
       });
}

/*
 * Check to see if an element is contained within the viewport
 */
function inViewport (elem) {
    var bounding = elem.getBoundingClientRect();
    return (
        bounding.top >= 0 &&
        bounding.left >= 0 &&
        bounding.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        bounding.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
};


/**
 * Add the toggle aside event listener to the closer
 * 
 */
function addCloser(){
    var closer = document.getElementById('aside-toggle');
    if (closer){
            closer.addEventListener('click', toggleAside);
    }

}

/**
 * Add the toggleNav event listener to the nav
 * hamburger button
 * 
 */
function addMenuBurger(){
    var menuBurger = document.querySelectorAll('nav.navbar > .hamburger')[0];
    menuBurger.addEventListener('click',toggleNav);
}

/**
 * Toggle the nav state
 * 
 */
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


/**
 * Add the click event for the object closer (which
 * is only visibile when the screen is below 768)
 * 
 */
function addObjectCloser(){
    var objectClosers = document.querySelectorAll('.objectCloser');
    var aside = document.getElementById('aside');
    
    /* Every object has a hidden closer */
    objectClosers.forEach(function(closer){
        closer.addEventListener('click', function(e){
            /* First, remove all of the active objects */
            removeActiveObj();
            
            /* Click the parent objects toggle (i.e. deselect
             * the reference) */
            var btn = closer.parentNode.querySelectorAll('.refToggle')[0];
            btn.click();
            
            /* Now remove all the modals */
            document.body.classList.remove('modal-on');
            aside.classList.remove('gpi-modal');
        });
    });
}


/**
 * Selects all of links that share the same
 * object reference and adds a common class 
 * to them 
 * 
 */
function select(){
    if (!this.classList.contains('clicked')){
     var refs = document.querySelectorAll("a[href='" + this.getAttribute('href') + "']");
     refs.forEach(function(ref){
         ref.classList.remove('deselected');
         ref.classList.add('selected');
     });
  }

}

/**
 * Selects all the links that share the same
 * object reference and removes a common class
 * from them. 
 * 
 * Note that this is necessary because of the CSS linear-gradient
 * animation; if you don't deselect, the background triggers prematurely
 * on page load.
 * 
 */
function deselect(){
  if (!this.classList.contains('clicked')){
     var refs = document.querySelectorAll("a[href='" + this.getAttribute('href') + "']");
     refs.forEach(function(ref){
         ref.classList.remove('selected');
         ref.classList.add('deselected');
     });
  }

}

/** 
 * Toggles the aside menu open and close.
 * 
 */
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




