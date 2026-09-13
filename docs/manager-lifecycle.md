# Calendar release lifecycle

Calendar is an ordinary optional Package. Manager uses the same admission,
installed store, selection and recovery transactions for Calendar as for other
Packages. No Calendar-specific trust setting, loader or migration service exists.

For the current update journey, keep the published [0.9.0 archive](https://github.com/rookframe/rookframe-calendar/releases/download/v0.9.0/Calendar-0.9.0.rookpackage)
and [0.9.1 archive](https://github.com/rookframe/rookframe-calendar/releases/download/v0.9.1/Calendar-0.9.1.rookpackage).
Each is immutable: rebuilding creates a new identity and fingerprint even when
the displayed version is unchanged. Version 0.9.1 uses SDK 0.9.2 and the exact
UI Kit pin in `plug.gd`; 0.9.0 keeps its original dependencies.

1. From Main Menu → Installed Packages → Install Package, import the 0.9.0 archive. Choose the
   System against which an optional install should be checked. In a stopped
   World's Packages, open Calendar's detail page, choose Use in this World and open that World.
2. Open Calendar from the left Rail. Set the Gregorian date to 2024-02-28,
   advance one day, and save a note titled “Leap day” with body “The gate opens.”
   Leave the World normally.
3. Import 0.9.1, then World Details → Packages →
   Review installed updates. Review 0.9.0 → 0.9.1 and apply once. Reopen: the
   date is 2024-02-29 and the note remains. My Settings → Day month year displays
   “Thursday, 29 February 2024”; a saved World title also survives the update. Current target Settings follow the
   existing SDK Settings migration contract; Package World Data stays opaque.
4. Stop, explicitly disable Calendar, and reopen. No Calendar Presentation or
   Implementation runs. Stop and re-enable it: the same date and note return.
5. Stop, open Calendar → Repair this version → Import matching archive and supply the **same exact 0.9.1 archive**.
   An intact release reports Already installed; missing/damaged files are repaired
   into new immutable materialization. Reopen and verify the date and note.
   A rebuilt archive is replacement, not an exact repair. A changed/private/
   missing public source requires matching local import, never another source.
6. Stop and choose Calendar → Remove Package → Delete from World. Review the destructive consequence and
   confirm: Calendar's selection, World date/notes and World Settings are removed.
   Installed files and User Settings remain. Re-add and open: the starting date
   is unset until explicitly set again.
7. Delete Calendar from that World again. Installed Packages → Calendar → Remove Package → Uninstall version now
   succeeds only if no local World selects that exact version, including disabled
   selections. It removes that version's User Settings/protected destinations;
   in-use backing remains immutable until every using instance exits.

Canceling an update proposal changes nothing. Installation-wide replacement
names affected Worlds and requires its own concrete acceptance. After an accepted
selection change, startup failure keeps the new selection current. Optional
failure can be recovered by disabling Calendar from stopped Manager without
running its code. A crash or hang requires manual close/relaunch into Manager;
it must never automatically retry Package activation.

## Recorded RFG-230 result

On 2026-09-13, ordinary SDK 0.8.0 builds of Calendar 0.8.0 and 0.8.1 passed
the Rookframe native Manager/World acceptance run on Godot Mono 4.7.2 desktop.
The run set 2024-02-28, advanced to Gregorian leap day 2024-02-29, and saved
“Leap day” / “The gate opens.” It verified the visible date and note after
update/reopen, disable/re-enable and exact repair of damaged installed bytes.
Package Deletion removed the World data and settings; selecting Calendar again
showed “World date not set”. Uninstall succeeded after removing the selection.


That historical acceptance is an observation, not a maintained extra E2E suite.
RFG-232 uses the existing Manager/store/preparation and bounded Godot seams for
the 0.9.0 → 0.9.1 journey. Its source, artifact fingerprints, actual outcomes and
platform limits are recorded in the application repository's `evidence/rfg-232/`.
The four retained platform journeys and device-free Fast Gate stay unchanged.
