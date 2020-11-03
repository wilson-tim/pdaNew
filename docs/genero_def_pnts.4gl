{
MODIFICATIONS
=============

22/09/95 BCB - Make sure hours and minutes from "0" to "9" are expressed
	as "00" to "09"

12/06/96 BCB - Suppress 'The item is due to occur today' window when default
	is from inspection list report back and AUTO_REPB_AUTO is Y.

}

database universe

globals
	"../UTILS/globals.4gl"

define
	m_defa				record like defa.*,
	m_defp_hdr			record like defp1.*,
	m_defp_dtl_na		record like defp2.*,
	m_defp_dtl_ca		record like defp3.*,
	m_defp_dtl_cb		record like defp4.*,
	vg_input_type		char(1),
	vg_pv_flag			smallint,			# when true use passed points 
	vg_mod_p_and_v_flag	smallint,
	vg_points			like defh.cum_points,
	vg_value			like defh.cum_value

function def_points(vl_contract_ref,
					vl_site_ref,
					vl_item_ref,
					vl_feature_ref,
					vl_trans_date,
					vl_default_level,
					vl_default_occ,
					vl_default_reason,
					vl_default_algorithm,
					vl_priority,
					vl_default_sublevel,
					vl_notice_type,
					vl_volume,
					vl_pv_flag,
					vl_points,
					vl_value,
					vl_input_type)

	define
		vlr_defi_rect			record like defi_rect.*,
		vl_service				like cont.service_c,
		vl_site_ref				like defh.site_ref,
		vl_contract_ref			like defh.contract_ref,
		vl_points				like defh.cum_points,
		vl_value				like defh.cum_value,
		vl_item_ref				like defi.item_ref,
		vl_feature_ref			like defi.feature_ref,
		vl_volume				like defi.volume,
		vl_default_reason		like defi.default_reason,
		vl_default_sublevel		like defp.sublevel,
		vl_default_algorithm	like defp.default_algorithm,
		vl_priority				like defp.priority,
		vl_default_level		like deft.default_level,
		vl_trans_date			like deft.trans_date,
		vl_notice_type			like defa.notice_rep_no,
		vl_default_occ			like deft.default_occ,
		vl_input_type			char(1),
		vl_int_flag,			smallint,
		vl_pv_flag				smallint,		# True use points passed
		vl_work_week 	        like ww.work_week

{ ADJ Debug:
display "vl_contract_ref:", vl_contract_ref
display	"vl_site_ref:", vl_site_ref
display	"vl_item_ref:", vl_item_ref
display	"vl_feature_ref:", vl_feature_ref
display "vl_trans_date:", vl_trans_date
display	"vl_default_level:", vl_default_level
display	"vl_default_occ:", vl_default_occ
display	"vl_default_reason:", vl_default_reason
display	"vl_default_algorithm:", vl_default_algorithm
display	"vl_priority:", vl_priority
display	"vl_default_sublevel:", vl_default_sublevel
display	"vl_notice_type:", vl_notice_type
display	"vl_volume:", vl_volume
display	"vl_pv_flag:", vl_pv_flag
display	"vl_points:", vl_points
display	"vl_value:", vl_value
display	"vl_input_type:", vl_input_type
} # ADJ DEBUG

	let vg_pv_flag = vl_pv_flag
	let vg_input_type = vl_input_type
	let vg_points = vl_points
	let vg_value = vl_value
	let vr_defi.volume = vl_volume
	let vl_int_flag = false

	select service_c
		into vl_service
	from cont
		where contract_ref = vl_contract_ref

	call check_and_create_key(vl_service)

	if skey_check("DEF_ALG", vl_service) = "N"
	then
		if not vl_pv_flag
		then
			call prompt_for_points_value()
				returning vl_points
		end if
		if vl_default_occ is null
		then
			let vl_default_occ = 0
		end if
		if vl_default_level is null
		then
			let vl_default_level = 0
		end if
		let vl_default_occ = vl_default_occ + 1
		let vl_default_level = vl_default_level + 1
		return vl_points,
			vl_value,
			vl_default_level,
			vl_default_occ,
			vl_default_algorithm,
			vl_default_sublevel,
			"",
			"",
			"",
			vg_mod_p_and_v_flag
	end if

# 	ADJ 11/08/2005 The "NEW_ALG" method should always be used
#	if skey_check("NEW_ALG", vl_service) = "Y"
#	then
		call new_algorithm(vl_contract_ref,
						vl_site_ref,
						vl_item_ref,
						vl_feature_ref,
						vl_trans_date,
						vl_default_level,
						vl_default_occ,
						vl_default_reason,
						vl_default_algorithm,
						vl_priority,
						vl_notice_type,
						vl_volume)
			returning vl_points,
					vl_value,
					vl_default_level,
					vl_default_occ,
					vl_default_algorithm,
					vl_default_sublevel
		select *
			into m_defa.*
		from defa
			where item_type = m_defp_hdr.item_type
			and notice_rep_no = vl_notice_type
			and default_algorithm = vl_default_algorithm
		let vlr_defi_rect.rectify_date = today
		call get_time()
			returning vlr_defi_rect.rectify_time_h,
					vlr_defi_rect.rectify_time_m
		let vr_defp.time_delay = m_defp_dtl_cb.time_delay
		call get_correct_by_dates(vr_defp.*,
								vlr_defi_rect.rectify_date,
								vlr_defi_rect.rectify_time_h,
								vlr_defi_rect.rectify_time_m,
								vl_item_ref)
			returning vlr_defi_rect.rectify_date,
					vlr_defi_rect.rectify_time_h,
					vlr_defi_rect.rectify_time_m
		let vlr_defi_rect.item_ref = vl_item_ref
		let vlr_defi_rect.feature_ref = vl_feature_ref

