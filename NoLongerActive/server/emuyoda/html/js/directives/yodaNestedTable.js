'use strict';

define(["./module"], function (directives) {
  directives
    .directive("yodaNestedTable", function () {
      return {
        restrict: "A",
        replace: false,
        scope: {
          object: "=yodaNestedTable"
        },
        template: "<yodanestedtablerow ng-repeat='(key, value) in object' key='key' value='value'></yodanestedtablerow>"
      };
    })
    .directive("yodanestedtablerow", function ($compile) {
      return {
        restrict: "E",
        replace: true,
        scope: {
          key: "=",
          value: "="
        },
        template: "<tr>",
        link: function (scope, element, attrs) {
          var val = "{{ value }}";
          if (angular.isObject(scope.value)) {
            val = "<table class='table table-striped table-hover' yoda-nested-table='value'>";
          }
          element.append("<td>{{ key }}:</td><td style='text-align:left;'>" + val + "</td></tr>");
          $compile(element.contents())(scope);
        }
      };
    });
});
