$(function() {
    jQuery.fn.extend({
        disable: function(state) {
            return this.each(function() {
                var $this = $(this);
                if($this.is('input, button'))
                    this.disabled = state;
                else
                    $this.toggleClass('disabled', state);
            });
        }
    });

    $('input[type="submit"], input[type="button"], button, a').disable(true);

    $('body').on('click', 'a.disabled', function(event) {
        event.preventDefault();
    });
});