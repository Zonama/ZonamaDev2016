"use strict";

define(["./module"], function (controllers) {
  controllers.controller("connectController", ["$scope", "yodaApiService", function ($scope, yodaApiService) {
    yodaApiService.getStatus().then(function (data) {
      $scope.server_status = data.response.server_status;
    }).catch(function () {
      $scope.error = "/api/status call failed";
    });
  }]);
});
