# add_def.4gl "Version %I%"

database universe

globals "../UTILS/globals.4gl"

define
	vlr_defh			record 
			default_no			like defh.default_no,
			cust_def_no			like defh.cust_def_no,
			site_ref			like defh.site_ref,
			site_name_1			like site.site_name_1,
			site_name_2			like site.site_name_2,
			contract_ref		like defh.contract_ref,
			cum_points			like defh.cum_points,
			cum_value			like defh.cum_value,
			start_date			like defh.start_date,
			start_time_h		like defh.start_time_h,
			start_time_m		like defh.start_time_m,
			default_status		like defh.default_status,
			clear_flag			like defh.clear_flag
				end record,
	vlr_defi			record
			item_ref			like defi.item_ref,
			item_desc			like item.item_desc,
			next_date			like defi.next_date,
			feature_ref			like feat.feature_ref,
			feature_desc		like feat.feature_desc,
			default_reason		like defi.default_reason,
			default_desc		like allk.lookup_text,
			volume				like defi.volume,
			next_action			like defi.next_action,
			text_flag			like defi.text_flag,
			default_algorithm	like defi.default_algorithm,
			clear_date			like defi.clear_date,
			item_status			like defi.item_status
				end record,
	vlr_defi_rect		record
			rectify_date		like defi_rect.rectify_date,
			rectify_time_h		like defi_rect.rectify_time_h,
			rectify_time_m		like defi_rect.rectify_time_m
				end record,
	vlr_deft			record
			points				like deft.points,
			value				like deft.value,
			priority_flag		like deft.priority_flag,
			notice_type			like deft.notice_type,
			po_code				like deft.po_code,
			default_level		like deft.default_level,
			default_occ			like deft.default_occ,
			default_sublevel	like deft.default_sublevel,
			source_flag			like deft.source_flag,
			source_ref			like deft.source_ref,
			notice_ref			like deft.notice_ref
		end record,
	vg_p_and_v_flag,
	vg_auto_flag	smallint,
	vg_text_mode	char(1)


function add_default(vl_po_code,
					vl_source_flag,
					vl_source_ref,
					vl_start_date,
					vl_start_time_h,
					vl_start_time_m,
					vl_site_ref,
					vl_contract_ref,
					vl_item_ref,
					vl_feature_ref,
					vl_default_reason,
					vl_auto_flag)
	define
		vl_print_rec record
			item_ref		like item.item_ref,
			feature_ref		like feat.feature_ref,
			default_level	like deft.default_level,
			default_occ		like deft.default_occ
		end record,
		vl_site_ref			like site.site_ref,
		vl_contract_ref		like cont.contract_ref,
		vl_item_ref			like item.item_ref,
		vl_feature_ref		like feat.feature_ref,
		vl_source_flag		like deft.source_flag,
		vl_po_code			like deft.po_code,
		vl_source_ref		like deft.source_ref,
		vl_user				like diry.source_user,
		vl_default_reason	like defi.default_reason,
		vl_default_status	like defh.default_status,
		vl_device_name		like device_def.device_name,
		vl_device_str		like device_def.device_str,
		vl_start_date		date,
		vl_upd_flag			smallint,
		vl_commit_flag		smallint,
		vl_auto_flag		smallint,
		vl_vol_flag			char(1),
		vl_auto_type		char(1),
		vl_cust_def_no		integer,
		vl_status			integer,
		f_run_string		char(400),
		vl_start_time_h,
		vl_start_time_m		char(2),
		vl_def_msg			char(80)

	let vg_auto_flag = vl_auto_flag

	call create_gully_temp()

	initialize vlr_defh.* to null
	initialize vlr_defi.* to null
	initialize vlr_deft.* to null
	initialize vlr_defi_rect.* to null

	let vlr_deft.source_ref = vl_source_ref
	let vlr_deft.source_flag = vl_source_flag
	let vlr_deft.po_code = vl_po_code
	let vlr_defh.site_ref = vl_site_ref
	let vlr_defh.start_date = vl_start_date
	let vlr_defh.start_time_h = vl_start_time_h
	let vlr_defh.start_time_m = vl_start_time_m
	let vlr_defh.contract_ref = vl_contract_ref
	let vlr_defi.item_ref = vl_item_ref
	let vlr_defi.feature_ref = vl_feature_ref

	if length(vl_site_ref)
	then
		if vg_property_on
		then
			select site_name_1, site_name_2
				into vlr_defh.site_name_1, vlr_defh.site_name_2
			from site where site_ref = vl_site_ref
		else
			call construct_site_name_12(vl_site_ref)
				returning vlr_defh.site_name_1, vlr_defh.site_name_2
		end if
	end if

	if length(vlr_defh.site_ref)
		and length(vlr_defi.item_ref)
		and length(vlr_defh.contract_ref)
		and length(vlr_defi.feature_ref)
	then
		let vlr_deft.priority_flag =
			get_prior(vlr_defh.site_ref,
					vlr_defi.item_ref,
					vlr_defh.contract_ref,
					vlr_defi.feature_ref)

		let vlr_defi.next_date =
			find_next_date( vlr_defi.item_ref,
						vlr_defi.feature_ref,
						vlr_defh.contract_ref,
						vlr_defh.site_ref)

		if skey_check("DEFAULT_VOLUME","ALL") != 0
		then
			select n_field into vlr_defi.volume
				from keys
			where keyname matches "DEFAULT_VOLUME"
		else
			let vlr_defi.volume = get_vol(vlr_defh.site_ref,
											vlr_defi.item_ref,
											vlr_defh.contract_ref,
											vlr_defi.feature_ref)
		end if
	end if

	if length(vl_item_ref)
	then
		select item_desc 
			into vlr_defi.item_desc
		from item where item_ref = vl_item_ref and
		contract_ref = vl_contract_ref
	end if
	if length(vl_feature_ref)
	then
		select feature_desc into vlr_defi.feature_desc
		from feat
			where feature_ref = vl_feature_ref
	end if
	if length(vl_default_reason)
	then
		let vlr_defi.default_reason = vl_default_reason
		select lookup_num, lookup_text
			into vlr_deft.notice_type, vlr_defi.default_desc
		from allk
			where lookup_func = "DEFRN"
			and lookup_code = vlr_defi.default_reason
			and status_yn = "Y"

		if status = notfound
		then
			let vlr_defi.default_reason = null
		else end if
	end if

	if not length(vlr_defi.next_action)
	then
		if skey_check("WHAT_NEXT_ACTION", "ALL") = "Y"
		then
			let vlr_defi.next_action = "I"
		else
			let vlr_defi.next_action = "N"
		end if
	end if

	let vg_print_def_rep = true

	if g_comp_def_text
	then
		select text_flag into vlr_defi.text_flag from comp, diry
			where diry_ref = vl_source_ref and
					diry.source_flag = "C" and
					comp.complaint_no = diry.source_ref
		if status = notfound
		then
			let vlr_defi.text_flag = "N"
		end if

