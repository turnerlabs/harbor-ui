<buildit_add_plan>
    <div>
        <div class="card blue-grey darken-1">
            <div class="card-content white-text">
                <p>Your repo must be build-able via <a href="http://docs.turner.com/display/MADOPS/BuildIt" target="_blank" title="BuildIt Documentation. Will open in new window/tab.">BuildIt</a>. To be build-able:</p>
                <ul>
                    <li>Please make sure your repo follows these instructions</li>
                    <li>* your repo needs to have a <code>Dockerfile</code> or <code>package.json</code> that lays out installation instructions.</li>
                    <li>* must have a version specified in <code>TURNER_METADATA</code> or in the <code>Dockerfile</code>, read <a href="https://bitbucket.org/vgtf/mss-docker-build-scripts" target="_blank">here</a> for more details on TURNER_METADATA</li>
                    <li>* must have a Deployment Key added to the repo (we will provide the deployment key in a later step).</li>
                </ul>
            </div>
        </div>

        <h5>Repo URL</h5>
        <div class="row">
            <div class="col s6">
                <div class="input-info">
                    <div name="repo-url" class="add-info"><p>Enter the URL, using the SSH GIT address, of your Bitbucket or Github repo.</p></div>
                </div>
                <input name="gitInput" type="text" value={ opts.plan.repo } onkeyup={ setGit } placeholder="git@bitbucket.org:vgtf/hello-world.git" required />
            </div>
            <div class="col s6">
                <h5>Groups</h5>
                <div class="row">
                    <div class="col s6 input-field">
                        <select id="groupSelect" class="group-select" onchange="{ addGroup }" style="width: 100%" data-placeholder="Pick group">
                            <option></option>
                            <option each="{ group in groups }" value="{ group }">{ group }</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col s6">
                <h5>Container Name</h5>
                <input id="containerInput" name="containerInput" type="text" value={ opts.plan.containerName } onkeyup={ setContainerName } placeholder="hello-world" required />
            </div>
            <div class="col s6">
                <h5>Branch Name</h5>
                <input name="branchInput" type="text" value={ opts.plan.branch.name } onkeyup={ setBranch } required placeholder="master" />
            </div>
        </div>
        <h5>Pre-Release Label</h5>
        <div class="input-info">
            <div name="pre-release-label" class="add-info"><p>This is an optional value to help Containers versions build off of different branches. This value must conform with
            <a href="http://semver.org/spec/v2.0.0.html" target="_blank">SemVer 2.0 Pre-Release Labels</a>, using this value helps to ensure your software development lifecycle conforms with
                the Tweleve Factor concept of a <a href="http://12factor.net/build-release-run" target="_blank" title="12 Factor: Build, Release, Run. Will open in a new window/tab">Release</a>.</p></div>
        </div>
        <p><input name="preReleaseLabelInput" placeholder="my-pre-release-label" type="text" value={ opts.plan.branch.preReleaseLabel } onkeyup={ setPreReleaseLabel } /></p>
    </div>

    <script>

    var self = this,
        d = utils.debug;

    RiotControl.on('get_user_groups_result', setGroups);

    setGit(evt) {
        d('buildit/add_plan::setGit', self.gitInput.value);

        if ($("#containerInput").is(":focus")) {
            self.plan.hasCustomName = true;
        }

        var val  = self.gitInput.value,
            branchName = self.branchInput.value,
            preReleaseLabel = self.preReleaseLabelInput.value,
            name = val.match(/\/(.+)/);

        self.plan.type = 'git';
        self.plan.repo = val;
        self.plan.branch = {
            name: branchName ? branchName : 'master'
        };
        self.plan.updated = true;

        self.containerName = self.containerInput.value;

        if (preReleaseLabel) {
            self.plan.branch.preReleaseLabel = preReleaseLabel;
        }

        if (!self.plan.hasCustomName && name && !self.containerInput.value) {
            name = name[1];

            if (name.indexOf('.git') !== -1) {
                name = name.split('.')[0];
            }

            self.plan.containerName = name;
        }

        if (self.opts.savestate) {
            RiotControl.trigger('save_state', 'code', self.plan);
            RiotControl.trigger('save_state', 'tab', 1);
        }

        self.update();
    }

    /**
     * setGroups
     * sets the groups to the local scope
     */
    function setGroups(data, err) {
        setTimeout(function () { $('.group-select').select2(); }, 100);
    }

    setContainerName(evt) {
        d('buildit/add_plan::setContainerName', self.containerInput.value);

        self.plan.containerName = self.containerInput.value;
        self.plan.updated = true;

        if (self.opts.savestate) {
            RiotControl.trigger('save_state', 'code', self.plan);
        }

        self.setGit();

        self.update();
    }

    setBranch(evt) {
        d('buildit/add_plan::setBranch', self.branchInput.value);

        self.plan.branch.name = self.branchInput.value;
        self.plan.updated = true;

        if (self.opts.savestate) {
            RiotControl.trigger('save_state', 'code', self.plan);
        }

        self.setGit();

        self.update();
    }

    setPreReleaseLabel(evt) {
        d('buildit/add_plan::setPreReleaseLabel', self.preReleaseLabelInput.value);

        var branchName = self.branchInput.value;

        if (!self.plan.branch) {
             self.plan.branch = {
                name: branchName ? branchName : 'master'
            };
        }

        self.plan.branch.preReleaseLabel = self.preReleaseLabelInput.value;
        self.plan.updated = true;

        if (self.opts.savestate) {
            RiotControl.trigger('save_state', 'code', self.plan);
        }

        self.setGit();

        self.update();
    }

    addGroup(evt) {
        var group = evt.target.value;
        self.plan.groups.length = 0;
        self.plan.groups.push(group);
        self.parent.update();
    }


    self.on('update', function(){
        self.groups = self.opts.groups;
        self.plan = self.opts.plan;
    });

    </script>

    <style>
    </style>
</buildit_add_plan>
