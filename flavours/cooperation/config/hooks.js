let ExtensionHooks = {};

// TODO: make this more configurable? ie. don't import disabled extensions

import { GeolocateHooks } from "../../../deps/bonfire_geolocate/assets/js/extension"
import { KanbanHooks } from "../../../deps/bonfire_ui_kanban/assets/js/extension"

Object.assign(ExtensionHooks, GeolocateHooks, KanbanHooks)

export { ExtensionHooks }