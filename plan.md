App in flutter with a fiuunction to create lists. The lists can be of anything and the user should be able to create many of these lists. 

the user should be able to name the lists.
In the list of lists the user should be able to see the list's name and how many items (unchecked/total)
there should be a button to delete a list
there should be a button to drag and reorder the list of lists
there should be a buttion to rename a list

Items in a list have the porperty of either being checked or unchecked.
a list should be visually split into 2, one part for unchecked items above a part for the checked items
unchecked items should be added to the bottom of the unchecked part, checked items should be added to the top of the checked part, there should be no other sorting
in a list the user should be able to add items. Items should be added as unchecked and be trimmed on both sides from whitespace
adding a item that already exists should show a small popup and uncheck the item, not create a new one. Items should be compared by their name in lower case  
there should be a button to delete an item
there should be reorder an item in a list

in the bottom right corner there should be a button to add a new list or item, depending on the view the user is in

the data should be saved inbetween app restarts

the workflow in build-apk is the main way of building and getting the app

write tests before the implementation, TDD
