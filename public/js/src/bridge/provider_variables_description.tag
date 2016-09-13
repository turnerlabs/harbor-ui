<provider_variables_description>
    <div class="col s4">
        <h4>Provider Variables</h4>
    </div>
    <div class="col s8 card blue-grey darken-1">
        <div class="card-content white-text">
            Providers are defined as the data center which the container is run. These can each have different replica values and different environment variables if needed.
        </div>
    </div>

    <script>
    var self = this;

    self.on('update', function() {
        self.shipment = self.opts.shipment;
    });
    </script>
</provider_variables_description>
