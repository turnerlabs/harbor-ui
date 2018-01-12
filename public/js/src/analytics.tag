<analytics>
    <script>
    var self = this,
        d = utils.debug;

    /*
     * a metric will be sent the the telemetry service
     * it needs to have these fields
     * source: (required) 'harbor-ui'
     * action: (required) variable; i.e., 'shipyard.create', 'buildit.delete', etc.
     * error:  (optional) error string
     * ip:     (required) Argo username
     * os:     (optional) navigator.platform
     * arch:   (optional) navigator.userAgent
     */
    RiotControl.on('send_metric', function (error, action) {
        var payload = {
                source: 'harbor-ui',
                action: action || 'unknown',
                ip: ArgoAuth.getUser() || 'unknown',
                os: window.navigator.platform || 'unknown',
                arch: window.navigator.userAgent || 'unknown'
            };

        if (error) {
            payload.error = typeof error === 'string' ? error : error.toString();
        }

        if (window.config.send_telemetry) {
            d('analytics::send_metric', payload);
            $.ajax({
                method: 'POST',
                url: '/api/v1/metric',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                accepts: 'application/json',
                data: JSON.stringify(payload),
                success: function () {
                    d('analytics::send_metric::success');
                },
                error: function (xhr, status, err) {
                    d('analytics::send_metric::error', xhr);
                }
            });
        }
        else {
            d('analytics::send_metric::not-sent', payload);
        }
    });
    </script>
</analytics>
