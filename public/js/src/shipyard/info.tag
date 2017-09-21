<info>

    <div id="create-info" class="container">

        <h4>Step 1: Basic Information</h4>
        <div class="card blue-grey lighten-4">
            <div class="card-content black-text">
                We will now setup the basic information for your Shipment. This shipment will run in a particular environment, and will have a particular name that is referred to as the Product name or Shipment name, these are used interchangeably.
                This basic information will help us categorize your app to ensure it gets the correct permissions and reporting. Group, Project and App Type are used to derive the Product.
            </div>
        </div>

        <div class="argo-tabs">
            
            <div class="row">
                <div class="col s6">
                    <h5>Contact Email (Required)</h5>
                    <p><input type="text" name="propertyInput" onblur={ setEmail } value={ email } required placeholder="Enter Email of Contact" /></p>
                    <span class="tiny-helper">The Distro or Individual Contact of who is responsible for this application</span>
                </div>
            </div>

            <div class="row">
                <div class="col s6">
                    <h5>Group</h5>
                    <span class="tiny-helper">The team that is responsible for this application. This will define who has write authorization for this Shipment.</span>
                    <select id="customer-select" class="harbor-select" onchange={ setCustomer } style="width: 100%" data-placeholder="Pick group">
                        <option></option>
                        <option each={ customers } selected={ parent.main.group == name }>{ name }</option>
                    </select>
                    <span class="col s1"><img if={ loading } src="images/loader.gif" width="16" height="16" title="Loading" alt="loading"/></span>
                </div>
                <div class="col s6">
                    <h5>Environment</h5>
                    <span class="tiny-helper">Your Environment will be used to determine escalation rules for your application, as well as determine usage patterns.</span>
                    <select id="environment-select" class="harbor-select" onchange={ setEnvironment } style="width: 100%" data-placeholder="Pick environment">
                        <option></option>
                        <option each={ environments } selected={ shipment.environment.name == name }>{ name }</option>
                    </select>
                </div>
            </div>

            <div class="row">
                <div class="col s3">
                    <h5>Property</h5>
                    <p><input type="text" name="propertyInput" onblur={ setProperty } value={ property } required placeholder="Enter the property name" /></p>
                    <span class="tiny-helper">The top-level domain, that this application will be served under. (e.g. nba.com, dmtio.net, cnn.com)</span>
                </div>
                <div class="col s3">
                    <h5>Project</h5>
                    <p><input type="text" name="projectInput" onblur={ setProject } value={ project } required placeholder="Enter the project name" /></p>
                    <span class="tiny-helper">The broad project name used by your team to collect and organize all the applications together. (e.g. expansion)</span>
                </div>
                <div class="col s3">
                    <h5>App Type</h5>
                    <p><input type="text" name="appNameInput" onblur={ setAppName } value={ appName } required placeholder="Enter the application name" /></p>
                    <span class="tiny-helper">The application type or purpose. This is generally something short, that when combined with the Project makes a more meaningful application name. (e.g. app, fe, or ws)</span>
                </div>
                <div class="col s3">
                    <h5>Product Name</h5>
                    <p><input type="text" name="productNameInput" value="{ main.name }" placeholder="The Product Name will be generated for you" onblur="{ setProduct }"/></p>
                    <span class="tiny-helper">This will be the name of the Shipment. You can override this field if you wish.</span>
                </div>
            </div>

            <button class="btn next-btn" onclick={ nextStep }>Next Step: Add Containers</button>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        showError = utils.showError,
        jqCustomer,
        jqAppName,
        jqProperty,
        jqProject,
        jqEnvironment,
        jqProduct;

    // main model
    var main = {
        name: '',
        group: '',
        usingCustomName: false,
        vars: []
    };

    // environment model
    var envObj = {
        name: '',
        vars: []
    };

    self.shipment = {
        main: main,
        environment: envObj,
        shipit: true
    };

    self.appName;
    self.project;
    self.customer;
    self.property;
    self.customers;
    self.environments;

    nextStep(evt) {
        d('shipyard/info::nextStep');

        if (validate()) {
            riot.route('shipyard/containers');
        }
    }

    setProduct() {
        var strings = [],
            conventionalNames = [];

        if (self.main.group) {
            strings.push(self.main.group);
            conventionalNames.push(strings.join('-'));
        }
        if (self.project) {
            strings.push(self.project);
            conventionalNames.push(strings.join('-'));
        }
        if (self.appName) {
            strings.push(self.appName);
            conventionalNames.push(strings.join('-'));
        }

        if (self.productNameInput.value.length > 0 && conventionalNames.indexOf(self.productNameInput.value) === -1) {
            self.main.usingCustomName = true;
        }

        if (self.main.usingCustomName === false) {
            self.main.name = conventionalNames[conventionalNames.length - 1];
        } else if (self.productNameInput.value) {
            self.main.name = self.productNameInput.value;
        }

        self.main.vars.splice(3,1,{name: "PRODUCT", value: self.main.name, type: 'basic'});
        RiotControl.trigger('save_state', 'shipment', self.shipment);
        self.update();
    }

    setCustomer(evt) {
        var val = $(evt.target).val().toLowerCase();
        self.main.group = val;
        self.main.vars.splice(0,1,{name: "CUSTOMER", value: val, type: 'basic'});
        mapProperty(val);
        self.setProduct();
    }

    setProperty(evt) {
        var val = self.propertyInput.value
        d('Property', val);
        self.property = val;
        self.main.vars.splice(1,1,{name: "PROPERTY", value: val, type: 'basic'});
        RiotControl.trigger('save_state', 'property', val);
        RiotControl.trigger('save_state', 'shipment', self.shipment);
    }

    setProject(evt) {
        var val = $(evt.target).val().toLowerCase().replace(/[\s\_]+/g, '-');

        if (val) {
            jqProject.removeClass('error');
        }

        self.project = val;
        self.main.vars.splice(2,1,{name: "PROJECT", value: val, type: 'basic'});
        self.setProduct();
        self.update();

        RiotControl.trigger('save_state', 'project', val);
    }

    setAppName(evt) {
        var val = $(evt.target).val().toLowerCase().replace(/[\s\_]+/g, '-');

        if (val) {
            jqAppName.removeClass('error');
        }

        self.appName = val;

        self.setProduct();
        self.update();

        RiotControl.trigger('save_state', 'appName', val);
    }

    setEnvironment(evt) {
        d('shipyard/info::setEnvironment');
        var val = $(evt.target).val().toLowerCase();

        if (!self.envObj) {
            self.envObj = envObj;
        }

        self.envObj.name = val;
        self.update();

        RiotControl.trigger('save_state', 'shipment', self.shipment);
    }

    setEmail(evt) {
        d('shipyard/info::setEmail');
        var val = $(evt.target).val().toLowerCase();

        self.main.contact_email = val;
        self.update();

        RiotControl.trigger('save_state', 'shipment', self.shipment);
    }

    function mapProperty(customer) {
        var map = {
                "adultswim": "adultswim.com",
                "cartoonnetwork": "cartoonnetwork.com",
                "cnn": "cnn.com",
                "cnn2": "cnn.com",
                "cnnalerts": "cnn.com",
                "doc": "dmtio.net",
                "gangstas": "dmtio.net",
                "mss": "dmtio.net",
                "nba": "nba.com",
                "ncaa": "ncaa.com",
                "neteng": "dmtio.net",
                "ops": "dmtio.net",
                "pga": "pga.com",
                "tcm": "tcm.com",
                "tnt": "tnt.com"
            },
            val = map[customer] || '';

        self.propertyInput.value = val;
        self.setProperty()
    }

    function setJqNames() {
        d('shipyard/info::setJqNames', self);

        if (!jqCustomer)
            jqCustomer = $(self.customerSelect);

        if (!jqAppName)
            jqAppName = $(self.appNameInput);

        if (!jqProject)
            jqProject = $(self.projectInput);

        if (!jqEnvironment)
            jqEnvironment = $(self.environmentInput);

        if (!jqProduct)
            jqProduct = $(self.productInput);

        if (!jqEnvironment)
            jqEnvironment = $(self.environmentSelect);

        if (!jqProperty)
            jqProperty = $(self.propertyInput);
    }

    function validate() {
        var valid = 0;

        if (self.shipment.main.group) {
            valid++;
        } else {
            RiotControl.trigger('flash_message', 'error', 'Group is a required field');
            valid --;
        }

        if (self.appName) {
            jqAppName.removeClass('error');
            valid++;
        } else {
            jqAppName.addClass('error');
            valid--;
        }

        if (self.project) {
            jqProject.removeClass('error');
            valid++;
        } else {
            jqProject.addClass('error');
            valid--;
        }

        if (self.shipment.main.name) {
            jqProduct.removeClass('error');
            valid++;
        } else {
            jqProduct.addClass('error');
            valid--;
        }

        if (self.shipment.environment.name) {
            valid++;
        } else {
            RiotControl.trigger('flash_message', 'error', 'Environment is a required field');
            valid--;
        }

        if (valid === 5) {
            valid = true;
        } else {
            showError('Please fix missing fields');
            valid = false;
        }

        return valid;
    }

    self.on('mount', function () {
        d('shipyard/info::mount');

        var user = ArgoAuth.getUser();

        self.environments = [
            {name: 'dev'},
            {name: 'int'},
            {name: 'ref'},
            {name: 'qa'},
            {name: 'staging'},
            {name: 'prod'}
        ];

        if (user) {
            user = 'private-' + user;
            self.environments.unshift({name: user});
        }

        envObj.name = self.environments[0].name;

        // we may already have the customers before we get here.
        if (!self.customers) {
            self.loading = true;
        }

        self.update();
    });

    self.on('update', function () {
        setTimeout(function () {
            $('.harbor-select').select2();
        }, 100);
    });

    RiotControl.on('retrieve_state_result', function (state) {
        if (state.page === 'info') {
            d('shipyard/info::retrieve_state_result', state, self.environments);
            self.appName     = state.appName;
            self.project     = state.project;
            self.customer    = state.customer;
            self.property    = state.property;
            self.shipment = state.shipment || {};
            self.main = self.shipment.main ? self.shipment.main : main;
            self.envObj = self.shipment.environment ? self.shipment.environment : envObj;
            self.shipment.main = self.main;
            self.shipment.environment = self.envObj;
            self.setProduct();

            setJqNames();

            self.update();
        }
    });

    RiotControl.on('get_user_groups_result', function (results) {
        d('shipyard/info::get_user_groups_result', results);

        self.customers = results.groups;
        self.loading   = false;
        self.update();
    });
    </script>

    <style scoped>
    code {
        color: #ADBCA5;
    }
    </style>
</info>
