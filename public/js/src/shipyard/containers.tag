<containers>
<div class="container">
    <h4>Step 2: Select Docker Container</h4>

    <div id="tabs-container">
        <div class="card blue-grey lighten-4">
            <div class="card-content black-text">
                <p>To get started, we need the container for the shipment.</p>
                <p>Select the Container and Version. <span class="info">This is also known as a Docker Image.</span></p>
                <p>These docker images are pulled directly from <strong><a href="{ view.catalogitUrl }">CatalogIt</a></strong>.
                <p>If you do not see your contianer here, update the Harbor Container Catalog, then you will be able to select it here.</p>
                <p>Visit <a href="{ view.catalogitDocsUrl }">the API docs for CatalogIt</a> for more information.</p>
            </div>
        </div>
        <button class="btn prev-btn" onclick={ addContainer }>Add Container</button>
        <div class="container" each="{container in shipment.containers}">
            <shipit_container container="{container}" images="{registryImages}"></shipit_container>
        </div>
        <div class="fake-container"if="{ shipment.containers.length == 0 }">
          <div class="card amber">
              <div class="card-content black-text">
                  <span class="card-title">Notification</span>
                  <p>You can continue without adding a contianer. If you want to just create the shipment
                    and add the contianer later. Just continue...
                  </p>
              </div>
          </div>
        </div>
    </div>

    <button class="btn prev-btn" onclick={ prevStep }>Prev Step: Shipment Info</button>
    <button class="btn next-btn" onclick={ nextStep }>Next Step: { view.linkInfoText }</button>
</div>

    <script>
    var self = this,
        d = utils.debug,
        retrievedState = false;

    self.view = {
        linkInfoText: 'Environment Variables',
        linkInfoPath: 'shipyard/variables',
        catalogitUrl: window.config.catalogit_url,
        catalogitDocsUrl: 'http://blog.harbor.services.dmtio.net/docs/catalogit-api/'
    };
    self.versions;

    nextStep(evt) {
        d('shipyard/containers::nextStep', self.linkInfo);

        if (validate()) {
            riot.route(self.view.linkInfoPath);
        }
    }

    prevStep(evt) {
        d('shipyard/containers::prevStep');
        riot.route('shipyard/info');
    }

    addContainer(evt) {
        d('shipyard/containers::addContainer');
        self.shipment.containers.push({});
    }

    function validate() {

        var valid = true,
            container;


        if (self.shipment.containers.length === 1) {
            container = self.shipment.containers[0];

            if (contianer.ports) {

                if (container.ports.length <= 0) {
                    RiotControl.trigger('flash_message', 'error', 'You must have at least one port object.', 30000);
                    valid = false;
                }

                container.ports.map(function(port) {
                    if (port.external) {
                        if (!port.healthcheck) {
                            RiotControl.trigger('flash_message', 'error', port.name + ':External ports must have a Healthcheck.', 30000);
                            valid = false;
                        }
                    }

                    if (!port.value) {
                        RiotControl.trigger('flash_message', 'error', port.name + ': Port Value must be set.', 30000);
                        valid = false;
                    }

                    if (port.healthcheck && port.healthcheck.substring(0,1) !== '/') {
                        RiotControl.trigger('flash_message', 'error', port.name + ':Healthcheck must start with a /', 30000);
                        valid = false;
                    }
                });
            }
        }

        return valid;
    }

    self.on('mount', function () {
        d('shipyard/containers::mount');
        RiotControl.trigger('get_containers');
        self.update();
    });

    self.on('update', function () {

        if (!retrievedState) {
            return;
        }

        RiotControl.trigger('save_state', 'shipment', self.shipment);
    });

    RiotControl.on('get_containers_result', function (results) {
        d('shipyard/containers::get_containers_result', results);
        self.registryImages = results;
        self.update();
    });

    RiotControl.on('retrieve_state_result', function (state) {

        self.shipment = state.shipment || {};
        self.shipment.containers = self.shipment.containers || [];
        retrievedState = true;
        self.update();
    });

    </script>

    <style scoped>
         .fake-container {
           height: 250px;
         }
    </style>
</containers>
