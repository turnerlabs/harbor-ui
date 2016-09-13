<sidenav>
    <div class="harbor-sidenav col s2half">
      <div class="center-align">
        <img src="{ config.main_logo }" width="135" height="135">
      </div>
      <div class="collection">
        <a each={ items } class="collection-item { active: path.indexOf(parent.parent.route) > -1 }" href={ path } onclick={ setActive }>{ name }</a>
      </div>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    self.config = window.config;
    self.items;

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
</sidenav>