#		if m_defa.change_alg_yn = "Y" and # BJG 19/1/2007 - Bob says this is NOT
#                                         to be included in the test.
		if
			(m_defa.prompt_for_points = "Y" 
			or m_defa.prompt_for_value = "Y"
			or m_defa.prompt_for_rectify = "Y")
		then
			let vg_mod_p_and_v_flag = true
			if vg_pv_flag
			then 
				let vl_points = vg_points
				let vl_value = vg_value
			else
				if vg_input_type = "A"
				then
					call mod_default_points_etc
						(vlr_defi_rect.*, vl_points, vl_value)
							returning vl_int_flag,
								vlr_defi_rect.rectify_date,
								vlr_defi_rect.rectify_time_h,
								vlr_defi_rect.rectify_time_m,
								vl_points,
								vl_value
				end if
			end if
		else
			let vg_mod_p_and_v_flag = false
		end if
		if vl_int_flag
		then
			return "", "", "", "", "", "", "", "", "", ""
		else
			if vlr_defi_rect.rectify_time_h[1] is null
			or vlr_defi_rect.rectify_time_h[1] = " "
			then
				let vlr_defi_rect.rectify_time_h[1] = "0"
			end if
			if vlr_defi_rect.rectify_time_h[2] is null
			or vlr_defi_rect.rectify_time_h[2] = " "
			then
				let vlr_defi_rect.rectify_time_h[2] =
					vlr_defi_rect.rectify_time_h[1]
				let vlr_defi_rect.rectify_time_h[1] = "0"
			end if
			if vlr_defi_rect.rectify_time_m[1] is null
			or vlr_defi_rect.rectify_time_m[1] = " "
			then
				let vlr_defi_rect.rectify_time_m[1] = "0"
			end if
			if vlr_defi_rect.rectify_time_m[2] is null
			or vlr_defi_rect.rectify_time_m[2] = " "
			then
				let vlr_defi_rect.rectify_time_m[2] =
					vlr_defi_rect.rectify_time_m[1]
				let vlr_defi_rect.rectify_time_m[1] = "0"
			end if
			return vl_points,
				vl_value,
				vl_default_level,
				vl_default_occ,
				vl_default_algorithm,
				vl_default_sublevel,
				vlr_defi_rect.rectify_date,
				vlr_defi_rect.rectify_time_h,
				vlr_defi_rect.rectify_time_m,
				vg_mod_p_and_v_flag
		end if
#	end if

	if vl_default_algorithm is not null
	then
		call get_def_rec(vl_contract_ref,
						vl_default_algorithm,
						vl_item_ref,
						vl_default_level,
						vl_default_occ,
						vl_default_sublevel,
						vl_priority)
	else
		call get_def_alg(vl_item_ref,
						vl_contract_ref,
						vl_notice_type,
						vl_priority,
						vl_default_level)
			returning vl_default_algorithm
		if vl_default_algorithm is not null
		then
			call get_def_rec(vl_contract_ref,
							vl_default_algorithm,
							vl_item_ref,
							vl_default_level,
							vl_default_occ,
							vl_default_sublevel,
							vl_priority)
		else
			let vl_points = 0
			let vl_value = 0
			return vl_points,
				vl_value,
				vl_default_level,
				vl_default_occ,
				vl_default_algorithm,
				vl_default_sublevel,
				"",			# rectify_date
				"",			# rectify_time_h
				"",			# rectify_time_m
				""
		end if
	end if

	if get_date_due(vl_trans_date,
					vl_item_ref,
					vl_site_ref,
					vl_feature_ref,
					vl_contract_ref)
	#ADJ! Ignore the fact that the si_i.date_due is today
	and skey_check("ALG_IGNORE_DATE_DUE", "ALL") = "N"
	then
		if vr_defp.action_next_ddate = "C"
		then
			call whats_happening_to_date_due()
				returning vr_defp.action_next_ddate
		end if

		case vr_defp.action_next_ddate
			when "C"
				let vl_default_level = 0
				let vl_default_occ = 0
				error " This item is due today ... it is now cleared "
				sleep 2

			when "D"
				call default_at_next_level(vl_site_ref,
										vl_item_ref,
										vl_feature_ref,
										vl_contract_ref,
										vl_trans_date,
										vl_default_level,
										vl_default_sublevel,
										vl_default_occ)
					returning vl_points,
							vl_value,
							vl_default_level,
							vl_default_sublevel,
							vl_default_occ

			when "R"
				call default_at_this_level(vl_trans_date,
										vl_item_ref,
										vl_site_ref,
										vl_feature_ref,
										vl_contract_ref,
										vl_default_occ,
										vl_points,
										vl_value)
					returning vl_points, vl_value, vl_default_occ
				if vl_default_level = 0
				or vl_default_level is null
				then
					let vl_default_level = 1
				end if
				if vl_default_occ = 0
				then
					let vl_default_level = 0
				end if

			otherwise
				error "this item is due today there is no next action"
				sleep 2
		end case
	else
		case vr_defp.next_action
			when "C"
				call default_it(vl_site_ref,
								vl_item_ref,
								vl_feature_ref,
								vl_contract_ref,
								vl_trans_date)
					returning vl_points, vl_value
				let vl_default_level = 0
				let vl_default_occ = 0
				error " This item is now cleared "
				sleep 2

			when "D"
				call default_at_next_level(vl_site_ref,
										vl_item_ref,
										vl_feature_ref,
										vl_contract_ref,
										vl_trans_date,
										vl_default_level,
										vl_default_sublevel,
										vl_default_occ)
					returning vl_points,
							vl_value,
							vl_default_level,
							vl_default_sublevel,
							vl_default_occ

			when "R"
				call default_at_this_level(vl_trans_date,
										vl_item_ref,
										vl_site_ref,
										vl_feature_ref,
										vl_contract_ref,
										vl_default_occ,
										vl_points,
										vl_value)
					returning vl_points, vl_value, vl_default_occ
				if vl_default_level = 0
				or vl_default_level is null
				then
					let vl_default_level = 1
				end if
				if vl_default_occ = 0
				then
					let vl_default_level = 0
				end if

			otherwise
				error "this item has no next action"
				sleep 2
		end case
	end if

	return vl_points,
		vl_value,
		vl_default_level,
		vl_default_occ,
		vl_default_algorithm,
		vl_default_sublevel,
		"",
		"",
		"",
		vg_mod_p_and_v_flag

end function


function default_at_next_level(vl_site_ref,
							vl_item_ref,
							vl_feature_ref,
							vl_contract_ref,
							vl_trans_date,
							vl_default_level,
							vl_default_sublevel,
							vl_default_occ)

	define
		vl_trans_date		like deft.trans_date,
		vl_item_ref			like defi.item_ref,
		vl_site_ref			like defh.site_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_points			like defh.cum_points,
		vl_value			like defh.cum_value,
		vl_default_level	like deft.default_level,
		vl_default_occ		like deft.default_occ,
		vl_default_sublevel	like deft.default_sublevel

	if vr_defp.max_occurs > vl_default_occ
	then
		call action_default_at_specified_level(vl_site_ref,
											vl_item_ref,
											vl_feature_ref,
											vl_default_occ,
											vl_contract_ref,
											vl_trans_date,
											vl_default_level,
											vl_default_sublevel)
			returning vl_points,
					vl_value,
					vl_default_sublevel,
					vl_default_level,
					vl_default_occ
	else
		call default_it(vl_site_ref,
						vl_item_ref,
						vl_feature_ref,
						vl_contract_ref,
						vl_trans_date)
			returning vl_points, vl_value

		if vl_default_level is null
		then
			let vl_default_level = 0
		end if

		let vl_default_level = vl_default_level + 1
	end if

	return vl_points,
		vl_value,
		vl_default_level,
		vl_default_sublevel,
		vl_default_occ

end function


