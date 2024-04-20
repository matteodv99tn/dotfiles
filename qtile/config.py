# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

from qtile_extras import widget
from qtile_extras.widget.decorations import BorderDecoration

import subprocess
import random
import os
from libqtile import hook

from catppuccin import Flavour
my_flavour = Flavour.mocha()

N_MONITORS = int(subprocess.Popen(
        "xrandr --listmonitors | wc -l",
        stdout=subprocess.PIPE,
        shell=True
        ).communicate()[0]) - 1


@hook.subscribe.startup
def autostart():
    home = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.run([home], stdin=None, stdout=None, stderr=None, close_fds=True)
    lazy.spawn("thunderbird")


@hook.subscribe.client_new
def new_client_hooks(client):
    if client.name.lower() == "thunderbird":
        client.togroup(9)


mod = "mod4"
terminal = guess_terminal()

rofi_launcher = os.path.expanduser("~/.config/rofi/launchers/type-6/launcher.sh")
rofi_power = os.path.expanduser("~/.config/rofi/powermenu/type-3/powermenu.sh")

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod],              "h",        lazy.layout.left(),             desc="Move focus to left"),
    Key([mod],              "j",        lazy.layout.down(),             desc="Move focus down"),
    Key([mod],              "k",        lazy.layout.up(),               desc="Move focus up"),
    Key([mod],              "l",        lazy.layout.right(),            desc="Move focus to the right"),
    Key([mod],              "space",    lazy.layout.next(),             desc="Move window focus to other window"),
    Key([mod, "shift"],     "h",        lazy.layout.shuffle_left(),     desc="Move window to the left"),
    Key([mod, "shift"],     "l",        lazy.layout.shuffle_right(),    desc="Move window to the right"),
    Key([mod, "shift"],     "j",        lazy.layout.shuffle_down(),     desc="Move window down"),
    Key([mod, "shift"],     "k",        lazy.layout.shuffle_up(),       desc="Move window up"),
    Key([mod, "control"],   "h",        lazy.layout.grow_left(),        desc="Grow window to the left"),
    Key([mod, "control"],   "l",        lazy.layout.grow_right(),       desc="Grow window to the right"),
    Key([mod, "control"],   "j",        lazy.layout.grow_down(),        desc="Grow window down"),
    Key([mod, "control"],   "k",        lazy.layout.grow_up(),          desc="Grow window up"),
    Key([mod],              "n",        lazy.layout.normalize(),        desc="Reset all window sizes"),
    Key([mod],              "v",        lazy.window.toggle_floating(),  desc="Toggle floating of the window"),
    Key([mod],              "q",        lazy.to_screen(0),              desc="Move focus to monitor 1"),
    Key([mod],              "w",        lazy.to_screen(1),              desc="Move focus to monitor 1"),
    # Key(
    #     [mod, "shift"],
    #     "Return",
    #     lazy.layout.toggle_split(),
    #     desc="Toggle between split and unsplit sides of stack",
    # ),
    Key([mod, "shift"],     "Return",   lazy.spawn(terminal),           desc="Launch terminal"),
    Key([mod, "shift"],     "c",        lazy.window.kill(),             desc="Kill focused window"),
    Key([mod],              "p",        lazy.spawn(rofi_launcher),      desc="Launch rofi"),
    Key([mod],              "space",    lazy.next_layout(),             desc="Toggle between layouts"),
    Key([mod],              "f",        lazy.spawn("firefox"),          desc="Launch firefox"),
    # Key([mod],              "r",        lazy.spawn("dmenu_run"),        desc="Launch dmenu"),
    Key([mod, "shift"],     "r",        lazy.reload_config(),           desc="Reload the config"),
    # Key([mod, "shift"],     "q",        lazy.shutdown(),                desc="Shutdown Qtile"),
    Key([mod, "shift"],     "e",        lazy.shutdown(),                desc="Shutdown Qtile"),
    Key([mod, "shift"],     "q",        lazy.spawn(rofi_power),         desc="Shutdown Qtile"),
    Key([mod, "shift"],     "r",        lazy.spawncmd(),                desc="Spawn a command using a prompt widget"),
]

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod],          i.name,     lazy.group[i.name].toscreen(),  desc="Switch to group {}".format(i.name)),
        Key([mod, "shift"], i.name,     lazy.window.togroup(i.name),    desc="Move window to group {}".format(i.name)),
        ])

