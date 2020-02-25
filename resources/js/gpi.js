
window.addEventListener('load',init);

function init(){
    body.classList.add('js');
    addCloser();
    addHoverListener();
    makeGenderLinks();
}


function makeGenderLinks(){
    var genderLinks = document.querySelectorAll('a.genderLink');
    genderLinks.forEach(function(link){
        link.addEventListener('click', function(e){
            e.preventDefault();
            highlightRefs(link);
        });
    });
}


function addHoverListener(){
    document.querySelectorAll('.poem a').forEach(function(a){
        a.addEventListener('mouseenter', select);
        a.addEventListener('mouseleave', deselect);
        a.addEventListener('click', toggle);
    }); 
}

function toggle(){
  if (this.classList.contains('clicked')){
    this.classList.remove('clicked');
    removeClicks();
  } else {
    removeClicks();
    this.classList.add('clicked');
  }
}

function removeClicks(){
  document.querySelectorAll('a.clicked').forEach(function(a){
    a.classList.remove('clicked');
  })
}

function select(){
  this.classList.remove('deselected');
  this.classList.add('selected');
}

function deselect(){
  this.classList.remove('selected');
  this.classList.add('deselected');
}


function addCloser(){
    var closer = document.getElementById('aside-toggle');
    if (closer){
            closer.addEventListener('click', toggleAside);
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

(function($){
    $(function(){

        // <span class="target" data-reference="#ida">
        function targetIn() {            
            var $this = $(this);
            var reference = $this.data('reference');
            console.log(reference);
            $("a[href='" + reference + "']").addClass('referenced');
        }

        function targetOut() {
            var $this = $(this);
            $(".referenced").removeClass("referenced");
        }

        function referenceIn() {
            var $this = $(this);
            var target = $this.attr('href');
            $("span[data-reference='" + target + "']").addClass('referenced');
        }

        function referenceOut() {
            var $this = $(this);
            $(".referenced").removeClass("referenced");
        }
        
        $("span.target").hover(targetIn, targetOut);
        $("a.reference").hover(referenceIn, referenceOut);
        
    });
})(jQuery);



