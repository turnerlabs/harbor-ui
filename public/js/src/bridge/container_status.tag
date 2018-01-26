<container_status>
    <loading_elm if="{ !helm }"></loading_elm>
    <div if="{ !helm.replicas }">
      <div class="card red">
          <div class="card-content black-text">
              <span class="card-title">Error</span>
              <p>There was an error fetching container data.</p>
          </div>
      </div>
    </div>
    <div if="{ !helm.error && helm.replicas.length }" class="status-window">
        <table class="highlight">
            <thead>
                <tr>
                    <th>Host</th>
                    <th>Replica</th>
                    <th>Phase</th>
                    <th>Container</th>
                    <th>Image</th>
                    <th>State</th>
                    <th>Restarts</th>
                    <th>Last Restart</th>
                </tr>
            </thead>

            <tbody each="{ replica in helm.replicas.sort(sortReplicas) }">
                <tr each="{ container in replica.containers.sort(sortContainers) }">
                    <td>{ replica.host }</td>
                    <td title="{ replica.name }">{ replica.name.replace('thedeployment-', '') }</td>
                    <td class="{ getColor(replica.phase) }">{ replica.phase }</td>
                    <td title="{ container.id }">{ container.id.slice(0, 7) }</td>
                    <td title="{ container.image }">{ container.imageDisplay }</td>
                    <td class="{ getColor(container.state )}">{ container.state }</td>
                    <td class="{ checkRestarts(container.restartCount) } center">{ container.restartCount }</td>
                    <td center>{ getLastRestarts(container.id) }</td>
                </tr>
            </tbody>
        </table>

        <p>The Shipment status at times will show that the phase and state are running, but your
            Shipment isn't working the way you intended. This is because the information that is
            being displayed is how the orchestration backend is handling your Shipment. It does not
            indicate the actual health of your application.</p>
    </div>

    <div if="{ !helm.replicas.length }">
        The Shipment has no running replicas.
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.helm;
    self.barge;
    self.route;
    self.interval;
    self.loadState;
    self.sortReplicas    = utils.sortReplicas;
    self.sortContainers  = utils.sortContainers;

    getColor(stage) {
        var clr;
        switch (stage) {
        case 'running':
        case 'succeeded':
            clr = 'green';
            break;

        case 'pending':
            clr = 'amber';
            break;

        case 'failed':
            clr = 'red';
            break;

        case 'unknown':
        default:
            clr = 'grey';
            break;
        }

        return clr + '-text';
    }

    checkRestarts(count) {
        var clr;

        if (count >= 50) {
            clr = 'red';
        } else if (count < 50 && count > 10) {
            clr = 'amber';
        } else {
            clr = 'black';
        }

        return clr + '-text';
    }

    getLastRestarts(id) {
        var lastRestart;
        self.containers.map(function(container) {
            if (container.id === id && container.lastState && container.lastState.terminated) {
                lastRestart = new Date(container.lastState.terminated.finishedAt).toLocaleString();
            }
        });

        return lastRestart || 'No Restarts';
    }

    RiotControl.on('get_shipment_model_result', function (caller, shipment) {
        if (caller === 'container_status') {
            d('bridge/container_status::get_shipment_model_result', self.route, shipment);
            if (self.route && self.route.shipment && self.route.environment && self.loadState === 'gettingShipmentInfo') {
                self.barge = utils.getBarge(shipment);
                self.loadState = 'loading';

                // Fire off for shipment status immediately
                RiotControl.trigger('get_container_status', self.barge, self.route.shipment, self.route.environment);

                // Setup interval for another container status
                if (self.barge) {
                    self.interval = setInterval(function () {
                        RiotControl.trigger('get_container_status', self.barge, self.route.shipment, self.route.environment);
                    }, 5 * 1000);
                }
            }
        }
    });

    RiotControl.on('toggle_container_status_interval', function (toggle, route) {
        d('bridge/container_status::toggle_container_status_interval', toggle, route);
        self.route = route;

        if (toggle && !self.loadState) {
            d('bridge/container_status::toggle_container_status_interval::toggle ON', route.shipment, route.environment);
            self.loadState = 'gettingShipmentInfo';
            // Turn on the container status interval
            RiotControl.trigger('get_shipment_model', 'container_status', route.shipment, route.environment);
        }
        else if (!toggle && self.loadState) {
            d('bridge/container_status::toggle_container_status_interval::toggle OFF');
            // Turn off the container status interval
            self.helm = null;
            self.barge = null;
            self.loadState = null;
            clearInterval(self.interval);
            self.update();
        }
    });

    RiotControl.on('get_container_status_result', function (helm) {
        d('bridge/container_status::get_container_status_result', helm);

        self.loadState = 'loaded';

        if (helm.replicas) {
            helm.replicas = helm.replicas.map(function (replica) {
                replica.containers = replica.containers.map(function (container) {
                    container.imageDisplay = container.image.replace(/[\w\S]+\//, '');
                    return container;
                });
                return replica;
            });
        }

        self.helm = helm;
        self.update();
    });
    </script>
    <style>
    .status-window {
        max-height: 750px;
        overflow: auto;
    }
    </style>
</container_status>
