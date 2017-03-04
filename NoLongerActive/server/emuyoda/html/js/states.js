/**
 * Defines the main states in the application.
 * The states you see here will be anchors '#/' unless specifically configured otherwise.
 *
 */
'use strict';

define(['app', 'services'], function (app) {
  app.config(['$stateProvider', '$urlRouterProvider', '$httpProvider', function ($stateProvider, $urlRouterProvider, $httpProvider) {

    $httpProvider.interceptors.push('authInterceptor');

    $urlRouterProvider.otherwise("/home");

    var burst = '?burst=v2';

    $stateProvider

    .state('home', {
        url         : '/home',
        templateUrl : 'views/home.html' + burst,
        controller  : 'navController',
        data        : { requireLogin: false },
    })
    .state('connect', {
        url         : '/connect',
        templateUrl : 'views/connect.html' + burst,
        controller  : 'connectController',
        data        : { requireLogin: false },
    })
    .state('control', {
        url         : '/control',
        templateUrl : 'views/control.html' + burst,
        controller  : 'controlController',
        data        : { requireLogin: true },
    })
    .state('tools', {
        url         : '/tools',
        templateUrl : 'views/tools.html' + burst,
        controller  : 'toolsController',
        data        : { requireLogin: false },
    })
    .state('about', {
        url         : '/about',
        templateUrl : 'views/about.html' + burst,
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
    });
  }]);
});