#		let vlr_defi.text_flag = "Y"
	else
		let vlr_defi.text_flag = "N"
	end if

	select service_c
		into vg_service_code
	from cont
		where contract_ref = vlr_defh.contract_ref

	if vlr_deft.source_flag = "C"
	then
		if skey_check("COMP_TEXT TO DEFS", vg_service_code) = "Y"
		then
			let vg_text_mode = "U"
		else
			let vg_text_mode = "A"
		end if
	else
		let vg_text_mode = "A"
	end if

	let vl_upd_flag = false

	let vl_status = 0 #chk_deft(vlr_defh.site_ref,
						#	vlr_defi.item_ref,
						#	vlr_defh.contract_ref,
						#	vlr_defi.feature_ref)

	if vg_temp_report is null or not vg_temp_report
	then
		call create_the_temp_report_tables()
		let vg_temp_report = true
	end if

	if vl_status = 0
	then
		if not vg_add_def or vg_add_def is null
		then
			let vg_add_def = true
		end if

		# Are we adding an auto default???
		if vl_auto_flag
		then
			let vl_auto_type = "A"
			let vl_commit_flag = true
		else
			call open_add_form()

			let vl_auto_type = "M"
			let vl_commit_flag = false
		end if

		if length(vlr_defh.contract_ref)
			and length(vlr_defh.site_ref)
			and length(vlr_defi.item_ref)
			and length(vlr_defi.feature_ref)
			and length(vlr_defi.default_reason)
			and length(vlr_deft.priority_flag)
		then
			call def_points(vlr_defh.contract_ref,
							vlr_defh.site_ref,
							vlr_defi.item_ref,
							vlr_defi.feature_ref,
							today,
							0,
							0,
							vlr_defi.default_reason,
							null,
							vlr_deft.priority_flag,
							null,
							vlr_deft.notice_type,
							vlr_defi.volume,
							false,
							0,
							0,
							vl_auto_type)
				returning vlr_deft.points,
						vlr_deft.value,
						vlr_deft.default_level,
						vlr_deft.default_occ,
						vlr_defi.default_algorithm,
						vlr_deft.default_sublevel,
						vlr_defi_rect.rectify_date,
						vlr_defi_rect.rectify_time_h,
						vlr_defi_rect.rectify_time_m,
						vg_p_and_v_flag

			if vlr_deft.default_level = 0
			then
				if length(vlr_defi.default_algorithm)
				then
					select count(*)
						into vl_commit_flag
					from defp1
						where algorithm = vlr_defi.default_algorithm
				else
					let vl_commit_flag = false
				end if
				if not vl_commit_flag
				then
					call valid_error ("", 
				"Algorithm error, no default-levels for this algorithm.",
						"")
				end if
			else
				let vl_commit_flag = true
			end if
			if vl_commit_flag
			then
				if length(vlr_defi.default_algorithm)
				then
					if skey_check("AN_VAL_DEF_ALG", "ALL") = "Y" 
					and vlr_deft.value
					then
						call custom_cum_value(vlr_defh.site_ref,
											vlr_defh.contract_ref,
											vlr_defh.start_date)
							returning vlr_deft.value
					end if
					if vlr_deft.points is null
					then
						let vlr_deft.points = 0
					end if
					if vlr_deft.value is null
					then
						let vlr_deft.value = 0
					end if
					if vlr_deft.default_level = 0
					and vlr_deft.default_occ = 0
					then
						let vlr_defi.clear_date = today
						let vlr_defi.item_status = "N"
					else
						let vlr_defi.clear_date = null
						let vlr_defi.item_status = "Y"
					end if
					if vlr_defh.cum_points is null
					then
						let vlr_defh.cum_points = 0
					end if
					if vlr_defh.cum_value is null
					then
						let vlr_defh.cum_value = 0
					end if

					if not vl_auto_flag
					then
						call display_defh()
						call input_add_default()
							returning vl_commit_flag	
					else
						#ADJ NEW 
						if skey_check("DEF_CHECK_WHOLE_VOL", "ALL") = "Y"
						then
							let vl_vol_flag = chk_volume(vlr_defh.site_ref,
														vlr_defi.item_ref,
														vlr_defh.contract_ref,
														vlr_defi.feature_ref,
														vlr_defi.volume)
							case vl_vol_flag
								when 2
									call valid_error("",
			"The volume entered exceeds the site item volume",
										"")
									let vl_commit_flag = false

								when 3
									call valid_error("",
			"The whole volume has been defaulted for the selected site item",
										"")
									let vl_commit_flag = false
							end case
						end if		
					end if
				else
					let vl_commit_flag = false
				end if
			end if
		else
			if not length(vlr_defh.contract_ref)
			then
				call valid_error("", 
					"Algorithm error, no value for contract reference.", "")
				let vl_commit_flag = false
			end if

			if not length(vlr_defh.site_ref)
			then
				call valid_error
					("", "Algorithm error, no value for site reference.", "")
				let vl_commit_flag = false
			end if

			if not length(vlr_defi.item_ref)
			then
				call valid_error
					("", "Algorithm error, no value for item reference.", "")
				let vl_commit_flag = false
			end if

			if not length(vlr_defi.feature_ref)
			then
				call valid_error
					("", "Algorithm error, no value for feature reference.", "")
				let vl_commit_flag = false
			end if

			if not length(vlr_defi.default_reason)
			then
				call valid_error
					("", "Algorithm error, no value for rectification reason.", "")
				let vl_commit_flag = false
			end if

			if not length(vlr_deft.priority_flag)
			then
				call valid_error
					("", "Algorithm error, no value for priority flag.", "")
				let vl_commit_flag = false
			end if

		end if	
	end if
	call mstart_wait("Adding Rectification, Please Wait ...")

	if vl_commit_flag
	then
		call commit_default_records()
				returning vl_cust_def_no
		if vlr_deft.default_level = 0 
		then
			let vr_defi.feature_ref = vlr_defi.feature_ref
			let vr_defi.item_ref = vlr_defi.item_ref
			call clear_default(vl_cust_def_no, 0, 0)
		end if

		if skey_check("ENTRY_PROMPT","ALL") = "Y"
		then
			if vl_auto_flag
			then
				call end_wait()
				call show_rectifications_tab(vl_cust_def_no, true)
				call gl_showpage("fold", "rectifications_page")
			end if

			let vl_def_msg = "The new rectification has been saved. ",
				"The reference number is ", 
				vl_cust_def_no using "<<<<<<<" clipped

			call valid_error("Information", vl_def_msg, "I")

			if int_flag
			then
				call valid_error("",
					"The rectification has been added... No interrupts allowed",
					"")
				let int_flag = false
			end if

			if vl_source_flag is null
			then
				let vl_source_flag = "X"
			end if

			if vl_source_flag = "X" or vl_source_flag is null
			then
				let vl_user = get_user()

				declare c_new_item cursor for
					select item_ref, 
						feature_ref, 
						default_level, 
						default_occ   
					from deft
						where default_no = vl_cust_def_no

				foreach c_new_item into vl_print_rec.*

					let f_run_string = "exec fglgo_def_prnt '", 
						vl_contract_ref clipped,
						"' ", vl_cust_def_no