function action_default_at_specified_level(vl_site_ref,
										vl_item_ref,
										vl_feature_ref,
										vl_default_occ,
										vl_contract_ref,
										vl_trans_date,
										vl_default_level,
										vl_default_sublevel)

	define
		vl_default_occ		like deft.default_occ,
		vl_trans_date		like deft.trans_date,
		vl_item_ref			like defi.item_ref,
		vl_site_ref			like defh.site_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_points			like defh.cum_points,
		vl_value			like defh.cum_value,
		vl_default_level	like deft.default_level,
		vl_default_sublevel	like defp.sublevel,
		vl_tmp_int,
		vl_count			smallint,
		vl_tmp_char			char(4)

	let vl_tmp_char = vr_defp.sublevel clipped, "?"
	let vl_tmp_int = vr_defp.default_level + 1

	select count(*)
		into vl_count
		from defp
		where default_algorithm = vr_defp.default_algorithm
		and contract_ref = vr_defp.contract_ref
		and item_type = vr_defp.item_type
		and default_level = vl_tmp_int
		and (sublevel matches vl_tmp_char
			or sublevel is null)

	if vl_count > 1
	then
		call another_decisive_pop_up(vl_default_sublevel, vl_default_level)
			returning vl_default_sublevel, vl_default_level

		call default_it(vl_site_ref,
						vl_item_ref,
						vl_feature_ref,
						vl_contract_ref,
						vl_trans_date)
			returning vl_points, vl_value
	else
		call default_at_this_level(vl_trans_date,
								vl_item_ref,
								vl_site_ref,
								vl_feature_ref,
								vl_contract_ref,
								vl_default_occ,
								vl_points,
								vl_value)
			returning vl_points, vl_value, vl_default_occ
	end if

	if vl_default_occ = 0
	then
		let vl_default_occ = 1
	end if

	if vl_default_level is null
	then
		let vl_default_level = 0
	end if

	let vl_default_level = vl_default_level + 1

	return vl_points,
		vl_value,
		vl_default_sublevel,
		vl_default_level,
		vl_default_occ

end function


function another_decisive_pop_up(vl_default_sublevel, vl_default_level)

	define
		va_sublevel			array [10] of record
			va_sub				char(4)
							end record,
		va_desc				array [10] of record
			desc1				char(60)
							end record,
		vl_default_level	like defp.default_level,
		vl_default_sublevel	like defp.sublevel,
		vl_cnt,
		vl_loop				smallint,
		vl_select			char(800),
		vl_choice3			char(1)


	open window iw_next_decision at 11,15 with form "def_opt"
#		attribute(border)

	let vl_loop = 1

	let vl_default_level = vr_defp.default_level + 1

	let vl_select = "select sublevel, default_desc from defp",
		" where contract_ref = ", "'", vr_defp.contract_ref, "'",
		" and item_type = ", "'", vr_defp.item_type, "'",
		" and default_level = ", vl_default_level,
		" and default_algorithm = ", "'", vr_defp.default_algorithm, "'",
		" and priority = ", "'", vr_defp.priority, "'"

	prepare ip_description from vl_select
	declare ic_description cursor for ip_description

	foreach ic_description into va_sublevel[vl_loop].va_sub,
								va_desc[vl_loop].desc1
		let vl_loop = vl_loop + 1
	end foreach

	let vl_loop = vl_loop - 1
	let vl_cnt = 1
	call set_count(vl_loop)

#	display "return key to accept cursor keys to choose" at 2,2

	display array va_desc to sa_desc.*
		on action cancel
			let vl_cnt = 0
			let int_flag = false
			exit display
	end display

	if vl_cnt > 0
	then
		let vl_cnt = arr_curr()
		let vl_default_sublevel = va_sublevel[vl_cnt].va_sub
	end if

	close window iw_next_decision

	return vl_default_sublevel, vl_default_level

end function


function default_at_this_level(vl_trans_date,
							vl_item_ref,
							vl_site_ref,
							vl_feature_ref,
							vl_contract_ref,
							vl_default_occ,
							vl_points,
							vl_value)

	define
		vl_default_occ		like deft.default_occ,
		vl_points			like defh.cum_points,
		vl_trans_date		like deft.trans_date,
		vl_item_ref			like defi.item_ref,
		vl_site_ref			like defh.site_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_value			like defh.cum_value

	if vr_defp.max_occurs > 1
	and vl_default_occ <= vr_defp.max_occurs
	then
		call default_it(vl_site_ref,
						vl_item_ref,
						vl_feature_ref,
						vl_contract_ref,
						vl_trans_date)
			returning vl_points, vl_value
		if vl_default_occ is null
		then
			let vl_default_occ = 0
		end if
		let vl_default_occ = vl_default_occ + 1
	else
		let vl_points = 0
		let vl_default_occ = 0
		let vl_value = 0
		error " could not re default this item"
		sleep 2
	end if

	return vl_points, vl_value, vl_default_occ

end function


function get_date_due(vl_trans_date,
					vl_item_ref,
					vl_site_ref,
					vl_feature_ref,
					vl_contract_ref)

	define
		vl_trans_date		like deft.trans_date,
		vl_item_ref			like defi.item_ref,
		vl_site_ref			like defh.site_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_contract_ref		like defh.contract_ref

	select date_due
		from si_i
		where item_ref = vl_item_ref
		and feature_ref = vl_feature_ref
		and contract_ref = vl_contract_ref
		and site_ref = vl_site_ref
		and date_due = vl_trans_date

	if status = notfound
	then
		return false
	else
		return true
	end if

end function


function get_def_alg(vl_item_ref,
					vl_contract_ref,
					vl_notice_type,
					vl_priority,
					vl_default_level)

	define
		vl_contract_ref		like si_i.contract_ref,
		vl_item_ref			like defi.item_ref ,
		vl_default_level	like deft.default_level,
		vl_priority			like defp.priority,
		vl_item_type		like item.item_type,
		vl_default_algorithm	like defp.default_algorithm,
		vl_notice_type		like defa.notice_rep_no,
		vl_count			smallint,
		f_prompt			char(1)

	select item_type
		into vl_item_type
		from item
		where item_ref = vl_item_ref
		and contract_ref = vl_contract_ref

	if vl_item_type = "MULTI"
	then
		call dis_def_alg(vl_item_type, vl_priority, vl_default_level)
			returning vl_default_algorithm
	else
		declare ic_def_alg cursor for
		select default_algorithm
			from defa
			where notice_rep_no = vl_notice_type
			and item_type = vl_item_type

		let vl_count = 0

		foreach ic_def_alg into vl_default_algorithm
			let vl_count = vl_count + 1
		end foreach

		if vl_count > 1
		then
			call dis_def_alg(vl_item_type, vl_priority, vl_default_level)
				returning vl_default_algorithm
		else
			if vl_count != 1
			then
				call prompt_ret_mess
			("No default algorithms for this item_type. Return to continue.")
				let int_flag = true
			end if
		end if
	end if

	return vl_default_algorithm
end function


