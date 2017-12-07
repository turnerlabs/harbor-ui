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
    <div if="{ !helm.error && helm.replicas.length }">
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

    RiotControl.on('update_logs_result', function (data) {
        d('bridge/container_status::update_logs_result', data);

        if (data.replicas) {
            data.replicas = data.replicas.map(function (replica) {
                replica.containers = replica.containers.map(function (container) {
                    container.imageDisplay = container.image.replace(/[\w\S]+\//, '');
                    return container;
                });
                return replica;
            });
        }

        self.helm = data;
        self.update();
    });

    RiotControl.on('shipment_status_result', function (data) {
        d('bridge_shipment_status::shipment_status_result', data);
        self.containers = data.status.containers;
        self.update();
    });
    </script>
</container_status>
