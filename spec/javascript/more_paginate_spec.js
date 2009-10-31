var TestUtil = {
  defaults: {
    success: function() { },
    disabledClass: "disabled",
    accept: "text/javascript"
  },

  reset: function() {
    $.extend($.fn.morePaginateDefaults, this.defaults);
    $("#events").html("");
  }
}

module("morePaginate");
test("should disable link on missing data-sort-value attribute", function() {
  var link = $("#missing_data_sort_link");
  link.morePaginate({ container: "#events" });
  link.click();
  ok(link.hasClass("disabled"), "Expected 'disabled' class");
});

test("should use given class to disable link on missing data-sort-value attribute", function() {
  var link = $("#missing_data_sort_link");
  link.morePaginate({ container: "#events", disabledClass: "disabledLink" });
  link.click();
  ok(link.hasClass("disabledLink"), "Expected 'disabledLink' class");
});

test("should perform an AJAX request when clicked", function() {
  TestUtil.reset();
  var link = $("#more_link");
  link.morePaginate({ container: "#events" });

  link.click();
  equals( $("#more_link").size(), 1 );

  link.click(); // verify if the new created link is ready for a new request
  equals( $("#more_link").size(), 1 );

  // wait for jQuery while inserting the server side HTML
  window.setTimeout(function() { equals( $("#events ul").size(), 2 ); }, 500);
});

test("should invoke custom function after the AJAX success", function() {
  TestUtil.reset();
  var link = $("#more_link_success");
  link.morePaginate({
    container: "#events",
    success: function() {
      $("#fixtures").append('<div id="success">success</div>');
    }
  });

  // wait for jQuery while inserting the server side HTML
  window.setTimeout(function() {
    equals( $("#events ul").size(), 1 );
    equals( $("#success").size(),   1 );
  }, 500);
});

module("morePaginateDefaults");
test("should have defaults", function() {
  TestUtil.reset();
  ok( $.isFunction($.fn.morePaginateDefaults['success']), "Expected function" );
  equals( $.fn.morePaginateDefaults['disabledClass'], "disabled" );
  equals( $.fn.morePaginateDefaults['accept'], "text/javascript" );
});
