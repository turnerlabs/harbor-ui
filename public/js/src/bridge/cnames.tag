<cnames>
    <div if="{ lbType == 'alb-ingress' }">
        <h4>CNAMES</h4>
        <p>When using a Shared Load Balancer, add CNAMES that should be placed on the Load Balancer to correctly direct
            traffic to the Shipment Environment. These CNAMES <em>must</em> also be setup with your DNS provider (such as Route 53).</p>
        <div class="row">
            <div class="col s12">
                <ul class="collection">
                    <li class="collection-item" each="{ url in shipment.cnames }">
                        <button class="btn-floating red right" onclick="{ removeCname }"><i class="material-icons">delete</i></button>
                        <input class="cnames" type="text" value="{ url }" />
                    </li>
                    <li class="collection-item">
                        <input id="add-cname" type="text" placeholder="Add new CNAME (e.g., foo.example.com)" />
                        <button class="btn btn-sm" onclick="{ addCname }">Add</button>
                    </li>
                </ul>
            </div>
            <div class="col s12">
                <button class="btn" onclick="{ saveCnames }" disabled="{ !dirty }">Save CNAMES</button>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        loaded = false;

    self.lbType = null;
    self.dirty = false;

    addCname(evt) {
        var url = $('#add-cname').val();

        self.dirty = true;
        self.shipment.cnames.push(url);
        $('#add-cname').val('');

        RiotControl.trigger('send_metric', 'bridge.cname.add');
    }

    removeCname(evt) {
        var url = $(evt.target).parent().parent().find('.cnames').val(),
            idx = self.shipment.cnames.indexOf(url);

        d('bridge/cnames::removeCname', idx, url);
        self.shipment.cnames.splice(idx, 1);
        self.dirty = true;

        RiotControl.trigger('send_metric', 'bridge.cname.remove');
    }

    saveCnames(evt) {
        var urls = $('.cnames').map(function () {
                return $(this).val();
            }).toArray();

        var shipmentUrl = self.shipment.parentShipment.name + '/environment/' + self.shipment.name;

        d('bridge/cnames::saveCnames', urls);

        self.dirty = false;
        RiotControl.trigger('shipit_update_value', shipmentUrl, {cnames: urls});
        RiotControl.trigger('send_metric', 'bridge.cname.save');
    }

    RiotControl.on('cnames_loaded', function (shipment) {
        self.shipment = shipment;

        self.shipment.containers.forEach(function (container) {
            container.ports.forEach(function (port) {
                if (port.primary) {
                    self.lbType = port.lbtype;
                }
            });
        });

        d('bridge/cnames::cnames_loaded', self.lbType)
        self.update();
    });

    self.on('update', function () {
        if (self.opts.shipment && !loaded) {
            loaded = true;
            RiotControl.trigger('cnames_loaded', self.opts.shipment);
        }
    });
    </script>
</cnames>