layout_defaults = {
        "border_focus": my_flavour.lavender.hex,
        "border_normal": my_flavour.base.hex,
        "border_width": 2,
        }


layouts = [
    layout.Columns(margin=8, **layout_defaults),
    # layout.MonadTall(margin=8, **layout_defaults),
    # layout.MonadTall(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=2, margin=8),
    layout.Max(margin=[100, 600, 100, 600]),
    layout.Max(margin=8),
    # layout.Zoomy(columnwidth=600, margin=[30, 40, 30, 40]),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
]


bg_color = my_flavour.base.hex
fg_color = my_flavour.text.hex

widget_defaults = dict(
    font="FiraCode Nerd Font Bold",
    fontsize=13,
    padding=3,
    foreground=fg_color,
    background=bg_color
)
extension_defaults = widget_defaults.copy()

mydecorator = lambda col: {"decorations": [BorderDecoration(colour=col, border_width=[0,0,2,0])]}
widgetstart = lambda text, col: widget.TextBox(text=text, foreground=col, **mydecorator(col))
separator = widget.Spacer(10)


def widget_lists(systray: bool=False):
    widgets_left = [
        widget.GroupBox(highlight_method="line",
                        highlight_color=my_flavour.surface1.hex,
                        rounded=True,
                        inactive=my_flavour.surface0.hex,
                        this_screen_border=my_flavour.lavender.hex,
                        this_current_screen_border=my_flavour.blue.hex,
                        other_current_screen_border=my_flavour.sapphire.hex),
        widgetstart("󰽙", my_flavour.mauve.hex),
        widget.CurrentLayout(**mydecorator(my_flavour.mauve.hex)),
        separator,
        widgetstart(" :", my_flavour.mauve.hex),
        widget.WindowName(),
        ]

    widgets_right = [
        widgetstart(" ", my_flavour.blue.hex),
        widget.CPU(format="{load_percent}%", **mydecorator(my_flavour.blue.hex)),
        # separator,
        # widgetstart("󰒋 ", my_flavour.blue.hex),
        # widget.Memory(format="{percent}%", **mydecorator(my_flavour.blue.hex)),
        # separator,
        widgetstart("", my_flavour.blue.hex),
        widget.Volume(**mydecorator(my_flavour.blue.hex)),
        separator,
        widgetstart("󱊢", my_flavour.blue.hex),
        widget.Battery(format="{percent:2.0%}", **mydecorator(my_flavour.blue.hex)),
        separator,
        widgetstart("󰃭 ", my_flavour.blue.hex),
        widget.Clock(format="%d-%m-%y", **mydecorator(my_flavour.blue.hex)),
        separator,
        widgetstart(" ", my_flavour.blue.hex),
        widget.Clock(**mydecorator(my_flavour.blue.hex)),
        separator
        ]
    widgets = widgets_left
    if systray:
        widgets.append(widget.Systray())
    widgets.extend(widgets_right)
    return widgets


BACKGROUND_DIR = os.path.expanduser("~/Pictures/Backgrounds")
wallpapers = random.sample(os.listdir(BACKGROUND_DIR), 2)

screens = [
    Screen(wallpaper=os.path.join(BACKGROUND_DIR, wallpapers[0]),
           wallpaper_mode="fill",
           top=bar.Bar(widget_lists(N_MONITORS == 1), 23)),
    Screen(wallpaper=os.path.join(BACKGROUND_DIR, wallpapers[1]),
           wallpaper_mode="fill",
           top=bar.Bar(widget_lists(True), 23)),
    ]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
