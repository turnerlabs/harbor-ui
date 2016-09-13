<buildit>

    <div class="section" id="index-banner">
        <div class="container">
            <div class="row">
              <div class="col s12 m12">
                <h1 class="header center-on-small-only">Buildit</h1>
              </div>
            </div>
            <nav if="{ crumbs.length > 1 }" class="row">
                <div class="nav-wrapper blue accent-1">
                    <div class="col s12">
                        <a each="{ crumb in crumbs }" href="{ crumb.url }" class="breadcrumb">{ crumb.name }</a>
                    </div>
                </div>
            </nav>
        </div>
    </div>

    <loading_elm if="{!plans}"></loading_elm>

    <div class="container" if="{plans}">
        <buildit_plans if="{ !plan && !branch && !buildNum }" plans="{plans}"></buildit_plans>
        <buildit_plan if="{ plan }" plan="{plan}"></buildit_plan>
    </div>

    <script>

    var self = this,
        d = utils.debug;

    function setBreadcrumbs(hash) {
        var bits = hash.split('/'),
            path = '',
            crumbs = [];

        bits.forEach(function (item, idx) {
            path += (idx ? '/' : '') + item;

            crumbs.push({
                name: item.replace('#buildit', 'home'),
                url: path
            });
        });

        self.crumbs = crumbs;
    }

    RiotControl.trigger('buildit_get_plans');
    RiotControl.trigger('menu_register', 'Buildit', 'buildit');

    self.on('mount', function() {
        d('Buildit mounted');
    });

    /**
     * sets the plans. This gets a list of all plans available in buildit.
     */
    RiotControl.on('buildit_get_plans_result', function(result, err) {

        if (err) {
            self.error = err;
        }

        self.plans = result;
        self.update();
    });

    riot.route(function (type, plan, branch, buildNum) {
        if (type.replace('#', '') === 'buildit') {
            d('buildit::riot.route', type, plan, branch, buildNum);
            setBreadcrumbs(location.hash);
            self.plan = plan;
            self.branch = branch;
            self.buildNum = buildNum;
            self.update();
        }

        if (type.replace('#', '') === 'buildit' && !plan && !branch && !buildNum) {
            RiotControl.trigger('buildit_get_plans');
            self.update();
        }
    });

    </script>

    <style scoped>
    </style>

</buildit>
