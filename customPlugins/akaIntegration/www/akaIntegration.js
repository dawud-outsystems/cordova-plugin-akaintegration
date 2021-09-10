var exec = require('cordova/exec');

exports.echo = function (arg0, success, error) {
    exec(success, error, 'akaIntegration', 'echo', [arg0]);
};

exports.printConfig = function (success, error) {
    exec(success, error, 'akaIntegration', 'printConfig', []);
};

exports.printCache = function (success, error) {
    exec(success, error, 'akaIntegration', 'printCache', []);
};

exports.registerSegment = function (arg0, success, error) {
    exec(success, error, 'akaIntegration', 'registerSegment', [arg0]);
};

exports.startAction = function (arg0, success, error) {
    exec(success, error, 'akaIntegration', 'startAction', [arg0]);
};

exports.stopAction = function (success, error) {
    exec(success, error, 'akaIntegration', 'stopAction', []);
};

exports.handleNotification = function (arg0, success, error) {
    exec(success, error, 'akaIntegration', 'handleNotification', [arg0]);
};
