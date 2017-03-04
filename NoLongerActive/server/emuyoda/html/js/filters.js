/**
 * defines custom filters for application
 */
"use strict";

define(["angular"], function (angular, moment) {
  return angular.module("app.filters", [])
    .filter("timestampToString", [function () {
      return function (timestamp) {
        var ss = parseInt(timestamp, 10);
        var dd = Math.floor(ss / 86400);
        ss = ss - dd * 86400;
        var hh = Math.floor(ss / 3600);
        ss = ss - hh * 3600;
        var mm = Math.floor(ss / 60);
        ss = ss - mm * 60;
        var str = (hh < 10 ? "0" + hh : hh) + ":" + (mm < 10 ? "0" + mm : mm) + ":" + (ss < 10 ? "0" + ss : ss);
        if (dd > 0) {
          str = dd + " days, " + str;
        }
        return str;
      };
    }]);
});
