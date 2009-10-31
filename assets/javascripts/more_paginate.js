(function($){  
  $.fn.extend({   
    morePaginate: function(options) {  
      var options = $.extend($.fn.morePaginateDefaults, options);

      return this.each(function() {
        var link = $(this);
        link.click(function() {
          if(null == link.attr("data-sort-value")) {
            link.addClass(options.disabledClass);
            return false;
          }

          $.ajax({
            type: "GET",
            url: link.attr("href"),
            beforeSend: function(xhr){
              xhr.setRequestHeader("Accept", options.accept);
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
      success: function() { },
      disabledClass: "disabled",
      accept: "text/javascript"
    }
  });
})(jQuery);  
