<bridge_environment_list>
    <div class="container">
        <h3>{ shipment } Environments</h3>
        <div class="collection">
            <div each={ environments } class="collection-item">
                <h5><a href={ path }>{ name }</a></h5>
            </div>
        </div>
    </div>
    <script>
    var self = this,
        d = utils.debug;

    self.shipment;
    self.environments;

    self.on('mount', function () {
        d('bridge/environment_list::mount');
    });

    RiotControl.on('get_shipment_environments_result', function (environments) {
        d('bridge/environment_list::get_shipment_environments_result', environments);

        self.environments = environments;

        self.update();
    });

    RiotControl.on('command_bridge_enabled', function (page, shipment) {
        if (page === 'environments') {
            d('bridge/environment_list::command_bridge_enabled', page, shipment);

            self.shipment = shipment;

            RiotControl.trigger('get_shipment_environments', shipment);
        }
    });
    </script>
</bridge_environment_list>
