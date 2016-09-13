<menu>
  <div class="container"><a href="#" data-activates="nav-mobile" class="button-collapse top-nav waves-effect waves-light circle hide-on-large-only"><i class="mdi-navigation-menu"></i></a></div>
  <ul id="nav-mobile" class="side-nav fixed">
    <li class="logo"><a id="logo-container" href="/#home" class="brand-logo">
        <img src="{logo}" /></a>
        <h3>Harbor</h3>
    </li>
    <li each={ items } class="bold { active: path.indexOf(parent.parent.route) > -1 }">
        <a href="{ path }" class="waves-effect waves-teal" onclick={ setActive }>{ name }</a>
    </li>
    <button class="btn" onclick="{ parent.logout }">Logout</button>
  </ul>
    <script>
        var self = this,
            d = utils.debug;

        self.items;
        self.route = window.location.hash;
        self.logo = window.config.main_logo;

        setActive(evt) {
            var route = evt.target.getAttribute('href'),
                hash = window.location.hash;

            self.currentRoute = route;
            riot.route(route);
        }

        RiotControl.on('menu_list_changed', function(list) {
            d('menu::menu_list_changed', list);
            self.items = list;
        });
    </script>

    <style scoped>
        img {
            width: 75%;
        }

        button {
            position: absolute;
            bottom: 75px;
            width: 75%;
            margin-left: 30px;
        }

        #logo-container {
            margin-bottom: 75px;
        }

        ul.side-nav.fixed li.logo {
            margin-top: 10px;
            margin-bottom: 25px;
        }
    </style>
</menu>
