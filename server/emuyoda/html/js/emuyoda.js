/*
 * emuyoda.js - AngularJS Application to interface with YodaAPI on server
 *
 * Author: Lord Kator <lordkator@swgemu.com>
 *
 * Created: Sat Jan 16 07:28:29 EST 2016
 */
var emuYodaApp = angular.module('emuYoda', ['ui.router', 'ngSanitize', 'ngAnimate', 'ui.bootstrap']);

emuYodaApp.factory('yodaApiService', function($rootScope, $http) {
    var authenticateUser = function(username, password) {
	return $http.post("/api/auth", { auth: { username: username, password: password } }).then(function(r) {
	    if(r.data.response.token) {
		$rootScope.currentUsername = username;
		$rootScope.authToken = r.data.response.token;
	    } else {
		delete $rootScope.currentUsername;
		delete $rootScope.authToken;
	    }

	    return r.data;
	}).catch(function() {
	    delete $rootScope.currentUsername;
	    delete $rootScope.authToken;
	});
    };

    var getConfig = function() {
	return $http.get("/api/config").then(function(response) {
	    return response.data;
	});
    };

    var updateConfig = function(config) {
	return $http.put("/api/config", config).then(function(response) {
	    return response.data;
	});
    };

    var getStatus = function() {
	return $http.get("/api/status").then(function(response) {
	    return response.data;
	});
    };

    var serverCommand = function(cmd) {
	return $http.get("/api/control?command=" + cmd).then(function(response) {
	    return response.data;
	});
    };

    var getAccount = function() {
	return $http.get("/api/account").then(function(response) {
	    return response.data;
	});
    };

    var addAccount = function(account) {
	return $http.post("/api/account", account).then(function(response) {
	    return response.data;
	});
    };

    return {
	authenticateUser: authenticateUser,
	addAccount: addAccount,
	getAccount: getAccount,
	getConfig: getConfig,
	getStatus: getStatus,
	serverCommand: serverCommand,
	updateConfig: updateConfig,
    };
});

emuYodaApp.factory('authInterceptor', function ($rootScope, $q, $window) {
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
});

emuYodaApp.config(function($stateProvider, $urlRouterProvider, $httpProvider) {
    $httpProvider.interceptors.push('authInterceptor');

    $urlRouterProvider.otherwise("/home");

    $stateProvider

    .state('home', {
	url         : '/home',
	templateUrl : 'pages/home.html',
	controller  : 'mainController',
	data        : { requireLogin: false },
    })
    .state('connect', {
	url         : '/connect',
	templateUrl : 'pages/connect.html',
	controller  : 'connectController',
	data        : { requireLogin: false },
    })
    .state('control', {
	url         : '/control',
	templateUrl : 'pages/control.html',
	controller  : 'controlController',
	data        : { requireLogin: true },
    })
    .state('about', {
	url         : '/about',
	templateUrl : 'pages/about.html',
	data        : { requireLogin: false },
    })
    .state('login', {
	url         : '/login',
	data        : { requireLogin: true },
	controller  : function($state) {
	    $state.go("home");
        }
    })
    .state('logout', {
	url         : '/logout',
	data        : { requireLogin: true },
	controller  : function($state, $rootScope) {
	    delete $rootScope.currentUsername;
	    delete $rootScope.authToken;
	    $state.go("home");
        }
    })
    ;

});

