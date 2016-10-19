/datum/antagonist/cabal_member
    prevented_antag_datum_type = /datum/antagonist/cabal_member
    some_flufftext = null

/datum/antagonist/cabal_member/Destroy()
    return ..()

/datum/antagonist/cabal_member/can_be_owned(mob/living/new_body)
    return ..()

/datum/antagonist/cabal_member/on_gain()
    if(ticker && ticker.mode && owner.mind)
        ticker.mode.cabal += owner.mind
        ticker.mode.update_cabal_icons_added(owner.mind)
        if(istype(ticker.mode, /datum/game_mode/cabal))
            var/datum/game_mode/cabal/C = ticker.mode
            // TODO
            //C.memorize_cabal_objectives(owner.mind)
    if(owner.mind)
        owner.mind.special_role = "cabal_member"
    owner.attack_log += "\[[time_stamp()]\] <span class='cult'>Has joined the cabal!</span>"
    ..()

/datum/antagonist/cabal_member/apply_innate_effects()
    owner.faction |= "cabal"
    ..()

/datum/antagonist/cabal_member/remove_innate_effects()
    owner.faction -= "cabal"
    ..()

/datum/antagonist/cabal_member/on_remove()
    if(owner.mind)
        owner.mind.wipe_memory()
        if(ticker && ticker.mode)
            ticker.mode.cabal -= owner.mind
            ticker.mode.update_cabal_icons_removed(owner.mind)
    owner << "<span class='userdanger'>An unfamiliar white light flashes through your mind, removing your memories of the cabal.</span>"
    owner.attack_log += "\[[time_stamp()]\] <span class='cult'>Has renounced the cabal life!</span>"
    if(!silent_update)
        owner.visible_message("<span class='big'>[owner] has renounced the cabal life!</span>")
    ..()
