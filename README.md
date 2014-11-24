Christmas
=========

[MV]_Christmas, the perfect Filterscript for christmas and newyear for your SA:MP server

<h1>Settings</h1>
```PAWN
#define MAX_PLAYERS             60      //Define how much slots your server uses
#define using_streamer          false   //When true you tell the script you are using Incognito's streamer
#define SF						false   //When true it will add some default objects in San Fierro (using 568 objects ! (You can edit it ofc))
#define MAX_BATTERIES       	50      //Maximum firework batteries
#define MAX_XMASTREES			20 	    //recommended - If you have more you might need a object streamer
#define MAX_SNOW_OBJECTS   		5 	    //recommended - If you have more you might need a object streamer
#define SNOW_UPDATE_INTERVAL	750     //time in milliseconds, the interval between the snow
#define NEXT_YEAR          		"2015"  //Which year is it next year ?
```


<h1>Functions:</h1>

```PAWN
native CreateChristmasTree(type,Float:x, Float:y, Float:z);
native GiveChristmasHat(playerid,type);
native CreateChristmasLights(Float:x, Float:y, Float:z);
```

Types:
```
TREE_TYPE_BIG
TREE_TYPE_SMALL

HAT_TYPE_1
HAT_TYPE_2
```

Examples
```PAWN
CreateChristmasTree(TREE_TYPE_SMALL,-1549.0511,585.0486,7.1797);
CreateChristmasTree(TREE_TYPE_BIG,-1548.4778,646.2723,7.1875);

GiveChristmasHat(playerid,HAT_TYPE_1);
```

<h1>Commands</h1>
```
/christmas
```

<h1>Images</h1>
<img src="http://exp-gaming.net/images/mv_christmas.png" />
<img src="http://exp-gaming.net/images/mv_christmas2.png" />
<img src="http://exp-gaming.net/images/mv_christmas3.png" />
