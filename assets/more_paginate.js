(function($){  
  $.fn.extend({   
    morePaginate: function(options) {  
      var defaults = {
        success: function() { }
      }

      var options = $.extend(defaults, options);  

      return this.each(function() {
        var link = $(this);
        link.click(function() {
          $.ajax({
            type: "GET",
            url: link.attr("href"),
            beforeSend: function(xhr){
              xhr.setRequestHeader("Accept", "text/javascript");
            },
            success: function(data) {
              // TODO update link options (via this)
              $(options.container).append(data);
              options.success.call();
            }
          });
 
          return false;
        });
      });
    }
  });
})(jQuery);  
