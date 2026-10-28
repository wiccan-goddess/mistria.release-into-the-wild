// credits to these lovely people in the unoficial discord:
// Thunderhorsekid: showing me where to look and giving me general tips
// Felix - (D3Ulo): for the UI reference guide
// Ennea Lyhsayin: literally awesome like wtf...
// crys (scopecreepingherself): RETURN IS WRONG
// but seriously thanks to everyone in the discord, you guys are amazing <3

// Runtime state initialization.
function __re_wild_runtime() {
    if (global[$ "__re_wild"] == undefined) {
        global.__re_wild = { registered_hooks: undefined };
    }
    return global.__re_wild;
}

// Hook callback registration.
function re_wild_register_callbacks() {
    var _rt = __re_wild_runtime();

    if (_rt.registered_hooks != undefined) {
        return;
    }

    _rt.registered_hooks = true;

    mmapi_on("save.game_loaded", re_wild_hook);
}

// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------

function re_wild_tool_coord_check(water) {
    var item = ARI.held_item();
    
    if (item != undefined && item.prototype.tool_type == ToolType.Net) {
        _sound = "net";
        return true;
    }

    if (item != undefined && (item.prototype.tool_type == ToolType.FishingRod || water == true)) {
        _sound = "rod";
        return true;
    }

    _sound = "none";
    return false;
}

function re_wild_sound_set() {
    if (_sound == "net") {
        TANGO.play("SoundEffects/Animals/BugSpawn", AUDIO_LISTENER_X , AUDIO_LISTENER_Y);
    }
    if (_sound == "rod") {
        TANGO.play("SoundEffects/Animals/SingleFishRun", AUDIO_LISTENER_X , AUDIO_LISTENER_Y);
    }
}

function re_wild_magic_trick(_dropped) { // YESSSSSSSSSSS
    trace(_dropped)
    trace("pre-fire")
    drop_item(_dropped, obj_ari.x, obj_ari.y);
    trace("shou;d've grebbaed succussfuly")
}

// curtosy of Ennea
// checks if ari's inv in full
function re_wild_is_ari_inventory_full() {
    return !ARI.inventory.slots.any(function(a) {
        return a.count == 0;
    });
}

// need to check if the inv has it already so it doesn't popup when it can be picked up
function re_wild_ari_space_aval(_item) {
    var can_fit = ARI.inventory.room_for_item(_item); //yeeted from ari

    trace(can_fit) //returned 997

    if (can_fit > 0){
        _space = true
    }else{
        _space = false
    }

    trace(_space)
}

// List[bugs]
// List[fishable, fishy]
// List[fishable, fishy, legendary_fish]
// List[dive, river, fishy]
// List[dive, ocean, fishy, fishable]
// List[dive, pond, junk, fishable]
// List[dive, pond, fishy, fishable]
// List[dive, river, fishy, fishable]

// bugs for bugs
// fishy for all fish

//wrapped everything in a check
function re_wild_not_live(_item) {
    if _item != undefined {
        var taggy = _item.prototype.tags

        if (taggy != undefined) {
            trace(taggy);

            var list_count = taggy.count() // thunder

            // actual for loop
            for (var i = 0; i < list_count; i++) {
                var list = taggy.get(i)
                trace(list)

                if (list == "bugs" || list == "fishy") {
                    return true;           
                } 
            }
        }
    }

    return false;
};

// okay so for the quest crash i'll try calling the living fn after base checks
// and for the item spawn error i'll do something with space fn

// looking back at enneas inv full fn on the discord they said to add undefined checks so i'll do that first because oops

// check all trigger vars
function re_wild_trigger(_item) {
    var full = re_wild_is_ari_inventory_full();
    var water = GRID.node_terrain_kind[GRID.node_index_for_room_position(obj_ari.x, obj_ari.y)] == TerrainKind.Water; // thunder
    var holding_tool = re_wild_tool_coord_check(water);
    re_wild_ari_space_aval(_item);
    var living = re_wild_not_live(_item);

    trace("starting checks")
    trace("---------------")

    trace(water);
    trace(full);
    trace(holding_tool);
    trace(_space);
    trace(living);

    trace("coords & _sound")

    trace(obj_ari.x);
    trace(obj_ari.y);
    trace(_sound);

    trace("---------------")
    trace("ending checks")

    if (full == true) && (_space == false) { // call living last prevents the crash
        if (holding_tool == true) || (water == true) {

            if (living == true) {
                return true;
            }
            
        } else {
            return false;
        }
    } else {
        return false;
    }
};

// pop up menu grabbed from UI Guide:
function re_wild_popup(_dropped, _sound) {  // gives LiveItem (blehbleh)

    var _popup = popup_creator(
        ANCHOR.wrap_for_local("Your inventory is full... "),
        ANCHOR.wrap_for_local("What'll you do with the little one?")
    );
    
    _popup.create_button(ANCHOR.wrap_for_local("Drop"), function() {
        re_wild_magic_trick(_dropped);
    });

    _popup.create_button(ANCHOR.wrap_for_local("Release"), function() {
        re_wild_sound_set();
    });

    _popup.spawn();
}

// Hook callback.
function re_wild_hook() {
    var orig_give_item = ARI.give_item;

    var new_scope = {
        orig_give_item: orig_give_item
    };

    with new_scope {
        var new_give_item = function (_item, _count, _show_toast = true, _should_drop = true) {
            
            // before
            if (re_wild_trigger(_item)) { //checks
                if (_should_drop == true) {
                    _dropped = _item // hopefully this passes it over

                    trace(_dropped);
                    re_wild_popup(_dropped);
                    return; // thanos snaps everything i try to pick up
                } 
            }

            // game values
            orig_give_item(_item, _count, _show_toast, _should_drop);

            // after
        };

        ARI.give_item = new_give_item;
    }


    mmapi_log_info("release_into_the_wild", "mod loaded yay?");
    mmapi_log_flush("release_into_the_wild"); // make this one-line proof visible immediately
}

// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------

// MMAPI mod declaration and hook registration.
mmapi_mod_declare("release_into_the_wild", "1.0.0");
re_wild_register_callbacks();