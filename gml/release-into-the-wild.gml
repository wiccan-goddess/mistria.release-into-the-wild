// credits to these lovely people in the unoficial discord:
// Thunderhorsekid: showing me where to look and giving me general tips
// Felix - (D3Ulo): for the UI reference guide
// Ennea Lyhsayin: literally awesome like wtf...
// crys (scopecreepingherself): RETURN IS WRONG
// but seriously thanks to everyone in the discord, you guys are amazing <3

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

// ConditionFactory vars?
// how'd I call em?
// function re_wild_is_creature() {
//     var bug = BugIsValid
//     var fish = FishIsValid
// };

// check for fishing rod or net
// function held_item() {
//     return self.inventory.slot(self.held_item_index).item;
// }

//grab values from Item/enum ToolTypes
// function re_wild_tool_check() {
//     if (ToolType == FishingRod || ToolType == Net) {
//         var tool_check = true
//     } else {
//         var tool_check = false
//     }
// }

function re_wild_tool__coord_check() {
    var item = ARI.held_item();
    
    if (item != undefined) {
        if (item.prototype.tool_type == ToolType.Net || item.prototype.tool_type == ToolType.FishingRod) {
            if (item.prototype.tool_type == ToolType.Net) {
                show_debug_message("NETNETNETNETNETNETNETNETNETNETNET");
                _sound = "net";
            }
            if (item.prototype.tool_type == ToolType.FishingRod) {
                show_debug_message("RODRODRODRODRODRODRODRODRODRODROD");
                _sound = "rod";
            }

            trace("-- trying coord teset")// obj.ari not ARI thx thunder

            _xx = obj_ari.x 
            _yy = obj_ari.y

            return true;
        }
    }
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

function re_wild_magic_trick(_xx, _yy) {
    drop_item_to_ground(_xx, _yy, 0);
    trace("shou;d've grebbaed succussfuly")
}

// function drop_item_to_ground(xx, yy, z_offset) {
//     var inst = instance_create_layer(xx, yy, "Instances", obj_item);
//     inst.move_draw_z = true;
//     inst.draw_z_offset = z_offset;
//     inst.ignore_collision = true;

//     return inst;
// }

//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------

// curtosy of Ennea
// checks if ari's inv in full
function re_wild_is_ari_inventory_full() {
    return !ARI.inventory.slots.any(function(a) {
        return a.count == 0;
    });
}

// function spawn_bug_object(xx, yy, bug, spawn_canopy=true) {
//     var inst = instance_create_depth(xx, yy, 0, obj_bug);
//     inst.setup(bug, spawn_canopy);
//     return instance_exists(inst) ? inst : undefined;
// }

//     TANGO.play("SoundEffects/Inventory/ItemDrop", xx, yy);
// }

// need to check if the inv has it already so it doesn't popup when it can be picked up

// pop up menu grabbed from UI Guide:
function re_wild_popup(_dropped, _xx, _yy, _sound) {  // gives LiveItem (blehbleh)
                                    // remove 'LiveItem (' + ')'
                                    // either that or see if spawn can push it

    var _popup = popup_creator(
        ANCHOR.wrap_for_local("Your inventory is full... "),
        ANCHOR.wrap_for_local("What'll you do with the little one?")
    );
    
    _popup.create_button(ANCHOR.wrap_for_local("Drop"), function() {
        show_debug_message("[ui_reference] Dropped");
        re_wild_magic_trick(_dropped, _xx, _yy);
    });

    _popup.create_button(ANCHOR.wrap_for_local("Release"), function() {
        show_debug_message("[ui_reference] Released");
        re_wild_sound_set();
    });

    _popup.spawn();
}

// delete_item_from_world fn? but it'd have to be that exact item and only the one that was just picked up
// scary sounding function ngl

// does drain do something similar? it sounds safer lol

//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------

// Hook callback.
function re_wild_hook() {
    var orig_give_item = ARI.give_item;
    
    

    var new_scope = {
        orig_give_item: orig_give_item
    };

    with new_scope {
        var new_give_item = function (_item, _count, _show_toast = true, _should_drop = true) {
            
            // before
            var holding_tool = re_wild_tool_check()

            trace("-- before give");

            if (holding_tool == true) {
                trace("TOOL");
                if (re_wild_is_ari_inventory_full()) {
                    if (_should_drop == true) {
                        _dropped = _item // hopefully this passes it over

                        trace(_dropped);
                        re_wild_popup(_dropped, _xx, _yy);
                        return; // is banned lmao, thanos snaps everything i try to pick up
                                // not what I was expecting...
                                // just wanted a pause!!!!
                    } 
                }
            };

            // game values
            orig_give_item(_item, _count, _show_toast, _should_drop);

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
re_wild_register_callbacks();