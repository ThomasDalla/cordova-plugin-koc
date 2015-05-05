var cordova = require('cordova');

/**
 * KoC plugin for Cordova to communicate natively with KoC
 * @constructor
 */
function KoC () {}

/**
 * Login to KoC natively
 * @param username KoC username
 * @param password KoC password
 * @param onSuccess called on success
 * @param onFail called on failure
 */
KoC.prototype.login = function(username, password, onSuccess, onFail) {
  cordova.exec(onSuccess, onFail, "KoC", "login", [ username, password ]);
};

// Register the plugin
var koc = new KoC();
module.exports = koc;
