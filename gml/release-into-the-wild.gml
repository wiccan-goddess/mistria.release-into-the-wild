// Runtime state initialization.
function __release_into_the_wild_runtime() {
    if (global[$ "__release_into_the_wild"] == undefined) {
        global.__release_into_the_wild = { registered_hooks: undefined };
    }
    return global.__release_into_the_wild;
}

// Hook callback registration.
function release_into_the_wild_register_callbacks() {
    var _rt = __release_into_the_wild_runtime();
    if (_rt.registered_hooks != undefined) return;
    _rt.registered_hooks = true;

    mmapi_on("game.new_day", release_into_the_wild_new_day); // EVENT hook registration
}

// Hook callback.
// game.new_day is an EVENT: the return value is ignored.
function release_into_the_wild_new_day(_ctx) {
    // _ctx contains { total_days }.
    // create_notification takes a LOCALIZATION KEY, not raw text (the engine
    // runs it through local_get). Wrapping with ANCHOR.wrap_for_local lets raw
    // text through - fine for a first mod. Shipped mods register real keys
    // instead (translatable, filter-aware): see SNIPPETS.md "Show a
    // Notification" and Mod Anatomy's "User-Facing Text".
    create_notification(ANCHOR.wrap_for_local("Day " + string(_ctx.total_days) + " begins."));
    mmapi_log_info("release_into_the_wild", "new day: " + string(_ctx.total_days));
    mmapi_log_flush("release_into_the_wild"); // make this one-line proof visible immediately
}

// MMAPI mod declaration and hook registration.
mmapi_mod_declare("release_into_the_wild", "1.0.0");
release_into_the_wild_register_callbacks();