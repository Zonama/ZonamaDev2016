"use strict";

define(["./module"], function (controllers) {
  controllers.controller("navController", ["$scope", "$q", "$location", "yodaApiService", function ($scope, $q, $location, yodaApiService) {
    $scope.cfg = {};
    $scope.server_status = {};
    $scope.account = {};
    $scope.zones = {};
    $scope.canCreateAdminAccount = false;
    $scope.shouldConfigureZones = false;

    $scope.isActive = function (viewLocation) {
      return viewLocation === $location.path();
    };

    $scope.loadData = function () {
      $scope.canCreateAdminAccount = false;
      $scope.shouldConfigureZones = false;
      $q.all([yodaApiService.getConfig().then(function (data) {
        $scope.cfg = data.response.config;
        $scope.messages = "";
        if (data.response.error) {
          $scope.messages = "API CALL TO " + data.response.service + " FAILED WITH ERROR: " + data.response.error;
          console.log($scope.messages);
        }
        if ($scope.cfg && $scope.cfg.emu && $scope.cfg.emu.ZonesEnabled) {
          $scope.cfg.emu.ZonesEnabled.forEach(function (zone) {
            $scope.zones[zone] = true;
          });
        }
      }).catch(function () {
        $scope.error = "/api/config call failed";
      }), yodaApiService.getStatus().then(function (data) {
	if (data.response.server_status.zoneServer_error) {
	    if (data.response.server_status.zoneServer_error.indexOf('read stream from socket') > -1) {
		data.response.server_status.zoneServer_error = 'Server not running';
	    } else {
		delete data.response.server_status.zoneServer_error;
	    }
	}
        $scope.server_status = data.response.server_status;
      }).catch(function () {
        $scope.error = "/api/status call failed";
      })]).then(function () {
        if ($scope.server_status.num_accounts === 0 && $scope.server_status.account && $scope.server_status.account.admin_level >= 15) {
          $scope.canCreateAdminAccount = true;
          $scope.shouldConfigureZones = false;
        }
        if ($scope.server_status.num_accounts === 1 && $scope.server_status.account && $scope.server_status.account.admin_level >= 15) {
          if ($scope.cfg.emu.ZonesEnabled.length <= 2) {
            $scope.shouldConfigureZones = true;
          }
        }
      });
    };

    $scope.createAdminAccount = function () {
      $scope.canCreateAdminAccount = false;
      $scope.account.admin_level = 15;
      yodaApiService.addAccount({
        account: $scope.account
      }).then(function (data) {
        if (data.response.status === "OK") {
          alert("Account " + $scope.account.username + " Created!");
        }
        $scope.messages = JSON.stringify(data.response);
        $scope.loadData();
      }).catch(function () {
        $scope.messages = "account POST failed";
      });
    };

    $scope.enableZones = function () {
      $scope.zones.tutorial = true;
      $scope.zones.tatooine = true;
      $scope.shouldConfigureZones = false;
      var z = [];
      for (var zone in $scope.zones) {
        if ($scope.zones[zone]) {
          z.push(zone);
        }
      }
      yodaApiService.updateConfig({
        config: {
          emu: {
            ZonesEnabled: z
          }
        }
      }).then(function (data) {
        if (data.response.status == "OK") {
          alert("Zones Updated");
        }
        $scope.messages = JSON.stringify(data.response);
        $scope.loadData();
      }).catch(function () {
        $scope.messages = "config PUT failed";
      });
    };

    $scope.loadData();
  }]);
});
