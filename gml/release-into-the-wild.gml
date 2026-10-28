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
// function re_wild_tool_coord_check() {
//     if (ToolType == FishingRod || ToolType == Net) {
//         var tool_check = true
//     } else {
//         var tool_check = false
//     }
// }

function re_wild_tool_coord_check(water) {
    var item = ARI.held_item();
    
    if (item != undefined) {
        if (item.prototype.tool_type == ToolType.Net || item.prototype.tool_type == ToolType.FishingRod) {
            if (item.prototype.tool_type == ToolType.Net) {
                show_debug_message("NETNETNETNETNETNETNETNETNETNETNET");
                _sound = "net";
            }
            if (item.prototype.tool_type == ToolType.FishingRod || water == true) {
                show_debug_message("RODRODRODRODRODRODRODRODRODRODROD");
                _sound = "rod";
            }

            trace("-- trying coord teset");// obj.ari not ARI thx thunder
            trace(obj_ari.x);
            trace(obj_ari.y);

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

function re_wild_magic_trick(_dropped) { // YESSSSSSSSSSS
    trace(_dropped)
    trace("pre-fire")
    drop_item(_dropped, obj_ari.x, obj_ari.y);
    trace("shou;d've grebbaed succussfuly")
}

// function drop_item(value, xx, yy, z_offset=0) {
//     var array = drop_item_input_cleanup(value);
//     if array == undefined {
//         return;
//     }

//     for (var i = 0; i < array_length(array); i++) {
//         var item = array[i];
//         item = is_struct(item) ? item : new LiveItem(item);
//         drop_item_default_setup(
//             instance_create_layer(xx, yy, "Instances", obj_item),
//             List(item),
//             drop_item_random_dir_distance(),
//             z_offset
//         );
//     }
//     TANGO.play("SoundEffects/Inventory/ItemDrop", xx, yy);
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

// look for rarity: junk and artifact_fishing
// and is_chest == true

// var testw = _item.prototype.tags // works and gives          List[bugs]
                                                             // List[fishable, fishy]
                                                             // List[fishable, fishy, legendary_fish]
                                                             // List[dive, river, fishy]
                                                             // List[dive, ocean, fishy, fishable]
                                                             // List[dive, pond, junk, fishable]
                                                             // List[dive, pond, fishy, fishable]
                                                             // List[dive, river, fishy, fishable]

                                                             // bugs for bugs
                                                             // fishy for all fish
                                                             // junk
                                                             // material
            // trace(testw)

// Umm, but essentially if you want to parse the list, the best way is to use var list_count = List.count(),
// and then a for loop where i  < list_count, to access each element in the list using List.get(i).

function re_wild_not_live(_item) {
    var taggy = _item.prototype.tags
    trace(taggy);

    var list_count = taggy.count() // <- i think this is what thunder meant? like the inv check?
    // var living = false

    // for (i < list_count) {
    //     List.get(i)
    // }

    // actual for loop
    for (var i = 0; i < list_count; i++) {
        var list = taggy.get(i)
        trace(list)

        if (list == "bugs" || list == "fishy") {
            return true;           
        } // else {
        //     var living = false <- reset living lol
        //     trace(living)
        // }
    }
    
    // if (taggy == asd) {
    //     return true;
    // } else {
    //     return false;
    // }
};

// check all trigger vars
function re_wild_trigger(_item) {
    var full = re_wild_is_ari_inventory_full();
    var water = GRID.node_terrain_kind[GRID.node_index_for_room_position(obj_ari.x, obj_ari.y)] == TerrainKind.Water; // thunder
    var holding_tool = re_wild_tool_coord_check(water);
    re_wild_ari_space_aval(_item);
    var living = re_wild_not_live(_item);

    trace("starting checks")

    trace(water);
    trace(full);
    trace(holding_tool);
    trace(_space);
    trace(living);

    trace("ending checks")

    trace(obj_ari.x);
    trace(obj_ari.y);
    trace(_sound);

    if (full == true) && (_space == false) && (living == true) {
        if (holding_tool == true) || (water == true) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
};

// pop up menu grabbed from UI Guide:
function re_wild_popup(_dropped, _sound) {  // gives LiveItem (blehbleh)
                                    // remove 'LiveItem (' + ')'
                                    // either that or see if spawn can push it

    var _popup = popup_creator(
        ANCHOR.wrap_for_local("Your inventory is full... "),
        ANCHOR.wrap_for_local("What'll you do with the little one?")
    );
    
    _popup.create_button(ANCHOR.wrap_for_local("Drop"), function() {
        show_debug_message("[ui_reference] Dropped");
        trace(_dropped);

        re_wild_magic_trick(_dropped);
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
            trace("-- before give");

            // trace(holding_tool)
            // trace("-- trying coord teset");// obj.ari not ARI thx thunder
            // trace(_xx);
            // trace(_yy);
            // var test = _item.prototype.rarity; //thunder as well <- crashes
            // var test = _item.fiddle_data // trying to get from item gml? <- crashes
            // var test = _item.prototype // gives all dis 
                                       // assets/gml/scripts/eepy_kitty_release_into_the_wild/release-into-the-wild.gml:275 -- 
                                       // { edible: false, value: { bin: 10, store: 20, renown: undefined }, tags: "List[bugs]", 
                                       // max_stamina_modifier: 0, soulbind: undefined, object: undefined, range: 1, catch_size: 0,
                                       // wallpaper: undefined, flooring: undefined, sow_sprite: undefined, new_inventory_size: undefined,
                                       // health_modifier: undefined, blueprint: undefined, door_mold: undefined,
                                       // default_infusion: undefined, song: undefined, item_id: 276, plant_grass: undefined,
                                       // crop_object: undefined, stamina_modifier: undefined, recipe: undefined,
                                       // crafting_preview_sprite: undefined, icon_sprite: -906243771343976512, sapling: undefined,
                                       // date_unlock: undefined, kitchen_tier_requirement: undefined, attract: undefined,
                                       // essence_charge: undefined, description_key: "items/other/bugs/beach_hopper/description",
                                       // recipe_key: "beach_hopper", size: undefined, cosmetic_to_unlock: undefined,
                                       // mana_modifier: undefined, stars: undefined, pet_treat: undefined, damage: 0,
                                       // tile_placement: undefined, bomb: undefined, use: undefined, crafting_level_requirement: undefined,
                                       // stamina_cost: -1, defense: 0, hold_over_head: true, giftable: true, max_stack: 999, mini_sprite: undefined,
                                       // set_unlock: undefined, pet_skin_unlock: undefined, max_health_modifier: 0,
                                       // name_key: "items/other/bugs/beach_hopper/name", tool_type: undefined,
                                       // icon_sprite_outline: -8585124786037942606, quality: 0, animal_feed: undefined,
                                       // purchased_once_per_year: false }

                                       // tags: fishy
                                       // tags: bugs
                                       // newts!
            // var testw = _item.prototype.tags // works and gives List[bugs]
            //                                                  // List[fishable, fishy]
            //                                                  // List[fishable, fishy, legendary_fish]
            //                                                  // List[dive, river, fishy]
            //                                                  // List[dive, ocean, fishy, fishable]
            //                                                  // List[dive, pond, junk, fishable]
            //                                                  // List[dive, pond, fishy, fishable]
            //                                                  // List[dive, river, fishy, fishable]
            //                                                  // List[dive, river, fishy]
            // trace(testw)

            re_wild_trigger(_item) // <- this checks all eventually

            if (re_wild_trigger(_item)) { //checks
                if (_should_drop == true) {
                    _dropped = _item // hopefully this passes it over

                    trace(_dropped);
                    re_wild_popup(_dropped);
                    return; // is banned lmao, thanos snaps everything i try to pick up
                            // not what I was expecting...
                            // just wanted a pause!!!!
                } 
            }

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