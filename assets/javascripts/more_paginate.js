(function($){
  $.fn.extend({
    morePaginate: function(options) {
      var options = $.extend({ }, $.fn.morePaginateDefaults, options);

      return this.each(function() {
        var link = $(this);

        if ("#" == link.attr("href")) { 
          link.addClass(options.disabledClass);
          link.attr("data-sort-value", "");
        }

        link.click(function() {
          if("" == link.attr("data-sort-value")) {
            link.addClass(options.disabledClass);
            return false;
          }

          $.ajax({
            type: "GET",
            url: link.attr("href"),
            beforeSend: function(xhr){
              xhr.setRequestHeader("Accept", options.accept);
              options.start.call();
            },
            success: function(data) {
              id = link.attr("id");
              link.remove();
              $(options.container).append(data);
              link = $("#" + id);
              link.morePaginate(options); // this is a workaround cause link.live doesn't work.
              options.success.call();
            }
          });

          return false;
        });
      });
    },

    morePaginateDefaults: {
      start:   function() { },
      success: function() { },
      disabledClass: "disabled",
      accept: "text/javascript"
    }
  });
})(jQuery);
