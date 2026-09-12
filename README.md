# Calendar

An ordinary optional Rookframe Package, developed throughout Project 02. This
first slice opens an authored Calendar scene from a button in the left Rail.
World date changes and dated notes are added in later slices. The example uses
one Gregorian calendar; it requires no remote account.

Package ID: `aae579da-5392-4507-8eaa-0d918af58076`.
Initial Package version: `0.1.0`. SDK Edition: `2027`, minimum revision `1`.

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

The two dependencies in `plug.gd` are SDK **v0.1.0** and UI Kit
**v1.0.0-rc.1** at exact commit
`238339d390ec01873585c002917c164948a0578d`. The independent authoring lock is
`.rookframe/authoring.lock.json`. Ordinary commands do not update either pin.
The generated facade is committed as Package-owned source; it is not a third
dependency or hand-written host adapter.

Open `project.godot` in Godot. The SDK plugin checks/generates the facade when
entering the editor, and Project → Tools offers Package Check and Build. Open
`rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/window.tscn` to edit or
run the normal authored scene. The UI uses the separately installed public Theme
and Section component. Rookframe owns the Rail slot and managed window chrome.

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
The RFG-225 application changes are required for the initial Rail-to-window path.