#						"'", vl_print_rec.item_ref, "' ",
#						"'", vl_print_rec.feature_ref, "' ",
#						"'", vl_print_rec.default_level, "' ",
#						"'", vl_print_rec.default_occ, "' "

					if skey_check("PRINT_CLEARED_DEF", "ALL") = "N"
					then
						#check if the default is cleared
						select default_status
							into vl_default_status
						from defh
							where cust_def_no = vl_cust_def_no
						
						if vl_default_status = "Y" 
						then
							call os_exec(f_run_string, true)
						end if
					else
						call os_exec(f_run_string, true) 
					end if
				end foreach
			end if
		else
			call end_wait()
		end if

{
		if not vl_auto_flag
		then
			call close_add_form()
		end if
	else
		if vl_status > 0
		then
			call upd_def(vlr_defh.cust_def_no)
			let vl_upd_flag = true
		else
			call upd_def(vlr_defh.cust_def_no)
		end if
}
	else
		call end_wait()
	end if

	if not vl_auto_flag
	then
		call close_add_form()
	end if

	let vr_defh.cust_def_no = vlr_defh.cust_def_no

	call reset_text_count()

#	return vl_upd_flag
	return vl_commit_flag
end function


function input_add_default()
	define
		vl_commit_flag		smallint,
		vl_service_c		like cont.service_c,
		vl_contract_ref		like cont.contract_ref,
		vl_default_reason	like defi.default_reason,
		item_save			like defi.item_ref,
		item_s   			like defi.item_ref,
		vl_volume			like defi.volume,
		vl_exit     		char(1)	

	while true
		call set_add_def_options()

		if vg_p_and_v_flag
		then
			if skey_check("COMP CODE>DEFRN LINK","ALL") = "Y"
			then
				call add_nondef_mod_p_and_v_default()	
					returning vl_exit
			else
				call add_def_mod_p_and_v_default()	
					returning vl_exit
			end if
		else
			if skey_check("COMP CODE>DEFRN LINK","ALL") = "Y"
			then
				call add_nondef_non_p_and_v_default()	
					returning vl_exit
			else
				call add_def_non_p_and_v_default()	
					returning vl_exit
			end if
		end if

		case vl_exit
			when "I"
				let vl_commit_flag = false
				exit while
			when "C"
				let vl_commit_flag = false
				continue while
			when "A"
				let vl_commit_flag = true
				exit while
			otherwise
				let vl_commit_flag = false
				exit while
		end case
				
	end while

	return vl_commit_flag

	call set_main_options()
end function


function chk_deft(vl_site_ref, 
				vl_item_ref, 
				vl_contract_ref, 
				vl_feature_ref,
				vl_volume)
	define
		vl_default_no		like defh.cust_def_no,
		vl_site_ref			like defh.site_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_item_ref			like defi.item_ref,
		vl_volume			like defi.volume,
		vl_si_i_volume		like si_i.volume,
		vl_vol_flag			char(1),
		vl_x				smallint

	declare ic_default cursor for
	select defh.cust_def_no
		from defi, defh
		where defi.item_status = "Y"
		and item_ref = vl_item_ref
		and defi.feature_ref = vl_feature_ref
		and contract_ref = vl_contract_ref
		and site_ref = vl_site_ref
		and defi.default_no = defh.cust_def_no

	let vl_x = 0

	foreach ic_default into vl_default_no
		let vl_x = vl_x + 1
	end foreach

	if vl_x = 0
	then
		let vl_default_no = 0
	else
		if skey_check("DEF_CHECK_WHOLE_VOL", "ALL") = "Y"
		then
			let vl_vol_flag = chk_volume(vl_site_ref,
										vl_item_ref,
										vl_contract_ref,
										vl_feature_ref,
										vl_volume)
			case vl_vol_flag
				when 2
					call valid_error("",
					"The volume entered exceeds the site item volume",
						"")
					let vg_print_def_rep = false

				when 3
					call valid_error("",
			"The whole volume has been defaulted for the selected site item",
						"")
					let vg_print_def_rep = false

				otherwise
					let vl_default_no = 0
			end case
		end if		
	end if

	return vl_default_no
end function	# chk_deft


function chk_volume(vl_site_ref, 
					vl_item_ref, 
					vl_contract_ref, 
					vl_feature_ref,
					vl_input_volume)
	define
		vl_input_volume		like defi.volume,
		vl_defi_volume		like defi.volume,
		vl_si_i_volume		like si_i.volume,
		vl_site_ref			like defh.site_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_item_ref			like defi.item_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_volume			like defi.volume,
		vl_return_flag		smallint

	if vl_input_volume = 0
	or vl_input_volume is null
	then
		return 1
	end if

	let vl_si_i_volume = get_vol(vl_site_ref,
								vl_item_ref,
								vl_contract_ref,
								vl_feature_ref)

	if vl_input_volume > vl_si_i_volume
	then
		return 2
	end if

	select sum(defi.volume)
		into vl_defi_volume
	from defi, defh
		where item_ref = vl_item_ref
		and site_ref = vl_site_ref
		and contract_ref = vl_contract_ref
		and defi.feature_ref = vl_feature_ref
		and defi.default_no = defh.cust_def_no
		and defi.item_status = "Y"

	if vl_defi_volume is null or vl_defi_volume = 0
	then
		return 1
	else
		let vl_volume = vl_defi_volume + vl_input_volume

		if vl_volume > vl_si_i_volume
		then
			return 3
		end if
	end if
	return 1
end function	# chk_volume


function get_vol(vl_site_ref, vl_item_ref, vl_contract_ref, vl_feature_ref)
	define
		vl_site_ref			like defh.site_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_item_ref			like defi.item_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_volume			like si_i.volume

	select volume
		into vl_volume
	from si_i
		where site_ref = vl_site_ref
		and item_ref = vl_item_ref
		and feature_ref = vl_feature_ref
		and contract_ref = vl_contract_ref

	if status != 0
	then
		let vl_volume = null
	end if

	return vl_volume

end function


function get_prior(vl_site_ref, vl_item_ref, vl_contract_ref, vl_feature_ref)
	define
		vl_site_ref			like defh.site_ref,
		vl_contract_ref		like defh.contract_ref,
		vl_item_ref			like defi.item_ref,
		vl_feature_ref		like defi.feature_ref,
		vl_prior			like si_i.priority_flag

	select priority_flag
		into vl_prior
		from si_i
		where site_ref = vl_site_ref
		and item_ref = vl_item_ref
		and feature_ref = vl_feature_ref
		and contract_ref = vl_contract_ref

	if status != 0
	then
# if no si_i try to get default priority value from item - BJG
		select priority_f
			into vl_prior
			from item
			where item_ref = vl_item_ref
			and contract_ref = vl_contract_ref

		if status != 0
			then
				let vl_prior = null
		end if
	end if

	return vl_prior
end function


function chk_priority()
	return true
end function


function chk_def_no(vl_def_no)
	define
		vl_def_no			integer

	select *
		from defh
		where cust_def_no = vl_def_no

	return not status
