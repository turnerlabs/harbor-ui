var _ = require('underscore'),
    requestify = require('requestify'),
    config = require('./config').config,
    common = require('./common'),
    log = require('./log').log;

var exports = module.exports,
    dontAdd = _.union(['ENVIRONMENT', 'PORT', 'HEALTHCHECK', 'PROTOCOL'], config.shipit_top_level),
    topLevel = config.shipit_top_level,
    shipitUrlMap = {
        main: {url: 'v1/shipments', next: 'environment', varUrls: [{type: 'vars', url: 'v1/shipment/$PRODUCT/envVars'}]},
        environment: {url: 'v1/shipment/$PRODUCT/environments', next: 'providers', varUrls: [{type: 'vars', url: 'v1/shipment/$PRODUCT/environment/$ENV/envVars'}]},
        providers: {url: 'v1/shipment/$PRODUCT/environment/$ENV/providers', next: 'containers', varUrls: [{type: 'vars', url: 'v1/shipment/$PRODUCT/environment/$ENV/provider/$NAME/envVars'}]},
        containers: {url: 'v1/shipment/$PRODUCT/environment/$ENV/containers', next: null,
            varUrls: [{type: 'ports', url: 'v1/shipment/$PRODUCT/environment/$ENV/container/$NAME/ports'}, {type: 'vars', url: 'v1/shipment/$PRODUCT/environment/$ENV/container/$NAME/envVars'}]}
    }

exports.convertShipment = convertShipment;
exports.createShipment = createShipment;

/**
 * @public
 *
 * takes a convertedShipment object. This contains pieces of the
 * shipment that need to be created. Loop through the object and make the correct
 * api calls to shipit, to create the shipment in its entirety.
 *
 * @param {Object} shipment The shipit object
 *
 * return Promise
 */
function createShipment(shipment) {

    var username = shipment.main.username,
        token = shipment.main.token,
        errors = false;

    return new Promise((resolve, reject) => {
        var promises = [];

        return postShipitStep('main', resolve, reject)
        .then((data) => {
            return postShipitStep('environment', resolve, reject);
        })
        .then((data) => {
            promises.push(postShipitStep('providers', resolve, reject));
            promises.push(postShipitStep('containers', resolve, reject));

            Promise.all(promises)
            .then((data) => {
                return resolve({shipment: shipment, errors: errors});
            });
        });
    });


    function postShipitStep(step) {
        var url = config.shipit_url + shipitUrlMap[step].url.replace('$PRODUCT', shipment.main.name)
                                        .replace('$ENV', shipment.environment.name),
            promises = [];

        if (_.isArray(shipment[step])) {
            shipment[step].map((data) => {
                promises.push(requestify.post(url, data, {headers: {'x-username': username, 'x-token': token}}));
            });
        } else {
            promises.push(requestify.post(url, shipment[step], {headers: {'x-username': username, 'x-token': token}}));
        }

        return Promise.all(promises)
        .then((data) => {

            var envPromises = [];
            shipitUrlMap[step].varUrls.forEach((varUrl) => {
                var envUrl = varUrl.url;

                envUrl = config.shipit_url + envUrl.replace('$PRODUCT', shipment.main.name)
                                                   .replace('$ENV', shipment.environment.name);

                if (_.isArray(shipment[step])) {
                    shipment[step].map((data) => {
                        createEnvPromise(data, envUrl.replace('$NAME', data.name));
                    });
                } else {
                    createEnvPromise(shipment[step], envUrl.replace('$NAME', shipment[step].name));
                }

                function createEnvPromise(data, url) {
                    log.info('shipment creation process success', step, url, data, varUrl.type);
                    var vars = data[varUrl.type];

                    if (vars) {
                        vars.map((envVar) => {
                            log.info('shipment creation process adding ' + varUrl.type, JSON.stringify(envVar));
                            envVar.username = username;
                            envVar.token = token;
                            envPromises.push(requestify.post(url, envVar, {headers: {'x-username': username, 'x-token': token}}));
                        });
                    }
                }
            });

            return Promise.all(envPromises).then((data) => data, errorFunction);
        }, errorFunction);

        function errorFunction(error) {
            log.error(error);

            if (step === 'main') {
                return;
            }

            if (!errors) {
                errors = {};
            }

            if (!errors[step]) {
                errors[step] = [];
            }

            errors[step].push({error: error.code, body: error.getBody().error});
        }
    }
}

/**
 *
 * @public
 * converts a current deployit shipment object into a shipit object.
 *
 * This function can take a deployit object and convert it to a shipit object.
 * It can also take a shipit object and pass it back out without throwing an error.
 * It determine if its a shipit object, if shipit === falsey
 *
 *
 * @param  {Object} shipment A shipment object from Harbor UI.
 *
 * @return {Object} shipitPieces An object that contains all the pieces to create a shipit shipment.
 */
function convertShipment(shipment) {
    var shipitPieces = {},
        promise;

    shipment.main.username = shipment.username;
    shipment.main.token = shipment.token;
    promise = new Promise((resolve) => resolve(shipment));

    return promise;
}
