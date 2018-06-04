<buildit_plans>

    <h2> Select a Plan
        <span class="tail">
            <input type="checkbox" id="tail" value="{ showAllPlans }" onclick="{ showAll }" checked="{checked: showAllPlans}"/>
            <label for="tail">Show All Plans</label>
        </span>
    </h2>


    <div class="row">
        <div class="input-field col s6">
          <i class="material-icons prefix">search</i>
          <input name="searchTextElm" id="search" placeholder="Search..." type="text" onkeyup="{ updateSearchText }">
        </div>
    </div>

    <div class="collection">
        <div each="{ item in opts.plans.filter(permsFilter).filter(textFilter) }" class="collection-item">
            <a href="#buildit/{ item.name }">
                <h5 name="item-{ item.name }">{ item.name }</h5>
            </a>
        </div>

        <div class="card blue-grey darken-1" if="{ opts.plans.filter(permsFilter).length === 0 }">
            <div class="card-content white-text">
                <p>There are no plans which you can edit at this time. Click the Show All Plans checkbox to navigate plans.</p>
            </div>
        </div>
    </div>


    <script>
    var self = this,
        d = utils.debug,
        routed = false;

    RiotControl.on('build_create_plan_result', notifyOnPlanAction);
    RiotControl.on('get_user_groups_result', setGroups);

    self.newPlan = {repo:'', branch: {}, groups: []};
    self.updating = false;
    self.groups = [];
    self.showAllPlans = false;

    showPlanForm () {
        self.addingPlan = !self.addingPlan;
    }

    showAll () {
        self.showAllPlans = !self.showAllPlans;
    }

    addPlan() {
        if (self.newPlan.groups.length === 0) {
            RiotControl.trigger('flash_message', 'error', 'You must add a Group.');
            return;
        }
        self.newPlan.name = self.newPlan.containerName;
        self.opts.plans.push(self.newPlan);
        RiotControl.trigger('send_metric', 'buildit.createPlan[%s].start'.replace('%s', self.newPlan.name));
        RiotControl.trigger('build_create_plan', self.newPlan.name, {code: self.newPlan});
        self.updating = true;
        self.update();
    }

    permsFilter (plan) {
        var show = self.showAllPlans,
            username = ArgoAuth.getUser();

        if (plan.admins.indexOf(username) !== -1) {
            show = true;
        }

        if (show === false) {
            for (var i = 0;i < self.groups.length;i++) {
                if (plan.groups.indexOf(self.groups[i])  !== -1) {
                    show = true;
                }
            }
        }

        return show;
    }

    textFilter (plan) {
        var show = false;
        if (self.searchText) {
            show = plan.name.indexOf(self.searchText) !== -1;
        } else {
            show = true;
        }

        return show;
    }

    updateSearchText(e) {
        self.searchText = e.target.value;
    }

    /**
     * notifyOnPlanAction
     * lets the user know what happened, since they created a new plan.
     * let them know they can now navigate to the new plan and create branches for it.
     */
    function notifyOnPlanAction(data, err) {

        if (!routed) {
            return;
        }

        if (err) {
            RiotControl.trigger('flash_message', 'error', 'The buildplan named: ' + self.newPlan.name + ' failed during creation with ' + err);
            RiotControl.trigger('send_metric', 'buildit.createPlan:failure', err);
        } else {
            RiotControl.trigger('send_metric', 'buildit.createPlan:success');
            RiotControl.trigger('flash_message', 'success', 'The buildplan named: ' + self.newPlan.name + ' was successfully created.');
            riot.route('buildit/' + self.newPlan.name);
            self.newPlan = {repo:'', branch: {}, groups: []};
        }

        self.updating = false;

        self.update();

    }

    /**
     * setGroups
     * sets the groups to the local scope
     */
    function setGroups(data, err) {
        self.groups = data.groups.map(function(k) { return k.name || ""; });
        self.update();
    }

    riot.route(function (type, plan, branch, buildNum) {

        if (type.replace('#', '') === 'buildit' && !plan) {
            routed = true;
        } else {
            routed = false;
        }

        self.update();
    });

    self.on('update', function() {
        setTimeout(function () { $('.group-select').select2(); });
    });
    </script>

    <style scoped>
    </style>
</buildit_plans>