emuYodaApp.controller('mainController', function($scope, $q, $location, yodaApiService) {
    $scope.cfg = {};
    $scope.server_status = {};
    $scope.account = {};
    $scope.zones = {};
    $scope.canCreateAdminAccount = false;
    $scope.shouldConfigureZones = false;

    $scope.isActive = function(viewLocation) { return viewLocation === $location.path(); }

    $scope.loadData = function() {
	$scope.canCreateAdminAccount = false;
	$scope.shouldConfigureZones = false;

	$q.all([
	    yodaApiService.getConfig().then(function(data) {
		$scope.cfg = data.response.config;
		$scope.messages = "";

		if (data.response.error) {
		    $scope.messages = "API CALL TO " + data.response.service + " FAILED WITH ERROR: " + data.response.error;
		}

		$scope.cfg.emu.ZonesEnabled.forEach( function(zone) {
		    $scope.zones[zone] = true;
		});
	    }).catch(function() {
		$scope.error = "/api/config call failed";
	    })
	,
	    yodaApiService.getStatus().then(function(data) {
		$scope.server_status = data.response.server_status;
	    }).catch(function() {
		$scope.error = "/api/status call failed";
	    })
    	]).then(function() {
	    if($scope.server_status.num_accounts == 0 && $scope.server_status.account && $scope.server_status.account.admin_level >= 15) {
		$scope.canCreateAdminAccount = true;
		$scope.shouldConfigureZones = false;
	    }

	    if($scope.server_status.num_accounts == 1 && $scope.server_status.account && $scope.server_status.account.admin_level >= 15) {
		if($scope.cfg.emu.ZonesEnabled.length <= 2) {
		    $scope.shouldConfigureZones = true;
		}
	    }
	});
    }

    $scope.createAdminAccount = function() {
	$scope.canCreateAdminAccount = false;
	$scope.account.admin_level = 15;
	yodaApiService.addAccount({ account: $scope.account }).then(function(data) {
	    if(data.response.status == "OK") {
		alert("Account " + $scope.account.username + " Created!");
	    }
	    $scope.messages = JSON.stringify(data.response);
	    $scope.loadData();
	}).catch(function() {
	    $scope.messages = "account POST failed";
	})
    }

    $scope.enableZones = function() {
	$scope.zones['tutorial'] = true;
	$scope.zones['tatooine'] = true;
	$scope.shouldConfigureZones = false;

	var z = [ ];

	for(zone in $scope.zones) {
	    if($scope.zones[zone]) {
		z.push(zone);
	    }
	}

	yodaApiService.updateConfig({ config: { emu: { ZonesEnabled: z } } }).then(function(data) {
	    if(data.response.status == "OK") {
		alert("Zones Updated");
	    }
	    $scope.messages = JSON.stringify(data.response);
	    $scope.loadData();
	}).catch(function() {
	    $scope.messages = "config PUT failed";
	})
    }

    $scope.loadData();
});

emuYodaApp.controller('connectController', function($scope, yodaApiService) {
    yodaApiService.getStatus().then(function(data) {
	$scope.server_status = data.response.server_status;
    }).catch(function() {
	$scope.error = "/api/status call failed";
    });
});

