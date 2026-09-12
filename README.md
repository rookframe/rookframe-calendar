# Calendar

An ordinary optional Rookframe Package, developed throughout Project 02. This
slice opens an authored Gregorian date view and dated-note editor from the left
Rail. World date and note persistence are connected in the domain-data slice. The example uses
one Gregorian calendar; it requires no remote account.

Package ID: `aae579da-5392-4507-8eaa-0d918af58076`.
Package version: `0.3.0`. SDK Edition: `2027`, minimum revision `4`.

## Clean clone

Install Godot **4.7.2** with matching export templates, Git, Python **3.10+** and
the **.NET 8 runtime**. No Rookframe application checkout or private host
assemblies are required. The gd-plug bootstrap and its license are included.

```sh
git clone https://github.com/rookframe/rookframe-calendar.git
cd rookframe-calendar
/path/to/godot --headless --path . --script plug.gd install
python3 addons/rookframe_sdk/rookframe_authoring.py facade --project .
python3 addons/rookframe_sdk/rookframe_authoring.py check --project . --godot /path/to/godot
python3 addons/rookframe_sdk/rookframe_authoring.py build --project . --godot /path/to/godot
```

The two dependencies in `plug.gd` are SDK **v0.3.0** and UI Kit
**v1.0.0-rc.1** at exact commit
`238339d390ec01873585c002917c164948a0578d`. The independent authoring lock is
`.rookframe/authoring.lock.json`. Ordinary commands do not update either pin.
The generated facade is committed as Package-owned source; it is not a third
dependency or hand-written host adapter.

Open `project.godot` in Godot. The SDK plugin checks/generates the facade when
entering the editor, and Project → Tools offers Package Check and Build. Open
`rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/window.tscn` to edit or
run the normal authored scene. The UI uses the separately installed public Theme, TextField, TextArea and StructuredRow components. Rookframe owns the Rail slot and managed window chrome.

The initial export configuration contains only `desktop` for macOS. On Windows
or Linux select the native platform in the desktop export preset. Add other
Rookframe profile presets only when intended; keep textual scripts and exclude
authoring dependencies/registries. The build command exports every configured
profile, verifies prepared contents, and writes one complete `.rookpackage` to
`build/`. A new build receives a fresh UUID; reinstallation uses the existing
archive unchanged. No publication or account is needed to build locally.

In Rookframe, create a World with a controlled System Extension. Open World
Details → Packages → Install or Update Packages → Import Local Archive, choose
the build, then include Calendar. Open the World and click Calendar's document
icon in the left Rail. Its initial scene opens in the normal managed window,
with dock, float, minimize, restore and close behavior. The entire selection
passes ordinary production admission before execution.

See the [SDK authoring guide](https://github.com/rookframe/rookframe-sdk) and
[UI Kit component API](https://github.com/rookframe/rookframe-ui-kit/blob/238339d390ec01873585c002917c164948a0578d/docs/public-components.md).
The RFG-226 application changes are required for these Edition revision 4 APIs.

## How the integration is authored

`ui/desktop.gd`, `ui/tablet.gd` and `ui/phone.gd` extends the generated SDK Presentation base. Rookframe binds
its typed `sdk` automatically before `compose()`:

```gdscript
const CALENDAR_WINDOW_BUTTON: SDK.WindowButton = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/window_button.tres")

func compose() -> void:
    var rail: SDK.Rail = sdk.rails.left
    rail.push(CALENDAR_WINDOW_BUTTON)
```

Open `ui/window_button.tres` in Godot's Inspector. Its `button_scene` points to
`ui/calendar_button.tscn`; its typed `window` target points to `ui/window.tscn`.
Edit the button's appearance in its scene and the Calendar content in the window
scene. The SDK owns the standard opening action, native instantiation, mounting,
reopening and cleanup. There is no Package-written signal connection, host
adapter, string-based mount call or rejected-control disposal.

Paths in this section are beneath `rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/`.

## Date and note workflow

View ISO Gregorian dates from 0001-01-01 to 9999-12-31, including leap years.
Advance one day navigates the date view. Enter a note title/body; the dated draft
row follows the selected date. Set World Date and Save Note currently report that
authoritative changes are not connected. They never claim to save. RFG-227
connects these actions to Rookframe-owned data; no Package persistent date/notes
model exists here.

Desktop, tablet and phone Presentations register the same authored window scene,
so an unfinished note and navigation state survive switching, closing and
reopening. The host uses its current logical canvas and owns docking, floating,
minimizing, orientation and shutdown. Drafts end when leaving the World.
The date helper is temporary typed calculation state, not authoritative data.
German translations are declared as a normal Godot Translation and accessed
through `sdk.translations`; the standalone scene keeps English source labels.