function dis_def_alg(vl_item_type, vl_priority, vl_default_level)

	define
		vlr_def				array [30] of record
			default_algorithm	like defp.default_algorithm,
			default_desc		like defp.default_desc
							end record,
		vl_default_level	like deft.default_level,
		vl_item_type		like item.item_type,
		vl_priority			like defp.priority,
		vl_default_algorithm	like defp.default_algorithm,
		vl_loop,
		vl_cnt				smallint

	declare ic_def_algo cursor for
	select default_algorithm, default_desc
		from defp
		where item_type = vl_item_type
		and priority = vl_priority
		and default_level = vl_default_level
		order by default_desc

	open window iw_def_algo with form "def_alg"

#	display "SELECT DEFAULT ALGORITHM" at 1, 2 attribute(bold, reverse)

	let vl_loop = 1

	foreach ic_def_algo into vlr_def[vl_loop].*
		let vl_loop = vl_loop + 1
		if vl_loop > 30
		then
			exit foreach
		end if
	end foreach

	call set_count(vl_loop - 1)

	display array vlr_def to sa_defalg.*
		before row
			let vl_cnt = arr_curr()
			message "Algorithm ", vl_cnt using "<<<<&", " of ",
						vl_loop -1 using "<<<<&"

		on action cancel
			let int_flag = true
	end display

	let vl_cnt = arr_curr()
	let vl_default_algorithm = vlr_def[vl_cnt].default_algorithm

	close window iw_def_algo

	return vl_default_algorithm
end function


function get_def_rec(vl_contract_ref,
					vl_default_algorithm,
					vl_item_ref,
					vl_default_level,
					vl_default_occ,
					vl_default_sublevel,
					vl_priority)

	define
		vl_contract_ref		like defh.contract_ref,
		vl_item_ref			like defi.item_ref,
		vl_default_level	like deft.default_level,
		vl_default_occ		like deft.default_occ,
		vl_default_algorithm	like defp.default_algorithm,
		vl_priority			like defp.priority,
		vl_default_sublevel	like defp.sublevel,
		vl_item_type		like item.item_type,
		vl_service_c		like cont.service_c

	select service_c
		into vl_service_c
		from cont
		where contract_ref = vl_contract_ref

# 	ADJ 11/08/2005 The "NEW_ALG" method should always be used
#	if skey_check("NEW_ALG", vl_service_c) = "Y"
#	then
		if get_hdr(vl_default_algorithm,
				vl_default_level,
				vl_priority,
				vl_contract_ref,
				vl_item_ref)
		then
			call get_dtl_cb()

			let vr_defp.time_delay = m_defp_dtl_cb.time_delay
			let vr_defp.report_by_hrs1 = m_defp_dtl_cb.report_by_hrs1
			let vr_defp.report_by_hrs2 = m_defp_dtl_cb.report_by_hrs2
			let vr_defp.report_by_hrs3 = m_defp_dtl_cb.report_by_hrs3
			let vr_defp.report_by_mins1 = m_defp_dtl_cb.report_by_mins1
			let vr_defp.report_by_mins2 = m_defp_dtl_cb.report_by_mins2
			let vr_defp.report_by_mins3 = m_defp_dtl_cb.report_by_mins3

			let vr_defp.correct_by_hrs1 = m_defp_dtl_cb.correct_by_hrs1
			let vr_defp.correct_by_hrs2 = m_defp_dtl_cb.correct_by_hrs2
			let vr_defp.correct_by_hrs3 = m_defp_dtl_cb.correct_by_hrs3
			let vr_defp.correct_by_mins1 = m_defp_dtl_cb.correct_by_mins1
			let vr_defp.correct_by_mins2 = m_defp_dtl_cb.correct_by_mins2
			let vr_defp.correct_by_mins3 = m_defp_dtl_cb.correct_by_mins3
		end if
	{
	else
		select item_type
			into vl_item_type
			from item
			where item_ref = vl_item_ref
			and contract_ref = vl_contract_ref

		if vl_default_sublevel is null
		or vl_default_sublevel = "	"
		then
			select *
				into vr_defp.*
				from defp
				where item_type = vl_item_type
				and default_algorithm = vl_default_algorithm
				and priority = vl_priority
				and contract_ref = vl_contract_ref
				and default_level = vl_default_level
				and sublevel is null

			if status = notfound
			then
				error "No Default Processing record found for ",
					vl_default_algorithm, ",", vl_priority
				sleep 2
			end if
		else
			select *
				into vr_defp.*
				from defp
				where item_type = vl_item_type
				and default_algorithm = vl_default_algorithm
				and priority = vl_priority
				and contract_ref = vl_contract_ref
				and default_level = vl_default_level
				and sublevel = vl_default_sublevel

			if status = notfound
			then
				error "No Default Processing record found for ",
					vl_default_algorithm, ",", vl_priority
				sleep 2
			end if
		end if
	end if
	}

end function
												

function default_it(vl_site_ref,
					vl_item_ref,
					vl_feature_ref,
					vl_contract_ref,
					vl_trans_date)

	define
		vl_site_ref			like defh.site_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_item_ref			like defi.feature_ref,
		vl_trans_date		like deft.trans_date,
		vl_points			like defh.cum_points,
		vl_value			like defh.cum_value

	let vl_points = 0
	let vl_value = 0

	call def_points_value(vr_defp.val_volume,
						vr_defp.val_unit_flag,
						vr_defp.val_default_unit,
						vr_defp.val_unit_of_meas,
						vr_defp.val_task_rate,
						vr_defp.val_multiplier,
						vr_defp.val_static,
						vl_site_ref,
						vl_contract_ref,
						vl_item_ref,
						vl_feature_ref,
						vl_trans_date)
	returning vl_value

	call def_points_value(vr_defp.pnts_volume,
						vr_defp.pnts_unit_flag,
						vr_defp.pnts_default_unit,
						vr_defp.pnts_unit_of_meas,
						vr_defp.val_task_rate,
						vr_defp.pnts_multiplier,
						vr_defp.pnts_static,
						vl_site_ref,
						vl_contract_ref,
						vl_item_ref,
						vl_feature_ref,
						vl_trans_date)
	returning vl_points

	return vl_points, vl_value

end function


