## Ethereal
Ethereal is a 128x128px (16x16 tiles) tilemap editor I made to use in my game, Eternity.<br/>
It uses [LÖVE](https://github.com/love2d/love) as framework and [leaf](https://github.com/mateusmds/leaf) as code core.<br/>

## Controls
You have two layers to work. You can select which you want to use by pressing 1 or 2. If you press 3 you get the full tilemap, and the editing mode will be disabled.<br/>

### Navegation and usage
You can use WASD to move your selection cursor in the tilemap, and the arrow keys to select your tile (from your tilemap source in `resources/tilemap.png`).<br/>
By pressing E you'll add your elected tile at your cursor position, and pressing Q will remove (actually you will be putting the last tile at it, so please keep it empty). Pressing ctrl+q you'll clear the entire layer, so be careful.<br/>
You can save your tilemap down to a file (`map.txt`) pressing ctrl+s.
