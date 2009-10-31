module("morePaginateDefaults");
test("should have defaults", function() {
  var defaults = {
    success: function() { },
    disabledClass: "disabled"
  }

  ok($.isFunction($.fn.morePaginateDefaults['success']), "Expected function");
  equals( "disabled", $.fn.morePaginateDefaults['disabledClass']);
});
