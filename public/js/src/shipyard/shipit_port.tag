<shipit_port>
    <div class="row">
        <div class="col s6 input-field">
            <div class="col s12">
                Name
                <i class="tiny material-icons"
                    title="Name of the Env Var that will be injected into the Container.">
                    info_outline
                </i>
            </div>
            <div class="col s12">
                <input if="{!onlyread}" type="text" name="{'name'}" value={ port.name } onblur={ setName } required />
                <input if="{onlyread}" type="text" name="{'name'}" value={ port.name } onblur={ setName } readonly />
            </div>
        </div>
        <div class="col s6 input-field">
            <div class="col s12">
                Value
                <i class="tiny material-icons"
                    title="The value of the port that is set on the Load Balancer. The name of this Port is used to determine which Env Var will contain this value.">
                    info_outline
                </i>
            </div>
            <div class="col s12">
                <input if="{!onlyread}" type="number" name="value" value={ port.value } onblur={ setValue } min="1" max="65535" required />
                <input if="{onlyread}" type="number" name="value" value={ port.value } onblur={ setValue } min="1" max="65535" readonly />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col s6 input-field">
            <div class="col s12">
                Healthcheck
                <i class="tiny material-icons"
                    title="The healthcheck path that determines if your application is alive. Only one is allowed.">
                    info_outline
                </i>
            </div>
            <div class="col s12">
                <input if="{!onlyread}" type="text" name="healthcheck" value={ port.healthcheck } onblur={ setValue } required />
                <input if="{onlyread}" type="text" name="healthcheck" value={ port.healthcheck } onblur={ setValue } readonly />
            </div>
        </div>
        <div class="col s6 input-field">
            <div class="col s12">
                Public Port
                <i class="tiny material-icons"
                    title="Override for the port value on the Load Balancer.">
                    info_outline
                </i>
            </div>
            <div class="col s12">
                <input if="{!onlyread}" type="number" name="public_port" value={ port.public_port } onblur={ setValue } min="1" max="65535" required />
                <input if="{onlyread}" type="number" name="public_port" value={ port.public_port } onblur={ setValue } min="1" max="65535" readonly />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col s6 input-field">
            <div class="col s12">
                Healthcheck Timeout
                <i class="tiny material-icons"
                    title="The amount of time that is valid for your healthcheck to return 200.">
                    info_outline
                </i>
            </div>
            <div class="col s12">
                <input if="{!onlyread}" type="number" name="healthcheck_timeout" value={ port.healthcheck_timeout } onblur={ setValue } min="1" max="60" required />
                <input if="{onlyread}" type="number" name="timeout" value={ port.healthcheck_timeout } onblur={ setValue } min="1" max="60" readonly />
            </div>
        </div>
        <div class="col s6 input-field">
            <div class="col s12">
                Healthcheck Interval
                <i class="tiny material-icons"
                    title="The time to wait in between each healthcheck. Cannot be less than healthcheck_timeout">
                    info_outline
                </i>
            </div>
            <div class="col s12">
                <input if="{!onlyread}" type="number" name="healthcheck_interval" value={ port.healthcheck_interval } onblur={ setValue } min="1" max="60" required />
                <input if="{onlyread}" type="number" name="healthcheck_interval" value={ port.healthcheck_interval } onblur={ setValue } min="1" max="60" readonly />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col s4 input-field">
            <input if="{!onlyread}" type="checkbox"
                     id="{parent.container.name}_primary_{port.name}"
                     name="primary"
                     onclick="{setBool}"
                     checked="{checked: port.primary}" />
            <input if="{onlyread}" type="checkbox"
                     id="{parent.container.name}_primary_{port.name}"
                     name="primary"
                     onclick="{setBool}"
                     checked="{checked: port.primary}" disabled/>
            <label for="{parent.container.name}_primary_{port.name}">Primary</label>
            <i class="tiny material-icons"
                title="If set, this Port's healthcheck value will be used to check the health of this Container.
                              Proto and Port values will be used from this port object as well.
                              If set, this Port's values will be used to check the health of this Container (protocol, healthcheck, port value, etc...)">
                info_outline
            </i>
        </div>
        <div class="col s4 input-field">
            <input if="{!onlyread}" name="external"
                     type="checkbox"
                     id="{parent.container.name}_external_{port.name}"
                     onclick="{setBool}"
                     checked="{checked: port.external}"/>
            <input if="{onlyread}" name="external"
                     type="checkbox"
                     id="{parent.container.name}_external_{port.name}"
                     onclick="{setBool}"
                     checked="{checked: port.external}" disabled/>
            <label for="{parent.container.name}_external_{port.name}">External</label>
            <i class="tiny material-icons"
                title="If set, this Port will be set on the Load Balancer.">
                info_outline
            </i>
        </div>
        <div class="col s4 input-field">
            <input if="{!onlyread}" name="public_vip"
                     type="checkbox"
                     id="{parent.container.name}_public_{port.name}"
                     onclick="{setBool}"
                     checked="{checked: port.public_vip}"/>
            <input if="{onlyread}" name="public_vip"
                     type="checkbox"
                     id="{parent.container.name}_public_{port.name}"
                     onclick="{setBool}"
                     checked="{checked: port.public_vip}" disabled/>
            <label for="{parent.container.name}_public_{port.name}">Public</label>
            <i class="tiny material-icons"
                title="If set, this Shipment will be exposed to the world on any Port set to external.">
                info_outline
            </i>
        </div>
    </div>
    <div class="row">
        <div class="col s12 input-field" if="{ !onlyread }">
            Load Balancer Type
            <select id="lbTypeSelect" class="proto-select" name="lbtype" onchange="{ setValue }" style="width: 100%">
                <option
                    each="{ lb in lbTypes }"
                    selected="{ lb.value == this.parent.port.lbtype }"
                    value="{ lb.value }">{ lb.name }
                </option>
            </select>
        </div>
        <div class="col s12 input-field" if="{ onlyread }">
            Load Balancer Type
            <p>{ port.lbtype }</p>
        </div>
    </div>
    <div class="row">
        <div class="col s12 input-field" if="{!onlyread}">
            Protocol
            <select id="protoSelect" class="proto-select" name="protocol" onchange="{ setValue }" style="width: 100%">
                <option
                    each="{ proto in protos }"
                    selected="{ proto == this.parent.port.protocol }"
                    value="{ proto }">{ proto }
                </option>
            </select>
        </div>
        <div class="col s6 input-field" if="{onlyread}">
            Protocol
            <p>{port.protocol}</p>
        </div>
        <div class="col s12" if="{port.protocol == 'tcp'}">
          <div class="col s4 input-field">
              <input if="{!onlyread}" type="checkbox"
                       id="{parent.container.name}_proxy_proto_{port.name}"
                       name="enable_proxy_protocol"
                       onclick="{setBool}"
                       checked="{checked: port.enable_proxy_protocol}" />
              <input if="{onlyread}" type="checkbox"
                       id="{parent.container.name}_proxy_proto_{port.name}"
                       name="enable_proxy_protocol"
                       onclick="{setBool}"
                       checked="{checked: port.enable_proxy_protocol}" disabled/>
              <div if="{onlyread}">
                <h1>{parent.container.name}_proxy_proto_{port.name}</h1>
              </div>
              <label for="{parent.container.name}_proxy_proto_{port.name}">Proxy Protocol</label>
              <i class="tiny material-icons"
                  title="If set, this port will forward client information along to the origin. Read Here for more info: http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-proxy-protocol.html">
                  info_outline
              </i>
          </div>
        </div>
        <div class="col s12" if="{port.protocol == 'https'}">
            <div class="row">
                <div class="col s12">
                  <br>
                  <p>Choose Type</p>
                  <div class="col s2 input-field">
                    <input class="with-ga"
                           if="{!onlyread}"
                           type="radio"
                           name="ssl_management_type_{port.name}"
                           value="acm"
                           onchange="{setValue}"
                           checked="{checked: port.ssl_management_type === 'acm'}"
                           {disabled: onlyread}
                           id="{parent.container.name}_acm_radio_{port.name}">
                     <input class="with-ga"
                            if="{onlyread}"
                            disabled
                            type="radio"
                            name="ssl_management_type_{port.name}"
                            value="acm"
                            onchange="{setValue}"
                            checked="{checked: port.ssl_management_type === 'acm'}"
                            {disabled: onlyread}
                            id="{parent.container.name}_acm_radio_{port.name}">
                    <label for="{parent.container.name}_acm_radio_{port.name}">ACM</label>
                    <i class="tiny material-icons type-i"
                        title="Use the ARN value of the certificate that works for this shipment. Make sure the ARN lives in the correct account or else the ELB will fail.">
                        info_outline
                    </i>
                  </div>
                  <div class="col s2 input-field">
                    <input class="with-ga"
                           if="{!onlyread}"
                           type="radio"
                           name="ssl_management_type_{port.name}"
                           value="iam"
                           onchange="{setValue}"
                           checked="{checked: port.ssl_management_type === 'iam'}"
                           id="{parent.container.name}_iam_radio_{port.name}">
                     <input class="with-ga"
                            if="{onlyread}"
                            disabled
                            type="radio"
                            name="ssl_management_type_{port.name}"
                            value="iam"
                            onchange="{setValue}"
                            checked="{checked: port.ssl_management_type === 'iam'}"
                            id="{parent.container.name}_iam_radio_{port.name}">
                    <label for="{parent.container.name}_iam_radio_{port.name}">IAM</label>
                    <i class="tiny material-icons type-i"
                        title="Use raw IAM to create a certificate. You will need the raw private key and the public certs to go with it.">
                        info_outline
                    </i>
                  </div>
                </div>
            </div>
            <div class="row" if="{port.ssl_management_type === 'iam'}">
                <div class="col s12 input-field">
                    <p if="{onlyread}">Private Key<input type="text" value="******" disabled/></p>
                    <p if="{!onlyread}"><textarea id="private_key" name="private_key" class="materialize-textarea" onchange="{setTextAreaValue}">{ port.private_key }</textarea></p>
                    <label if="{!onlyread}" for="private_key">Private Key</label>
                </div>

                <div class="col s12 input-field">
                    <p if="{onlyread}">Public Key Certificate<input type="text" value="******" disabled/></p>
                    <p if="{!onlyread}"><textarea id="public_key_certificate" name="public_key_certificate" class="materialize-textarea" onchange="{setTextAreaValue}">{ port.public_key_certificate }</textarea></p>
                    <label if="{!onlyread}" for="public_key_certificate">Public Key Certificate</label>
                </div>

                <div class="col s12 input-field">
                    <p if="{onlyread}">Certificate Chain<input type="text" value="******" disabled/></p>
                    <p if="{!onlyread}"><textarea id="certificate_chain" name="certificate_chain" class="materialize-textarea" onchange="{setTextAreaValue}">{ port.certificate_chain }</textarea></p>
                    <label if="{!onlyread}" for="certificate_chain">Certificate Chain</label>
                </div>
            </div>
            <div class="row"  if="{port.ssl_management_type === 'acm'}">
              <div class="col s12 input-field">
                  <input if="{!onlyread}" type="text" name="ssl_arn" value={ port.ssl_arn } onblur={ setValue } />
                  <input if="{onlyread}" type="text" name="ssl_arn" value={ port.ssl_arn } onblur={ setValue } disabled />
                  <label for="ssl_arn">SSL ARN</label>
              </div>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.protos = ['http', 'https', 'tcp'];
    self.lbTypes = getAllowedLbTypes();

    /**
     * setTextAreaValue
     *
     * sets values for text areas that might contain line breaks
     *
     * @param {Element} input The element is the event was triggered
     */
    setTextAreaValue(input) {
        self.port[input.target.name] = input.target.value.replace(/\\n/g, "\\n");
        self.parent.parent.update();
        self.port.value = parseInt(self.port.value);
        RiotControl.trigger('port_value_changed', self.parent.container, self.port);
    }

    /**
     *
     * setValue
     *
     * sets the value of a branches value, based on the input name
     *
     * @param {Element} input The element that the event was triggered
     */
    setValue(input) {
        var name = input.target.name.replace('_' + self.port.name, '');
        if (input.target.value || name === 'healthcheck') {
            self.port[name] = input.target.value;
            self.parent.parent.update();
            self.port.value = parseInt(self.port.value);
            if (self.port.primary === true && !self.port.healthcheck) {
                RiotControl.trigger('flash_message', 'error', 'Primary Ports must have a healthcheck.', 30000);
            } else if (self.port.healthcheck_interval < self.port.healthcheck_timeout) {
                RiotControl.trigger('flash_message', 'error', 'Healthcheck Timeout must be less than Interval.', 30000);
            } else {
                RiotControl.trigger('port_value_changed', self.parent.container, self.port);
            }
        } else if (input.target.value || name === 'ssl_arn') {
            input.target.value = input.target.value.trim();
        }
    }

    /**
     *
     * setName
     *
     * sets the name of a port
     *
     * @param {Element} input The element that the event was triggered
     */
    setName(input) {
        self.port.oldName = self.port[input.target.name];
        self.port[input.target.name] = input.target.value;
        self.parent.parent.update();
        self.port.value = parseInt(self.port.value);
        RiotControl.trigger('port_value_changed', self.parent.container, self.port);
    }

    setBool(input) {
        var name = input.target.name;
        self.port[input.target.name] = !self.port[input.target.name];

        if (name === 'primary') {
            self.parent.container.ports.map(function(port) {
                if (port.name !== self.port.name) {
                    port.primary = false;
                    RiotControl.trigger('port_value_changed', self.parent.container, port);
                }
            });

            if (self.port.primary) {
               self.port.external = true;
            }
        }

        if (name === 'public_vip') {
            if (self.port.public_vip) {
                self.port.external = true;
            }
        }

        if (name === 'external') {
            if (self.port.public_vip && !self.port.external) {
                self.port.public_vip = false;
            }

            if (self.port.primary && !self.port.external) {
                self.port.primary = false;
            }
        }

        self.port.value = parseInt(self.port.value);

        RiotControl.trigger('port_value_changed', self.parent.container, self.port);

        self.parent.parent.update();
    }

    function getAllowedLbTypes() {
        var types = config.lb_types_allowed.split(','), // 'd1:v1,d2:v2'
            temp,
            i;

        for (var i = 0; i < types.length; i++) {
            temp = types[i].split(':'); // 'display:value'
            types[i] = { name: temp[0], value: temp[1] };
        }

        return types;
    }

    RiotControl.on('app_changed', function (route, path, env) {
        d('shipyard/shipit_port::app_changed', route, path, env);
        if (route === 'bridge' && path && env && env === 'containers' && self.port) {
            switch (self.port.lbtype) {
            case 'alb-ingress':
                // Allow unique types to be shown; right now only alb-ingress exists
                self.lbTypes.push({ name: self.port.lbtype, value: self.port.lbtype });
                break;

            default:
                self.lbTypes = getAllowedLbTypes();
                break;
            }
        }
    });

    self.on('mount', function() {
        $('.proto-select').select2();
    });

    self.on('update', function() {
        self.port = self.opts.port;
        self.onlyread = self.opts.onlyread;
        self.container = self.opts.container;
    });
    </script>

    <style scoped>
        .proto-select {
            display: block;
        }

        .input-field label {
            top: 0;
            padding-right: .7rem;
            color: #000;
        }

        textarea {
            color: black;
        }

        textarea {
            color: black;
        }

        .type-i {
            margin-right: -16px;
        }
    </style>
</shipit_port>
