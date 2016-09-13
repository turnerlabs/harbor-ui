var config  = require('./config').config,
    requestify = require('requestify'),
    log = require('./log').log,
    exports = module.exports;

exports.url = url;
exports.fetchFeed = fetchRssFeed;

function url() {
    var args = [],
        i;

    for (i = 0; i < arguments.length; i++) {
        if (arguments[i]) {
            args.push(arguments[i]);
        }
    }

    return args.join('/');
}

function fetchRssFeed() {
    requestify.get(config.blog_rss).then(function (response) {
        log.info('Fetching RSS Feed (http code: %s)', response.code);

        if (response.code < 400) {
            global.rssCache = response.body;
        }
    });
}