end function


function chk_notice_type(vl_notice_type)
	define
		vl_notice_type		like deft.notice_type

	select *
		from allk
	where lookup_func = "NOTYPE"
		and lookup_code = vl_notice_type

	return not status
end function


function get_notice_ref(vl_notice_type)
	define
		vl_notice_type		like deft.notice_type

	return vlr_defh.cust_def_no
end function


function find_next_date(vl_item_ref,
						vl_feature_ref,
						vl_contract_ref,
						vl_site_ref)
	define
		vl_item_ref			like item.item_ref,
		vl_feature_ref		like feat.feature_ref,
		vl_contract_ref		like cont.contract_ref,
		vl_site_ref			like si_i.item_ref,
		vl_next_date		like defi.next_date

	if vl_next_date is null or vl_next_date <= today
	then
		select date_due
			into vl_next_date
		from si_i
			where item_ref = vl_item_ref
			and site_ref = vl_site_ref
			and contract_ref = vl_contract_ref
			and feature_ref = vl_feature_ref

		if status = notfound or vl_next_date is null
		then
			let vl_next_date = today
		end if
	end if

	return vl_next_date
end function


function check_item_ref()
	select *
		from item
	where item_ref = vlr_defi.item_ref
		and contract_ref = vlr_defh.contract_ref

	if status = notfound
	then
		return false
	end if

	select *
		from it_f
	where feature_ref = vlr_defi.feature_ref
		and item_ref = vlr_defi.item_ref

	if status = notfound
	then
		return false
	end if

	return true
end function


function open_add_form()
	open window iw_add_def with form "add_def"

	call set_main_options()
end function


function close_add_form()
	close window iw_add_def
end function


function display_defh()
	display by name vlr_defh.site_name_1,
					vlr_defh.site_name_2,
					vlr_defi.item_ref,
					vlr_defi.item_desc,
					vlr_defi.feature_ref,
					vlr_defi.feature_desc,
					vlr_defi.next_date,
					vlr_defh.contract_ref,
					vlr_deft.priority_flag,
					vlr_defi.default_reason,
					vlr_defi.default_desc,
					vlr_defi.next_action,
					vlr_defi.volume,
					vlr_deft.points,
					vlr_deft.value,
					vlr_deft.notice_type,
					vlr_defi_rect.rectify_date,
					vlr_defi_rect.rectify_time_h,
					vlr_defi_rect.rectify_time_m,
					vlr_defi.text_flag 
end function


function commit_default_records()

	define
		vl_user				like deft.username,
		vl_default_no		like defh.cust_def_no,
		vl_diry_ref			like diry.source_ref,
		vl_x				smallint,
		vl_time_h,
		vl_time_m			char(2)

	call get_time()
		returning vl_time_h, vl_time_m

	let vl_user = upshift(get_user())

 	let vlr_defh.default_status = vlr_defi.item_status

	let vlr_defh.default_no = 0

	whenever error continue

	while true

		if vlr_defh.cust_def_no is null
		then
			let vlr_defh.cust_def_no = get_next_def_no()
		end if
		#ADJ SERIALS
		let vlr_defh.default_no = get_next_s_no("defh", "")

		insert into defh values (vlr_defh.default_no,
								vlr_defh.cust_def_no,
								vlr_defh.start_date,
								vlr_defh.start_time_h,
								vlr_defh.start_time_m,
								vlr_defh.site_ref,
								vlr_defh.contract_ref,
								vlr_deft.points,
								vlr_deft.value,
								null,
								vlr_defh.default_status,
								vlr_defi.default_reason,   
								vlr_defh.clear_flag,   
								null,
								null)

		if errtst()
		then
			exit while
		else
			select max(cust_def_no) 
				into vlr_defh.cust_def_no
			from defh

			if status = notfound
			then
				let vlr_defh.cust_def_no = 1
			else
				let vlr_defh.cust_def_no = vlr_defh.cust_def_no + 2
				update s_no set serial_no = vlr_defh.cust_def_no
					where sn_func = 'DEFREF'
				let vlr_defh.cust_def_no = vlr_defh.cust_def_no - 1
			end if
		end if
	end while

	whenever error stop

	#ADJ SERIALS
	let vl_diry_ref = get_next_s_no("diry", "")
	let vl_default_no = vlr_defh.cust_def_no

	insert into diry(diry_ref,
					prev_record,
					source_flag,
					source_ref,
					source_date,
					source_time_h,
					source_time_m,
					site_ref,
					item_ref,
					contract_ref,
					feature_ref,
					date_due,
					pa_area,
					action_flag,
					source_user,
					po_code)
		values (vl_diry_ref,
				vr_diry.diry_ref,
				'D',
				vl_default_no,
				today,
				vl_time_h,
				vl_time_m,
				vlr_defh.site_ref,
				vlr_defi.item_ref,
				vlr_defh.contract_ref,
				vlr_defi.feature_ref,
				vlr_defi.next_date,
				vr_diry.pa_area,
				vlr_defi.next_action,
				vl_user,
				vlr_deft.po_code)

	let vr_diry_upd.next_record = vl_diry_ref
	let vr_diry_upd.dest_ref = vl_default_no
	let vr_diry_upd.dest_flag = "D"
	let vr_diry_upd.dest_date = today
	let vr_diry_upd.dest_time_h = vl_time_h
	let vr_diry_upd.dest_time_m = vl_time_m
	let vr_diry_upd.dest_user = vl_user
	let vr_diry_upd.po_code = vlr_deft.po_code

	call diry_text_update(vl_diry_ref)

	call update_defi_nb(vlr_defh.cust_def_no,
						vlr_defi.feature_ref,
						vlr_defi.item_ref)

	let vlr_deft.notice_ref = vlr_defh.cust_def_no
 
	insert into defi values (vlr_defh.cust_def_no,
							vlr_defi.item_ref,
							vlr_defi.feature_ref,
							vlr_defi.volume,
							vlr_defi.default_reason,
							vlr_defi.text_flag,
							vlr_deft.points,
							vlr_deft.value,
							vlr_defi.next_action,
							vlr_defi.next_date,
							vlr_defi.item_status,
							vlr_defi.clear_date,
							vlr_defi.default_algorithm,
							null,
							null)
 
	call ins_def_cont_i(vlr_defh.cust_def_no,
						vlr_defi.item_ref,
						vlr_defi.feature_ref)

	insert into deft values(vlr_defh.cust_def_no,
							vlr_defi.item_ref,
							vlr_defi.feature_ref,
							vlr_deft.default_level,
							1,
							'D',
							today,
							vlr_deft.notice_type,
							vlr_deft.notice_ref,
							vlr_deft.priority_flag,
							vlr_deft.points,
							vlr_deft.value,
							vlr_deft.source_flag,
							vlr_deft.source_ref,
							null,
							vl_user,
							vlr_deft.po_code,
							vl_time_h,
							vl_time_m,
							vlr_deft.default_occ,
							vlr_deft.default_sublevel,
							null,
							null,
							null,
							null)

	call insert_defi_rect(0,
						vlr_defh.cust_def_no,
						1,
						vlr_defi.item_ref,
						vlr_defi.feature_ref,
						vlr_defi_rect.rectify_date,
						vlr_defi_rect.rectify_time_h,
						vlr_defi_rect.rectify_time_m)

	return vlr_defh.cust_def_no
