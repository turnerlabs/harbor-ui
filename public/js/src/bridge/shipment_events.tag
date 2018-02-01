<shipment_events>
    <div if="{ running }" class="row">
        <div class="col s12">
            <p if="{ !show }">There are no event messages at this time. Which is an indication that the containers are running smoothly.</p>
            <p if="{ show }">There are event messages. This could be an indication that there are issues with the Shipment.</p>
            <ul if="{ show }" class="collection">
                <li each="{ event in events }" class="collection-item { typeToClass(event.type) }" style="padding-right: 85px;">
                    <span class="badge grey lighten-2" >count: { event.count }</span> { event.message }
                    <br><em>Last event { moment(event.lastTimestamp).fromNow() }.</em>
                </li>
            </ul>
            <p if="{ lastRun }" class="grey-text lighten-2">Last check was at { lastRun }.</p>
        </div>
    </div>
    <div if="{ !running && !show }">
        <loading_elm></loading_elm>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        interval;

    self.show    = false; // there is data to show
    self.running = false; // this should be checking on an interval

    self.typeToClass = function (state) {
        var colors = '';

        switch (state) {
            case 'Normal':
                colors = ''; break;
            case 'Warning':
            default:
                colors = 'red lighten-2'; break;
        }

        return colors;
    }

    RiotControl.on('get_shipment_events', function (shipment) {
        d('bridge/shipment_events::get_shipment_events', shipment);
        self.running = true;
        self.shipment = shipment;
        self.barge = utils.getBarge(shipment);

        // fetch now
        RiotControl.trigger('fetch_shipment_events', self.barge, shipment.parentShipment.name, shipment.name);
        // fetch later (5 minutes)
        interval = setInterval(function () {
            RiotControl.trigger('fetch_shipment_events', self.barge, shipment.parentShipment.name, shipment.name);
        }, 1000 * 60 * 5);
    });

    RiotControl.on('app_changed', function (page, one, two) {
        if (self.running) {
            d('bridge/shipment_events::app_changed(turn-off)', page, one, two);
            clearInterval(interval);
            self.running = false;
            self.show = false;
        }
        if (page === 'bridge' && two === 'overview' && !self.running && self.shipment) {
            d('bridge/shipment_events::app_changed(turn-back-on)', page, one, two);
            RiotControl.trigger('get_shipment_events', self.shipment);
        }
    });

    RiotControl.on('fetch_shipment_events_result', function (data) {
        d('bridge/shipment_events::fetch_shipment_events_result', data);

        self.lastRun = moment().format("h:mm:ss a \on MMM. D YYYY");

        if (data.namespace === self.shipment.parentShipment.name +'-'+ self.shipment.name) {
            if (data.events.length > 0) {
                self.show = true;

                self.events = data.events.sort(eventSort).filter(function (evt) {
                    return evt.reason !== 'MissingClusterDNS'
                });
            }
            else {
                self.show = false;
            }
        }

        self.update();
    });

    function eventSort(a, b) {
        if (a.lastTimestamp > b.lastTimestamp) {
            return -1;
        }
        else if (a.lastTimestamp < b.lastTimestamp) {
            return 1;
        }
        else {
            return 0;
        }
    }

    </script>

    <style scoped>
    em {
        font-size: smaller;
    }
    .collection {
        max-height: 250px;
        overflow: auto;
    }
    </style>
</shipment_events>
