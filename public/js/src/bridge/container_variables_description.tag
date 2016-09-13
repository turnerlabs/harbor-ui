<container_variables_description>
    <div class="col s4">
        <h4>Containers</h4>
    </div>
    <div class="col s8 card blue-grey darken-1">
        <div class="card-content white-text">
            These are the images that are run. These object contiain port objects, which
            determine the public facing services of the running shipment.
            These values can also have environment variables.
        </div>
    </div>

    <script>
    var self = this;

    self.on('update', function() {
        self.shipment = self.opts.shipment;
    });
    </script>
</container_variables_description>
