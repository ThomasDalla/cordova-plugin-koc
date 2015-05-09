# cordova-plugin-koc
KoC plugin for Cordova, to call functions natively

## install
bower install https://github.com/ThomasDalla/cordova-plugin-koc.git --save

## use
window.cordova.koc.login( (str) username, (str) password, (func) onSuccess, (func) onError);<br>
In case of success, onSuccess is called with the response being an object with *session* key being the koc_session.
