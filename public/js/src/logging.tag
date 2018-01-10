<logging>
    <div class="row">
        <div class="col s3">
            <p>Data Refresh Interval<br>
                <select class="interval-select" onchange={ updateMultiplier } style="width: 100%">
                    <option selected={ multiplier == 'stop' } value="stop">Stop</option>
                    <option selected={ multiplier == 1 } value="1">1</option>
                    <option selected={ multiplier == 5 } value="5">5</option>
                    <option selected={ multiplier == 10 } value="10">10</option>
                    <option selected={ multiplier == 20 } value="20">20</option>
                    <option selected={ multiplier == 30 } value="30">30</option>
                </select></p>
        </div>
        <div if="{ !loading && !helm.error }" class="col s12" each="{ replica in helm.replicas.sort(sortReplicas) }">
            <div class="col s12" each="{ container in replica.containers.sort(sortContainers) }">
                <h4>Container: { container.name }</h4>
                <h5>Provider:  { replica.provider }</h5>
                <p>Host:       { replica.host }</p>
                <p>ID:         { container.id }</p>

                <h5>Logs</h5>
                <textarea class="logs" value="{ container.logs.join('') }" readonly></textarea>

            </div>
        </div>
        <div if="{ loading && !helm.error }">
            Loading
        </div>
        <div if="{ helm.error }">
            <h4>There are no running instances of this shipment.</h4>
            <p>{ view.helm.msg }</p>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        config = window.config;

    self.helm;
    self.timer;
    self.route;
    self.loading = true;
    self.loaded = false;
    self.multiplier = config.updateInterval;
    self.sortReplicas = utils.sortReplicas;
    self.sortContainers = utils.sortContainers;

    updateMultiplier(evt) {
        var val = $(evt.target).val();

        RiotControl.trigger('save_interval_multiplier', val);
    }

    function updateInterval(num) {
        d('bridge/logging::updateInterval(%s)', num);
        var barge;

        if (self.timer) {
            clearInterval(self.timer);
        }

        if (self.opts.shipment) {
            barge = utils.getBarge(self.opts.shipment);
            d('bridge/logging::updateInterval::trigger', barge, self.route.shipment, self.route.environment)
            RiotControl.trigger('update_logs', barge, self.route.shipment, self.route.environment);

            if (num !== 'stop') {
                self.interval = parseInt(num, 10) * 1000;

                self.timer = setInterval(function () {
                    RiotControl.trigger('update_logs', barge, self.route.shipment, self.route.environment);
                }, self.interval);
            }
        }
        else {
            d('bridge/logging::updateInterval NOPE');
        }
    }

    function resetHelm() {
        return {
            error: false,
            replicas: [
                {
                    host: '0.0.0.0',
                    provider: '',
                    containers: [
                        {
                            id: '1',
                            name: '',
                            image: 'foo',
                            logs: ['']
                        }
                    ]
                }
            ]
        };
    }

    RiotControl.on('update_logs_result', function (helm) {
        d('bridge/logging::update_logs_result', helm);

        self.helm = helm;
        self.update();

        if (!self.loading) {
            if (self.loaded) {
                utils.tailTextarea($('textarea.logs'));
            }
            else {
                utils.setupTextarea($('textarea.logs'))
                self.loaded = true;
            }
        }
    });

    RiotControl.on('toggle_logging_interval', function (toggle, route) {
        d('bridge/logging::toggle_logging_interval', toggle, route);
        self.route = route;

        if (toggle) {
            RiotControl.trigger('retrieve_interval_multiplier');
        }
        else {
            self.loaded = false;
            self.loading = true;
            clearInterval(self.timer);
            RiotControl.trigger('update_logs_result', resetHelm());
        }
    });

    RiotControl.on('interval_multiplier_result', function (val) {
        d('bridge/logging::interval_multiplier_result', val);
        self.multiplier = val;

        RiotControl.trigger('get_shipment_model', 'logging', self.route.shipment, self.route.environment);
    });

    RiotControl.on('get_shipment_model_result', function (caller, shipment) {
        if (caller === 'logging') {
            d('bridge/logging::get_shipment_model_result', shipment);
            if (self.route) {
                self.shipment = shipment;
                self.loading = false;

                updateInterval(self.multiplier);
            }
        }
    });

    </script>
</logging>
