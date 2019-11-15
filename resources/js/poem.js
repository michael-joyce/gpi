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
