// credits to these lovely people in the unoficial discord:
// Thunderhorsekid: showing me where to look and giving me general tips
// Felix - (D3Ulo): for the UI reference guide
// Ennea Lyhsayin: literally awesome

// tips/links from thunder
// https://mikesbookshelf.com/gml/scripts/GameplaySystems/Inventory/Inventory.html
// https://mikesbookshelf.com/gml/scripts/GameplaySystems/Player/Ari.html#L466
// give_item() function in Ari.gml
// var can_fit = self.inventory.room_for_item(item); Ari.inventory.room_for_item(item)

// quick notes:
// room for item is no then that'd be a drop
// find a way to register the net and fishing rod only for being held so if it drops when holding them it'll most likely be a fish or insect
// create a two option menu [release/drop]
// drop would be default vanilla
// release would despawn said dropped item

// flow roughly:
// the first two checks might be interchangalbe

// check if inventory is full everytime it changes
//     if yes then check for fishing rod or net
//         if rod or net
//             open menu
//                 if option to release
//                     despawn what should be dropped
//                     notify that the creature went home
//                 if option to drop do nothing
//         if no then do nothing
//     if no then do nothing

// to-do #1
// scope ari or inventory so .self works if neeeded
// figure out checks
// figure out what hooks are needed [maybe? menu], if any <- SAVE GAME LOADED IS DEF NEEDED LMAO
// animations?? nothing major just like a sparkling effect or something?
// show a toast notif?

// yes it's the toolbar code
// it works tho

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

    if (_rt.registered_hooks != undefined) {
        return;
    }

    _rt.registered_hooks = true;

    mmapi_on("save.game_loaded", release_into_the_wild_hook);
}

//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------

// curtosy of Ennea
// checks if ari's inv in full
function release_into_the_wild_is_ari_inventory_full() {
    return !ARI.inventory.slots.any(function(a) {
        return a.count == 0;
    });
}

// pop up menu grabbed from UI Guide:
function release_into_the_wild_popup() {
    var _popup = popup_creator(
        ANCHOR.wrap_for_local("Your inventory is full... "),
        ANCHOR.wrap_for_local("What'll you do with the little one?")
    );
    
    _popup.create_button(ANCHOR.wrap_for_local("Drop"), function() {
        show_debug_message("[ui_reference] Dropped");
    });

    _popup.create_button(ANCHOR.wrap_for_local("Release"), function() {
        show_debug_message("[ui_reference] Released");
        // despawn/delete item
    });

    _popup.spawn();
}

//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------

// Hook callback.
function release_into_the_wild_hook() {     

    var orig_give_item = ARI.give_item;

    var new_scoe = {
        orig_give_item: orig_give_item
    };

    with new_scope {
<<<<<<< HEAD
        var new_give_item = function (_item, _should_drop = true) {
=======
        var new_give_item = function (_item, _count, _show_toast = true, _should_drop = true) {
>>>>>>> a2754a37e0f1ac04d91a9951e909d6319c7cac38
            
            // before
            trace("-- before give ", _item);
            
            if (release_into_the_wild_is_ari_inventory_full()) {
                if _should_drop == true {
                    release_into_the_wild_popup()
                } 
            }

            // game values
<<<<<<< HEAD
            orig_give_item(_item, _should_drop);
=======
            orig_give_item(_item, _count, _show_toast, _should_drop);
>>>>>>> a2754a37e0f1ac04d91a9951e909d6319c7cac38

            // after
            trace("-- after give");
        };

        ARI.give_item = new_give_item;
    }


    mmapi_log_info("release_into_the_wild", "mod loaded yay?");
    mmapi_log_flush("release_into_the_wild"); // make this one-line proof visible immediately
}

//-------------------------------------------------------------------------------------------------------------
// MMAPI mod declaration and hook registration.
mmapi_mod_declare("release_into_the_wild", "1.0.0");
release_into_the_wild_register_callbacks();