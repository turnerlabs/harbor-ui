<shipit_container>
    <div class="row">
        <div class="col s6 input-field">
            <p if="{container.name}">Selected Container: {container.name}</p>
            <h5>Select a Container</h5>
            <select id="containerSelect" class="container-select harbor-select" onchange={ setContainer } style="width: 100%">
                <option></option>
                <option
                    each={ image in images }
                    selected="{ image.name == this.parent.container.name }"
                    value={ image.name }>{ image.name }</option>
            </select>
            <div class="row">
                <div class="col s6 input-field">
                    <h5>Select a Version</h5>
                    <select id="versionSelect" class="version-select harbor-select" onchange="{ setShipmentVersion }" style="width: 100%">
                        <option></option>
                        <option
                            each="{ container in versionCompare(versions) }"
                            selected="{ container.version == this.parent.container.version }"
                            value="{ JSON.stringify(container) }">{ container.version }
                        </option>
                    </select>
                </div>
                <div class="col s6" if="{loading}">
                    <h5>loading versions...</h5>
                </div>
            </div>
        </div>
        <div class="col s6 input-field" if="{container.version}">
            <div class="row">
                <h5>Ports</h5>
                <div class="col s12 input-field" each="{port, i in container.ports}">
                    <shipit_port port="{port}" container="{container}"></shipit_port>
                    <button if="{i > 0}" name="{i}" onclick="{removePort}" class="btn delete-btn right">Remove Port</button>
                </div>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        lastContainer,
        portCount = 0;


    versionCompare = function(array) {
        return array.sort(utils.versionCompare)
    }

    setContainer(evt) {
        d('shipyard/containers::setContainer');

        var val = $(evt.target).val();

        self.container.name = val;
        self.container.version = null;
        self.container.ports = [{
            protocol: 'http',
            healthcheck: '/hc',
            external: true,
            primary: true,
            public_vip: false,
            value: utils.getDefaultPort(),
            ssl_management_type: 'iam',
            enable_proxy_protocol: false,
            healthcheck_interval: 10,
            healthcheck_timeout: 3,
            name: "PORT"
        }];
        self.container.vars = [];

        RiotControl.trigger('get_container_versions', val, setVersion);
        self.loading = true;
        self.update();
    }

    setShipmentVersion(evt) {
        d('shipyard/containers::setShipmentVersion');

        var containerVersion = JSON.parse($(evt.target).val());
        self.container.name = containerVersion.name;
        self.container.version = containerVersion.version;
        self.container.image = containerVersion.image.replace('http://', '').replace('https://', '');
        self.update();
    }

    removePort(evt) {
        var index = parseInt(evt.target.name),
            port = self.container.ports.splice(index, 1);
        portCount--;
        RiotControl.trigger('shipit_delete_port', self.container, port[0]);
        self.parent.update();
    }

    function setVersion(results) {
        d('shipyard/containers::get_container_versions_result', results);
        self.versions = results;
        self.loading = false;

        self.update();
    }

    self.on('update', function () {
        self.container = self.opts.container;
        self.images = self.opts.images;

        if (self.container && self.container.ports) {
            portCount = self.container.ports.length;
        } else {
            portCount = 0;
        }

        if (self.container && self.container.image) {
            self.container.version = self.container.image.split(':')[1];
        }

        if (self.container.name && self.container.name !== lastContainer) {
            lastContainer = self.container.name;
            self.loading = true;
            RiotControl.trigger('get_container_versions', self.container.name, setVersion);
        }

        $('.container-select').select2();
        $('.version-select').select2();
    });
    </script>
    <style scoped>
        .add-port-btn {
            width: 200px;
            font-size: 16px;
        }

        .delete-btn {
            background-color: #F44336;
        }
    </style>
</shipit_container>
