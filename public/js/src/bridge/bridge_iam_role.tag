<bridge_iam>
    <div class="row">
        <div class="col s6">
            <p><strong>IAM Role</strong></p>
            <p>{ environment.iamRole }</p>
        </div>
        <div class="col s6">
            <p><strong>Iam Role:</strong></p>
            <p><input
                class="iam_role"
                value="{ environment.iamRole }"
                type="text"
                onchange="{ setValue }"
            /></p>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        mu = utils.makeUrl;

    /**
    *
    * setValue
    *
    * sets the value  based on the input name
    *
    * @param {Element} input The element that the event was triggered
    */
    setValue(input) {
        var url = self.environment.parentShipment.name  + '/environment/' + self.environment.name ;
        self.environment.iamRole = input.target.value;
        RiotControl.trigger('shipit_update_value', url, self.environment);
    }

    self.on('update', function() {
        self.environment = self.opts.environment;
    });

    </script>
</bridge_iam>