function def_points_value(vp_volume,
						vp_unit_flag,
						vp_default_unit,
						vp_unit_of_meas,
						vp_task_rate,
						vp_multiplier,
						vp_static,
						vl_site_ref,
						vl_contract_ref,
						vl_item_ref,
						vl_feature_ref,
						vl_trans_date)

	define
		vp_volume			like defp.val_volume,
		vp_unit_flag		like defp.val_unit_flag,
		vp_default_unit		like defp.val_default_unit,
		vp_unit_of_meas		like defp.val_unit_of_meas,
		vp_task_rate		like defp.val_task_rate,
		vl_task_rate		like ta_r.task_rate,
		vp_multiplier		like defp.val_multiplier,
		vp_static			like defp.val_static,
		vl_site_ref			like defh.site_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_item_ref			like defi.item_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_trans_date		like deft.trans_date,
		vl_volume,
		vl_subtotal,
		vl_gross_total		decimal(16,6)

	if vp_volume = "N"
	then
		let vl_volume = vr_defi.volume
	else
		select volume
			into vl_volume
			from si_f
			where site_ref = vl_site_ref
			and feature_ref = vl_feature_ref
	end if

	if vp_unit_flag = "Y"
	then
		select unit_of_meas
			into vp_default_unit
			from task
			where task_ref = (select task_ref
								from item
								where item_ref = vl_item_ref
								and contract_ref = vl_contract_ref)
	else			# use the real default_unit
		if vp_default_unit is not null
		then
			if vp_default_unit > 0
			then
				let vl_volume = round(vl_volume / vp_default_unit)
									* vp_default_unit
			else
				let vl_volume = 0
			end if
		else
			let vp_default_unit = 0
		end if
	end if

	if vp_unit_of_meas = "Y"
	and vp_default_unit
	then
		let vl_subtotal = vl_volume / vp_default_unit
	else
		let vl_subtotal = vl_volume
	end if

	if vp_task_rate = "Y"
	then
		select task_rate
			into vl_task_rate
			from ta_r
			where task_ref in (select task_ref
								from item
								where item_ref = vl_item_ref
								and contract_ref = vl_contract_ref)
			and contract_ref = vl_contract_ref
			and rate_band_code = "BUY"
			and contractor_ref in (select contractor_ref
									from cont
									where contract_ref = vl_contract_ref)
			and cont_cycle_no in (select cont_cycle_no from c_da
									where contract_ref = vl_contract_ref
									and period_start <= vl_trans_date
									and period_finish >= vl_trans_date)

		let vl_subtotal = vl_subtotal * vl_task_rate
	end if

	if vp_multiplier is not null
	then
		let vl_gross_total = vl_subtotal * vp_multiplier
	else
		let vl_gross_total = vl_subtotal
	end if

	if vp_static is not null
	then
		let vl_gross_total = vl_gross_total + vp_static
	end if
		
	if vl_gross_total is null
	then
		let vl_gross_total = vp_static
	end if

	return vl_gross_total

end function


function round(vl_tmp_dec)

	define
		vl_tmp_dec,
		vl_error_func		decimal(16,2),
		vl_tmp_int			integer

	let vl_tmp_int = vl_tmp_dec
	let vl_error_func = vl_tmp_int - vl_tmp_dec

	if vl_error_func = 0
	then
		return vl_tmp_int
	else
		let vl_tmp_int = vl_tmp_int + 1
		return vl_tmp_int
	end if

end function


function whats_happening_to_date_due()

	define
		vl_next_action		char(1)
		
	if skey_check("DEFS_HAPPENING_FLAG", "ALL") = "Y"
	then			# fully automated - take inspector's word for it
		let vl_next_action = "R"
	else			# behave exactly as before
		open window iw_action with form "what_to_do"
#			attributes(border,
#					form line first,
#					message line last,
#					comment line last)

		input vl_next_action from sa_action

			after input
				if vl_next_action = "C"
				then
					display "CLEARED" to action_desc
				else
					if vl_next_action = "D"
					then
						let vl_next_action = "R"
						display "DEFAULTED" to action_desc
					end if
				end if
				if vl_next_action is null
				then
					next field sa_action
				end if

		end input

		close window iw_action
      
	end if
	return vl_next_action
end function


function prompt_for_points_value()

	define
		vl_points			like deft.points

	open window iw_def_pnts with form "pnts"
#		attribute(border, bold)

	input vl_points from points

	close window iw_def_pnts

	return vl_points

end function


function new_algorithm(f_contract_ref,
					f_site_ref,
					f_item_ref,
					f_feature_ref,
					f_trans_date,
					f_default_level,
					f_default_occ,
					f_default_reason,
					f_default_algorithm,
					f_priority,
					f_notice_type,
					f_volume)

	define
		f_contract_ref		like cont.contract_ref,
		f_site_ref			like site.site_ref,
		f_feature_ref		like feat.feature_ref,
		f_default_level		like deft.default_level,
		f_default_occ		like deft.default_occ,
		f_default_reason	like defi.default_reason,
		f_default_algorithm	like defi.default_algorithm,
		f_priority			like deft.priority_flag,
		f_notice_type		like defa.notice_rep_no,
		f_points			like deft.points,
		f_value				like deft.value,
		f_item_ref			like defi.item_ref,
		f_item_status		like defi.item_status,
		f_volume			like defi.volume,
		f_trans_date		date,
		f_def_count			integer,
		f_month				smallint,
		f_change_flag		smallint

	let f_change_flag = false

	if can_the_algorithm_change(f_item_ref,
								f_contract_ref,
								f_notice_type,
								f_default_algorithm)
	and re_def_flag
	then
		call get__new_def_alg(f_item_ref,
							f_contract_ref,
							f_notice_type,
							f_priority,
							f_default_level)
			returning f_default_algorithm
		let f_change_flag = true
	end if

	if f_default_algorithm is null
	and not f_change_flag
	then
		call get__new_def_alg(f_item_ref,
							f_contract_ref,
							f_notice_type,
							f_priority,
							f_default_level)
			returning f_default_algorithm
	end if

#   ADJJJ
#	if f_default_level = 0
#	then
#		let f_default_level = 1
#	end if

	{ADJ Debug
	display "get_hdr()"
	display "f_default_algorithm: ", f_default_algorithm
	display "f_default_level: ", f_default_level
	display "f_priority: ", f_priority
	display "f_contract_ref: ", f_contract_ref
	display "f_item_ref: ", f_item_ref
	} #ADJ Debug
	if get_hdr(f_default_algorithm,
			f_default_level,
			f_priority,
			f_contract_ref,
			f_item_ref)
	then
		if m_defp_hdr.monthly = "Y"
		then

#Andy Jones (ADJ) Get the current month.....  
			let f_month = month(TODAY)

			select count(*) into f_def_count 
			from defi, defh
			where defi.default_algorithm = f_default_algorithm
			and defi.default_no = defh.cust_def_no
			and month(defh.start_date) = f_month
			if f_def_count >= m_defp_hdr.max_occ
			then
				let f_default_level = f_default_level + 1
				let f_default_occ = 0
			end if
		else
			if f_default_occ >= m_defp_hdr.max_occ
			then
				let f_default_level = f_default_level + 1
				let f_default_occ = 0
			end if
		end if

		if get_hdr(f_default_algorithm,
				f_default_level,
				f_priority,
				f_contract_ref,
				f_item_ref)
		then
			call get_dtl_na()
			call get_dtl_ca()
			call get_dtl_cb()
			call analyse_def_alg(f_site_ref,
								f_contract_ref,
								f_item_ref,
								f_feature_ref,
								f_default_level,
								f_default_occ,
								f_volume)
				returning f_default_level,
						f_default_occ,
						f_points,
						f_value,
						f_item_status
		else
			#ADJ WBCHSGV7
			let f_default_algorithm = null
			let f_item_status = "N"
		end if
	else
		#ADJ WBCHSGV7
		let f_default_algorithm = null
		let f_item_status = "N"
	end if

	if f_item_status = "N"
	then
		let f_default_level = 0
		let f_default_occ = 0
	end if
