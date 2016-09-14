<bridge_container_version>
    <div class="row valign-wrapper">
        <p class="col s4 valign"><a href="{ config.catalogit_url }container/{ container.name }">{ container.name }</a></p>
        <p class="col s4 valign"><a href="{ config.catalogit_url }container/{ container.name }/{ container.version }">{ container.version }</a></p>
        <p class="col s4 valign">
            <select id="versionSelect-{ idx }" class="bridge-version-select harbor-select" style="width: 100%" onchange="{ saveVersion }">
                <option
                    each="{ contain in versionCompare(versions) }"
                    selected="{ parent.container.version == contain.version }"
                    value="{ JSON.stringify(contain) }">{ contain.version }
                </option>
            </select>
        </p>
    </div>

    <script>
    var self = this,
        d = utils.debug,
        lastContainer,
        localVersion,
        portCount = 0,
        requesting = false;

    versionCompare = function(array) {
        return array.sort(utils.versionCompare)
    }

    saveVersion(evt) {
        d('shipyard/containers::saveVersion', self.idx);

        var container = JSON.parse($('#versionSelect-' + self.idx).val());

        self.container.version = container.version;
        if (!self.container.ports || !self.container.ports.length) {
            self.addPort(true);
        }
        self.container.image = container.image.replace('http://', '').replace('https://', '');
        RiotControl.trigger('set_container', self.container);
        self.parent.update();
    }

    function setVersion(results) {
        d('shipyard/containers::get_container_versions_result', results);
        self.versions = results;
        self.update();
        setTimeout(function() { $('.bridge-version-select').select2()}, 1000);
    }

    self.on('update', function () {
        var version,
            update;
            
        self.idx = self.opts.idx;
        self.container = self.opts.container;

        if (self.container && self.container.ports) {
            portCount = self.container.ports.length;
        } else {
            portCount = 0;
        }

        if (self.container && !self.container.version) {
            version = self.container.image.split(':')[1];
            if (version) {
                self.container.version = version;
            }
        }

        if (portCount === 0 && self.container.ports && self.container.version) {
            self.addPort(true);
        }

        if (self.container.name && self.container.name !== lastContainer) {
            requesting = true;
            lastContainer = self.container.name;
            RiotControl.trigger('get_container_versions', self.container.name, setVersion);
        }
        
        if (!self.container || localVersion !== self.container.version) {
            update = true;  
        }
        
        localVersion = self.container.version;
        if (update) {
            setTimeout(function() { $('.bridge-version-select').select2()});
        }
    });
    </script>
</bridge_container_version>
