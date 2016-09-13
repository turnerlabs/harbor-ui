<container_modal>
    <div class="modal-content">
        <h4>Create New Container</h4>
        <div class="row">
            <div class="col s12 input-field">
                <select id="containerSelect" class="container-select-2 harbor-select" onchange="{ setContainer }" style="width: 100%;">
                    <option></option>
                    <option each="{ image in images }" value="{ image.name }">{ image.name }</option>
                </select>
            </div>
            <div class="col s12 input-field">
                <select id="containerVersionsSelect" class="version-select-2 harbor-select" onchange="{ setVersion }" style="width: 100%;">
                    <option></option>
                    <option each="{ container in versions }" value="{ JSON.stringify(container) }">{ container.version }</option>
                </select>
            </div>
            <div if="{ showPort }" class="col s12">
                <div class="row">
                    <div class="col s6 input-field">
                        <div class="col s12">
                            Name
                            <i class="tiny material-icons"
                                title="Name of the Env Var that will be injected into the Container.">
                                info_outline
                            </i>
                        </div>
                        <div class="col s12">
                            <input type="text" name="portName" id="addPortName" value="PORT" required />
                        </div>
                    </div>
                    <div class="col s6 input-field">
                        <div class="col s12">
                            Value
                            <i class="tiny material-icons"
                                title="The value of the port that is set on the Load Balancer. The name of this Port is used to determine which Env Var will contain this value.">
                                info_outline
                            </i>
                        </div>
                        <div class="col s12">
                            <input type="number" name="value" value="{ portValue }" id="addPortValue" min="1" max="65535" required />
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col s6 input-field">
                        <div class="col s12">
                            Healthcheck
                            <i class="tiny material-icons"
                                title="The healthcheck path that determines if your application is alive. Only one is allowed.">
                                info_outline
                            </i>
                        </div>
                        <div class="col s12">
                            <input type="text" name="healthcheck" id="addHealthcheck" value="/" required />
                        </div>
                    </div>
                    <div class="col s6 input-field">
                        <div class="col s12">
                            Public Port
                            <i class="tiny material-icons"
                                title="Override for the port value on the Load Balancer.">
                                info_outline
                            </i>
                        </div>
                        <div class="col s12">
                            <input type="number" name="public_port" id="addPublicPort" value="" min="1" max="65535" />
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col s4 input-field">
                        <input type="checkbox" id="addPrimary"/>
                        <label for="addPrimary">Primary</label>
                        <i class="tiny material-icons"
                            title="If set, this Port's healthcheck value will be used to check the health of this Container.
                                          Proto and Port values will be used from this port object as well.
                                          If set, this Port's values will be used to check the health of this Container (protocol, healthcheck, port value, etc...)">
                            info_outline
                        </i>
                    </div>
                    <div class="col s4 input-field">
                        <input type="checkbox" id="addExternal" checked/>
                        <label for="addExternal">External</label>
                        <i class="tiny material-icons"
                            title="If set, this Port will be set on the Load Balancer.">
                            info_outline
                        </i>
                    </div>
                    <div class="col s4 input-field">
                        <input type="checkbox" id="addPublicVip"/>
                        <label for="addPublicVip">Public</label>
                        <i class="tiny material-icons"
                            title="If set, this Shipment will be exposed to the world on any Port set to external.">
                            info_outline
                        </i>
                    </div>
                </div>
                <div class="row">
                  <div class="col s12 input-field" if="{!onlyread}">
                      Protocol
                      <select id="protoSelect" class="proto-select" name="protocol" onchange="{ setProtocol }" style="width: 100%; display: block;">
                        <option
                            each="{ proto in protos }"
                            value="{ proto }">{ proto }
                        </option>
                      </select>
                  </div>
                </div>
            </div>
        </div>
    </div>
    <div class="modal-footer">
        <button class="modal-action waves-effect waves-green btn" onclick="{ saveContainer }">Save</button>
        <button class="modal-action modal-close waves-effect waves-red btn-flat">Cancel</button>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        port,
        container;

    self.protos = ['http', 'https', 'tcp'];
    self.images = [];
    self.versions = [];
    self.portValue = utils.getDefaultPort();

    saveContainer(evt) {
        d('bridge/container_modal::saveContainer');
        $('.modal-action').attr('disabled', true);
        var shipment = self.parent.shipment.parentShipment.name,
            environment = self.parent.shipment.name,
            public_port = parseInt($('#addPublicPort').val());

        port = {
            name: $('#addPortName').val(),
            value: parseInt($('#addPortValue').val()),
            healthcheck: $('#addHealthcheck').val(),
            protocol: $('#addProtocol').val(),
            primary: $('#addPrimary').is(':checked'),
            external: $('#addExternal').is(':checked'),
            public_vip: $('#addPublicVip').is(':checked')
        };

        if (public_port) {
            port.public_port = public_port;
        }

        RiotControl.trigger('create_container', shipment, environment, container, port);
    }

    setContainer(evt) {
        var name = $(evt.target).val();

        RiotControl.trigger('get_container_versions', name, function versionsCallback(versions) {
            d('bridge/container_modal::get_container_versions::callback', versions);
            self.versions = versionCompare(versions);
            self.update();
        });
    }

    setVersion(evt) {
        var val = $(evt.target).val();

        container = JSON.parse(val);

        self.showPort = true;
        self.update();
    }

    setProtocol(evt) {
        self.protocol = $(evt.target).val();
        self.update();
    }

    function versionCompare(array) {
        return array.sort(utils.versionCompare)
    }

    function containerVersions(versions) {
        d('bridge/container_modal::containerVersions', versions);
    }

    RiotControl.on('get_containers_result', function (images) {
        d('bridge/container_modal::get_containers_result', images);
        self.images = images;
        self.update();
    });


    </script>
</container_modal>
