<buildit_plan>

    <loading_elm if="{!plan && !branch && !error}"></loading_elm>
    <buildit_branch if="{branch && !buildNum}" plan="{ plan.name }" branch="{branch}"></buildit_branch>
    <div class="container" if="{branch && buildNum}">
        <buildit_run if="{!error}" plan="{ plan }" branch="{ branch }" buildnum="{ buildNum }" run="{ run }"></buildit_run>
        <div if="{error}">
            <center>
                <h4>404 Not Found ({plan.name}/{ branch.name }/{ buildNum })</h4>
            </center>
        </div>
    </div>
    <div if="{plan && !branch}">
        <ul id="buildit-plan-tabs" class="tabs">
            <li class="tab col s2"><a href="#tabs-branches" value="branches" onclick="{ editUrl }">Branches</a></li>
            <li class="tab col s2"><a href="#tabs-info" value="info" onclick="{ editUrl }">Information</a></li>
            <li class="tab col s2"><a href="#tabs-admin" value="admin" onclick="{ editUrl }">Administration</a></li>
        </ul>


        <div id="tabs-branches">
            <h4>Branches</h4>
            <button class="btn" onclick="{ addBranch }">Add Branch</button>
            <div class="collection">
                <div if="{ adding }" class="collection-item">
                    Name: <input placeholder="branch_name" name="" type="text" onkeyup="{ setNewBranch }" />
                    Pre Release Label: <input placeholder="pre-release-label" type="text" name="" onkeyup="{ setPreReleaseLabel }" />
                </div>
                <div each="{ item in plan.branches}" class="collection-item">
                    <div class="row">
                        <div class="col s8">
                            <a href="#buildit/{ plan.name }/{ item.name }">
                                <h5 name="item-{ item.name }">{ item.name }</h5>
                            </a>
                        </div>
                        <div class="col s2">
                            <button class="right btn run-btn" name="{ item.name }" onclick="{ runBuild }">
                                Run Build
                            </button>
                        </div>
                        <div class="col s2">
                            <button class="right btn delete-btn" name="{ item.name }" onclick="{ spliceBranch }">
                                delete
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="tabs-info">
            <h4>Information</h4>
            <h5>Repo URL</h5>
            <input name="repo"
                   type="text"
                   value={ plan.repo }
                   onkeyup={ setValue }
                   placeholder="git@github.com:turnerlabs/hello-world.git"
                   required/>

            <h5>Webhook</h5>
            <input type="text"
                   value={ plan.webhook }
                   readonly="true"
                   placeholder="git@bitbucket.org:vgtf/hello-world.git"
                   required/>

            <h5>Pub Key</h5>
            <textarea class="pubkey"
                   name="pubKey"
                   type="text"
                   value={ plan.pubKey }
                   readonly="true"
                   required/>
        </div>

        <div id="tabs-admin">
            <h4>Administration</h4>
            <h5>Users</h5>
            <div class="row">
                <div class="col s6 input-field">
                    <p>+ Admins</p>
                    <select id="adminSelect" class="user-select selectbox" onchange="{ addAdmin }" style="width: 100%" data-placeholder="Pick user for admin">
                        <option></option>
                        <option each="{ user in users }" value="{ user }">{ user }</option>
                    </select>
                </div>
            </div>
            <div class="collection">
                <div each="{ item in plan.admins}" class="collection-item">
                    <div class="row">
                        <div class="col s10">
                            <p name="item-{ item }">
                                { item }
                            </p>
                        </div>
                        <div class="col s2">
                            <button class="right btn delete-btn" name="{ item }" onclick="{spliceAdmin}">
                                delete
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <h5>Groups</h5>
            <div class="row">
                <div class="col s6 input-field">
                    <p>+ Groups</p>
                    <select id="groupSelect" class="group-select selectbox" onchange="{ addGroup }" style="width: 100%" data-placeholder="Pick a group">
                        <option></option>
                        <option each="{ group in groups }" value="{ group }">{ group }</option>
                    </select>
                </div>
            </div>
            <div class="collection">
                <div each="{ item in plan.groups}" class="collection-item">
                    <div class="row">
                        <div class="col s10">
                            <p name="item-{ item }">
                                { item }
                            </p>
                        </div>
                        <div class="col s2">
                            <button class="right btn delete-btn" name="{ item }" onclick="{spliceGroup}">
                                delete
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <button disabled="{updating || !plan.changed ? true : ''}" class="btn" onclick={ updatePlan }>Update Plan</button>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        routed = false,
        checking = false,
        wasRunning = false,
        branchName,
        lastBuildNum,
        timestamp;

    self.error = false;
    self.updating = false;
    RiotControl.on('build_alter_plan_result', alterPlanResult);
    RiotControl.on('build_check_for_plan_result', setPlan);
    RiotControl.on('build_get_latest_build_logs_diff_result', setBuildItLogs);
    RiotControl.on('build_run_plan_result', onBuildTriggered);
    RiotControl.on('get_users_result', setUsers);
    RiotControl.on('get_user_groups_result', setGroups);

    addBranch() {
        self.adding = !self.adding;
    }

    addAdmin(evt) {
        var user = evt.target.value;

        if ( self.plan.admins.indexOf(user) === -1) {
            self.plan.admins.push(user);
        }

        self.plan.changed = true;
        self.update();
    }

    editUrl(evt) {
        var val = evt.target.getAttribute('value'),
            hash = window.location.hash.split('/');

        d('build plan', val, hash);

        hash[3] = val;
        //window.location.hash = hash.join('/');
    }

    runBuild(evt) {
        var branch = evt.target.name;
        RiotControl.trigger('build_run_plan', self.plan.name, branch);
        RiotControl.trigger('send_metric', 'buildit.plan.run.start');
        self.update();
    }

    spliceAdmin(evt) {
        var index = self.plan.admins.indexOf(evt.target.name);

        if (index !== -1) {
            self.plan.admins.splice(index, 1);
        }

        self.plan.changed = true;

        self.update();
    }

    addGroup(evt) {
        var group = evt.target.value;

        if ( self.plan.groups.indexOf(group) === -1) {
            self.plan.groups.push(group);
            self.plan.changed = true;
        }

        self.update();
    }

    spliceGroup(evt) {
        var index = self.plan.groups.indexOf(evt.target.name);

        if (index !== -1) {
            self.plan.groups.splice(index, 1);
            self.plan.changed = true;
        }

        self.update();
    }

    spliceBranch(evt) {
        var name = evt.target.name,
            index;


        for (var i = 0;i < self.plan.branches.length;i++) {
            if (self.plan.branches[i].name === name) {
                index = i;
                break;
            }
        }

        if (index !== undefined) {
            self.plan.branches.splice(index, 1);
            self.plan.changed = true;
        }

        self.update();
    }

    setNewBranch(e) {
        self.newBranch = {name: e.target.value};
        self.plan.changed = true;
        self.update();
    }

    setPreReleaseLabel(evt) {
        self.newBranch.preReleaseLabel = evt.target.value;
        self.update();
    }

    /**
     *
     * setValue
     *
     * sets the value of a plans value, based on the input name
     *
     * @param {Element} input The element that the event was triggered
     */
    setValue(input) {
        self.plan[input.srcElement.name] = input.srcElement.value;
        self.plan.changed = true;
        self.update();
    }

    /**
     * updates the current plan
     */
    updatePlan() {
        self.updating = true;
        if (self.newBranch) {
            self.plan.branches.push(self.newBranch);
            self.newBranch = null;
        }
        RiotControl.trigger('send_metric', 'buildit.plan.alter.start');
        RiotControl.trigger('build_alter_plan', self.plan.name, self.plan);
    }

    /**
     * alterPlanResult
     *
     * when the request comes back. The app needs to do two differnent actions based on success or failure.
     *
     * @param  {Object} result The data object returned from buildit
     * @param  {Object} err (optional) If present then there was an error, show this error message
     */
    function alterPlanResult(result, err) {
        if (err) {
             RiotControl.trigger('send_metric', 'buildit.plan.alter:failure', err)
             RiotControl.trigger('flash_message', 'error', err);
             self.error = true;
        } else {
             RiotControl.trigger('send_metric', 'buildit.plan.alter:success')
             RiotControl.trigger('flash_message', 'success', 'Updated  "' + self.plan.name + '" Successfully');
        }
        self.updating = false;
        self.update();
    }

    /**
     * setPlan
     *
     * when the app gets a plan, set it to this context.
     *
     * @param  {Object} result The data object returned from buildit
     * @param  {Object} status The status of the request
     */
    function setPlan(result, status) {

        checking = false;

        if (status === 'error') {
            RiotControl.trigger('flash_message', 'error', 'The buildplan named: ' + self.plan.name + ' does not exist');
            self.error = true;
        } else {
            self.plan = result;

            if (self.branch && self.buildNum) {
                checking = true;
                RiotControl.trigger('build_get_latest_build_logs_diff', result.name, self.branch.name, self.buildNum);
            }
        }

        self.update();
    }

    /**
     * getPlan
     *
     * when the app is routed to this page, get the desired buildplan.
     *
     * @param  {String} plan The plan's name
     */
    function getPlan(plan) {
        if (plan) {
            self.plan = null;
            RiotControl.trigger('build_check_for_plan', plan);
            checking = true;
        }
    }

    /**
     *  setBuildItLogs
     *  sets the latest logs from buildit
     *
     * @param {Object} data The data returned from buildit
     * @param {String} error The error message
     */
    function setBuildItLogs(data, error) {

        if (!routed) {
            return;
        }

        lastBuildNum = self.buildNum;

        if (error) {
            setTimeout(function() {
                if (self.branch && self.buildNum && self.run && self.run.status === 'running') {
                    RiotControl.trigger('build_get_latest_build_logs_diff', self.plan.name, self.branch.name, self.buildNum, timestamp);
                } else {
                    RiotControl.trigger('flash_message', 'error', error);
                    RiotControl.trigger('send_metric', 'buildit.plan.run:failure', error);
                    self.error = true;
                    self.update();
                }
                self.update();
            }, 3 * 1000);
            return;
        }

        if (!self.run) {
            self.run = data;
        }

        self.run.status = data.status;

        if (data.logs && data.logs.length > 0) {
            timestamp = data.logs[data.logs.length - 1].date;
        }

        if (!self.run.convertedLogs) {
             self.run.convertedLogs = '';
        }

        self.run.convertedLogs += data.logs.map(function(o) { return o.text}).join('');


        if (data.status === 'running' || data.error) {
            wasRunning = true;
            setTimeout(function() {
                if (self.branch && self.buildNum && self.run && self.run.status === 'running') {
                    RiotControl.trigger('build_get_latest_build_logs_diff', data.name, self.branch.name, self.buildNum, timestamp);
                }
            }, 3 * 1000);
        } else if (wasRunning && data.status === 'failure') {
            RiotControl.trigger('flash_message', 'error', 'The build failed.');
            RiotControl.trigger('send_metric', 'buildit.plan.run.end', 'The build failed.');
        } else if (wasRunning && data.status === 'success') {
            RiotControl.trigger('flash_message', 'passed', 'The build passed.');
            RiotControl.trigger('send_metric', 'buildit.plan.run.end');
        }

        checking = false;

        riot.update();
    }

    /**
     * onBuildTriggered
     *
     * The occurs, once a build is triggered to run.
     *
     */
    function onBuildTriggered(data, err) {

        if (!routed) {
            return;
        }

        d('build::build_run_plan_result', data);

        if (err) {
            var message = 'The buildplan named: ' + self.plan.name + ' for Branch: ' + self.branch.name + ' failed to run.';
            RiotControl.trigger('flash_message', 'error', message);
            RiotControl.trigger('send_metric', 'buildit.plan.run.failed', message)
        } else {
            self.run = null;
            riot.route('buildit/' + data.name + '/' + data.branch + '/' + data.number);
        }

        self.update();

    }

    /**
     * setUsers
     * sets the users to the local scope
     */
    function setUsers(data, err) {
        self.users = data.users;
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

    self.on('update', function() {

        if (!routed || checking === true) {
            return;
        }

        if (self.plan) {

            self.branch = self.plan.branches.find(function(item) {
                if (item.name === branchName) {
                    return true;
                }
            });
        }

        if (self.opts.plan && !self.plan || (self.plan && self.plan.name !== self.opts.plan)) {
            getPlan(self.opts.plan);
        } else if (self.branch && self.buildNum && lastBuildNum !== self.buildNum) {
            self.run = null;
            lastBuildNum = self.buildNum;
            RiotControl.trigger('build_get_latest_build_logs_diff', self.plan.name, self.branch.name, self.buildNum);
        }

        setTimeout(function () { $('.selectbox').select2(); }, 100);
    });

    riot.route(function (type, plan, branch, buildNum) {


        branchName = branch;
        self.buildNum = buildNum;
        self.error = false;

        if (type.replace('#', '') === 'buildit' && plan) {
            routed = true;
        } else {
            routed = false;
            checking = false;
            lastBuildNum = null;
            wasRunning = false;
        }

        self.update();
    });

    self.on('mount', function () {
        setTimeout(function () {
            $('#buildit-plan-tabs').tabs();
        }, 200);
    });
    </script>

    <style scoped>

    .pubkey {
        height: 150px;
        font-family: monospace;
    }

    .delete-btn {
        margin-top: 10px;
        margin-right: 10px;
        background-color: #F44336;
    }

    .run-btn {
        margin-top: 10px;
        margin-right: 30px;
    }

    </style>

</buildit_plan>