#	if f_item_status = "C"
#	then
#		let f_default_level = -99
#		let f_default_occ = -99
#	end if

	{ADJ Debug
	display "Algorithm Success!"
	display "f_points: ", f_points
	display "f_value: ", f_value
	display "f_default_level: ", f_default_level
	display "f_default_occ: ", f_default_occ
	display "f_default_algorithm: ", f_default_algorithm
	} #ADJ Debug

	return f_points,
		f_value,
		f_default_level,
		f_default_occ,
		f_default_algorithm,
		""

end function


function analyse_def_alg(f_site_ref,
						f_contract_ref,
						f_item_ref,
						f_feature_ref,
						f_default_level,
						f_default_occ,
						f_volume)

	define
		f_site_ref			like site.site_ref,
		f_item_ref			like item.item_ref,
		f_contract_ref		like cont.contract_ref,
		f_feature_ref		like feat.feature_ref,
		f_points			like deft.points,
		f_value				like deft.value,
		f_default_level		like deft.default_level,
		f_default_occ		like deft.default_occ,
		f_item_status		like defi.item_status,
		f_volume			like defi.volume

	if get_date_due(today,
					f_item_ref,
					f_site_ref,
					f_feature_ref,
					f_contract_ref)
	#ADJ! Ignore the fact that the si_i.date_due is today
	and skey_check("ALG_IGNORE_DATE_DUE", "ALL") = "N"
	then
		call whats_happening_to_date_due()
			returning vr_defp.action_next_ddate

		if vr_defp.action_next_ddate = "C"
		then
			let m_defp_dtl_na.and_clear = "Y"
		end if

		if vr_defp.action_next_ddate = "R"
		then
			let m_defp_dtl_na.and_clear = "N"
		end if

		if m_defp_dtl_na.and_clear = "Y"
		then
			#let f_item_status = "C" # item is clear
			let f_item_status = "N" # item is clear
		else
			let f_item_status = "Y"
		end if

		if m_defp_dtl_na.and_default = "Y"
		then
			if m_defp_hdr.last_level = "N"
			or not length(m_defp_hdr.last_level)
			then
				let f_default_level = f_default_level + 1
				let f_default_occ = 1
			else
				let f_default_occ = f_default_occ + 1
			end if

			call get_p_v(f_item_ref,
						f_site_ref,
						f_feature_ref,
						f_contract_ref,
						f_volume)
				returning f_points, f_value
		end if

		if m_defp_dtl_na.and_redeft = "Y"
		then
			let f_default_occ = f_default_occ + 1

			call get_p_v(f_item_ref,
						f_site_ref,
						f_feature_ref,
						f_contract_ref,
						f_volume)
				returning f_points, f_value
		end if
	else
		if m_defp_dtl_na.na_clear = "Y"
		then
			#let f_item_status = "C" # item is clear
			let f_item_status = "N" # item is clear
		else
			let f_item_status = "Y"
		end if

		if m_defp_dtl_na.na_default = "Y"
		then
			if m_defp_hdr.last_level = "N"
			or not length(m_defp_hdr.last_level)
			then
				let f_default_level = f_default_level + 1
				let f_default_occ = 1
			else
				let f_default_occ = f_default_occ + 1
			end if

			call get_p_v(f_item_ref,
						f_site_ref,
						f_feature_ref,
						f_contract_ref,
						f_volume)
				returning f_points, f_value
		end if

		if m_defp_dtl_na.na_redeft = "Y"
		then
			let f_default_occ = f_default_occ + 1

			call get_p_v(f_item_ref,
						f_site_ref,
						f_feature_ref,
						f_contract_ref,
						f_volume)
				returning f_points, f_value
		end if
	end if

	if f_default_level = 0
	then
		let f_default_level = 1
	end if

	return f_default_level, f_default_occ, f_points, f_value, f_item_status

end function


function get_hdr(f_default_algorithm,
				f_default_level,
				f_priority,
				f_contract_ref,
				f_item_ref)

	define
		f_default_algorithm	like defp.default_algorithm,
		f_default_level		like defp.default_level,
		f_priority			like defp.priority,
		f_contract_ref		like defp.contract_ref,
		f_item_ref			like item.item_ref,
		f_return			integer

	# ADJ
	if f_default_level = 0
	then
		let f_default_level = 1
	end if

	#ADJ Debug
	#display "f_default_level: ", f_default_level

	select *
		into m_defp_hdr.*
	from defp1
		where algorithm = f_default_algorithm
		and default_level = f_default_level
		and priority = f_priority
		and contract_ref = f_contract_ref
		and item_type in (select item_type
							from item
							where item_ref = f_item_ref
							and contract_ref = f_contract_ref)

	if status = notfound
	then
		#ADJ Debug
		#display "get_hdr() return false"
		let f_return = false
	else
		#ADJ Debug
		#display "get_hdr() return true"
		let f_return = true
	end if

	return f_return

end function


function get_dtl_na()

	select *
		into m_defp_dtl_na.*
		from defp2
		where defp2.next_action_id = m_defp_hdr.next_action_id

end function


function get_dtl_ca()

	select *
		into m_defp_dtl_ca.*
		from defp3
		where defp3.calc_id = m_defp_hdr.calc_id

end function


function get_dtl_cb()

	select *
		into m_defp_dtl_cb.*
		from defp4
		where defp4.cb_time_id = m_defp_hdr.cb_time_id

	let vr_defp_dtl_cb.* = m_defp_dtl_cb.*

end function


