<home>
    <div class="center-align">
        <h1>Welcome to Harbor</h1>
    </div>

    <div class="divider"></div>

    <div class="row">
        <div class="col s6">
            <h4>Getting Started</h4>
            <p>If you are you are new to Harbor, start with our <a href="{ config.blog_url }articles/hello-world/">getting started</a>
                document over on the <a href="{ config.blog_url }">Harbor Blog</a>. The article will give you a
                complete overview of how to begin with local development, through creating your
                first Shipment in Harbor. Don't forget to subscribe to the <a href="{ config.blog_rss }">RSS feed</a> to get the
                latest updates to documentation, blog posts and help articles.</p>
            <h5>First Steps</h5>
            <ol>
                <li>Create a new Container using <a href="#buildit">BuildIt</a>.</li>
                <li>Create a new Shipment using the <a href="#shipyard/info">Shipyard</a>.</li>
                <li>Manage your Shipment (including cloning it to another environment) using the <a href="#bridge">Command Bridge</a>.</li>
            </ol>
        </div>
        <div class="col s6">
            <h4>Latest News</h4>
            <ul if={ blogPosts }>
                <li each={ blogPosts } class="blog-post">
                    <h6><a href="{ link }">{ title }</a></h6>
                    <p class="grey-text">{ pubDate }</p>
                </li>
                <li><a href="{ config.blog_url }">More on Harbor Blog&hellip;</a></li>
            </ul>
            <div if={ blogError }>
                <p>Unable to retrieve blog posts</p>
            </div>
        </div>
    </div>

    <div class="divider"></div>

    <div class="row">
        <div class="col s12">
            <h4>Additional Reading</h4>

            <h5><a href="http://12factor.net/" target="_blank">The Twelve-Factor App</a></h5>
            <p>The Twelve-Factor App is a essay on modern software practices. Very interesting
                read, a good bit of 12 Factor has influenced the design of Harbor.</p>

            <h5><a href="https://www.docker.com/" target="_blank">Docker</a></h5>
            <p>Docker is a container strategy that packages an application with all of its
                dependencies into an easily deployable unit. It is quickly becoming the defacto
                container strategy. Docker is the basis of the MSS Harbor/Barge/Shipment strategy.</p>
        </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.config = window.config;
    self.blogError;
    self.blogPosts;

    RiotControl.trigger('menu_register', 'Home', 'home');
    RiotControl.trigger('home_get_blog_rss');

    self.on('mount', function () {
        d('home::mount');
        self.update();
    });

    RiotControl.on('home_get_blog_rss_result', function(error, data) {
        d('home::home_get_blog_rss_result', error, data);
        if (error) {
            self.blogError = 'Could Not Retrieve Blog';
        }

        self.blogPosts = data;
        self.update();
    });


    </script>

    <style scoped>
        .info-box {
          border-right: 1px solid #e0e0e0;
        }

        .blog-post {
            font-size: smaller;
        }

        .blog-post a {
            font-size: larger;
        }
    </style>
</home>
