<bridge_command>
    <div class="row">
        <div class="col s12">
            <ul id="command_bridge_tabs" class="tabs">
                <li class="tab col s2"><a href="#tabs-overview" value="overview" onclick="{ editUrl }">Overview</a></li>
                <li class="tab col s2"><a href="#tabs-env-vars" value="env-vars" onclick="{ editUrl }">Env Vars</a></li>
                <li class="tab col s2"><a href="#tabs-containers" value="containers" onclick="{ editUrl }">Containers</a></li>
                <li class="tab col s2"><a href="#tabs-audit" value="audit" onclick="{ editUrl }">Audit</a></li>
                <li class="tab col s2"><a href="#tabs-graphs" value="graphs" onclick="{ editUrl }">Graphs</a></li>
                <li class="tab col s2"><a href="#tabs-logs" value="logs" onclick="{ editUrl }">Logs</a></li>
                <li class="tab col s2"><a href="#tabs-cmds" value="cmds" onclick="{ editUrl }">Commands</a></li>
            </ul>
        </div>
    </div>

    <bridge_lb_status></bridge_lb_status>
    <bridge_shipment_status></bridge_shipment_status>

    <copy_shipment_modal targetid="copyModal" shipment="{ shipment }"></copy_shipment_modal>

    <div class="row valign-wrapper">
        <div class="col s9 valign">
            <h2>{ shipment.parentShipment.name } :: { shipment.name }</h2>
        </div>
        <div class="col s3 valign">
            <p>Pick another Environment<br/><select class="bridge-environment-select" onchange={ pickEnvironment } style="width: 100%">
                <option each={ environments }
                        selected={ name === this.parent.shipment.name }
                        value={ path }>{ name }</option>
            </select></p>
        </div>
    </div>

    <div id="tabs-overview">
        <div class="row">
            <div class="col s10">&nbsp;</div>
            <div class="col s2 right-align valign">
                <a class="{ btn: true, disabled: triggering }" onclick="{ triggerShipment }" title="Will trigger the Shipment">Trigger</a>
            </div>
        </div>

        <h4>Service</h4>
        <div class="row">
            <div each={ service in shipment.providers.map(getViewServices) }>
                <div each={ link in service.links }>
                    <p class="col s2">{ service.provider } ({ link.proto })</p>
                    <p if={ link.linkable} class="col s10"><a href="{ link.href }" target="_blank">{ link.href }</a></p>
                    <p if={ !link.linkable } class="col s10">{ link.href }</p>
                </div>
            </div>
        </div>

        <h4>Container Versions</h4>
        <div each={ container, idx in shipment.containers }>
            <bridge_container_version container="{ container }" idx="{ idx }"></bridge_container_version>
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

        <h4>Provider Information</h4>
        <div each={ service in shipment.providers.map(getViewServices) }>
            <bridge_providers shipment="{ parent.shipment }" service="{ service }"></bridge_providers>
        </div>
        <div if={ shipment.providers.length < 1 }>
            <div class="card amber">
                <div class="card-content black-text">
                    <span class="card-title">Warning</span>
                    <p>There are no Providers set on this Shipment. Shipments
                        must have at least one Provider to be able to be run.</p>
                </div>
            </div>
            <button class="btn" onclick="{addProvider}">Add Ec2 as a Provider</button>
        </div>

        <h4>Shipment Status</h4>
        <container_status></container_status>

        <h4>Group</h4>
        <p>The group value of your Shipment impacts who is authorized to make edits to all Environments
            within the Shipment.</p>
        <div class="row">
            <p class="col s4">{ shipment.parentShipment.group }</p>
            <p class="col s4 valign"></p>
            <p class="col s4">
                <select class="group-select" style="width: 100%" onchange="{ pickGroup }">
                    <option each={ group in groups }
                            selected="{ group.name == parent.shipment.parentShipment.group }"
                            value={ group.name }>{ group.name }</option>
                </select>
            </p>
        </div>

        <h4>Info</h4>
        <div class="row">
            <p class="col s2">ShipIt</p>
            <p class="col s10"><a href="{ view.shipit }" target="_blank">{ view.shipit }</a></p>

            <p class="col s2">ERP</p>
            <p class="col s10"><a href="{ view.erp }" target="_blank">{ view.erp }</a></p>

            <p class="col s2">Monitoring</p>
            <p class="col s10">
                <input type="checkbox" id="enableMonitoring" checked="{ checked: shipment.enableMonitoring }" onchange="{ updateMonitoring }" />
                <label for="enableMonitoring" style="color: #000;">Enable Monitoring</label>
            </p>

            <p class="col s2" if="{ shipment.buildToken }">Build Token</p>
            <p class="col s7" if="{ shipment.buildToken }">{ shipment.buildToken }</p>
            <p class="col s3 right-align" if="{ shipment.buildToken }"><button class="btn" onclick="{ rollToken }">Roll token</button></p>
        </div>

        <div class="row valign-wrapper">
            <p class="col s4 valign">
                <a id="delete-shipment-button" class="btn red {disableShipmentBtn}" onclick="{ deleteShipment }" title="Will permanently delete Shipment">Delete</a>
                <br><span class="grey-text text-lighten-1">Replicas must be set to zero and triggered to be able to delete a Shipment.</span>
            </p>
            <p class="col s4">&nbsp;</p>
            <p class="col s2 valign center-align"><a class="btn" onclick="{ showModal }" target="copyModal" title="Clone the current Shipment:Environment to a new Environment">Clone</a><br>&nbsp;</p>
            <p class="col s2 valign right-align"><a class="{ btn: true, disabled: triggering }" onclick="{ triggerShipment }" title="Will trigger the Shipment">Trigger</a><br>&nbsp;</p>
        </div>
    </div>

    <div id="tabs-env-vars">
        <bridge_env_vars shipment="{ shipment }"></bridge_env_vars>
    </div>

    <div id="tabs-containers">
        <bridge_containers shipment="{ shipment }"></bridge_containers>
    </div>

    <div id="tabs-cmds">
        <div class="row">
            <div if="{loading === false && !view.helm.error}" class="col s12" each="{container in shipment.containers}">
                <h4>{container.name}</h4>
                <ssh helm="{ view.helm }" container="{ container.name }" shipment="{ shipment }"></ssh>
            </div>
            <div if="{view.helm.error}">
                <h4>There are no running instances of this shipment.</h4>
                <p>{view.helm.msg}</p>
            </div>
        </div>
    </div>

    <div id="tabs-audit">
        <div class="row">
            <div if="{ loading === false && !view.helm.error }" class="col s12" each="{ log in shipment.audit_logs }">
                <audit_log log="{log}"></audit_log>
            </div>
            <div if="{ shipment.audit_logs.length == 0 }">
                <h4>There are no logs for this Shipment.</h4>
            </div>
        </div>
    </div>

    <div id="tabs-logs">
        <div class="row">
            <div class="col s3">
                <p>Data Refresh Interval<br>
                    <select class="interval-select" onchange={ updateMultiplier } style="width: 100%">
                        <option selected={ multiplier == 'stop' } value="stop">Stop</option>
                        <option selected={ multiplier == 1 } value="1">1</option>
                        <option selected={ multiplier == 5 } value="5">5</option>
                        <option selected={ multiplier == 10 } value="10">10</option>
                        <option selected={ multiplier == 20 } value="20">20</option>
                        <option selected={ multiplier == 30 } value="30">30</option>
                    </select></p>
            </div>
            <div if="{ !loading && !view.helm.error }" class="col s12" each="{replica in view.helm.replicas.sort(sortReplicas)}">
                <div class="col s12" each="{container in replica.containers.sort(sortContainers)}">
                    <h4>Container: {container.name}</h4>
                    <h5>Provider: {replica.provider}</h5>
                    <p>Host: {replica.host}</p>
                    <p>ID: {container.id}</p>
                    <logging logs="{ container.logs }" loggerId="{ container.id }"></logging>
                </div>
            </div>
            <div if="{ view.helm.error }">
                <h4>There are no running instances of this shipment.</h4>
                <p>{view.helm.msg}</p>
            </div>
        </div>
    </div>

    <div id="tabs-graphs">
        <div class="row" if="{ view.renderGraphs }">
            <div class="col s6">
                <span>
                    <input name="group1" type="radio" id="1_hour" checked="{checked: view.timeframe === '1_hour'}" onclick="{setTimeframe}" />
                    <label for="1_hour">Last 1 Hour</label>
                </span>
                <span>
                    <input name="group1" type="radio" id="4_hours" checked="{checked: view.timeframe === '4_hours'}" onclick="{setTimeframe}" />
                    <label for="4_hours">Last 4 Hours</label>
                </span>
                <span>
                    <input name="group1" type="radio" id="1_day" checked="{checked: view.timeframe === '1_day'}" onclick="{setTimeframe}" />
                    <label for="1_day">Last 24 Hours</label>
                </span>
            </div>
            <div class="col s6 right-align">
                Visit your
                    <a target="_blank" href="{datadogLink}&tpl_var_environment={shipment.name}&tpl_var_shipment={shipment.parentShipment.name}-{shipment.name}&tpl_var_product={shipment.parentShipment.name}">
                        DataDog Dashboard</a>.
            </div>
        </div>
        <div class="row" if="{ view.renderGraphs }">
            <div class="col s6 graphs center-align" each="{ graph in view.datadog_data[view.timeframe] }">
                <raw-html html="{ graph.html }" timeframe="{ view.timeframe }"></raw-html>
            </div>
            <div if="{ !view.datadog_data }">
                <h4>There are no graphs to view.</h4>
            </div>
        </div>
    </div>

    <loading_elm if={ loading || view.datadogLoading } isloading="{ loading || view.datadogLoading }"></loading_elm>

    <script>
    var self = this,
        d = utils.debug,
        config = window.config,
        view = {
            editText: 'Edit',
            onlyread: true,
            timeframe: '4_hours'
        },
        routed = false,
        lastDataDogRequest;

    self.view = view;
    self.environments;
    self.multiplier = config.updateInterval;
    self.barges = config.barges.split(',');
    self.datadogLink = config.data_dog_link;
    self.sortRepliacs = utils.sortReplicas;
    self.sortContainers = utils.sortContainers;
    self.disableShipmentBtn = '';
    self.loading = true;

    showModal(evt) {
        var target = evt.target.getAttribute('target');
        $('#' + target).openModal();
    }

    pickEnvironment(evt) {
        var tar = $(evt.target).val(),
            val = tar.split('/'),
            cur = window.location.hash,
            arr = cur.split('/'),
            url;

        if (arr.length == 4 && val.lenth != arr.length) {
            // Put the end of current path onto the target path
            val.push(arr.pop());
        }

        url = val.join('/');
        d('bridge/command::pickEnvironment', url);
        riot.route(url);
    }

    pickGroup(evt) {
        d('bridge/command::pickGroup');
        var val = $('.group-select').val(),
            url = self.shipment.parentShipment.name;

        self.shipment.parentShipment.group = val;
        RiotControl.trigger('shipit_update_value', url, {group: val}, 'PUT');
        self.update();
    }

    addProvider(evt) {
        var url = self.shipment.parentShipment.name + '/environment/' + self.shipment.name + '/providers',
            newProvider = {
                name: 'ec2',
                replicas: 1,
                barge: window.config.default_barge,
                envVars: []
            };

        self.shipment.providers.push(newProvider);
        RiotControl.trigger('shipit_update_value', url, newProvider, 'POST');
        self.update();
    }

    updateMultiplier(evt) {
        var val = $(evt.target).val();

        self.multiplier = val;
        self.update();
    }

    updateReplicas(evt) {
        var name = evt.target.name,
            url = self.shipment.parentShipment.name + '/environment/' + self.shipment.name + '/provider/' + name;

        for (var i = 0;i < self.shipment.providers.length;i++) {
            if (self.shipment.providers[i].name === name) {
                self.shipment.providers[i].replicas = evt.target.value;
            }
        }

        RiotControl.trigger('shipit_update_value', url, {replicas: parseInt(evt.target.value)}, 'PUT');
        self.update();
    }

    updateMonitoring(evt) {
        var val = $(evt.target).is(':checked'),
            url = self.shipment.parentShipment.name + '/environment/' + self.shipment.name;

        if (val) {
            self.shipment.enableMonitoring = true;
        } else {
            self.shipment.enableMonitoring = false;
        }
        RiotControl.trigger('shipit_update_value', url, { enableMonitoring: val }, 'PUT');
        self.update();
    }

    setTimeframe(evt) {
        var val = evt.target.id;
        if (val) {
          self.view.timeframe = val;
        }
        self.update();
    }

    editUrl(evt) {
        var val = evt.target.getAttribute('value'),
            hash = window.location.hash.split('/');

        hash[3] = val;
        window.location.hash = hash.join('/');
        if (val === 'graphs') {
            view.renderGraphs = true;
            setDataDogData();
            self.update();
        }
    }

    editShipment(evt) {
        view.onlyread = !view.onlyread;

        if (!view.onlyread) {
            view.editText = 'View';
        } else {
            view.editText = 'Edit';
        }

        $('#command_bridge_tabs').find('a[href="#tabs-info"]').trigger('click');

        self.update();
    }

    getViewServices(provider) {

        if (!self.shipment) {
            return;
        }

        var service = {
            provider: provider.name,
            replicas: provider.replicas,
            barge: provider.barge,
            providerObj: provider,
            links: []
        };

        self.shipment.containers.forEach(function(container) {
            container.ports.forEach(function(port) {
                var link = {};
                if (port.protocol === 'http' || port.protocol === 'https') {
                    link.linkable = true;
                }
                link.proto = port.protocol;
                link.href = [];
                link.href.push(port.protocol)
                link.href.push('://')
                link.href.push(self.shipment.parentShipment.name)
                link.href.push('.')
                link.href.push(self.shipment.name)
                link.href.push('.')
                link.href.push('services.')
                link.href.push(provider.name)
                link.href.push('.dmtio.net:')
                link.href.push(port.public_port || port.value)
                link.href.push(port.healthcheck)
                link.href = link.href.join('');
                service.links.push(link);
            });
        });

        return service;
    }

    triggerShipment(evt) {
        d('bridge/bridge_command::triggerShipment');
        if (!self.shipment) {
            return;
        }

        self.shipment.providers.forEach(function(provider) {
            var tooTrigger = true;
            if (provider.replicas === 0) {
              var question = confirm('Replicas are zero for provider: ' + provider.name + '. Triggering will Delete the running application and the LoadBalancer.');
              if (question === false) {
                  tooTrigger = false;
              }
            }

            if (tooTrigger) {
                RiotControl.trigger('bridge_shipment_trigger', self.shipment.parentShipment.name, self.shipment.name, provider.name);
                self.triggering = true;
                self.update();
            }
        });
    }

    scaleShipment(evt) {
        if (!self.shipment) {
            return;
        }

        self.shipment.providers.forEach(function(provider) {
            RiotControl.trigger('bridge_shipment_scale', self.shipment.parentShipment.name, self.shipment.name, provider.name);
        });

        self.scaling = true;
        self.update();
    }

    deleteShipment(evt) {
        if (!self.shipment || self.disableShipmentBtn === 'disabled') {
            return;
        }

        var msg = 'Are you sure you want to delete this Shipment?\nname:\t\t\t%s\nenvironment:\t\t%e\n\nThis cannot be undone!'.replace('%s', self.shipment.parentShipment.name).replace('%e', self.shipment.name),
            sure = window.confirm(msg);

        if (sure) {
            RiotControl.trigger('delete_shipment', self.shipment.parentShipment.name, self.shipment.name);
            self.update();
        } else {
            self.update();
        }
    }

    rollToken(evt) {
        if (confirm('Are you sure? Rolling a build token is a permanent action and cannot be undone.')) {
            RiotControl.trigger('roll_build_token', self.shipment.parentShipment.name, self.shipment.name);
        }
    }

    function checkDeleteButton() {

        if (!self.shipment || !view.helm) {
          return;
        }

        var total = self.shipment.providers.length,
            count = 0;

        self.shipment.providers.forEach(function(provider) {
            if (provider.replicas === 0) {
                count++;
            }
        });

        if (count === total && view.helm.msg && view.helm.msg.toLowerCase() === 'could not find product') {
            // All replicas are zero, so we can delete
            self.disableShipmentBtn = '';
        } else {
            self.disableShipmentBtn = 'disabled';
        }

        d('bridge/command/overview::checkDeleteButton `%s`', self.disableShipmentBtn);
    }

    RiotControl.on('bridge_shipment_trigger_result', function(result, err) {
        self.triggering = false;
        self.update();
    });

    RiotControl.on('bridge_shipment_scale_result', function(result, err) {
        self.scaling = false;
        self.update();
    });

    self.on('mount', function () {
        d('bridge/command::mount');

        RiotControl.trigger('retrieve_state');
        RiotControl.trigger('get_containers');

        setTimeout(function () {
            $('#command_bridge_tabs').tabs();
            $('.interval-select').select2();
        }, 100);
    });

    self.on('update', function () {
        if (routed) {
           updateInterval(self.multiplier);
           checkDeleteButton();
        }
    });

    RiotControl.on('command_bridge_loaded', function (loaded) {
        d('bridge/command::command_bridge_loaded', loaded)
        RiotControl.trigger('bridge_lb_status_start', self.shipment);
        self.loading = !loaded;
        self.update();
    });

    RiotControl.on('get_shipment_environments_result', function (environments) {
        d('bridge/command::get_shipment_environments_result', environments);
        self.environments = environments;
        setTimeout(function () { $('.bridge-environment-select').select2({val: self.shipment.name}); }, 1000);
        self.update();
    });

    RiotControl.on('get_helm_details_result', function (helm) {
        d('bridge/command::get_helm_details_result', helm);

        var i;

        view.helm = helm;

        if (view.helm.replicas && helm.replicas.length) {
            view.actual = helm.replicas.length;
            view.helm.replicas = helm.replicas;
        } else {
            self.actual = 0;
        }

        self.update();

        // Finshed loading
        RiotControl.trigger('command_bridge_loaded', true);
    });

    RiotControl.on('get_shipment_details_result', function (shipment) {
        d('bridge/command::get_shipment_details_result', shipment);
        self.shipment = shipment;
        view.editText = 'Edit';
        view.onlyread = true;
        var barge = utils.getBarge(shipment);
        setDataDogData();
        RiotControl.trigger('command_bridge_loaded', true);
        RiotControl.trigger('app_changed', 'bridge', true, true);
        if (!barge) {
            RiotControl.trigger('flash_message', 'error', "No Barge set on this shipment. Please select a barge value.", 30000);
        } else {
          RiotControl.trigger('get_helm_details', barge,  self.shipment.parentShipment.name, self.shipment.name);
          RiotControl.trigger('get_shipment_status', self.shipment);
        }
        RiotControl.trigger('get_shipment_audit_logs', self.shipment.parentShipment.name, self.shipment.name);
        self.update();
        setTimeout(function() {
          $('.group-select').select2();
        }, 100);
    });

    RiotControl.on('shipit_update_value_result', function (audit_logs) {
        d('bridge/command::bridge_changes_success', audit_logs);
        RiotControl.trigger('get_shipment_audit_logs', self.shipment.parentShipment.name, self.shipment.name);
    });

    RiotControl.on('get_shipment_audit_logs_result', function (audit_logs) {
        d('bridge/command::get_shipment_details_result', audit_logs);
        if (self.shipment) {
            self.shipment.audit_logs = audit_logs;
        }
        self.update();
    });

    RiotControl.on('datadog_create_embed_result', function(data) {
        d('datadog_create_embed_result', data);
        view.datadogLoading = false;
        if (!view.datadog_data[data.timeframe]) {
            view.datadog_data[data.timeframe] = [];
        }
        view.datadog_data[data.timeframe].push(data);
        self.update();
    });

    RiotControl.on('command_bridge_enabled', function (page, shipment, environment, tab) {
        if (page === 'bridge') {
            d('bridge/command::command_bridge_enabled', page, shipment, environment, tab);

            view.shipit = config.shipit_url + 'v1/shipment/' + shipment + '/environment/' + environment;
            view.erp = 'http://erp.services.dmtio.net/products/' + shipment + '/' + environment;
            view.currentRoute = '#bridge/' + shipment + '/' + environment;

            if (tab) {
               self.currentRoute += '/tabs-' + tab;
               setTimeout(function() {
                   $('#command_bridge_tabs').find('a[href="#tabs-' + tab + '"]').trigger('click');
               }, 1000);
               if (tab === 'graphs') {
                   view.renderGraphs = true;
               }
            }
            RiotControl.trigger('get_shipment_environments', shipment);
            RiotControl.trigger('get_shipment_details', shipment, environment);
            RiotControl.trigger('shipment_status_clear');
        }
    });

    RiotControl.on('set_container', function(container, addContainer) {
        if (!routed) {
            return true;
        }
        var url = self.shipment.parentShipment.name + '/environment/' + self.shipment.name + '/container';

        if (addContainer) {
            url += 's';
        } else {
            url += '/' + container.name;
        }

        RiotControl.trigger('shipit_update_value', url, container, addContainer ? 'POST' : 'PUT');
        self.update();
    });

    RiotControl.on('roll_build_token_result', function (token) {
        d('bridge/command::roll_build_token_result', token);
        self.shipment.buildToken = token;
        self.update();
    });

    function updateInterval(num) {
        d('bridge/command/logging::updateInterval(%s)', num);

        clearInterval(self.timer);

        if (num !== 'stop') {
            self.interval = parseInt(num, 10) * 1000;
            var barge = utils.getBarge(self.shipment);

            self.timer = setInterval(function () {
                RiotControl.trigger('update_logs', barge, self.shipment.parentShipment.name, self.shipment.name);
            }, self.interval);

        }


    }

    function setEnvVars(envVars, vars) {
        for (var i = 0;i < vars.length;i++) {
            envVars[vars[i].name] = vars[i].value;
        }
        return envVars;
    }

    function setDataDogData() {

        if (!view.renderGraphs || lastDataDogRequest === self.shipment.parentShipment.name + '-' + self.shipment.name) {
            return;
        }
        lastDataDogRequest = self.shipment.parentShipment.name + '-' + self.shipment.name;

        var datadog_data = getDataDogData(self.shipment.parentShipment.name, self.shipment.name);

        view.datadog_data = {};

        view.datadogLoading = true;
        datadog_data.forEach(function(data) {
            RiotControl.trigger('datadog_create_embed', data, data.timeframe);
        });
    }


    function getDataDogData(name, environment) {
        var graphs = [],
            cpu = {
                graph_json: {
                  viz: "timeseries",
                  requests: [
                    {
                      q: "max:kubernetes.cpu.usage.total{kube_environment:" + environment + ",kube_name:" + name + "} by {container_name}",
                      aggregator: "avg",
                      conditional_formats: [],
                      type: "area"
                    }
                  ]
                },
                timeframe: '4_hours',
                size: 'small',
                legend: 'yes',
                title: 'CPU Usage (last 4 hours)'
            },
            elbLatency = {
                graph_json: {
                    viz: "timeseries",
                    requests: [
                      {
                        q: "max:aws.elb.latency{product:" + name + ",environment:" + environment + "}",
                        aggregator: "avg",
                        conditional_formats: [],
                        type: "line"
                      }
                    ]
                },
                timeframe: '4_hours',
                size: 'small',
                legend: 'yes',
                title: 'Elb Latency (last 4 hours)'
            },
            elbRequestCount = {
                graph_json: {
                  viz: "timeseries",
                  requests: [
                    {
                      q: "max:aws.elb.request_count{product:" + name + ",environment:" + environment + "}.as_rate()",
                      aggregator: "avg",
                      conditional_formats: [],
                      type: "area"
                    }
                  ]
                },
                timeframe: '4_hours',
                size: 'small',
                legend: 'yes',
                title: 'Elb Request Count (last 4 hours)'
            },
            memory = {
                graph_json: {
                  "viz": "timeseries",
                  "requests": [
                    {
                      "q": "avg:kubernetes.memory.usage{kube_environment:" + environment + ",kube_name:" + name + "}",
                      "conditional_formats": [],
                      "type": "line",
                      "aggregator": "avg"
                    }
                  ]
                },
                timeframe: '4_hours',
                size: 'small',
                legend: 'yes',
                title: 'Memory (last 4 hours)'
            };

        graphs.push(elbLatency);
        graphs.push(elbRequestCount);
        graphs.push(cpu);
        graphs.push(memory);
        var graphs1Hour = graphs.map(function(data) {
            var newData = JSON.parse(JSON.stringify(data));
            newData.title = data.title.replace('(last 4 hours)', '(last 1 hour)');
            newData.timeframe = '1_hour';
            return newData;
        });
        var graphs1Day = graphs.map(function(data) {
            var newData = JSON.parse(JSON.stringify(data));
            newData.title = data.title.replace('(last 4 hours)', '(last 24 hours)');
            newData.timeframe = '1_day';
            return newData;
        });
        return graphs.concat(graphs1Hour).concat(graphs1Day);
    }

    RiotControl.on('update_logs_result', function (helm) {
        d('bridge/command/logging::update_logs_result', helm);

        view.helm = helm;
        view.helm.replicas = view.helm.replicas;
        self.update();
        RiotControl.trigger('get_logs');
    });

    RiotControl.on('app_changed', function (route, path, env) {
        if (route === 'bridge' && path && env) {
            routed = true;
        } else {
            clearInterval(self.timer);
            routed = false;
        }
    });

    RiotControl.on('get_user_groups_result', function (results) {
        d('shipyard/info::get_user_groups_result', results);
        self.groups = results.groups;
        self.update();
    });

    </script>

    <style scoped>
        .graphs {
            margin-bottom: 30px;
        }

        textarea {
            background-color: black;
            color: white;
            max-height: 1000px;
            padding: auto 5px;
        }
    </style>
</bridge_command>
