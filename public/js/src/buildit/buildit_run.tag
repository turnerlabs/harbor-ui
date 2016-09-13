<buildit_run>

    <loading_elm if="{!run}"></loading_elm>

    <div if="{run}">

        <h4 class="{run.status}">Status: { run && run.status || 'N/A' }</h4>

        <div class="argo-tabs">

            <span if="{ run && plan }">
                <button class="btn" if={ plan.name } disabled="{run.status === 'running' ? true : ''}" onclick="{ runBuild }" >Run Build</button>
                <button class="btn" if={ plan.pubKey } onclick={ alterPubKey }>{ view.deploymentKeyText }</button>
                <button class="btn" onclick="{ clearLogs }">Clear Logs</button>
            </span>

            <div show={view.showPubKey === true} hide={view.showPubKey !== true}>
                <h5>Public Key</h5>
                <p>This public key must be added to your repository as a deploymnet key. If it is not added then the
                buildit run will fail.</p>
                <textarea class="pubkey" value="{plan.pubKey}"></textarea>
            </div>

            <div class="logs" if="{view.messages}">
                <h5>Harbor Logs</h5>
                <div class="status">
                    <p each={ view.messages }><strong>{ date }</strong> { msg }</p>
                </div>
            </div>

            <div if="{ run.status }" class="logs">
                <h5>
                    Buildit Logs
                     <span class="tailbox">
                        <input type="checkbox" id="tail" value="{ view.tail }" onclick="{ setTail }" checked="{checked: tail, notChecked: !tail}"/>
                        <label for="tail">Tail Logs</label>
                    </span>
                </h5>
                <textarea name="builditlogs" class="log" value="{ run.convertedLogs }" readonly></textarea>
            </div>
        </div>

    </div>

    <script>
        var self = this,
            d = utils.debug,
            routed = false,
            setView = false;

        self.view = {tail : true, showPubKey: false, deploymentKeyText: "Show Deployment Key"};

        clearLogs() {
             self.run.convertedLogs = "";
             self.update();
        }

        setTail() {
            self.view.tail = !self.view.tail;
            self.view.edited = true;
        }

        runBuild() {
            RiotControl.trigger('build_run_plan', self.plan.name, self.branch.name);
        }

        alterPubKey() {
            self.view.showPubKey = !self.view.showPubKey;
            if (self.view.showPubKey) {
                self.view.deploymentKeyText = 'Hide Deployment Key';
            } else {
                self.view.deploymentKeyText = 'Show Deployment Key';
            }
            self.view.edited = true;
            self.update();
        }

        self.on('mount', function () {
            d('buildit_run::mount');
            autosize(self.builditlogs);
        });

        self.on('update', function() {

            if (!self.opts.run || !self.opts.plan) {
                return;
            }

            self.run = self.opts.run;
            self.plan = self.opts.plan;
            self.branch = self.opts.branch;
            self.plan.name = self.plan.name || self.plan.path;

            if (self.opts.view && !self.view || self.view && !self.view.edited && self.opts.view) {
                self.view = self.opts.view;
            }

            utils.tailTextarea(self.builditlogs, self.view.tail);
        });

    </script>
    <style scoped>
    .status {
        background-color: #DCDCDD;
        border: 1px solid #ADBCA5;
        border-radius: 4px;
        padding: 5px 10px;
    }
    .status strong {
        font-weight: normal;
        color: #858275;
    }
    .status p {
        color: #46494C;
        font-family: "Lucida Console", Monaco, monospace;
        font-size: 11px;
        margin: 0;
    }

     .log-screen {
        position: relative;
        background-color: #000;
        font-family: "Lucida Console", Monaco, monospace;
        border-radius: 4px;
        padding: 3px;
        min-height: 100px;
        max-height: 500px;
        overflow: auto;
    }

    .log-screen > p {
        color: white;
    }

    .pubkey {
        width: 500px;
        height: 150px;
        margin-top: 10px;
        margin-left: 25px;
        font-family: monospace;
    }

    H4.failure .log.stderror {
        color: red;
    }
    H4.success{
        color: green;
    }
    H4.running{
        color: black;
    }

    .nav {
        margin-left: 25px;
    }

    H3 {
        margin-bottom: 10px;
    }

    .tailbox {
        margin-left: 10px;
    }

    textarea {
        color: white;
        background-color: black;
        max-height: 1000px;
    }

    .success {
        background-color: transparent;
    }
    </style>
</buildit_run>