emuYodaApp.controller('controlController', function($rootScope, $scope, $timeout, $location, yodaApiService) {
    $scope.pendingCmd = "";
    $scope.pendingSend = false;
    $scope.sendText = "";

    $scope.updateStatus = function() {
	yodaApiService.getStatus().then(function(data) {
	    $scope.server_status = data.response.server_status;
	}).catch(function() {
	    $scope.error = "/api/status call failed";
	});
    };

    $scope.consoleAppend = function(text, className) {
	// TODO has to be a more AngularJS way to do this...
	var e = document.getElementById('logPre');

	if(e) {
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
	} else {
	    console.log("consoleAppend: Failed to find element (logPre): ln=" + ln);
	}
    };

    $scope.serverCommand = function(cmd) {
	if(cmd == "send") {
	    if($scope.pendingSend) {
		$scope.pendingSend = false;
		if($scope.sendText == "") {
		    $scope.consoleAppend("Missing text to send", "danger");
		    return;
		}
		cmd = cmd + "&arg1=" + $scope.sendText;
	    } else {
		$scope.pendingSend = true;
		return;
	    }
	}

	if($scope.pendingCmd != "") {
	    $scope.consoleAppend("Waiting for " + $scope.pendingCmd + " to complete.", "danger");
	    return;
	}

	$scope.pendingCmd = cmd;

	if(cmd != "status") {
	    var auth = "none";

	    //Add timestamp to console output
		var dtDate = new Date();
		var hours = dtDate.getHours();
		var minutes = dtDate.getMinutes();
		var seconds = dtDate.getSeconds();
  		hours = hours < 10 ? '0'+hours : hours; // hours before 10:00:00 add leading zero
  		minutes = minutes < 10 ? '0'+minutes : minutes; //minutes before 00:10:00 add leading zero
  		seconds = seconds < 10 ? '0'+seconds : seconds; //seconds before 00:00:10 add leading zero
		var timeStr = hours + ":" + minutes + ":" + seconds + " ";
	//End of timestamp creation. timeStr added below in consoleAppend statements

	    if ($rootScope.authToken) {
		auth = $rootScope.authToken;
	    }

	    var proto = $location.protocol() == "https" ? 'wss://' : 'ws://';

	    $scope.ws_cmd = new WebSocket(proto + $location.host() + ':' + $location.port() + '/api/control?websocket=1&command=' + cmd + '&token=' + auth);

	    $scope.ws_cmd.onmessage = function (e) {
		var data = JSON.parse(e.data);

		if(data) {
		    var r = data.response;

		    if (r.status == "OK" || r.status == "CONTINUE") {
			$scope.consoleAppend(timeStr + cmd + ">> " + r.output, "success");
		    } if (r.error) {
			$scope.consoleAppend(timeStr + cmd + ">> ERROR: " + r.error_description, "danger");
		    }
		} else {
		    $scope.consoleAppend(timeStr + cmd + ">> ERROR: UNEXPECTED RESPONSE FORMAT: " + e.data, "danger");
		}
	    };

	    $scope.ws_cmd.onclose = function () {
		$scope.pendingCmd = "";
		$scope.consoleAppend(timeStr + cmd + ">> [Command Complete]", "success");
		var tmp_ws = $scope.ws_cmd;
		delete $scope.ws_cmd;
		tmp_ws.close();
	    };
	} else {

	//Add timestamp to console output
		var dtDate = new Date();
		var hours = dtDate.getHours();
		var minutes = dtDate.getMinutes();
		var seconds = dtDate.getSeconds();
  		hours = hours < 10 ? '0'+hours : hours; // hours before 10:00:00 add leading zero
  		minutes = minutes < 10 ? '0'+minutes : minutes; //minutes before 00:10:00 add leading zero
  		seconds = seconds < 10 ? '0'+seconds : seconds; //seconds before 00:00:10 add leading zero
		var timeStr = hours + ':' + minutes + ":" + seconds + " ";
	//End of timestamp creation. timeStr added below in consoleAppend statements

	    yodaApiService.serverCommand(cmd).then(function(data) {
		if (data.response.output) {
		    $scope.consoleAppend(timeStr + cmd + ">> " + data.response.output.replace(/\n$/, ""), "success");
		} else {
		    $scope.consoleAppend(timeStr + cmd + ">> ERROR: " + data.response.error_description, "danger");
		}
		$scope.pendingCmd = "";
		$scope.updateStatus();
	    }).catch(function() {
		$scope.consoleAppend(timeStr + cmd + ">> ERROR: API Call Failure.", "danger");
		$scope.pendingCmd = "";
		$scope.updateStatus();
	    });
	}
    }

    if(!$scope.ws) {
        var auth = "none";

	if ($rootScope.authToken) {
	    auth = $rootScope.authToken;
	}

	var proto = $location.protocol() == "https" ? 'wss://' : 'ws://';

	$scope.ws = new WebSocket(proto + $location.host() + ':' + $location.port() + '/api/console?token=' + auth);

	$scope.ws.onmessage = function (e) {
	    $scope.consoleAppend(e.data);

	    if ($scope.server_status && !$scope.server_status.server_pid) {
		$scope.updateStatus();
	    }
	};

	$scope.ws.onopen = function () {
	    $scope.consoleAppend("[Console Channel Connected]");
	};

	$scope.ws.onclose = function () {
	    $scope.consoleAppend("[Console Channel Closed]");
	    var tmp_ws = $scope.ws;
	    delete $scope.ws;
	    tmp_ws.close();
	};
    }

    $scope.updateStatus();
});

// Login Handling
emuYodaApp.service('loginModalService', function($rootScope, $uibModal, yodaApiService) {
    var openModal = function() {
	return $uibModal.open({
	    animation: true,
	    templateUrl: 'views/loginModalTemplate.html',
	    controller: 'loginModalController',
	    size: "sm"
	}).result.then(function(auth) {
	    $rootScope.currentUsername = auth.username;
	    yodaApiService.authenticateUser(auth.username, auth.password);
	    return auth.username;
	});
    };

    return {
	openModal: openModal
    };
})

emuYodaApp.controller('loginModalController', function ($scope, $uibModalInstance) {
    $scope.username = '';
    $scope.password = '';

    $scope.ok = function() {
	$uibModalInstance.close({ username: $scope.username, password: $scope.password });
    };

    $scope.cancel = function() {
	$uibModalInstance.dismiss('cancel');
    }
});

emuYodaApp.run(function ($rootScope, $state, $templateCache, loginModalService) {
  // Causes http://127.0.0.1:44480/uib/template/modal/window.html 404
  // $rootScope.$on('$viewContentLoaded', function() { $templateCache.removeAll(); });
  $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {
    var requireLogin = toState.data.requireLogin;

    if (requireLogin && typeof $rootScope.currentUsername === 'undefined') {
      event.preventDefault();

      loginModalService.openModal().then(function () {
	  return $state.go(toState.name, toParams);
      }).catch(function () {
          return $state.go('home');
      });
    }
  });
});
