import { App, Widget } from "../../imports.js";
import Battery from "./modules/battery.js";
import Bluetooth from "./modules/bluetooth.js";
import Date from "./modules/date.js";
import Music from "./modules/music.js";
import Net from "./modules/net.js";
import SystemInfo from "./modules/system_info.js";
import Tray from "./tray.js";
import Workspaces from "./modules/workspaces.js";

const Start = Widget.Box({
  children: [
    Workspaces,
    // Indicators
  ],
});

const Center = Widget.Box({
  children: [
    Music,
  ],
});

const End = Widget.Box({
  hexpand: true,
  hpack: "end",

  children: [
    Tray,
    SystemInfo,
    Widget.EventBox({
      className: "system-menu-toggler",
      onPrimaryClick: () => App.toggleWindow("system-menu"),
      child: Widget.Box({
        children: [
          Net,
          Bluetooth,
          Battery,
        ],
      }),
      connections: [[
        App,
        (self, window, visible) =>
          self.toggleClassName("active", window === "system-menu" && visible),
      ]],
    }),
    Date,
  ],
});

export default Widget.Window({
  monitor: 0,
  name: `bar`,
  anchor: ["top", "left", "right"],
  exclusivity: "exclusive",

  child: Widget.CenterBox({
    className: "bar",

    startWidget: Start,
    centerWidget: Center,
    endWidget: End,
  }),
});