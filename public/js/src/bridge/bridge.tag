<bridge>
    <div if={ page != 'bridge' } class="container" id="index-banner">
        <div class="row">
            <div class="col s12 m12">
                <h1 class="header center-on-small-only">Command Bridge</h1>
            </div>
        </div>
    </div>
    <div class="container">
        <bridge_shipment_list if={ page=='shipments' }></bridge_shipment_list>
        <bridge_environment_list if={ page=='environments' }></bridge_environment_list>
        <bridge_command if={ page=='bridge' }></bridge_command>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        _page, _shipment, _environment;

    self.page;

    function toggleBridgeIntervals(type, shipment, environment, tab) {
        if (type === 'bridge') {
            // only toggle based on tab
            if ((typeof tab === 'undefined' || tab === 'overview') && environment) {
                // toggle off logging
                RiotControl.trigger('toggle_logging_interval', false);
                // toggle on container status
                RiotControl.trigger('toggle_container_status_interval', true, { shipment: shipment, environment: environment, tab: tab });
                // toggle off audit logs
                RiotControl.trigger('toggle_audit_logs_interval', false);
            }
            else if (tab === 'logs') {
                // toggle on logging
                RiotControl.trigger('toggle_logging_interval', true, { shipment: shipment, environment: environment, tab: tab });
                // toggle off container status
                RiotControl.trigger('toggle_container_status_interval', false);
                // toggle off audit logs
                RiotControl.trigger('toggle_audit_logs_interval', false);
            }
            else if (tab === 'audit') {
                // toggle on logging
                RiotControl.trigger('toggle_logging_interval', false);
                // toggle off container status
                RiotControl.trigger('toggle_container_status_interval', false);
                // toggle off audit logs
                RiotControl.trigger('toggle_audit_logs_interval', true, { shipment: shipment, environment: environment, tab: tab });
            }
            else {
                // toggle off logging
                RiotControl.trigger('toggle_logging_interval', false);
                // toggle off container status
                RiotControl.trigger('toggle_container_status_interval', false);
                // toggle off audit logs
                RiotControl.trigger('toggle_audit_logs_interval', false);
            }
        }
        else {
            // toggle off logging
            RiotControl.trigger('toggle_logging_interval', false);
            // toggle off container status
            RiotControl.trigger('toggle_container_status_interval', false);
            // toggle off audit logs
            RiotControl.trigger('toggle_audit_logs_interval', false);
        }
    }

    RiotControl.trigger('menu_register', 'Command Bridge', 'bridge');

    RiotControl.on('command_bridge_enabled', function (page) {
        d('bridge::command_bridge_enabled', page);
    });

    riot.route(function (type, shipment, environment, tab) {
        toggleBridgeIntervals(type, shipment, environment, tab);

        if (type === 'bridge') {
            d('bridge::riot.route', type, shipment, environment, tab);
            var page = 'shipments';

            if (tab === 'logs') {
                setTimeout(function () {
                    $('.interval-select').select2();
                }, 100);
            }

            if (_page === type && _shipment === shipment && _environment === environment) {
                return;
            }

            _page = type;
            _shipment = shipment;
            _environment = environment;

            if (environment) {
                page = 'bridge';
            } else if (shipment) {
                page = 'environments';
            } else {
                RiotControl.trigger('get_shipments');
            }

            self.page = page;
            RiotControl.trigger('command_bridge_enabled', page, shipment, environment, tab);
            RiotControl.trigger('bridge_lb_status_stop');
            self.update();
        }
    });
    </script>
</bridge>
