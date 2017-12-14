<bridge_shipment_status>
    <div class="row" if="{ !running }">
        <div class="col s12 { warn_colors } white-text">
            <h4>{ warn_message }</h4>
            <p if="{ phase != 'Unknown' }">This shipment is currently in a failure mode and is not running correctly.</p>
            <p if="{ phase != 'Running' && phase != 'Unknown' }">Status phase: { phase }</p>
            <p if="{ restarts > 0 }">Average restarts across all Containers: { restarts }</p>
            <p each="{ conditions }">
                Condition ({ type } &ndash; { status })<br />
                { reason }:
                { message }
            </p>
            <ol>
                <li each="{ containers }">
                    <span if="{ restarts > 0 }">Restarts: { restarts }</span>
                    <pre>{ JSON.stringify(state, null, '  ') }</pre>
                </li>
            </ol>
            <p if="{ phase != 'Unknown' }">
                <button id="view-shipment-status-events-btn" class="btn red lighten-1 waves-effect" onclick="{ viewStatusEvents }">
                    View Shipment Status Events
                </button>
            </p>
            <p if="{ phase == 'Unknown' }">
                The Barge does not know about this Shipment. This could because you have not triggered or becuase you have the wrong barge set.
            </p>
        </div>
    </div>

    <div id="events-modal" class="modal">
        <div class="modal-content">
            <h4>Status Events</h4>
            <div class="row">
                <div class="col s12 { type }" each="{ events }">
                    <div if="{ reason != 'MissingClusterDNS' }">
                        <h5>{ reason }</h5>
                        <p>{ message }</p>
                        <p if="{ count > 0 }">Count: { count }</p>
                    </div>
                </div>
                <div class="col s12 { type }" if="{ events.length < 1 }">
                    <h5>No events to show at this time.</h5>
                </div>
            </div>
        </div>
    </div>

    <style>
    .Warning {
        background-color: #ef9a9a;
        margin-bottom: 5px;
    }

    .Normal {
        background-color: #a5d6a7;
        margin-bottom: 5px;
    }
    </style>

    <script>
    var self = this,
        d = utils.debug;

    self.phase        = '';
    self.events       = [];
    self.running      = true;
    self.fetching     = false;
    self.shipment     = null;
    self.namespace    = '';
    self.conditions   = [];
    self.containers   = [];
    self.warn_colors  = 'red darken-4';
    self.warn_message = 'Shipment Failure';

    viewStatusEvents(evt) {
        if (self.shipment) {
            $('#view-shipment-status-events-btn').addClass('disabled');
            d('bridge_shipment_status::fetch_shipment_status_events', self.barge, self.shipment.parentShipment.name, self.shipment.name);
            RiotControl.trigger('fetch_shipment_status_events', self.barge, self.shipment.parentShipment.name, self.shipment.name);
        }
    }

    function isNotRunning() {
        var replicas = 0;

        self.parent.shipment.providers.forEach(function (provider) {
            replicas += provider.replicas;
        });

        return replicas < 1;
    }

    RiotControl.on('shipment_status_clear', function() {
        self.running = true;
    });

    RiotControl.on('get_shipment_status', function (shipment) {
        d('bridge_shipment_status::get_shipment_status', shipment);
        self.running = true;
        self.shipment = shipment;
        self.barge = utils.getBarge(shipment);

        if (!self.fetching) {
            self.fetching = true;
            RiotControl.trigger('fetch_shipment_status', self.barge, shipment.parentShipment.name, shipment.name);
        }
    });

    RiotControl.on('shipment_status_result', function (data) {
        d('bridge_shipment_status::shipment_status_result', data);
        self.phase = data.status.phase;
        self.fetching = false;
        self.restarts = data.averageRestarts;
        self.conditions = data.status.conditions;
        self.containers = data.status.containers;

        if (self.phase !== 'Running') {
            self.running = false;
        }

        if (self.phase === 'Unknown' && isNotRunning()) {
            // Kube doesn't know about, and replicas are 0, this isn't running
            self.warn_colors  = 'amber darken-3';
            self.warn_message = 'Shipment Not Running';
        }

        if (data.averageRestarts > 50) {
            self.running = false;
        }

        self.update();
    });

    RiotControl.on('shipment_status_events_result', function (data) {
        d('bridge_shipment_status::shipment_status_result', data);
        self.events = data.events;
        self.update();

        $('#events-modal').openModal();
        $('#view-shipment-status-events-btn').removeClass('disabled');
    });
    </script>
</bridge_shipment_status>
