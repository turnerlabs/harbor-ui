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
                <input type="text" name="{ 'name' }" value="{ port.name }" onblur="{ setName }" required />
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
                <input type="number" name="value" value="{ port.value }" onblur="{ setValue }" min="1" max="65535" required />
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
                <input type="text" name="healthcheck" value="{ port.healthcheck }" onblur="{ setValue }" required />
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
                <input type="number" name="public_port" value="{ port.public_port }" onblur="{ setValue }" min="1" max="65535" required />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col s4 input-field">
            <input type="checkbox"
                     id="{ parent.container.name }_primary_{ port.name }"
                     name="primary"
                     onclick="{ setBool }"
                     checked="{ checked: port.primary }" />
            <label for="{ parent.container.name }_primary_{ port.name }">Primary</label>
            <i class="tiny material-icons"
                title="If set, this Port's healthcheck value will be used to check the health of this Container.
                              Proto and Port values will be used from this port object as well.
                              If set, this Port's values will be used to check the health of this Container (protocol, healthcheck, port value, etc...)">
                info_outline
            </i>
        </div>
        <div class="col s4 input-field">
            <input name="external"
                     type="checkbox"
                     id="{ parent.container.name }_external_{ port.name }"
                     onclick="{ setBool }"
                     checked="{ checked: port.external }"/>
            <label for="{ parent.container.name }_external_{ port.name }">External</label>
            <i class="tiny material-icons"
                title="If set, this Port will be set on the Load Balancer.">
                info_outline
            </i>
        </div>
        <div class="col s4 input-field">
            <input name="public_vip"
                     type="checkbox"
                     id="{ parent.container.name }_public_{ port.name }"
                     onclick="{ setBool }"
                     checked="{ checked: port.public_vip }"/>
            <label for="{ parent.container.name }_public_{ port.name }">Public</label>
            <i class="tiny material-icons"
                title="If set, this Shipment will be exposed to the world on any Port set to external.">
                info_outline
            </i>
        </div>
    </div>
    <div class="row">
        <div class="col s12 input-field">
            Protocol
            <select id="protoSelect" class="proto-select" name="protocol" onchange="{ setValue }" style="width: 100%">
                <option
                    each="{ proto in protos }"
                    selected="{ proto == this.parent.port.protocol }"
                    value="{ proto }">{ proto }
                </option>
            </select>
        </div>
        <div class="col s12" if="{ port.protocol == 'tcp' }">
          <div class="col s4 input-field">
              <input type="checkbox"
                       id="{ parent.container.name }_proxy_proto_{ port.name }"
                       name="enable_proxy_protocol"
                       onclick="{ setBool }"
                       checked="{ checked: port.enable_proxy_protocol }" />
              <label for="{ parent.container.name }_proxy_proto_{ port.name }">Proxy Protocol</label>
              <i class="tiny material-icons"
                  title="If set, this port will forward client information along to the origin. Read Here for more info: http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-proxy-protocol.html">
                  info_outline
              </i>
          </div>
        </div>
        <div class="col s12" if="{ port.protocol == 'https' }">
            <div class="row">
                <div class="col s12">
                  <br>
                  <p>Choose Type</p>
                  <div class="col s2 input-field">
                    <input class="with-ga"
                           type="radio"
                           name="ssl_management_type_{ port.name }"
                           value="acm"
                           onchange="{ setValue }"
                           checked="{ checked: port.ssl_management_type === 'acm' }"
                           id="{ parent.container.name }_acm_radio_{ port.name }">
                    <label for="{ parent.container.name }_acm_radio_{ port.name }">ACM</label>
                    <i class="tiny material-icons type-i"
                        title="Use the ARN value of the certificate that works for this shipment. Make sure the ARN lives in the correct account or else the ELB will fail.">
                        info_outline
                    </i>
                  </div>
                  <div class="col s2 input-field">
                    <input class="with-ga"
                           type="radio"
                           name="ssl_management_type_{ port.name }"
                           value="iam"
                           onchange="{ setValue }"
                           checked="{ checked: port.ssl_management_type === 'iam' }"
                           id="{ parent.container.name }_iam_radio_{ port.name }">
                    <label for="{ parent.container.name }_iam_radio_{ port.name }">IAM</label>
                    <i class="tiny material-icons type-i"
                        title="Use raw IAM to create a certificate. You will need the raw private key and the public certs to go with it.">
                        info_outline
                    </i>
                  </div>
                </div>
            </div>
            <div class="row" if="{ port.ssl_management_type === 'iam' }">
                <div class="col s12 input-field">
                    <p><textarea id="private_key" name="private_key" class="materialize-textarea" onchange="{ setTextAreaValue }">{ port.private_key }</textarea></p>
                    <label for="private_key">Private Key</label>
                </div>

                <div class="col s12 input-field">
                    <p><textarea id="public_key_certificate" name="public_key_certificate" class="materialize-textarea" onchange="{ setTextAreaValue }">{ port.public_key_certificate }</textarea></p>
                    <label for="public_key_certificate">Public Key Certificate</label>
                </div>

                <div class="col s12 input-field">
                    <p><textarea id="certificate_chain" name="certificate_chain" class="materialize-textarea" onchange="{ setTextAreaValue }">{ port.certificate_chain }</textarea></p>
                    <label for="certificate_chain">Certificate Chain</label>
                </div>
            </div>
            <div class="row"  if="{ port.ssl_management_type === 'acm' }">
              <div class="col s12 input-field">
                  <input type="text" name="ssl_arn" value="{ port.ssl_arn }" onblur="{ setValue }" />
                  <label for="ssl_arn">SSL ARN</label>
              </div>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.protos = ['http', 'https', 'tcp'];

    /**
     * setTextAreaValue
     *
     * sets values for text areas that might contain line breaks
     *
     * @param {Event} evt The event that was triggered
     */
    setTextAreaValue(evt) {
        d('shipit_port::setTextAreaValue')
        self.port[evt.target.name] = evt.target.value.replace(/\\n/g, "\\n");
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
     * @param {Event} evt The event that was triggered
     */
    setValue(evt) {
        d('shipit_port::setValue %s="%s"', evt.target.name, evt.target.value)
        var ele = evt.target;

        if (ele.value) {
            self.port[ele.name] = ele.value;
            self.parent.parent.update();
            self.port.value = parseInt(self.port.value);
            if (self.port.primary === true && !self.port.healthcheck) {
                RiotControl.trigger('flash_message', 'Primary Ports must have a healthcheck.', 30000);
            } else {
                RiotControl.trigger('port_value_changed', self.parent.container, self.port);
            }
        }
    }

    /**
     * setName
     *
     * sets the name of a port
     *
     * @param {Event} evt The event that was triggered
     */
    setName(evt) {
        d('shipit_port::setName')
        self.port.oldName = self.port[evt.target.name];
        self.port[evt.target.name] = evt.target.value;
        self.parent.parent.update();
        self.port.value = parseInt(self.port.value);
        RiotControl.trigger('port_value_changed', self.parent.container, self.port);
    }

    /**
     * setBool
     *
     * sets a boolean value
     *
     * @param {Event} evt The event that was triggered
     */
    setBool(evt) {
        d('shipit_port::setBool')
        var name = evt.target.name;
        self.port[evt.target.name] = !self.port[evt.target.name];

        if (name === 'primary') {
            self.parent.container.ports.map(function (port) {
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

    self.on('mount', function () {
        $('.proto-select').select2();
    });

    self.on('update', function () {
        d('shipit_port::update', self.opts)
        self.port = self.opts.port;
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
