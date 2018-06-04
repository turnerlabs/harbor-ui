<home>
    <div class="center-align">
        <h1>Welcome to Harbor</h1>
    </div>

    <div class="divider"></div>

    <div class="row">
        <div class="col s6">
            <h4>Sunsetting Harbor</h4>
            <p>
                As we announced on March 28th, we are sunsetting the Harbor platform in
                favor of teams having more control over their container orchestration. The
                Cloud Architecture team is developing a migration tool to ease a move to
                <a href="https://aws.amazon.com/fargate/" target="_blank">AWS Fargate</a>,
                which we believe is a great platform with even more features than Harbor,
                while offering all the benefits of Harbor. Please head over to our
                <a href="https://github.com/turnercode/fargate-migration" target="_blank">migration blog</a>
                to learn more about migrating off of Harbor.
            </p>
            <h5>Deprecated Services</h5>
            <dl>
                <dt>New build plans in BuildIt</dt>
                <dd>Instead, consider creating the plan in CircleCI.</dd>

                <dt>New Shipments in Harbor</dt>
                <dd>Instead, consider creating the service in Fargate.</dd>
            </dl>
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
        dt {
            font-weight: bold;
        }

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
