var winston = require('winston'),
    exports = module.exports;

var log = new (winston.Logger)({
    transports: [
        new (winston.transports.Console)({timestamp: true})
    ]
});

exports.logInfo = logInfo;
exports.log = log;


function logInfo(res) {
    var now = (new Date()).getTime();
    log.info('%s %s HTTP/%s %s %sms', res.req.method, res.req.url, res.req.httpVersion, res.statusCode, (now - res.req.count));
}
