/*
  ___ __  ____      _____      _____ _          _     _
 |  _|  \/  \ \    / /_  |    / ____| |        (_)   | |
 | | | \  / |\ \  / /  | |   | |    | |__  _ __ _ ___| |_ _ __ ___   __ _ ___
 | | | |\/| | \ \/ /   | |   | |    | '_ \| '__| / __| __| '_ ` _ \ / _` / __|
 | | | |  | |  \  /    | |   | |____| | | | |  | \__ \ |_| | | | | | (_| \__ \
 | |_|_|  |_|   \/    _| |    \_____|_| |_|_|  |_|___/\__|_| |_| |_|\__,_|___/
 |___|               |___|______
                         |______|

Free to use on the following conditions:

	*Do not re-release edited versions without my permision
	*Do not and NEVER clame this as your own, not even an edit!
	*Say thanks on the sa-mp forums if you like ;)

	*Thanks to Zh3r0 for the moving snowman textdraw
	*Thanks to Meta for the countdown snippet
	*Thanks to ShOoBy for the snowball minigame
----------------UPDATES:--------------------------------------------------------
- Rescripted and optimized some functions/variables, just whole the script.
- Redesigned newyearcountdowntextdraw
- I don't know which version this is.
*/

#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <xFireworks>

#define pLoop()             	for(new i = 0, j = GetMaxPlayers(); i < j; i++) if(IsPlayerConnected(i))
#define Loop(%0,%1) 			for(new %0 = 0; %0 < %1; %0++)
#define LoopEx(%0,%1,%2) 		for(new %0 = %1; %0 < %2; %0++)
#undef  MAX_PLAYERS

#define MAX_PLAYERS             60      //Define how much slots your server uses
#define using_streamer          false   //When true you tell the script you are using Incognito's streamer
#define SF 			false   //When true it will add some default objects in San Fierro (using 568 objects ! (You can edit it ofc))
#define MAX_BATTERIES           50      //Maximum firework batteries
#define MAX_XMASTREES 		20 	//recommended - If you have more you might need a object streamer
#define MAX_SNOW_OBJECTS    	5 	//recommended - If you have more you might need a object streamer
#define SNOW_UPDATE_INTERVAL	750     //time in milliseconds, the interval between the snow
#define NEXT_YEAR               "2015"  //Which year is it next year ?

#if using_streamer
	#include <streamer>
	#define CreateObject CreateDynamicObject
#endif
//---------------------------------- COLORS ------------------------------------
#define COLOR_INVISIBLE 	0xFFFFFF00
#define COLOR_WHITE 		0xFFFFFFFF
#define COLOR_BLACK 		0x000000FF
#define COLOR_BLUE 		0x0000DDFF
#define COLOR_RED 		0xAA3333AA
#define COLOR_GREEN 		0x00FF00FF
#define COLOR_PURPLE 		0xC2A2DAAA
#define COLOR_YELLOW 		0xFFFF00AA
#define COLOR_YELLOWORANGE	0xE8D600FF
#define COLOR_GREY 		0xAFAFAFAA
#define COLOR_ORANGE 		0xFF5F11FF
#define ORANGE 			0xF4B906FF
#define COLOR_BROWN 		0x804000FF
#define COLOR_CYAN 		0x00FFFFFF
#define COLOR_LIGHTBLUE 	0x33CCFFAA
#define COLOR_PINK 		0xFF80C0FF

#define COL_ORANGE         			"{FFAF00}"
#define COL_GREEN          			"{6EF83C}"
#define COL_RED            			"{FF4040}"
#define COL_BLUE           			"{0285FF}"
#define COL_YELLOW         			"{FFEA02}"
#define COL_EASY           			"{FFF1AF}"

#define DIALOG_CHRISTMASMUSIC 		1113
#define DIALOG_CHRISTMASMUSICALL    	1114
#define DIALOG_CHRISTMAS        	1112
#define DIALOG_CHRISTMASFW      	1110

#define TREE_TYPE_BIG               0
#define TREE_TYPE_SMALL             1

#define HAT_TYPE_1                  0
#define HAT_TYPE_2                  1

#define KEY_AIM (128)

new Snow_F[MAX_PLAYERS], Obj[MAX_PLAYERS], Shoot[MAX_PLAYERS], Killer[MAX_PLAYERS], Charged[MAX_PLAYERS];
new explosions[] = {0,2,4,5,6,7,8,9,10,13};

enum e_Battery {
    inuse,
    timer,
    count,
    Float:height,
    hvar,
    Float:windspeed,
    Float:interval,
    Float:pos[3],
    machine
};

new batteries[MAX_BATTERIES][e_Battery];
new Text:NYCounter[3];
forward  Animate();

new
	Text:SM_Textdraw[20],
    	Float:TheX = 508.000000,
	Float:BoxY = 0.499999,
	gDirection,
	gCount,
	bool:pLogo[ MAX_PLAYERS ]
;

new bool:snowOn[MAX_PLAYERS char],
        snowObject[MAX_PLAYERS][MAX_SNOW_OBJECTS],
        updateTimer[MAX_PLAYERS char]
;

enum XmasTrees
{
	XmasTreeX,
    Float:XmasX,
    Float:XmasY,
    Float:XmasZ,
    XmasObject[10],
};

new Treepos[MAX_XMASTREES][XmasTrees];
new s_Timer[2];

