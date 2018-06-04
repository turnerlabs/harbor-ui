<shipyard>
    <div class="container" id="index-banner">
        <div class="row">
            <div class="col s12 m12">
                <h1 class="header center-on-small-only">Shipyard</h1>
            </div>
        </div>
    </div>
    <no_groups_found if="{ !hasGroups }"></no_groups_found>
    <info if={ hasGroups && step == 'info' }></info>
    <containers  if={ hasGroups && step == 'containers' }></containers>
    <variables if={ hasGroups && step == 'variables' }></variables>
    <confirm if={ hasGroups && step == 'confirm' }></confirm>
    <create if={ hasGroups && step == 'create' }></create>

    <script>
    var self = this,
        d = utils.debug,
        currentRoute;

    riot.route(function (type, step, path, branch) {

        if (type === 'shipyard') {
            d('create::riot.route(%s %s)', type, step, branch);
            RiotControl.trigger('retrieve_state', step, path, branch);

            self.step = step;
            self.path = path;
            self.branch = branch;
            self.update();
        }

        RiotControl.trigger('app_changed', type, step, branch);

    });

    RiotControl.on('get_user_groups_result', function (data) {
        self.hasGroups = data.groups.length > 0;
        self.update();
    });
    </script>
</shipyard>
