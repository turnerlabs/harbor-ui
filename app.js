'use strict';

if (!process.env.CLOUD_HEALTH_API_KEY || !process.env.DATADOG_API_KEY || !process.env.DATADOG_APP_KEY) {
    console.log('missing env vars');
    process.env.CLOUD_HEALTH_API_KEY || console.log('missing CLOUD_HEALTH_API_KEY');
    process.env.DATADOG_API_KEY || console.log('missing DATADOG_API_KEY');
    process.env.DATADOG_APP_KEY || console.log('missing DATADOG_APP_KEY');
    return;
}

var express = require('express'),
    path = require('path'),
    requestify = require('requestify'),
    bodyParser = require('body-parser'),
    log = require('./handlers/log').log,
    logInfo = require('./handlers/log').logInfo,
    configHandler = require('./handlers/config'),
    shipitHelper = require('./handlers/shipit'),
    commonHandler = require('./handlers/common'),
    datadogHandler = require('./handlers/datadog'),
    rssTtl = configHandler.config.rssTtl,
    port = configHandler.config.port,
    argonaut = configHandler.config.argonaut_url,
    catalogIt = configHandler.config.catalogit_url,
    shipIt = configHandler.config.shipit_url,
    registry = configHandler.config.registry,
    healthcheck = configHandler.config.healthcheck,
    url = commonHandler.url,
    app = express();

if (!global.rssCache) {
    commonHandler.fetchFeed();
    setInterval(commonHandler.fetchFeed, rssTtl);
}

app.use(function (req, res, next) {
    res.req.count = (new Date()).getTime();
    return next();
});

app.use(express.static('public'));
app.use(bodyParser.json());

app.get(healthcheck, function (req, res) {
    var pkg = require('./package.json');

    res.json({ version: pkg.version });
});

app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname, 'index.html'));
    logInfo(res);
});

app.get('/config.js', configHandler.getConfigFile);

app.get('/api/v1/auth/users', function(req, res) {
    requestify.get(url(argonaut, 'api', 'users'), {dataType: 'json'}).then(function (response) {
        res.status(response.code).json(JSON.parse(response.body));
        logInfo(res);
    }, function errorCallback(error) {
        res.status(error.code).json(error.getBody());
        logInfo(res);
    });
});

app.get('/api/v1/auth/groups/:user', function (req, res) {
    var user = req.params.user;

    requestify.get(url(argonaut, 'getUserGroups', user), {dataType: 'json'}).then(function (response) {
        // User groups come back in two arrays (groups_adminned and groups_in)
        // combine these into one array of objects {name: value, admin: boolean}
        var result = JSON.parse(response.body),
            groups = [],
            i;

        for (i = 0; i < result.groups_adminned.length; i++) {
            groups.push({
                name: result.groups_adminned[i],
                admin: true
            });
        }

        for (i = 0; i < result.groups_in.length; i++) {
            groups.push({
                name: result.groups_in[i],
                admin: false
            });
        }

        res.status(response.code).json({
            name: result.username,
            groups: groups
        });
        logInfo(res);
    }, function errorCallback(error) {
        res.status(error.code).json(error.getBody());
        logInfo(res);
    });
});

app.get('/app/v1/cloudhealth', function (req, res) {
    var path = req.query.path + '?api_key=' + configHandler.config.cloud_health_api_key;

    requestify.get(url(path)).then(function (response) {
        var now;

        res.status(response.code).json(response.getBody());

        now = (new Date()).getTime();
        log.info('%s %s HTTP/%s %s %sms', res.req.method, res.req.url, res.req.httpVersion, res.statusCode, (now - res.req.count));
    }, function errorCallback(error) {
        res.status(error.code).json(error.getBody());
        logInfo(res);
    });
});

app.get('/api/v1/container/config/:container/:version', function (req, res) {
    var container = req.params.container,
        version   = req.params.version;

    requestify.get(url(catalogIt, 'container', container, version)).then(function (response) {
        var body = response.getBody(),
            image = body.image.split('/')[1];

        requestify.get(url(registry, 'v2', image, 'manifests', version)).then(function (response) {
            var body = response.getBody(),
                config = JSON.parse(body.history[0].v1Compatibility);

            res.status(response.code).json(config.config.Env);
            logInfo(res);
        }, errorCallback);
    }, errorCallback);

    function errorCallback(error) {
        res.status(error.code).json(error.getBody());
        logInfo(res);
    }
});

app.post('/api/v1/shipments', function (req, res) {
    var name = req.body.name,
        env  = req.body.environment;

    shipitHelper.convertShipment(req.body)
    .then((data) =>  {
       console.log('converted shipment. Now saving');
       return shipitHelper.createShipment(data);
    }, errorCallback)
    .then(function (data) {
        res.status(200).json(data);
        log.info('shipment creation success');
    }, errorCallback);

    function errorCallback(error) {
        res.status(error.code).json(error.getBody());
        logInfo(res);
    };
});

app.post('/api/v1/datadog', function(req, res) {
    var data = req.body;
    log.info('creating datadog embed', req.body.title);
    datadogHandler.createEmbed(data, function(error, data) {
        if (error) {
            res.status(500).json(error);
            return;
        }

        res.json(data);
    });
});

app.get('/api/v1/blog-feed', function(req, res) {
    var rss = configHandler.config.blog_rss;

    requestify.get(rss).then(function (response) {
        res.set({
            'Content-Type': 'application/rss+xml'
        }).status(response.code).send(response.body);
        logInfo(res);
    });
});

app.listen(port, function () {
    console.log('Harbor API running on %s', port);
});