public OnFilterScriptInit()
{
	print("[MV]_Christmas Version 1.3 loaded");

	LoadMetasTextdraws();
	LoadTextdraws();
	
 	s_Timer[1] = SetTimer("Animate",300,true);
 	Loop(i,sizeof(batteries)) batteries[i][inuse] = false;

	//------------------snowball minigame----
	CreateObject(8172,-716.59997559,3800.50000000,8.50000000,0.00000000,0.00000000,90.00000000); //object(vgssairportland07) (1)
	CreateObject(3074,-782.29998779,3785.30004883,8.50000000,0.00000000,270.00000000,269.99948120); //object(d9_runway) (6)
	CreateObject(3074,-782.29998779,3798.89990234,8.50000000,0.00000000,270.00000000,269.99450684); //object(d9_runway) (7)
	CreateObject(3074,-782.29998779,3807.60009766,8.50000000,0.00000000,270.00000000,269.99450684); //object(d9_runway) (8)
	CreateObject(3074,-752.09997559,3807.60009766,8.50000000,0.00000000,270.00000000,269.99450684); //object(d9_runway) (9)
	CreateObject(3074,-722.00000000,3807.50000000,8.50000000,0.00000000,270.00000000,269.99450684); //object(d9_runway) (10)
	CreateObject(3074,-691.79998779,3807.50000000,8.50000000,0.00000000,270.00000000,269.99450684); //object(d9_runway) (11)
	CreateObject(3074,-661.59997559,3807.50000000,8.50000000,0.00000000,270.00000000,269.99450684); //object(d9_runway) (12)
	CreateObject(3074,-753.79998779,3795.19995117,8.60000038,0.00000000,270.00000000,269.99450684); //object(d9_runway) (14)
	CreateObject(3074,-723.59997559,3795.10009766,8.60000038,0.00000000,270.00000000,269.99450684); //object(d9_runway) (15)
	CreateObject(3074,-693.40002441,3794.89990234,8.60000038,0.00000000,270.00000000,269.99450684); //object(d9_runway) (16)
	CreateObject(3074,-664.09997559,3794.69995117,8.60000038,0.00000000,270.00000000,269.99450684); //object(d9_runway) (17)
	CreateObject(3074,-664.29998779,3781.69995117,8.69999981,0.00000000,270.00000000,269.99450684); //object(d9_runway) (18)
	CreateObject(3074,-694.50000000,3781.80004883,8.69999981,0.00000000,270.00000000,269.99450684); //object(d9_runway) (19)
	CreateObject(3074,-724.40002441,3781.89990234,8.69999981,0.00000000,270.00000000,269.99450684); //object(d9_runway) (20)
	CreateObject(3074,-754.40002441,3782.00000000,8.69999981,0.00000000,270.00000000,269.99450684); //object(d9_runway) (21)
	CreateObject(8172,-796.79998779,3800.50000000,-48.00000000,90.00000000,0.00000000,90.00000000); //object(vgssairportland07) (2)
	CreateObject(8172,-650.20001221,3800.50000000,-48.00000000,90.00000000,180.00000000,90.00000000); //object(vgssairportland07) (3)
	CreateObject(8172,-729.09997559,3780.69995117,12.80000019,0.00000000,270.00000000,270.00000000); //object(vgssairportland07) (4)
	CreateObject(8172,-726.20001221,3820.19995117,12.80000019,0.00000000,270.00000000,90.00000000); //object(vgssairportland07) (5)


	//------------SF christmas trees---------
	#if SF == true
	CreateChristmasTree(TREE_TYPE_SMALL,-1549.0511,585.0486,7.1797);
	CreateChristmasTree(TREE_TYPE_BIG,-1548.4778,646.2723,7.1875);
	CreateChristmasTree(TREE_TYPE_SMALL,-1568.5579,828.9424,7.1875);
	CreateChristmasTree(TREE_TYPE_BIG,-1991.4308,89.8115,27.6799);
	CreateChristmasTree(TREE_TYPE_SMALL,-1992.0767,205.6595,27.6875);
	CreateChristmasTree(TREE_TYPE_BIG,-2633.8052,607.2700,14.4531);
	CreateChristmasTree(TREE_TYPE_SMALL,-2675.2756,607.2688,14.4545);
	CreateChristmasTree(TREE_TYPE_BIG,-2600.0955,1384.2037,7.1607);
	CreateChristmasTree(TREE_TYPE_SMALL,-2608.5371,1348.2877,7.1953);
	
	//SF big christmas tree with objects around
	CreateObject(664,-2707.30761719,376.57815552,3.96888542,0.00000000,0.00000000,44.00000000);
	CreateObject(664,-2706.46826172,375.02407837,3.96923542,0.00000000,0.00000000,349.99475098);
	CreateObject(664,-2707.12426758,379.04116821,3.96928978,0.00000000,0.00000000,97.99145508);
	CreateObject(2486,-2708.43017578,373.17453003,4.97945309,0.00000000,0.00000000,354.00000000);
	CreateObject(2485,-2709.13354492,374.46206665,4.97945309,0.00000000,0.00000000,0.00000000);
	CreateObject(2484,-2707.38378906,372.33828735,4.80856562,0.00000000,0.00000000,0.00000000);
	CreateObject(2454,-2702.79663086,375.01049805,3.97252083,0.00000000,0.00000000,0.00000000);
	CreateObject(2454,-2702.54785156,377.06506348,3.96868849,0.00000000,0.00000000,89.99548340);
	CreateObject(2454,-2709.84130859,378.29168701,3.96876383,0.00000000,0.00000000,205.99450684);
	CreateObject(14870,-2706.71582031,373.61630249,11.54687119,0.00000000,0.00000000,0.00000000);
	CreateObject(14870,-2704.56494141,373.26446533,24.75610924,0.00000000,0.00000000,296.00000000);
	CreateObject(14870,-2705.25488281,373.35855103,15.12049675,0.00000000,0.00000000,17.99914551);
	CreateObject(14870,-2706.72265625,364.66778564,24.47894669,0.00000000,0.00000000,215.99560547);
	CreateObject(14870,-2707.57861328,381.17886353,19.09156799,0.00000000,0.00000000,155.99121094);
	CreateObject(14870,-2704.77075195,377.04089355,20.49364662,0.00000000,0.00000000,155.98937988);
	CreateObject(3877,-2707.77490234,373.80313110,16.76913071,271.00000000,0.00000000,152.00000000);
	CreateObject(3877,-2708.58154297,379.04061890,15.68122482,270.99975586,0.00000000,107.99584961);
	CreateObject(3877,-2707.08251953,381.24850464,16.50436783,270.99426270,0.00000000,21.99560547);
	CreateObject(3877,-2704.91479492,376.21548462,17.06835556,270.99426270,0.00000000,291.99462891);
	CreateObject(3877,-2704.30419922,374.74246216,15.31949806,270.99426270,0.00000000,235.99462891);
	CreateObject(3877,-2706.62670898,373.60058594,19.21698761,270.99426270,0.00000000,181.99182129);
	CreateObject(3877,-2706.60522461,373.59677124,25.51964188,270.99426270,0.00000000,181.98852539);
	CreateObject(3877,-2708.80078125,376.48785400,25.34601974,270.99426270,0.00000000,143.98852539);
	CreateObject(3877,-2708.76245117,380.32965088,22.49613190,270.99426270,0.00000000,49.98681641);
	CreateObject(3877,-2705.79125977,379.82800293,20.90824699,270.99426270,0.00000000,283.98229980);
	CreateObject(3534,-2714.23632812,378.60433960,15.30849075,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2707.74877930,375.39852905,16.67776489,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2704.40332031,378.12808228,11.28053474,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2708.10400391,381.10507202,12.84053516,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2707.80346680,375.45501709,14.76138401,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2708.46166992,378.18728638,12.28053474,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2707.83056641,373.84539795,18.48528862,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2707.92895508,375.27389526,15.86812496,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2708.50781250,378.51614380,17.39788818,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2706.96020508,381.26565552,24.25031090,13.00000000,194.00000000,314.00000000);
	CreateObject(3472,-2705.07421875,376.74777222,30.69754219,12.99682617,193.99658203,257.99475098);
	CreateObject(3534,-2713.55468750,363.66510010,21.78607178,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2705.38818359,358.29653931,20.97453690,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2693.00292969,367.05838013,19.85726357,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2702.90283203,383.85583496,20.11940193,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2699.66821289,383.50790405,15.66015148,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2698.00952148,380.52221680,16.66557312,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2701.49658203,375.21389771,17.21406555,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2713.64453125,370.86132812,18.92479324,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2708.59521484,379.13803101,30.03047752,13.00000000,194.00000000,0.00000000);
	CreateObject(3472,-2708.01733398,375.67639160,25.94305611,12.99682617,193.99658203,96.00000000);
	CreateObject(3534,-2720.61157227,384.60675049,22.78135681,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2715.02368164,385.54934692,20.23530579,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2718.37109375,377.79827881,19.75296783,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2725.89916992,375.05877686,21.18688011,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2698.17187500,373.01635742,15.73170090,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2701.84106445,368.41925049,17.12574768,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2705.81225586,373.45687866,22.08354568,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2709.46386719,374.91137695,25.64812851,13.00000000,194.00000000,68.00000000);
	CreateObject(3472,-2708.39379883,381.06442261,21.48554802,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2705.72656250,379.36645508,23.78524208,13.00000000,194.00000000,216.00000000);
	CreateObject(3472,-2705.59863281,373.21707153,24.72511101,12.99682617,193.99658203,183.99670410);
	CreateObject(3472,-2708.55273438,378.83599854,27.33802032,12.99682617,193.99108887,77.99353027);
	CreateObject(3472,-2707.00610352,381.25921631,28.51313019,12.99682617,193.99108887,283.99194336);
	CreateObject(3534,-2704.69604492,384.71276855,16.07434654,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2708.01049805,365.46545410,20.03053093,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2699.31030273,365.08697510,21.65671539,0.00000000,0.00000000,0.00000000);
	CreateObject(3534,-2711.09155273,367.46783447,25.64758110,0.00000000,0.00000000,0.00000000);
	CreateObject(3472,-2708.09887695,373.47668457,32.40806961,12.99682617,193.99658203,103.99987793);
	CreateObject(3472,-2705.20361328,373.34951782,32.51392365,12.99682617,193.99108887,155.99658203);
	CreateObject(3472,-2701.80981445,378.32183838,26.66471672,12.99682617,193.99108887,229.99487305);
	CreateObject(3038,-2706.46289062,373.57168579,10.39013863,99.00000000,0.00000000,48.00000000);
	CreateObject(3038,-2704.14379883,375.65164185,7.62436914,98.99783325,0.00000000,165.99926758);
	CreateObject(3038,-2705.21508789,377.54974365,11.81369305,98.99780273,0.00000000,183.99792480);
	CreateObject(3038,-2705.92187500,380.75765991,11.07896423,98.99780273,0.00000000,189.99353027);
	CreateObject(3038,-2708.19018555,381.09298706,7.86560822,98.99780273,0.00000000,223.99206543);
	CreateObject(3038,-2708.62670898,379.36236572,7.49907446,98.99780273,0.00000000,179.98925781);
	CreateObject(3038,-2708.48266602,377.44958496,13.01852798,98.99780273,0.00000000,179.98901367);
	CreateObject(3038,-2706.24975586,373.53408813,7.27033615,98.99780273,0.00000000,179.98901367);
	CreateObject(970,-2710.69140625,371.59402466,3.94076157,0.00000000,0.00000000,314.00000000);
	CreateObject(970,-2706.46606445,370.02069092,3.93623304,0.00000000,0.00000000,359.99475098);
	CreateObject(970,-2701.73046875,371.75238037,3.94078469,0.00000000,0.00000000,43.99450684);
	CreateObject(970,-2701.80297852,380.86795044,3.92647910,0.00000000,0.00000000,137.98925781);
	CreateObject(970,-2703.66650391,376.11059570,4.60033703,275.00000000,0.00000000,87.98449707);
	CreateObject(970,-2706.29931641,382.41464233,3.91866851,0.00000000,0.00000000,179.98376465);
	CreateObject(970,-2710.92382812,380.47610474,3.91866851,0.00000000,0.00000000,223.98352051);
	CreateObject(970,-2712.72534180,376.12063599,3.92792559,0.00000000,0.00000000,269.97827148);
	CreateObject(3877,-2712.58178711,378.66693115,5.03292847,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2712.51611328,373.55255127,5.05479240,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2708.97583008,370.20312500,5.04991341,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2703.76489258,370.20312500,5.04991341,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2700.09375000,373.60821533,5.04971313,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2700.02294922,379.27618408,5.04073906,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2703.79223633,382.11779785,5.03292847,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2708.85937500,382.00000000,5.03292847,0.00000000,0.00000000,0.00000000);
	CreateObject(2124,-2703.68579102,376.19537354,5.58674717,0.00000000,0.00000000,178.00000000);
	CreateObject(1472,-2703.39843750,376.12493896,3.99562263,0.00000000,0.00000000,90.00000000);
	CreateObject(1577,-2703.58471680,378.94894409,4.16833305,0.00000000,0.00000000,0.00000000);
	CreateObject(2710,-2702.46582031,376.82360840,5.10903502,0.00000000,0.00000000,0.00000000);
	CreateObject(2057,-2704.42260742,379.12969971,5.14990664,0.00000000,0.00000000,336.00000000);
	CreateObject(2035,-2702.76123047,375.29367065,5.01246452,0.00000000,0.00000000,0.00000000);
	CreateObject(1654,-2703.45800781,378.24755859,5.53104591,0.00000000,0.00000000,0.00000000);
	CreateObject(1579,-2702.21606445,374.08361816,4.37533331,0.00000000,0.00000000,0.00000000);
	CreateObject(3522,-2699.57617188,376.09201050,3.45473099,0.00000000,0.00000000,0.00000000);
	CreateObject(2057,-2703.59228516,374.04187012,5.14990664,0.00000000,0.00000000,335.99487305);
	CreateObject(1577,-2702.17285156,374.61962891,4.38290453,0.00000000,0.00000000,0.00000000);
	CreateObject(1827,-2702.13793945,374.12081909,3.97474098,0.00000000,0.00000000,0.00000000);
	CreateObject(1954,-2701.78198242,373.78027344,4.69306993,0.00000000,0.00000000,46.00000000);
	CreateObject(2484,-2702.41088867,378.17538452,4.69339085,0.00000000,0.00000000,90.00000000);
	CreateObject(2484,-2704.55395508,376.18743896,6.87564707,0.00000000,0.00000000,90.00000000);
	CreateObject(2484,-2709.94458008,374.98107910,4.80514002,0.00000000,0.00000000,116.00000000);
	CreateObject(2485,-2702.60839844,377.15664673,5.00863266,0.00000000,0.00000000,126.00000000);
	CreateObject(2464,-2701.64501953,375.14590454,4.11610460,0.00000000,0.00000000,290.00000000);
	CreateObject(2464,-2701.89282227,377.39620972,4.11152649,0.00000000,0.00000000,257.99511719);
	CreateObject(2464,-2703.32958984,379.53802490,4.10850334,0.00000000,0.00000000,309.99194336);
	CreateObject(2464,-2709.75537109,378.10208130,5.15171289,0.00000000,0.00000000,63.99023438);
	CreateObject(2464,-2710.69531250,375.15093994,4.11727858,0.00000000,0.00000000,91.98986816);
	CreateObject(2464,-2708.88745117,372.80325317,4.11450672,0.00000000,0.00000000,105.98852539);
	CreateObject(2464,-2703.42065430,372.72836304,4.11189795,0.00000000,0.00000000,219.98510742);
	CreateObject(2466,-2705.27709961,377.61380005,6.06908226,0.00000000,0.00000000,94.00000000);
	CreateObject(2466,-2701.61425781,374.35293579,4.55010271,0.00000000,0.00000000,117.99902344);
	CreateObject(2477,-2702.24511719,378.58636475,4.41969681,0.00000000,0.00000000,84.00000000);
	CreateObject(2477,-2705.17846680,371.86395264,4.53150940,0.00000000,0.00000000,1.99597168);
	CreateObject(2477,-2710.75488281,376.70098877,4.53381872,0.00000000,0.00000000,275.99401855);
	CreateObject(970,-2697.26513672,373.62747192,3.93238306,0.00000000,0.00000000,2.00000000);
	CreateObject(970,-2697.31054688,379.07852173,3.92647910,0.00000000,0.00000000,359.99902344);
	CreateObject(970,-2692.37377930,373.79226685,3.92839718,0.00000000,0.00000000,359.99450684);
	CreateObject(970,-2692.45971680,379.13003540,3.91866851,0.00000000,0.00000000,359.99450684);
	CreateObject(3877,-2694.81933594,373.61663818,5.04487801,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2695.22143555,379.01626587,5.03292847,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2690.27124023,373.53881836,5.04664612,0.00000000,0.00000000,0.00000000);
	CreateObject(3877,-2690.11132812,379.28613281,5.04073906,0.00000000,0.00000000,0.00000000);
//-----------------------ANOTHER CHRISTMAS TREE -------------------------------------------------------
	CreateObject(664, -1998.0460205078, 148.79306030273, 25.906070709229, 0, 0, 340);
	CreateObject(664, -1998.0458984375, 148.79296875, 25.906070709229, 0, 0, 325.99938964844);
	CreateObject(664, -1998.0458984375, 148.79296875, 25.906070709229, 0, 0, 303.99731445313);
	CreateObject(664, -1998.0458984375, 148.79296875, 25.906070709229, 0, 0, 287.99719238281);
	CreateObject(3472, -1997.1529541016, 148.4162902832, 32.6875, 0, 0, 0);
	CreateObject(3472, -1997.15234375, 148.416015625, 36.607498168945, 0, 0, 0);
	CreateObject(3472, -1997.15234375, 148.416015625, 44.357498168945, 0, 0, 0);
	CreateObject(3472, -1997.4702148438, 148.65103149414, 55.107498168945, 0, 0, 0);
	CreateObject(3472, -1998.1090087891, 148.44111633301, 50.607498168945, 40, 0, 0);
	CreateObject(3472, -2001.8745117188, 148.5101776123, 47.607498168945, 39.995727539063, 0, 90);
	CreateObject(3472, -2000.2878417969, 145.7417755127, 50.607498168945, 39.995727539063, 0, 170);
	CreateObject(3472, -1996.1226806641, 149.14767456055, 44.607498168945, 39.995727539063, 0, 277.99694824219);
	CreateObject(3472, -1996.2100830078, 149.05192565918, 41.607498168945, 39.995727539063, 0, 277.99255371094);
	CreateObject(3472, -2000.4672851563, 151.34553527832, 41.607498168945, 39.995727539063, 0, 39.992553710938);
	CreateObject(3472, -1999.8195800781, 147.89109802246, 41.607498168945, 39.995727539063, 0, 127.990234375);
	CreateObject(3472, -1998.1652832031, 147.17254638672, 41.607498168945, 39.995727539063, 0, 207.98522949219);
	CreateObject(3472, -1997.15234375, 148.416015625, 28.857498168945, 0, 0, 310);
	CreateObject(3515, -1998.8930664063, 144.0747833252, 27.581159591675, 0, 0, 0);
	CreateObject(3515, -1998.8284912109, 154.17958068848, 27.831155776978, 0, 0, 0);
	CreateObject(3534, -1998.560546875, 141.37292480469, 48.970138549805, 28, 0, 352);
	CreateObject(3534, -1993.6901855469, 142.69296264648, 48.970138549805, 27.998657226563, 0, 29.996459960938);
	CreateObject(3534, -1991.8308105469, 148.89370727539, 48.970138549805, 27.998657226563, 0, 85.99267578125);
	CreateObject(3534, -1995.1551513672, 155.28498840332, 48.970138549805, 27.998657226563, 0, 123.98999023438);
	CreateObject(3534, -1999.73828125, 155.6160736084, 48.970138549805, 27.998657226563, 0, 159.98620605469);
	CreateObject(3534, -2004.7911376953, 149.40711975098, 48.970138549805, 27.998657226563, 0, 215.98291015625);
	CreateObject(3534, -2002.8659667969, 144.27090454102, 48.970138549805, 27.998657226563, 0, 277.98022460938);
	CreateObject(3534, -2001.7861328125, 145.97839355469, 56.220138549805, 27.998657226563, 0, 291.97607421875);
	CreateObject(3534, -2001.3598632813, 150.37046813965, 56.220138549805, 27.998657226563, 0, 253.97265625);
	CreateObject(3534, -1997.0113525391, 150.35415649414, 55.470138549805, 27.998657226563, 0, 177.97094726563);
	CreateObject(3534, -1995.1121826172, 147.66877746582, 55.470138549805, 27.998657226563, 0, 161.96752929688);
	CreateObject(3534, -1997.7120361328, 144.8631439209, 56.220138549805, 27.998657226563, 0, 3.97265625);
	CreateObject(3534, -2000.2390136719, 144.6975402832, 40.745124816895, 356.92108154297, 167.98248291016, 24.167358398438);
	CreateObject(3534, -2002.3602294922, 147.19053649902, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -2002.7614746094, 150.74235534668, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -2001.1950683594, 153.51251220703, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -1999.08984375, 154.86074829102, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -1994.4105224609, 155.89538574219, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -1990.2229003906, 153.66470336914, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -1989.1068115234, 150.2596282959, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -1990.0328369141, 144.34252929688, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -1992.7410888672, 140.88737487793, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(3534, -1996.2249755859, 139.30950927734, 40.745124816895, 356.91833496094, 167.98095703125, 24.164428710938);
	CreateObject(7666, -1998.1800537109, 148.45513916016, 74.819854736328, 0, 0, 0);
	CreateObject(7666, -1998.1796875, 148.455078125, 74.819854736328, 0, 0, 280);
	CreateObject(3472, -1997.4697265625, 148.650390625, 60.357498168945, 0, 0, 0);
	
//--------------------------------------SF circuslamposts----------------------------------------
	CreateChristmasLights(-1293.96105957,471.57125854,6.18750000);
	CreateChristmasLights(-1260.64416504,444.49423218,6.18750000); 
	CreateChristmasLights(-1229.65881348,453.10644531,6.18750000); 
	CreateChristmasLights(-1373.04516602,475.83438110,6.18750000);
	CreateChristmasLights(-1478.45825195,460.13754272,6.18750000); 
	CreateChristmasLights(-1529.34753418,515.56933594,6.17968750); 
	CreateChristmasLights(-1567.61364746,549.51361084,6.17968750); 
	CreateChristmasLights(-1524.52832031,660.17004395,7.41608429); 
	CreateChristmasLights(-1499.36853027,776.62878418,6.18531609);
	CreateChristmasLights(-1550.60546875,781.25585938,6.26562500);
	CreateChristmasLights(-1520.44885254,815.79431152,6.18750000); 
	CreateChristmasLights(-1581.40991211,822.94024658,6.18750000); 
	CreateChristmasLights(-1546.51574707,913.64306641,6.03906250); 
	CreateChristmasLights(-1518.42053223,982.31994629,6.18750000); 
	CreateChristmasLights(-1550.61291504,961.41210938,6.26562500); 
	CreateChristmasLights(-1579.41711426,998.09582520,6.26562500); 
	CreateChristmasLights(-1562.93664551,1053.31579590,6.18750000); 
	CreateChristmasLights(-1592.88037109,1104.89196777,6.18750000); 
	CreateChristmasLights(-1709.11193848,623.88732910,23.89062500);
	CreateChristmasLights(-1724.10241699,740.69903564,23.89062500); 
	CreateChristmasLights(-1660.48291016,742.40258789,16.72198486); 
	CreateChristmasLights(-1651.47204590,723.47357178,15.10015297); 
	CreateChristmasLights(-1615.34167480,737.95001221,12.58959675); 
	CreateChristmasLights(-1607.08288574,723.17523193,11.25325871);
	CreateChristmasLights(-1624.35449219,825.00469971,6.38964462); 
	CreateChristmasLights(-1966.59936523,1295.37219238,6.18750000);
	CreateChristmasLights(-1967.86145020,1330.51306152,6.18750000); 
	CreateChristmasLights(-2032.22045898,1324.98010254,6.27741623); 
	CreateChristmasLights(-2059.11791992,1295.58276367,6.33593750); 
	CreateChristmasLights(-2077.17700195,1257.81030273,11.29933167); 
	CreateChristmasLights(-2089.61059570,1337.08764648,7.75382042);
	CreateChristmasLights(-2134.23706055,1320.89282227,6.18750000); 
	CreateChristmasLights(-2173.73852539,1340.86975098,7.54163265);
	CreateChristmasLights(-2205.13208008,1321.81726074,6.18750000); 
	CreateChristmasLights(-2249.03027344,1341.90502930,6.18750000); 
	CreateChristmasLights(-2340.65991211,1363.66772461,6.27034760); 
	CreateChristmasLights(-2613.32861328,1407.99890137,6.14962482); 
	CreateChristmasLights(-2658.95239258,1281.64196777,6.18750048); 
	CreateChristmasLights(-2694.06298828,1298.85168457,6.18109035);
	CreateChristmasLights(-2740.91113281,1280.98754883,5.82114124); 
	CreateChristmasLights(-2768.25146484,1303.40466309,5.25621080); 
	CreateChristmasLights(-2813.50683594,1275.10961914,4.72656250); 
	CreateChristmasLights(-2634.42016602,607.13775635,13.45312500);
	CreateChristmasLights(-2697.69799805,619.00164795,13.45312500); 
	CreateChristmasLights(-2700.64990234,582.93231201,14.81543350);
	CreateChristmasLights(-2700.76367188,410.51034546,3.36718750);
	CreateChristmasLights(-2721.14721680,411.87704468,3.17631340);
	CreateChristmasLights(-2698.97534180,343.98141479,3.41406250);
	CreateChristmasLights(-2713.60205078,342.31127930,3.41406250); 
	CreateChristmasLights(-2705.25708008,289.91201782,3.28906250);
	CreateChristmasLights(-2066.05908203,69.35791016,27.39062500); 
	CreateChristmasLights(-2051.78149414,116.07773590,28.08853531);
	CreateChristmasLights(-2022.22412109,116.58210754,26.92206764);
	CreateChristmasLights(-1972.75964355,332.83102417,33.53115845);
	CreateChristmasLights(-1985.43359375,437.95660400,34.17187500); 
	CreateChristmasLights(-1985.44323730,437.71679688,34.28994370); 
	CreateChristmasLights(-1917.57788086,584.41796875,34.22170639); 
	CreateChristmasLights(-1911.19750977,723.03210449,44.44531250); 
	CreateChristmasLights(-2035.43908691,713.39001465,51.75196457);
	CreateChristmasLights(-2024.85827637,679.72918701,47.81198883); 
	CreateChristmasLights(-1983.20715332,880.57531738,44.20312500);
	CreateChristmasLights(-1912.47937012,876.44409180,34.24229050); 
	CreateChristmasLights(-2015.01782227,584.51171875,34.17187500);
	CreateChristmasLights(-1958.47534180,596.22546387,34.17187500);
	CreateChristmasLights(-2029.48034668,496.16537476,34.17187500);
	CreateChristmasLights(-2127.29736328,497.09268188,34.17187500);
	CreateChristmasLights(-2244.83691406,532.76287842,34.14505005);
	CreateChristmasLights(-2261.08129883,746.97790527,48.29687500);
	#endif
	return true;
}

stock CountObjects()
{
	new o_count;
	
	#if using_streamer
	o_count = CountDynamicObjects();
	#else
	Loop(i,MAX_OBJECTS)	if(IsValidObject(i)) o_count++;
	#endif
	
	return o_count;
}

public OnRconCommand(cmd[])
{
	if(!strcmp("count",cmd,false))
	{
		printf("%i",CountObjects());
	}
	return 1;
}

CMD:tele(playerid,params[])
{
	new Float:x, Float:y,Float:z;
	if(sscanf(params,"fff",x,y,z)) return 0;
	SetPlayerPos(playerid,x,y,z);
	return 1;
}

CMD:spawn(playerid,params[])
{
    new id,Float:x, Float:y,Float:z;
	if(sscanf(params,"i",id)) return 0;
	GetPlayerPos(playerid,x,y,z);
	CreateChristmasTree(2, x,y+9,z);
	return 1;
}

public OnFilterScriptExit()
{
	TextDrawDestroy(NYCounter[0]);
	TextDrawDestroy(NYCounter[1]);
    TextDrawDestroy(NYCounter[2]);
    KillTimer(s_Timer[0]);
    KillTimer(s_Timer[1]);

	DestroyTextdraws();

 	pLoop()
	{
    	if(snowOn{i})
        {
			Loop(x,MAX_SNOW_OBJECTS) DestroyObject(snowObject[i][x]);
            KillTimer(updateTimer{i});
        }
 	}
 	Loop(i,sizeof(batteries)) DestroyObject(batteries[i][machine]);
	return 1;
}
public OnPlayerDisconnect(playerid,reason)
{
	if(snowOn{playerid})
    {
    	Loop(i,MAX_SNOW_OBJECTS) DestroyObject(snowObject[playerid][i]);
        snowOn{playerid} = false;
        KillTimer(updateTimer{playerid});
    }
	return 1;
}

public OnPlayerConnect(  playerid  )
{
	SendClientMessage(playerid,COLOR_YELLOW,"This server uses [MV]_Christmas, cmds: /christmas");

	new year, month, day, hour, minute, second;
    getdate(year, month, day);
    gettime(hour, minute, second);
    if(day == 1 && month == 1 && (second > 0 || hour > 0)) TextDrawShowForPlayer(playerid, NYCounter[2]);

	Snow_F[playerid] = 0;
	Killer[playerid] = 501;
	Charged[playerid] = 0;
	Shoot[playerid] = 0;

    return 1;
}
public OnPlayerSpawn(playerid)
{
  	SendClientMessage(playerid,COLOR_YELLOW,"This server uses [MV]_Christmas, cmds: /christmas");
	pLogo[ playerid ] = true ;
	ShowLogo(playerid);
    GiveChristmasHat(playerid,HAT_TYPE_1);
    CreateSnow(playerid);

    DestroyObject(Obj[playerid]);
    if(Killer[playerid] != 501)
	{
		Shoot[Killer[playerid]] = 0;
		Killer[playerid] = 501;
    }
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
  	if(Snow_F[playerid] == 1) return Snow_F[playerid] = 0;
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Snow_F[playerid] == 1)
	{
		if(Shoot[playerid] == 0)
		{
			if(newkeys & KEY_AIM)
			{
				if(Charged[playerid] == 1) return CheckSnow(playerid);
				else if(Charged[playerid] == 0) return ApplyAnimation( playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0 ), Charged[playerid] = 1;
			}
		}
	}
	return 1;
}

