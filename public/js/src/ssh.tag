<ssh>
    <h4>{ container } Docker Commands</h4>
    <code>
        # SSH<br/>
        <span each="{ replicas }"> ssh -t { host } -l { user } sudo docker exec -ti { container_id } /bin/bash<br/></span>
    </code>
    <code>
        # Logs<br/>
        <span each="{ replicas }"> ssh -t { host } -l { user } sudo docker logs -f { container_id }<br/></span>
    </code>
    <code>
        # Top<br/>
        <span each="{ replicas }"> ssh -t { host } -l { user } sudo docker top { container_id }<br/></span>
    </code>
    <code>
        # Stats<br/>
        <span each="{ replicas }"> ssh -t { host } -l { user } sudo docker stats { container_id }<br/></span>
    </code>
    <code>
        # Inspect<br/>
        <span each="{ replicas }"> ssh -t { host } -l { user } sudo docker inspect { container_id }<br/></span>
    </code>
    <code>
        # Real Time Events<br/>
        <span each="{ replicas }"> ssh -t { host } -l { user } sudo docker events --filter container={ container_id }<br/></span>
    </code>

    <script>
    var self = this,
        d = utils.debug,
        updated = false;

    self.on('update', function () {
        d('bridge/command/ssh::update');

        var i, j;

        self.helm = opts.helm;
        self.user = ArgoAuth.getUser();

        if (!self.helm || !self.helm.replicas) {
            return;
        }

        self.container = opts.container;
        self.replicas = [];

        for (i = 0; i < self.helm.replicas.length; i++) {
            for (j = 0; j < self.helm.replicas[i].containers.length; j++) {
                if (self.helm.replicas[i].containers[j].name === self.container) {
                    self.replicas.push({
                        host: self.helm.replicas[i].host,
                        container_id: self.helm.replicas[i].containers[j].id
                    });
                    break;
                }
            }
        }

        self.update();

    });
    </script>

    <style scoped>
    code {
        display: block;
        background-color: #f5f5f5;
        border: 1px solid #bdbdbd;
        padding: 5px 10px;
        border-radius: 4px;
        overflow-x: scroll;
        margin-bottom: 5px;
    }
    code span {
        white-space: nowrap;
    }
    </style>
</ssh>
