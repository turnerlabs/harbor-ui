<environment_variables_description>
    <div class="col s4">
        <h4>Environment Variables</h4>
    </div>
    <div class="col s8 card blue-grey darken-1">
        <div class="card-content white-text">
            These variables are exported inside of all running instances of this Environment: <strong>{shipment.name}</strong>
        </div>
    </div>

    <script>
    var self = this;

    self.on('update', function() {
        self.shipment = self.opts.shipment;
    });
    </script>
</environment_variables_description>