public Animate()
{
	switch(gDirection)
	{
		case 0:
		{
			gCount++;
			switch(gCount)
			{
				case 1:
				{
					TheX += 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 0;
				    AddEyesOptions();
				}
				case 2:
				{
					TheX += 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 0;
				    AddEyesOptions();
				}
				case 3:
				{
					TheX += 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 0;
				    AddEyesOptions();
				}
				case 4:
				{
					TheX -= 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 0;
				    AddEyesOptions();
				}
				case 5:
				{
					TheX -= 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 0;
				    AddEyesOptions();
				}
				case 6:
				{
					TheX -= 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    AddEyesOptions();
				    gDirection = 1;
				    gCount = 0;
				}
			}
			pLoop()	if ( pLogo[ i ] == true ) TextDrawShowForPlayer( i, SM_Textdraw[11]);
		}
		
		case 1:
		{
			gCount++;
			switch(gCount)
			{
				case 1:
				{
					TheX += 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 1;
				    AddEyesOptions();
				}
				case 2:
				{
					TheX += 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 1;
				    AddEyesOptions();
				}
				case 3:
				{
					TheX += 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 1;
				    AddEyesOptions();
				}
				case 4:
				{
					TheX -= 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 1;
				    AddEyesOptions();
				}
				case 5:
				{
					TheX -= 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    gDirection = 1;
				    AddEyesOptions();
				}
				case 6:
				{
					TheX -= 0.500;
					TextDrawDestroy(Text:SM_Textdraw[11] );
				    SM_Textdraw[11] = TextDrawCreate(TheX, 405.000000, "..");
				    AddEyesOptions();
				    gDirection = 2;
				    gCount = 0;
				}
	    		
			}
			Loop(i,MAX_PLAYERS ) if ( pLogo[ i ] == true )	TextDrawShowForPlayer( i, SM_Textdraw[11]);
		}
		
		case 2:
		{
			gCount++;
			switch(gCount)
			{
				case 1:
				{
					BoxY += 0.050;
				    TextDrawLetterSize(SM_Textdraw[1],  2.099999,BoxY);
				    gDirection = 2;
				    AddMouthOptions();
				}
				case 2:
				{
					BoxY += 0.050;
				    TextDrawLetterSize(SM_Textdraw[1],  2.099999,BoxY);
				    gDirection = 2;
				    AddMouthOptions();
				}
				case 3:
				{
					BoxY -= 0.050;
				    TextDrawLetterSize(SM_Textdraw[1],  2.099999,BoxY);
				    gDirection = 2;
				    AddMouthOptions();
				}
				case 4:
				{
					BoxY -= 0.050;
				    TextDrawLetterSize(SM_Textdraw[1],  2.099999,BoxY);
				    gDirection = 2;
				    AddMouthOptions();
				}
				case 5:
				{
					BoxY += 0.050;
				    TextDrawLetterSize(SM_Textdraw[1],  2.099999,BoxY);
				    gDirection = 2;
				    AddMouthOptions();
				}
				case 6:
				{
					BoxY += 0.050;
				    TextDrawLetterSize(SM_Textdraw[1],  2.099999,BoxY);
				    gDirection = 2;
				    AddMouthOptions();
				}
				case 7:
				{
					BoxY -= 0.050;
				    TextDrawLetterSize(SM_Textdraw[1],  2.099999,BoxY);
				    gDirection = 2;
				    AddMouthOptions();
				}
				case 8:
				{
					BoxY-= 0.050;
				    TextDrawLetterSize(SM_Textdraw[1],  2.099999,BoxY);
				    AddMouthOptions();
				    gDirection = 0;
				    gCount = 0;
				}
			}
   			Loop(i,MAX_PLAYERS ) if ( pLogo[ i ] ==  true )	TextDrawShowForPlayer( i, SM_Textdraw[1]);
		}
	}
}
stock DestroyTextdraws()
{
	TextDrawHideForAll(SM_Textdraw[0]);
	TextDrawDestroy(SM_Textdraw[0]);
	TextDrawHideForAll(SM_Textdraw[1]);
	TextDrawDestroy(SM_Textdraw[1]);
	TextDrawHideForAll(SM_Textdraw[2]);
	TextDrawDestroy(SM_Textdraw[2]);
	TextDrawHideForAll(SM_Textdraw[3]);
	TextDrawDestroy(SM_Textdraw[3]);
	TextDrawHideForAll(SM_Textdraw[4]);
	TextDrawDestroy(SM_Textdraw[4]);
	TextDrawHideForAll(SM_Textdraw[5]);
	TextDrawDestroy(SM_Textdraw[5]);
	TextDrawHideForAll(SM_Textdraw[6]);
	TextDrawDestroy(SM_Textdraw[6]);
	TextDrawHideForAll(SM_Textdraw[7]);
	TextDrawDestroy(SM_Textdraw[7]);
	TextDrawHideForAll(SM_Textdraw[8]);
	TextDrawDestroy(SM_Textdraw[8]);
	TextDrawHideForAll(SM_Textdraw[9]);
	TextDrawDestroy(SM_Textdraw[9]);
	TextDrawHideForAll(SM_Textdraw[10]);
	TextDrawDestroy(SM_Textdraw[10]);
	TextDrawHideForAll(SM_Textdraw[11]);
	TextDrawDestroy(SM_Textdraw[11]);
	TextDrawHideForAll(SM_Textdraw[12]);
	TextDrawDestroy(SM_Textdraw[12]);
	TextDrawHideForAll(SM_Textdraw[13]);
	TextDrawDestroy(SM_Textdraw[13]);
	TextDrawHideForAll(SM_Textdraw[14]);
	TextDrawDestroy(SM_Textdraw[14]);
	TextDrawHideForAll(SM_Textdraw[15]);
	TextDrawDestroy(SM_Textdraw[15]);
	TextDrawHideForAll(SM_Textdraw[16]);
	TextDrawDestroy(SM_Textdraw[16]);
	TextDrawHideForAll(SM_Textdraw[17]);
	TextDrawDestroy(SM_Textdraw[17]);
	TextDrawHideForAll(SM_Textdraw[18]);
	TextDrawDestroy(SM_Textdraw[18]);
	TextDrawHideForAll(SM_Textdraw[19]);
	TextDrawDestroy(SM_Textdraw[19]);
}

