var _getCallbackId = function () {
    var ramdom = parseInt(Math.random() * 100000);
    return 'iCallback_' + new Date().getTime() + ramdom;
}


var _sendTpRequest = function (methodName, params, callbackId) {
    // if Android
    if (window.JsNativeBridge) {
        window.JsNativeBridge.callHandler(methodName, params, callbackId);
    }
    
    // if iOS
    if (window.webkit) {
        window.webkit.messageHandlers[methodName].postMessage({
                                                              body: {
                                                              'params': params,
                                                              'callback': callbackId
                                                              }
                                                              });
    }
}

var donut = {
isConnected: function () {
    return !!(window.JsNativeBridge || (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.getDeviceId));
},
getAppInfo: function () {
    return new Promise(function (resolve, reject) {
                       var callbackId = _getCallbackId();
                       
                       window[callbackId] = function (result) {
                       result = result.replace(/\r/ig, "").replace(/\n/ig, "");
                       try {
                       var res = JSON.parse(result);
                       resolve(res);
                       } catch (e) {
                       reject(e);
                       }
                       }
                       _sendTpRequest('getAppInfo', '', callbackId);
                       
                       });
},
getDeviceId: function () {
    return new Promise(function (resolve, reject) {
                       var callbackId = _getCallbackId();
                       
                       window[callbackId] = function (result) {
                       result = result.replace(/\r/ig, "").replace(/\n/ig, "");
                       try {
                       var res = JSON.parse(result);
                       resolve(res);
                       } catch (e) {
                       resolve(result);
                       }
                       }
                       
                       _sendTpRequest('getDeviceId', '', callbackId);
                       
                       });
    
},
getWallets: function () {
    return new Promise(function (resolve, reject) {
                       var callbackId = _getCallbackId();
                       
                       window[callbackId] = function (result) {
                       result = result.replace(/\r/ig, "").replace(/\n/ig, "");
                       try {
                       var res = JSON.parse(result);
                       resolve(res);
                       } catch (e) {
                       reject(e);
                       }
                       }
                       
                       _sendTpRequest('getWallets', '', callbackId);
                       
                       });
},
getCurrentWallet: function () {
    return new Promise(function (resolve, reject) {
                       var callbackId = _getCallbackId();
                       
                       window[callbackId] = function (result) {
                       result = result.replace(/\r/ig, "").replace(/\n/ig, "");
                       try {
                       var res = JSON.parse(result);
                       resolve(res);
                       } catch (e) {
                       reject(e);
                       }
                       }
                       _sendTpRequest('getCurrentWallet', '', callbackId);
                       });
},
sign: function (params) {
    
    return new Promise(function (resolve, reject) {
                       var callbackId = _getCallbackId();
                       
                       window[callbackId] = function (result) {
                       result = result.replace(/\r/ig, "").replace(/\n/ig, "");
                       try {
                       var res = JSON.parse(result);
                       resolve(res);
                       } catch (e) {
                       reject(e);
                       }
                       }
                       
                       _sendTpRequest('sign', JSON.stringify(params), callbackId);
                       });
},
transfer: function (params) {
    
    return new Promise(function (resolve, reject) {
                       var callbackId = _getCallbackId();
                       
                       window[callbackId] = function (result) {
                       result = result.replace(/\r/ig, "").replace(/\n/ig, "");
                       try {
                       var res = JSON.parse(result);
                       resolve(res);
                       } catch (e) {
                       reject(e);
                       }
                       }
                       
                       _sendTpRequest('transfer', JSON.stringify(params), callbackId);
                       });
},
invokeQRScanner: function () {
    return new Promise(function (resolve, reject) {
                       var callbackId = _getCallbackId();
                       
                       window[callbackId] = function (result) {
                       result = result.replace(/\r/ig, "").replace(/\n/ig, "");
                       try {
                       var res = JSON.parse(result);
                       resolve(res);
                       } catch (e) {
                       resolve(result);
                       }
                       }
                       
                       _sendTpRequest('invokeQRScanner', '', callbackId);
                       
                       });
},
back: function () {
    _sendTpRequest('back', '', '');
},
fullScreen: function (params) {
    _sendTpRequest('fullScreen', JSON.stringify(params), '');
},
close: function () {
    _sendTpRequest('close', '', '');
},
shareToSNS: function (params) {
    return new Promise(function (resolve, reject) {
                       var callbackId = _getCallbackId();
                       
                       window[callbackId] = function (result) {
                       result = result.replace(/\r/ig, "").replace(/\n/ig, "");
                       try {
                       var res = JSON.parse(result);
                       resolve(res);
                       } catch (e) {
                       resolve(result);
                       }
                       }
                       
                       _sendTpRequest('shareToSNS', JSON.stringify(params), callbackId);
                       
                       });
},
};


module.exports = donut;
