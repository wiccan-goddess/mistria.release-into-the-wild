// credits to these lovely people in the unoficial discord:
// Thunderhorsekid: showing me where to look and giving me general tips
// Felix - (D3Ulo): for the UI reference guide

// https://mikesbookshelf.com/gml/scripts/GameplaySystems/Inventory/Inventory.html
// https://mikesbookshelf.com/gml/scripts/GameplaySystems/Player/Ari.html#L466

// give_item() function in Ari.gml
// var can_fit = self.inventory.room_for_item(item); Ari.inventory.room_for_item(item)

// this might not need to be a hook thing... not sure tho

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

// to-do
// menu setup
// scope ari or inventory so .self works
// figure out checks
// figure out what hooks are needed [maybe menu?], if any

// pop up menu:
function uiref_message_popup() {
    var _popup = popup_creator(
        ANCHOR.wrap_for_local("Your inventory is full... "),
        ANCHOR.wrap_for_local("What'll you do with the little one?")
    );
    
    _popup.create_button(ANCHOR.wrap_for_local("Drop them :("), function() {
        show_debug_message("[ui_reference] YOU ARE EVIL");
    });

    _popup.create_button(ANCHOR.wrap_for_local("Release them :)"), function() {
        show_debug_message("[ui_reference] They went home!!!");
    });
    
    _popup.spawn();
}