end function


function insert_defi_rect(vlr_defi_rect)
	define
		vlr_defi_rect		record like defi_rect.*

	#ADJ SERIALS
	let vlr_defi_rect.rect_key = get_next_s_no("defi_rect", "")

	insert into defi_rect values (vlr_defi_rect.*)

end function	# insert_defi_rect


function get_allk_num(vl_lookup_code)
	define
		vl_lookup_code		like allk.lookup_code,
		vl_lookup_num		like allk.lookup_num

	select lookup_num
		into vl_lookup_num
		from allk
		where allk.lookup_func = "NOTYPE"
		and allk.lookup_code = vl_lookup_code

	if status = notfound
	then
		error "Check allk table for lookup_func: NOTYPE"
		sleep 2
		let vl_lookup_num = null
	end if

	return vl_lookup_num
end function


function left_justify_int(vl_cust_def_no)
	define
		vl_notice_ref		like deft.notice_ref,
		vl_int_loop,
		vl_chr_loop			smallint,
		vl_cust_def_no		char(20)

	let vl_int_loop = 1

	for vl_chr_loop = 1 to 20
		if vl_cust_def_no[vl_chr_loop] != " "
		then
			let vl_notice_ref[vl_int_loop] = vl_cust_def_no[vl_chr_loop]

			let vl_int_loop = vl_int_loop+1
		end if
	end for

	return vl_notice_ref, vl_int_loop
end function	# left_justify_int


function get_next_def_no()
#
# The default number is no longer contract related: Locking is now implemented
#
	define
		vl_def_no			integer,
		vl_count			smallint

	select count(*)
		into vl_count
		from s_no
		where sn_func = "DEFREF"

	case
		when vl_count = 0
		or vl_count is null
			let vl_def_no = 1
			insert into s_no values ('DEFREF', NULL, 1)

		when vl_count > 1
			error "Sorting out s_no table....."
			select max(serial_no)
				into vl_def_no
				from s_no
				where sn_func = "DEFREF"
			delete from s_no
				where sn_func = "DEFREF"
				and serial_no != vl_def_no
	end case

	#whenever error continue
	declare gn_def_no_curs cursor for
		select serial_no
			from s_no
		where sn_func = 'DEFREF'
			for update

	if vg_trans_logging = "Y"
	then
		begin work
	end if
	while true
		open gn_def_no_curs
		if status != -250
		then
			fetch gn_def_no_curs into vl_def_no
			if status != -250
			then
				if status = notfound
				then
					error "No next rectification number found"
				end if

				let vl_def_no = vl_def_no + 1

				update s_no
					set serial_no = vl_def_no
				where current of gn_def_no_curs

				close gn_def_no_curs
				exit while
			end if
		end if
		close gn_def_no_curs

		error "Unable to find rectification number, record locked, retrying..."
		sleep 1
	end while

	if vg_trans_logging = "Y"
	then
		commit work
	end if
#	whenever error stop

	return vl_def_no
end function
{------------------------------------------------------------------------------}


function set_add_def_options()
	options input wrap
end function


################################################################################
# WARNING - WARNING - WARNING - WARNING - WARNING - WARNING - WARNING - WARNING 
################################################################################
# The four functions below are very similar and any changes need to be reflected
# on each.  The input fields differ in each allowing certain fields to be 
# disbled .. in character mode a "before field-next field" was sufficient but
# the mouse driven GUI this becomes very messy - ADJ 01/06/01
################################################################################

