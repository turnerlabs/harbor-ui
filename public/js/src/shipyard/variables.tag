<variables>
    <div class="container">

        <h4>Step 3: Provide Configuration</h4>
        <div class="card blue-grey lighten-4">
            <div class="card-content black-text">
                <p>At this step we will provide configuration values to the container while it runs. These values will be provided as environment variables.</p>
                <p>Now provide configuration for the Shipment. Several values are required, but you can include others if you'd like.</p>
            </div>
        </div>

        <div class="argo-tabs">
            <h5>Config Values</h5>
            <div class="row">
                <div each="{provider,i in shipment.providers}">
                    <div class="col s3">REPLICAS</div>
                    <div class="col s9">
                        <input type="number" class="required" name="{i}" value={ provider.replicas } onblur={ parseReplicas } min="1" required />
                    </div>
                    <select_barge provider="{provider}" callback="{saveState}"></select_barge>
                </div>

                <hr/>
                <h5>Env Vars</h5>
                <config-pair each={ key in shipment.environment.vars } key={ key.name } val={ key.value } type="{ key.type }"></config-pair>
            </div>
        </div>

        <div class="argo-tabs">
            <div class="card blue-grey lighten-4">
                <div class="card-content black-text">
                    <div name="config-help" class="add-info">
                        <p>These key/value pairs that will be injected into your Docker container as Env Vars when running in the specified environment.</p>
                        <p>The key must be uppercase, and cannot include dashes (use underscores instead).</p>
                    </div>
                </div>
            </div>
            <h5>Environment Env Vars</h5>

            <add-variable list="{shipment.environment.vars}" type="basic" location="environment" where="shipyard"></add-variable>
        </div>

        <div class="argo-tabs">
            <div class="card blue-grey lighten-4">
                <div class="card-content black-text">
                    <div name="discover-help" class="add-info">
                        <p>Use the Argo Discover tool to find the IP and Port of other Products running in Argo.</p>
                        <p>The key will be the name of the environment variable. The value should be a Product name.</p>
                        <p>You can use a different environment than you currently are defining by separating it with a colon. For example, <code>cnn-pal:dev</code>.</p>
                    </div>
                </div>
            </div>

            <h5>Discover Values <span name="helper-discover-help" class="ui-icon ui-icon-help inline-icon"></span></h5>

            <add-variable list="{shipment.environment.vars}" type="discover" location="environment" where="shipyard"></add-variable>

            <div class="empty-box"></div>

            <button class="btn prev-btn" onclick={ prevStep }>Previous Step: Select Containers</button>
            <button class="btn next-btn" onclick={ nextStep }>Next Step: Confirm</button>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    nextStep(evt) {
        d('shipyard/variables::nextStep');
        riot.route('shipyard/confirm');
    }

    prevStep(evt) {
        d('shipyard/variables::prevStep');
        riot.route('shipyard/containers');
    }

    parseReplicas(evt) {
        self.shipment.providers[parseInt(evt.target.name)].replicas = parseInt(evt.target.value);
    }

    saveState() {
        RiotControl.trigger('save_state', 'shipment', self.shipment);
    }

    function addIfMissing(arr, ele) {
        var missing = true;

        arr.forEach(function (item) {
            if (item.name == ele.name) {
                missing = false;
            }
        });

        if (missing) {
            arr.push(ele);
        }

        return arr;
    }

    self.on('mount', function () {
        d('shipyard/variables::mount');
    });

    RiotControl.on('shipyard_add_envvar', function (envVar) {
        d('shipyard/variables::shipyard_add_envvar', envVar);

        if (!self.shipment) {
            return;
        }

        addIfMissing(self.shipment.environment.vars, envVar);

        RiotControl.trigger('save_state', 'shipment', self.shipment);
        self.update();
    });

    RiotControl.on('environment_variable_update', function (key, value) {
        d('shipyard/variables::environment_variable_update', key, value);

        if (!self.shipment) {
            return;
        }

        self.shipment.environment.vars.map(function(variable) {
            if (variable.name === key) {
                variable.value = value;
            }
        });

        RiotControl.trigger('save_state', 'shipment', self.shipment);
    });

    RiotControl.on('environment_variable_delete', function (key) {
        d('shipyard/variables::environment_variable_delete', key);

        if (!self.shipment) {
            return;
        }

        self.shipment.environment.vars = self.shipment.environment.vars.filter(function(variable) {
            if (variable.name !== key) {
                return variable;
            }
        });

        RiotControl.trigger('save_state', 'shipment', self.shipment);
        self.update();
    });

    RiotControl.on('retrieve_state_result', function (state) {
        if (state.page === 'variables') {
            d('shipyard/variables::retrieve_state_result', state);
            self.shipment = state.shipment;
            // we need to give the user a way to add thier own providers in the future
            if (!self.shipment.providers) {
                self.shipment.providers = [{
                    name: 'ec2',
                    replicas: 1,
                    barge: window.config.default_barge,
                    vars: []
                }];
            }

            self.shipment.providers[0].barge = utils.getDefaultBarge(self.shipment.providers[0].barge, self.shipment.main.group, window.config.barges);
            // make sure all ports and ENV vars are correct
            self.shipment.containers.forEach(function(container) {
                utils.setPorts(container, container.vars);
            });

            self.update();
        } else {
            self.shipment = null;
        }
    });
    </script>

    <style scoped>
        .empty-box {
            height: 100px;
        }
    </style>
</variables>
