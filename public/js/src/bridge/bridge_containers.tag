<bridge_containers>
    <div class="row valign-wrapper">
        <div class="col s8">&nbsp;</div>
        <div class="col s2 right-align valign">
            <input type="checkbox" id="edit-btn-containers" onclick="{ toggleEditMode }"/>
            <label for="edit-btn-containers">Edit mode</label>
        </div>
        <div class="col s2 right-align valign">
            <button class="btn trigger-containers-btn" onclick="{ triggerShipment }">Trigger</button>
        </div>
    </div>

    <div class="row" each="{ container, i in shipment.containers }">
        <div class="col s12">
            <bridge_container container="{ container }" onlyread="{onlyread}"/>
        </div>
    </div>
    <div if={ shipment.containers.length < 1 }>
        <div class="card amber">
            <div class="card-content black-text">
                <span class="card-title">Warning</span>
                <p>There are no Containers set on this Shipment. Shipments
                    must have at least one Container to be able to be run.</p>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col s12">
            <button class="btn add-containers-btn btn-disable modal-trigger" data-target="container-modal" disabled={ onlyread } onclick="{ addContainer }">Add Container</button>
        </div>
    </div>

    <div id="container-modal" class="modal modal-fixed-footer">
        <container_modal></container_modal>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.newContainer = {};
    self.onlyread = true;

    toggleEditMode(evt) {
        d('bridge/containers::toggleEditMode');
        self.onlyread = !self.onlyread;
        RiotControl.trigger('bridge_container_toggle_edit_mode', self.onlyread);
    }

    triggerShipment(evt) {
        d('bridge/bridge_containers::triggerShipment');
        if (!self.shipment) {
            return;
        }

        self.shipment.providers.forEach(function(provider) {
            RiotControl.trigger('bridge_shipment_trigger', self.shipment.parentShipment.name, self.shipment.name, provider.name);
        });

        self.triggering = true;
        self.update();
    }

    addContainer(evt) {
        d('bridge_containers::addContainer');
        RiotControl.trigger('get_containers');
    }

    RiotControl.on('container_created', function (container, port) {
        d('bridge_containers::container_created', container, port);
        $('.modal-action').attr('disabled', false);
        $('#container-modal').closeModal();

        if (container && port) {
            container.version = container.image.split(':')[1];
            container.envVars = [];
            container.ports = [];
            container.ports.push(port);

            self.shipment.containers.push(container);
            self.update();
        }
    });

    RiotControl.on('container_deleted', function (container) {
        d('bridge_containers::container_deleted', container, self.shipment.containers)

        if (container) {
            var idx = -1;

            self.shipment.containers.forEach(function (c, i) {
                if (container === c.name) {
                    idx = i;
                }
            });

            if (idx >= 0) {
                self.shipment.containers.splice(idx, 1);
                self.update();
            }
        }
    });

    self.on('update', function () {
        self.shipment = self.opts.shipment;
    });

    self.on('mount', function () {
        $('.modal-trigger').leanModal();
    });
    </script>
</bridge_containers>