function add_def_mod_p_and_v_default()
	define 	
		vl_exit				char(1),
		vl_volume			like defi.volume,
		vl_default_reason	like defi.default_reason,
		vl_p_and_v_flag		smallint,
		vl_vol_flag			char(1),
		vl_complaint_no		like comp.complaint_no

	input by name vlr_defi.default_reason,
				vlr_defi.volume,
				vlr_defi.next_action, 
				vlr_deft.points,
				vlr_deft.value,
				vlr_defi_rect.rectify_date,
				vlr_defi_rect.rectify_time_h,
				vlr_defi_rect.rectify_time_m without defaults 

		on action f2_lookup
			if infield(default_reason)
			then
				call defrn_look(vlr_defh.contract_ref, 
								vlr_defi.item_ref, "Y")
					returning vl_default_reason

				call set_add_def_options()

				if length(vl_default_reason)
				then
					let vlr_defi.default_reason = vl_default_reason
					select lookup_num, lookup_text
						into vlr_deft.notice_type, vlr_defi.default_desc
					from allk
						where lookup_func = "DEFRN"
						and lookup_code = vlr_defi.default_reason

					display by name vlr_defi.default_reason,
								vlr_deft.notice_type 
				end if
			else
				call valid_error("", 
					"There are no lookups available on this field", "")
			end if

		before field default_reason
			if length(vlr_defi.default_reason)
			then
				let vl_default_reason = vlr_defi.default_reason 
			else
				let vl_default_reason = "NULL"
			end if

		after field default_reason
			if length(vlr_defi.default_reason) 
			then
				if vl_default_reason != vlr_defi.default_reason
				then
					select lookup_num, lookup_text
						into vlr_deft.notice_type, vlr_defi.default_desc
					from allk
						where lookup_func = "DEFRN"
						and lookup_code = vlr_defi.default_reason

					if status = notfound 
					then
						call valid_error("", 
							"A valid rectification reason must be entered", 
							"")
						next field default_reason
					else
						call create_temp_allk()
						if chk_defrn(vlr_defh.contract_ref, 
									vlr_defi.item_ref, "Y")
						then
							call set_add_def_options()

							select * 
								from temp_allk
							where lookup_code = vlr_defi.default_reason

							if status = notfound
							then
								call drop_temp_allk()
								call valid_error("",
			"The rectification reason is not valid for the selected item", "")
								next field default_reason
							else
								call drop_temp_allk()
								display by name vlr_defi.default_reason
								display by name vlr_deft.notice_type,
									vlr_defi.default_desc 

								call def_points(vlr_defh.contract_ref,
											vlr_defh.site_ref,
											vlr_defi.item_ref,
											vlr_defi.feature_ref,
											today,
											0,
											0,
											vlr_defi.default_reason,
											null,
											vlr_deft.priority_flag,
											null,
											vlr_deft.notice_type,
											vlr_defi.volume,
											false,
											0,
											0,
											"M")
									returning vlr_deft.points,
										vlr_deft.value,
										vlr_deft.default_level,
										vlr_deft.default_occ,
										vlr_defi.default_algorithm,
										vlr_deft.default_sublevel,
										vlr_defi_rect.rectify_date,
										vlr_defi_rect.rectify_time_h,
										vlr_defi_rect.rectify_time_m,
										vg_p_and_v_flag
								
								if skey_check
									("AN_VAL_DEF_ALG", "ALL")="Y" 
										and vlr_deft.value
								then
									call custom_cum_value
										(vlr_defh.site_ref,
										vlr_defh.contract_ref,
										vlr_defh.start_date)
											returning vlr_deft.value
								end if

								if vlr_defi.default_algorithm is null
								then
									let int_flag = true
									exit input
								end if
								if vlr_deft.points is null
								then
									let vlr_deft.points = 0
								end if
								if vlr_deft.value is null
								then
									let vlr_deft.value = 0
								end if
								# ADJ default algorithm changes
								#if vlr_deft.default_level = 0
								#	and vlr_deft.default_occ = 0
								#if vlr_deft.default_level = -99 
								#	and vlr_deft.default_occ = -99
								#then
								#	let vlr_defi.clear_date = today
								#	let vlr_defi.item_status = "N"
								#else
									let vlr_defi.clear_date = null
									let vlr_defi.item_status = "Y"
								#end if
								if vlr_defh.cum_points is null
								then
									let vlr_defh.cum_points = 0
								end if
								if vlr_defh.cum_value is null
								then
									let vlr_defh.cum_value = 0
								end if
								display by name vlr_deft.points, 
										vlr_deft.value,
										vlr_defi_rect.rectify_date,
										vlr_defi_rect.rectify_time_h, 
										vlr_defi_rect.rectify_time_m 
								if vl_p_and_v_flag != vg_p_and_v_flag
								then
									let vg_p_and_v_flag = vl_p_and_v_flag
									let vl_exit = "C"	
								end if
							end if
						else
							call set_add_def_options()

							call valid_error("",
"There are NO rectification reasons associated with the selected contract/item.", "")
						end if
					end if
				end if
			else
				call valid_error("", 
					"A valid rectification reason must be entered", "")
				next field default_reason
			end if

		before field volume
			if vlr_defi.volume is null
			then
				let vl_volume = 0
			else
				let vl_volume = vlr_defi.volume 
			end if

		after field volume
			if vlr_defi.volume is not null
			then
				if skey_check("DEF_CHECK_WHOLE_VOL", "ALL") = "Y"
				then
					let vl_vol_flag = chk_volume(vlr_defh.site_ref,
												vlr_defi.item_ref,
												vlr_defh.contract_ref,
												vlr_defi.feature_ref,
												vlr_defi.volume)
					case vl_vol_flag
						when 2
							call valid_error("",
							"The volume entered exceeds the site item volume",
								"")
							next field volume

						when 3
							call valid_error("",
			"The whole volume has been defaulted for the selected site item",
								"")
							next field volume
					end case
				end if		
			else
				call valid_error("","A valid volume must be entered","")
				next field volume
			end if

		before field next_action
			if not length(vlr_defi.next_action)
			then
				if skey_check("WHAT_NEXT_ACTION", "ALL") = "Y"
				then
					let vlr_defi.next_action = "I"
				else
					let vlr_defi.next_action = "N"
				end if
				display by name vlr_defi.next_action 
			end if

		after field next_action
			if vlr_defi.next_action not matches "[INL]"
			then	
				call valid_error("",
					"A valid next action must be entered", "")
				next field next_action
			end if

		after field rectify_date
			if vlr_defi_rect.rectify_date is not null
			and vlr_defi_rect.rectify_date < vlr_defh.start_date
			then
				call valid_error("Validation",
										"Invalid date value",
										"I")
				next field rectify_date
			end if

		after field rectify_time_h
			if vlr_defi_rect.rectify_time_h is not null
			then
				if not valid_hours(vlr_defi_rect.rectify_time_h)
				then
					call valid_error("Validation",
										"Invalid value for hours in time",
										"I")
					next field rectify_time_h
				end if
			end if

		after field rectify_time_m
			if vlr_defi_rect.rectify_time_m is not null
			then
				if not valid_minutes(vlr_defi_rect.rectify_time_m)
				then
					call valid_error("Validation",
										"Invalid value for minutes in time",
										"I")
					next field rectify_time_m
				end if
			end if

		on action cancel
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action Close
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action Exit
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action text
			if not lock_text(vlr_defh.cust_def_no, "D")
			then
				return
			end if
			if skey_check("UPD_COMP_DEST_TEXT","ALL") = "Y"
			then
				select complaint_no 
					into vl_complaint_no
				from comp
					where dest_ref = vlr_defh.cust_def_no
					and action_flag = "D"
				if length(vl_complaint_no)
				then
					if not lock_text(vl_complaint_no, "C")
					then
						return
					end if
				end if
			end if
			if add_scroll_defi_nb(vlr_defh.cust_def_no,
								vlr_defi.feature_ref,
								vlr_defi.item_ref,
								vg_text_mode)			#AB 25/05/1995
			then										#CRO80
				let vlr_defi.text_flag = "Y"
				display by name vlr_defi.text_flag 
			end if
			#ADJ 101005 Text Locking
			call unlock_text(vlr_defh.cust_def_no, "D")
			if skey_check("UPD_COMP_DEST_TEXT","ALL") = "Y"
			then
				if length(vl_complaint_no)
				then
					call unlock_text(vl_complaint_no, "C")
				end if
			end if

		after input
			case
				when not length(vlr_defi.default_reason)
					next field default_reason

				when not length(vlr_defi.volume)
					next field volume

				when not length(vlr_defi.next_action)
					next field next_action

				when vlr_defi_rect.rectify_date is null
					next field rectify_date

				when not length(vlr_defi_rect.rectify_time_h)
					next field rectify_time_h

				when not length(vlr_defi_rect.rectify_time_m)
					next field rectify_time_m

			end case
			let vl_exit = "A"
	end input
	return vl_exit
end function	


