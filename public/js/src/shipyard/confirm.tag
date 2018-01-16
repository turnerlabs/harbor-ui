<confirm>
    <div id="confirm" class="container">

        <h4>Step 4: Confirm</h4>
        <div class="card blue-grey lighten-4">
            <div class="card-content black-text">
                <p>Confirm that the information you've provided is correct. You can change this information later, but better to double check now.</p>
            </div>
        </div>

        <div class="argo-tabs">
            <h4>Shipment Variables</h4>
            <dl each="{envVar in shipment.main.vars}">
                <dt>{envVar.name}</dt>
                <dd>{ envVar.value }</dd>
            </dl>
            <p><a class="btn" href="#shipyard/info">Edit Basic Information</a></p>

            <h5>Environment Variables</h5>
            <dl each="{envVar in shipment.environment.vars}">
                <dt>{envVar.name}</dt>
                <dd>{ envVar.value }</dd>
            </dl>
            <p><a class="btn" href="#shipyard/variables">Edit Variables</a></p>

            <h5>Provider Values</h5>
            <dl each="{provider in shipment.providers}">
                <dt>Name</dt>
                <dd>{provider.name}</dd>
                <dt>Replicas</dt>
                <dd>{provider.replicas}</dd>
                <dt>Barge</dt>
                <dd>{provider.barge}</dd>
            </dl>
            <p><a class="btn" href="#shipyard/variables">Edit Variables</a></p>

            <h4>Docker Containers</h4>
            <dl each="{container in shipment.containers}">
                <dt>Container Name</dt>
                <dd>{ container.name }</dd>
                <dt>Version</dt>
                <dd>{ container.version }</dd>
                <dt>Image Url</dt>
                <dd>{ container.image }</dd>
                <dt each="{port in container.ports}">Port Name: {port.name}:{port.value}</dt>
            </dl>
            <p><a class="btn" href="#shipyard/containers">Edit Docker Containers</a></p>


            <div if={ good }>
                <button  class="btn next-btn" onclick={ create }>Create Shipment!</button>
            </div>
            <div if={ !good }>
                There are one or more problems with the shipment data provided.
                <button class="btn" onclick={ prevStep }>Previous Step: Edit Varibles</button>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.good;
    self.state;
    self.config;
    self.stores;

    create(evt) {
        d('shipyard/confirm::create');
        RiotControl.trigger('save_state', self.state);
        RiotControl.trigger('send_metric', 'shipyard.create.start');
        riot.route('shipyard/create');
    }

    prevStep(evt) {
        d('shipyard/confirm::prevStep');
        riot.route('shipyard/variables');
    }

    function checkIssues() {

        if (!self.shipment) {
            return;
        }

        self.good = true;

        var i,
            keys,
            issues = {
                CUSTOMER: true,
                PROJECT: true,
                PROPERTY: true,
                PRODUCT: true
            };

        self.shipment.main.vars.map(function(variable) {
            if(issues[variable.name]) {
                issues[variable.name] = false;
            }
        });

        for (var key in issues) {
            if (issues[key]) {
                RiotControl.trigger('flash_message', 'error', key + ': Environment variables is missing', 30000);
                self.good = false;
            }
        }

        if (!self.shipment.environment || !self.shipment.environment.name) {
            RiotControl.trigger('flash_message', 'error', 'Environment object is missing.', 30000);
            self.good = false;
        }

        if ((self.shipment.main.name + '-' + self.shipment.environment.name).length > 63) {
            RiotControl.trigger('flash_message', 'error', 'The combination of Shipment and Environment as a name is too long. It must be less than 63 characters.', 30000);
            self.good = false;
        }

        self.update();
    }

    self.on('mount', function () {
        d('shipyard/confirm::mount');
    });

    self.on('update', function () {
    });

    RiotControl.on('retrieve_state_result', function (state) {
        if (state.page === 'confirm') {
            d('shipyard/confirm::retrieve_state_result', state);
            self.shipment = state.shipment;
            checkIssues();
            self.update();
        }
    });
    </script>

    <style scoped>
    .help {
        margin: 0 25px;
        font-size: 11px;
        color: #DCDCDD;
    }

    .issue {
        border-bottom: 2px solid #F44336;
        box-shadow: 0 1px 0px #F44336;
        width: 250px;
    }

    dt {
        font-weight: bolder;
        font-size: 16px;
    }
    </style>
</confirm>
