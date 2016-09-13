<bridge_container>
    <div class="card z-depth-0 bordered">
        <div class="card-content">
            <div class="card-title">
                { container.name }
                <span class="sm">{ container.version }</span>
            </div>
            <div class="row">
                <div class="col s12 card red darken-1" if="{portValueChanged}">
                    <div class="card-content white-text">
                        If you change a Port value that is already attached to a running Shipment,
                        you must set the shipment's replicas to 0, then trigger the Shipment,
                        and then set back to the desired replicas and trigger again.
                        This is required due to ELB values only being set on creation.
                    </div>
                </div>
                <div class="col s8">
                    <h5>Ports</h5>
                </div>
                <div class="col s4 right-align">
                    <button class="btn right add-port-btn" disabled={ onlyread } onclick="{ addPort }">Add Port</button>
                </div>
                <div class="col s12" if="{ container.version }">
                    <div class="row">
                        <div class="col s12 input-field" each="{ port, i in container.ports }">
                            <shipit_port port="{ port }" onlyread="{ onlyread }" container="{ container }"></shipit_port>
                            <button if="{ i > 0 && !onlyread }" name="{ i }" onclick="{ removePort }" class="btn delete-btn right">Remove Port</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col s12">
                    <h5>Container Env Vars</h5>
                    <p>These env vars are exposed to only to Shipment instances with container, <strong>{ container.name }</strong>.
                    <div class="row">
                        <config-pair each={ key, i in container.envVars }
                            iterator="{ container.envVars }"
                            index="{ i }"
                            target="{ container.name }"
                            location="container"
                            key="{ key.name }"
                            var_type="{ key.type }"
                            onlyread="{ onlyread }"
                            val="{ key.value }"></config-pair>
                        <add-variable
                            if="{ !onlyread }"
                            target="{ container.name }"
                            location="container"
                            list="{ container.envVars }"></add-variable>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col s12">
                    <button class="btn delete-btn" name="{ container.name }" disabled={ onlyread } onclick="{ removeContainer }">Delete Container</button>
                </div>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        portCount = 0,
        lastContainer;

    self.onlyread = true;
    self.requesting = false;

    self.portValueChanged = false;

    versionCompare = function(array) {
        return array.sort(utils.versionCompare)
    }

    setVersion(evt, passedRaw) {
        d('shipyard/containers::setVersion');

        var container = passedRaw ? evt : JSON.parse($(evt.target).val());

        self.container.version = container.version;
        if (!self.container.ports || !self.container.ports.length) {
            self.addPort(true);
        }
        self.container.image = container.image.replace('http://', '').replace('https://', '');
        RiotControl.trigger('set_container', self.container);
        self.parent.update();
    }

    removeContainer(evt) {
        var name = $(evt.target).attr('name'),
            shipment = self.parent.shipment.parentShipment.name,
            environment = self.parent.shipment.name;

        d('bridge_container::removeContainer', name);

        RiotControl.trigger('delete_container', shipment, environment, name);
    }

    addPort(primary) {
        var port = utils.getDefaultPort();
        var portObj = {
            protocol: 'http',
            external: true,
            primary: primary === true ? true : false,
            public_vip: false,
            healthcheck: '',
            ssl_management_type: 'iam',
            enable_proxy_protocol: false,
            value: port,
            name: "PORT"
        };

        if (portCount > 0) {
            portObj.name += '_' + portCount;
        }

        if (!self.container.ports) {
            portCount = 0;
            self.container.ports = [];
        }

        self.container.ports.push(portObj);
        portCount++
        RiotControl.trigger('shipit_added_port', self.container, portObj);
        self.update();
    }

    removePort(evt) {
        var index = parseInt(evt.target.name),
            port = self.container.ports.splice(index, 1);
        portCount--;
        RiotControl.trigger('shipit_delete_port', self.container, port[0]);
        self.parent.update();
    }

    function setPorts(container) {
        var shouldSaveEnvVars = utils.setPorts(container, container.envVars);

        shouldSaveEnvVars.list.forEach(function(envVar) {
            var envUrl = self.parent.shipment.parentShipment.name + '/environment/' + self.parent.shipment.name + '/container/' + container.name + '/envVar';
            if (envVar.add) {
                envUrl += 's'
            } else {
                envUrl += '/' + envVar.name;
            }

            RiotControl.trigger('shipit_update_value', envUrl, envVar, envVar.add ? 'POST' : 'PUT');
        });
    }

    function validateContainers(containers) {
        var portNums = 0,
            valid = true,
            alerted = {};

        containers.forEach(function(container) {
            container.ports.forEach(function(port) {
                if (port.primary) {
                    portNums++;
                }
            });
            if (portNums > 1 && !alerted.primary) {
                RiotControl.trigger('flash_message', 'error', 'Cannot have more than one primary port across multiple containers.', 30000);
                valid = false;
                alerted.primary = true;
            }
        });

        return valid;
    }

    function setVersion(results) {
        d('shipyard/containers::get_container_versions_result', results);
        self.versions = results;
        self.update();
        setTimeout(function() { $('.bridge-version-select').select2()}, 1000);
    }

    RiotControl.on('shipit_added_port', function(container, port) {

        var url = self.parent.shipment.parentShipment.name + '/environment/' + self.parent.shipment.name + '/container/' + container.name + '/ports';
        setPorts(container);
        RiotControl.trigger('shipit_update_value', url, port, 'POST');
        self.update();
    });

    RiotControl.on('shipit_delete_port', function(container, port) {

        var url = self.parent.shipment.parentShipment.name + '/environment/' + self.parent.shipment.name + '/container/' + container.name + '/port/' + port.name;
        setPorts(container);
        RiotControl.trigger('shipit_update_value', url, port, 'DELETE');
        self.update();
    });


    RiotControl.on('port_value_changed', function(container, port) {
        d('bridge/bridge_container::port_value_changed', container, port);
        self.portValueChanged = true;

        var validated = false,
            url;

        url = self.parent.shipment.parentShipment.name + '/environment/' + self.parent.shipment.name + '/container/' + container.name + '/port/' + (port.oldName || port.name);
        setPorts(container);

        validated = validateContainers(self.parent.shipment.containers);

        if (validated) {
            RiotControl.trigger('shipit_update_value', url, port);
        }
        self.update();
    });

    self.on('update', function () {
        var version;
        self.onlyread = self.opts.onlyread;
        self.container = self.opts.container;

        if (self.container && self.container.ports) {
            portCount = self.container.ports.length;
        } else {
            portCount = 0;
        }

        if (self.container && !self.container.version) {
            version = self.container.image.split(':')[1];
            if (version) {
                self.container.version = version;
            }
        }

        if (portCount === 0 && self.container.ports && self.container.version) {
            self.addPort(true);
        }

        if (self.container.name && self.container.name !== lastContainer) {
            self.requesting = true;
            lastContainer = self.container.name;
            RiotControl.trigger('get_container_versions', self.container.name, setVersion);
        } else if (self.container.ports.length === 0 && self.versions) {
            var firstVersion = self.versions.sort(utils.versionCompare)[0];
            self.setVersion(firstVersion, true);
        }
    });
    </script>
    <style scoped>
        .sm {
            font-size: small;
        }

        .bordered {
            border: 1px solid #e0e0e0
        }

        .add-port-btn {
            width: 200px;
            font-size: 16px;
        }

        .delete-btn {
            background-color: #F44336;
        }
    </style>
</bridge_container>