function add_def_non_p_and_v_default()
	define 	
		vl_exit				char(1),
		vl_vol_flag			char(1),
		vl_volume			like defi.volume,
		vl_default_reason	like defi.default_reason,
		vl_p_and_v_flag		smallint,
		vl_complaint_no		like comp.complaint_no

	input by name vlr_defi.default_reason,
				vlr_defi.volume,
				vlr_defi.next_action without defaults 

		on action f2_lookup
			if infield(default_reason)
			then
				call defrn_look(vlr_defh.contract_ref, 
								vlr_defi.item_ref, "Y")
					returning vl_default_reason

				call set_add_def_options()

				if length(vl_default_reason)
				then
					let vlr_defi.default_reason = vl_default_reason
					select lookup_num, lookup_text
						into vlr_deft.notice_type, vlr_defi.default_desc
					from allk
						where lookup_func = "DEFRN"
						and lookup_code = vlr_defi.default_reason

					display by name vlr_defi.default_reason,
								vlr_deft.notice_type 
				end if
			else
				call valid_error("", 
					"There are no lookups available on this field", "")
			end if

		before field default_reason
			if length(vlr_defi.default_reason)
			then
				let vl_default_reason = vlr_defi.default_reason 
			else
				let vl_default_reason = "NULL"
			end if

		after field default_reason
			if length(vlr_defi.default_reason) 
			then
				if vl_default_reason != vlr_defi.default_reason
				then
					select lookup_num, lookup_text
						into vlr_deft.notice_type, vlr_defi.default_desc
					from allk
						where lookup_func = "DEFRN"
						and lookup_code = vlr_defi.default_reason

					if status = notfound 
					then
						call valid_error("", 
							"A valid rectification reason must be entered", 
							"")
						next field default_reason
					else
						call create_temp_allk()
						if chk_defrn(vlr_defh.contract_ref, 
									vlr_defi.item_ref, "Y")
						then
							call set_add_def_options()

							select * 
								from temp_allk
							where lookup_code = vlr_defi.default_reason

							if status = notfound
							then
								call drop_temp_allk()
								call valid_error("",
			"The rectification reason is not valid for the selected item", "")
								next field default_reason
							else
								call drop_temp_allk()
								display by name vlr_defi.default_reason
								display by name vlr_deft.notice_type,
									vlr_defi.default_desc 

								call def_points(vlr_defh.contract_ref,
											vlr_defh.site_ref,
											vlr_defi.item_ref,
											vlr_defi.feature_ref,
											today,
											0,
											0,
											vlr_defi.default_reason,
											null,
											vlr_deft.priority_flag,
											null,
											vlr_deft.notice_type,
											vlr_defi.volume,
											false,
											0,
											0,
											"M")
									returning vlr_deft.points,
										vlr_deft.value,
										vlr_deft.default_level,
										vlr_deft.default_occ,
										vlr_defi.default_algorithm,
										vlr_deft.default_sublevel,
										vlr_defi_rect.rectify_date,
										vlr_defi_rect.rectify_time_h,
										vlr_defi_rect.rectify_time_m,
										vg_p_and_v_flag
								
								if skey_check
									("AN_VAL_DEF_ALG", "ALL")="Y" 
										and vlr_deft.value
								then
									call custom_cum_value
										(vlr_defh.site_ref,
										vlr_defh.contract_ref,
										vlr_defh.start_date)
											returning vlr_deft.value
								end if

								if vlr_defi.default_algorithm is null
								then
									let int_flag = true
									exit input
								end if
								if vlr_deft.points is null
								then
									let vlr_deft.points = 0
								end if
								if vlr_deft.value is null
								then
									let vlr_deft.value = 0
								end if
								# ADJ default algorithm changes
								#if vlr_deft.default_level = 0
								#	and vlr_deft.default_occ = 0
								#if vlr_deft.default_level = -99
								#	and vlr_deft.default_occ = -99
								#then
								#	let vlr_defi.clear_date = today
								#	let vlr_defi.item_status = "N"
								#else
									let vlr_defi.clear_date = null
									let vlr_defi.item_status = "Y"
								#end if
								if vlr_defh.cum_points is null
								then
									let vlr_defh.cum_points = 0
								end if
								if vlr_defh.cum_value is null
								then
									let vlr_defh.cum_value = 0
								end if
								display by name vlr_deft.points, 
										vlr_deft.value,
										vlr_defi_rect.rectify_date,
										vlr_defi_rect.rectify_time_h, 
										vlr_defi_rect.rectify_time_m 
								if vl_p_and_v_flag != vg_p_and_v_flag
								then
									let vg_p_and_v_flag = vl_p_and_v_flag
									let vl_exit = "C"
								end if
							end if
						else
							call set_add_def_options()

							call valid_error("",
"There are NO rectification reasons associated with the selected contract/item.", "")
						end if
					end if
				end if
			else
				call valid_error("", 
					"A valid rectification reason must be entered", "")
				next field default_reason
			end if

		before field volume
			if vlr_defi.volume is null
			then
				let vl_volume = 0
			else
				let vl_volume = vlr_defi.volume 
			end if

		after field volume
			if vlr_defi.volume is not null
			then
				if skey_check("DEF_CHECK_WHOLE_VOL", "ALL") = "Y"
				then
					let vl_vol_flag = chk_volume(vlr_defh.site_ref,
												vlr_defi.item_ref,
												vlr_defh.contract_ref,
												vlr_defi.feature_ref,
												vlr_defi.volume)
					case vl_vol_flag
						when 2
							call valid_error("",
							"The volume entered exceeds the site item volume",
								"")
							next field volume

						when 3
							call valid_error("",
			"The whole volume has been defaulted for the selected site item",
								"")
							next field volume
					end case
				end if		
			else
				call valid_error("","A valid volume must be entered","")
				next field volume
			end if

		before field next_action
			if not length(vlr_defi.next_action)
			then
				if skey_check("WHAT_NEXT_ACTION", "ALL") = "Y"
				then
					let vlr_defi.next_action = "I"
				else
					let vlr_defi.next_action = "N"
				end if
				display by name vlr_defi.next_action 
			end if

		after field next_action
			if vlr_defi.next_action not matches "[INL]"
			then	
				call valid_error("",
					"A valid next action must be entered", "")
				next field next_action
			end if

		on action cancel
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action Close
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action Exit
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action text
			if not lock_text(vlr_defh.cust_def_no, "D")
			then
				return
			end if
			if skey_check("UPD_COMP_DEST_TEXT","ALL") = "Y"
			then
				select complaint_no 
					into vl_complaint_no
				from comp
					where dest_ref = vlr_defh.cust_def_no
					and action_flag = "D"
				if length(vl_complaint_no)
				then
					if not lock_text(vl_complaint_no, "C")
					then
						return
					end if
				end if
			end if
			if add_scroll_defi_nb(vlr_defh.cust_def_no,
								vlr_defi.feature_ref,
								vlr_defi.item_ref,
								vg_text_mode)			#AB 25/05/1995
			then										#CRO80
				let vlr_defi.text_flag = "Y"
				display by name vlr_defi.text_flag 
			end if
			#ADJ 101005 Text Locking
			call unlock_text(vlr_defh.cust_def_no, "D")
			if skey_check("UPD_COMP_DEST_TEXT","ALL") = "Y"
			then
				if length(vl_complaint_no)
				then
					call unlock_text(vl_complaint_no, "C")
				end if
			end if

		after input
			case
				when not length(vlr_defi.default_reason)
					next field default_reason

				when not length(vlr_defi.volume)
					next field volume

				when not length(vlr_defi.next_action)
					next field next_action
			end case
			let vl_exit  = "A"
	end input
	return vl_exit
end function


function add_nondef_mod_p_and_v_default()
	define 	
		vl_exit				char(1),
		vl_vol_flag			char(1),
		vl_volume			like defi.volume,
		vl_default_reason	like defi.default_reason,
		vl_p_and_v_flag		smallint,
		vl_complaint_no		like comp.complaint_no

	input by name vlr_defi.volume,
				vlr_defi.next_action, 
				vlr_deft.points,
				vlr_deft.value,
				vlr_defi_rect.rectify_date,
				vlr_defi_rect.rectify_time_h,
				vlr_defi_rect.rectify_time_m without defaults 

