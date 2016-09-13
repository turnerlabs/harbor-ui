<shipment_variables_description>
    <div class="col s4">
        <h4>Shipment Variables</h4>
    </div>
    <div class="col s8 card blue-grey darken-1">
        <div class="card-content white-text">
            These Shipment variabels, are inherited by all shipments of
            this Name: <strong>{shipment.parentShipment.name}</strong>
        </div>
    </div>

    <script>
    var self = this;

    self.on('update', function() {
        self.shipment = self.opts.shipment;
    });
    </script>
</shipment_variables_description>
