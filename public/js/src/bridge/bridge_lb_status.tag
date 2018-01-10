<bridge_lb_status>

    <div class="row" if="{ showStatus }">
        <div class="col s12 brown lighten-5 brown-text z-depth-1">
            <h4>Load Balancer Status</h4>
            <h5 each="{ status in statuses }">{ status }</h5>
            <p each="{ desc in descriptions }">{ desc }</p>

            <div if="{ inProgress }" class="progress">
                <div class="indeterminate"></div>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.wait         = 1000 * 10;
    self.interval     = null;
    self.statuses     = [];
    self.started      = false;
    self.inProgress   = false;
    self.showStatus   = false;
    self.descriptions = [];

    function reset() {
        clearTimeout(self.interval);
        self.environment = null;
        self.showStatus  = null;
        self.shipment    = null;
        self.provider    = null;
        self.replicas    = -1;
        self.started     = null;
    }

    function configure(obj) {
        var provider = 0;

        self.environment = obj.name;
        self.shipment    = obj.parentShipment.name;
        self.provider    = obj.providers[provider] ? obj.providers[provider].name : '';
        self.replicas    = obj.providers[provider] ? obj.providers[provider].replicas : 0;
        self.raw_provider = obj.providers[provider] ? obj.providers[provider] : {};
        self.started     = true;
    }

    RiotControl.on('bridge_lb_status_result', function (data) {
        d('bridge/bridge_lb_status::bridge_lb_status_result', data);

        if (!data || (!data.instance_states && !data.message && !data.load_balancers)) {
            return;
        }

        // if we get an error back from requesting for an alb.
        // These just return {"message":" LB not active"}
        if (data.message) {
            self.inProgress = true;
            self.showStatus = true;
            self.interval = setTimeout(function () {
                RiotControl.trigger('bridge_lb_status', self.shipment, self.environment, self.provider);
            }, self.wait);
            return;
        }

        var all,
            outage,
            isAlb = false;

        self.raw_provider.id = data.lb_name;
        RiotControl.trigger('load_balancer_name', data.lb_name);

        // if it has load_balancers, then it's an alb
        if (data.load_balancers) {
            isAlb = true;
            all = data.load_balancers.length
            outage = data.load_balancers
            .map(function(val) { return {state: val.state.code}})
            .filter(function (val) { return val.state !== 'active' });
        } else {
            all = data.instance_states.length;
            outage = data.instance_states.filter(function (val) { return val.state === 'OutOfService' });
        }

        // Show only when all messages are errors
        self.showStatus = outage.length === all;

        if (self.showStatus) {
            d('bridge_lb_status_result::outage', outage);
            self.statuses = outage
                .map(function (val) { return val.state; })
                .filter(function (val, idx, me) { return me.indexOf(val) === idx; });

            if (!isAlb) {
                self.descriptions = outage
                    .map(function (val) { return val.description; })
                    .filter(function (val, idx, me) { return me.indexOf(val) === idx; });

                self.inProgress = self.descriptions.reduce(function (prev, cur) {
                    if (cur.indexOf('in progress') !== -1) {
                        return true;
                    } else {
                        return prev;
                    }
                }, false);
            }

            self.interval = setTimeout(function () {
                RiotControl.trigger('bridge_lb_status', self.shipment, self.environment, self.provider);
            }, self.wait);
        }
    });

    RiotControl.on('bridge_lb_status_start', function (shipment) {
        d('bridge/bridge_lb_status::bridge_lb_status_start', shipment);
        if (!self.started) {
            configure(shipment);

            if (self.replicas > 0) {
                RiotControl.trigger('bridge_lb_status', self.shipment, self.environment, self.provider);
            }
        }
    });

    RiotControl.on('bridge_lb_status_stop', function () {
        d('bridge/bridge_lb_status::bridge_lb_status_stop');
        reset();
    });
    </script>
</bridge_lb_status>