{
		on key(f2)
			call valid_error("", 
				"There are no lookups available on this field", "")
}

		before field volume
			if vlr_defi.volume is null
			then
				let vl_volume = 0
			else
				let vl_volume = vlr_defi.volume 
			end if

		after field volume
			if vlr_defi.volume is not null
			then
				if skey_check("DEF_CHECK_WHOLE_VOL", "ALL") = "Y"
				then
					let vl_vol_flag = chk_volume(vlr_defh.site_ref,
												vlr_defi.item_ref,
												vlr_defh.contract_ref,
												vlr_defi.feature_ref,
												vlr_defi.volume)
					case vl_vol_flag
						when 2
							call valid_error("",
							"The volume entered exceeds the site item volume",
								"")
							next field volume

						when 3
							call valid_error("",
			"The whole volume has been defaulted for the selected site item",
								"")
							next field volume
					end case
				end if
			else
				call valid_error("","A valid volume must be entered","")
				next field volume
			end if

		before field next_action
			if not length(vlr_defi.next_action)
			then
				if skey_check("WHAT_NEXT_ACTION", "ALL") = "Y"
				then
					let vlr_defi.next_action = "I"
				else
					let vlr_defi.next_action = "N"
				end if
				display by name vlr_defi.next_action 
			end if

		after field next_action
			if vlr_defi.next_action not matches "[INL]"
			then	
				call valid_error("",
					"A valid next action must be entered", "")
				next field next_action
			end if

		after field rectify_date
			if vlr_defi_rect.rectify_date is not null
			and vlr_defi_rect.rectify_date < vlr_defh.start_date
			then
				call valid_error("Validation",
										"Invalid date value",
										"I")
				next field rectify_date
			end if

		after field rectify_time_h
			if vlr_defi_rect.rectify_time_h is not null
			then
				if not valid_hours(vlr_defi_rect.rectify_time_h)
				then
					call valid_error("Validation",
										"Invalid value for hours in time",
										"I")
					next field rectify_time_h
				end if
			end if

		after field rectify_time_m
			if vlr_defi_rect.rectify_time_m is not null
			then
				if not valid_minutes(vlr_defi_rect.rectify_time_m)
				then
					call valid_error("Validation",
										"Invalid value for minutes in time",
										"I")
					next field rectify_time_m
				end if
			end if

		on action cancel
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action Close
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action Exit
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action text
			if not lock_text(vlr_defh.cust_def_no, "D")
			then
				return
			end if
			if skey_check("UPD_COMP_DEST_TEXT","ALL") = "Y"
			then
				select complaint_no 
					into vl_complaint_no
				from comp
					where dest_ref = vlr_defh.cust_def_no
					and action_flag = "D"
				if length(vl_complaint_no)
				then
					if not lock_text(vl_complaint_no, "C")
					then
						return
					end if
				end if
			end if
			if add_scroll_defi_nb(vlr_defh.cust_def_no,
								vlr_defi.feature_ref,
								vlr_defi.item_ref,
								vg_text_mode)			#AB 25/05/1995
			then										#CRO80
				let vlr_defi.text_flag = "Y"
				display by name vlr_defi.text_flag 
			end if
			#ADJ 101005 Text Locking
			call unlock_text(vlr_defh.cust_def_no, "D")
			if skey_check("UPD_COMP_DEST_TEXT","ALL") = "Y"
			then
				if length(vl_complaint_no)
				then
					call unlock_text(vl_complaint_no, "C")
				end if
			end if

		after input
			case
				when not length(vlr_defi.volume)
					next field volume

				when not length(vlr_defi.next_action)
					next field next_action

				when vlr_defi_rect.rectify_date is null
					next field rectify_date

				when not length(vlr_defi_rect.rectify_time_h)
					next field rectify_time_h

				when not length(vlr_defi_rect.rectify_time_m)
					next field rectify_time_m

			end case
			let vl_exit = "A"
	end input
	return vl_exit
end function	


function add_nondef_non_p_and_v_default()
	define 	
		vl_exit				char(1),
		vl_vol_flag			char(1),
		vl_volume			like defi.volume,
		vl_default_reason	like defi.default_reason,
		vl_p_and_v_flag		smallint,
		vl_complaint_no		like comp.complaint_no

	input by name vlr_defi.volume,
				vlr_defi.next_action without defaults 

{
		on key(f2)
			call valid_error("", 
				"There are no lookups available on this field", "")
}

		before field volume
			if vlr_defi.volume is null
			then
				let vl_volume = 0
			else
				let vl_volume = vlr_defi.volume 
			end if

		after field volume
			if vlr_defi.volume is not null
			then
				if skey_check("DEF_CHECK_WHOLE_VOL", "ALL") = "Y"
				then
					let vl_vol_flag = chk_volume(vlr_defh.site_ref,
												vlr_defi.item_ref,
												vlr_defh.contract_ref,
												vlr_defi.feature_ref,
												vlr_defi.volume)
					case vl_vol_flag
						when 2
							call valid_error("",
							"The volume entered exceeds the site item volume",
								"")
							next field volume

						when 3
							call valid_error("",
			"The whole volume has been defaulted for the selected site item",
								"")
							next field volume
					end case
				end if		
			else
				call valid_error("","A valid volume must be entered","")
				next field volume
			end if

		before field next_action
			if not length(vlr_defi.next_action)
			then
				if skey_check("WHAT_NEXT_ACTION", "ALL") = "Y"
				then
					let vlr_defi.next_action = "I"
				else
					let vlr_defi.next_action = "N"
				end if
				display by name vlr_defi.next_action 
			end if

		after field next_action
			if vlr_defi.next_action not matches "[INL]"
			then	
				call valid_error("",
					"A valid next action must be entered", "")
				next field next_action
			end if

		on action cancel
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action Close
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action Exit
			if continue_yn("Abort new rectification entry")
			then
				let int_flag = false
				let vl_exit = "I"
				exit input
			end if

		on action text
			if not lock_text(vlr_defh.cust_def_no, "D")
			then
				return
			end if
			if skey_check("UPD_COMP_DEST_TEXT","ALL") = "Y"
			then
				select complaint_no 
					into vl_complaint_no
				from comp
					where dest_ref = vlr_defh.cust_def_no
					and action_flag = "D"
				if length(vl_complaint_no)
				then
					if not lock_text(vl_complaint_no, "C")
					then
						return
					end if
				end if
			end if
			if add_scroll_defi_nb(vlr_defh.cust_def_no,
								vlr_defi.feature_ref,
								vlr_defi.item_ref,
								vg_text_mode)			#AB 25/05/1995
			then										#CRO80
				let vlr_defi.text_flag = "Y"
				display by name vlr_defi.text_flag 
			end if
			#ADJ 101005 Text Locking
			call unlock_text(vlr_defh.cust_def_no, "D")
			if skey_check("UPD_COMP_DEST_TEXT","ALL") = "Y"
			then
				if length(vl_complaint_no)
				then
					call unlock_text(vl_complaint_no, "C")
				end if
			end if

		after input
			case
				when not length(vlr_defi.volume)
					next field volume

				when not length(vlr_defi.next_action)
					next field next_action
			end case
			let vl_exit  = "A"
	end input
	return vl_exit
end function