stock AddEyesOptions()
{
	TextDrawBackgroundColor(SM_Textdraw[11], 255);
	TextDrawFont(SM_Textdraw[11], 1);
	TextDrawLetterSize(SM_Textdraw[11], 0.400000, 1.500000);
	TextDrawColor(SM_Textdraw[11], 255);
	TextDrawSetOutline(SM_Textdraw[11], 0);
	TextDrawSetProportional(SM_Textdraw[11], 0);
	TextDrawSetShadow(SM_Textdraw[11], 0);
}

stock AddMouthOptions()
{
	TextDrawBackgroundColor(SM_Textdraw[1], 255);
	TextDrawFont(SM_Textdraw[1], 1);
	TextDrawColor(SM_Textdraw[1], -1);
	TextDrawSetOutline(SM_Textdraw[1], 0);
	TextDrawSetProportional(SM_Textdraw[1], 1);
	TextDrawSetShadow(SM_Textdraw[1], 1);
	TextDrawUseBox(SM_Textdraw[1], 1);
	TextDrawBoxColor(SM_Textdraw[1], -1);
	TextDrawTextSize(SM_Textdraw[1], 504.000000, 0.000000);
}

stock LoadTextdraws()
{
	SM_Textdraw[0] = TextDrawCreate(501.000000, 402.000000, "O");
	TextDrawBackgroundColor(SM_Textdraw[0], 255);
	TextDrawFont(SM_Textdraw[0], 1);
	TextDrawLetterSize(SM_Textdraw[0], 0.899999, 3.000000);
	TextDrawColor(SM_Textdraw[0], -1);
	TextDrawSetOutline(SM_Textdraw[0], 0);
	TextDrawSetProportional(SM_Textdraw[0], 1);
	TextDrawSetShadow(SM_Textdraw[0], 0);

	SM_Textdraw[1] = TextDrawCreate(521.000000, 412.000000, "~n~");
	TextDrawBackgroundColor(SM_Textdraw[1], 255);
	TextDrawFont(SM_Textdraw[1], 1);
	TextDrawLetterSize(SM_Textdraw[1], 2.099999, 0.499999);
	TextDrawColor(SM_Textdraw[1], -1);
	TextDrawSetOutline(SM_Textdraw[1], 0);
	TextDrawSetProportional(SM_Textdraw[1], 1);
	TextDrawSetShadow(SM_Textdraw[1], 1);
	TextDrawUseBox(SM_Textdraw[1], 1);
	TextDrawBoxColor(SM_Textdraw[1], -1);
	TextDrawTextSize(SM_Textdraw[1], 504.000000, 0.000000);

	SM_Textdraw[2] = TextDrawCreate(496.000000, 412.000000, "O");
	TextDrawBackgroundColor(SM_Textdraw[2], 255);
	TextDrawFont(SM_Textdraw[2], 1);
	TextDrawLetterSize(SM_Textdraw[2], 1.329998, 4.899999);
	TextDrawColor(SM_Textdraw[2], -1);
	TextDrawSetOutline(SM_Textdraw[2], 0);
	TextDrawSetProportional(SM_Textdraw[2], 1);
	TextDrawSetShadow(SM_Textdraw[2], 0);

	SM_Textdraw[3] = TextDrawCreate(527.000000, 429.000000, "~n~");
	TextDrawBackgroundColor(SM_Textdraw[3], 255);
	TextDrawFont(SM_Textdraw[3], 1);
	TextDrawLetterSize(SM_Textdraw[3], 2.099999, 1.400000);
	TextDrawColor(SM_Textdraw[3], -1);
	TextDrawSetOutline(SM_Textdraw[3], 0);
	TextDrawSetProportional(SM_Textdraw[3], 1);
	TextDrawSetShadow(SM_Textdraw[3], 1);
	TextDrawUseBox(SM_Textdraw[3], 1);
	TextDrawBoxColor(SM_Textdraw[3], -1);
	TextDrawTextSize(SM_Textdraw[3], 501.000000, -2.000000);

	SM_Textdraw[4] = TextDrawCreate(511.000000, 418.000000, ":");
	TextDrawBackgroundColor(SM_Textdraw[4], 255);
	TextDrawFont(SM_Textdraw[4], 1);
	TextDrawLetterSize(SM_Textdraw[4], 0.469999, 1.500000);
	TextDrawColor(SM_Textdraw[4], 255);
	TextDrawSetOutline(SM_Textdraw[4], 0);
	TextDrawSetProportional(SM_Textdraw[4], 1);
	TextDrawSetShadow(SM_Textdraw[4], 0);

	SM_Textdraw[5] = TextDrawCreate(550.000000, 427.000000, "O");
	TextDrawBackgroundColor(SM_Textdraw[5], 255);
	TextDrawFont(SM_Textdraw[5], 1);
	TextDrawLetterSize(SM_Textdraw[5], 2.029999, 4.899999);
	TextDrawColor(SM_Textdraw[5], -1);
	TextDrawSetOutline(SM_Textdraw[5], 0);
	TextDrawSetProportional(SM_Textdraw[5], 1);
	TextDrawSetShadow(SM_Textdraw[5], 0);

	SM_Textdraw[6] = TextDrawCreate(512.000000, 432.000000, "O");
	TextDrawBackgroundColor(SM_Textdraw[6], -1);
	TextDrawFont(SM_Textdraw[6], 1);
	TextDrawLetterSize(SM_Textdraw[6], 2.029999, 4.899999);
	TextDrawColor(SM_Textdraw[6], -1);
	TextDrawSetOutline(SM_Textdraw[6], 0);
	TextDrawSetProportional(SM_Textdraw[6], 1);
	TextDrawSetShadow(SM_Textdraw[6], -2);

	SM_Textdraw[7] = TextDrawCreate(553.000000, 433.000000, "O");
	TextDrawBackgroundColor(SM_Textdraw[7], 20);
	TextDrawFont(SM_Textdraw[7], 1);
	TextDrawLetterSize(SM_Textdraw[7], 2.029999, 4.899999);
	TextDrawColor(SM_Textdraw[7], -1);
	TextDrawSetOutline(SM_Textdraw[7], 0);
	TextDrawSetProportional(SM_Textdraw[7], 1);
	TextDrawSetShadow(SM_Textdraw[7], 0);

	SM_Textdraw[8] = TextDrawCreate(573.000000, 427.000000, "O");
	TextDrawBackgroundColor(SM_Textdraw[8], -1);
	TextDrawFont(SM_Textdraw[8], 1);
	TextDrawLetterSize(SM_Textdraw[8], 3.789998, 4.899999);
	TextDrawColor(SM_Textdraw[8], -1);
	TextDrawSetOutline(SM_Textdraw[8], 0);
	TextDrawSetProportional(SM_Textdraw[8], 1);
	TextDrawSetShadow(SM_Textdraw[8], 4);

	SM_Textdraw[9] = TextDrawCreate(500.000000, 405.000000, "O");
	TextDrawBackgroundColor(SM_Textdraw[9], 255);
	TextDrawFont(SM_Textdraw[9], 1);
	TextDrawLetterSize(SM_Textdraw[9], 0.949999, 0.799998);
	TextDrawColor(SM_Textdraw[9], 255);
	TextDrawSetOutline(SM_Textdraw[9], 1);
	TextDrawSetProportional(SM_Textdraw[9], 1);

	SM_Textdraw[10] = TextDrawCreate(527.000000, 406.000000, "~n~");
	TextDrawBackgroundColor(SM_Textdraw[10], 255);
	TextDrawFont(SM_Textdraw[10], 1);
	TextDrawLetterSize(SM_Textdraw[10], 0.500000, 0.099999);
	TextDrawColor(SM_Textdraw[10], -1);
	TextDrawSetOutline(SM_Textdraw[10], 0);
	TextDrawSetProportional(SM_Textdraw[10], 1);
	TextDrawSetShadow(SM_Textdraw[10], 1);
	TextDrawUseBox(SM_Textdraw[10], 1);
	TextDrawBoxColor(SM_Textdraw[10], 255);
	TextDrawTextSize(SM_Textdraw[10], 498.000000, 0.000000);

	SM_Textdraw[12] = TextDrawCreate(511.000000, 428.000000, ":");
	TextDrawBackgroundColor(SM_Textdraw[12], 255);
	TextDrawFont(SM_Textdraw[12], 1);
	TextDrawLetterSize(SM_Textdraw[12], 0.469999, 1.500000);
	TextDrawColor(SM_Textdraw[12], 255);
	TextDrawSetOutline(SM_Textdraw[12], 0);
	TextDrawSetProportional(SM_Textdraw[12], 1);
	TextDrawSetShadow(SM_Textdraw[12], 0);

	SM_Textdraw[13] = TextDrawCreate(512.000000, 420.000000, "/");
	TextDrawBackgroundColor(SM_Textdraw[13], 255);
	TextDrawFont(SM_Textdraw[13], 1);
	TextDrawLetterSize(SM_Textdraw[13], 0.449998, -0.399998);
	TextDrawColor(SM_Textdraw[13], -15466241);
	TextDrawSetOutline(SM_Textdraw[13], 0);
	TextDrawSetProportional(SM_Textdraw[13], 1);
	TextDrawSetShadow(SM_Textdraw[13], 0);

	SM_Textdraw[14] = TextDrawCreate(530.000000, 380.000000, ".     ~n~  .  .    .      . ~n~ .   .   .     . .  .~n~     .    . ~n~ .    .       .       . ~n~    .    .     .  . ~n~ .  .   ");
	TextDrawBackgroundColor(SM_Textdraw[14], -206);
	TextDrawFont(SM_Textdraw[14], 1);
	TextDrawLetterSize(SM_Textdraw[14], 0.330000, 0.999998);
	TextDrawColor(SM_Textdraw[14], -1);
	TextDrawSetOutline(SM_Textdraw[14], 0);
	TextDrawSetProportional(SM_Textdraw[14], 1);
	TextDrawSetShadow(SM_Textdraw[14], 10);

	SM_Textdraw[15] = TextDrawCreate(576.000000, 482.000000, ".     ~n~  .  .    .      . ~n~ .   .   .     . .  .~n~     .    . ~n~ .    .       .       . ~n~    .    .     .  . ~n~ .  .   ");
	TextDrawBackgroundColor(SM_Textdraw[15], -206);
	TextDrawFont(SM_Textdraw[15], 1);
	TextDrawLetterSize(SM_Textdraw[15], 0.330000, -1.000000);
	TextDrawColor(SM_Textdraw[15], -1);
	TextDrawSetOutline(SM_Textdraw[15], 0);
	TextDrawSetProportional(SM_Textdraw[15], 1);
	TextDrawSetShadow(SM_Textdraw[15], -60);

	SM_Textdraw[16] = TextDrawCreate(526.000000, 422.000000, "Merry Xmas!");
	TextDrawBackgroundColor(SM_Textdraw[16], -1);
	TextDrawFont(SM_Textdraw[16], 1);
	TextDrawLetterSize(SM_Textdraw[16], 0.430000, 2.000000);
	TextDrawColor(SM_Textdraw[16], -1);
	TextDrawSetOutline(SM_Textdraw[16], 0);
	TextDrawSetProportional(SM_Textdraw[16], 1);
	TextDrawSetShadow(SM_Textdraw[16], 0);

	SM_Textdraw[17] = TextDrawCreate(505.000000, 419.000000, "/");
	TextDrawBackgroundColor(SM_Textdraw[17], 255);
	TextDrawFont(SM_Textdraw[17], 1);
	TextDrawLetterSize(SM_Textdraw[17], -0.889999, 1.299998);
	TextDrawColor(SM_Textdraw[17], -1656160001);
	TextDrawSetOutline(SM_Textdraw[17], 0);
	TextDrawSetProportional(SM_Textdraw[17], 1);
	TextDrawSetShadow(SM_Textdraw[17], 0);

	SM_Textdraw[18] = TextDrawCreate(498.000000, 410.000000, "/");
	TextDrawBackgroundColor(SM_Textdraw[18], 255);
	TextDrawFont(SM_Textdraw[18], 1);
	TextDrawLetterSize(SM_Textdraw[18], -0.889999, 1.299998);
	TextDrawColor(SM_Textdraw[18], -1656160001);
	TextDrawSetOutline(SM_Textdraw[18], 0);
	TextDrawSetProportional(SM_Textdraw[18], 1);
	TextDrawSetShadow(SM_Textdraw[18], 0);

	SM_Textdraw[19] = TextDrawCreate(528.000000, 424.000000, "Merry Xmas!");
	TextDrawBackgroundColor(SM_Textdraw[19], -1);
	TextDrawFont(SM_Textdraw[19], 1);
	TextDrawLetterSize(SM_Textdraw[19], 0.409999, 1.700000);
	TextDrawColor(SM_Textdraw[19], 50);
	TextDrawSetOutline(SM_Textdraw[19], 0);
	TextDrawSetProportional(SM_Textdraw[19], 1);
	TextDrawSetShadow(SM_Textdraw[19], 0);

	SM_Textdraw[11] = TextDrawCreate(508.000000, 405.000000, "..");
	TextDrawBackgroundColor(SM_Textdraw[11], 255);
	TextDrawFont(SM_Textdraw[11], 1);
	TextDrawLetterSize(SM_Textdraw[11], 0.400000, 1.500000);
	TextDrawColor(SM_Textdraw[11], 255);
	TextDrawSetOutline(SM_Textdraw[11], 0);
	TextDrawSetProportional(SM_Textdraw[11], 0);
	TextDrawSetShadow(SM_Textdraw[11], 0);

	pLoop() HideLogo(i);
}

