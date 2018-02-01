var winston = require('winston'),
    exports = module.exports;

var log = new (winston.Logger)({
    transports: [
        new (winston.transports.Console)({timestamp: true})
    ]
});

exports.logInfo = logInfo;
exports.log = log;


function logInfo(res, cached) {
    var now = (new Date()).getTime();
    log.info('%s%s %s HTTP/%s %s %sms', cached ? 'CACHED ' : '', res.req.method, res.req.url, res.req.httpVersion, res.statusCode, (now - res.req.count));
}
