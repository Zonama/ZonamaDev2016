"use strict";

var controllerProvider;

define([
  "angular",
  "ui.router",
  "angular.animate",
  "angular.sanitize",
  "ui.bootstrap",
  "./controllers/index",
  "./directives/index",
  "config",
  "services",
  "filters"
], function (angular) {
  return angular.module("app", [
    "ui.router",
    "ngAnimate",
    "ngSanitize",
    "ui.bootstrap",
    "app.controllers",
    "app.directives",
    "app.constants",
    "app.services",
    "app.filters"
  ], function ($controllerProvider) {
    controllerProvider = $controllerProvider;
  }).run(function ($rootScope, $state, $templateCache, $cacheFactory, loginModalService) {
    $rootScope.$on("$stateChangeStart", function (event, toState, toParams, fromState, fromParams) {
      if (typeof toState !== "undefined" && typeof toState.templateUrl == "string") {
        $templateCache.remove(toState.templateUrl);
      }
      var requireLogin = toState.data.requireLogin;
      if (requireLogin && typeof $rootScope.currentUsername === "undefined") {
        event.preventDefault();
        loginModalService.openModal().then(function () {
          return $state.go(toState.name, toParams);
        }).catch(function () {
          return $state.go("home");
        });
      }
    });
  });
});
