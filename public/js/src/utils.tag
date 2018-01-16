/* global $ */
var utils = (function () {
    function buttonMe(btns) {
        var e;

        for (e in btns) {
            if (btns.hasOwnProperty(e)) {
                if (typeof btns[e] === 'string') {
                    $(e).button({icons: {primary: 'ui-icon-' + btns[e]}});
                } else {
                    $(e).button(btns[e]);
                }
            }
        }
    }

    function debug() {
        if (config.showDebug || self.host.indexOf('localhost') !== -1 || self.host.indexOf('10.') !== -1 || checkSearch('debug=true')) {
            arguments[0] = ']> ' + arguments[0];
            console.log.apply(console, arguments);
        }
    }

    function checkSearch(keyval) {
        return window.location.search.indexOf(keyval) !== -1
    }

    function makeUrl() {
        var args = [],
            i;

        for (i = 0; i < arguments.length; i++) {
            if (arguments[i]) {
                args.push(arguments[i]);
            }
        }

        return args.join('/');
    }

    function myFromItems(a) {
        var i = 0,
            l = a.length,
            o = {};

        while (i < l) {
            o[a[i].key] = a[i].value;
            i++;
        }

        return o;
    }

    function myToItems(o) {
        var a = [],
            e;

        for (e in o) {
            a.push({key: e, value: o[e]});
        }

        return a;
    }

    function versionClass(val, out) {
        out = out || '';

        if (val > 0) {
            out += 'ahead';
        } else if (val < 0) {
            out += 'behind';
        } else {
            out += 'same';
        }

        return out;
    }

    function sortOn(val) {
        return function (a, b) {
            if (a[val] > b[val]) {
                return 1;
            }
            else if (a[val] < b[val]) {
                return -1;
            }
            else {
                return 0;
            }
        };
    }

    /**
     * Attempt to cast the pieces of semver into Number
     * if not able to cast them, leave as String
     * Do this before comparing the items for sorting
     */
    function versionCast(arr) {
        var i, len, tmp;

        arr.shift();

        len = arr.length;

        for (i = 0; i < len; i++) {
            tmp = Number(arr[i]);

            if (tmp !== NaN) {
                arr[i] = tmp;
            }
        }

        return arr;
    }

    function getAllParts(parts) {
        var all_parts = [],
            new_parts;
        for(var i = 0;i < parts.length;i++) {
            new_parts = parts[i].split('-');
            for (var x = 0;x < new_parts.length;x++) {
                all_parts.push(new_parts[x]);
            }
        }

        return all_parts;
    }

    var numeric = /^[0-9]+$/;
    function versionCompare(v1, v2) {

        if (!v1.version || !v2.version) {
            return 1;
        }

        var v1parts = getAllParts(v1.version.split('.'));
        var v2parts = getAllParts(v2.version.split('.'));

        for (var i = 0; i < v1parts.length; ++i) {
            if (v2parts.length == i) {
                return 1;
            }

            var compare = partCompare(v1parts[i], v2parts[i]);

            if (compare === 0) {
                continue;
            } else {
                return compare;
            }
        }

        if (v1parts.length < v2parts.length) {
            return -1;
        }

        return 0;
    }

    // source https://github.com/npm/node-semver/blob/master/semver.js#L528
    function partCompare(a, b) {
      var anum = numeric.test(a);
      var bnum = numeric.test(b);

      if (anum && bnum) {
        a = +a;
        b = +b;
      }

      return (!anum && !bnum) ? 0 :
             (anum && !bnum)  ? 1 :
             (bnum && !anum)  ? -1 :
             a < b ? 1 :
             a > b ? -1 :
             0;
    }

    function formatArr(arr, offset) {
        var idx = 0,
            len = arr.length,
            out = [];

        offset = offset || '';

        out.push('[\n');
        while (idx < len) {
            out.push('  ');
            out.push(formatObj(arr[idx], offset));
            out.push('\n');
            idx++;
        }
        out.push(']');

        return out.join('');
    }

    function formatObj(obj, offset) {
        var out = [],
            prop;

        offset = offset || '';

        out.push('{\n');
        for (prop in obj) {
            if (obj.hasOwnProperty(prop)) {
                out.push('  ' + prop + ': ');
                if (Array.isArray(obj[prop])) {
                    out.push(formatArr(obj[prop]));
                } else if (obj[prop] === null) {
                    out.push('null');
                } else if (obj[prop] === undefined) {
                    out.push('undefined');
                } else if (obj[prop] === 'object') {
                    out.push(formatObj(obj[prop], '  '));
                } else {
                    out.push(obj[prop].toString());
                }
                out.push('\n');
            }
        }
        out.push('}');

        return out.join('');
    }

    function stringify(val) {
        var out;

        if (val === null) {
            val = '&nbsp;';
        } else if (val === undefined) {
            val = '<em>undefined</em>';
        } else if (Array.isArray(val)) {
            val = '<pre>' + formatArr(val, '') + '</pre>';
        } else if (typeof val === 'object') {
            val = '<pre>' + formatObj(val, '') + '</pre>';
        }

        val = val || '!!not found!!';

        return val;
    }

    function showError(msg) {
        RiotControl.trigger('flash_message', 'error', msg);
    }

    function logFormat(entries) {
        var from,
            to,
            e,
            i;

        for (i = 0; i < entries.length; i++) {
            entries[i].changed = [];
            from = entries[i].changed_from;
            to   = entries[i].changed_to;

            for (e in from) {
                if (from.hasOwnProperty(e)) {
                    entries[i].changed.push({
                        name: e,
                        from: stringify(from[e]),
                        to: stringify(to[e])
                    });
                }
            }
        }

        return entries;
    }

    /**
     * sort an array of replicas by container ids
     */
    function sortContainers(a, b) {
        return a.id < b.id ? -1 : 1;
    }

    /**
     * sort an array of replicas by provider name
     */
    function sortReplicas(a, b) {
        return a.host < b.host ? -1 : 1;
    }

    /**
     * scrolls a textarea to the bottom
     *
     * @param {Element} element The element to scroll
     * @param {Boolean} tail If True then tail
     *
     */
    function tailTextarea(elements) {
        $.each(elements, function (i, ele) {
            var foo = autosize.update($(ele));
            ele.scrollTop = ele.scrollHeight;
        });
    }

    function setupTextarea(elements) {
        $.each(elements, function (i, ele) {
            autosize($(ele));
            ele.scrollTop = ele.scrollHeight;
        });
    }

    /**
     * sets port values as environment variables
     *
     * @param {Object} container The container object to check against
     * @param {Array} list The array of objects to push if port was not found
     *
     * @return {Object} tells us if we should save, and what to save
     */
    function setPorts(container, list, save) {
        var shouldSave = {save: false, list: []};

        container.ports.forEach(function(port) {
            var hasPort = false,
                hasHealthcheck = false,
                portName = port.name.toUpperCase();

            port.value = parseInt(port.value);

            if (port.public_port) {
               port.public_port = parseInt(port.public_port);
            }

            list.forEach(function(envVar, i) {
                if (envVar.name.toUpperCase() === portName) {
                    hasPort = true;

                    if (parseInt(envVar.value) !== port.value) {
                        // make sure they are always in sync
                        envVar.value = port.value + '';
                        shouldSave.save = true;
                        envVar.add = false;
                        shouldSave.list.push(envVar);
                    }
                }

                if (envVar.name === 'HEALTHCHECK') {
                    hasHealthcheck = true;

                    if (port.primary === true && port.healthcheck !== envVar.value) {
                        port.healthcheck = port.healthcheck || '/changeMe';
                        envVar.value = port.healthcheck;
                        envVar.add = false;
                        shouldSave.save = true;
                        shouldSave.list.push(envVar);
                    } else if (port.primary === false){
                        port.healthcheck = "";
                    }
                }
            });

            if (hasHealthcheck === false && port.primary === true) {
                var envVarHC = {name: 'HEALTHCHECK', value: port.healthcheck, type: 'basic'};
                envVarHC.add = true;
                shouldSave.save = true;
                shouldSave.list.push(envVarHC);
                list.push(envVarHC);
            }
        });

        return shouldSave;
    }

    function convertShipment(shipment) {
        var newShipment = {};
        newShipment.main = {
            name: shipment.parentShipment.name,
            vars: shipment.parentShipment.envVars,
            group: shipment.parentShipment.group
        };
        newShipment.environment = {
            name: shipment.name,
            vars: shipment.envVars
        };
        newShipment.containers = shipment.containers.map(function(container) {
            return {
                name: container.name,
                image: container.image,
                ports: container.ports,
                version: container.version,
                vars: container.envVars
            }
        });
        newShipment.providers = shipment.providers.map(function(provider) {
            return {
                name: provider.name,
                replicas: provider.replicas,
                barge: provider.barge,
                vars: provider.envVars
            }
        });
        return newShipment;
    }

    function getDefaultPort() {
        var min = 1025,
            max = 65535;

        return Math.floor(Math.random() * (max - min + 1) + min);
    }

    function getDefaultBarge(defaultBarge, group, barges) {
        var barges = barges.split(',');

        for (var i = 1;i < barges.length;i++) {
            if (group === barges[i]) {
                return barges[i];
            }
        }

        return defaultBarge;
    }

    function getBarge(shipment) {

        if (!shipment) {
            return;
        }

        var barge;

        for (var i = 0; i < shipment.providers.length; i++) {
            barge = shipment.providers[i].barge;
        }

        return barge;
    }

    function setEnvVars(envVars, vars) {
        for (var i = 0;i < vars.length;i++) {
            envVars[vars[i].name] = vars[i].value;
        }
        return envVars;
    }

    return {
        buttonMe: buttonMe,
        debug: debug,
        logFormat: logFormat,
        makeUrl: makeUrl,
        showError: showError,
        sortOn: sortOn,
        myFromItems: myFromItems,
        myToItems: myToItems,
        versionClass: versionClass,
        versionCompare: versionCompare,
        sortReplicas: sortReplicas,
        sortContainers: sortContainers,
        tailTextarea: tailTextarea,
        setupTextarea: setupTextarea,
        setPorts: setPorts,
        convertShipment: convertShipment,
        getDefaultPort: getDefaultPort,
        getDefaultBarge: getDefaultBarge,
        getBarge: getBarge
    };
})();

String.prototype.toTitleCase = function toTitleCase() {
    var self = this,
        pieces = self.split(' '),
        first,
        rest,
        i;

    for (i = 0; i < pieces.length; i++) {
        first = pieces[i].substr(0, 1);
        rest  = pieces[i].substr(1);

        pieces[i] = first.toUpperCase() + rest.toLowerCase();
    }

    return pieces.join(' ');
};

if (!Array.prototype.find) {
  Array.prototype.find = function(predicate) {
    if (this === null) {
      throw new TypeError('Array.prototype.find called on null or undefined');
    }
    if (typeof predicate !== 'function') {
      throw new TypeError('predicate must be a function');
    }
    var list = Object(this);
    var length = list.length >>> 0;
    var thisArg = arguments[1];
    var value;

    for (var i = 0; i < length; i++) {
      value = list[i];
      if (predicate.call(thisArg, value, i, list)) {
        return value;
      }
    }
    return undefined;
  };
}
