var pkgConfig = require('../package.json'),
    fs = require('fs'),
    mustache = require('mustache'),
    CONFIG_DATA = {
        env: process.env.ENVIRONMENT || 'local',
        showDebug: process.env.SHOW_DEBUG || false,
        argonaut_url: process.env.ARGONAUT_URL || 'https://argonaut.turner.com/',
        catalogit_url: process.env.CATALOGIT_URL || 'http://catalogit.services.dmtio.net/v1/',
        trigger_url: process.env.TRIGGER_URL || 'http://trigger.services.dmtio.net/',
        helmit_url: process.env.HELMIT_URL || 'http://helmit.services.dmtio.net',
        buildit_url: process.env.BUILDIT_URL || 'http://buildit.services.dmtio.net/v1',
        shipit_url: process.env.SHIPIT_URL || 'http://shipit.services.dmtio.net',
        registry_url: process.env.REGISTRY_URL || 'http://registry.services.dmtio.net',
        blog_rss: process.env.BLOG_RSS || 'http://artifacts-east.s3.amazonaws.com/harbor/feed.xml',
        blog_url: process.env.BLOG_URL || 'http://localhost:4000/',
        data_dog_link: process.env.DATADOG_LINK || 'https://app.datadoghq.com/dash/128045/shipment-dashboard?live=true&page=0',
        alb_data_dog_link: process.env.ALB_DATADOG_LINK || 'https://app.datadoghq.com/dash/292434/shipment-dashboard-alb?live=true&page=0',
        main_logo: process.env.MAIN_LOGO || 'images/harbor-beta.png',
        cloud_health_api_key: process.env.CLOUD_HEALTH_API_KEY,
        healthcheck: process.env.HEALTHCHECK || '/_hc',
        port: process.env.PORT || '7890',
        rssTtl: process.env.RSS_TTL || 1000 * 60 * 30,
        updateInterval: process.env.UPDATE_INTERVAL || 30,
        providers: process.env.PROVIDER_LIST || 'ec2',
        default_provider: process.env.DEFAULT_PROVIDER || 'ec2',
        default_replica_int: process.env.DEFAULT_REPLICA_INT || 2,
        default_port_name: process.env.DEFAULT_PORT_NAME || 'main',
        shipit_top_level: process.env.TOP_LEVEL ? process.env.TOP_LEVEL.split(',') : ['PRODUCT', 'PROJECT', 'CUSTOMER', 'PROPERTY'],
        barges: process.env.BARGES || ',mss,cnn,nba,digital-sandbox,corp-sandbox',
        default_barge: process.env.DEFAULT_BARGE || 'mss',
        version: pkgConfig.version
    },
    FE_CONFIG_TEMPLATE = './templates/config.tpl.js';

exports.getConfigFile = getFEConfigJSFileRoute;
exports.config = CONFIG_DATA;

/** gets the config and creates a javascript file out of some template file */
function getFEConfigJSFileRoute(req, res) {
    console.log("Creating dynamic config");
    responseWithInterpolatedConfig(CONFIG_DATA, req, res);
}

/**
 * this takes in a config json, interpolates it into a template via mustache, and returns it as a javascript file
 *
 * @param  {JSON} configData the json retrieved from wherever
 * @param  {Object} req        the request object
 * @param  {Object} res        the response object
 *
 */
function responseWithInterpolatedConfig(configData, req, res) {
    fs.readFile(FE_CONFIG_TEMPLATE, 'utf8', function (err, data) {
        if (err) { throw err; }
        var tmpFile = mustache.render(data, {config: JSON.stringify(configData)});
        res.setHeader("content-type", "application/javascript");
        res.send(tmpFile);
    });
}