function get_p_v(f_item_ref,
				f_site_ref,
				f_feature_ref,
				f_contract_ref,
				f_volume)

	define
		f_item_ref			like item.item_ref,
		f_site_ref			like site.site_ref,
		f_feature_ref		like feat.feature_ref,
		f_contract_ref		like cont.contract_ref,
		f_points			like deft.points,
		f_value				like deft.value,
		f_task_ref			like task.task_ref,
		f_task_rate			like ta_r.task_rate,
		f_u_o_m				like defp3.d_u_o_m,
		f_volume			like si_f.volume,
		f_max_start_date	date

	if   m_defp_dtl_ca.std_cv         = "Y"
	and  m_defp_dtl_ca.std_val        = "Y"
	and	 m_defp_dtl_ca.fr_v_flag 	  = "Y"
	and	 m_defp_dtl_ca.multip_v_flag  = "Y"
	then
		let f_value = f_volume * m_defp_dtl_ca.multip_v
	else

	if m_defp_dtl_ca.si_i_vol = "Y"
	then
		select volume
			into f_volume
			from si_f
			where site_ref = f_site_ref
			and feature_ref = f_feature_ref
	end if

	if m_defp_dtl_ca.std_cv = "Y"
	then
		select task_ref
			into f_task_ref
			from item
			where item_ref = f_item_ref
			and contract_ref = f_contract_ref
	end if

	if m_defp_dtl_ca.d_u_o_m_flag = "Y"
	then
		let f_u_o_m = m_defp_dtl_ca.d_u_o_m
	else
		select unit_of_meas
			into f_u_o_m
			from task
			where task_ref = f_task_ref
	end if

	if m_defp_dtl_ca.std_cv = "Y"
	then
		if m_defp_dtl_ca.d_ta_r_flag = "N"
		then
			select task_rate
				into f_task_rate, f_max_start_date
				from ta_r
				where task_ref = f_task_ref
				and contract_ref = f_contract_ref
				and rate_band_code = "BUY"
				and start_date = (select max(start_date)
									from ta_r
									where task_ref = f_task_ref
									and contract_ref = f_contract_ref
									and start_date <= today)
		else
			let f_task_rate = m_defp_dtl_ca.d_ta_r
		end if

		let f_value = f_task_rate * f_volume / f_u_o_m
	else
		let f_value = 0
	end if

	if m_defp_dtl_ca.std_val = "Y"
	then
		let f_value = f_volume / f_u_o_m
	end if

	if m_defp_dtl_ca.multip_v_flag = "Y"
	then
		let f_value = f_value * m_defp_dtl_ca.multip_v
	end if

	if m_defp_dtl_ca.fr_v_flag = "Y"
	then
		let f_value = f_value + m_defp_dtl_ca.fr_v
	end if

	end if

	#ADJ

	if m_defp_dtl_ca.std_pnts = "Y"
	then
		let f_points = f_volume / f_u_o_m
	else
		let f_points = 0
	end if

	if m_defp_dtl_ca.fr_p_flag = "Y"
	then
		let f_points = f_points + m_defp_dtl_ca.fr_p
	end if

	if m_defp_dtl_ca.multip_p_flag = "Y"
	then
		let f_points = f_points * m_defp_dtl_ca.multip_p
	end if

	if m_defp_dtl_ca.rounding = "Y"
	then
		let f_points = round(f_points)
		let f_value = round(f_value)
	end if

	return f_points, f_value

end function



function dis__new_def_alg(vl_item_type,
						vl_priority,
						vl_default_level,
						vl_contract_ref,
						vl_notice_type)

	define
		vlr_def				array [30] of record
			default_algorithm	like defp1.algorithm,
			default_desc		like defp1.algorithm_desc
							end record,
		vl_default_level	like deft.default_level,
		vl_item_type		like item.item_type,
		vl_default_algorithm	like defp1.algorithm,
		vl_priority			like defp1.priority,
		vl_contract_ref		like defp1.contract_ref,
		vl_notice_type		like defa.notice_rep_no,
		vl_loop,
		vl_cnt				smallint,
		vl_mess				char(100)

	if vl_default_level = 0
	then
		let vl_default_level = 1
	end if

	if vl_notice_type not matches "Z" 
	then
		declare ic_def_algo2 cursor for
		select algorithm, algorithm_desc
			from defp1, defa
			where defp1.item_type = vl_item_type
			and defa.item_type = vl_item_type
			and defp1.priority = vl_priority
			and defp1.default_level = vl_default_level
			and defp1.contract_ref = vl_contract_ref
			and defa.notice_rep_no = vl_notice_type 
			and defp1.algorithm = defa.default_algorithm
			order by algorithm_desc

		let vl_loop = 1

		foreach ic_def_algo2 into vlr_def[vl_loop].*
			let vl_loop = vl_loop + 1
		end foreach

		call set_count(vl_loop - 1)
	else
		declare ic_def_alg22 cursor for
		select algorithm, algorithm_desc
			from defp1
			where item_type = vl_item_type
			and priority = vl_priority
			and default_level = vl_default_level
			and contract_ref = vl_contract_ref
			order by algorithm_desc

		let vl_loop = 1

		foreach ic_def_alg22 into vlr_def[vl_loop].*
			let vl_loop = vl_loop + 1
		end foreach

		call set_count(vl_loop - 1)
	end if

	if vl_loop - 1 < 1
	then
#		error "No Algorithms available."
		let vl_mess = "No Algorithms available for Item Type ",
							vl_item_type clipped, " Priority ",
							vl_priority clipped, " Default Level ",
							vl_default_level, " Contract ",
							vl_contract_ref
		call valid_error("",vl_mess,"")
		let int_flag = true
		initialize vl_default_algorithm to null
	else
		if vl_loop - 1 > 1
		then
			open window iw_def_algo with form "def_alg"
#				attribute(border, bold)

#			display "SELECT DEFAULT ALGORITHM" at 1, 2 attribute(bold, reverse)

			display array vlr_def to sa_defalg.*
				before row
					let vl_cnt = arr_curr()
					message "Algorithm ", vl_cnt using "<<<<&", " of ",
								vl_loop -1 using "<<<<&"

				on action cancel
					let int_flag = true
					exit display
			end display

			close window iw_def_algo

			if int_flag 
			then
				let int_flag = false
				return ""
			end if	

			let vl_cnt = arr_curr()

			let vl_default_algorithm = vlr_def[vl_cnt].default_algorithm
		else
			let vl_default_algorithm = vlr_def[1].default_algorithm
		end if
	end if

	return vl_default_algorithm
end function


function get_user_req()
	define
		f_flag				integer,
		f_action			char(1)

	let f_flag = true

	while f_flag
		prompt "This item has now reached it's maximum occurence.",
				" Default(D) or Clear(C)" for f_action

		if f_action matches "[CD]"
		then
			let f_flag = false
		else
			call valid_error("", "An action must specified", "")
		end if
	end while

	return f_action

end function


function check_and_create_key(f_service_c)

	define
		f_service_c			like cont.service_c,
		f_count				integer

	let f_count = 0

	select *
		from skop
		where keyname = "NEW_ALG"

	if status = notfound
	then
		insert into skop values("NEW_ALG", "C")
	end if

	select count(*)
		into f_count
		from keys
		where keyname = "NEW_ALG"
		and service_c = f_service_c

	if f_count = 0
	then
		insert into keys (service_c, keyname, keydesc, c_field)
			values(f_service_c,
				"NEW_ALG",
				"ARE YOU USING THE NEW ALG TABLES?",
				"N")
	end if

end function