stock ShowLogo( playerid )
{
	Loop(i, 20) TextDrawShowForPlayer(playerid, SM_Textdraw[i]);
}
stock HideLogo( playerid )
{
	Loop(i,20) TextDrawHideForPlayer(playerid, SM_Textdraw[i]);
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
		case DIALOG_CHRISTMASMUSIC:
	    {
	        switch(listitem)
	        {
				case 0:PlayAudioStreamForPlayer(playerid,"http://pat.exp-gaming.net/music/JoseFelicianoFelizNavidad.mp3");
				case 1:PlayAudioStreamForPlayer(playerid,"http://pat.exp-gaming.net/music/Wewishyouamerrychristmas.mp3");
				case 2:PlayAudioStreamForPlayer(playerid,"http://pat.exp-gaming.net/music/jinglebells.mp3");
				case 3:PlayAudioStreamForPlayer(playerid,"http://pat.exp-gaming.net/music/DeanMartinLetitSnow.mp3");
				case 4:PlayAudioStreamForPlayer(playerid,"http://pat.exp-gaming.net/music/MariahCareyAllIWantForChristmasIsYou.mp3");
				case 5:PlayAudioStreamForPlayer(playerid,"http://pat.exp-gaming.net/music/michaelbublwhitechristmas.mp3");
				case 6:PlayAudioStreamForPlayer(playerid,"http://pat.exp-gaming.net/music/whamlastchristmas.mp3");
				case 7:PlayAudioStreamForPlayer(playerid,"http://pat.exp-gaming.net/music/TrainShakeUpChristmas.mp3");
				case 8:StopAudioStreamForPlayer(playerid);
			}
		}
		case DIALOG_CHRISTMASMUSICALL:
		{
			switch(listitem)
			{
				case 0:pLoop() PlayAudioStreamForPlayer(i,"http://pat.exp-gaming.net/music/JoseFelicianoFelizNavidad.mp3");
				case 1:pLoop() PlayAudioStreamForPlayer(i,"http://pat.exp-gaming.net/music/Wewishyouamerrychristmas.mp3");
				case 2:pLoop() PlayAudioStreamForPlayer(i,"http://pat.exp-gaming.net/music/jinglebells.mp3");
				case 3:pLoop() PlayAudioStreamForPlayer(i,"http://pat.exp-gaming.net/music/DeanMartinLetitSnow.mp3");
				case 4:pLoop() PlayAudioStreamForPlayer(i,"http://pat.exp-gaming.net/music/MariahCareyAllIWantForChristmasIsYou.mp3");
				case 5:pLoop() PlayAudioStreamForPlayer(i,"http://pat.exp-gaming.net/music/michaelbublwhitechristmas.mp3");
				case 6:pLoop() PlayAudioStreamForPlayer(i,"http://pat.exp-gaming.net/music/whamlastchristmas.mp3");
				case 7:pLoop() PlayAudioStreamForPlayer(i,"http://pat.exp-gaming.net/music/TrainShakeUpChristmas.mp3");
				case 8:pLoop() StopAudioStreamForPlayer(i);
			}
		}
	}
	return 0;
}

