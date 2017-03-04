"use strict";

require.config({
  urlArgs: 'bust=v2',
  paths: {
    'angular': '/lib/angular/angular',
    'angular.sanitize': '/lib/angular-sanitize/angular-sanitize.min',
    'angular.animate': '/lib/angular-animate/angular-animate.min',
    'bootstrap': '/lib/bootstrap/dist/js/bootstrap.min',
    'ui.bootstrap': '/lib/angular-bootstrap/ui-bootstrap-tpls.min',
    'ui.router': '/lib/angular-ui-router/release/angular-ui-router',
    'jquery': '/lib/jquery/dist/jquery',

    'app': '/js/app',
    'states': '/js/states',
    'controller': '/js/controllers/module',
    'services': '/js/services',
    'filters': '/js/filters',
  },
  shim: {
    'angular': { 'exports': 'angular' },
    'angular.sanitize': ['angular'],
    'angular.animate': ['angular'],
    'bootstrap': ['jquery'],
    'ui.bootstrap': ['angular', 'bootstrap'],
    'ui.router': ['angular'],

    'app': { 'exports': 'app' }
  }
});

window.name = 'NG_DEFER_BOOTSTRAP!';

require(['jquery', 'angular', 'app', 'states', 'services', 'bootstrap'], function ($, angular, app) {
  console.debug('main.js started.');
  angular.element().ready(function () {
    console.debug('main.js: start bootstrap angular.');
    angular.resumeBootstrap([app.name]);
    console.debug('main.js: end bootstrap angular.');
  });
  $(document).ready(function () {
    $('script[data-load]').each(function (index) {
      console.debug('main.js: load '.$(this).attr('data-load'));
      require([$(this).attr('data-load')]);
      console.debug('main.js: loaded '.$(this).attr('data-load'));
    });
  });
});
