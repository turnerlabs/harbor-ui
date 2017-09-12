(function ArgoAuth(window) {

    'use strict';

    var argo = {},
        hostArray = window.location.hostname.split('.'),
        HOST = '',
        AUTH_USER = 'argo_username',
        AUTH_TOKEN = 'argo_token',
        AUTHURL = window.config.AUTHN_URL;

    HOST = HOST[0] !== 'localhost' ? hostArray.pop() : '';
    HOST += hostArray.length ? '.' + hostArray.pop() : '';

    function login(username, password, callback) {

        jQuery.ajax({
            type: 'POST',
            url: AUTHURL + '/v1/auth/gettoken',
            data: JSON.stringify({username: username, password: password}),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            success: function store(data) {

                if (data.success) {
                    $.cookie(AUTH_USER, username);
                    $.cookie(AUTH_TOKEN, data.token);
                }

                if (callback) {
                    callback(data);
                }
            },
            error: function(data) {
                callback(JSON.parse(data.responseText));
            }
        });
    }

    function logout(callback) {
        var authUser = $.cookie(AUTH_USER),
            authToken = $.cookie(AUTH_TOKEN);

        if (authUser && authToken) {
            jQuery.ajax({
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                url: AUTHURL + '/v1/auth/destroytoken',
                data: JSON.stringify({token: authToken, username: authUser}),
                success: function (data) {

                    if (data.success) {
                        $.removeCookie(AUTH_USER);
                        $.removeCookie(AUTH_TOKEN);
                    }

                    callback(data);
                },
                error: function(data) {
                    callback(JSON.parse(data.responseText));
                }
            });
        }

    }

    function isAuthenticated(callback) {

        var authUser = $.cookie(AUTH_USER),
            authToken = $.cookie(AUTH_TOKEN);

        if (authUser && authToken) {

            // check if still authed with current token
            jQuery.ajax({
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                url: AUTHURL + '/v1/auth/checktoken',
                data: JSON.stringify({token: authToken, username: authUser}),
                success: function(data) {
                    callback(data);
                },
                error: function(data) {
                    callback(JSON.parse(data.responseText))
                }
            });
        } else {
            callback({success: false});
        }

    }

    function getUser() {
        return $.cookie(AUTH_USER);
    }

    function getToken() {
        return $.cookie(AUTH_TOKEN);
    }

    argo.login = login;
    argo.logout = logout;
    argo.isAuthenticated = isAuthenticated;
    argo.getUser = getUser;
    argo.getToken = getToken;

    window.ArgoAuth = argo;

})(window);
