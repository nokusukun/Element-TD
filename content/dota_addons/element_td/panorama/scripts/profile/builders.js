function AnimateBuildersSpawn() {
    $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "LightBuilder", "donkey", "SetAnimation", "spawn");
    $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "DarkBuilder", "rex", "SetAnimation", "courier_spawn");
    $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "WaterBuilder", "puppey", "SetAnimation", "spawn");
    $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "FireBuilder", "hellsworn", "SetAnimation", "golem_spawn");
    //$.DispatchEvent("DOTAGlobalSceneFireEntityInput", "NatureBuilder", "otter", "SetAnimation", "spawn");
    $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "EarthBuilder", "armadillo", "SetAnimation", "spawn");
}

var names = {}
names["LightBuilder"] = "donkey"
names["DarkBuilder"] = "rex"
names["WaterBuilder"] = "puppey"
names["FireBuilder"] = "hellsworn"
names["NatureBuilder"] = "otter"
names["EarthBuilder"] = "armadillo"

var hover_anims = {}
hover_anims["LightBuilder"] = "run"
hover_anims["DarkBuilder"] = "courier_run"
hover_anims["WaterBuilder"] = "greet"
hover_anims["FireBuilder"] = "golem_attack2"
hover_anims["NatureBuilder"] = "run"
hover_anims["EarthBuilder"] = "victory"

var idle_anims = {}
idle_anims["LightBuilder"] = "idle"
idle_anims["DarkBuilder"] = "courier_idle"
idle_anims["WaterBuilder"] = "capture_idle"
idle_anims["FireBuilder"] = "golem_idle"
idle_anims["NatureBuilder"] = "capture_idle_head_turn"
idle_anims["EarthBuilder"] = "idle_standing"

function AnimateBuilderHover(id) {
    $.DispatchEvent("DOTAGlobalSceneFireEntityInput", id, names[id], "SetAnimation", hover_anims[id]);
}

function AnimateBuilderIdle(id) {
    $.DispatchEvent("DOTAGlobalSceneFireEntityInput", id, names[id], "SetAnimation", idle_anims[id]);
}

function Hovering(name) {
    if (!bHasPass) return

    var panel = $("#"+name)
    panel.AddClass("Hovering")
    panel.hovering = true
}

function HoverOut(name) {
    var panel = $("#"+name)

    var hero =  Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
    var heroName = Entities.GetUnitName(hero)

    if (panel && name != backgrounds[heroName])
    {
        panel.RemoveClass("Hovering")
        panel.hovering = undefined
    }
}

function ChooseBuilder(heroName) {
    if (!bHasPass) return

    GameEvents.SendCustomGameEventToServer( "player_choose_custom_builder", { "hero_name": heroName } );
    CloseCustomBuilders()
    HoverAllOut()
}

var backgrounds = {}
backgrounds["npc_dota_hero_skywrath_mage"] = "LightBackground"
backgrounds["npc_dota_hero_faceless_void"] = "DarkBackground"
backgrounds["npc_dota_hero_mirana"] = "WaterBackground"
backgrounds["npc_dota_hero_warlock"] = "FireBackground"
backgrounds["npc_dota_hero_lone_druid"] = "NatureBackground"
backgrounds["npc_dota_hero_earthshaker"] = "EarthBackground"

function HighlightSelectedBuilder () {
    var hero =  Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
    var heroName = Entities.GetUnitName(hero)

    $.Schedule(1, HighlightSelectedBuilder)
    
    bHasPass = GameUI.PlayerHasProfile(Game.GetLocalPlayerID())
    if (!bHasPass) return

    for (var name in backgrounds)
    {
        if (name == heroName)
            Hovering(backgrounds[name])
        else
        {
            var panel = $("#"+backgrounds[name])
            if (panel && ! panel.hovering)
                HoverOut(backgrounds[name])
        }
    }
}

function HoverAllOut() {
    for (var name in backgrounds)
    {
        var panel = $("#"+backgrounds[name])
        if (panel)
        {
            panel.RemoveClass("Hovering")
            panel.hovering = undefined
        }
    }
}

function ResetBuilder () {
    GameEvents.SendCustomGameEventToServer( "player_reset_builder", {} );
    CloseCustomBuilders()
    HoverAllOut()
}

$.Schedule(1, HighlightSelectedBuilder)
var bHasPass = GameUI.PlayerHasProfile(Game.GetLocalPlayerID())