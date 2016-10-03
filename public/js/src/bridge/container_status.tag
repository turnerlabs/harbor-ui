<container_status>
    <loading_elm if="{ !helm }"></loading_elm>

    <div if="{ !helm.error && helm.replicas.length }">
        <table>
            <thead>
                <tr>
                    <th>Host</th>
                    <th>Replica</th>
                    <th>Phase</th>
                    <th>Container</th>
                    <th>State</th>
                    <th>Restarts</th>
                </tr>
            </thead>

            <tbody each="{replica in helm.replicas.sort(sortReplicas)}">
                <tr each="{container in replica.containers.sort(sortContainers)}">
                    <td>{ replica.host }</td>
                    <td>{ replica.name }</td>
                    <td class="{ getColor(replica.phase) }">{ replica.phase }</td>
                    <td>{ container.id.slice(0, 32) }</td>
                    <td class="{ getColor(container.state )}">{ container.state }</td>
                    <td class="{ checkRestarts(container.restartCount) }">{ container.restartCount }</td>
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

    RiotControl.on('update_logs_result', function (data) {
        d('bridge/container_status::update_logs_result', data);

        self.helm = data;
        self.update();
    });
    </script>
</container_status>