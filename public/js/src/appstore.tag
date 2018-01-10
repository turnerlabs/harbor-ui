function AppStore(host, services) {
    var self = riot.observable(this),
        mu = utils.makeUrl,
        d = utils.debug,
        recheckInterval = 1000 * 60 * 3, // every 3 minutes
        sourceData,
        hosts,
        state,
        calledGetUserGroups = false,
        calledGetUsers = false;

    hosts = {
        catalogit: window.config.catalogit_url.substring(0, window.config.catalogit_url.length - 1),
        shipit: window.config.shipit_url.substring(0, window.config.shipit_url.length - 1),
        blogRss: window.config.blog_rss,
        trigger: window.config.trigger_url,
        helmit: window.config.helmit_url,
        buildit: window.config.buildit_url
    };

    state = {};

    self.list = [];

    /* Auth Store */
    self.on('get_user_groups', function (data) {
        d('AuthStore::get_user_groups');

        if (calledGetUserGroups) { return false; }

        calledGetUserGroups = true;

        var user = ArgoAuth.getUser();

        if (user) {
           $.ajax({
                url: mu('api', 'v1', 'auth', 'groups', user),
                dataType: 'json',
                success: function (result) {
                    d('AuthStore::get_user_groups::success', result);
                    RiotControl.trigger('get_user_groups_result', result);
                },
                error: function (xhr, status, err) {
                    var error = xhr.responseText || err;
                    d('AuthStore::get_user_groups::error', error);
                    RiotControl.trigger('flash_message', 'error', error, 30000);
                }
            });
        }
    });

    self.on('get_users', function (data) {
        d('AuthStore::get_users');

        if (calledGetUsers) {
            return;
        }

        calledGetUsers = true;

        $.ajax({
            url: mu('api', 'v1', 'auth', 'users'),
            dataType: 'json',
            success: function (result) {
                d('AuthStore::get_users::success', result);
                RiotControl.trigger('get_users_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('AuthStore::get_users::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });

    });

    /* Menu Store */
    self.on('menu_register', function (name, path) {
        d('MenuStore::menu_register', name, path);
        self.list.push({name: name, path: '#' + path, isActive: false});

        RiotControl.trigger('menu_list_changed', self.list);
    });

    /* StateStore */
    self.on('save_state', function (key, value) {
        state[key] = value;

        sessionStorage.setItem('harbor_state', JSON.stringify(state));

        RiotControl.trigger('save_state_result', state);
    });

    self.on('retrieve_state', function (page, path, type) {
        var fetched;

        if (sessionStorage.getItem('harbor_state')) {
            fetched = sessionStorage.getItem('harbor_state');
            fetched = JSON.parse(fetched);
            state = fetched;
        } else {
            fetched = state;
        }

        fetched.page = page;
        fetched.path = path;
        fetched.type = type;

        RiotControl.trigger('retrieve_state_result', fetched);
    });

    self.on('clear_state', function () {
        d('StateStore::clear_state');
        sessionStorage.clear();
        state = {};
    });

    self.on('save_interval_multiplier', function (num) {
        localStorage.setItem('harbor_interval_multiplier', num);
        d('StateStore::save_interval_multiplier', num);

        RiotControl.trigger('interval_multiplier_result', num);
    });

    self.on('retrieve_interval_multiplier', function () {
        var num = localStorage.getItem('harbor_interval_multiplier') || config.updateInterval;
        d('StateStore::retrieve_interval_multiplier', num);

        RiotControl.trigger('interval_multiplier_result', num);
    });

    /* APIStore */

    self.on('get_containers', function () {
        d('APIStore::get_containers');
        $.ajax({
            url: mu(hosts.catalogit, 'containers'),
            dataType: 'json',
            success: function (containers) {
                d('APIStore::get_containers::success');
                var result = containers.map(function(container) { return {name: container}});
                RiotControl.trigger('get_containers_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::get_containers::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('get_container_versions', function (container, callback) {
        d('APIStore::get_container_versions', container);

        $.ajax({
            url: mu(hosts.catalogit, 'container', container),
            dataType: 'json',
            success: function (result) {
                d('APIStore::get_container_versions::success');
                callback(result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::get_container_versions::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('get_shipments', function () {
        d('APIStore::get_shipments');

         $.ajax({
            url: mu(hosts.shipit, 'v1', 'shipments'),
            dataType: 'json',
            success: function (result) {
                d('APIStore::get_shipments::success');
                var shipments = {},
                    customer,
                    product,
                    env,
                    i;

                for (i = 0; i < result.length; i++) {
                    // result[i] = {name: result[i], path: mu('#bridge', result[i])};
                    customer = (result[i].group || 'no-one').toLowerCase();
                    product  = result[i].name;
                    env      = result[i].environments;

                    if (!shipments[customer]) {
                        shipments[customer] = {};
                    }

                    shipments[customer][product] = env;
                }

                RiotControl.trigger('get_shipments_result', shipments);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err || 'Error connecting to ShipIt';

                d('APIStore::get_shipments::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('get_shipment_environments', function (shipment) {
        d('APIStore::get_shipment_environments', shipment);

        $.ajax({
            url: mu(hosts.shipit, 'v1', 'shipment', shipment),
            dataType: 'json',
            success: function (result) {
                d('APIStore::get_shipment_environments::success');
                var environments = [],
                    i;

                for (i = 0; i < result.environments.length; i++) {
                    environments.push({name: result.environments[i].name, path: mu('#bridge', shipment, result.environments[i].name)});
                }

                RiotControl.trigger('get_shipment_environments_result', environments);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::get_shipment_environments::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('get_shipment_details', function (shipment, environment) {
        d('APIStore::get_shipment_details', shipment);

        $.ajax({
            url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment),
            dataType: 'json',
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result) {
                d('APIStore::get_shipment_details::success');
                RiotControl.trigger('get_shipment_details_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::get_shipment_details::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('get_shipment_audit_logs', function (shipment, environment) {
        d('APIStore::get_shipment_audit_logs', shipment);

        $.ajax({
            url: mu(hosts.shipit, 'v1', 'logs', 'shipment', shipment, 'environment', environment),
            dataType: 'json',
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result) {
                d('APIStore::get_shipment_audit_logs::success');
                RiotControl.trigger('get_shipment_audit_logs_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::get_shipment_audit_logs::error', error);
            }
        });
    });



    self.on('get_helm_details', function (customer, shipment, environment) {
        d('APIStore::get_helm_details', customer, shipment, environment);

        $.ajax({
            url: mu(hosts.helmit, 'v2', 'harbor', customer, shipment, environment),
            dataType: 'json',
            success: function (result) {
                RiotControl.trigger('get_helm_details_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::get_helm_details::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('shipit_update_value', function (url, value, method) {
        d('ShipitStore::alter shipment with value:', url, value, method);

        var payload = {};

        if (typeof value === 'object') {
            for (var key in value) {
                payload[key] = value[key];
            }
        } else {
            console.log('Error: shipit_update_value, Must pass in an object');
            return;
        }

        $.ajax({
            method: method ? method : 'PUT',
            url: mu(hosts.shipit, 'v1', 'shipment', url),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            accepts: 'application/json',
            data: JSON.stringify(payload),
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                d('ShipitStore::shipit_update_value::shipit_update_value_success', url, result);
                RiotControl.trigger('flash_message', 'success', 'Updated value');
                RiotControl.trigger('shipit_update_value_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err || 'Failed To Trigger Shipment!';
                d('ShipitStore::shipit_update_value_plan::shipit_update_value_error', name, error);
                RiotControl.trigger('flash_message', 'error', 'Failed to update value ('+ status +')');
                RiotControl.trigger('shipit_update_value_result', 'error', error);
            }
        });
    });

    self.on('bridge_delete_parent_shipment', function (shipment) {
        d('ShipItStore::bridge_delete_parent_shipment', shipment);

        $.ajax({
            method: 'DELETE',
            url: mu(hosts.shipit, 'v1', 'shipment', shipment),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                d('ShipItStore::bridge_delete_parent_shipment::success', result);
                RiotControl.trigger('flash_message', 'success', 'Deleted Parent Shipment');
                RiotControl.trigger('bridge_delete_parent_shipment_result', shipment);
            },
            error: function (xhr, status, err) {
                var error = JSON.parse(xhr.responseText).error || err || 'Failed to delete parent Shipment: '+ shipment;
                d('ShipItStore::bridge_delete_parent_shipment::error', shipment, error);
                RiotControl.trigger('flash_message', 'error', 'Failed to delete parent Shipment ('+ error +')');
            }
        });
    });

    self.on('get_container_status', function (barge, shipment, environment) {
        d('APIStore::get_container_status', barge, shipment, environment);

        $.ajax({
            url: mu(hosts.helmit, 'v2', 'harbor', barge, shipment, environment) + '?' + new Date().getTime(),
            dataType: 'json',
            success: function (result) {
                RiotControl.trigger('get_container_status_result', result);
            },
            error: function (xhr, status, err) {
                var error = { replicas: [], error: xhr.responseJson };
                d('APIStore::get_container_status::error', error);
                RiotControl.trigger('get_container_status_result', error);
            }
        });
    });

    self.on('update_logs', function (barge, shipment, environment) {
        d('APIStore::update_logs', barge, shipment, environment);

        $.ajax({
            url: mu(hosts.helmit, 'v2', 'harbor', 'logs', barge, shipment, environment) + '?' + new Date().getTime(),
            dataType: 'json',
            success: function (result) {
                RiotControl.trigger('update_logs_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::update_logs::error', error);
                RiotControl.trigger('update_logs_result', error);
            }
        });
    });

    self.on('get_chart_data', function (host, id) {
        d('APIStore::get_chart_data', host, id);

        $.ajax({
            url: mu(hosts.helmit, 'cadvisor', 'api', host, id) + '?' + new Date().getTime(),
            data: 'json',
            success: function (result) {
                RiotControl.trigger('get_chart_data_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::get_chart_data::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('get_cloudhealth_data', function (path, callback) {
        d('APIStore:get_cloudhealth_data', path);

        $.ajax({
            url: '/app/v1/cloudhealth?path=' + encodeURI(path),
            dataType: 'json',
            success: function (result) {
                callback(result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('APIStore::get_cloudhealth_data::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });

    });

    self.on('discover', function (product, env, successTrigger) {
        var url = 'http://idb.services.dmtio.net/instances/' + product + '/' + env;

            $.ajax({
                url: url + '?q=' + 'NOT offline:true',
                dataType: 'json',
                success: function (result) {
                    RiotControl.trigger(successTrigger, result, product);
                },
                error: function (xhr, status, err) {
                    var error = xhr.responseText || err;

                    d('Lighthouse:discover::error', error);
                    RiotControl.trigger('flash_message', 'error', error, 30000);
                }
            });
    });

    self.on('get_kube_data', function (url, successTrigger) {
        $.ajax({
            url: 'http://' + url + ':8080/api/v1/replicationcontrollers',
            dataType: 'json',
            success: function (result) {
                RiotControl.trigger(successTrigger, result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;

                d('Lighthouse:discover::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('get_container_config', function (container, version) {
        d('APIStore::get_container_config', container, version);

        $.ajax({
            url: mu('api', 'v1', 'container', 'config', container, version),
            dataType: 'json',
            success: function (result) {
                RiotControl.trigger('get_container_config_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;

                d('APIStore::get_container_config::error', error);
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('build_create_shipment', function (shipment) {
        d('BuildStore::build_create_shipment', shipment);

        shipment.token = ArgoAuth.getToken();
        shipment.username = ArgoAuth.getUser();

        $.ajax({
            url: mu('api', 'v1', 'shipments'),
            method: 'POST',
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            data: JSON.stringify(shipment),
            success: function (result, status, xhr) {
                RiotControl.trigger('build_create_shipment_result', xhr.status, result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BuildStore::build_create_shipment::error', error);
                RiotControl.trigger('build_create_shipment_result', xhr.status, error);
            }
        });
    });

    self.on('bridge_create_shipment', function (shipment) {
        d('BuildStore::bridge_create_shipment', shipment);

        $.ajax({
            url: mu(hosts.shipit, 'v1', 'bulk', 'shipments'),
            method: 'POST',
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            data: JSON.stringify(shipment),
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                d('BuildStore::bridge_create_shipment::success', result)
                RiotControl.trigger('flash_message', 'success', "Saved Shipment");
                RiotControl.trigger('bridge_create_shipment_result', xhr.status, result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BuildStore::bridge_create_shipment::error', error);
                RiotControl.trigger('bridge_create_shipment_result', xhr.status, error);
            }
        });
    });

    self.on('build_shipment_trigger', function (shipment, environment, provider) {
        d('BuildStore::build_shipment_trigger', shipment, environment, provider);

        $.ajax({
            method: 'POST',
            url: mu(hosts.trigger, shipment, environment, provider) + '?shipment',
            contentType: 'application/json',
            accepts: 'application/json',
            data: {},
            success: function (result) {
                d('BuildStore::build_shipment_trigger::success', result);
                result = JSON.parse(result);
                RiotControl.trigger('build_shipment_trigger_result', result);
                RiotControl.trigger('flash_message', 'success', result.message);

                if (result.elb_id) {
                    d('BuildStore::build_shipment_trigger->bridge_lb_status');
                    RiotControl.trigger('bridge_lb_status', shipment, environment, provider);
                }
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err || 'Failed To Trigger Shipment!';
                error = JSON.parse(error);
                d('BuildStore::build_shipment_trigger::error', error);

                RiotControl.trigger('flash_message', 'error', error.message, 30000);
                RiotControl.trigger('build_shipment_trigger_result', {}, error.message);
            }
        });
    });

    self.on('bridge_shipment_trigger', function (shipment, environment, location) {
        d('BridgeStore::bridge_shipment_trigger', shipment, environment, location);

        $.ajax({
            method: 'POST',
            url: mu(hosts.trigger, shipment, environment, location),
            contentType: 'application/json',
            accepts: 'application/json',
            data: {},
            success: function (result) {
                d('BuildStore::bridge_shipment_trigger::success', result);
                result = JSON.parse(result);
                RiotControl.trigger('bridge_shipment_trigger_result', result);
                RiotControl.trigger('flash_message', 'success', result.message);

                if (result.elb_id) {
                    d('BridgeStore::bridge_shipment_trigger->bridge_lb_status');
                    RiotControl.trigger('bridge_lb_status', shipment, environment, location);
                }
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err || 'Failed To Trigger Shipment!';
                error = JSON.parse(error);
                d('BridgeStore::build_shipment_trigger::error', error);

                RiotControl.trigger('flash_message', 'error', error.message, 30000);
                RiotControl.trigger('bridge_shipment_trigger_result', {}, error.message);
            }
        });
    });

    self.on('bridge_lb_status', function (shipment, environment, provider) {
        d('BridgeStore::bridge_lb_status', shipment, environment, provider);

        $.ajax({
            method: 'GET',
            url: mu(hosts.trigger, 'loadbalancer', 'status', shipment, environment, provider),
            dataType: 'json',
            accepts: 'application/json',
            success: function (result, status, xhr) {
                d('BridgeStore::bridge_lb_status::success');
                RiotControl.trigger('bridge_lb_status_result', result);
            },
            error: function (xhr, status, err) {
                d('BridgeStore::build_shipment_scale::error', err);
                RiotControl.trigger('bridge_lb_status_result', xhr.responseJSON);
            }
        });
    });

    self.on('bridge_shipment_scale', function (shipment, environment, location, scale) {
        d('BridgeStore::build_shipment_scale', shipment, environment, location, scale);

        $.ajax({
            method: 'POST',
            url: mu(hosts.trigger, 'scale', shipment, environment, location),
            contentType: 'application/json',
            accepts: 'application/json',
            data: {},
            success: function (result) {
                result = JSON.parse(result);
                RiotControl.trigger('bridge_shipment_scale_result', result);
                RiotControl.trigger('flash_message', 'success', result.message);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err || 'Failed To Scale Shipment!';
                d('BridgeStore::build_shipment_scale::error', error);

                RiotControl.trigger('flash_message', 'error', error, 30000);
                RiotControl.trigger('bridge_shipment_scale_result', {}, error);
            }
        });
    });

    self.on('build_check_for_plan', function (name) {
        d('BuildStore::check buildit for plan', name);

        $.ajax({
            method: 'GET',
            url: mu(hosts.buildit, 'plan', name),
            dataType: 'json',
            contentType: 'application/json',
            success: function (result, status, xhr) {
                d('BuildStore::build_check_for_plan::retrieved_build_plan', name);
                RiotControl.trigger('build_check_for_plan_result', result, status);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BuildStore::build_check_for_plan::no_build_plan', name);
                RiotControl.trigger('build_check_for_plan_result', {}, status);
            }
        });
    });

    self.on('build_alter_plan_branches', function (name, data) {
        d('BuildStore::alter plan with name:', name, data);

        data.branch.username = ArgoAuth.getUser();
        data.branch.token = ArgoAuth.getToken();

        $.ajax({
            method: 'POST',
            url: mu(hosts.buildit, 'plan', name, 'branches'),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            accepts: 'application/json',
            data: JSON.stringify(data.branch),
            success: function (result, status, xhr) {
                d('BuildStore::build_create_plan::built_plan_success', name, result.number);
                RiotControl.trigger('build_create_plan_result', result);
            },
            error: function (xhr, status, err) {
                d('BuildStore::build_create_plan::built_plan_error', name, err);
                RiotControl.trigger('build_create_plan_result', {}, err);
            }
        });
    });

    self.on('build_alter_plan_branch', function (name, data) {
        d('BuildStore::alter plan with name:', name, data);

        data.branch.username = ArgoAuth.getUser();
        data.branch.token = ArgoAuth.getToken();

        $.ajax({
            method: 'PUT',
            url: mu(hosts.buildit, 'plan', name, 'branch', data.branch.name),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            accepts: 'application/json',
            data: JSON.stringify(data.branch),
            success: function (result, status, xhr) {
                d('BuildStore::build_create_plan::built_plan_success', name, result.number);
                RiotControl.trigger('build_alter_branch_result', result);
            },
            error: function (xhr, status, err) {
                d('BuildStore::build_create_plan::built_plan_error', name, err);
                RiotControl.trigger('build_alter_branch_result', {}, err);
            }
        });
    });

    self.on('build_alter_plan', function (name, data) {
        d('BuildStore::alter plan with name:', name, data);

        data.username = ArgoAuth.getUser();
        data.token = ArgoAuth.getToken();

        $.ajax({
            method: 'PUT',
            url: mu(hosts.buildit, 'plan', name),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            accepts: 'application/json',
            data: JSON.stringify(data),
            success: function (result, status, xhr) {
                d('BuildStore::alter_buildit_plan::alter_buildit_plan_success', name, result.number);
                RiotControl.trigger('build_alter_plan_result', result);
            },
            error: function (xhr, status, err) {
                d('BuildStore::alter_buildit_plan::alter_buildit_plan_error', name, err);
                RiotControl.trigger('build_alter_plan_result', {}, err);
            }
        });
    });

    self.on('build_create_plan', function (name, data) {
        d('BuildStore::create plan with name:', name, data);
        var newData = JSON.stringify({
               username: ArgoAuth.getUser(),
               token: ArgoAuth.getToken(),
               repo: data.code.repo,
               branches: [data.code.branch],
               groups: data.code.groups,
               name: name
        });
        $.ajax({
            method: 'POST',
            url: mu(hosts.buildit, 'plans'),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            accepts: 'application/json',
            data: newData,
            success: function (result, status, xhr) {
                d('BuildStore::build_create_plan::built_plan_success', name, result.number);
                RiotControl.trigger('build_create_plan_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BuildStore::build_create_plan::built_plan_error', name, error);
                RiotControl.trigger('build_create_plan_result', {}, error);
            }
        });
    });

    self.on('build_run_plan', function (name, branch) {
        d('BuildStore::run plan with name', name, branch);

        $.ajax({
            method: 'POST',
            url: mu(hosts.buildit, 'build', name, branch),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            accepts: 'application/json',
            data: JSON.stringify({}),
            success: function (result, status, xhr) {
                d('BuildStore::build_run_plan:success', result.name, result.number);
                RiotControl.trigger('build_run_plan_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BuildStore::build_run_plan:run_plan_error', name, error);
                RiotControl.trigger('build_run_plan_result', {}, error);
            }
        });
    });

    self.on('build_get_latest_build', function (name, branch) {
        d('BuildStore::build_get_latest_build', name, branch);

        $.ajax({
            method: 'GET',
            url: mu(hosts.buildit, 'build', name, branch, 'latest'),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            success: function (result, status, xhr) {
                d('BuildStore::build_get_latest_build:success', name, result.number);
                RiotControl.trigger('build_get_latest_build_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BuildStore::build_run_plan:build_get_latest_build_error', name, error);
                RiotControl.trigger('build_get_latest_build_result', {}, error);
            }
        });
    });

    self.on('build_get_all_builds', function (name, branch) {
        d('BuildStore::build_get_all_builds', name, branch);

        $.ajax({
            method: 'GET',
            url: mu(hosts.buildit, 'build', name, branch, 'all'),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            success: function (result, status, xhr) {
                d('BuildStore::build_get_all_builds:success', name);
                RiotControl.trigger('build_get_all_builds_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BuildStore::build_run_plan:build_get_all_builds_error', name, error);
                RiotControl.trigger('build_get_all_builds_result', [], error);
            }
        });
    });

    self.on('build_get_latest_build_logs_diff', function (name, branch, number, timestamp) {
        d('BuildStore::build_get_latest_build_logs_diff', name, branch, number, timestamp);

        $.ajax({
            method: 'GET',
            url: mu(hosts.buildit, 'build', name, number, 'logs', timestamp ? timestamp : ''),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            success: function (result, status, xhr) {
                d('BuildStore::build_get_latest_build_logs_diff:success', name, result.number);
                RiotControl.trigger('build_get_latest_build_logs_diff_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BuildStore::build_run_plan:build_get_latest_build_error', name, error);
                RiotControl.trigger('build_get_latest_build_logs_diff_result', {}, error);
            }
        });
    });

    self.on('buildit_get_plans', function() {
        d('Buildit::buildit_get_plans');

        $.ajax({
            method: 'GET',
            url: mu(hosts.buildit, 'plans'),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            success: function (result, status, xhr) {
                d('Buildit::buildit_get_plans:success');
                RiotControl.trigger('buildit_get_plans_result', result);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('Buildit::buildit_get_plans:error', error);
                RiotControl.trigger('buildit_get_plans_result', {}, error);
            }
        });
    });

    self.on('datadog_create_embed', function(data) {
        d('DataDog::create_embed');

        $.ajax({
            method: 'POST',
            url: mu('api', 'v1', 'datadog'),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            data: JSON.stringify(data),
            success: function (result, status, xhr) {
                d('datadog::datadog_create_embed:success');
                result.timeframe = data.timeframe;
                RiotControl.trigger('datadog_create_embed_result', result, null);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseJSON || xhr.responseText || err;
                d('datadog::datadog_create_embed:error', error);
                RiotControl.trigger('datadog_create_embed_result', {}, error);
            }
        });
    });

    self.on('roll_build_token', function (shipment, environment) {
        d('BridgeStore::roll_build_token', shipment, environment);

        $.ajax({
            method: 'PUT',
            url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment, 'buildToken'),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                d('BridgeStore::roll_build_token::success', result);
                RiotControl.trigger('flash_message', 'success', 'Build token rolled');
                RiotControl.trigger('roll_build_token_result', result.buildToken);
            },
            error: function (xhr, status, err) {
                d('BridgeStore::roll_build_token::error', xhr.responseText, err);
                var error = xhr.responseText || err;
                RiotControl.trigger('flash_message', 'error', error);
            }
        });
    });

    self.on('create_annotation', function (shipment, environment, annotation) {
        d('BridgeStore::create_annotation', shipment, environment, annotation);

        $.ajax({
            method: 'POST',
            url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment, 'annotations'),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            data: JSON.stringify(annotation),
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                d('BridgeStore::create_annotation::success', result);
                RiotControl.trigger('flash_message', 'success', 'Created Annotation');

                RiotControl.trigger('annotations_modified', result.annotations);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BridgeStore::create_annotation::error', error);
                RiotControl.trigger('flash_message', 'error', error);

                RiotControl.trigger('annotations_modified', false);
            }
        });
    });

    self.on('update_annotation', function (shipment, environment, name, annotation) {
        d('BridgeStore::update_annotation', shipment, environment, name, annotation);

        $.ajax({
            method: 'PUT',
            url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment, 'annotation', name),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            data: JSON.stringify(annotation),
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                d('BridgeStore::update_annotation::success', result);
                RiotControl.trigger('flash_message', 'success', 'Updated Annotation');

                RiotControl.trigger('annotations_modified', result.annotations);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BridgeStore::update_annotation::error', error);
                RiotControl.trigger('flash_message', 'error', error);

                RiotControl.trigger('annotations_modified', false);
            }
        });
    });

    self.on('delete_annotation', function (shipment, environment, name) {
        d('BridgeStore::delete_annotation', shipment, environment, name);

        $.ajax({
            method: 'DELETE',
            url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment, 'annotation', name),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                d('BridgeStore::delete_annotation::success', result);
                RiotControl.trigger('flash_message', 'success', 'Delete Annotation');

                RiotControl.trigger('annotations_modified', result.annotations);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BridgeStore::delete_annotation::error', error);
                RiotControl.trigger('flash_message', 'error', error);

                RiotControl.trigger('annotations_modified', false);
            }
        });
    });

    self.on('create_container', function (shipment, environment, container, port) {
        d("BridgeStore::create_container", shipment, environment, container, port)

        $.ajax({
            method: 'POST',
            url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment, 'containers'),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            data: JSON.stringify(container),
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (containerResult, status, xhr) {
                RiotControl.trigger('flash_message', 'success', 'Created Container');

                $.ajax({
                    method: 'POST',
                    url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment, 'container', container.name, 'ports'),
                    dataType: 'json',
                    contentType: 'application/json',
                    accepts: 'application/json',
                    data: JSON.stringify(port),
                    headers: {
                        'x-username': ArgoAuth.getUser(),
                        'x-token': ArgoAuth.getToken()
                    },
                    success: function (portResult, status, xhr) {
                        RiotControl.trigger('flash_message', 'success', 'Created Port');

                        RiotControl.trigger('container_created', containerResult, portResult);
                    },
                    error: function (xhr, status, err) {
                        var error = xhr.responseText || err;
                        d('BridgeStore::create_container::port::error', error);
                        RiotControl.trigger('flash_message', 'error', error);
                        RiotControl.trigger('container_created', false);
                    }
                });
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BridgeStore::create_container::container::error', error);
                RiotControl.trigger('flash_message', 'error', error);

                RiotControl.trigger('container_created', false);
            }
        });
    });

    self.on('delete_container', function (shipment, environment, container) {
        d("BridgeStore::delete_container", shipment, environment, container);

        $.ajax({
            method: 'DELETE',
            url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment, 'container', container),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                RiotControl.trigger('flash_message', 'success', 'Container deleted');

                RiotControl.trigger('container_deleted', container);
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                d('BridgeStore::delete_container::error', xhr, status, err);
                RiotControl.trigger('flash_message', 'error', error);

                RiotControl.trigger('container_deleted', null);
            }
        });
    });

    self.on('delete_shipment', function (shipment, environment) {
        d("BridgeStore::delete_shipment", shipment, environment);

        $.ajax({
            method: 'DELETE',
            url: mu(hosts.shipit, 'v1', 'shipment', shipment, 'environment', environment),
            headers: {
                'x-username': ArgoAuth.getUser(),
                'x-token': ArgoAuth.getToken()
            },
            success: function (result, status, xhr) {
                var msg = 'Deleted shipment %s %e'.replace('%s', shipment).replace('%e', environment);
                RiotControl.trigger('flash_message', 'success', msg);
                riot.route('bridge');
            },
            error: function (xhr, status, err) {
                var error = xhr.responseText || err;
                RiotControl.trigger('flash_message', 'error', error);
            }
        });
    });

    self.on('home_get_blog_rss', function() {
        //feed to parse
        var feed = mu('api', 'v1', 'blog-feed');

        $.ajax(feed, {
            accepts:{
                xml:"application/rss+xml"
            },
            dataType:"xml",
            success: function(data) {
                // Credit: http://stackoverflow.com/questions/10943544/how-to-parse-an-rss-feed-using-javascript
                var rssJson = [];

                $(data).find("item").each(function () { // or "item" or whatever suits your feed
                    var el = $(this),
                        rssEntry = {};

                    rssEntry.title = el.find("title").text();
                    rssEntry.link = el.find("link").text();
                    rssEntry.pubDate = (new Date(el.find("pubDate").text())).toLocaleString('en-US', {
                        weekday: 'long',
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric'
                    });

                    rssJson.push(rssEntry);
                });

                d('AppStore::home_get_blog_rss:success', rssJson);
                RiotControl.trigger('home_get_blog_rss_result', null, rssJson.slice(0, 5));
            },
            error: function(xhr, status, err) {
                var error = xhr.responseText || err;
                d('AppStore::home_get_blog_rss:error', error);
                RiotControl.trigger('home_get_blog_rss_result', error, null);
            }
        });
    });

    self.on('fetch_shipment_status_events', function (barge, shipment, environment) {
        d('HelmItStore::fetch_shipment_status_events', barge, shipment, environment);

        $.ajax({
            method: 'GET',
            url: mu(hosts.helmit, 'shipment', 'events', barge, shipment, environment),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            success: function (result, status, xhr) {
                d('HelmItStore::fetch_shipment_status_events::success', result, status);
                RiotControl.trigger('shipment_status_events_result', result);
            },
            error: function (xhr, status, err) {
                d('HelmItStore::fetch_shipment_status_events::error', err, xhr.responseText || status);
                var error = xhr.responseText || err;
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });

    self.on('fetch_shipment_status', function (barge, shipment, environment) {
        d('HelmItStore::fetch_shipment_status', barge, shipment, environment);

        $.ajax({
            method: 'GET',
            url: mu(hosts.helmit, 'shipment', 'status', barge, shipment, environment),
            dataType: 'json',
            contentType: 'application/json',
            accepts: 'application/json',
            success: function (result, status, xhr) {
                d('HelmItStore::fetch_shipment_status::success', result, status);
                RiotControl.trigger('shipment_status_result', result);
            },
            error: function (xhr, status, err) {
                d('HelmItStore::fetch_shipment_status::error', err, xhr.responseText || status);
                var error = xhr.responseText || err;
                RiotControl.trigger('flash_message', 'error', error, 30000);
            }
        });
    });
}
