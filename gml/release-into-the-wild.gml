// credits to these lovely people in the unoficial discord:
// Thunderhorsekid: showing me where to look and giving me general tips
// Felix - (D3Ulo): for the UI reference guide

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

// TODO #1
// menu setup
// scope ari or inventory so .self works if neeeded
// figure out checks
// figure out what hooks are needed [maybe? menu], if any
// animations?? nothing major just like a sparkling effect or something?

// pop up menu grabbed from UI Guide:
function release_popup() {
    var _popup = popup_creator(
        ANCHOR.wrap_for_local("Your inventory is full... "),
        ANCHOR.wrap_for_local("What'll you do with the little one?")
    );
    
    _popup.create_button(ANCHOR.wrap_for_local("Drop them :("), function() {
        show_debug_message("[ui_reference] YOU ARE EVIL");
    });

    _popup.create_button(ANCHOR.wrap_for_local("Release them :)"), function() {
        show_debug_message("[ui_reference] They went home!!!");
        // despawn item
    });

    _popup.spawn();
}

// // checks

//     // Scripts/GameplaySystems/Player/Ari
//     function give_item
//         if should_drop

//     // Scripts/GameplaySystems/Data/Conditions/Conditions
//     function ConditionFactory
//         static FishIsValid
//         static BugIsValid


function release_wild() {
    var orig_give_item = give_item;

    var new_scope = {
        orig_give_item: orig_give_item
    };

    with new_scope {
        var new_give_item = function(){

            var if_should_drop = should_drop;
            var is_critter = false;

            if (fish == true || bug == true){
                is_critter = true;
            }else{
                is_critter = false;
            };
            
            if (if_should_drop > 0){
                if (instance_exists == false && is_creature == true){
                    release_popup();
                };
            };
            
            orig_give_item();
        };
    };
};

// -----------------------------------------------------------
// from toolbar-wrap
// -----------------------------------------------------------

// Runtime state initialization.
function __toolbar_wrap_runtime() {
    if (global[$ "__toolbar_wrap"] == undefined) {
        global.__toolbar_wrap = { registered_hooks: undefined };
    }
    return global.__toolbar_wrap;
}

// Hook callback registration.
function toolbar_wrap_register_callbacks() {
    var _rt = __toolbar_wrap_runtime();

    if (_rt.registered_hooks != undefined) {
        return;
    }

    _rt.registered_hooks = true;

    mmapi_on("ui.menu_opened", toolbar_wrap_menu_opened); // EVENT hook registration
}

// Hook callback.
function toolbar_wrap_menu_opened(_ctx) {     
    // from sopholopho code example should just check for the toolbar
    var _menu = _ctx.menu;

    if (_menu == undefined || _menu[$"type"] != Menu.Toolbar) {
        return;
    }

    var orig_on_think = _menu.on_think;

    var new_scope = {
        menu: _menu,
        orig_on_think: orig_on_think
    };

    with new_scope {
        var new_on_think = function () {

            // current values
            var old_page = menu.page;
            var old_slot = ARI.held_item_index mod 10;

            // game values
            orig_on_think();

            // updated values
            var new_page = menu.page;
            var new_slot = ARI.held_item_index mod 10;

            if (new_page != old_page){
                if (new_slot == 0 && old_slot == 9){
                    ARI.set_held_item_index(old_page * 10);
                    menu.page = old_page;
                    menu.update();
                }
                else if (new_slot == 9 && old_slot == 0){
                    ARI.set_held_item_index((old_page * 10) + 9);
                    menu.page = old_page;
                    menu.update();
                }
            }

        };

        menu.on_think = new_on_think;
    }


    mmapi_log_info("toolbar_wrap", "mod loaded yay?");
    mmapi_log_flush("toolbar_wrap"); // make this one-line proof visible immediately
}

// MMAPI mod declaration and hook registration.
mmapi_mod_declare("toolbar_wrap", "1.0.0");
toolbar_wrap_register_callbacks();