<buildit_branch>
    <loading_elm if="{!builds}"></loading_elm>
    <div if="{opts.plan && builds}">
        <button class="btn" onclick="{ runBuild }" >Run Build</button>

        <h5>Pre-Release Label</h5>
        <div class="input-info">
            <div name="pre-release-label" class="add-info"><p>Add a pre-release-label if this branch needs to be built constantly without
            updates to the version, or if this branch needs to prepend the pre-release-label to the container name.</p></div>
        </div>
        <input name="preReleaseLabel"
               type="text"
               value={ branch.preReleaseLabel }
               onkeyup={ setValue }
               placeholder="pre-release-label"
               required/>

        <button disabled="{updating ? true : ''}" if="{ branch.changed }" class="btn" onclick={ updateBranch }>Update Plan</button>

        <h5>Builds</h5>
        <div class="collection">
            <div each="{ item in builds.filter(filterBranch)}" class="collection-item { item.status }">
                <a href="#buildit/{ parent.opts.plan }/{ branch.name }/{ item.number }">
                    <h5 name="item-{ item.number }">{ item.number }</h5>
                </a>
                <ul>
                    <li>Started: { item.started }<li>
                    <li>Status Message: { item.statusMessage }</li>
                    <li>Version: { item.version }</li>
                    <li>Status: { item.status }</li>
                <ul>
            </div>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        routed;

    self.branch = null;
    self.builds = null;
    self.updating = false;

    RiotControl.on('build_get_all_builds_result', setBuilds);
    RiotControl.on('build_alter_branch_result', alertOnBranchUpdate);

    runBuild() {
        RiotControl.trigger('build_run_plan', self.opts.plan, self.branch.name);
    }

    updateBranch() {
        self.updating = true;
        RiotControl.trigger('build_alter_plan_branch', self.opts.plan, {branch: self.branch});
        self.update();
    }

    filterBranch(build) {
        return build.branch === self.branch.name;
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
        self.branch[input.srcElement.name] = input.srcElement.value;
        self.branch.changed = true;
        self.update();
    }

    /**
     * setBuilds
     *
     * when the app gets a plan, set it to this context.
     *
     * @param  {Object} result The data object returned from buildit
     * @param  {Object} status The status of the request
     */
    function setBuilds(result, status) {

        if (!routed) {
            return;
        }

        if (status === 'error') {
             RiotControl.trigger('flash_message', 'error', 'There was an error with the request for Branch: ' + self.branch.name);
        } else {
             self.builds = result;
        }
        self.update();
    }

    /**
     * alertOnBranchUpdate
     * alerts the user and lets them know what happened when they tried to save the branch.
     */
    function alertOnBranchUpdate(data, err) {

        if (!routed) {
            return;
        }

        if (err) {
            RiotControl.trigger('flash_message', 'error', 'There was an error with the request: ' + err);
        } else {
            RiotControl.trigger('flash_message', 'success', 'Branch: ' + self.branch.name + ' has been saved.');
        }

        addMessage(msg.replace('%name', self.state.path));
    }

    /**
     * getBranchBuilds
     *
     * when the app is routed to this page, get the desired buildplan.
     *
     * @param  {String} plan The plan's name
     * @param  {Object} branch The branch
     */
    function getBranchBuilds(plan, branch) {
        if (plan && branch) {
            self.branch = branch;
            self.plan = plan;
            self.builds = null;
            RiotControl.trigger('build_get_all_builds', plan, branch.name);
        }
    }

    riot.route(function (type, plan, branch, buildNum) {

        self.buildNum = buildNum;

        if (type.replace('#', '') === 'buildit' && plan && branch) {
            routed = true;
        } else {
            routed = false;
            self.branch = null;
        }

        self.update();
    });

    self.on('update', function() {
        if (!routed) {
            return;
        }

        if (self.opts.plan && self.opts.branch && !self.branch || (self.plan !== self.opts.plan) || (self.branch && self.opts.branch && self.branch.name !== self.opts.branch.name)) {
            getBranchBuilds(self.opts.plan, self.opts.branch);
        }
    });

    </script>

    <style scoped>

    .collection-item.failure {
        border: 5px solid #F44336;
    }

    </style>

</buildit_branch>
