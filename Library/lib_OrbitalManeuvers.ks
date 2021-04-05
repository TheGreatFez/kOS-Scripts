@lazyGlobal OFF.

global orbitManLib to ({
	local function Circularize_AP {
        local u to ship:body:MU.
        local e to ship:orbit:eccentricity.
        local a to ship:orbit:semimajoraxis.
        local Rp to ship:body:radius + apoapsis.
        local V_ap to sqrt(((1-e)*u)/((1+e)*a)).

        local Vcir_pe to sqrt(u/(Rp)).
        local DeltaV to Vcir_pe- V_ap.
        local circ_pe_node to NODE(time:seconds + eta:apoapsis,0,0,DeltaV).
        add circ_pe_node.
	}

    local function Circularize_PE {
        local u to ship:body:MU.
        local e to ship:orbit:eccentricity.
        local a to ship:orbit:semimajoraxis.
        local Rp to ship:body:radius + periapsis.

        local V_pe to 0.

        if e >= 1 {
            set V_pe to sqrt(u*((2/(Rp))-(1/a))).
            }
        if e < 1 {
            set V_pe to sqrt(((1+e)*u)/((1-e)*a)).
            }

        local Vcir_pe to sqrt(u/(Rp)).
        local DeltaV to Vcir_pe- V_pe.
        local circ_pe_node to NODE(time:seconds + eta:periapsis,0,0,DeltaV).
        add circ_pe_node.
	}

	return lexicon(
		"Circularize_AP", Circularize_AP@,
        "Circularize_PE", Circularize_PE@
	).

}):call().