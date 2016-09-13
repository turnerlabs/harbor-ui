<bridge_shipment_list>
        <div class="container">

            <div if="{ allowedShipments.length === 0}">
                <no_groups_found></no_groups_found>
            </div>

            <div if="{ allowedShipments.length > 0}">

                <div class="row">
                    <div class="input-field col s6">
                      <i class="material-icons prefix">search</i>
                      <input name="searchTextElm" id="search" placeholder="Search..." type="text" onkeyup="{ updateSearchText }">
                    </div>
                </div>

                <div class="collection">
                    <div each="{ group in allowedShipments.filter(textFilter) }" class="collection-item">
                        <h5 name="shipment-{ group.name }" onclick={ toggleShipment }>{ group.name }</h5>
                        <div class="collection {isSearching} shipment-{ group.name }">
                            <div class="collection-item" each={ shipment in group.shipments.filter(shipmentFilter) }>
                                <h4>{ shipment.name }</h4>
                                <ul class="link-list">
                                    <li each={ environment in shipment.environments } class="indented"><a href="#bridge/{ parent.shipment.name }/{ environment }">{ environment }</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <loading_elm if={ loading } isloading="{ loading }"></loading_elm>
        </div>

    <script>
    var self = this,
        d = utils.debug;

    self.customers;
    self.shipments;
    self.allowedShipments;
    self.environments = [];
    self.currentEnv = 'prod';
    self.isSearching = 'closed';

    textFilter (shipment) {
        var shipmentKeys,
            show = false;
        if (self.searchText) {
            self.isSearching = '';
            shipments = shipment.shipments;
            if (shipment.name.indexOf(self.searchText) > -1) {
                show = true;
            } else {
                show = self.shipmentFilter(shipments)
            }
        } else {
            self.isSearching = 'closed';
            show = true;
        }

        return show;
    }

    envFilter (shipments) {
        return true;
    }

    shipmentFilter(shipments) {
        var show = false;

        if (self.searchText) {
            if (shipments.filter) {
                shipments.forEach(function(ship) {
                    if (ship.name.indexOf(self.searchText) > -1) {
                        show = true;
                    }
                });
            } else {
                show = shipments.name.indexOf(self.searchText) > -1
            }
        } else {
            show = true;
        }

        return show;
    }

    updateSearchText(e) {
        self.searchText = e.target.value;
    }

    toggleShipment(evt) {
        d('bridge/shipment_list::toggleShipment', evt.item.name);
        var name = '.' + evt.target.getAttribute('name');
        $(name).slideToggle({ easing: 'linear' });
    }

    self.on('mount', function () {
        d('bridge/shipment_list::mount');

        // may have both of these, if not show loading spinner
        if (!self.customers || !self.shipments) {
            self.loading = true;
            self.update();
        }
    });

    RiotControl.on('shipment_list_filtered', function (list) {
        self.shipments = list;
        self.update();
    });

    RiotControl.on('get_user_groups_result', function (data) {
        d('bridge/shipment_list::get_user_groups_result', data);
        self.customers = data.groups;
        RiotControl.trigger('check_shipment_list');
    });

    RiotControl.on('get_shipments_result', function (shipments) {
        d('bridge/shipment_list::get_shipments_result', shipments);
        self.shipments = shipments;

        RiotControl.trigger('check_shipment_list');
    });

    RiotControl.on('check_shipment_list', function () {
        if (self.customers && self.shipments) {
            d('bridge/shipment_list::check_shipment_list', self.customers, self.shipments);
            var keys = Object.keys(self.shipments),
                shipmments,
                enviromnets,
                allowed,
                key,
                i;

            self.allowedShipments = [];

            for (i = 0; i < self.customers.length; i++) {
                if (keys.indexOf(self.customers[i].name) !== -1) {
                    key = self.customers[i].name;
                    shipments = getNewShipments(self.shipments[key]);
                    environments = shipments[1];
                    shipments = shipments[0];
                    self.allowedShipments.push({name: key, shipments: shipments});

                    self.environments = self.environments.concat(environments);

                }
            }

            self.allowedShipments = self.allowedShipments.sort(function(a, b) {
                if (a.name < b.name) {
                    return -1;
                } else {
                    return 1;
                }
            });

            RiotControl.trigger('get_groups_result', self.allowedShipments);

            self.loading = false;
            self.update();
        }
    });

    /**
     * gets a structured shipment list from an object. This way we can sort the list correctly.
     *
     * @param  {Object} shipments The raw shipments from catalogit.
     *
     * @return {Array}  [shipments that can be sorted by shipment name, environments found]
     */
    function getNewShipments(shipments) {
        var newShipments = [],
            envs = [];

        for (var key in shipments) {

            shipments[key].forEach(function(env) {
                if (envs.indexOf(env) === -1) {
                    envs.push(env);
                }
            });

            newShipments.push({name: key, environments: shipments[key], envs: envs});

        }

        return [newShipments, envs];
    }

    </script>

    <style scoped>

    .closed {
        display: none;
    }

    h5 {
        cursor: pointer;
    }
    </style>
</bridge_shipment_list>