function can_the_algorithm_change(f_item_ref,
								f_contract_ref,
								f_notice_rep_no,
								f_algorithm)

	define
		f_item_ref			like item.item_ref,
		f_item_type			like item.item_type,
		f_contract_ref		like item.contract_ref,
		f_notice_rep_no		like defa.notice_rep_no,
		f_algorithm			like defa.default_algorithm,
		ret_status			smallint

	initialize m_defa.change_alg_yn to null
	let ret_status = true

	select item_type
		into f_item_type
		from item
		where item_ref = f_item_ref
		and contract_ref = f_contract_ref

	select *
		into m_defa.*
		from defa
		where item_type = f_item_type
		and notice_rep_no = f_notice_rep_no
		and default_algorithm = f_algorithm

	if m_defa.change_alg_yn != "Y"
	then
		let ret_status = false
	end if

	return ret_status

end function	# can_the_algorithm_change


function mod_default_points_etc(vlr_defi_rect, vl_points, vl_value)
	define
		vlr_mod_vals		record
			item_ref			like defi_rect.item_ref,
			feature_ref			like defi_rect.feature_ref,
			rectify_date		like defi_rect.rectify_date,
			rectify_time_h		like defi_rect.rectify_time_h,
			rectify_time_m		like defi_rect.rectify_time_m,
			cum_points			like defi.cum_points,
			cum_value			like defi.cum_value
							end record,
		vlr_defi_rect		record like defi_rect.*,
		vl_points			like defi.cum_points,
		vl_value			like defi.cum_value,
		vl_max_points		integer,
		vl_valid_error		char(80),
		vl_rect_h_int,
		vl_rect_m_int		smallint,
		vl_time_h,
		vl_time_m			char(2)

	let vlr_mod_vals.item_ref = vlr_defi_rect.item_ref
	let vlr_mod_vals.feature_ref = vlr_defi_rect.feature_ref
	let vlr_mod_vals.rectify_date = vlr_defi_rect.rectify_date
	let vlr_mod_vals.rectify_time_h = vlr_defi_rect.rectify_time_h
	let vlr_mod_vals.rectify_time_m = vlr_defi_rect.rectify_time_m
	if length(vlr_mod_vals.rectify_time_m) = 1
	then
		let vlr_mod_vals.rectify_time_m = "0",  
			vlr_mod_vals.rectify_time_m clipped
	end if
	if length(vlr_mod_vals.rectify_time_h) = 1
	then
		let vlr_mod_vals.rectify_time_h = "0",
			vlr_mod_vals.rectify_time_h clipped
	end if
	let vlr_mod_vals.cum_points = vl_points
	let vlr_mod_vals.cum_value = vl_value

	options input wrap
	open window Wmod_vals at 6,22 with form "mod_vals"

	display by name vlr_mod_vals.item_ref 
	display by name vlr_mod_vals.feature_ref 

	input vlr_mod_vals.rectify_date,
			vlr_mod_vals.rectify_time_h,
			vlr_mod_vals.rectify_time_m,
			vlr_mod_vals.cum_points,
			vlr_mod_vals.cum_value without defaults from sr_mod_vals.*

		before field rectify_date
			if m_defa.prompt_for_rectify != "Y"
			then
				next field cum_points
			end if

		after field rectify_date
			if vlr_mod_vals.rectify_date < today
			then
				call valid_error("", "The date cannot be before today", "")
				next field rectify_date
			end if

		after field rectify_time_h
			whenever error continue
			let vl_rect_h_int = vlr_mod_vals.rectify_time_h
			if status != 0
			or vl_rect_h_int < 0
			or vl_rect_h_int > 23
			then
				whenever error stop
				error "Error in field"
				next field rectify_time_h
			end if
			whenever error stop

		after field rectify_time_m
			whenever error continue
			let vl_rect_m_int = vlr_mod_vals.rectify_time_m
			if status != 0
			or vl_rect_m_int < 0
			or vl_rect_m_int > 59
			then
				whenever error stop
				error "Error in field"
				next field rectify_time_m
			end if
			whenever error stop
			call get_time()
				returning vl_time_h, vl_time_m
			if vlr_mod_vals.rectify_date = today
			and (vlr_mod_vals.rectify_time_h < vl_time_h
				or (vlr_mod_vals.rectify_time_h = vl_time_h
					and vlr_mod_vals.rectify_time_m < vl_time_m))
			then
				call valid_error("",
					"The Date/Time cannot be before current time", "")
				next field rectify_date
			end if

		before field cum_points
			if m_defa.prompt_for_points != "Y"
			then
				next field cum_value
			end if

		after field cum_points
			let vl_max_points = skey_check("MAX_DEF_POINTS", "ALL")
			if vl_max_points
			then
				if vlr_mod_vals.cum_points > vl_max_points
				then
					let vlr_mod_vals.cum_points = vl_max_points
					display by name vlr_mod_vals.cum_points
					let vl_valid_error =
						"Points can not exceed ", vl_max_points using "<<<<<",
						" changed to ", vl_max_points using "<<<<<", "."
					call valid_error("", vl_valid_error, "")
				end if
			end if

		before field cum_value
			if m_defa.prompt_for_value != "Y"
			then
				next field rectify_date
			end if

		on action cancel
			if continue_yn("Abort New Rectification Entry")
			then
				let int_flag = true
				exit input
			end if

	end input

	close window Wmod_vals
	if int_flag
	then
		let int_flag = false
		return true, "", "", "", "", ""
	else	
		return false,
			vlr_mod_vals.rectify_date,
			vlr_mod_vals.rectify_time_h,
			vlr_mod_vals.rectify_time_m,
			vlr_mod_vals.cum_points,
			vlr_mod_vals.cum_value
	end if	
end function	# mod_default_points_etc


function get__new_def_alg(vl_item_ref,
						vl_contract_ref,
						vl_notice_type,
						vl_priority,
						vl_default_level)

	define
		vl_contract_ref		like si_i.contract_ref,
		vl_item_ref			like defi.item_ref ,
		vl_default_level	like deft.default_level,
		vl_priority			like defp.priority,
		vl_item_type		like defa.item_type,
		vl_notice_type		like defa.notice_rep_no,
		vl_default_algorithm	like defp.default_algorithm,
		vl_count			smallint

	select item_type
		into vl_item_type
		from item
		where item_ref = vl_item_ref
		and contract_ref = vl_contract_ref

	if vl_item_type matches "MULTI*"
	then
		call dis__new_def_alg(vl_item_type,
							vl_priority,
							vl_default_level,
							vl_contract_ref,
							vl_notice_type)
			returning vl_default_algorithm
	else
		declare ic_def_alg2 cursor for
		select default_algorithm
			from defa
			where notice_rep_no = vl_notice_type
			and item_type = vl_item_type

		let vl_count = 0

		foreach ic_def_alg2 into vl_default_algorithm
			let vl_count = vl_count + 1
		end foreach

		if vl_count > 1
		then
			call dis__new_def_alg(vl_item_type,
								vl_priority,
								vl_default_level,
								vl_contract_ref,
								"Z")
				returning vl_default_algorithm
		else
			if vl_count = 0
			then
				error "No algorithms found for this item type ", vl_item_type
			end if
		end if
	end if

	return vl_default_algorithm

end function

{------------------------------------------------------------------------------}
