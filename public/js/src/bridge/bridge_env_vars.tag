<bridge_env_vars>
    <div class="row valign-wrapper">
        <div class="col s12 right-align valign">
            <button class="{ btn: true, disabled: triggering }" onclick="{ triggerShipment }">Trigger</button>
            <button class="{ btn: true, disabled: !haveChanges }" onclick="{ viewChanges }">Save</button>
        </div>
    </div>

    <div class="row">
        <h4>Env Vars</h4>
        <p>Env Vars are key/value pairs of <a href="https://en.wikipedia.org/wiki/Environment_variable">environment variables</a> that are injected and exposed within a running Container.<p>
        <p>The key must be an uppercase alphanumeric, they are allowed to contain underscores. It is strongly encouraged to have words separated with underscores. Dashes, hyphens and spaces are forbidden.</p>
        <p>Values are strings.</p>
    </div>

    <div class="row">
        <h4>Shipment Env Vars</h4>
        <p>These env vars are exposed to all Shipment instances with name, <strong>{ shipment.parentShipment.name }</strong>, regardless of Environment.</p>
    </div>
    <div class="row">
        <config-pair each="{ key, i in shipment.parentShipment.envVars }"
          iterator="{ shipment.parentShipment.envVars }"
          target="{ shipment.parentShipment.name }"
          location="shipment"
          index="{ i }"
          key="{ key.name }"
          var_type="{ key.type }"
          val="{ key.value }"/>
        <add-variable
            target="{ shipment.parentShipment.name }"
            location="shipment"
            list="{ shipment.parentShipment.envVars }"/>
    </div>

    <div class="row">
        <h4>Environment Env Vars</h4>
        <p>These env vars are exposed to only to Shipment instances with environment, <strong>{ shipment.name }</strong>.
    </div>
    <div class="row">
        <config-pair each="{ key, i in shipment.envVars }"
          iterator="{ shipment.envVars }"
          index="{ i }"
          target="{ shipment.name }"
          location="environment"
          key="{ key.name }"
          var_type="{ key.type }"
          val="{ key.value }"/>
        <add-variable
            target="{ shipment.name }"
            location="environment"
            list="{ shipment.envVars }"/>
    </div>

    <div class="row">
        <h4>Provider Env Vars</h4>
        <p>Providers are defined as the data center within which the container is run. These can each have different replica values and different environment variables if needed.</p>
    </div>
    </div>
    <div class="row" each="{ provider, i in shipment.providers }">
        <div class="col s12">
              <h5>{ provider.name } Env Vars</h5>
              <div class="row">
                  <config-pair each="{ key, j in provider.envVars }"
                      iterator="{ provider.envVars }"
                      index="{ j }"
                      target="{ provider.name }"
                      location="provider"
                      key="{ key.name }"
                      var_type="{ key.type }"
                      val="{ key.value }"/>
                  <add-variable
                      target="{ provider.name }"
                      location="provider"
                      list="{ provider.envVars }"></add-variable>
              </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    saveChanges(evt) {
        d('bridge/envVars::saveChanges');
        RiotControl.trigger('shipit_save_changes');
    }

    triggerShipment(evt) {
        d('bridge/bridge_env_vars::triggerShipment');
        if (!self.shipment) {
            return;
        }

        self.shipment.providers.forEach(function (provider) {
            RiotControl.trigger('bridge_shipment_trigger', self.shipment.parentShipment.name, self.shipment.name, provider.name);
        });
    }

    viewChanges(evt) {
        RiotControl.trigger('show_changes_panel');
    }

    function getUrl(key, opts) {
        var url;
        if (opts.location === 'shipment') {
            url = self.shipment.parentShipment.name + '/envVar';
        } else if (opts.location === 'environment') {
            url = self.shipment.parentShipment.name + '/environment/' + self.shipment.name + '/envVar';
        } else if (opts.location === 'provider') {
            url = self.shipment.parentShipment.name + '/environment/' + self.shipment.name + '/provider/' + opts.target + '/envVar';
        } else if (opts.location === 'container') {
            url = self.shipment.parentShipment.name + '/environment/' + self.shipment.name + '/container/' + opts.target + '/envVar';
        }

        if (key) {
            url += '/' + key
        } else {
            url += 's'
        }

        return url;
    }

    RiotControl.on('bridge_shipment_is_triggering', function (result) {
        self.triggering = result;
        self.update();
    });

    RiotControl.on('bridge_have_changes_result', function (result) {
        self.haveChanges = result;
    });

    RiotControl.on('shipit_added_var', function (envVar, opts) {
        d('bridge/bridge_env_vars::shipit_added_var', envVar, opts);
        if (!self.shipment) {
            return;
        }

        var url = getUrl(null, opts);

        // Add to the UI
        switch (opts.location) {
        case 'shipment':
            self.shipment.parentShipment.envVars.push(envVar);
            break;
        case 'environment':
            self.shipment.envVars.push(envVar);
            break;
        case 'provider':
            self.shipment.providers.forEach(function (provider, index) {
                if (provider.name === opts.target) {
                    self.shipment.providers[index].envVars.push(envVar);
                }
            });
            break;
        case 'container':
            self.shipment.containers.forEach(function (container, index) {
                if (container.name === opts.target) {
                    self.shipment.containers[index].envVars.push(envVar);
                    self.parent.update();
                }
            });
            break;
        }

        RiotControl.trigger('shipit_update_value', url, envVar, 'POST');
        self.update();
    });

    RiotControl.on('environment_variable_update', function (data, value, opts) {
        d('bridge/bridge_env_vars::config_value_update', data, value, opts);

        if (opts.type === 'number') {
            value = parseInt(value);
        }

        var url = getUrl(data.name, opts);

        data.value = value;
        opts.iterator[opts.index].value = value;

        RiotControl.trigger('shipit_update_value', url, data);
    });

    RiotControl.on('environment_variable_delete', function (key, opts) {
        d('bridge/bridge_env_vars::environment_variable_delete', key, opts);

        var url = getUrl(key, opts);

        opts.iterator.splice(opts.index, 1);
        RiotControl.trigger('shipit_update_value', url, {}, 'DELETE');
        self.update();
    });

    self.on('update', function () {
        self.shipment = self.opts.shipment;
    });
    </script>
</bridge_env_vars>
