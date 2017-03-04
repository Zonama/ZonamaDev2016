/**
 * Attach controllers to this module
 * if you get 'unknown {x}Provider' errors from angular, be sure they are
 * properly referenced in one of the module dependencies in the array.
 **/
'use strict';

define(['angular'], function (angular) {
  return angular.module('app.controllers', ['ui.router']);
});