public OnObjectMoved(objectid)
{
    xFireworks_OnObjectMoved(objectid);
}
//------------------------------CMDS--------------------------------------------
CMD:logo(playerid,params[])
{
    if (pLogo[playerid] == true)
    {
        pLogo[playerid] = false ;
        SendClientMessage( playerid, -1, ""#COL_EASY"The logo has been hidden! {FFFFFF}["#COL_RED"DISABLED{FFFFFF}]");
        SendClientMessage( playerid, -1, ""#COL_EASY"Write again "#COL_BLUE"/logo"#COL_EASY" to activate it!");
        HideLogo(playerid);
    }
    else
    {
        pLogo[playerid] = true ;
        SendClientMessage( playerid, -1, ""#COL_EASY"The logo is displayed on the screen! {FFFFFF}["#COL_GREEN"ENABLED{FFFFFF}]");
        SendClientMessage( playerid, -1, ""#COL_EASY"Write again "#COL_BLUE"/logo"#COL_EASY" to de-activate it!");
        ShowLogo(playerid);
    }
    return 1;
}
CMD:snow(playerid, params[])
{
    if(snowOn{playerid})
    {
        DeleteSnow(playerid);
        SendClientMessage(playerid, COLOR_RED, "* It's not snowing anymore now.");
    }
    else
    {
        CreateSnow(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "* Let it snow, let it snow, let it snow!");
    }
    return 1;
}

CMD:hat(playerid,params[])
{
	new hat;
	if(sscanf(params,"i",hat)) return SendClientMessage(playerid,COLOR_RED,"Usage: /hat [0/1]");
	if(hat < 0 || hat > 1) return SendClientMessage(playerid,COLOR_RED,"Invalid value");
	GiveChristmasHat(playerid,hat);
	SendClientMessage(playerid,COLOR_ORANGE,"You've now a(n other) christmashat.");
	return 1;
}

CMD:christmasmusic(playerid,params[])
{
	ShowPlayerDialog(playerid,DIALOG_CHRISTMASMUSIC,DIALOG_STYLE_LIST,"Christmas Songs:","Jose Feliciano - Feliz Navidad\nWe wish you a merry christmas\nJingle Bells\nDean Martin - Let it Snow\nMariah Carey - All I Want For Christmas Is You\nMichael Buble - White Christmas\nWham - Last Christmas\nTrain - Shake Up Christmas\nStop music","Play","Cancel");
	return 1;
}

CMD:cm(playerid,params[]) 	return cmd_christmasmusic(playerid,params);
CMD:cma(playerid,params[]) 	return cmd_christmasmusicall(playerid,params);

CMD:christmasmusicall(playerid,params[])
{
	ShowPlayerDialog(playerid,DIALOG_CHRISTMASMUSICALL,DIALOG_STYLE_LIST,"Christmas Songs:","Jose Feliciano - Feliz Navidad\nWe wish you a merry christmas\nJingle Bells\nDean Martin - Let it Snow\nMariah Carey - All I Want For Christmas Is You\nMichael Buble - White Christmas\nWham - Last Christmas\nTrain - Shake Up Christmas\nStop music","Play","Cancel");
	return 1;
}

CMD:christmas(playerid,params[])
{
	ShowPlayerDialog(playerid, DIALOG_CHRISTMAS, DIALOG_STYLE_MSGBOX,"[MV]_Christmas by Michael@Belgium","/hat - Attach a christmashat on your head. \n/snow - (Dis)able the snow \n/logo - (Dis)able the moving snowman\n/snowmini - Go to the snowball minigame\n/fw(2)help - Fireworks help\n/christmasmusic(all) /cm(a) - Stream popular christmas songs. \n/setnight - switches everyone to night","OK","");
	return 1;
}


CMD:snowmini(playerid,params[])
{
	if(Snow_F[playerid] == 0)
	{
	    ResetPlayerWeapons(playerid);
		Snow_F[playerid] = 1;
		Charged[playerid] = 0;
		Shoot[playerid] = 0;
		SetPlayerPos(playerid,-708.40002441,3796.19995117,9.69999981);
		new res22[256], iName[128];
		GetPlayerName(playerid,iName,sizeof(iName));
		format(res22,sizeof(res22),"{0088FF}Hey {FF0000}%s{0088FF}!\nYou've just started playing {15FF00}SnowBall Fight{0088FF} minigame.\nIn this minigame , your goal is to hit as many players,\nas you can , without being hit by them.\nTo throw an snowball press : {FF7B0F}AIM Key\n{FFFF0F}Good Luck! ",iName);
		ShowPlayerDialog(playerid,9944,DIALOG_STYLE_MSGBOX,"{FF0000}SnowBalls {FFFF00}Fight",res22,"Ok","");
	}
	else if(Snow_F[playerid] == 1)
	{
		Snow_F[playerid] = 0;
		SpawnPlayer(playerid);
	}
	return 1;
}

CMD:fwspawn(playerid, params[])
{
   new c, id, Float:h, hv, Float:w, Float:in;
   if (sscanf(params, "ififf",c,h,hv,w,in)) {
       SendClientMessage(playerid, 0xFFFFFFFF, "Usage: /fwspawn {COUNT} {HEIGHT} {HVAR} {WINDSPEED} {INTERVAL}");
       SendClientMessage(playerid, 0xFFFFFFFF, "Example: /fwspawn 20 50.0 20 30.0 1.0");
   }
   else {
        id = FindEmptySlot();
        if (id<0) SendClientMessage(playerid, 0xFFFFFFFF, "No free slot!");
        else {
    	    new Float:x, Float:y, Float:z, Float:a;
    	    GetPlayerPos(playerid,x,y,z);
    	    GetPlayerFacingAngle(playerid,a);
	        GetXYInFrontOfPosition(x,y,a,1.0);
	        batteries[id][pos][0] = x;
	        batteries[id][pos][1] = y;
	        batteries[id][pos][2] = z;
	        batteries[id][count] = c;
	        batteries[id][height] = h;
	        batteries[id][hvar] = hv;
	        batteries[id][windspeed] = w;
	        batteries[id][interval] = in;

	        batteries[id][inuse] = true;
            batteries[id][machine] = CreateObject(2780,x,y,z,0.0,0.0,0.0);
            new tmp[256];
            format(tmp,sizeof(tmp),"Machine created. Slot: %d", id);
            SendClientMessage(playerid, 0x55FF55FF, tmp);
        }
   }
   return 1;
}

CMD:fwfire(playerid, params[])
{
   new id;
   if (sscanf(params, "i",id) || id>sizeof(batteries) || id<0) SendClientMessage(playerid, 0xFFFFFFFF, "Usage: /fwfire {ID}");
   else {
	   batteries[id][timer] = SetTimerEx("machinetimer",GetSomeTime(id),false,"i",id);
       SendClientMessage(playerid, 0xFFFFFFFF, "Firework started.");
   }
   return 1;
}

CMD:fwfireall(playerid, params[])
{
   for (new i=0; i<sizeof(batteries); i++) {
       if (batteries[i][inuse]) {
	        batteries[i][timer] = SetTimerEx("machinetimer",GetSomeTime(i),false,"i",i);
       }
   }
   SendClientMessage(playerid, 0xFFFFFFFF, "All fireworks started.");
   return 1;
}

CMD:fwkill(playerid, params[])
{
   new id;
   if (sscanf(params, "i",id) || id>sizeof(batteries) || id<0) SendClientMessage(playerid, 0xFFFFFFFF, "Usage: /fwfire {ID}");
   else {
	   KillTimer(batteries[id][timer]);
	   batteries[id][inuse] = false;
	   DestroyObject(batteries[id][machine]);
       SendClientMessage(playerid, 0xFFFFFFFF, "Firework deleted.");
   }
   return 1;
}

CMD:fwkillall(playerid, params[])
{
   for (new i=0; i<sizeof(batteries); i++) {
       if (batteries[i][inuse]) {
    	   KillTimer(batteries[i][timer]);
    	   batteries[i][inuse] = false;
    	   DestroyObject(batteries[i][machine]);
       }
   }
   SendClientMessage(playerid, 0xFFFFFFFF, "All fireworks deleted.");
   return 1;
}

CMD:fwsave(playerid, params[])
{
    new filename[20],tmp[256];
    if (sscanf(params, "s",filename)) SendClientMessage(playerid, 0xFFFFFFFF, "Usage: /fwsave {NAME}");
    else {
        format(tmp,sizeof(tmp),"%s.firework",filename);
        new File:f = fopen(tmp,io_write);
        for (new i=0; i<sizeof(batteries); i++) {
            if (batteries[i][inuse]) {
                format(tmp, sizeof(tmp), "%f %f %f %d %f %d %f %f\r\n",
                                        batteries[i][pos][0],
                                        batteries[i][pos][1],
                                        batteries[i][pos][2],
                                        batteries[i][count],
                                        batteries[i][height],
                                        batteries[i][hvar],
                                        batteries[i][windspeed],
                                        batteries[i][interval]);
                fwrite(f, tmp);
            }
        }
        fclose(f);
        SendClientMessage(playerid, 0xFFFFFFFF, "Fireworks saved.");
    }
    return 1;
}


CMD:fwload(playerid, params[])
{
    new filename[20],tmp[256];
    if (sscanf(params, "s",filename)) SendClientMessage(playerid, 0xFFFFFFFF, "Usage: /fwload {NAME}");
    else
	{
        format(tmp,sizeof(tmp),"%s.firework",filename);
        if (!fexist(tmp)) SendClientMessage(playerid, 0xFFFFFFFF, "File not found!");
        else
		{
            new id;
            new File:f = fopen(tmp,io_read);
        	while(fread(f, tmp)) {
        	    id = FindEmptySlot();
        	    if (id<0) {
        	        SendClientMessage(playerid, 0xFFFFFFFF, "Out of slots...");
                    return 1;
        	    }
                batteries[id][inuse] = true;
                sscanf(tmp, "fffififf",
                             batteries[id][pos][0],
                             batteries[id][pos][1],
                             batteries[id][pos][2],
                             batteries[id][count],
                             batteries[id][height],
                             batteries[id][hvar],
                             batteries[id][windspeed],
                             batteries[id][interval]);
                batteries[id][machine] = CreateObject(2780,batteries[id][pos][0],batteries[id][pos][1],batteries[id][pos][2],0.0,0.0,0.0);

        	}
            fclose(f);
            SendClientMessage(playerid, 0xFFFFFFFF, "Fireworks loaded.");
        }
    }
    return 1;
}

CMD:setnight(playerid, params[])
{
    SetWorldTime(0);
    SendClientMessageToAll(0xDDDD11FF,"The world time has been changed to 0:00.");
    return 1;
}

CMD:fwhelp(playerid, params[])
{
	ShowPlayerDialog(playerid,DIALOG_CHRISTMASFW,DIALOG_STYLE_MSGBOX,"[MV]_Christmas - Fireworks","Fireworks Script Commands:\n/fwspawn - create a battery \n/fwfire - fire a single battery \n/fwkill - remove a single battery \n/fwfireall - fire all batteries \n/fwkillall - remove all batteries \n/fwsave - save/overwrite all current batteries \n/fwload - load a file","OK","");
	return 1;
}

//------------------------------------------------------------------------------
stock GiveChristmasHat(playerid,number)
{
	switch(number)
	{
		case HAT_TYPE_1:
		{
		    RemovePlayerAttachedObject(playerid,1);
		    SetPlayerAttachedObject(playerid, 1, 19065, 15, -0.025, -0.04, 0.23, 0, 0, 270, 2, 2, 2);
		}
		case HAT_TYPE_2:
		{
			RemovePlayerAttachedObject(playerid,1);
			SetPlayerAttachedObject(playerid, 1, 19065, 2, 0.120000, 0.040000, -0.003500, 0, 100, 100, 1.4, 1.4, 1.4);
		}
	}
}
forward UpdateSnow(playerid);
public UpdateSnow(playerid)
{
    if(!snowOn{playerid}) return 0;
    new Float:pPos[3];
    GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
    Loop(i,MAX_SNOW_OBJECTS) SetObjectPos(snowObject[playerid][i], pPos[0] + random(25), pPos[1] + random(25), pPos[2] - 5);
    return 1;
}

stock CreateSnow(playerid)
{
    if(snowOn{playerid}) return 0;
    new Float:pPos[3];
    GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
    Loop(i,MAX_SNOW_OBJECTS) snowObject[playerid][i] = CreateObject(18864, pPos[0] + random(25), pPos[1] + random (25), pPos[2] - 5, random(100), random(100), random(100));
    snowOn{playerid} = true;
    updateTimer{playerid} = SetTimerEx("UpdateSnow", SNOW_UPDATE_INTERVAL, true, "i", playerid);
    return 1;
}

stock DeleteSnow(playerid)
{
    if(!snowOn{playerid}) return 0;
    Loop(i,MAX_SNOW_OBJECTS) DestroyObject(snowObject[playerid][i]);
    KillTimer(updateTimer{playerid});
    snowOn{playerid} = false;
    return 1;
}

stock CreateChristmasTree(type, Float:X, Float:Y, Float:Z)
{
	switch(type)
	{
	    case TREE_TYPE_BIG:
	    {
			CreateObject(3472,X+0.28564453,Y+0.23718262,Z+27.00000000,0.00000000,0.00000000,230.48021);
			CreateObject(664,X+0.20312500,Y+0.01171875,Z+-3.00000000,0.00000000,0.00000000,0.00000000);
			CreateObject(3472,X+0.45312500,Y+0.51562500,Z+4.00000000,0.00000000,0.00000000,69.7851562);
			CreateObject(3472,X+0.65136719,Y+1.84570312,Z+17.00000000,0.00000000,0.00000000,41.863403);
			CreateObject(7666,X+0.34130859,Y+0.16845703,Z+45.00000000,0.00000000,0.00000000,298.12524);
			CreateObject(7666,X+0.34082031,Y+0.16796875,Z+45.00000000,0.00000000,0.00000000,27.850342);
			CreateObject(3472,X+0.45312500,Y+0.51562500,Z+12.00000000,0.00000000,0.00000000,350.02441);
			CreateObject(3472,X+0.45312500,Y+0.51562500,Z+7.00000000,0.00000000,0.00000000,30.0805664);
			CreateObject(3472,X+0.45312500,Y+0.51562500,Z+22.00000000,0.00000000,0.00000000,230.47119);
			CreateObject(1262,X+0.15039062,Y+0.57128906,Z+29.45285416,0.00000000,0.00000000,162.90527);
		}
		case TREE_TYPE_SMALL:
		{
			Loop(i,sizeof(Treepos))
		    {
		        if(Treepos[i][XmasTreeX] == 0)
		        {
		            Treepos[i][XmasTreeX]=1;
		            Treepos[i][XmasX]=X;
		            Treepos[i][XmasY]=Y;
		            Treepos[i][XmasZ]=Z;
		            Treepos[i][XmasObject][0] = CreateObject(19076, X, Y, Z-1.0,0,0,300);
		            Treepos[i][XmasObject][1] = CreateObject(19054, X, Y+1.0, Z-0.4,0,0,300);
		            Treepos[i][XmasObject][2] = CreateObject(19058, X+1.0, Y, Z-0.4,0,0,300);
		            Treepos[i][XmasObject][3] = CreateObject(19056, X, Y-1.0, Z-0.4,0,0,300);
		            Treepos[i][XmasObject][4] = CreateObject(19057, X-1.0, Y, Z-0.4,0,0,300);
		            Treepos[i][XmasObject][5] = CreateObject(19058, X-1.5, Y+1.5, Z-1.0,0,0,300);
		            Treepos[i][XmasObject][6] = CreateObject(19055, X+1.5, Y-1.5, Z-1.0,0,0,300);
		            Treepos[i][XmasObject][7] = CreateObject(19057, X+1.5, Y+1.5, Z-1.0,0,0,300);
		            Treepos[i][XmasObject][8] = CreateObject(19054, X-1.5, Y-1.5, Z-1.0,0,0,300);
		            Treepos[i][XmasObject][9] = CreateObject(3526, X, Y, Z-1.0,0,0,300);
		            break;
		        }
		    }
		}
		case 3:
		{
			CreateObject(19076, X, Y, Z,   0.00, 0.00, 0.00);
			CreateObject(19054, X+0.37, Y+2.38, Z,   0.00, 0.00, 0.00);
			CreateObject(19055, X-1.18, Y-1.18, Z,   0.00, 0.00, 0.00);
			CreateObject(19056, X+1.94, Y-1.34, Z,   0.00, 0.00, 0.00);
			CreateObject(19057, X+1.67, Y+1.52, Z,   0.00, 0.00, 0.00);
		}
	}
}

stock CreateChristmasLights(Float:x, Float:y, Float:z)
{
	CreateObject(3472, x,y,z,0,0,300);
	CreateObject(3472, x,y,z+4,0,0,300);
}

stock LoadMetasTextdraws()
{
    NYCounter[0] = TextDrawCreate(316.399780, 0.995545, "_");
	TextDrawLetterSize(NYCounter[0], 0.293599, 1.510400);
	TextDrawAlignment(NYCounter[0], 2);
	TextDrawColor(NYCounter[0], -1);
	TextDrawSetShadow(NYCounter[0], 0);
	TextDrawSetOutline(NYCounter[0], 1);
	TextDrawBackgroundColor(NYCounter[0], 51);
	TextDrawFont(NYCounter[0], 1);
	TextDrawSetProportional(NYCounter[0], 1);

	NYCounter[1] = TextDrawCreate(394.000000, 1.500000, "usebox");
	TextDrawLetterSize(NYCounter[1], 0.000000, 5.158888);
	TextDrawTextSize(NYCounter[1], 242.000000, 0.000000);
	TextDrawAlignment(NYCounter[1], 1);
	TextDrawColor(NYCounter[1], 0);
	TextDrawUseBox(NYCounter[1], true);
	TextDrawBoxColor(NYCounter[1], 102);
	TextDrawSetShadow(NYCounter[1], 0);
	TextDrawSetOutline(NYCounter[1], 0);
	TextDrawFont(NYCounter[1], 0);

    NYCounter[2] = TextDrawCreate(340.000000, 350.000000, "~>~ HAPPY NEW YEAR ~<~~n~~y~"NEXT_YEAR"!");
    TextDrawAlignment(NYCounter[2], 2);
    TextDrawBackgroundColor(NYCounter[2], 255);
    TextDrawFont(NYCounter[2], 1);
    TextDrawLetterSize(NYCounter[2], 1.000000, 4.000000);
    TextDrawColor(NYCounter[2], 16777215);
    TextDrawSetOutline(NYCounter[2], 1);
	TextDrawSetProportional(NYCounter[2], 1);

    s_Timer[0] = SetTimer("CounterTimer", 400, true);
    return 1;
}

forward CounterTimer();
public CounterTimer()
{
    new string[150];
    new year, month, day, hour, minute, second;
    getdate(year, month, day);
    gettime(hour, minute, second);
    if(month == 1 && day == 1)
    {
        TextDrawHideForAll(NYCounter[0]);
        TextDrawShowForAll(NYCounter[2]);
        KillTimer(s_Timer[0]);
    }
    else
    {
        //gettime(hour, minute, second);

        new day2;
        switch(month)
        {
            case 1, 3, 5, 7, 8, 10, 12: day2 = 31;
            case 2: { if(year%4 == 0) { day2 = 29; } else { day2 = 28; } }
            case 4, 6, 9, 11: day2 = 30;
        }
        month = 12 - month;
        day = day2 - day;
        hour = 24 - hour;
		if(hour == 24) { hour = 0; }
		if(minute != 0) { hour--; }
        minute = 60 - minute;
		if(minute == 60) { minute = 0; }
		if(second != 0) { minute--; }
        second = 60 - second;
		if(second == 60) { second = 0; }

        format(string, sizeof(string), "~p~%02d ~w~month(s), ~p~%02d ~w~day(s)~n~~p~%02d ~w~hour(s), ~p~%02d ~w~min, ~p~%02d ~w~secs~n~~y~untill %s", month, day, hour, minute, second, NEXT_YEAR);

        TextDrawHideForAll(NYCounter[0]);
        TextDrawSetString(NYCounter[0], string);
        TextDrawShowForAll(NYCounter[0]);
    }
    return 1;
}

forward CheckSnow(playerid);
public CheckSnow(playerid)
{
	Shoot[playerid] = 0;
	Loop(i,30)
	{
		new Float:X, Float:Y;
		GetXYInFrontOfPlayer(playerid,X,Y,i);
	    Loop(z,GetMaxPlayers())
		{
			if(z != playerid && Shoot[playerid] == 0 && Killer[z] == 501)
			{
				if(IsPlayerInRangeOfPoint(z,1.0,X,Y,9.69999981))
				{
					Shoot[playerid] = 1;
					new Float:pX,Float:pY,Float:pZ,Float:tX,Float:tY,Float:tZ;
					GetPlayerPos(playerid,pX,pY,pZ);
					GetPlayerPos(z,tX,tY,tZ);
					Obj[z] = CreateObject(2709,pX,pY,pZ+0.5,0.0,0.0,0.0,30);
					MoveObject(Obj[z],tX,tY,tZ-0.9,25.0);
					SetPlayerHealth(z,0);
					Killer[z] = playerid;
					GameTextForPlayer(playerid,"~R~Target ~y~Shoot~B~!~N~~G~+ 500 ~p~Cash",1000,3);
					GivePlayerMoney(playerid,500);
					Charged[playerid] = 0;
				    ApplyAnimation(playerid,"GRENADE","WEAPON_throw",4.1,0,1,1,0,1000,1);
				}
			}
		}
	}
	if(Shoot[playerid] == 0) GameTextForPlayer(playerid,"~R~NO ~G~Targets~B~!",1000,1);
	return 1;
}

GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
    new Float:a;
    GetPlayerPos(playerid, x, y, a);
    GetPlayerFacingAngle(playerid, a);
    if (GetPlayerVehicleID(playerid))
    {
      GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
    }
    x += (distance * floatsin(-a, degrees));
    y += (distance * floatcos(-a, degrees));
}

//---------------------------FW-------------------------------------------------
stock FindEmptySlot()
{
    for (new i=0;i<sizeof(batteries);i++) {
        if (!batteries[i][inuse]) return i;
    }
    return -1;
}

stock GetSomeTime(id)
{
   return floatround((400 + random(300)) * batteries[id][interval]);
}


forward machinetimer(id);
public machinetimer(id)
{
    if (batteries[id][count]) {
		CreateFirework(batteries[id][pos][0],batteries[id][pos][1],batteries[id][pos][2],           //pos
                       batteries[id][height] - batteries[id][hvar]/2 + random(batteries[id][hvar]),   //height
                       random(360),batteries[id][windspeed],                                        //wind
                       50.0,                                                                        //speed
                       explosions[random(sizeof(explosions))],100.0);                               //explosion
        batteries[id][count]--;
        batteries[id][timer] = SetTimerEx("machinetimer",GetSomeTime(id),false,"i",id);
    } else {
        KillTimer(batteries[id][timer]);
        batteries[id][timer] = -1;
        batteries[id][inuse] = false;
	    DestroyObject(batteries[id][machine]);
    }
}
