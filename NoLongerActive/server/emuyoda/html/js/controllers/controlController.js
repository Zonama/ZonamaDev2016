"use strict";

define(["./module"], function (controllers) {
  controllers.controller("controlController", ["$rootScope", "$scope", "$timeout", "$location", "yodaApiService", function ($rootScope, $scope, $timeout, $location, yodaApiService) {
    $scope.pendingCmd = "";
    $scope.pendingSend = false;
    $scope.sendText = "";
    $scope.autostart_server = false;

    $scope.updateStatus = function () {
      yodaApiService.getStatus().then(function (data) {
        $scope.server_status = data.response.server_status;
      }).catch(function () {
        $scope.error = "/api/status call failed";
      });
    };

    $scope.updateServerOptions = function () {
      console.log("updateServerOptions: $scope.autostart_server = " + $scope.autostart_server);
      var newcfg = {
        config: {
          yoda: {
            flags: {
              autostart_server: $scope.autostart_server
            }
          }
        }
      };
      console.log("updateServerOptions: newcfg = " + JSON.stringify(newcfg));
      yodaApiService.putConfig(newcfg).then(function (data) {
        if (data.response.error) {
          $scope.consoleAppend("update server options>> ERROR: " + data.response.error_description, "danger");
        } else {
          $scope.consoleAppend("update server options>> Set autostart_server to " + newcfg.config.yoda.flags.autostart_server, "success");
        }
      }).catch(function () {
        console.log("/api/config call failed");
      });
    };

    $scope.consoleAppend = function (text, className) {
      var e = document.getElementById("logPre");
      if (e) {
        var lines = text.split("\n");
        for (var i in lines) {
          var s = document.createElement("span");
          if (!className) {
            className = "white";
          }
          s.className = "consoleText label-" + className;
          s.appendChild(document.createTextNode(lines[i]));
          e.appendChild(s);
          e.appendChild(document.createElement("br"));
        }
        e.scrollTop = e.scrollHeight;
      }
    };

    $scope.serverCommand = function (cmd) {
      if (cmd == "send") {
        if ($scope.pendingSend) {
          $scope.pendingSend = false;
          if ($scope.sendText === "") {
            $scope.consoleAppend("Missing text to send", "danger");
            return;
          }
          cmd = cmd + "&arg1=" + $scope.sendText;
        } else {
          $scope.pendingSend = true;
          return;
        }
      }
      if ($scope.pendingCmd !== "") {
        $scope.consoleAppend("Waiting for " + $scope.pendingCmd + " to complete.", "danger");
        return;
      }
      $scope.pendingCmd = cmd;
      if (cmd != "status") {
        var auth = "none";
        if ($rootScope.authToken) {
          auth = $rootScope.authToken;
        }
        var proto = $location.protocol() == "https" ? "wss://" : "ws://";
        $scope.ws_cmd = new WebSocket(proto + $location.host() + ":" + $location.port() + "/api/control?websocket=1&command=" + cmd + "&token=" + auth);
        $scope.ws_cmd.onmessage = function (e) {
          var data = JSON.parse(e.data);
          if (data) {
            var r = data.response;
            if (r.status == "OK" || r.status == "CONTINUE") {
              $scope.consoleAppend(cmd + ">> " + r.output, "success");
            }
            if (r.error) {
              $scope.consoleAppend(cmd + ">> ERROR: " + r.error_description, "danger");
            }
          } else {
            $scope.consoleAppend(cmd + ">> ERROR: UNEXPECTED RESPONSE FORMAT: " + e.data, "danger");
          }
        };
        $scope.ws_cmd.onclose = function () {
          $scope.pendingCmd = "";
          $scope.consoleAppend(cmd + ">> [Command Complete]", "success");
          var tmp_ws = $scope.ws_cmd;
          delete $scope.ws_cmd;
          tmp_ws.close();
        };
      } else {
        yodaApiService.serverCommand(cmd).then(function (data) {
          if (data.response.output) {
            $scope.consoleAppend(cmd + ">> " + data.response.output.replace(/\n$/, ""), "success");
          } else {
            $scope.consoleAppend(cmd + ">> ERROR: " + data.response.error_description, "danger");
          }
          $scope.pendingCmd = "";
          $scope.updateStatus();
        }).catch(function () {
          $scope.consoleAppend(cmd + ">> ERROR: API Call Failure.", "danger");
          $scope.pendingCmd = "";
          $scope.updateStatus();
        });
      }
    };

    if (!$scope.ws) {
      var auth = "none";
      if ($rootScope.authToken) {
        auth = $rootScope.authToken;
      }
      var proto = $location.protocol() == "https" ? "wss://" : "ws://";
      $scope.ws = new WebSocket(proto + $location.host() + ":" + $location.port() + "/api/console?token=" + auth);
      $scope.ws.onmessage = function (e) {
        var data = JSON.parse(e.data);
        if (data) {
          var r = data.response;
          if (r.channel == "SERVER_STATUS" && r.output !== "" || r.channel == "CONSOLE" && (r.status == "OK" || r.status == "CONTINUE")) {
            if (r.server_pid) {
              $scope.consoleAppend("Core3[" + r.server_pid + "]>> " + r.output);
            } else {
              $scope.consoleAppend("Core3[not-running]>> " + r.output);
            }
          }
          if (r.error) {
            $scope.consoleAppend(">> ERROR: " + r.error_description, "danger");
          }
          if (r.server_status) {
            $scope.server_status = r.server_status;
            $scope.$apply();
          }
        } else {
          $scope.consoleAppend(">> ERROR: UNEXPECTED RESPONSE FORMAT: " + e.data, "danger");
        }
      };
      $scope.ws.onopen = function () {
        $scope.consoleAppend("[Console channel connected to server]");
      };
      $scope.ws.onclose = function () {
        $scope.consoleAppend("[Console channel closed by server]");
        var tmp_ws = $scope.ws;
        delete $scope.ws;
        tmp_ws.close();
      };
    }

    $scope.updateStatus();

    yodaApiService.getConfig().then(function (data) {
      $scope.cfg = data.response.config;
      if (data.response.error) {
        console.log($scope.messages);
        $scope.autostart_server = false;
      } else {
        if ($scope.cfg && $scope.cfg.yoda && $scope.cfg.yoda.flags && $scope.cfg.yoda.flags.autostart_server) {
          $scope.autostart_server = $scope.cfg.yoda.flags.autostart_server;
        } else {
          $scope.autostart_server = false;
        }
      }
    }).catch(function () {
      console.log("/api/config call failed");
    });
  }]);
});
