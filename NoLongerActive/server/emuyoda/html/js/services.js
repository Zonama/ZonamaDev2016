"use strict";

define(["angular"], function (angular) {
  return angular.module("app.services", [])
    .factory("yodaApiService", function ($rootScope, $http) {
      console.debug("return yodaApiService");
      return {
        authenticateUser: function (username, password) {
          return $http.post("/api/auth", {
            auth: {
              username: username,
              password: password
            }
          }).then(function (r) {
            if (r.data.response.token) {
              $rootScope.currentUsername = username;
              $rootScope.authToken = r.data.response.token;
            } else {
              delete $rootScope.currentUsername;
              delete $rootScope.authToken;
            }
            return r.data;
          }).catch(function () {
            delete $rootScope.currentUsername;
            delete $rootScope.authToken;
          });
        },
        getConfig: function () {
          return $http.get("/api/config").then(function (response) {
            return response.data;
          });
        },
        putConfig: function (data) {
          return $http.put("/api/config", data).then(function (r) {
            return r.data;
          });
        },
        updateConfig: function (config) {
          return $http.put("/api/config", config).then(function (response) {
            return response.data;
          });
        },
        getStatus: function () {
          return $http.get("/api/status").then(function (response) {
            return response.data;
          });
        },
        serverCommand: function (cmd) {
          return $http.get("/api/control?command=" + cmd).then(function (response) {
            return response.data;
          });
        },
        getAccount: function () {
          return $http.get("/api/account").then(function (response) {
            return response.data;
          });
        },
        addAccount: function (account) {
          return $http.post("/api/account", account).then(function (response) {
            return response.data;
          });
        }
      };
    })
    .factory("authInterceptor", function ($rootScope, $q, $window) {
      console.debug("return authInterceptor");
      return {
        request: function (config) {
          config.headers = config.headers || {};
          if ($rootScope.authToken) {
            config.headers.Authorization = $rootScope.authToken;
          }
          return config;
        },
        response: function (response) {
          if (response.status === 401) {
            delete $rootScope.currentUsername;
            delete $rootScope.authToken;
          }
          return response || $q.when(response);
        }
      };
    })
    .factory("loginModalService", function ($rootScope, $uibModal, yodaApiService) {
      console.debug("return loginModalService");
      return {
        openModal: function () {
          console.debug("loginModalService.openModal()");
          return $uibModal.open({
            animation: true,
            templateUrl: "views/loginModalTemplate.html?burst=v2",
            controller: "loginModalController",
            size: "sm"
          }).result.then(function (auth) {
            $rootScope.currentUsername = auth.username;
            yodaApiService.authenticateUser(auth.username, auth.password);
            return auth.username;
          });
        }
      };
    });
});
