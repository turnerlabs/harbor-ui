<bridge_lb_status>

    <div class="row" if="{ showStatus }">
        <div class="col s12 brown lighten-5 brown-text z-depth-1">
            <h4>Load Balancer Status</h4>
            <p>{ lb_status_message }</p>
            <p>{ lb_status_description }</p>

            <div class="progress">
                <div class="indeterminate"></div>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.wait = 1000 * 10;
    self.showStatus = false;
    self.lb_status_message = '';
    self.lb_status_description = '';

    RiotControl.on('bridge_lb_status_result', function (data) {
        d('bridge_lb_status::bridge_lb_status_result', data);
        var outOfService = data.instance_states.filter(function (val) { return val.state === 'OutOfService' }),
            show = outOfService.length > 0;

        self.showStatus = show;

        if (show) {
            d('bridge_lb_status_result::outOfService', outOfService)
            d('bridge_lb_status_result::mapped', outOfService.map(function (val) {return val.state}));
            self.lb_status_message = outOfService
                .map(function (val) { return val.state; })
                .reduce(function (prev, cur) { return cur; }, '');
            self.lb_status_description = outOfService
                .map(function (val) { return val.description; })
                .reduce(function (prev, cur) { return cur; }, '');

            setTimeout(function () {
                if (self.lbName) {
                    RiotControl.trigger('bridge_lb_status', self.shipment, self.environment, self.provider, self.lbName);
                }
            }, self.wait);
        } else {
            RiotControl.trigger('bridge_lb_status_stop');
        }
    });

    RiotControl.on('bridge_lb_status_start', function (s, e, p, n) {
        d('bridge_lb_status::bridge_lb_status_start', s, e, p, n)
        self.shipment    = s;
        self.environment = e;
        self.provider    = p;
        self.lbName      = n;

        RiotControl.trigger('bridge_lb_status', s, e, p, n);
    });

    RiotControl.on('bridge_lb_status_stop', function () {
        d('bridge_lb_status::bridge_lb_status_stop')
        self.shipment    = null;
        self.environment = null;
        self.provider    = null;
        self.lbName      = null;
    });
    </script>
</bridge_lb_status>
