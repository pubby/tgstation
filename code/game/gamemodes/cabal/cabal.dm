//Cabal Game Mode

/datum/game_mode
    var/list/datum/mind/cabal = list()
    var/list/datum/mind/cabal_leader = null

/proc/is_cabal_member(var/mob/living/M)
    return istype(M) && M.has_antag_datum(/datum/antagonist/cabal_member, TRUE)

/datum/game_mode/cabal
    name = "cabal"
    config_tag = "cabal"
    antag_flag = ROLE_CABAL
    restricted_jobs = list("AI", "Cyborg")
    protected_jobs = list("Security Officer", "Warden", "Detective", "Captain", "Head of Security")
    required_players = 0 // 10
    required_enemies = 1 // 3
    recommended_enemies = 3
    enemy_minimum_age = 7

    announce_span = "danger"
    announce_text = "A secretive cabal has infiltrated the station!\n\
    <span class='danger'>Cabal members</span>: Complete your objectives!\n\
    <span class='notice'>Crew</span>: Do not let the cabal succeed!"

/datum/game_mode/cabal/pre_setup()
    if(config.protect_roles_from_antagonist)
        restricted_jobs += protected_jobs

    if(config.protect_assistant_from_antagonist)
        restricted_jobs += "Assistant"

    if(antag_candidates.len < required_enemies)
        return FALSE

    cabal_leader = pick(antag_candidates)
    cabal_leader.special_role = "Cabal Leader"
    cabal_leader.restricted_roles = restricted_jobs

    antag_candidates -= cabal_leader

    log_game("[cabal_leader.key] has been selected as the Cabal Leader")

    return TRUE

var/list/cabal_job_groups = list(engineering_positions, medical_positions, science_positions, supply_positions, civilian_positions)

/datum/game_mode/cabal/post_setup()
    var/list/cabal_candidates
    var/list/members_to_member = list(cabal_leader)

    for(var/datum/mind/candidate in antag_candidates)
        if(cabal_leader.assigned_role == candidate.assigned_role)
            cabal_candidates[candidate] = 20
            antag_candidates -= candidate

    for(var/datum/mind/candidate in antag_candidates)
        for(var/list/job_group in cabal_job_groups)
            if(cabal_leader.assigned_role in job_group && candidate.assigned_role in job_group)
                cabal_candidates[candidate] = 10
                antag_candidates -= candidate
                break

    for(var/i = 1 to required_enemies - 1)
        var/datum/mind/candidate = pickweight(cabal_candidates)
        cabal_candidates -= candidate
        members_to_member += candidate

    spawn(10)
        for(var/datum/mind/cabal_member in members_to_member)
            equip_cabal_member(cabal_member)
            cabal_member.current << "<span class='userdanger'>You are a member of the cabal!</span>"
            add_cabal_member(cabal_member)
    ..()

/datum/game_mode/proc/equip_cabal_member(mob/living/carbon/human/mob)
    if (istype(mob) && mob.mind && mob.mind.assigned_role == "Clown")
        mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
        mob.dna.remove_mutation(CLOWNMUT)

/datum/game_mode/proc/update_cabal_icons_added(datum/mind/cabal_mind)
    var/datum/atom_hud/antag/cabalhud = huds[ANTAG_HUD_CABAL]
    cabalhud.join_hud(cabal_mind.current)
    set_antag_hud(cabal_mind.current, "cabal")

/datum/game_mode/proc/update_cabal_icons_removed(datum/mind/cabal_mind)
    var/datum/atom_hud/antag/cabalhud = huds[ANTAG_HUD_CABAL]
    cabalhud.leave_hud(cabal_mind.current)
    set_antag_hud(cabal_mind.current, null)

/datum/game_mode/proc/add_cabal_member(datum/mind/member_mind)
    if(!istype(member_mind))
        return FALSE
    if(member_mind.current.gain_antag_datum(/datum/antagonist/cabal_member))
        return TRUE

