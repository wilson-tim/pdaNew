
# complain.4gl "Version 6.125"

database universe

# complain.4gl
# Contender Version 7.0
{
 (c) 2003 DataPro Software Limited
 This program is the property of DataPro Software Limited.
 YOU MAY NOT use, copy, modify, or transfer the program,
 or any copy, modification, or merged portion of the program,
 in whole or in part, without the express permission of
 DataPro Software Limited.
 This module allows the user to enter, query and update Complaints.
 It links to *_comp.4gl for functions specific to a Service.

VER		DATE		PROG			PROJ
___________________________________________________________________________
5.100	30/05/02	Ken Jenkins		CE00024
					Enforcements	New Service: ENFORC
__________________________________________________________________________
5.103	24/06/02	Ken Jenkins		CE00024
					Enforcements delete related comp_enf.
 					Enforcements Query by Suspect Detail (vg_query_text).
 					Enforcements Query by Action Detail (vg_query_text).
___________________________________________________________________________
5.104	22/07/02	Ken Jenkins		CE00024
 					Enforcements Query speed up. New col comp_enf.car_id.
___________________________________________________________________________
6.43	05/09/02	Ken Jenkins		CE00024
 					AJ batch #83.
 					"Show-dest" label corrected after deletion.
___________________________________________________________________________
6.88	24/09/03	Ken Jenkins		CE000??
 					AV Islington: AV "Show-detail"
					expanded, including Works Orders.
___________________________________________________________________________
}

globals "../UTILS/globals.4gl"
globals "../ENFORCE/enf_glob.4gl"

DEFINE
    va_attachment_flag_color  DYNAMIC array of record
		attachment_flag     STRING
	end record,
    va_attachment_flag  DYNAMIC array of record
		attachment_flag     CHAR(80)
	end record,
	vgs_comp_correspond	record like comp_correspond.*,	
	vg_comp_save		record like comp.*,	
	vg_customer_save	record like customer.*,	
	vr_site_detail		record like site_detail.*,
	vr_comp_clin		record like comp_clin.*,
#	vr_comp_weee_sale	record like comp_weee_sale.*,
	vr_comp_nappy		record like comp_nappy.*,
	vr_comp_av			record like comp_av.*,
#	vr_comp_trade		record like comp_trade.*,
	m_comp_save_text   	array[500] of record
		txt				like comp_text.txt
	end record,
	m_comp_save_text_u	array[500] of record
		seq				integer,
		doa				like comp_text.doa,
		time_entered_h	like comp_text.time_entered_h,
		time_entered_m	like comp_text.time_entered_m,
		username		like comp_text.username
	end record,
	vg_disp_sl_sf		dynamic array of record 
		unit_no				like sl_sf.unit_no,
#		furniture_type		char(7),
		furniture_desc		like sl_furniture.furniture_desc,
		unit_position		like sl_sf.unit_position,
		comp_code			like comp_sl.comp_code,
		repair_type			like sl_sf_hist.repair_type,
		out_of_lighting	char(1),
		sl_status			like comp_sl.sl_status
			end record,
	vg_hidden_sl_sf		dynamic array of record
		inv_id				like sl_sf.inv_id,
		seq_no				smallint,
		lookup_text			like allk.lookup_text,
		sent_date			like comp_sl.sent_date,
		sent_time_h			char(5),
		sent_time_m			char(5) # ,
#		out_of_lighting	char(1)
			end record,
	m_comp_save_arr_count	smallint,
	vg_clin_item		char(13),
	vg_nappy_item		char(13),
	vg_bv199_item		char(12),
	vg_runner_call		smallint,
	vg_sl_count			smallint,
	vg_sl_line			smallint,
	vg_task_line		smallint,
	vg_show_source		smallint,
	vg_loc_change		smallint,
	vg_off_change		smallint,
	vg_f2_pressed		smallint,
	vg_sc_line			smallint,
	vg_ac_line			smallint,
	vg_title			char(80),
	m_curr_row			integer,
	vg_act				char(1),
	vg_query_text  		char(2000),
	vg_tot_in_list		integer,
	vg_progress			integer,
	vl_addwaste_point,
	vl_addwaste_count	integer,
	vg_url				char(1000),
	vg_zoom				char(10),
	vg_map_easting		char(20),
	vg_map_northing		char(20),
	vlr_addwaste   		array[50] of record
		waste_ref 			like comp_flycap_addw.waste_ref,
		waste_desc	 		like allk.lookup_text,
		waste_qty	 		like comp_flycap_addw.waste_qty
	end record,
#	vr_comp_adhoc_sample record like comp_adhoc_sample.*,  # now in globals
#	vr_comp_monitor 	record like comp_monitor.*,  # now in globals
	vlr_fly_loads		record like fly_loads.*,
	vlr_comp_addw		record like comp_flycap_addw.*,
	vl_land_desc		like allk.lookup_text,
	vl_waste_desc		like allk.lookup_text,
	vg_agreement_no		like agreement.agreement_no,
	vg_trade_site_no	like agreement.site_ref,
	cb 					ui.ComboBox

define
{
# BJG - Moved to globals 18/11/2008 ############################
	va_deft				dynamic array of record like deft.*,
	va_disp_deft   		dynamic array of record
		def_seq_no          like deft.seq_no,
		def_action_desc     char(13),
		def_action_date     date,
		def_action_time_h   char(2),
		def_action_time_m   char(2),
		def_action_user     char(8),
		def_points          like deft.points,
		def_value           like deft.value,
		def_rectify_date    date,
		def_rectify_time_h  char(2),
		def_rectify_time_m  char(2)
	end record,
	vg_deft_count 		smallint,
	va_works_order		dynamic array of record
		woi_no 				like wo_i.woi_no,
		woi_site_ref 		like wo_i.woi_site_ref,
		woi_task_ref 		like wo_i.woi_task_ref,
		woi_item_price 		like wo_i.woi_item_price,
		woi_volume 			like wo_i.woi_volume,
		woi_line_total 		like wo_i.woi_line_total,
		woi_comp_date 		like wo_i.woi_comp_date
	end record,
	vg_wo_count 		smallint,
	vg_wo_line			smallint,
	vm_attach 			dynamic array of record
		orig_file_name 		like attachments.orig_file_name,
		comment 			like attachments.comment,
		doa 				like attachments.doa,
		username 			like attachments.username
	end record,
	vm_attach_no 		dynamic array of like attachments.attach_no,
	vm_comp_text 		dynamic array of record
		username 		like comp_text.username,
		doa 				like comp_text.doa,
		txt	 			like comp_text.txt
	end record,
	vm_disp_cust 		dynamic array of char(80),
	va_dummy		dynamic array of record
		dummy_line				char(20)
	end record,
	va_actions		dynamic array of record
		act_seq					integer,
		action_ref				like enf_action.action_ref,
		action_date				like enf_action.action_date,
		due_date					like enf_action.due_date,
		paid_date				like enf_action.paid_date,
		act_enf_status			like enf_action.enf_status,
		aut_officer				like enf_action.aut_officer,
		act_text_flag			like enf_action.text_flag,
		plea						like enf_action.plea,
		judgement				like enf_action.judgement,
		penalty					like enf_action.penalty_ref,
		costs						like enf_action.costs,
		fine						like enf_action.fine,
		suspect_ref				like enf_action.suspect_ref,
		days						char(5)
	end record,
	va_actions_color	dynamic array of record
		act_seq					string,
		action_ref				string,
		action_date				string,
		due_date					string,
		paid_date				string,
		act_enf_status			string,
		aut_officer				string,
		act_text_flag			string,
		plea						string,
		judgement				string,
		penalty					string,
		costs						string,
		fine						string,
		suspect_ref				string,
		days						string
	end record,
	vr_enf_suspect		record like enf_suspect.*,
	va_suspect		dynamic array of record
		susp_column_name		char(20),
		susp_column_value		char(200)
	end record,
	va_evidence 		dynamic array of record
		username 		like comp_text.username,
		doa 				like comp_text.doa,
		txt	 			like comp_text.txt
	end record,
	va_action_text 		dynamic array of record
		action_date 	like enf_act_text.action_date,
		action_ref 		like enf_act_text.action_ref,
		username 		like enf_act_text.username,
		doa 				like enf_act_text.doa,
		txt	 			like enf_act_text.txt
	end record,
	va_costs 		dynamic array of record
		action_code 	like enf_cost_trans.action_code,
		rate_code 		like enf_cost_trans.rate_code,
		qty 				like enf_cost_trans.qty,
		unit_price 		like enf_cost_trans.unit_price,
		value 			like enf_cost_trans.value,
		text 				like enf_cost_trans.text,
		username 		like enf_cost_trans.username,
		cost_date	 	like enf_cost_trans.cost_date
	end record,
	vm_total_costs		like enf_cost_trans.value,
# BJG - Moved to globals 18/11/2008 ############################
}
	vm_current_page		char(20),
	vg_related_count		integer

define
	vg_cur_pos			smallint

function complain_main(vl_complaint_no, vl_action_type, vl_runner_call, vl_act)
	define 
		vl_complaint_no		like comp.complaint_no,
		vl_a_menu_desc		char(80),
		vl_q_menu_desc		char(80),
		vl_action_type 		smallint,
		vl_runner_call		smallint,
		vl_act				char(1),
		w					ui.Window,
		f					ui.Form

    CALL va_attachment_flag.clear()
    CALL va_attachment_flag.appendElement()
    CALL va_attachment_flag_color.clear()
    CALL va_attachment_flag_color.appendElement()

	let w = ui.Window.getCurrent()
	let f = w.getForm()

	call set_comp_options()

	let vg_enforce_ref = 0
	let vg_action_type = vl_action_type
	let vg_runner_call = vl_runner_call
	let vg_act = vl_act

	#ADJ GENERO
	if vl_complaint_no
	then
		select * into vr_comp.* from comp
			where complaint_no = vl_complaint_no
	end if

	let vg_clin_item = skey_check("CLIN_ITEM", "ALL")
	let vg_nappy_item = skey_check("NAPPY_ITEM", "ALL")
	let vg_clin_item = vg_clin_item clipped, "*"
	let vg_nappy_item = vg_nappy_item clipped, "*"
	let vg_bv199_item = skey_check("BV199_ITEM", "ALL")
	let vg_show_source = false

	#ADJ GENERO
	call reset_comp_form_variables()
	let m_normalform_open = true

	let m_avform_open = false
	let m_trform_open = false
	let m_clform_open = false
	let m_npform_open = false
	let vg_loc_change = false
	let vg_off_change = false

	call set_comp_options()

	if vl_complaint_no is null or vl_complaint_no < 1
	then
		if vg_customer_retain
		then
			# We need to keep the existing complainant info...
			let vg_f3_pressed = true
			message "Add new details"
			call add_complain()
			message ""

			#ADJ GENERO
			call qrywindow_of()
			call qrycomp_of()

			initialize vr_diry.* to null
			call centre(4, 1, vg_company)
		else
			if vg_display_menu_icons = "Y"
			then
				let vl_a_menu_desc = "(A)dd a new ", 
					downshift(vg_record_title) clipped, " to the database." 
				let vl_q_menu_desc = "(Q)uery a specific ", 
					downshift(vg_record_title) clipped, "."
			else
				let vl_a_menu_desc = "Add a new ", 
					downshift(vg_record_title) clipped, " to the database." 
				let vl_q_menu_desc = "Query a specific ", 
					downshift(vg_record_title) clipped, "."
			end if

#			menu vg_comp_title
			menu " "
				before menu
					hide option all
					show option "Exit"
					show option "Add"
					show option "Query"

					if not quiet_allow("complain_add")
					then
						hide option "Add"
					end if
					if not quiet_allow("complain_query")
					then
						hide option "Query"
					end if

				command key(control-t)
					let vr_comp.complaint_no = 0
					call complaint_history()

				on action Add
					let vg_customer_retain = false
					initialize vr_comp.* to NULL
					let vg_enforce_ref = 0
					message "Add new details"
					call add_complain()
					message ""

					#ADJ GENERO
					call qrywindow_of()
					call qrycomp_of()

					initialize vr_diry.* to null
					call centre(4, 1, vg_company)

				on action Query
					let vg_q_flag = 1
					while vg_q_flag = 1
						if not allow("query_comp")
						then
							let vg_q_flag = 3
							exit while
						else
							let vg_title = vg_comp_title clipped, " Query"
							let vg_show_source = false
							message "Enter query criteria"
							let vg_q_flag = query_complain(0)
#							current window is iw_complain
							message ""
							clear form
							call complain_labels()
#							display "Reference" to reference_label
#							display "History" to history_title
						end if
					end while
					case vg_q_flag
						when 0		# User pressed "DEL" key
							next option "Query"

						when 2		# User chose "Add" from the STEP menu
							let vg_customer_retain = false
							initialize vr_comp.* to null
							message "Add new details"
							call add_complain()
							message""

							#ADJ GENERO
							call qrywindow_of()
							call qrycomp_of()

						when 3	# User has deleted all rows in old query-list
							exit case

						otherwise
							call centre(4, 1, vg_company)
							next option "Query"
					end case
					call set_comp_options()
					call centre(4, 1, vg_company)

				on action about
					call os_exec("exec fglgo_about", 1)

				on action Exit
					exit menu

				on action close
					exit menu
			end menu
		end if
	else
		let vg_show_source = true
		if allow("query_comp")
		then
			let vg_q_flag = query_complain(vl_complaint_no)
		end if
	end if

#	if vg_action_type
#	then
#		call qrycomp_cf()
#	end if	
end function	# complain_main


function add_complain()
	define
		vl_comp_code		char(10),
		vl_centre_code		char(10),
		vl_mess				char(80),
		vl_search			char(80),
		vl_comp_code_flag	smallint,
		vl_exit_flag 		char(1)

	call addwindow_of()

#	let vr_comp.service_c = skey_check("DEFAULT SERVICE", "ALL")
	let vr_comp.service_c = vg_default_service

	if not vg_enforce_ref
	then
		let vg_comp_init_variables = true
		let vg_allow_text_clear = false
	end if
	let vg_enforce_added = false

# BJG - clear global areas at start of new add complaint string to avoid
# retention of earlier or queried complaints when in MULTI_COMPLAIN mode.
	initialize vg_av_arr.* to null
	initialize vg_enf_arr.* to NULL
    initialize vr_comp_trade.* to NULL
	initialize vr_comp_agreq.* to null
	initialize vr_comp_tree.* to null
	initialize vr_comp_gm.* to null
	initialize vr_comp_hway.* to null
	initialize vr_comp_measurement.* to null
	initialize vg_clin_site.* to null
	initialize vg_agreement_no to null
	initialize vl_centre_code to null
	call reset_wo_h_text() # BJG 18/11/2010 - always clear wo text
	call clear_wo_text() # BJG 22/11/2010 - always clear wo text

	call add_comp_while_loop()

{ BJG - Code below copied to a new function as also used by replicate ****
	while true 
		let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
		case 
			when vg_ms_installation = "Y"
					and vg_ms_fault_codes matches vl_comp_code
					and length(vr_comp.comp_code)
				call add_measurement_complain(vl_comp_code_flag)
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					let vl_comp_code_flag = false
					continue while
				else
					if vl_exit_flag = "S"
					then
						let vl_comp_code_flag = true
						continue while
					else
						return
					end if
				end if

			when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "N"
					and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
				if vg_sched_collect_items = "Y"
				then
					call add_sched_item_complain()
						returning vl_exit_flag
				else
					call add_sched_complain()
						returning vl_exit_flag
				end if
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "Y"
					and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
				if vg_sched_collect_items = "Y"
				then
					call add_weee_sched_item_complain("")
						returning vl_exit_flag
				else
					call add_weee_sched_complain("")
						returning vl_exit_flag
				end if
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_nappy_service
					and vg_nappy_installation = "Y"
				call add_nappy_complain("")
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_clin_service
					and vg_clin_installation = "Y"
				call add_clin_complain("")
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
			when vr_comp.service_c = vg_weee_service
					and vg_weee_installation = "Y"
				call add_weee_complain("")
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
			when vr_comp.service_c = vg_weee_sales_service
					and vg_sales_installation = "Y"
#				if skey_check("WEEE_ENTITLEMENT", "ALL") = "Y"
				if vg_weee_sales_entitlement = "Y"
				then
#					call add_weee_sales_ent_complain("")
#						returning vl_exit_flag
					call add_weee_sales_ent_complain(vl_centre_code)
						returning vl_exit_flag, vl_centre_code
				else
#					call add_weee_sales_complain("")
#						returning vl_exit_flag
					call add_weee_sales_complain(vl_centre_code)
						returning vl_exit_flag, vl_centre_code
				end if
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
			when vr_comp.service_c = vg_trade_service
					and vg_trade_installation = "Y"
				if vg_agreement_no
				then
					select site_ref into vg_trade_site_no
						from agreement
						where agreement_no = vg_agreement_no
					call add_trade_complain(vg_trade_site_no,vg_agreement_no)
						returning vl_exit_flag
				else
					call add_trade_complain("","")
						returning vl_exit_flag
				end if
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
			when vr_comp.service_c = vg_enf_service
					and vg_enf_installation = "Y"
				if quiet_allow("enf_add_upd")
				and not vg_enforce_ref # cannot raise enforcement from enforcement
				then
					call add_enf_complain(0)
						returning vl_exit_flag
					if vl_exit_flag = "C"
					then
						continue while
					else
						return
					end if
				else
					let vr_comp.service_c = vg_default_service
					continue while
				end if
#ADJ ENFTR			
			when vr_comp.service_c = vg_enf_trade_service
					and vg_enf_trade_installation = "Y"
				if quiet_allow("enf_add_upd")
				and not vg_enforce_ref # cannot raise enforcement from enforcement
				then
					call add_enf_trade_complain(0)
						returning vl_exit_flag
					if vl_exit_flag = "C"
					then
						continue while
					else
						return
					end if
				else
					let vr_comp.service_c = vg_default_service
					continue while
				end if
			when vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
				call add_av_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
			when vr_comp.service_c = vg_hway_service
				and vg_hway_installation = "Y"
				call add_hway_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
			when vr_comp.service_c = vg_sl_service
				and vg_sl_installation = "Y"
				call add_sl_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_gm_service
				and vg_gm_installation = "Y"
				call add_gm_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
			when vr_comp.service_c = vg_ert_service
				and vg_ert_installation = "Y"
				and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
				call add_ert_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
			when vr_comp.service_c = vg_trees_service
				and vg_trees_installation = "Y"
				call add_tree_complain("", "")
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_agreq_service
					and vg_agreq_installation = "Y"
				call add_agreq_complain()
						returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			otherwise
				# Just make sure the service exists then normal add
				let vl_search = "keys.service_c = '", 
								vr_comp.service_c clipped, "'"

				if no_of_rows("keys", vl_search, "") = 0
				then 
					let vl_mess = " The Service code ", vr_comp.service_c, 
						" does not exist" 
					call valid_error("",vl_mess,"")
					return
				else
					call add_normal_complain(vl_comp_code_flag)
						returning vl_exit_flag
					if vl_exit_flag = "C"
					then
						let vl_comp_code_flag = false
						continue while
					else
						if vl_exit_flag = "S"
						then
							let vl_comp_code_flag = true
							continue while
						else
							return
						end if
					end if
				end if
		end case

		exit while

	end while 
BJG - end of copied code ************ }
	 
end function	# add_complain


function complaint_print_confirm() 
    define 
        f_return_code       char( 1 )

    open window Wconfirm with form "comp_print_select"

	let f_return_code = "T"

    input by name f_return_code without defaults
		after input
			if not length(f_return_code)
			then
				call valid_error("",
					"At least one print destination must be selected", "") 
				next field f_return_code
			end if

	end input
    close window Wconfirm 

    return f_return_code 
end function    # complaint_print_confirm 


function query_complain(vl_complaint_no)
# returns: 0 error condition encountered in query
#          1 User selected "Add" from step menu
#          2 User selected "Query" from step menu
	define
		vlr_comp_save			record like comp.*,
		vlr_diry_save			record like diry.*,
		vlr_si_i_save			record like si_i.*,
		vlr_customer_save		record like customer.*,
		fv_def_cont_i			record like def_cont_i.*,
		vl_action_flag			like comp.action_flag,
		vl_complaint_no		  	like comp.complaint_no,
		vl_user				  	like diry.source_user,
		vl_wo_key				like wo_h.wo_key,
		vl_wo_type_f_new		like wo_h.wo_type_f,
		vl_task_ref				like task.task_ref,
		vl_act_flag			    like comp.action_flag,
		vl_act_flag_save	  	like comp.action_flag,
		vl_prev_record		  	like diry.prev_record,
		vl_service_c		    like keys.service_c,
		vl_exit_flag 		    like keys.service_c,
		v_source_ref 		    like diry.source_ref,
		v_dest_ref			    like diry.dest_ref,
		vl_lookup_text		  	like keys.c_field,
		vl_evidence				like comp_enf.evidence,
		vl_enforcement_ref		like comp_enf.source_ref,
		f_complaint_no			like comp.complaint_no,
		vl_length			  	smallint,						
		vl_customer				smallint,
		vl_comp_agreq		  	smallint,						
		vl_comp_av			  	smallint,						
		vl_comp_weee			smallint,						
		vl_comp_weee_sale		smallint,						
		vl_comp_hway		    smallint,						
		vl_comp_meas		    smallint,						
		vl_comp_sl			    smallint,						
		vl_comp_enf			    smallint,						
		vl_comp_gm			    smallint,						
		vl_q_flag			    smallint,	# Holds the return code
		vl_del_flag			    smallint,	
		vl_where_part		    char(2000), #The "where" clause from cnstrct
		vl_det_where_part	  	char(1000), #The detailed "where" clause 
		vl_det_where_part_ii  	char(1000), #The second detailed "where" clause 
		vl_det_where_part_iii  	char(1000), #The third detailed "where" clause 
		vl_txt_part			    char(150),  #The detailed "where" clause 
		vl_txt_part_ii		    char(150),  #The detailed "where" clause 
		vl_imp_part			    char(1000),						
		vl_like_service		  	char(25),						
		vl_runcomm			    char(100),						
		vl_text				    char(80),						
		vl_tmp_char			    char(80),						
		vl_diry_ref			    char(12),						
		vl_comp_code			char(10),
		username			    char(20),						
		vl_trade_ref 		    integer,						
		vl_null				    smallint,						
		vl_normal_query		  	smallint,						
		vl_source_query		  	smallint,						
		vl_av_query			    smallint,						
		vl_weee_query		    smallint,						
		vl_weee_sales_query		smallint,						
		vl_enf_query		    smallint,						
		vl_enftr_query		    smallint,						
		vl_clin_query		    smallint,						
		vl_nappy_query		  	smallint,						
		vl_trade_query		  	smallint,						
		vl_agreq_query		  	smallint,						
		vl_hway_query		    smallint,						
		vl_measurement_query	smallint,
		vl_sl_query			    smallint,						
		vl_gm_query			    smallint,						
		vl_ert_query		    smallint,						
		vl_tree_query		    smallint,						
		vl_sched_query		  	smallint,						
		vl_weee_sched_query		smallint,						
		vl_attach_no 		    integer,						
		vl_a_menu_desc		  	char(80),						
		vl_q_menu_desc		  	char(80),						
		vl_f_menu_desc		  	char(80),						
		vl_n_menu_desc		  	char(80),
		vl_p_menu_desc		  	char(80),
		vl_pe_menu_desc		  	char(80),
		vl_fs_menu_desc		  	char(80),
		vl_ho_menu_desc		  	char(80),
		vl_l_menu_desc		  	char(80),
		vl_o_menu_desc		  	char(80),
		vl_s_menu_desc		  	char(80),
		vl_sd_menu_desc		  	char(80),
		vl_dd_menu_desc		  	char(80),
		vl_ag_menu_desc		  	char(80),
		vl_u_menu_desc		  	char(80),
		vl_r_menu_desc		  	char(80),
		vl_h_menu_desc		  	char(80),
		vl_i_menu_desc		  	char(80),
		vl_c_menu_desc		  	char(80),
		vl_d_menu_desc		  	char(80),
		vl_t_menu_desc		  	char(80),
		vl_e_menu_desc			char(80),
		vl_hpi_menu_desc	  	char(80),
		vl_wo_menu_desc		  	char(80),
		vl_message_text			char(80),
		vl_police_email			char(80),
		vl_fire_email			char(80),
		vl_housing_email		char(80),
		vl_runstr			    char(255),
		vl_save_action_type		char(1),
		vl_date_police_email	date,
		vl_date_fire_email		date,
		vl_date_housing_email	date,
		vl_return_date			date,
		vl_date				    date,
		vl_date_2			    date,
		vl_count					integer,
		vl_id						integer,
		vl_insp_item_flag		like item.insp_item_flag,
		vl_current_text		integer,
		vl_task_desc			like task.task_desc,
		vl_comp_text			like work_schedule.waste_type,
		vl_quantity				like work_schedule.quantity,
		vl_weighting_total	like work_schedule.weighting_total,
		vlr_wo_stat				record like wo_stat.*,
		vl_wo_payment_f		like wo_h.wo_payment_f,
        v_unjust_reason     LIKE def_cont_i.unjust_reason

#	current window is iw_complain
	let vm_current_page = "generic_page"

	let vl_exit_flag = null
	let vl_null = null
	let int_flag = false
	initialize vr_qry_import.* to null
	let vr_qry_import.waiting = "N"
	let vr_qry_import.live = "L"
	let vr_qry_import.discarded = "N"

	let vl_source_query = false
	let vl_av_query = false
		# WEEE
	let vl_weee_query = false
	let vl_weee_sales_query = false
	let vl_enf_query = false
	let vl_enftr_query = false
	let vl_sl_query = false
	let vl_gm_query = false
	let vl_ert_query = false
	let vl_tree_query = false
	let vl_hway_query = false
	let vl_measurement_query = false
	let vl_clin_query = false
	let vl_nappy_query = false
	let vl_trade_query = false
	let vl_agreq_query = false
	let vl_sched_query = false
	let vl_weee_sched_query = false
	let vl_normal_query = false
	let vl_source_query = false
	
	initialize vr_comp.* to null

	if vl_complaint_no is null or vl_complaint_no < 1
	then
		case
			when vg_default_service = vg_nappy_service
			and vg_nappy_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_nappy_query = true

			when vg_default_service = vg_clin_service
				and vg_clin_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_clin_query = true

			when vg_default_service = vg_enf_service
				and vg_enf_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_enf_query = true
#ADJ ENFTR
			when vg_default_service = vg_enf_trade_service
				and vg_enf_trade_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_enftr_query = true

			when vg_default_service = vg_av_service
				and vg_av_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_av_query = true

			when vg_default_service = vg_weee_service
				and vg_weee_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_weee_query = true

			when vg_default_service = vg_weee_sales_service
				and vg_sales_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_weee_sales_query = true

			when vg_default_service = vg_sl_service
				and vg_sl_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_sl_query = true
			
			when vg_default_service = vg_gm_service
				and vg_gm_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_gm_query = true

			when vg_default_service = vg_ert_service
				and vg_ert_installation = "Y"
				and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_ert_query = true

			when vg_default_service = vg_trees_service
				and vg_trees_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_tree_query = true

			when vg_default_service = vg_hway_service
				and vg_hway_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_hway_query = true

			when vg_default_service = vg_trade_service
				and vg_trade_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_trade_query = true

			when vg_default_service = vg_agreq_service
				and vg_agreq_installation = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_agreq_query = true

			when vg_default_service = vg_sched_service
				and vg_sched_installation = "Y"
				and vg_weee_installation = "N"
				and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
				let vr_comp.service_c = vg_default_service
				let vl_sched_query = true

			otherwise
				let vl_normal_query = true
		end case
	else
		let vl_source_query = true
	end if
	
	initialize vr_comp_correspond.* to null
	initialize vr_customer.* to null
	initialize vr_comp_clink.* to null
	initialize vr_qry_comp.* to null
	let generic_action_text	= null
	let av_action_text = null
	let gm_action_text = null
	let hway_action_text = null
	let ert_action_text = null
	let trade_action_text = null
	let weee_action_text = null
	let sched_action_text = null
	let agreq_action_text  = null
	let clin_action_text = null
	let ert_action_text	= null
	let nappy_action_text = null
	let sales_action_text = null
	let tree_action_text = null
	initialize vg_qry_comp_weee_sale.* to null
	initialize vg_av_arr.* to null
	initialize vg_enf_arr.* to null
	initialize vg_enf_qry.* to null
	initialize vgr_enf_suspect.* to null
	initialize vgr_enf_company.* to null
	initialize vgr_enf_action.* to null
	initialize eg_comp_text.* to null
	initialize eg_evidence_text.* to null
	initialize vg_comp_sl.* to null
	initialize vg_clin_site.* to null
	initialize vg_nappy_site.* to null
	initialize vr_comp_enf_hist.* to null
	initialize vr_comp_enf.* to null
	initialize vr_comp_hway.* to null
	initialize vr_comp_measurement.* to null
	initialize vg_qry_comp_ert.* to null
	initialize vr_comp_dart_header.* to null
	initialize vr_comp_ert_header.* to null
	initialize vr_comp_ert_detail.* to null
	initialize vr_comp_ert_tags.* to null
	initialize vr_site.* to null
	initialize vl_det_where_part_iii to null
	if vg_sw_installation = "Y"
	THEN
        let vg_f3_pressed = false
		call init_sw_values()
	end if
	
	while true
		while true
			if int_flag
			then
				let int_flag = false
				let vg_tot_in_list = -1
				exit while
			end if

			if vl_source_query
			then
				exit while
			end if

			if vl_hway_query
			then
				let vm_current_page = "hway_page"
				call query_hway_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_measurement_query
			then
				let vm_current_page = "meas_page"
				call query_measurement_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_enf_query
			then
				let vm_current_page = "enf_page"
				call query_enf_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_txt_part_ii, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_det_where_part_iii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_enftr_query
			then
				let vm_current_page = "enf_page"
				call query_enf_trade_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_txt_part_ii, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_det_where_part_iii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_av_query
			then
				let vm_current_page = "av_page"
				call query_av_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_nappy_query
			then
#				let vm_current_page = "nappy_page"
				let vm_current_page = "generic_page"
				call query_nappy_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_clin_query
			then
				let vm_current_page = "generic_page"
				call query_clin_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_weee_query
			then
				let vm_current_page = "weee_page"
				call query_weee_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_weee_sales_query
			then
				if vg_weee_sales_entitlement = "Y"
				then
					let vm_current_page = "weee_sales_ent_page"
					call query_weee_sales_ent_complain()
						returning vl_where_part, 
									vl_txt_part, 
									vl_det_where_part,
									vl_det_where_part_ii,
									vl_imp_part,
									vl_exit_flag
				else
					let vm_current_page = "weee_page"
					call query_weee_sales_complain()
						returning vl_where_part, 
									vl_txt_part, 
									vl_det_where_part,
									vl_det_where_part_ii,
									vl_imp_part,
									vl_exit_flag
				end if
			end if

			if vl_agreq_query
			then
				let vm_current_page = "agreq_page"
				call query_agreq_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_trade_query
			then
				let vm_current_page = "trade_page"
				call query_trade_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_sl_query
			then
				let vm_current_page = "sl_page"
				call query_sl_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_gm_query
			then
				let vm_current_page = "gm_page"
				call query_gm_complain()
					returning vl_where_part,
								vl_txt_part,
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

#ADJ140104ERT
			if vl_ert_query
			then
				let vm_current_page = "ert_page"
				call query_ert_complain()
					returning vl_where_part,
								vl_txt_part,
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_tree_query
			then
				let vm_current_page = "tree_page"
				call query_tree_complain()
					returning vl_where_part,
								vl_txt_part,
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_sched_query
			then
				let vm_current_page = "sched_page"
				call query_sched_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_weee_sched_query
			then
				let vm_current_page = "sched_page"
				call query_weee_sched_complain()
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			if vl_normal_query
			then
				let vm_current_page = "generic_page"
				call query_normal_complain("")
					returning vl_where_part, 
								vl_txt_part, 
								vl_det_where_part,
								vl_det_where_part_ii,
								vl_imp_part,
								vl_exit_flag
			end if

			let vl_trade_query = false
			let vl_agreq_query = false
			let vl_clin_query = false
			let vl_nappy_query = false
			let vl_hway_query = false
			let vl_measurement_query = false
			let vl_enf_query = FALSE
            let vl_enftr_query = false
			let vl_av_query = false
			let vl_weee_query = false
			let vl_weee_sales_query = false
			let vl_sl_query = false
			let vl_gm_query = false
			let vl_ert_query = false
			let vl_tree_query = false
			let vl_normal_query = false
			let vl_sched_query = false
			let vl_weee_sched_query = false
			let vl_source_query = false
			let vg_show_source = false
			let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
			case
				when vg_ms_installation = "Y"
				and vg_ms_fault_codes matches vl_comp_code
				and length(vr_qry_comp.comp_code)
				and vl_exit_flag != "A"
					let vl_measurement_query = true
				when vl_exit_flag = vg_nappy_service
					and vg_nappy_installation = "Y"
					let vl_nappy_query = true
				when vl_exit_flag = vg_clin_service
					and vg_clin_installation = "Y"
					let vl_clin_query = true
				when vl_exit_flag = vg_enf_service
					and vg_enf_installation = "Y"
					let vl_enf_query = true
#ADJ ENFTR
				when vl_exit_flag = vg_enf_trade_service
					and vg_enf_trade_installation = "Y"
					let vl_enftr_query = true
				when vl_exit_flag = vg_av_service
					and vg_av_installation = "Y"
					let vl_av_query = true
				when vl_exit_flag = vg_weee_service
					and vg_weee_installation = "Y"
					let vl_weee_query = true
				when vl_exit_flag = vg_weee_sales_service
					and vg_sales_installation = "Y"
					let vl_weee_sales_query = true
				when vl_exit_flag = vg_sl_service
					and vg_sl_installation = "Y"
					let vl_sl_query = true
				when vl_exit_flag = vg_gm_service
					and vg_gm_installation = "Y"
					let vl_gm_query = true
				when vl_exit_flag = vg_ert_service
					and vg_ert_installation = "Y"
					and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
					let vl_ert_query = true
				when vl_exit_flag = vg_trees_service
					and vg_trees_installation = "Y"
					let vl_tree_query = true

				when vl_exit_flag = vg_hway_service
					and vg_hway_installation = "Y"
					let vl_hway_query = true

				when vl_exit_flag = vg_trade_service
					and vg_trade_installation = "Y"
					let vl_trade_query = true

				when vl_exit_flag = vg_agreq_service
					and vg_agreq_installation = "Y"
					let vl_agreq_query = true

#				when vl_exit_flag = skey_check("SCHED_SERVICE", "ALL")
#					and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
				when vl_exit_flag = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "N"
					and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
					let vl_sched_query = true

#				when vl_exit_flag = skey_check("SCHED_SERVICE", "ALL")
#					and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
				when vl_exit_flag = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "Y"
					and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
					let vl_weee_sched_query = true

				when vl_exit_flag = "A"
					exit while

				when vl_exit_flag = "I"
					exit while

				otherwise 
					select count(*) from keys
						where service_c = vl_exit_flag
					if status = notfound
					then
						let vl_exit_flag = "A"
						exit while
					else
						let vl_normal_query = true
					end if
			end case

		end while  
	
		if vl_exit_flag = "I"
		then
			let int_flag = false
			let vg_q_flag = 0
			return 0
		end if

		if vl_source_query
		then
			let vg_query_text =
				" select comp.complaint_no, comp.service_c from comp",
				" where comp.complaint_no = ", vl_complaint_no using "<<<<<<&"
		else
			if not length(vl_txt_part_ii)
				and not length(vl_det_where_part)
				and not length(vl_det_where_part_iii)
				and vl_where_part not matches "*customer.*"
				and vl_where_part not matches "*comp_tr.*"
				and vl_where_part not matches "*comp_text.*"
				and vl_where_part not matches "*comp_import.*"
				and vl_where_part not matches "*formonly.qry_doa*"
				and vl_where_part not matches "*formonly.qry_username*"
				and vl_where_part not matches "*formonly.qry_txt*"
			then
				let vg_query_text =
					" select comp.complaint_no, comp.service_c from comp"
			else
				let vg_query_text =
					" select distinct comp.complaint_no, comp.service_c",
					" from comp"
			end if	

			let vl_comp_agreq = false
			let vl_comp_av = false
			let vl_comp_weee = false
			let vl_comp_weee_sale = false
			let vl_comp_hway = false
			let vl_comp_meas = false
			let vl_comp_sl = false
			let vl_comp_gm = false
			let vl_comp_enf = false
			let vl_customer = false

			if vl_det_where_part matches "*site.*"
			then
				let vg_query_text = 
					vg_query_text clipped, ", site"
			end if

			if vl_where_part matches "*customer.*"
			or vl_where_part matches "*comp_clink.*"
			or vl_det_where_part matches "*customer.*"
			then
				let vg_query_text = 
					vg_query_text clipped, ", customer, comp_clink"

				let vl_customer = true
			end if
			if vl_where_part matches "*agree_task.task_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"agree_task.task_ref",
								"comp_tr.task_ref")
			end if
			if vl_where_part matches "*formonly.qry_txt*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"formonly.qry_txt",
								"comp_text.txt")
			end if
			if vl_where_part matches "*formonly.qry_username*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"formonly.qry_username",
								"comp_text.username")
			end if
			if vl_where_part matches "*formonly.qry_doa*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"formonly.qry_doa",
								"comp_text.doa")
			end if

#			display vl_where_part clipped
			if vl_where_part matches "*generic_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"generic_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*av_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"av_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*gm_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*hway_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"hway_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*meas_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"meas_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*ert_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*trade_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*weee_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"weee_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*sched_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sched_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*agreq_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"agreq_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*clin_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"clin_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*ert_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*nappy_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"nappy_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*sales_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sales_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*tree_action_text*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_action_text", 
									"comp.action_flag")
			end if
			if vl_where_part matches "*generic_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"generic_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*av_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"av_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*gm_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*hway_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"hway_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*ert_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*trade_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*weee_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"weee_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*sched_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sched_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*agreq_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"agreq_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*clin_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"clin_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*ert_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*nappy_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"nappy_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*sales_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sales_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*tree_dest_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_dest_ref", 
									"comp.dest_ref")
			end if
			if vl_where_part matches "*generic_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"generic_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*av_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"av_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*gm_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*hway_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"hway_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*ert_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*trade_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*weee_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"weee_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*sched_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sched_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*agreq_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"agreq_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*clin_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"clin_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*ert_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*nappy_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"nappy_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*sales_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sales_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*tree_dest_suffix*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_dest_suffix", 
									"comp.dest_suffix")
			end if
			if vl_where_part matches "*generic_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"generic_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*av_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"av_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*gm_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*hw_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"hw_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*ert_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*trade_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*weee_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"weee_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*sched_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sched_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*agreq_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"agreq_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*clin_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"clin_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*ert_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*nappy_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"nappy_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*sales_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sales_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*tree_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*sl_date_closed*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sl_date_closed", 
									"comp.date_closed")
			end if
			if vl_where_part matches "*generic_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"generic_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*av_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"av_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*gm_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*hway_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"hway_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*ert_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*trade_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*weee_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"weee_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*sched_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sched_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*agreq_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"agreq_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*clin_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"clin_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*ert_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*nappy_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"nappy_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*sales_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sales_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*tree_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*sl_time_closed_h*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sl_time_closed_h", 
									"comp.time_closed_h")
			end if
			if vl_where_part matches "*generic_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"generic_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*av_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"av_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*gm_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*hway_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"hway_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*ert_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*trade_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*weee_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"weee_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*sched_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sched_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*agreq_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"agreq_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*clin_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"clin_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*ert_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*nappy_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"nappy_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*sales_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sales_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*tree_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*sl_time_closed_m*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"sl_time_closed_m", 
									"comp.time_closed_m")
			end if
			if vl_where_part matches "*gm_feature_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_feature_ref", 
									"comp.feature_ref")
			end if
			if vl_where_part matches "*gm_item_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_item_ref", 
									"comp.item_ref")
			end if
			if vl_where_part matches "*gm_item_desc*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_item_desc", 
									"item.item_desc")
			end if
			if vl_where_part matches "*gm_comp_code*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"gm_comp_code", 
									"comp.comp_code")
			end if
			if vl_where_part matches "*hway_comp_code*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"hway_comp_code", 
									"comp.comp_code")
			end if
			if vl_where_part matches "*ert_item_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_item_ref", 
									"comp.item_ref")
			end if
			if vl_where_part matches "*ert_comp_code*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_comp_code", 
									"comp.comp_code")
			end if
			if vl_where_part matches "*ert_item_info1*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"ert_item_info1", 
									"si_i.occur_day")
				let vg_query_text = vg_query_text clipped, ", si_i"
			end if

			if vl_where_part matches "*ert_item_info2*"
			then
				if skey_check("DISPLAY ROUND_C", vl_service_c) = "Y"
				then
					let vl_where_part = 
						replace_string(vl_where_part, 
									"ert_item_info2", 
									"comp.round_c")
				else
					let vl_where_part = 
						replace_string(vl_where_part, 
									"ert_item_info2", 
									"diry.pa_area")
					let vg_query_text = vg_query_text clipped, ", diry"
				end if
			end if
			if vl_where_part matches "*nappy_site_name*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"nappy_site_name", 
										"site.site_name")
				end if
				if vl_where_part matches "*trade_build_no*"
				then
					let vl_where_part = 
						replace_string(vl_where_part, 
										"trade_build_no", 
										"comp.build_no")
			end if
			if vl_where_part matches "*trade_build_name*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_build_name", 
									"comp.build_name")
			end if
			if vl_where_part matches "*trade_location_name*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_location_name", 
									"comp.location_name")
			end if
			if vl_where_part matches "*trade_location_desc*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_location_desc", 
									"comp.location_desc")
			end if
			if vl_where_part matches "*trade_postcode*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_postcode", 
									"comp.postcode")
			end if
			if vl_where_part matches "*trade_townname*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_townname", 
									"comp.townname")
			end if
			if vg_disp_county_or_postal = "Y"
			then
				if vl_where_part matches "*trade_posttown*"
				then
					let vl_where_part = 
						replace_string(vl_where_part, 
										"trade_posttown", 
										"comp.countyname")
				end if
			else 
				if vl_where_part matches "*trade_posttown*"
				then
					let vl_where_part = 
						replace_string(vl_where_part, 
										"trade_posttown", 
										"comp.posttown")
				end if
			end if
			if vl_where_part matches "*trade_area_ward_desc*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"trade_area_ward_desc", 
									"comp.area_ward_desc")
			end if
			if vl_where_part matches "*agreq_details_1*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"agreq_details_1", 
									"comp.details_1")
			end if
			if vl_where_part matches "*meas_comp_code*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"meas_comp_code", 
									"comp.comp_code")
			end if
			if vl_where_part matches "*meas_item_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"meas_item_ref", 
									"comp.item_ref")
			end if
			if vl_where_part matches "*meas_remarks_line*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"meas_remarks_line", 
									"comp.details_1")
			end if
			if vl_where_part matches "*tree_comp_code*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_comp_code", 
									"comp.comp_code")
			end if
			if vl_where_part matches "*tree_item_ref*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_item_ref", 
									"comp.item_ref")
			end if
			if vl_where_part matches "*tree_item_info1*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"tree_item_info1", 
									"si_i.occur_day")
				let vg_query_text = vg_query_text clipped, ", si_i"
			end if

			if vl_where_part matches "*tree_item_info2*"
			then
				if skey_check("DISPLAY ROUND_C", vl_service_c) = "Y"
				then
					let vl_where_part = 
						replace_string(vl_where_part, 
									"tree_item_info2", 
									"comp.round_c")
				else
					let vl_where_part = 
						replace_string(vl_where_part, 
									"tree_item_info2", 
									"diry.pa_area")
					let vg_query_text = vg_query_text clipped, ", diry"
				end if
			end if
			if vl_where_part matches "*weee_remarks_line*"
			then
				let vl_where_part =
						replace_string(vl_where_part, 
									"weee_remarks_line", 
									"comp.details_1")
			end if
			if vl_where_part matches "*item_info1*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
									"item_info1", 
									"si_i.occur_day")
				let vg_query_text = vg_query_text clipped, ", si_i"
			end if
			let vl_service_c = vg_default_service
			if vl_where_part matches "*item_info2*"
			then
				if skey_check("DISPLAY ROUND_C", vl_service_c) = "Y"
				then
					let vl_where_part = 
						replace_string(vl_where_part, 
									"item_info2", 
									"comp.round_c")
				else
					let vl_where_part = 
						replace_string(vl_where_part, 
									"item_info2", 
									"diry.pa_area")
					let vg_query_text = vg_query_text clipped, ", diry"
				end if
			end if

			if vl_where_part matches "*comp_nappy.*"
			or vl_where_part matches "*nappy_site.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_nappy"
			end if

			if vl_where_part matches "*comp_clin.*"
			or vl_where_part matches "*clin_site.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_clin"
			end if

			if vl_where_part matches "*comp_trade.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_trade"
			end if

			if vl_where_part matches "*comp_tr.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_tr"
			end if

			if vl_where_part matches "*comp_hway.*"
			or vl_where_part matches "*hway_status.*"
			or vl_det_where_part matches "*hway_status.*"
			then
				if length(vl_det_where_part)
				then
					let vg_query_text = vg_query_text clipped, 
						", comp_hway, hway_status"
				else
					let vg_query_text = vg_query_text clipped, ", comp_hway"
					if vl_where_part matches "*hway_status.*"
					then
						let vg_query_text = 
							vg_query_text clipped, ", hway_status"
					end if
				end if
				let vl_comp_hway = true
			end if

			if vl_where_part matches "*comp_measurement.*"
            THEN
				let vg_query_text = 
							vg_query_text clipped, ", comp_measurement"
                LET vl_comp_meas = true
            END IF
            
			if vl_where_part matches "*comp_av.*"
			or vl_where_part matches "*comp_av_hist.*"
			or vl_det_where_part matches "*comp_av_hist.*"
			then
				if length(vl_det_where_part)
				or vl_where_part matches "*comp_av_hist.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", comp_av, comp_av_hist"
				else
					let vg_query_text = vg_query_text clipped, ", comp_av"
				end if
				let vl_comp_av = true
			end if

			if vl_where_part matches "*comp_agreq.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_agreq"
				let vl_comp_agreq = true
			end if
		
			if vl_where_part matches "*comp_weee.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_weee"
				let vl_comp_weee = true
			end if

			if vl_where_part matches "*comp_weee_sale.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_weee_sale"
				let vl_comp_weee_sale = true
			end if

			if vl_where_part matches "*weee_centre.*"
			then
				if vl_comp_weee_sale
				then
					let vg_query_text = vg_query_text clipped, 
						", weee_centre"
				else
					let vg_query_text = vg_query_text clipped, 
						", comp_weee_sale, weee_centre"
				end if
				let vl_comp_weee_sale = true
			end if

			if vl_where_part matches "*weee_proof.*"
			then
				if vl_customer
				then
					let vg_query_text = vg_query_text clipped, 
						", weee_proof"
				else
					let vg_query_text = vg_query_text clipped, 
						", customer, comp_clink, weee_proof"
				end if
				let vl_customer = true
			end if

			if vl_where_part matches "*weee_load_item.*"
			then
				let vg_query_text = vg_query_text clipped, ", weee_load_item"
				if not vl_comp_weee
				then
					let vg_query_text = vg_query_text clipped, ", comp_weee"
					let vl_comp_weee = true
				end if
				if vl_where_part matches "*weee_load_dtl.*"
				then
					let vg_query_text = vg_query_text clipped, ", weee_load_dtl"
				end if
			else
				if vl_where_part matches "*weee_load_dtl.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", weee_load_dtl, weee_load_item"
					if not vl_comp_weee
					then
						let vg_query_text = vg_query_text clipped, ", comp_weee"
						let vl_comp_weee = true
					end if
				end if
			end if

			if vl_where_part matches "*officers.*"
			then
				let vg_query_text = vg_query_text clipped, ", officers"
				if not vl_comp_av	
				then
					let vg_query_text = vg_query_text clipped, ", comp_av"
					let vl_comp_av = true
				end if
			end if

			if vl_where_part matches "*colour.*"
			then
				let vg_query_text = vg_query_text clipped, ", colour"
				if not vl_comp_av	
				then
					let vg_query_text = vg_query_text clipped, ", comp_av"
					let vl_comp_av = true
				end if
			end if

			if vl_where_part matches "*models.*"
			then
				let vg_query_text = vg_query_text clipped, ", models"
				if not vl_comp_av	
				then
					let vg_query_text = vg_query_text clipped, ", comp_av"
					let vl_comp_av = true
				end if
			end if

			if vl_where_part matches "*makes.*"
			then
				let vg_query_text = vg_query_text clipped, ", makes"
				if not vl_comp_av	
				then
					let vg_query_text = vg_query_text clipped, ", comp_av"
					let vl_comp_av = true
				end if
			end if

			if vl_where_part matches "*nappy_site*"
			then
				let vg_query_text = vg_query_text clipped, ", nappy_site"
			end if	

			if vl_where_part matches "*clin_site*"
			then
				let vg_query_text = vg_query_text clipped, ", clin_site"
			end if	

			if vl_where_part matches "*comp_sl.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_sl"
				let vl_comp_sl = true
			end if	

			if vl_where_part matches "*comp_gm.*"
			or vl_where_part matches "*c_sf.*"
			or vl_where_part matches "*c_si.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_gm"
				let vl_comp_gm = true
				if vl_where_part matches "*c_sf.*"
				then
					let vg_query_text = vg_query_text clipped, ", c_sf"
				end if
				if vl_where_part matches "*c_si.*"
				then
					let vg_query_text = vg_query_text clipped, ", c_si"
				end if
			end if
			if vl_where_part matches "*feat.*"
			then
				let vg_query_text = vg_query_text clipped, ", feat"
			end if
			if vl_where_part matches "*item.*"
			then
				let vg_query_text = vg_query_text clipped, ", item"
			end if

			if vl_where_part matches "*sl_sf.*"
			then
				let vg_query_text = vg_query_text clipped, ", sl_sf"
				if not vl_comp_sl
				then
					let vg_query_text = vg_query_text clipped, ", comp_sl"
					let vl_comp_sl = true
				end if
			     
				if vl_where_part matches "*sl_furniture.*"
				then
					let vg_query_text = vg_query_text clipped, ", sl_furniture"
					if not vl_comp_sl
					then
						let vg_query_text = vg_query_text clipped, ", comp_sl"
						let vl_comp_sl = true
					end if
				end if	
			else
				if vl_where_part matches "*sl_furniture.*"
				then
					let vg_query_text = vg_query_text clipped, ", sl_sf"
					let vg_query_text = vg_query_text clipped, ", sl_furniture"
					if not vl_comp_sl
					then
						let vg_query_text = vg_query_text clipped, ", comp_sl"
						let vl_comp_sl = true
					end if
				end if	
			end if	

			if vl_where_part matches "*sl_sf_hist.*"
			then
				let vg_query_text = vg_query_text clipped, ", sl_sf_hist"
				if not vl_comp_sl
				then
					let vg_query_text = vg_query_text clipped, ", comp_sl"
					let vl_comp_sl = true
				end if
			end if	

			if vl_where_part matches "*work_schedule.*"
			or vl_where_part matches "*wo_h.*"
			then
				let vg_query_text = vg_query_text clipped, 
					", work_schedule, wo_h"
				if vl_where_part matches "*work_sched_hdr.*"
				then
					let vg_query_text = vg_query_text clipped,
						", work_sched_hdr"
				end if
			else
				if vl_where_part matches "*work_sched_hdr.*"
				then
					let vg_query_text = vg_query_text clipped,
						", work_schedule, wo_h, work_sched_hdr"
				end if
			end if

			if vl_where_part matches "*comp_ert.*"
			then
				let vg_query_text = vg_query_text clipped, 
					", comp_ert"
			end if
			if vl_where_part matches "*comp_ert_tags.*"
			then
				let vg_query_text = vg_query_text clipped, 
					", comp_ert_tags"
			end if
			if vl_where_part matches "*comp_tree.*"
			and vl_where_part matches "*trees.*"
			then
				let vg_query_text = vg_query_text clipped, 
					", comp_tree, trees"
			else
				if vl_where_part matches "*trees.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", comp_tree, trees"
				end if
				if vl_where_part matches "*comp_tree.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", comp_tree"
				end if
			end if
			if vl_where_part matches "*comp_sched.*"
			then
				let vg_query_text = vg_query_text clipped, 
					", comp_sched"
			end if
			if vl_where_part matches "*comp_text.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_text"
			end if

			if vl_where_part matches "*comp_enf.*"
			or vl_det_where_part matches "*enf_suspect.*"
			or vl_det_where_part_ii matches "*enf_suspect.*"
			or vl_det_where_part matches "*enf_action.*"
			or vl_det_where_part_ii matches "*enf_action.*"
			or vl_det_where_part matches "*enf_company.*"
			or vl_det_where_part_ii matches "*enf_company.*"
			then
				let vg_query_text = vg_query_text clipped,
					", comp_enf"

				if vl_det_where_part matches "*enf_action.*"
				or vl_det_where_part_ii matches "*enf_action.*"
				then
					let vg_query_text = vg_query_text clipped,
						", enf_action"
				end if
				if vl_det_where_part matches "*enf_suspect.*"
				or vl_det_where_part_ii matches "*enf_suspect.*"
				or vl_det_where_part matches "*enf_company.*"
				or vl_det_where_part_ii matches "*enf_company.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", enf_suspect"
				end if
				if vl_det_where_part matches "*enf_company.*"
				or vl_det_where_part_ii matches "*enf_company.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", enf_company"
				end if
			end if	
			if vl_det_where_part matches "*comp_dart_header.*"
			then
				let vg_query_text = vg_query_text clipped,
					", comp_dart_header"
			end if
			if vl_det_where_part matches "*comp_ert_header.*"
			then
				let vg_query_text = vg_query_text clipped,
					", comp_ert_header"
			end if
			if vl_det_where_part matches "*comp_ert_detail.*"
			then
				let vg_query_text = vg_query_text clipped,
					", comp_ert_detail"
			end if
			if vl_det_where_part matches "*comp_ert_tags.*"
			then
				let vg_query_text = vg_query_text clipped,
					", comp_ert_tags"
			end if
			if vl_where_part matches "*comp_incident.*"
			or vl_det_where_part matches "*incident.*"
			or vl_det_where_part_ii matches "*incident.*"
			then
				let vg_query_text = vg_query_text clipped,
					", comp_incident"

				if vl_det_where_part matches "*incident.*"
				or vl_det_where_part_ii matches "*incident.*"
				then
					let vg_query_text = vg_query_text clipped,
						", incident"
				end if
			end if	
			if vl_where_part matches "*comp_referral.*"
			or vl_det_where_part matches "*referral.*"
			or vl_det_where_part_ii matches "*referral.*"
			then
				let vg_query_text = vg_query_text clipped,
					", comp_referral"

				if vl_det_where_part matches "*referral.*"
				or vl_det_where_part_ii matches "*referral.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", referral"
				end if
			end if
			if vl_det_where_part matches "*client.*"
			or vl_det_where_part_ii matches "*client.*"
			or vl_det_where_part matches "*asbo.*"
			or vl_det_where_part_ii matches "*asbo.*"
			then
				let vg_query_text = vg_query_text clipped, 
					", comp_client, client"

				if vl_det_where_part matches "*asbo.*"
				or vl_det_where_part_ii matches "*asbo.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", asbo"
				end if
			end if

			if vl_det_where_part matches "*comp_warden.*"
			or vl_det_where_part_ii matches "*comp_warden.*"
			then
				let vg_query_text = vg_query_text clipped,
					", comp_warden"
			end if

			if vl_det_where_part_iii matches "*comp_enf_hist.*"
			then
				let vg_query_text = vg_query_text clipped, 
					", comp_enf_hist"
			end if

			if length(vl_txt_part_ii)
			then
				let vg_query_text = vg_query_text clipped, ", evidence_text"
			end if

			if vl_where_part matches "*comp_import.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_import "
			end if

			if vl_where_part matches "*comp_correspond.*"
			then
				let vg_query_text = vg_query_text clipped, ", comp_correspond "
			end if

			if (vl_where_part matches "* site.*"
				or vl_where_part matches "site.*"
				or vl_where_part matches "*site_name_*")
				and vl_where_part not matches "area.*"
				and vl_where_part not matches "* area.*"
				and vl_where_part not matches "ward.*"
				and vl_where_part not matches "* ward.*"
			then
				let vg_query_text = vg_query_text clipped, ", site",
					" where comp.site_ref = site.site_ref"
			else
				if vl_where_part matches "* area.*"
				or vl_where_part matches "area.*"
				then
					let vg_query_text = vg_query_text clipped, 
						", site, area",
						" where comp.site_ref = site.site_ref",
						" and site.area_c = area.area_c"
				else
					if vl_where_part matches "* ward.*"
					or vl_where_part matches "ward.*"
					then
						let vg_query_text = vg_query_text clipped, 
							", site, ward",
							" where comp.site_ref = site.site_ref",
							" and site.ward_code = ward.ward_code"
					else
						let vg_query_text = vg_query_text clipped, " where 1=1"
					end if
				end if
			end if

			if vl_customer
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_clink.complaint_no",
					" and comp_clink.customer_no = customer.customer_no"

				if vl_where_part matches "*weee_proof.*"
				then
					let vg_query_text = vg_query_text clipped,
						" and customer.customer_no = weee_proof.customer_no"
				end if
			end if

			if vl_comp_hway
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_hway.complaint_no"
				if length(vl_det_where_part)
					or vl_where_part matches "*hway_status.*"
				then
					let vg_query_text = vg_query_text clipped, 
						" and comp.complaint_no = hway_status.enquiry_no"
				end if	
			end if

			if vl_comp_meas
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_measurement.complaint_no"
			end if

			if vl_comp_agreq
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_agreq.complaint_no"
			end if

			if vl_comp_av	
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_av.complaint_no"

				if length(vl_det_where_part)
				or vl_where_part matches "*comp_av_hist.*"
				then
					let vg_query_text = vg_query_text clipped, 
						" and comp.complaint_no = comp_av_hist.complaint_no"
					if vl_where_part matches "*comp_av_hist.*"
					then
						let vg_query_text = vg_query_text clipped, 
							" and comp_av_hist.seq = ",
							" (select max(seq) from comp_av_hist",
							" where comp.complaint_no =",
							" comp_av_hist.complaint_no",
							" and comp_av_hist.status_ref not in",
							" ('LOC_CH', 'OFF_CH'))"
					end if
				end if	
			end if

			if vl_comp_weee	
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_weee.complaint_no"
			end if

			if vl_comp_weee_sale
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_weee_sale.sale_no"

				if vl_where_part matches "*weee_centre.*"
				then
					let vg_query_text = vg_query_text clipped, 
						" and comp_weee_sale.centre_code = weee_centre.code"
				end if
			end if

			if vl_where_part matches "*comp_ert.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_ert.complaint_no"
			end if
			if vl_where_part matches "*comp_ert_tags.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_ert_tags.complaint_no"
			end if
			if vl_where_part matches "*comp_tree.*"
			or vl_where_part matches "*trees.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_tree.complaint_no"
			end if
			if vl_where_part matches "*trees.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and trees.tree_ref = comp_tree.tree_ref"
			end if

			if vl_where_part matches "*weee_load_item.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp_weee.item_no = weee_load_item.item_no"
				if vl_where_part matches "*weee_load_dtl.*"
				then
					let vg_query_text = vg_query_text clipped, 
						" and comp_weee.item_no = weee_load_item.item_no"
				end if
			else
				if vl_where_part matches "*weee_load_dtl.*"
				then
					let vg_query_text = vg_query_text clipped, 
						" and comp_weee.item_no = weee_load_item.item_no",
						" and weee_load_item.batch_no = weee_load_dtl.batch_no",
						" and weee_load_item.detail_no = weee_load_dtl.detail_no"
				end if
			end if

			if vl_comp_sl	
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_sl.complaint_no"
			end if

			if vl_comp_gm
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_gm.complaint_no"
				if vl_where_part matches "*c_sf.*"
				then
					let vg_query_text = vg_query_text clipped,
						" and comp_gm.c_sf_id = c_sf.c_sf_id"
				end if
				if vl_where_part matches "*c_si.*"
				then
					let vg_query_text = vg_query_text clipped,
						" and comp_gm.c_si_id = c_si.c_si_id"
				end if
			end if
			if vl_where_part matches "*feat.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.feature_ref = feat.feature_ref"
			end if
			if vl_where_part matches "*item.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.item_ref = item.item_ref"
			end if
			if vl_where_part matches "*comp_text.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_text.complaint_no"
			end if

			if vl_where_part matches "*comp_enf.*"
			or vl_det_where_part matches "*enf_suspect.*"
			or vl_det_where_part_ii matches "*enf_suspect.*"
			or vl_det_where_part matches "*enf_action.*"
			or vl_det_where_part_ii matches "*enf_action.*"
			or vl_det_where_part matches "*enf_company.*"
			or vl_det_where_part_ii matches "*enf_company.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_enf.complaint_no"

				if vl_det_where_part matches "*enf_action.*"
				or vl_det_where_part_ii matches "*enf_action.*"
				then
					let vg_query_text = vg_query_text clipped, 
						" and comp.complaint_no = enf_action.complaint_no"
				end if	
				if vl_det_where_part matches "*enf_suspect.*"
				or vl_det_where_part_ii matches "*enf_suspect.*"
				or vl_det_where_part matches "*enf_company.*"
				or vl_det_where_part_ii matches "*enf_company.*"
				then
					let vg_query_text = vg_query_text clipped, 
						 " and comp_enf.suspect_ref = enf_suspect.suspect_ref"
				end if
				if vl_det_where_part matches "*enf_company.*"
				or vl_det_where_part_ii matches "*enf_company.*"
				then
					let vg_query_text = vg_query_text clipped,
						" and enf_suspect.company_ref = enf_company.company_ref"
				end if	
			end if

			if vl_where_part matches "*comp_incident.*"
			or vl_det_where_part matches "*incident.*"
			or vl_det_where_part_ii matches "*incident.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_incident.complaint_no"

				if vl_det_where_part matches "*incident.*"
				or vl_det_where_part_ii matches "*incident.*"
				then
					let vg_query_text = vg_query_text clipped, 
						" and comp_incident.incident_ref =incident.incident_ref"
				end if	
			end if
			if vl_where_part matches "*comp_referral.*"
			or vl_det_where_part matches "*referral.*"
			or vl_det_where_part_ii matches "*referral.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_referral.complaint_no"

				if vl_det_where_part matches "*referral.*"
				or vl_det_where_part_ii matches "*referral.*"
				then
					let vg_query_text = vg_query_text clipped,
						" and comp_referral.referral_ref =referral.referral_ref"
				end if	
			end if
			if vl_det_where_part matches "*client.*"
			or vl_det_where_part_ii matches "*client.*"
			or vl_det_where_part matches "*asbo.*"
			or vl_det_where_part_ii matches "*asbo.*"
			then
				let vg_query_text = vg_query_text clipped, 
					 " and comp.complaint_no = comp_client.complaint_no",
					 " and comp_client.client_ref = client.client_ref"

				if vl_det_where_part matches "*asbo.*"
				or vl_det_where_part_ii matches "*asbo.*"
				then
					let vg_query_text = vg_query_text clipped, 
						 " and client.client_ref = asbo.client_ref"
				end if
			end if

			if vl_det_where_part matches "*comp_warden.*"
			or vl_det_where_part_ii matches "*comp_warden.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_warden.complaint_no"
			end if	

			if vl_det_where_part_iii matches "*comp_enf_hist.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_enf_hist.complaint_no"
			end if	

			if length(vl_txt_part_ii)
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = evidence_text.complaint_no"
			end if

			if vl_where_part matches "*comp_import.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_import.complaint_no"
			end if
			if vl_where_part matches "*comp_correspond.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_correspond.complaint_no"
			end if

#ADJ131003
			if vl_where_part matches "*comp_status=\"Y\"*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"comp_status=\"Y\"", 
								"date_closed is null")
			end if
			if vl_where_part matches "*comp_status=\'Y\'*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"comp_status=\'Y\'", 
								"date_closed is null")
			end if

			if vl_where_part matches "*comp_status=\"N\"*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"comp_status=\"N\"", 
								"date_closed is not null")
			end if
			if vl_where_part matches "*comp_status=\'N\'*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"comp_status=\'N\'", 
								"date_closed is not null")
			end if

			if vl_where_part matches "*comp_status=\"RUNNING\"*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"comp_status=\"RUNNING\"", 
								"date_closed is null")
			end if
			if vl_where_part matches "*comp_status=\'RUNNING\'*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"comp_status=\'RUNNING\'", 
								"date_closed is null")
			end if

			if vl_where_part matches "*comp_status=\"CLOSED\"*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"comp_status=\"CLOSED\"", 
								"date_closed is not null")
			end if
			if vl_where_part matches "*comp_status=\'CLOSED\'*"
			then
				let vl_where_part = 
					replace_string(vl_where_part, 
								"comp_status=\'CLOSED\'", 
								"date_closed is not null")
			end if

			if vl_where_part matches "*sl_sf.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp_sl.inv_id = sl_sf.inv_id"

				if vl_where_part matches "*sl_furniture.*"
				then
					let vg_query_text = vg_query_text clipped,
					" and sl_sf.furniture_type = sl_furniture.furniture_type"
				end if
			else
				if vl_where_part matches "*sl_furniture.*"
				then
					let vg_query_text = vg_query_text clipped,
					" and comp_sl.inv_id = sl_sf.inv_id",
					" and sl_sf.furniture_type = sl_furniture.furniture_type"
				end if
			end if

			if vl_where_part matches "*sl_sf_hist.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp_sl.inv_id = sl_sf_hist.inv_id"
			end if

			if vl_where_part matches "*officers.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and officers.officer_ref = comp_av.officer_id"
			end if

			if vl_where_part matches "*colour.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and colour.colour_ref = comp_av.colour_ref"
			end if

			if vl_where_part matches "*models.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and models.model_ref = comp_av.model_ref",
					" and models.make_ref = comp_av.make_ref"
			end if

			if vl_where_part matches "*makes.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and makes.make_ref = comp_av.make_ref"
			end if

			if vl_where_part matches "*comp_nappy*"
			or vl_where_part matches "*nappy_site*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_nappy.complaint_no",
					" and comp_nappy.nappy_ref = nappy_site.nappy_ref"
			end if

			if vl_where_part matches "*comp_clin.*"
			or vl_where_part matches "*clin_site.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_clin.complaint_no",
					" and comp_clin.clinical_ref = clin_site.clinical_ref"
			end if

			if vl_where_part matches "*comp_trade.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_trade.complaint_no"
			end if

			if vl_where_part matches "*comp_tr.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = comp_tr.complaint_no"
			end if

			if vl_where_part matches "*diry.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.complaint_no = diry.source_ref",
					" and diry.source_flag = 'C'"
			end if
			if vl_where_part matches "*si_i.*"
			then
				let vg_query_text = vg_query_text clipped, 
					" and comp.site_ref = si_i.site_ref",
					" and comp.item_ref = si_i.item_ref"
			end if

			if vl_where_part matches "*work_schedule.*"
			or vl_where_part matches "*work_sched_hdr.*"
			or vl_where_part matches "*wo_h.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.dest_ref = wo_h.wo_ref",
					" and comp.dest_suffix = wo_h.wo_suffix",
					" and work_schedule.wo_key = wo_h.wo_key"
				if vl_where_part matches "*work_sched_hdr.*"
				then
					let vg_query_text = vg_query_text clipped,
						" and work_schedule.schedule_ref =",
						" work_sched_hdr.schedule_ref"
				end if
			end if

			if vl_where_part matches "*hway_remarks_line*"
			then
				let vl_where_part =
						replace_string(vl_where_part, 
									"hway_remarks_line", 
									"comp.details_1")
			end if
			if vl_where_part matches "*remarks_line*"
			then
				let vl_where_part =
						replace_string(vl_where_part, 
									"remarks_line", 
									"comp.details_1")
			end if
			if vl_where_part matches "*comp_sched.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_sched.complaint_no"
			end if
			if vl_det_where_part matches "*comp_dart_header.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_dart_header.complaint_no"
			end if
			if vl_det_where_part matches "*comp_ert_header.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_ert_header.complaint_no"
			end if
			if vl_det_where_part matches "*comp_ert_detail.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_ert_detail.complaint_no"
			end if
			if vl_det_where_part matches "*comp_ert_tags.*"
			then
				let vg_query_text = vg_query_text clipped,
					" and comp.complaint_no = comp_ert_tags.complaint_no",
					" and comp_ert_tags.seq_no = 1"
			end if

			let vg_query_text = vg_query_text clipped,
					" and ", vl_where_part clipped

			if length(vl_det_where_part)
			then
				let vg_query_text = vg_query_text clipped, 
					" and ", vl_det_where_part clipped
			end if	

			if length(vl_det_where_part_ii)
			then
				let vg_query_text = vg_query_text clipped, 
					" and ", vl_det_where_part_ii clipped
			end if	

			if length(vl_det_where_part_iii)
			then
				let vg_query_text = vg_query_text clipped, 
					" and ", vl_det_where_part_iii clipped
			end if	

			if length(vl_txt_part_ii)
			then
				let vg_query_text = vg_query_text clipped,
					" and ", vl_txt_part_ii clipped
			end if

			let vg_query_text = vg_query_text clipped,
				" order by comp.complaint_no desc"
		end if

		if vl_where_part = " 1=1"
		then
			case 
				when downshift(vg_record_title) matches "*s"
					let vg_title = 
						"Are you sure you wish to select ALL ",
						vg_record_title clipped, "  *This may take some time*"
				when downshift(vg_record_title) matches "*y"
					let vl_length = length(vg_record_title)
					let vg_title = "Are you sure you wish to select ALL ",
						vg_record_title[1, vl_length-1], 
						"ies  *This may take some time*"
				otherwise
					let vl_length = length(vg_record_title)
					let vg_title = "Are you sure you wish to select ALL ",
						vg_record_title clipped, "s  *This may take some time*"
			end case

			if continue_yn(vg_title)
			then
				if skey_check("QUERY_ALL_PASSWORD", "ALL") = "Y"
				then
					if get_passwd()
					then
						if vg_passwd = skey_check("COMPLAIN_PW", "ALL")
						then
							# select all!!
						else
							call valid_error("", "Incorrect Password", "")
							return 0
						end if
					else
						return 0
					end if
				end if
			else
				return 0
			end if
		end if

		case 
			when downshift(vg_record_title) matches "*s"
				let vg_title = "Selecting ", vg_record_title clipped, 
					", Please Wait ..."
			when downshift(vg_record_title) matches "*y"
				let vl_length = length(vg_record_title)
				let vg_title = "Selecting ", vg_record_title[1, vl_length-1], 
					"ies, Please Wait ..."
			otherwise
				let vg_title = "Selecting ", vg_record_title clipped, 
					"s, Please Wait ..."
		end case

		call select_complain_rows()

		if vg_tot_in_list = 0
		then
			case
				when downshift(vg_record_title) matches "*s"
					let vg_title = "No matching ", 
						downshift(vg_record_title) clipped,
						" found.  Alter criteria and search again"
				when downshift(vg_record_title) matches "*s"
					let vl_length = length(vg_record_title)
					let vg_title = "No matching ", 
						downshift(vg_record_title[1, vl_length-1]),
						"ies found.  Alter criteria and search again"
				otherwise
					let vg_title = "No matching ", 
						downshift(vg_record_title) clipped,
						"s found.  Alter criteria and search again"
			end case
			if continue_yn(vg_title)
			then
				let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
				case
					#ADJ MEASUREMENT TODO
					when vg_ms_installation = "Y"
						and vg_ms_fault_codes matches vl_comp_code
						and length(vr_comp.comp_code)
						let vl_measurement_query = true

					when vr_comp.service_c = vg_nappy_service
						and vg_nappy_installation = "Y"
						let vl_nappy_query = true

					when vr_comp.service_c = vg_clin_service
						and vg_clin_installation = "Y"
						let vl_clin_query = true

					when vr_comp.service_c = vg_av_service
						and vg_av_installation = "Y"
						let vl_av_query = true

					# WEEE
					when vr_comp.service_c = vg_weee_service
						and vg_weee_installation = "Y"
						let vl_weee_query = true

					# WEEE
					when vr_comp.service_c = vg_weee_sales_service
						and vg_sales_installation = "Y"
						let vl_weee_sales_query = true

					when vr_comp.service_c = vg_enf_service
						and vg_enf_installation = "Y"
						let vl_enf_query = true
#ADJ ENFTR
					when vr_comp.service_c = vg_enf_trade_service
						and vg_enf_trade_installation = "Y"
						let vl_enftr_query = true

					when vr_comp.service_c = vg_sl_service
						and vg_sl_installation = "Y"
						let vl_sl_query = true

					when vr_comp.service_c = vg_gm_service
						and vg_gm_installation = "Y"
						let vl_gm_query = true

					when vr_comp.service_c = vg_ert_service
						and vg_ert_installation = "Y"
						and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
						let vl_ert_query = true

					when vr_comp.service_c = vg_trees_service
						and vg_trees_installation = "Y"
						let vl_tree_query = true

					when vr_comp.service_c = vg_trade_service
						and vg_trade_installation = "Y"
						let vl_trade_query = true

					when vr_comp.service_c = vg_agreq_service
						and vg_agreq_installation = "Y"
						let vl_agreq_query = true

					when vr_comp.service_c = vg_hway_service
						and vg_hway_installation = "Y"
						let vl_hway_query = true

					when vr_comp.service_c = vg_sched_service
						and vg_sched_installation = "Y"
						and vg_weee_installation = "N"
						and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
						let vl_sched_query = true

					when vr_comp.service_c = vg_sched_service
						and vg_sched_installation = "Y"
						and vg_weee_installation = "Y"
						and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
						let vl_weee_sched_query = true

					otherwise
						let vl_normal_query = true
				end case
				continue while
			else
				let vl_q_flag = 0
				exit while
			end if
		else		
			exit while
		end if
	end while

	if vg_tot_in_list < 1
	then
		return 0
	end if

	call get_complain_row(0, 1)

	if not vg_progress
	then
		let vl_q_flag = 0
		#ADJ GENERO
		#display "" at 23, 1
		case 
			when downshift(vg_record_title) matches "*s"
				let vg_title = "There are no ", 
					downshift(vg_record_title) clipped, 
					" which satisfy those criteria"
			when downshift(vg_record_title) matches "*y"
				let vl_length = length(vg_record_title)
				let vg_title = "There are no ", 
					downshift(vg_record_title[1, vl_length-1]), 
					"ies which satisfy those criteria"
			otherwise
				let vg_title = "There are no ", 
					downshift(vg_record_title) clipped, 
					"s which satisfy those criteria"
		end case
		call valid_error("", vg_title, "")	
		return 0
	end if

	if vg_action_type 
	then
		#ADJ GENERO
		#call qrymenu_of()
	end if

	if vg_display_menu_icons = "Y"
	then
		let vl_a_menu_desc = "(A)dd a new ", 
			downshift(vg_record_title) clipped, " to the database." 
		let vl_q_menu_desc = "(Q)uery a specific ", 
			downshift(vg_record_title) clipped, "."
		let vl_f_menu_desc = "Display the (F)irst selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_n_menu_desc = "Display the (N)ext selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_p_menu_desc = "Display the (P)revious selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_l_menu_desc = "Display the (L)ast selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_u_menu_desc = "(U)pdate the selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_r_menu_desc = "(D)elete the selected ", 
			downshift(vg_record_title) clipped, "."
	else
		let vl_a_menu_desc = "Add a new ", 
			downshift(vg_record_title) clipped, " to the database." 
		let vl_q_menu_desc = "Query a specific ", 
			downshift(vg_record_title) clipped, "."
		let vl_f_menu_desc = "Display the first selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_n_menu_desc = "Display the next selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_p_menu_desc = "Display the previous selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_l_menu_desc = "Display the last selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_u_menu_desc = "Update the selected ", 
			downshift(vg_record_title) clipped, "."
		let vl_r_menu_desc = "Remove the selected ", 
			downshift(vg_record_title) clipped, "."
	end if
	let vl_o_menu_desc = "Display the source of the selected ",
		downshift(vg_record_title) clipped, "."
	let vl_s_menu_desc = "Display the destination of the selected ",
		downshift(vg_record_title) clipped, "."
	let vl_t_menu_desc = "Display/Update any text related to the selected ",
		downshift(vg_record_title) clipped, "."
	let vl_h_menu_desc = "Display historical information",
		" for the selected property/location."
	let vl_c_menu_desc = "Display ", downshift(vg_compln_title) clipped,	
		" information for the selected ",
		downshift(vg_record_title) clipped, "."
	let vl_i_menu_desc = "Output the selected ",
		downshift(vg_record_title) clipped, " to a printer or via email."
	let vl_sd_menu_desc =
			"Display status and location history of this abandoned vehicle."
	let vl_dd_menu_desc = 
		"Display detailed information relating to the selected ",
		downshift(vg_record_title) clipped, "."
	let vl_ag_menu_desc = 
		"Display terms and conditions information relating to the selected ",
		downshift(vg_record_title) clipped, "."

# 22/9/3
	let vl_lookup_text = skey_check("AV HPI WEB", "ALL")

	if (length(skey_check("AV POLICE EMAIL", "ALL"))
	     and quiet_allow("av_police_email"))
	or (length(skey_check("AV_FIRE_EMAIL", "ALL"))
	     and quiet_allow("av_fire_email"))
	or (length(skey_check("AV_HOUSING_EMAIL", "ALL"))
	     and quiet_allow("av_housing_email"))
	or length(vl_lookup_text)
	or skey_check("AV WO USED","ALL") = "Y" 
	then
		let vl_sd_menu_desc = "Display status and location history"
		if length(skey_check("AV POLICE EMAIL", "ALL"))
		and quiet_allow("av_police_email") 
		then
			let vl_sd_menu_desc = vl_sd_menu_desc clipped, ", Police"
		end if
		if length(skey_check("AV_FIRE_EMAIL", "ALL"))
		and quiet_allow("av_fire_email") 
		then
			let vl_sd_menu_desc = vl_sd_menu_desc clipped, ", Fire"
		end if
		if length(skey_check("AV_HOUSING_EMAIL", "ALL"))
		and quiet_allow("av_housing_email") 
		then
			let vl_sd_menu_desc = vl_sd_menu_desc clipped, ", Housing"
		end if
		if length(vl_lookup_text)
		then
			let vl_sd_menu_desc = vl_sd_menu_desc clipped, ", HPI Check"
		end if
		if skey_check("AV WO USED","ALL") = "Y" then
			let vl_sd_menu_desc = vl_sd_menu_desc clipped, ", Works Order"
		end if
		let vl_sd_menu_desc = vl_sd_menu_desc clipped, "."
	end if

	if (vr_comp.service_c = vg_enf_service and vg_enf_installation = "Y")
	or (vr_comp.service_c = vg_enf_trade_service and vg_enf_trade_installation = "Y")
	then
		let vl_sd_menu_desc =
				"Display Evidence, Suspect and Actions for this Enforcement."
	end if

# BJG - code to force update of new enforcement
	if vg_act = "U"
#	and vr_comp.service_c = vg_enf_service
#	and vg_enf_installation = "Y"
	then
#		call update_enf_complain(vr_comp.complaint_no, vg_act)
		case
			when (vr_comp.service_c = vg_enf_service
			and vg_enf_installation = "Y")
				call update_enf_complain(vr_comp.complaint_no, vg_act)

			when (vr_comp.service_c = vg_enf_trade_service
			and vg_enf_trade_installation = "Y")
				call update_enf_trade_complain(vr_comp.complaint_no, vg_act)

			otherwise
				call update_complain_menu()
		end case
	else
# BJG - code to force update of new enforcement

	{ ADJ 22/09/08
	if (vm_current_page = "actions_page" # Only allowed for enforcements
	or vm_current_page = "suspect_page" # Only allowed for enforcements
	or vm_current_page = "evidence_page" # Only allowed for enforcements
	or vm_current_page = "action_text_page" # Only allowed for enforcements
	or vm_current_page = "costs_page") # Only allowed for enforcements
	and not (vr_comp.service_c = vg_enf_service
	and vg_enf_installation = "Y")
	and not (vr_comp.service_c = vg_enf_trade_service
	and vg_enf_trade_installation = "Y")
	then
		let vm_current_page = "generic_page"
	end if
	if vm_current_page = "trade_page" # Only allowed for trade
	and not (vr_comp.service_c = vg_trade_service
	and vg_trade_installation = "Y")
	then
		let vm_current_page = "generic_page"
	end if
	if (vm_current_page = "debtor_page" # Only allowed for trade or agreq
	or vm_current_page = "trade_site_page")
	and not ((vr_comp.service_c = vg_trade_service
	and vg_trade_installation = "Y")
	or (vr_comp.service_c = vg_agreq_service
	and vg_agreq_installation = "Y"))
	then
		let vm_current_page = "generic_page"
	end if
	}
	let vg_wo_line = 1

	dialog attributes(unbuffered)
		display array va_attachment_flag to sa_attachment_flag.*
		end DISPLAY
		display array va_disp_deft to sa_defi.*
		end display

		display array va_works_order to sa_wo_i.* attributes(count=vg_wo_count)
			before row
				let vg_wo_line = arr_curr()
				if vg_wo_line
				then
					display va_works_order[vg_wo_line].woi_task_ref
																to formonly.task_ref

					select task_desc 
						into vl_task_desc
					from task
						where task_ref = va_works_order[vg_wo_line].woi_task_ref

					display vl_task_desc to wo_task_desc
				end if
		end display

		display array vm_comp_text to sa_inp_text.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)

			before row
				let vl_current_text = arr_curr()
				if vl_current_text
				then
					display vm_disp_cust[vl_current_text] to cust_disp
				end IF
		end display

		display array vm_attach to sa_attach.*
			before display
				call dialog.setActionHidden("attachadd", false)
				call dialog.setActionActive("attachadd", true)
				if vm_attach.getlength() > 0
				then
					call dialog.setActionHidden("attachdelete", false)
					call dialog.setActionActive("attachdelete", true)
					call dialog.setActionHidden("attachshow", false)
					call dialog.setActionActive("attachshow", true)
				end if
		end display

		display array vg_agtsks to sa_tasks.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)

		end display

		display array va_trade_site to sa_trade_site.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
		end display

		display array va_debtor to sa_debtor.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
#				call gl_showpage("fold",vm_current_page)
		end display

		display array va_av_status to sa_av_status.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
#				call gl_showpage("fold",vm_current_page)
		end display

		display array va_actions to sa_actions.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
#				call gl_showpage("fold",vm_current_page)
		end display

		display array va_costs to sa_costs.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
#				call gl_showpage("fold",vm_current_page)
		end display

		display array va_suspect to sa_suspect.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
#				call gl_showpage("fold",vm_current_page)
		end display

		display array va_evidence to sa_evidence.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
#				call gl_showpage("fold",vm_current_page)
		end display

		display array va_action_text to sa_action_text.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
#				call gl_showpage("fold",vm_current_page)
		end display

		display array vg_disp_sl_sf to sa_sl_sf.*
			before display
				call dialog.setActionHidden("attachadd", true)
				call dialog.setActionActive("attachadd", false)
				call dialog.setActionHidden("attachdelete", true)
				call dialog.setActionActive("attachdelete", false)
				call dialog.setActionHidden("attachshow", true)
				call dialog.setActionActive("attachshow", false)
				if skey_check("USE_WO_H_EXTRA_TABLE", "ALL") = "N" then
					call dialog.setActionHidden("wo_addinfo", true)
					call dialog.setActionActive("wo_addinfo", false)
				end if
{
				let vg_sl_line = arr_curr()
				if vg_sl_line
				then
					display vg_hidden_sl_sf[vg_sl_line].inv_id, 
							vg_hidden_sl_sf[vg_sl_line].lookup_text,
							vg_hidden_sl_sf[vg_sl_line].sent_date,
							vg_hidden_sl_sf[vg_sl_line].sent_time_h,
							vg_hidden_sl_sf[vg_sl_line].sent_time_m
						to inv_id, 
							sl_fault_desc, 
							sent_date,
							sent_time_h,
							sent_time_m

					if skey_check("SL_ENHANCEMENTS","ALL") = "Y"
					then
						if vg_hidden_sl_sf[vg_sl_line].sent_date is null
						then
							display "WAITING" to sent_to_dw
						else
							display "SENT" to sent_to_dw
						end if
					else
						display "SENT" to sent_to_dw
					end if
				end if
}

			before row
				let vg_sl_line = arr_curr()
				if vg_sl_line
				then
					display vg_hidden_sl_sf[vg_sl_line].inv_id, 
							vg_hidden_sl_sf[vg_sl_line].lookup_text,
							vg_hidden_sl_sf[vg_sl_line].sent_date,
							vg_hidden_sl_sf[vg_sl_line].sent_time_h,
							vg_hidden_sl_sf[vg_sl_line].sent_time_m
						to inv_id, 
							sl_fault_desc, 
							sent_date,
							sent_time_h,
							sent_time_m

					if skey_check("SL_ENHANCEMENTS","ALL") = "Y"
					then
						if vg_hidden_sl_sf[vg_sl_line].sent_date is null
						then
							display "WAITING" to sent_to_dw
						else
							display "SENT" to sent_to_dw
						end if
					else
						display "SENT" to sent_to_dw
					end if
				end if

		end display

		on action generic_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "generic_page"

		on action rectifications_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "rectifications_page"

		on action works_order_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "works_order_page"

		on action av_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "av_page"

		on action status_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "status_page"

		on action gm_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "gm_page"

		on action ert_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "ert_page"

		on action hway_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "hway_page"

		on action trade_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "trade_page"

		on action trade_details_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "trade_details_page"

		on action agreq_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "agreq_page"

		on action enf_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "enf_page"

		on action meas_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "meas_page"

		on action sl_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "sl_page"

		on action weee_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "weee_page"

		on action weee_sales_ent_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "weee_sales_ent_page"

		on action sched_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "sched_page"

		on action customer_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "customer_page"

		on action tree_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "tree_page"

		on action text_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "text_page"

		on action text_query_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "text_query_page"

		on action import_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "import_page"

		on action debtor_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "debtor_page"

		on action trade_site_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "trade_site_page"

		on action actions_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "actions_page"

		on action action_text_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "action_text_page"

		on action costs_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "costs_page"

		on action suspect_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "suspect_page"

		on action evidence_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "evidence_page"

		on action correspondence_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "correspondence_page"

		on action map_page 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)
			let vm_current_page = "map_page"

		on action attachments_page
			call dialog.setActionHidden("attachadd", false)
			call dialog.setActionActive("attachadd", true)
			if vm_attach.getlength() > 0
			then
				call dialog.setActionHidden("attachdelete", false)
				call dialog.setActionActive("attachdelete", true)
				call dialog.setActionHidden("attachshow", false)
				call dialog.setActionActive("attachshow", true)
			end if
			let vm_current_page = "attachments_page"

		before dialog
            #call dialog.setArrayAttributes("sa_attachment_flag", va_attachment_flag_color)
			call dialog.setArrayAttributes("sa_actions", va_actions_color)

			if skey_check("USE_INSPECTION_ITEMS", "ALL") = "Y" then
				select insp_item_flag into vl_insp_item_flag from item
				where item_ref = vr_comp.item_ref and
				contract_ref = vr_comp.contract_ref
				if
					vl_insp_item_flag = "Y" and not length(vr_comp.date_closed)
				then
					call dialog.setActionActive("duedate", true)
				else
					call dialog.setActionActive("duedate", false)
				end if
			else
				call dialog.setActionActive("duedate", false)
			end if
			if skey_check("ALLOW_COMP_DELETE","ALL") = "N"
			then
				call dialog.setActionHidden("delete", true)
				call dialog.setActionActive("delete", false)
			end if
			if skey_check("USE_IE_MAPPING","ALL") = "N"
			then
				call dialog.setActionHidden("current_map", true)
				call dialog.setActionActive("current_map", false)
				call dialog.setActionHidden("selected_map", true)
				call dialog.setActionActive("selected_map", false)
			end if
			if vg_fc_installation = "N"
			then
				call dialog.setActionHidden("flycapture", true)
				call dialog.setActionActive("flycapture", false)
			end if
			if vg_tot_in_list = 1 or vg_show_source
			then
				call dialog.setActionActive("f", false)
				call dialog.setActionActive("n", false)
				call dialog.setActionActive("p", false)
				call dialog.setActionActive("l", false)
			end if
			if not quiet_allow("complain_add") or vg_show_source
			then
				call dialog.setActionActive("add", false)
			end if
{
			if not quiet_allow("complain_update") 
			then
#				call dialog.setActionActive("update", false)
# BJG 01/09/2010 - disable all update actions !
#  MOVED TO FUNCTION set_actions_step(DIALOG)
			end if
}
			if not quiet_allow("complain_delete") or vg_show_source
			then
				call dialog.setActionActive("delete", false)
			end IF
            IF NOT check_install("BSP")
            THEN
                call dialog.setActionHidden("bsp", true)
                call dialog.setActionActive("bsp", false)
            END IF 
            IF NOT check_install("GIS")
            THEN
                call dialog.setActionHidden("gis", true)
                call dialog.setActionActive("gis", false)
            END IF 
			call dialog.setActionHidden("attachadd", true)
			call dialog.setActionActive("attachadd", false)
			call dialog.setActionHidden("attachdelete", true)
			call dialog.setActionActive("attachdelete", false)
			call dialog.setActionHidden("attachshow", true)
			call dialog.setActionActive("attachshow", false)

			call set_actions_step(DIALOG)
			call gl_showpage("fold",vm_current_page)

		on action F
			let vg_progress = 1
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)
# BJG 04/07/2010 - Workflow 3348 - THIS CODE IS REQUIRED !            
			call gl_showpage("fold",vm_current_page)

		on action N
			let vg_progress = vg_progress + 1
			if vg_progress > vg_tot_in_list
			then
				error "There are no more rows in the direction you are going ..."
				let vg_progress = vg_tot_in_list
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)
# BJG 04/07/2010 - Workflow 3348 - THIS CODE IS REQUIRED !            
			call gl_showpage("fold",vm_current_page)

		on action P
			let vg_progress = vg_progress - 1
			if vg_progress < 1
			then
				error "There are no more rows in the direction you are going ..."
				let vg_progress = 1
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)
# BJG 04/07/2010 - Workflow 3348 - THIS CODE IS REQUIRED !            
			call gl_showpage("fold",vm_current_page)

		on action L
			let vg_progress = vg_tot_in_list
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)
# BJG 04/07/2010 - Workflow 3348 - THIS CODE IS REQUIRED !            
			call gl_showpage("fold",vm_current_page)

        ON ACTION refresh
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)
        
		on action Query
			let vg_show_source = false
			let vl_q_flag = 1
			exit dialog

		on action Add
			let vl_q_flag = 2
			exit dialog

		on action Text
			let g_text_update = true
			let vg_customer_save.* = vr_customer.*
			initialize vr_customer.* to null
			call text_yes_no()
			let g_text_update = false
			call set_comp_options()
			let vr_customer.* = vg_customer_save.*
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action update_header
			call check_comp_exist(vg_progress)
				returning vl_del_flag
			if not vl_del_flag
			then
				let vl_q_flag = 1
				exit dialog
			end if
			if vr_comp.date_closed is not null
			then
				# Only allow closed complaints to be updated
				# by an authorized user.
				# Unless its AV and AV WO USED = N, then let anyone update.
				## ABOVE LINE CHANGED - SEE BOB LANGHORNE
				# Unless its AV and AV_ALWAYS_DISP_RUN = Y, then let anyone update
				#  all usual fields as if running and don't ask for password.
				#  If its AV and AV_ALWAYS_DISP_RUN = N, then ask for password
				#  and only allow update of SOURCE and POSITION
				let vl_del_flag = true
				if vg_av_installation = "Y"
				and vr_comp.service_c = vg_av_service
#				and skey_check("AV WO USED", "ALL") = "N"
				and skey_check("AV_ALWAYS_DISP_RUN", "ALL") = "Y"
				then
					let vl_del_flag = false
				else
					if get_passwd()
					then
						if vg_passwd = skey_check("COMPLAIN_PW", "ALL")
						then
							let vl_del_flag = false
						end if
					end if
				end if
			else
				let vl_del_flag = false
			end if
# Make sure that vr_diry.* is clear of old values as if not it upsets further
# Processing - BJG - 09/06/2010 #############################################
			initialize vr_diry.* to null

			if not vl_del_flag
			then
				call set_comp_options()

--#				call fgl_keysetlabel("f7","History")
--#				call fgl_keysetlabel("f3","Customer")

				let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
				case
					when vg_ms_installation = "Y"
					and vg_ms_fault_codes matches vl_comp_code
					and length(vr_comp.comp_code)
						if vr_comp.action_flag matches "[HPI]"
						then
							call update_measurement_hold_complain()
						else
							call update_measurement_complain()
						end if

					when vr_comp.service_c = vg_av_service
						and vg_av_installation = "Y"
						call update_av_complain(vr_comp.complaint_no)

					when vr_comp.service_c = vg_enf_service
						and vg_enf_installation = "Y"
						call update_enf_complain(vr_comp.complaint_no, "X")

					when vr_comp.service_c = vg_enf_trade_service
						and vg_enf_trade_installation = "Y"
						call update_enf_trade_complain
							(vr_comp.complaint_no, "X")

					when vr_comp.service_c = vg_sl_service
						and vg_sl_installation = "Y"
						if vg_hidden_sl_sf[1].sent_date is null
						then
							call update_sl_complain(m_curr_row)
						else
							if vg_hidden_sl_sf[1].sent_date is not null
							then
								display "SENT" to sent_to_dw 
							end if
							call update_sent_sl_complain(m_curr_row)
						end if

					when vr_comp.service_c = vg_gm_service
						and vg_gm_installation = "Y"
						call update_gm_complain(vr_comp.complaint_no)

					when vr_comp.service_c = vg_ert_service
						and vg_ert_installation = "Y"
						and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
						call update_ert_complain(m_curr_row)
						
					when vr_comp.service_c = vg_trees_service
						and vg_trees_installation= "Y"
						if vr_comp.action_flag matches "[HPI]"
						then
							call update_tree_hold_complain(m_curr_row)
						else
							call update_tree_complain(m_curr_row)
						end if

					when vr_comp.service_c = vg_trade_service
						and vg_trade_installation="Y"
						call update_trade_complain(m_curr_row)

					when vr_comp.service_c = vg_agreq_service
						and vg_agreq_installation="Y"
						call update_agreq_complain(m_curr_row)

					when vr_comp.service_c = vg_nappy_service
						and vg_nappy_installation="Y"
						call update_nappy_complain(m_curr_row)

					when vr_comp.service_c = vg_clin_service
						and vg_clin_installation="Y"
						call update_clin_complain(m_curr_row)

					when vr_comp.service_c = vg_hway_service
						and vg_hway_installation="Y"
						call update_hway_complain(m_curr_row)

					when vr_comp.service_c = vg_sched_service
						and vg_sched_installation="Y"
						if vr_comp.action_flag = "H"
						then
							call update_sched_hold_complain()
						else
							call update_sched_complain(m_curr_row)
						end if

					otherwise 
						if vr_comp.action_flag matches "[HPI]"
						then
							call update_hold_complain()
						else
							call update_complain()
						end if
				end case

			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action update_destination
			call load_comp_text_array(vr_comp.complaint_no)
			if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
			then
				call load_comp_det_text_array() 
			end if
			call save_wo_del_contact()		# 17/11/03

			if vr_comp.service_c = vg_sched_service
			and vg_sched_installation = "Y"
			and vg_sched_collect_items = "Y"
			then
				if vr_comp.action_flag = "H"
				then
					select wo_type_f
						into vr_wo_h.wo_type_f
					from comp_sched
						where complaint_no = vr_comp.complaint_no
				end if
					
				call update_comp_sched_destination(vr_wo_h.wo_type_f)
			else
				call update_comp_destination()
			end if

			call update_comp_contract_ref_wo()		# 14/11/03 AV
			if vr_comp.text_flag = "N"
			then
				select count(*)
					into vl_count
				from comp_text
					where complaint_no = vr_comp.complaint_no

				if vl_count
				then
					let vr_comp.text_flag = "Y"
					update comp 
						set text_flag = "Y"
					where complaint_no = vr_comp.complaint_no
					display by name vr_comp.text_flag
				end if
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action duedate
			call upd_date_due
			(
				vr_comp.item_ref,
				vr_comp.site_ref,
				vr_comp.feature_ref,
				vr_comp.contract_ref
			)

		on action enforcement
			let vl_enforcement_ref = 0
			select enf_complaint_no into vl_enforcement_ref
				from comp_enf_link
				where source_complaint = vr_comp.complaint_no
			if vl_enforcement_ref
			then
				let vl_runcomm = 
					"exec fglgo_complain U X X X X ", vl_enforcement_ref
				call os_exec(vl_runcomm, false)
			else
				if allow("enf_add_upd")
				then
					call start_wait()
					call load_comp_text_array(vr_comp.complaint_no) 
					if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
					then
						call load_comp_det_text_array() 
					end if
					select diry_ref
						into vl_diry_ref
					from diry
						where source_ref = vr_comp.complaint_no
						and source_flag = "C"
					call end_wait()
					if vl_diry_ref 
					then
						let vlr_comp_save.* = vr_comp.*
						let vlr_customer_save.* = vr_customer.*
						let vlr_diry_save.* = vr_diry.*
						let vlr_si_i_save.* = vr_si_i.*
						call history_save_text(true)	
						let vg_allow_text_clear = TRUE 
#						open window iw_complain_2 at 1,1 
#							with 20 rows, 90 columns
						open window iw_complain_2 with form "complain"
                       	let vg_module_title = vg_comp_title clipped
--#                     call fgl_settitle(vg_module_title clipped)
						call complain_labels()
						call save_comp_form_variables()
						call reset_comp_form_variables()
						call qrycomp_of()
						call addwindow_of()
						initialize vg_enf_arr.* to null
						let vg_replication = "N"
						if vr_comp.service_c = vg_trade_service
						and vg_trade_installation = "Y"
						then
							call add_enf_trade_complain(vl_diry_ref)
								returning vl_action_flag
						else
							call add_enf_complain(vl_diry_ref)
								returning vl_action_flag
						end if
						close window iw_complain_2
						call restore_comp_form_variables()
						let vg_allow_text_clear = false
						let vr_comp.* = vlr_comp_save.*
						let vr_customer.* = vlr_customer_save.*
						let vr_diry.* = vlr_diry_save.*
						let vr_si_i.* = vlr_si_i_save.*
						call history_save_text(false)	
						if vl_action_flag != "I"
						then
							call update_comp_enf_source_ref(vl_diry_ref)
						end if
#						exit dialog
					else
						call valid_error("", 
							"ERROR: The complaint source cannot be found", "")
					end if
				end if
			end if	
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action replicate
			let vl_runcomm = "exec fglgo_complain REPLICATE C ", 
							vr_comp.complaint_no using "<<<<<<<"
			call os_exec(vl_runcomm, true)

		on action flycapture
			if update_comp_flycapture(true) then end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		{
		on action Update
			call update_complain_menu()
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)
		}

		ON ACTION Delete
			if not select_complain(vg_progress)
			then
				exit dialog
			end if
			if delete_complain()
			then
				call mstart_wait("Deleting Selected Record, Please Wait ...")
				call select_complain_rows()
				call end_wait()
				if vg_progress > 1
				then
					let vg_progress = vg_progress - 1
				end if
				if vg_tot_in_list < 1
				or vg_progress > vg_tot_in_list
				then
					let vl_q_flag = 3		# last row deleted - select Add
					exit dialog
				end if
			end if
			call get_complain_row(vg_progress, 0)
#			if select_complain(vg_progress)
#			then
#				call set_actions_step(DIALOG)
{
				call disp_comp_count()
				call disp_comp_looks()
				hide option "tree-Information"
				case
					when vr_comp.service_c = vg_av_service
						and vg_av_installation = "Y"
						hide option "Show-dest"
						show option "Show-detail"

					when vr_comp.service_c = vg_enf_service
						and vg_enf_installation = "Y"
						hide option "Show-dest"
						show option "Show-detail"
#ADJ ENFTR
					when vr_comp.service_c = vg_enf_trade_service
						and vg_enf_trade_installation = "Y"
						hide option "Show-dest"
						show option "Show-detail"

					when vr_comp.service_c = vg_hway_service
						and vg_hway_installation = "Y"
						hide option "Show-dest"
						show option "Show-detail"

					when vr_comp.service_c = vg_dart_service
						and vg_dart_installation = "Y"
						hide option "Show-dest"
						show option "Show-detail"

					when vr_comp.service_c = vg_sw_service
						and vg_sw_installation = "Y"
						hide option "Show-dest"
						show option "Show-detail"

					when vr_comp.service_c = vg_trees_service
						and vg_trees_installation = "Y"
						show option "tree-Information"

					otherwise 
						hide option "Show-detail"
						show option "Show-dest"
				end case
}

#			else
#				let vl_q_flag = 4		# error reading row
#				exit dialog
#			end if

		on action Customer
			if vg_customer_actioned = "Y"
			then
				call valid_error
					("","This action has already been invoked, Exit to re-view.","")
			ELSE
                if vr_comp.date_closed is not NULL
                THEN
                    # Only allow closed complaints to be updated
                    # by an authorized user.
                    # Unless its AV and AV WO USED = N, then let anyone update.
                    ## ABOVE LINE CHANGED - SEE BOB LANGHORNE
                    # Unless its AV and AV_ALWAYS_DISP_RUN = Y, then let anyone update
                    #  all usual fields as if running and don't ask for password.
                    #  If its AV and AV_ALWAYS_DISP_RUN = N, then ask for password
                    #  and only allow update of SOURCE and POSITION
                    let vl_del_flag = TRUE
                    if vg_av_installation = "Y"
                    and vr_comp.service_c = vg_av_service
#   				and skey_check("AV WO USED", "ALL") = "N"
                    and skey_check("AV_ALWAYS_DISP_RUN", "ALL") = "Y"
                    THEN
                        let vl_del_flag = FALSE
                    ELSE
                        IF NOT continue_yn("Enquiry is closed, view Customer details only")
                        THEN 
                            if get_passwd()
                            THEN
                                if vg_passwd = skey_check("COMPLAIN_PW", "ALL")
                                THEN
                                    let vl_del_flag = FALSE
                                end IF
                            end IF
                        end IF
                    end IF
                else
                    let vl_del_flag = FALSE
                end IF
                IF NOT vl_del_flag
                THEN
                    let vg_customer_actioned = "Y"
                    let vl_save_action_type = vg_action_type # bjg 31.03.2003
                    if not add_complainant(false, false, "U") then end IF
                    let vg_action_type = vl_save_action_type # bjg 31.03.2002
                    let vg_customer_actioned = "N"
                    call set_comp_options()
                    call get_complain_row(vg_progress, 0)
                    call set_actions_step(DIALOG)
                ELSE 
                    let vg_customer_actioned = "Y"
                    let vl_save_action_type = vg_action_type # bjg 31.03.2003
                    CALL disp_comp_cust_sc_show(vr_comp.complaint_no)
                    let vg_action_type = vl_save_action_type # bjg 31.03.2002
                    let vg_customer_actioned = "N"
                    call set_comp_options()
                    call get_complain_row(vg_progress, 0)
                    call set_actions_step(DIALOG)
                END IF 
			end if

		on action related
			call drive_enforce_destination()
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action replicated
			call drive_show_replications()
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action ViewGazetteer
			call show_enhanced_property_details(vr_comp.site_ref)

		on action MonitorResults
			let vl_runstr = 
				"exec fglgo_monitor_main ", 
				vr_comp.complaint_no using "<<<<<<<<"
			call os_exec(vl_runstr, false)
#here

		on action dest
			call save_wo_del_contact()
			call drive_destination_display()
			if vr_comp.text_flag = "N"
			then
				select count(*)
					into vl_count
				from comp_text
					where complaint_no = vr_comp.complaint_no

				if vl_count
				then
					let vr_comp.text_flag = "Y"
					update comp 
						set text_flag = "Y"
					where complaint_no = vr_comp.complaint_no
					display by name vr_comp.text_flag attributes(yellow,reverse)
				end if
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)


			on action saleinfo
				select * into vr_comp_weee_sale.*
					from comp_weee_sale
					where sale_no = vr_comp.complaint_no
				call weee_sale_details("QUERY")
					returning vg_null, vg_null, vg_null

			on action worksched
				select wo_key
					into vl_wo_key
				from wo_h
					where wo_ref = vr_comp.dest_ref
					and wo_suffix = vr_comp.dest_suffix

				if status != notfound
				then
					let vl_runcomm = "exec fglgo_work_sched ",
						vl_wo_key using "<<<<<<<"
					call os_exec(vl_runcomm, false)
				else
					call valid_error("","Work schedule could not be located","")
				end if

			on action av_status
				call show_av_status()
				call display_av_status()
				call get_complain_row(vg_progress, 0)

			on action hway_status
				call show_hway_status()	
				call get_complain_row(vg_progress, 0)

			on action location
				case
					when vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
						call show_av_loc_history()
					when vr_comp.service_c = vg_enf_service
					and vg_enf_installation = "Y"
						call show_enf_loc_history()
				end case

			on action officer
				call show_av_off_history()

			on action avemailp
				if allow("av_police_email")
				then
					select date_police_email 
						into vl_date_police_email
					from comp_av
						where complaint_no = vr_comp.complaint_no

					if vl_date_police_email is not null 
					then
						let vl_message_text =
						"Police E-mail ALREADY SENT ",
						vl_date_police_email 
						using "dd/mm/yyyy", ".",
						" Are you sure you want to",
						" RESEND to Police"
					else
						let vl_message_text =
							"Are you sure you want ",
							"to send an e-mail to the ",
							"Police"
					end if
					if continue_yn(vl_message_text) 
					then
						call mstart_wait
							("Sending Police E-mail, Please Wait ...")
						let vl_police_email = 
							skey_check("AV POLICE EMAIL", "ALL")
						call av_police_email(vl_police_email)
											returning vl_return_date
						call end_wait()

						if vl_return_date is not null 
						then
							update comp_av
								set date_police_email = vl_return_date
							where complaint_no = vr_comp.complaint_no
						end if
					end if
				end if

			on action avemailf
				if allow("av_fire_email")
				then
					select date_fire_email into vl_date_fire_email
					from comp_av
						where complaint_no = vr_comp.complaint_no	

					if vl_date_fire_email is not null 
					then
						let vl_message_text =
							"Fire Service E-mail",
							" ALREADY SENT ",
							vl_date_fire_email 
							using "dd/mm/yyyy", ".",
							" Are you sure you want to",
							" RESEND to Fire Service"
					else
						let vl_message_text =
				"Are you sure you want to send an e-mail to the Fire Service"
					end if
					if continue_yn(vl_message_text) 
					then
						call mstart_wait
							("Sending Fire Service E-mail, Please Wait ...")
						let vl_fire_email = skey_check("AV_FIRE_EMAIL","ALL")
						call av_fire_email(vl_fire_email) 
													returning vl_return_date
						call end_wait()

						if vl_return_date is not null 
						then
							update comp_av
								set date_fire_email = vl_return_date
							where complaint_no = vr_comp.complaint_no
						end if
					end if
				end if

			on action avemailh
				if allow("av_housing_email")
				then
					select date_housing_email into vl_date_housing_email
					from comp_av
						where complaint_no = vr_comp.complaint_no

					if vl_date_housing_email is not null
					then
						let vl_message_text =
								"Housing Service E-mail ALREADY SENT ",
								vl_date_housing_email using "dd/mm/yyyy", ".",
								" Are you sure you want to RESEND to Housing"
					else
						let vl_message_text =
				"Are you sure you want to send an e-mail to the Housing Service"
					end if
					if continue_yn(vl_message_text) 
					then
						call mstart_wait
							("Sending Housing Service E-mail, Please Wait ...")
						let vl_housing_email = skey_check("AV_HOUSING_EMAIL","ALL")
						call av_housing_email(vl_housing_email) 
													returning vl_return_date
						call end_wait()

						if vl_return_date is not null 
						then
							update comp_av
								set date_housing_email = vl_return_date
							where complaint_no = vr_comp.complaint_no
						end if
					end if
				end if

			on action showenf
				let vl_enforcement_ref = 0
				if vg_enf_installation = "Y"
				or vg_enf_trade_installation = "Y"
				then
					# Find out if the complaint has a 
					# related enforcement
{
					select complaint_no
						into vl_enforcement_ref
					from comp_enf
						where source_ref = vr_comp.complaint_no
}
					select enf_complaint_no
						into vl_enforcement_ref
					from comp_enf_link
						where source_complaint = vr_comp.complaint_no
				end if
				if vl_enforcement_ref
				then
					let vl_runstr = "exec fglgo_complain X X X X X ", 
										vl_enforcement_ref
					call os_exec(vl_runstr, false)
				end if

			on action dhoinfo
				call disp_dho()

			on action dhoupdate
				select * into vr_comp_av.* from comp_av
					where complaint_no = vr_comp.complaint_no
				call add_dho(vr_comp.recvd_by,
						vr_comp_av.dho_rep, vr_comp_av.dho_cc_building)
					returning vg_av_arr.dho_rep, vg_av_arr.dho_cc_building
				call set_comp_options()
				if vg_av_arr.dho_rep is not null
				then
					update comp_av
						set dho_rep = vg_av_arr.dho_rep,
							dho_cc_building = vg_av_arr.dho_cc_building
						where complaint_no = vr_comp.complaint_no
				end if

			{
			on action enforcement
				let vl_runstr = 
					"exec fglgo_complain X X X X X ", 
					vl_enforcement_ref
				call os_exec(vl_runstr, false)
			}

			on action hpicheck
				let vl_lookup_text =
						skey_check("AV HPI WEB", "ALL")
				call av_hpi_web(vl_lookup_text)

			on action evidence
				call enter_evidence(vr_comp.complaint_no)
				call get_complain_row(vg_progress, 0)

			on action suspect
				call enf_suspect("S",9,vr_comp.complaint_no)
					returning g_enf_suspect.suspect_ref
				call display_enf_status()
				call get_complain_row(vg_progress, 0)

			on action actions
				if length(vg_enf_arr.suspect_ref) then
					call enf_action(14,vr_comp.complaint_no)
					call display_enf_status()
					call set_comp_options()
					call get_complain_row(vg_progress, 0)
					call set_actions_step(DIALOG)
				else
					call valid_error ("",
						"Please add suspect details before adding any actions",
						"I")
				end if

			on action addaction
				if length(vg_enf_arr.suspect_ref) then
					if add_enf_action(2, vr_comp.complaint_no)
					then
						#
					end if
					call get_complain_row(vg_progress, 0)
					call set_actions_step(DIALOG)
				else
					call valid_error ("",
						"Please add suspect details before adding any actions",
						"I")
				end if

			on action costs
				call enf_costs(vr_comp.complaint_no)
				call get_complain_row(vg_progress, 0)
				call set_actions_step(DIALOG)

			on action addcost
				if add_enf_costs(vr_comp.complaint_no)
				then
					#
				end if
				call get_complain_row(vg_progress, 0)
				call set_actions_step(DIALOG)

			on action tandc
				if ert_information_pt2(0) then end if

			on action tandcup
				if ert_information_pt2(1) then end if

			on action detail
			case 
				when vr_comp.service_c = vg_av_service
				and vg_av_installation = "Y"
					call show_av_status()
					call display_av_status()
					if select_complain(vg_progress)
					then
						call disp_comp_count()
						call disp_comp_looks()
					end if

				when vr_comp.service_c = vg_dart_service
				and vg_dart_installation = "Y"
					call display_dart_information(false)

				when vr_comp.service_c = vg_ert_service
				and vg_ert_installation = "Y"
					call display_ert_information(true, false)

				when vr_comp.service_c = vg_sw_service
				and vg_sw_installation = "Y"
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "V"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_visits_display")
					then
						call display_warden_information
							(vr_comp.complaint_no, "V")
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "L"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_leaflet_display")
					then
						call display_warden_information
							(vr_comp.complaint_no, "L")
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "P"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_propmrk_display")
					then
						call display_warden_information
							(vr_comp.complaint_no, "P")
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "C"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_cardrem_display")
					then
						call display_warden_information
							(vr_comp.complaint_no, "C")
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "I"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_incident_display")
					then
						if allow("sw_incident_display")
						then
							call display_incident_information
								(vr_comp.complaint_no, false)
						end if
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "R"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_referral_display")
					then
						if allow("sw_referral_display")
						then
							call display_referral_information
								(vr_comp.complaint_no, false)
						end if
					end if

				when vr_comp.service_c = vg_sl_service
				and vg_sl_installation = "Y"
					call sl_history
						(vg_hidden_sl_sf[vg_ac_line].inv_id, false)
					let vg_show_source = false
					let vg_action_type = true
					call get_complain_row(vg_progress, 0) 
					call set_actions_step(DIALOG)

				otherwise
					call valid_error("Program error",
						"complain.4gl:  action detail invalid","")

			end case

			on action detailup
			case 
{
				when vr_comp.service_c = vg_av_service
				and vg_av_installation = "Y"
					call show_av_status()
					call display_av_status()
					if select_complain(vg_progress)
					then
						call disp_comp_count()
						call disp_comp_looks()
					end if
}

				when vr_comp.service_c = vg_dart_service
				and vg_dart_installation = "Y"
					call display_dart_information(true)

				when vr_comp.service_c = vg_ert_service
				and vg_ert_installation = "Y"
					call display_ert_information(true, true)

				when vr_comp.service_c = vg_sw_service
				and vg_sw_installation = "Y"
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "V"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_visits_display")
					then
						call display_warden_information
							(vr_comp.complaint_no, "V")
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "L"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_leaflet_display")
					then
						call display_warden_information
							(vr_comp.complaint_no, "L")
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "P"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_propmrk_display")
					then
						call display_warden_information
							(vr_comp.complaint_no, "P")
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "C"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_cardrem_display")
					then
						call display_warden_information
							(vr_comp.complaint_no, "C")
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "I"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_incident_display")
					then
						if allow("sw_incident_display")
						then
							call display_incident_information
								(vr_comp.complaint_no, false)
						end if
					end if
					select count(*)
						into vl_count
					from warden_item
						where warden_item_type = "R"
						and item_ref = vr_comp.item_ref
						and contract_ref = vr_si_i.contract_ref
					if vl_count
					and quiet_allow("sw_referral_display")
					then
						if allow("sw_referral_display")
						then
							call display_referral_information
								(vr_comp.complaint_no, false)
						end if
					end if

				when vr_comp.service_c = vg_sl_service
				and vg_sl_installation = "Y"
					call sl_history
						(vg_hidden_sl_sf[vg_ac_line].inv_id, false)
					let vg_show_source = false
					let vg_action_type = true
					call get_complain_row(vg_progress, 0) 
					call set_actions_step(DIALOG)

				otherwise
					call valid_error("Program error",
						"complain.4gl:  action detail invalid","")

			end case

{
		on action Text
			if allow("disp_comp_text")
			then
				let vg_customer_save.* = vr_customer.*
				call disp_scroll_complain_n(0)
				call set_comp_options()
				let vr_customer.* = vg_customer_save.*
				display by name vr_comp.text_flag attributes(yellow,reverse)
			end if

		on action T
			if allow("disp_comp_text")
			then
				let vg_customer_save.* = vr_customer.*
				call disp_scroll_complain_n(0)
				call set_comp_options()
				let vr_customer.* = vg_customer_save.*
				display by name vr_comp.text_flag attributes(yellow,reverse)
			end if
}

		on action History
			if length(vr_comp.site_ref)
			then
				let vr_comp.build_no = vr_comp.build_no clipped
				let vr_comp.build_name = vr_comp.build_name clipped
				let vg_comp_save.* = vr_comp.*
				let vg_customer_save.* = vr_customer.*
				call history_save_text(true)	
				let m_comp_arr_count = 0

				call prompt_for_scroll(false, "L")

				let vr_comp.* = vg_comp_save.*
				let vr_customer.* = vg_customer_save.*
				call history_save_text(false)	
				#ADJrunner
				if not vg_runner_call
				then
					let vg_show_source = false
					let vg_action_type = true
				end if
				call get_complain_row(vg_progress, 0)
				call set_actions_step(DIALOG)
			else
				call valid_error("",
			"The selected property does not exist in the geographical data",
					"")
			end if

		on action UserPrint
			call print_comp_notice(vr_comp.complaint_no)
			call check_action("Enquiry:Re-Print", vr_comp.complaint_no)
			call set_comp_options()
			call valid_error("", "The selected record has been printed", "")

		on action print_current
			call print_comp_notice(vr_comp.complaint_no)
			call check_action("Enquiry:Re-Print", vr_comp.complaint_no)
			call set_comp_options()
			call valid_error("", "The selected record has been printed", "")

		on action print_selected
			declare ic_pa_2 cursor for
				select complaint_no from comp_01
				order by complaint_no asc

			foreach ic_pa_2 into f_complaint_no
				call print_comp_notice(f_complaint_no)
				call check_action("Enquiry:Re-Print", f_complaint_no)
			end foreach
			call set_comp_options()
			call valid_error("", "The selected record(s) have been printed", "")

		on action print_default
			let vr_defh.cust_def_no = vr_comp.dest_ref
			let vr_defh.contract_ref = vr_comp.contract_ref
			call print_default_action(false)	
			call set_comp_options()
			call valid_error("", 
				"The selected rectification has been printed", "")

		on action print_works_order
			call print_works_order_notice(vr_comp.dest_ref, vr_comp.dest_suffix)
			call valid_error("", 
				"The selected works order has been printed", "")

		on action print_letter
			call print_scroll_complain_n()
			call set_comp_options()

#		command key(I) "Inventory" 
#			"Display street lighting inventory information."
		on action inventory
{
            if vr_comp.service_c = vg_gm_service
			and vg_gm_installation = "Y"
			then
				# GM Stuff
			end if
}            
			if vr_comp.service_c = vg_sl_service
			and vg_sl_installation = "Y"
			then
				call display_comp_sl_sf(false,vg_progress,vg_tot_in_list)
				let vg_show_source = false
				let vg_action_type = true
				call get_complain_row(vg_progress, 0) 
				call set_actions_step(DIALOG)
				let vg_ac_line = 1
				let vg_sc_line = 1
			end if

		on action current_map
			if length(vr_comp.site_ref)
			then
				if skey_check("MAP_TYPE", "ALL") = "INTERNET" 
				then
					call display_map(vr_comp.site_ref, 
									vr_comp.easting,
									vr_comp.northing,
									"", 
									"", 
									"")
				else
					call display_map
					(
						vr_comp.site_ref,
						vr_comp.easting,
						vr_comp.northing,
						vr_comp.complaint_no,
						vr_comp.service_c,
						"COMPLAINT"
					)
				end if
			else
				call valid_error("",
			"The selected property does not exist in the geographical data",
					"")
			end if

		on action selected_map
			if length(vr_comp.site_ref)
			then
				if skey_check("MAP_TYPE", "ALL") = "INTERNET" 
				then
					call display_map(vr_comp.site_ref, 
									vr_comp.easting,
									vr_comp.northing,
									"", 
									"", 
									"")
				else
					if vg_tot_in_list > 1 
					then
						let vl_id = store_selected_points("COMPLAINT")
						call display_selected_map(vl_id)
					else
						call display_map
						(
							vr_comp.site_ref,
							vr_comp.easting,
							vr_comp.northing,
							vr_comp.complaint_no,
							vr_comp.service_c,
							"COMPLAINT"
						)
					end if
				end if
			else
				call valid_error("",
			"The selected property does not exist in the geographical data",
					"")
			end if

{
#		command key(up)
		on action previous # BJG - 09/04/2008
			if vr_comp.service_c = vg_sl_service
				and vg_sl_installation = "Y"
			then	
				if vg_ac_line > 1
				then
					let vg_ac_line = vg_ac_line - 1
					if vg_sc_line = 1
					then
						# shuffle downwards
						display vg_disp_sl_sf[vg_ac_line].* 
							to sa_sl_sf[1].*
						display vg_disp_sl_sf[vg_ac_line+1].* 
							to sa_sl_sf[2].*
						display vg_disp_sl_sf[vg_ac_line+2].* 
							to sa_sl_sf[3].*
					else
						let vg_sc_line = vg_sc_line - 1
						display vg_disp_sl_sf[vg_ac_line+1].* 
							to sa_sl_sf[vg_sc_line+1].*
						display vg_disp_sl_sf[vg_ac_line].* 
							to sa_sl_sf[vg_sc_line].*
					end if
					display vg_hidden_sl_sf[vg_ac_line].inv_id, 
							vg_hidden_sl_sf[vg_ac_line].lookup_text
						to inv_id, 
							fault_desc 
				else
					error "There are no more rows in the direction you are going"
				end if
			end if

#		command key(down)
		on action next # BJG - 09/04/2008
			if vr_comp.service_c = vg_sl_service
				and vg_sl_installation = "Y"
			then	
				if vg_ac_line < vg_sl_count
				then
					let vg_ac_line = vg_ac_line + 1
					if vg_sc_line = 3
					then
						# shuffle upwards
						display vg_disp_sl_sf[vg_ac_line-2].* 
							to sa_sl_sf[1].*
						display vg_disp_sl_sf[vg_ac_line-1].* 
							to sa_sl_sf[2].*
						display vg_disp_sl_sf[vg_ac_line].* 
							to sa_sl_sf[3].*
					else
						let vg_sc_line = vg_sc_line + 1
						display vg_disp_sl_sf[vg_ac_line-1].* 
							to sa_sl_sf[vg_sc_line-1].*
						display vg_disp_sl_sf[vg_ac_line].* 
							to sa_sl_sf[vg_sc_line].*
					end if
					display vg_hidden_sl_sf[vg_ac_line].inv_id, 
							vg_hidden_sl_sf[vg_ac_line].lookup_text
						to inv_id, 
							fault_desc 
				else
					error "There are no more rows in the direction you are going"
				end if
			end if
}

#		command key(I) "nappy-Information" 
#			"Display the selected nappy service record information"
		on action nappyinfo
			let vl_runcomm = "exec fglgo_nappy_disp ",
				vr_comp_nappy.nappy_ref using "<<<<<<<<", " A"
			call os_exec(vl_runcomm, false)

		on action createload
			call create_weee_load()
			select count(*)
				into vl_count
			from weee_load_hdr
				where source_ref = vr_comp.complaint_no
			if vl_count
			then
				call dialog.setActionActive("createload", false)
				call dialog.setActionActive("viewload", true)
			else
				call dialog.setActionActive("createload", true)
				call dialog.setActionActive("viewload", false)
			end if

		on action viewload
			let vl_runcomm = "exec fglgo_weee_load 1 Q ",
				vr_comp.complaint_no using "<<<<<<<<"
			call os_exec(vl_runcomm, false)


#		command key(I) "clinical-Information" 
#			"Display the selected clinical waste record information"
		on action clininfo
			let vl_runcomm = "exec fglgo_clin_disp ",
				vr_comp_clin.clinical_ref using "<<<<<<<<", " A"
			call os_exec(vl_runcomm, false)

#		command key(O) "allOcation" 
#			"Display/Update allocation information."
		on action alloc
			call enter_destination("D")
				returning vr_comp_destination.*

#		command key(G)	"taGs" 
		on action tags
			call disp_comp_tags(vr_comp.complaint_no)

		on action attachadd
			if skey_check("ATTACH_TRANS_METHOD", "ALL") = "UNC" 
			or skey_check("ATTACH_TRANS_METHOD", "ALL") = "MAPPED" 
			then
				if allow("add_attachment") 
				then
					let vl_attach_no = dialog.getcurrentrow("sa_attach")
					if vl_attach_no = 0
					then
						let vl_attach_no = 1
					end if
					call attachment("C",
						vr_comp.complaint_no,
						vm_attach_no[vl_attach_no],
						"Add",
						"Enquiry") #NP
					call get_complain_row(vg_progress,0)
					if vm_attach.getlength() > 0
					then
						call dialog.setActionHidden("attachdelete", false)
						call dialog.setActionActive("attachdelete", true)
						call dialog.setActionHidden("attachshow", false)
						call dialog.setActionActive("attachshow", true)
					end if
				end if
			end if

		on action attachdelete
			if skey_check("ATTACH_TRANS_METHOD", "ALL") = "UNC" 
			or skey_check("ATTACH_TRANS_METHOD", "ALL") = "MAPPED" 
			then
				if allow("delete_attachment") 
				then
					let vl_attach_no = dialog.getcurrentrow("sa_attach")
					if vl_attach_no = 0
					then
						let vl_attach_no = 1
					end if
					call attachment("C", 
						vr_comp.complaint_no,
						vm_attach_no[vl_attach_no],
						"delete",
						"Enquiry") #NP
					call get_complain_row(vg_progress,0)
					if vm_attach.getlength() > 0
					then
						call dialog.setActionHidden("attachdelete", false)
						call dialog.setActionActive("attachdelete", true)
						call dialog.setActionHidden("attachshow", false)
						call dialog.setActionActive("attachshow", true)
					else
						call dialog.setActionHidden("attachdelete", true)
						call dialog.setActionActive("attachdelete", false)
						call dialog.setActionHidden("attachshow", true)
						call dialog.setActionActive("attachshow", false)
					end if
				end if
			end if

		on action attachshow
			if skey_check("ATTACH_TRANS_METHOD", "ALL") = "UNC" 
			or skey_check("ATTACH_TRANS_METHOD", "ALL") = "MAPPED" 
			then
				let vl_attach_no = dialog.getcurrentrow("sa_attach")
				if vl_attach_no = 0
				then
					let vl_attach_no = 1
				end if
				call attachment("C",
					vr_comp.complaint_no,
					vm_attach_no[vl_attach_no],
					"Show",
					"Enquiry") #NP
			end if

#		command key(I) "tree-Information"
#			"Display the selected tree record information."
		on action treeinfo
			let vl_runstr = "fglgo_tree_sidetail ", vr_comp_tree.tree_ref
			call os_exec(vl_runstr, false)

		on action dbtrshow
			if vr_comp.service_c = vg_trade_service
			and vg_trade_installation = "Y"
			then
				select debtor.debtor_ref into vl_trade_ref
					from debtor, trade_site, agreement
				where trade_site.debtor_ref = debtor.debtor_ref
					and trade_site.site_no = agreement.site_ref
					and agreement.agreement_no = vr_comp_trade.agreement_no

				if vl_trade_ref > 0
				then
					let vl_runcomm = "exec fglgo_dbtr ",
						vl_trade_ref using "<<<<<<<", " A"
					call os_exec(vl_runcomm, true)
				else
					call valid_error("","Data error: Cannot display debtor","")
				end if
			else
				select * into g_agreement_h.* from agreement_h
					where agreement_no = vr_comp_agreq.agreement_no_h
				if status = 0
				then
					if length(g_agreement_h.live_site_ref)
					then
						select debtor.debtor_ref into vl_trade_ref
							from debtor, trade_site
							where trade_site.debtor_ref = debtor.debtor_ref
							and trade_site.site_no = g_agreement_h.live_site_ref
						if vl_trade_ref > 0
						then
							let vl_runcomm = "exec fglgo_dbtr ",
								vl_trade_ref using "<<<<<<<", " A"
							call os_exec(vl_runcomm, true)
						else
							call valid_error("","Data error: Cannot display debtor","")
						end if
					else
						if length(g_agreement_h.site_ref)
						then
							select * into g_trade_site_h.* from trade_site_h
								where site_no = g_agreement_h.site_ref
							if status = 0
							then
								if length(g_trade_site_h.live_debtor_ref)
								then
									let vl_runcomm = "exec fglgo_dbtr ",
									g_trade_site_h.live_debtor_ref using "<<<<<<<", " A"
									call os_exec(vl_runcomm, true)
								else
									if length(g_trade_site_h.debtor_ref)
									then
										let vl_runcomm = "exec fglgo_dbtr_h ",
											g_trade_site_h.debtor_ref using "<<<<<<<", " A"
										call os_exec(vl_runcomm, true)
									else
										call valid_error
											("","Data error: Cannot display debtor","")
									end if
								end if
							else
								call valid_error
									("","Data error: Cannot display debtor","")
							end if
						else
							call valid_error("","Data error: Cannot display debtor","")
						end if
					end if
				else
					call valid_error("","Data error: Cannot display debtor","")
				end if
			end if
			call get_complain_row(vg_progress, 0)

{
		on action dbtrshow2
			if vr_comp.service_c = vg_trade_service
			and vg_trade_installation = "Y"
			then
				select debtor.debtor_ref into vl_trade_ref
					from debtor, trade_site, agreement
				where trade_site.debtor_ref = debtor.debtor_ref
					and trade_site.site_no = agreement.site_ref
					and agreement.agreement_no = vr_comp_trade.agreement_no

				if vl_trade_ref > 0
				then
					let vl_runcomm = "exec fglgo_dbtr ",
						vl_trade_ref using "<<<<<<<", " A"
					call os_exec(vl_runcomm, true)
				else
					call valid_error("","Data error: Cannot display debtor","")
				end if
			else
				select * into g_agreement_h.* from agreement_h
					where agreement_no = vr_comp_agreq.agreement_no_h
				if status = 0
				then
					if g_agreement_h.live_site_ref
					then
						select debtor.debtor_ref into vl_trade_ref
							from debtor, trade_site
							where trade_site.debtor_ref = debtor.debtor_ref
							and trade_site.site_no = g_agreement_h.live_site_ref
						if vl_trade_ref > 0
						then
							let vl_runcomm = "exec fglgo_dbtr ",
								vl_trade_ref using "<<<<<<<", " A"
							call os_exec(vl_runcomm, true)
						else
							call valid_error("","Data error: Cannot display debtor","")
						end if
					else
						if g_agreement_h.site_ref
						then
							select * into g_trade_site_h.* from trade_site_h
								where site_no = g_agreement_h.site_ref
							if status = 0
							then
								if g_trade_site_h.live_debtor_ref
								then
									let vl_runcomm = "exec fglgo_dbtr ",
									g_trade_site_h.live_debtor_ref using "<<<<<<<", " A"
									call os_exec(vl_runcomm, true)
								else
									if g_trade_site_h.debtor_ref
									then
										let vl_runcomm = "exec fglgo_dbtr_h ",
											g_trade_site_h.debtor_ref using "<<<<<<<", " A"
										call os_exec(vl_runcomm, true)
									else
										call valid_error
											("","Data error: Cannot display debtor","")
									end if
								end if
							else
								call valid_error
									("","Data error: Cannot display debtor","")
							end if
						else
							call valid_error("",
								"Data error: Cannot display debtor","")
						end if
					end if
				else
					call valid_error("","Data error: Cannot display debtor","")
				end if
			end if
			call get_complain_row(vg_progress, 0)
}

		on action trstshow
			if vr_comp.service_c = vg_trade_service
			and vg_trade_installation = "Y"
			then
				select trade_site.site_no into vl_trade_ref
					from trade_site, agreement
				where trade_site.site_no = agreement.site_ref
					and agreement.agreement_no = vr_comp_trade.agreement_no

				if vl_trade_ref > 0
				then
					let vl_runcomm = "exec fglgo_trst ",
						vl_trade_ref using "<<<<<<<", " A"
					call os_exec(vl_runcomm, true)
				else
					call valid_error("",
						"Data error: Cannot display trade site","")
				end if
			else
				select * into g_agreement_h.* from agreement_h
					where agreement_no = vr_comp_agreq.agreement_no_h
				if status = 0
				then
					if length(g_agreement_h.live_site_ref)
					then
						let vl_runcomm = "exec fglgo_trst ",
							g_agreement_h.live_site_ref using "<<<<<<<", " A"
						call os_exec(vl_runcomm, true)
					else
						if g_agreement_h.site_ref
						then
							let vl_runcomm = "exec fglgo_trst_h ",
								g_agreement_h.site_ref using "<<<<<<<", " A"
							call os_exec(vl_runcomm, true)
						else
							call valid_error
									("","Data error: Cannot display trade site","")
						end if
					end if
				else
					call valid_error("","Data error: Cannot display trade site","")
				end if
			end if
			call get_complain_row(vg_progress, 0)

{
		on action trstshow2
			if vr_comp.service_c = vg_trade_service
			and vg_trade_installation = "Y"
			then
				select trade_site.site_no into vl_trade_ref
					from trade_site, agreement
				where trade_site.site_no = agreement.site_ref
					and agreement.agreement_no = vr_comp_trade.agreement_no

				if vl_trade_ref > 0
				then
					let vl_runcomm = "exec fglgo_trst ",
						vl_trade_ref using "<<<<<<<", " A"
					call os_exec(vl_runcomm, true)
				else
					call valid_error("",
						"Data error: Cannot display trade site","")
				end if
			else
				select * into g_agreement_h.* from agreement_h
					where agreement_no = vr_comp_agreq.agreement_no_h
				if status = 0
				then
					if g_agreement_h.live_site_ref
					then
						let vl_runcomm = "exec fglgo_trst ",
							g_agreement_h.live_site_ref using "<<<<<<<", " A"
						call os_exec(vl_runcomm, true)
					else
						if g_agreement_h.site_ref
						then
							let vl_runcomm = "exec fglgo_trst_h ",
								g_agreement_h.site_ref using "<<<<<<<", " A"
							call os_exec(vl_runcomm, true)
						else
							call valid_error
								("","Data error: Cannot display trade site","")
						end if
					end if
				else
					call valid_error("","Data error: Cannot display trade site","")
				end if
			end if
			call get_complain_row(vg_progress, 0)
}

		on action agmtshow
			if vr_comp.service_c = vg_trade_service
			and vg_trade_installation = "Y"
			then
				if length(vr_comp_trade.agreement_no) > 0
				then
					let vl_runcomm = "exec fglgo_agmt ",
						vr_comp_trade.agreement_no clipped, " A"
					call os_exec(vl_runcomm, true)
				else	
					call valid_error("","Data error: Cannot display agreement","")
				end if
			else
				select * into g_agreement_h.* from agreement_h
					where agreement_no = vr_comp_agreq.agreement_no_h
				if status = 0
				then
					if g_agreement_h.live_agreement_no
					then
						let vl_runcomm = "exec fglgo_agmt ",
							g_agreement_h.live_agreement_no clipped, " A"
						call os_exec(vl_runcomm, true)
					else	
						let vl_runcomm = "exec fglgo_agmt_h ",
							g_agreement_h.agreement_no clipped, " A"
						call os_exec(vl_runcomm, true)
					end if
				else	
					call valid_error("","Data error: Cannot display agreement","")
				end if
			end if
			call get_complain_row(vg_progress, 0)

#		command key(B) "Bv199" "View BV199 details."
		on action bv199
			call show_bv199()

        ON ACTION bsp
            IF vr_comp.service_c = vg_trade_service
            AND vg_trade_installation = "Y"
            THEN
                let vg_task_line  = dialog.getCurrentRow("sa_tasks")
                IF vg_task_line
                THEN
                    CALL view_bsp(vr_comp.service_c, vg_agtsks[vg_task_line].task_ref, vg_agtsks[vg_task_line].comp_code)
                ELSE
                    CALL view_bsp(vr_comp.service_c, "", "")
                END IF 
            ELSE 
                CALL view_bsp(vr_comp.service_c, vr_comp.item_ref, vr_comp.comp_code)
            END IF 

        ON ACTION gis
            IF vr_comp.service_c = vg_trade_service
            AND vg_trade_installation = "Y"
            THEN
                let vg_task_line  = dialog.getCurrentRow("sa_tasks")
                IF vg_task_line
                THEN
                    CALL view_gis(vr_comp.site_ref, vr_comp.service_c, vg_agtsks[vg_task_line].task_ref, vg_agtsks[vg_task_line].comp_code)
                ELSE
                    CALL view_gis(vr_comp.site_ref, vr_comp.service_c, "", "")
                END IF 
            ELSE 
                CALL view_gis(vr_comp.site_ref, vr_comp.service_c, vr_comp.item_ref, vr_comp.comp_code)
            END IF 
            
		on action reset
			let vg_map_easting = vr_comp.easting
			let vg_map_northing = vr_comp.northing
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"reset")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_zoom_in
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_zoom_in")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_zoom_out
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_zoom_out")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_up
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_up")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_down
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_down")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_left
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_left")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_right
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_right")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action about
			call os_exec("exec fglgo_about", 1)

		on action exit
			let vl_q_flag = 0
			exit program

		on action close
			let vl_q_flag = 0
			exit program

		on action hiddentxt
			call complaint_history()
			call get_complain_row(vg_progress, 0)

		on action source
			call show_comp_source()
			call get_complain_row(vg_progress, 0)

		on action def_credit
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			select * 
				into vr_defh.*
			from defh
				where cust_def_no = vr_comp.dest_ref
			select * 
				into vr_defi.*
			from defi
				where default_no = vr_comp.dest_ref
				and item_ref = vr_comp.item_ref
				and feature_ref = vr_comp.feature_ref
			if allow("credit_def") 
			then
				if length(vr_comp.item_ref)
				then
					if continue_yn
						("Credit the selected rectification")
					then
						if chk_for_cleared_item
							(vr_comp.dest_ref)
						and chk_header_stat
							(vr_comp.dest_ref)
						then
							call credit_default
								(vr_comp.dest_ref,0,0)
						else
							call valid_error("", 
				"The selected rectification has NOT been credited",
							"")
						end if
					end if
				end if
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_creditall 
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			select * 
				into vr_defh.*
			from defh
				where cust_def_no = vr_comp.dest_ref
			select * 
				into vr_defi.*
			from defi
				where default_no = vr_comp.dest_ref
				and item_ref = vr_comp.item_ref
				and feature_ref = vr_comp.feature_ref
			if allow("credit_def") 
			then
				if length(vr_comp.item_ref)
				then
					if continue_yn
					("Credit TOTALS of the selected rectification")
					then
						if chk_for_cleared_item
							(vr_comp.dest_ref)
						and chk_header_stat
							(vr_comp.dest_ref)
						then
							call credit_tot_default
								(vr_comp.dest_ref)
						else
							call valid_error("", 
						"The selected rectification has NOT been credited",
							"")
						end if
					end if
				end if
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_clear
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			select * 
				into vr_defh.*
			from defh
				where cust_def_no = vr_comp.dest_ref
			select * 
				into vr_defi.*
			from defi
				where default_no = vr_comp.dest_ref
				and item_ref = vr_comp.item_ref
				and feature_ref = vr_comp.feature_ref

			if allow("clear_def") 
			then
				if length(vr_comp.item_ref)
				then
					if continue_yn
						("Clear the selected rectification")
					then
						call clear_default(vr_comp.dest_ref, 0, 0)
						let vr_defh.cust_def_no = vr_comp.dest_ref
						let vr_defh.contract_ref = vr_comp.contract_ref
						call print_default_action(false)	
					end if
				end if
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_redefault
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			select * 
				into vr_defh.*
			from defh
				where cust_def_no = vr_comp.dest_ref
			select * 
				into vr_defi.*
			from defi
				where default_no = vr_comp.dest_ref
				and item_ref = vr_comp.item_ref
				and feature_ref = vr_comp.feature_ref
			if allow("re-def_def") 
			then
				if continue_yn
					("Re-Default the selected rectification")
				then
					if length(vr_comp.item_ref)
						and chk_for_cleared_item
							(vr_comp.dest_ref)
						and chk_header_stat
							(vr_comp.dest_ref)
					then
						let re_def_flag = true
						if re_default(vr_comp.dest_ref)
						then
							let vr_defh.cust_def_no = vr_comp.dest_ref
							let vr_defh.contract_ref = vr_comp.contract_ref
							call print_default_action(false)	
						end if
						let re_def_flag = false
					else
						call valid_error("", 
			"The selected rectification has NOT been redefaulted",
							"")
					end if
				end if
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_management
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			select * 
				into vr_defh.*
			from defh
				where cust_def_no = vr_comp.dest_ref
			select * 
				into vr_defi.*
			from defi
				where default_no = vr_comp.dest_ref
				and item_ref = vr_comp.item_ref
				and feature_ref = vr_comp.feature_ref
			if allow("man_act_def") 
			then
				if continue_yn
					("Are you sure you want to raise a management action")
				then
					if length(vr_comp.item_ref)
						and chk_header_stat(vr_comp.dest_ref)
					then
						call mng_action(vr_comp.dest_ref)
						let vr_defh.cust_def_no = vr_comp.dest_ref
						let vr_defh.contract_ref = vr_comp.contract_ref
						call print_default_action(false)	
					end if
				end if
			end if
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_conthist
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			call def_act_hist_disp(vr_comp.dest_ref)
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_Actioned
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			call set_def_cont_i_comp(vr_comp.dest_ref, 'A', '')
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_notactioned
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			call set_def_cont_i_comp(vr_comp.dest_ref, 'N', '')
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_Void
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
			call reset_def_cont_i(vr_comp.dest_ref,
									vr_comp.item_ref,
									vr_comp.feature_ref)
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_Unjustified
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref
            LET v_unjust_reason = unjustified_reason(vr_comp.dest_ref)
            IF NOT length(v_unjust_reason)
            THEN
                CALL valid_error("","Cannot set as unjustified as Reason was not identified","")
            ELSE 
                call set_def_cont_i_comp(vr_comp.dest_ref, 'U', v_unjust_reason)
            END IF 
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action def_completion 
			let gv_saved_item = vr_comp.item_ref
			let gv_saved_feature = vr_comp.feature_ref

			select *
				into fv_def_cont_i.*
			from def_cont_i
				where cust_def_no = vr_comp.dest_ref
				and	item_ref = vr_comp.item_ref
				and feature_ref = vr_comp.feature_ref

			select * 
				into vr_defh.*
			from defh
				where cust_def_no = vr_comp.dest_ref
		
			if fv_def_cont_i.action = "A"
			then
				call get_completion(fv_def_cont_i.*)
					returning fv_def_cont_i.completion_date,
					fv_def_cont_i.completion_time_h,
					fv_def_cont_i.completion_time_m

				update def_cont_i
					set completion_date = fv_def_cont_i.completion_date,
						completion_time_h = fv_def_cont_i.completion_time_h,
						completion_time_m = fv_def_cont_i.completion_time_m,
                        unjust_reason = NULL 
				where cust_def_no = vr_comp.dest_ref
				and	item_ref = vr_comp.item_ref
				and feature_ref = vr_comp.feature_ref

				if vg_crm_enhanced = "Y"
				then
					call pop_ci_export_variables(vr_comp.complaint_no)
					let vr_crm_import_export.transaction_type = "C"
					call unload_crm_export_file(vr_crm_import_export.*)
				end if

				call ws_ext_integration(0, vr_comp.dest_ref, "", "D")

			else
				call valid_error
				(
					"",
"The record must be actioned before the completion information can be updated",
					""
				)
			end if

		on action wo_status
			select *
				into vr_wo_h.*
			from wo_h
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
			call update_wo_header_stat()
            LET INT_FLAG = false
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

		on action wo_payinfo
			select *
				into vr_wo_h.*
			from wo_h
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
			let vl_wo_payment_f = vr_wo_h.wo_payment_f
            call wo_h_pay_of() # BJG 03/07/2012 - Workflow 2857
			if update_wo_h_payment() then end IF
            call wo_h_pay_cf() # BJG 03/07/2012 - Workflow 2857

# BJG 01/09/2010 - Do we need more here Camden issue 82 ??

			if vr_wo_h.service_c = vg_sched_service
			and vg_sched_installation = "Y"
			and vr_wo_h.wo_payment_f = "C"
			then
				if vr_wo_h.wo_payment_f != vl_wo_payment_f
				then
#					current window is iw_wo_h
					call progress_to_schedule(true)
#					current window is iw_wo_h_pay_d
				end if
			end if
			call get_complain_row(vg_progress, 0)

		on action wo_delinv
			select *
				into vr_wo_h.*
			from wo_h
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
			call del_inv_of()
			if add_invoice_address() 
			then 
				update wo_h 
					set * = vr_wo_h.*
				where wo_key = vr_wo_h.wo_key
				call check_action("Works-Order:Update", vr_wo_h.wo_key)
			end if
			call del_inv_cf()

		on action wo_addinfo
			select *
				into vr_wo_h.*
			from wo_h
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
			call wo_h_extra("A") returning vg_null

		on action wo_taskdets
			select woi_task_ref
				into vl_task_ref
			from wo_i
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
				and woi_no = 1

			let vl_runcomm = "exec fglgo_generic 1 \"", 
				vl_task_ref clipped, "\"", " U"
			call os_exec(vl_runcomm, false)

		on action wo_payinfo_v
			select *
				into vr_wo_h.*
			from wo_h
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
			call wo_h_payment_display()
			call get_complain_row(vg_progress, 0)

		on action wo_delinv_v
			select *
				into vr_wo_h.*
			from wo_h
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
			call manage_del_inv_info(true)

		on action wo_addinfo_v
			select *
				into vr_wo_h.*
			from wo_h
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
			call wo_h_extra("D") returning vg_null

		on action wo_taskdets_v
			select woi_task_ref
				into vl_task_ref
			from wo_i
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix
				and woi_no = 1

			let vl_runcomm = "exec fglgo_generic 1 \"", 
				vl_task_ref clipped, "\"", " D"
			call os_exec(vl_runcomm, false)

#		command key(A) "Add sale items" "Add details of items sold to customer"
		on action addsale
			call update_weee_sales_complain()
			call set_comp_options()
			call get_complain_row(vg_progress, 0)
			call set_actions_step(DIALOG)

#		command key(C) "Close sale" "Close this sales request"
		on action closesale
			call close_weee_sales_complain()
			call set_comp_options()
			if vr_comp.action_flag = "N"
			then
				call get_complain_row(vg_progress, 0)
				call set_actions_step(DIALOG)
			end if

		on action scheditems
            IF length(vr_comp.dest_ref)
            AND length(vr_comp.dest_suffix)
            THEN 
                select * into vr_wo_h.* from wo_h
                    where wo_ref = vr_comp.dest_ref
                    and wo_suffix = vr_comp.dest_suffix
            ELSE
                SELECT wo_type_f INTO vr_wo_h.wo_type_f FROM comp_sched
                    WHERE complaint_no = vr_comp.complaint_no

                LET vr_wo_h.contract_ref = vr_comp.contract_ref
            END IF 

            call item_sched_comp(vr_wo_h.wo_type_f, vr_wo_h.contract_ref, "U")
                returning vl_wo_type_f_new, vg_null 

			if length(vl_wo_type_f_new)
			then
				delete from comp_sched_item 
					where complaint_no = vr_comp.complaint_no
				call populate_comp_sched_item()
				call pop_display_collection_items()
					returning vl_comp_text, vl_quantity, vl_weighting_total, vg_null

				initialize vlr_wo_stat.* to null
				select * into vlr_wo_stat.* from wo_stat
					where wo_h_stat = vr_wo_h.wo_h_stat

				if vlr_wo_stat.assessment = "Y"
				or vr_comp.action_flag = "H"
				or skey_check("SCHED_UPDATE_ITEMS","ALL") = "Y" # BJG
				then
					update work_schedule set 
						waste_type = vl_comp_text,
						quantity = vl_quantity,
						weighting_total = vl_weighting_total
					where wo_key = vr_wo_h.wo_key
				else
					update work_schedule set 
						waste_type = vl_comp_text
					where wo_key = vr_wo_h.wo_key
				end if

				call set_comp_options()
				call get_complain_row(vg_progress, 0)
				call set_actions_step(DIALOG)
#				call disp_current_comp_screen("U")
#				display vl_quantity to quantity attribute(bold)
#				display vl_comp_text to waste_type attribute(bold)
			end if


	end dialog

	end if # BJG - end of mod to force update of new enforcement

	if vg_action_type
	then
		call qrymenu_cf()
	end if	

#	current window is iw_complain
	clear form
	call complain_labels()
#	display "Reference" to reference_label
#	display "History" to history_title

	while true
		if vg_action_type
		then
			drop table comp_01
		else	
			drop table comp_02
		end if

		if errtst()
		then
			exit while
		end if
	end while

	let vg_q_flag = vl_q_flag
	return vl_q_flag

end function	# query_complain


function update_complain()	# Update a complaint other than on hold
	define
		f_comp_destination	record
			destination			like comp_destination.destination,
			destination_date	like comp_destination.destination_date
							end record,
		vl_search			char(50),
		remarks_line		char(210),
		vl_mess				char(75),
		vl_lookup_text		like allk.lookup_text

	initialize vg_null to null

	let int_flag = false
	# We need to keep the existing complainant info...
	let vg_f3_pressed = true

	let f_comp_destination.destination = 
		vr_comp_destination.destination
	let f_comp_destination.destination_date = 
		vr_comp_destination.destination_date
{
    let remarks_line = vr_comp.details_1 clipped, " ",
						vr_comp.details_2 clipped, " ",
						vr_comp.details_3 clipped
}                        
	let remarks_line = form_remarks(vr_comp.details_1, vr_comp.details_2, vr_comp.details_3) 

--#	call fgl_keysetlabel("f3", vg_compln_title)
--#	call fgl_keysetlabel("f7", "History")

	display by name vr_comp.complaint_no,
					vr_comp.location_name, 
					vr_customer.compl_name,
					vr_customer.compl_surname,
					vr_comp.comp_code,
					vr_comp.postcode,
					vr_comp.item_ref

#	call gl_showpage("fold","generic_page")

	call before_update_correspond()
	input by name vr_comp.recvd_by,
				remarks_line,
				vr_comp_correspond.corr_entered,
				vr_comp_correspond.date_due,
				vr_comp_correspond.date_response,
				vr_comp_correspond.assigned_to
				without DEFAULTS

        BEFORE input
            IF NOT check_install("BSP")
            THEN
                call dialog.setActionHidden("bsp", true)
                call dialog.setActionActive("bsp", false)
            END IF 
            IF NOT check_install("GIS")
            THEN
                call dialog.setActionHidden("gis", true)
                call dialog.setActionActive("gis", false)
            END IF 
            
		on key(control-t)
			call complaint_history()
			call disp_complaint_history_text()

		on action Customer
			let vr_comp.service_c = get_fldbuf(service_c)
			let vr_comp.recvd_by = get_fldbuf(recvd_by)
			let remarks_line = get_fldbuf(remarks_line)

			let vg_comp_save.* = vr_comp.*
			let vg_customer_save.* = vr_customer.*

			if not add_complainant(false, false, "U") then end if

			let vr_comp.* = vg_comp_save.*
			let vr_customer.* = vg_customer_save.*
			call set_comp_options()

		#ADJ GENERO
		{
		on key(f6)
			let vg_comp_save.* = vr_comp.*
			let vg_customer_save.* = vr_customer.*
			call history_save_text(true)	
			let m_comp_arr_count = 0

			call join()

			let vr_comp.* = vg_comp_save.*
			let vr_customer.* = vg_customer_save.*
			call history_save_text(false)	
			call set_comp_options()
--#			call fgl_keysetlabel("f3", vg_compln_title)
--#			call fgl_keysetlabel("f7","History")
		}

		on action cancel
			let int_flag = true
			exit input

		on action close
			let int_flag = true
			exit input

		on action f2_lookup
			case
				when infield(assigned_to)
					call correspond_assign_lookup()
				when infield(recvd_by)
					call allk_look("CTSRC", "", "Y")
						returning vr_comp.recvd_by
					call set_comp_options()
					display vr_comp.recvd_by to recvd_by
					next field recvd_by

				otherwise
					call valid_error("",
						"There is no lookup available for this entry", "")
			end CASE

        ON ACTION bsp
            CALL view_bsp(vr_comp.service_c, vr_comp.item_ref, vr_comp.comp_code)

        ON ACTION gis
            CALL view_gis(vr_comp.site_ref, vr_comp.service_c, vr_comp.item_ref, vr_comp.comp_code)
            
 		after field recvd_by
# 			if vr_comp.recvd_by is not null
 			if length(vr_comp.recvd_by)
 			then
 				let vl_search = "lookup_func = 'CTSRC' and lookup_code = '", 
 					vr_comp.recvd_by clipped, "'"

 				if no_of_rows("allk", vl_search, "") = 0
				then
 					let vl_mess = " The source code ", vr_comp.recvd_by clipped,
 						" does not exist"
					call valid_error("", vl_mess,"")
					next field recvd_by
				end if
				initialize vl_lookup_text to null
				select lookup_text into vl_lookup_text from allk
					where lookup_func = "CTSCR"
					and lookup_code = vr_comp.recvd_by
				display vl_lookup_text to lookup_char
			end if

		after field corr_entered
			if not after_field_correspond("date_entered","U") then
				next field corr_entered
			end if
		after field date_due
			if not after_field_correspond("date_due","U") then
				next field date_due
			end if
		after field date_response
			if not after_field_correspond("date_response","U") then
				next field date_response
			end if
		after field assigned_to
			if not after_field_correspond("assigned_to","U") then
				next field assigned_to
			end if

		after input
			if not validate_correspond("U") then
				next field corr_entered
			end if
			if not length(vr_comp.recvd_by)
			then
				call valid_error("","The Complaint Source must be specified.","")
				next field recvd_by
			end if

	end input

	if int_flag
	then
		let int_flag = false
		return
	end if

	display by name vr_comp.complaint_no,
					vr_comp.location_name, 
					vr_customer.compl_name,
					vr_customer.compl_surname,
					vr_comp.comp_code,
					vr_comp.item_ref

	call format_field(70,3,remarks_line)
		returning vr_comp.details_1,
					vr_comp.details_2,
					vr_comp.details_3,
					vg_null_val, vg_null_val

	while true			# begin work
		update comp
			set recvd_by = vr_comp.recvd_by,
				text_flag = vr_comp.text_flag,
				details_1 = vr_comp.details_1,
				details_2 = vr_comp.details_2,
				details_3 = vr_comp.details_3
			where complaint_no = vr_comp.complaint_no

		call update_complaint_source()
		call save_correspond()

		update comp_destination
			set destination = f_comp_destination.destination,
				destination_date = f_comp_destination.destination_date
			where complaint_no = vr_comp.complaint_no

		if sqlca.sqlcode < 0
		then
			if errtst()
			then			# user selects to ignore error
				exit while
			else			# user selects to retry
				continue while
			end if
		end if

		exit while
	end while

	if vg_crm_enhanced = "Y"
	then
		call pop_ci_export_variables(vr_comp.complaint_no)
		let vr_crm_import_export.transaction_type = "C"
		call unload_crm_export_file(vr_crm_import_export.*)
	end if

	call ws_ext_integration(vr_comp.complaint_no, "", "", "")

    call check_action("Enquiry:Update", vr_comp.complaint_no)

	call set_comp_options()
end function	# update_complain


function disp_comp_count()
	options message line last
	message vg_record_title clipped, " ", vg_progress using "<<<<<<<", 
		" of ", vg_tot_in_list using "<<<<<<<" 
	options message line 2
end function	# disp_comp_count


function complain_help()
	call showhelp(get_complain_help_no())
end function	# complain_help


function get_complain_help_no()

	case
		when infield(date_entered)
			return 101

		when infield(time_h)
			return 102

		when infield(time_m)
			return 103

		when infield(date_entered)
			return 104

		when infield(location_c)
			return 105

		when infield(location_name)
			return 106

		when infield(location_desc)
			return 107

		when infield(compl_name)
			return 108

		when infield(compl_build_no)
			return 109

		when infield(compl_build_name)
			return 110

		when infield(compl_addr2)
			return 111

		when infield(compl_addr3)
			return 112

		when infield(compl_phone)
			return 113

		when infield(comp_code)
			return 114

		when infield(service_c)
			return 115

		when infield(details_1)
			return 116

		when infield(text_flag)
			return 117

		when infield(notice_type)
			return 118

		when infield(action_flag)
			return 119

		when infield(entered_by)
			return 121

		when infield(ent_time_h)
			return 122

		when infield(ent_time_m)
			return 123

		when infield(due_date)
			return 125

		when infield(date_due)
			return 126

		when infield(complaint_no)
			return 134

		when infield(build_no)
			return 141

		when infield(build_name)
			return 142

		when infield(destination)
			return 143

		when infield(recvd_by)
#			call display_recvd_info()
			return 124

		otherwise
			return 999
	end case

end function	# get_complain_help_no


function disp_comp_looks()
	define 
		#ADJ GENERO
		vl_service_desc		like keys.c_field,
		vl_area_ward_desc 	like area.area_name,
		vl_comp_code		char(10),
		vl_rec_count		smallint	

	initialize vr_site.* to null
	initialize vr_locn.* to null
	call vg_agtsks.clear()

	select *
		into vr_site.*
	from site
		where site_ref = vr_comp.site_ref

	select *
		into vr_locn.*
	from locn
		where location_c = vr_site.location_c

{ADJWEEE
	if skey_check("DISP_WARD_OR_AREA", "ALL") = "Y" 
	then
		select area_name
			into vl_area_ward_desc
		from area
			where area_c = vr_site.area_c
	else
		select ward_name
			into vl_area_ward_desc
		from ward
			where ward_code = vr_site.ward_code
	end if
}
	let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
	case 
		when vr_comp.service_c = vg_weee_service
			and vg_weee_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_weee_info() 
			call get_repl_info(1) 

		when vr_comp.service_c = vg_weee_sales_service
			and vg_sales_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_weee_sales_info() 
			call get_repl_info(1) 

		when vr_comp.service_c = vg_av_service
			and vg_av_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_av_info() 
			call get_repl_info(1) 

		when vr_comp.service_c = vg_enf_service
			and vg_enf_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_enf_info() 
			call get_repl_info(0) 

#ADJ ENFTR
		when vr_comp.service_c = vg_enf_trade_service
			and vg_enf_trade_installation = "Y"
			call get_enftr_info() 
			call get_repl_info(0) 

		when vr_comp.service_c = vg_sl_service
			and vg_sl_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_sl_info() 
			call display_item_info()
			call get_repl_info(1) 

		when vr_comp.service_c = vg_gm_service
			and vg_gm_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_gm_info()
			call display_item_info()
			call get_repl_info(1) 

			select lookup_text
				into vr_allk.lookup_text
			from allk
				where allk.lookup_code = vr_comp.comp_code
				and lookup_func = "COMPLA"

			display vr_comp.comp_code to gm_comp_code
			display vr_allk.lookup_text to gm_fault_desc
		when vr_comp.service_c = vg_ert_service
			and vg_ert_installation = "Y"
			and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			select count(*) 
				into vl_rec_count
			from si_i
				where si_i.site_ref = vr_comp.site_ref
				and si_i.item_ref = vr_comp.item_ref

			if vl_rec_count = 1
			then
				select *
					into vr_si_i.*
				from si_i
					where si_i.site_ref = vr_comp.site_ref
					and si_i.item_ref = vr_comp.item_ref
			end if
			call display_item_info()

			select lookup_text
				into vr_allk.lookup_text
			from allk
				where allk.lookup_code = vr_comp.comp_code
				and lookup_func = "COMPLA"

			display vr_comp.comp_code to ert_comp_code
			display vr_allk.lookup_text to ert_fault_desc
			let vr_comp.occur_day = set_occur_day(vr_comp.occur_day)

			call get_ert_info()
			call get_repl_info(1) 


		when vr_comp.service_c = vg_trees_service
			and vg_trees_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc

			select lookup_text
				into vr_allk.lookup_text
			from allk
				where allk.lookup_code = vr_comp.comp_code
				and lookup_func = "COMPLA"

			display vr_comp.comp_code to tree_comp_code
			display vr_allk.lookup_text to tree_fault_desc
			call display_item_info()
			call get_tree_info() 
			call display_tree_info(vr_comp_tree.tree_ref)
			call get_repl_info(1) 

		when vr_comp.service_c = vg_hway_service
			and vg_hway_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_hway_info() 
			call display_item_info()
			call get_repl_info(1) 

			select lookup_text
				into vr_allk.lookup_text
			from allk
				where allk.lookup_code = vr_comp.comp_code
				and lookup_func = "HWYDEF"

			display vr_comp.comp_code to hway_comp_code
			display vr_allk.lookup_text to hway_fault_desc

		when vg_ms_installation = "Y"
		and vg_ms_fault_codes matches vl_comp_code
		and length(vr_comp.comp_code)
			call get_measurement_info()
			select count(*) 
				into vl_rec_count
			from si_i
				where si_i.site_ref = vr_comp.site_ref
				and si_i.item_ref = vr_comp.item_ref

			if vl_rec_count = 1
			then
				select *
					into vr_si_i.*
				from si_i
					where si_i.site_ref = vr_comp.site_ref
					and si_i.item_ref = vr_comp.item_ref
			end if
			call display_item_info()

			select lookup_text
				into vr_allk.lookup_text
			from allk
				where allk.lookup_code = vr_comp.comp_code
				and lookup_func = "COMPLA"

			display vr_comp.comp_code to meas_comp_code
			display vr_allk.lookup_text to meas_fault_desc

			let vr_comp.occur_day = set_occur_day(vr_comp.occur_day)
			call get_repl_info(1) 

		when vr_comp.service_c = vg_trade_service
			and vg_trade_installation = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			let g_agreement.agreement_no = vr_comp_trade.agreement_no
			let vg_new_codes = 0
			call load_agree_tasks(vr_comp.complaint_no,1)
			let g_no_of_agtsk = 1
#			call display_agree_tasks(1, "E") # BJG - 11/04/2008 now in dialog
			call display_item_info()
			call get_repl_info(1) 

		when vr_comp.service_c = vg_agreq_service
			and vg_agreq_installation = "Y"
# BJG - CODE TO GET AGREQ DETAILS
{ +++++++++++++++++++++++++++++++
#			display vl_area_ward_desc to area_ward_desc
			let g_agreement.agreement_no = vr_comp_trade.agreement_no
			let vg_new_codes = 0
			call load_agree_tasks(vr_comp.complaint_no,1)
			let g_no_of_agtsk = 1
#			call display_agree_tasks(1, "E") # BJG - 11/04/2008 now in dialog
}
			call get_repl_info(1) 

		when vr_comp.service_c = vg_nappy_service
			and vg_nappy_installation = "Y"
			call get_nappy_info()
			call display_item_info()
			call get_repl_info(1) 

			select lookup_text
				into vr_allk.lookup_text
			from allk
				where allk.lookup_code = vr_comp.comp_code
				and lookup_func = "COMPLA"

#			display vr_allk.lookup_text to nappy_fault_desc

			let vr_comp.occur_day = set_occur_day(vr_comp.occur_day)

		when vr_comp.service_c = vg_clin_service
			and vg_clin_installation = "Y"
			call get_clin_info()
			call display_item_info()
			call get_repl_info(1) 

			select lookup_text
				into vr_allk.lookup_text
			from allk
				where allk.lookup_code = vr_comp.comp_code
				and lookup_func = "COMPLA"

			display vr_allk.lookup_text to fault_desc

			let vr_comp.occur_day = set_occur_day(vr_comp.occur_day)

#		when vr_comp.service_c = skey_check("SCHED_SERVICE", "ALL")
#			and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
		when vr_comp.service_c = vg_sched_service
			and vg_sched_installation = "Y"
			and vg_weee_installation = "N"
			and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_sched_info()
			call get_repl_info(1) 

#		when vr_comp.service_c = skey_check("SCHED_SERVICE", "ALL")
#			and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
		when vr_comp.service_c = vg_sched_service
			and vg_sched_installation = "Y"
			and vg_weee_installation = "Y"
			and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			call get_sched_info()
			#ADJ_WEEE_FIX
			#call get_weee_sched_info()
			call get_repl_info(1) 

		otherwise
#ADJWEEE
#			display vl_area_ward_desc to area_ward_desc
			select count(*) 
				into vl_rec_count
			from si_i
				where si_i.site_ref = vr_comp.site_ref
				and si_i.item_ref = vr_comp.item_ref

			if vl_rec_count = 1
			then
				select *
					into vr_si_i.*
				from si_i
					where si_i.site_ref = vr_comp.site_ref
					and si_i.item_ref = vr_comp.item_ref
			end if
			call display_item_info()
			call get_repl_info(1) 

			select lookup_text
				into vr_allk.lookup_text
			from allk
				where allk.lookup_code = vr_comp.comp_code
				and lookup_func = "COMPLA"

			display vr_allk.lookup_text to fault_desc
			display vr_allk.lookup_text to sl_fault_desc

			let vr_comp.occur_day = set_occur_day(vr_comp.occur_day)

	end case

	call disp_complaint_history_text()

	call show_attach_flag()

	if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
		call get_correspond_info()
	end if

#ADJ Genero	
#(
	select keydesc
		into vl_service_desc
	from keys
		where service_c = vr_comp.service_c
		and keyname = "HEADER"

	if (vg_agreq_service = vr_comp.service_c
	and vg_agreq_installation = "Y")
	then
		call display_stage_info()
		call display_recvd_info()
	else
		call display_recvd_info()
		if (vg_trade_service = vr_comp.service_c
		and vg_trade_installation = "Y")
		or (vg_enf_trade_service = vr_comp.service_c
		and vg_enf_trade_installation = "Y")
		then
			# Do nothing
		else
			#display vl_service_desc to service_desc
		end if
	end if

#)
#ADJ Genero	
end function	# disp_comp_looks


function get_complain_row(vl_irow, vl_idirection)
	define
		vl_irow				integer,
		vl_idirection		integer,
		vl_orow				integer,
		vl_tdirection		integer

	let vl_orow = vl_irow
	let vl_tdirection = vl_idirection

	while true
		let vl_orow = vl_orow + vl_tdirection

		if vl_orow < 1
		or vl_orow > vg_tot_in_list
		then		# Change direction of search
			let vl_tdirection = 0 - vl_tdirection

			if vl_tdirection = vl_idirection
			then		# there are no rows left #
				let vl_orow = 0
				exit while
			end if
		
			error "There are no more rows in the direction you are going ..."

			continue while
		end if

		let vg_rcode = select_complain(vl_orow)

		exit while
	end while

	let vg_progress = vl_orow
	call disp_comp_looks()
	call disp_comp_count()
end function	# get_complain_row


function select_complain(vl_row)
	define
		remarks_line		char(210),
		vl_comp_code		char(10),
		vl_row,
		vl_rid				integer,
		vl_area				like area.area_name

	initialize vr_comp.* to null
	initialize vr_customer.* to null

	if vg_action_type
	then
		select complaint_no
			into vr_comp.complaint_no
		from comp_01
			where pos = vl_row
	else
		select complaint_no
			into vr_comp.complaint_no
		from comp_02
			where pos = vl_row
	end if	

	if status != 0
	then
		return false
	end if

	select comp.*
		into vr_comp.*
	from comp
		where comp.complaint_no = vr_comp.complaint_no

	if status != 0
	then
		if vg_action_type
		then
			delete from comp_01 where pos = vl_row
		else
			delete from comp_02 where pos = vl_row
		end if
		return false
	end if

	select comp_destination.*
		into vr_comp_destination.*
	from comp_destination
		where comp_destination.complaint_no = vr_comp.complaint_no

	let m_curr_row = vr_comp.complaint_no

{
	let remarks_line = vr_comp.details_1 clipped, # " ",
						vr_comp.details_2 clipped, # " ",
						vr_comp.details_3 clipped
}                        
	let remarks_line = form_remarks(vr_comp.details_1, vr_comp.details_2, vr_comp.details_3) 

	select customer.*, comp_clink.*
		into vr_customer.*, vr_comp_clink.*
	from customer, comp_clink
		where customer.customer_no = comp_clink.customer_no
		and comp_clink.complaint_no = vr_comp.complaint_no
		and comp_clink.seq_no = 1

	if status != 0
	then
		let vr_customer.int_ext_flag = "I"
		let vr_comp_clink.cust_satisfaction = "N"
	end if
		
	if vm_current_page = "works_order_page"
	and vr_comp.action_flag != "W"
	then
		initialize vm_current_page to null
	end if
	if vm_current_page = "rectifications_page"
	and vr_comp.action_flag != "D"
	then
		initialize vm_current_page to null
	end if

	let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
	case
		when vr_comp.service_c = vg_weee_service
		and vg_weee_installation = "Y"
			if not m_weeeform_open
			then
				call weee_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "weee_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "weee_page"
			end if

		when vr_comp.service_c = vg_weee_sales_service
		and vg_sales_installation = "Y"
			if not m_weee_sales_form_open
			then
				if vg_weee_sales_entitlement = "Y"
				then
					call weee_sales_ent_qrycomp_of()
				else
					call weee_sales_qrycomp_of()
				end if
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "weee_sales_ent_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "weee_sales_ent_page"
			end if

		when vr_comp.service_c = vg_hway_service
		and vg_hway_installation = "Y"
			if not m_hwayform_open
			then
				call hway_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "hway_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "hway_page"
			end if

		when vg_ms_installation = "Y"
		and vg_ms_fault_codes matches vl_comp_code
		and length(vr_comp.comp_code)
			if not m_measurementform_open
			then
				call measurement_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "meas_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "meas_page"
			end if

		when vr_comp.service_c = vg_av_service
		and vg_av_installation = "Y"
			if not m_avform_open
			then
				call av_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "av_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "av_page"
			end if

		when vr_comp.service_c = vg_trade_service
		and vg_trade_installation = "Y"
			if not m_trform_open
			then
				call tr_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "trade_page"
                END IF 
			else
				{
				#ADJ GENERO
#				current window is iw_complain 
				}
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "trade_page"
			end if

		when vr_comp.service_c = vg_agreq_service
		and vg_agreq_installation = "Y"
			if not m_agreqform_open
			then
				call agreq_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "agreq_page"
                END IF 
			else
				{
				#ADJ GENERO
#				current window is iw_complain 
				}
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "agreq_page"
			end if

		when vr_comp.service_c = vg_nappy_service
		and vg_nappy_installation = "Y"
			if not m_npform_open
			then
				call np_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "generic_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "generic_page"
			end if

		when vr_comp.service_c = vg_clin_service
		and vg_clin_installation = "Y"
			if not m_clform_open
			then
				call cl_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "generic_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "generic_page"
			end if

		when vr_comp.service_c = vg_sl_service
		and vg_sl_installation = "Y"
			if not m_slform_open
			then
				call sl_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "sl_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
#			display "combo" to h
#			display "combo" to i
			if not length(vm_current_page)
			then
				let vm_current_page = "sl_page"
			end if

		when vr_comp.service_c = vg_gm_service
		and vg_gm_installation = "Y"
			if not m_gmform_open
			then
				call gm_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "gm_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "gm_page"
			end if

		when vr_comp.service_c = vg_enf_service
		and vg_enf_installation = "Y"

			if not m_enfform_open
			then
				call enf_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "enf_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "enf_page"
			end if

		when vr_comp.service_c = vg_enf_trade_service
		and vg_enf_trade_installation = "Y"

			if not m_enftrform_open
			then
				call enf_trade_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "enf_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "enf_page"
			end if

		when vr_comp.service_c = vg_sched_service
		and vg_sched_installation = "Y"
		and vg_weee_installation = "N"
		and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
			if not m_sched_form_open
			then
				call sched_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "sched_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "sched_page"
			end if

		when vr_comp.service_c = vg_sched_service
		and vg_sched_installation = "Y"
		and vg_weee_installation = "Y"
		and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
			if not m_weee_sched_form_open
			then
				call weee_sched_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "sched_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "sched_page"
			end if

		when vr_comp.service_c = vg_ert_service
		and vg_ert_installation = "Y"
		and skey_check("ERT_COMPLAINTS", "ALL") = "Y"

			if not m_ertform_open
			then
				call ert_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "ert_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "ert_page"
			end if

		when vr_comp.service_c = vg_trees_service
		and vg_trees_installation = "Y"
			if not m_treeform_open
			then
				call tree_qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "tree_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "tree_page"
			end if

		otherwise
			if not m_normalform_open
			then
				call qrycomp_of()
                # BJG 04/07/2012 - Workflow 3348 - Only change page if it was generic
                IF vm_current_page = "generic_page"
                OR vm_current_page = "av_page"
                OR vm_current_page = "gm_page"
                OR vm_current_page = "ert_page"
                OR vm_current_page = "hway_page"
                OR vm_current_page = "trade_page"
                OR vm_current_page = "agreq_page"
                OR vm_current_page = "enf_page"
                OR vm_current_page = "meas_page"
                OR vm_current_page = "sl_page"
                OR vm_current_page = "tree_page"
                OR vm_current_page = "weee_page"
                OR vm_current_page = "weee_sales_ent_page"
                OR vm_current_page = "sched_page"
                THEN 
                    let vm_current_page = "generic_page"
                END IF 
			else
				#ADJ GENERO
#				current window is iw_complain 
			end if
			if not length(vm_current_page)
			then
				let vm_current_page = "generic_page"
			end if
	end case

	select comp.*
		into vr_comp.*
	from comp
		where comp.complaint_no = vr_comp.complaint_no

	if status != 0
	then
		if vg_action_type
		then
			delete from comp_01 where pos = vl_row
		else
			delete from comp_02 where pos = vl_row
		end if
		return false
	else
		select comp_destination.*
			into vr_comp_destination.*
		from comp_destination
			where comp_destination.complaint_no = vr_comp.complaint_no

		let m_curr_row = vr_comp.complaint_no

{
		let remarks_line = vr_comp.details_1 clipped, # " ",
							vr_comp.details_2 clipped, # " ",
							vr_comp.details_3 CLIPPED
}                            
        let remarks_line = form_remarks(vr_comp.details_1, vr_comp.details_2, vr_comp.details_3) 

		display by name remarks_line
		display remarks_line to hway_remarks_line
		display remarks_line to enf_remarks_line
		display remarks_line to meas_remarks_line
		display remarks_line to weee_remarks_line
		display remarks_line to weee_sales_ent_remarks_line
		display remarks_line to comp.details_1

		select customer.*, comp_clink.*
			into vr_customer.*, vr_comp_clink.*
		from customer, comp_clink
			where customer.customer_no = comp_clink.customer_no
			and comp_clink.complaint_no = vr_comp.complaint_no
			and comp_clink.seq_no = 1

		if status != 0
		then
			let vr_customer.int_ext_flag = "I"
			let vr_comp_clink.cust_satisfaction = "N"
		end if
		
		let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to generic_dest_ref,
					generic_dest_suffix, 
					generic_date_closed,
					generic_time_closed_h,
					generic_time_closed_m

		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to av_dest_ref,
					av_dest_suffix, 
					av_date_closed,
					av_time_closed_h,
					av_time_closed_m

		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to gm_dest_ref,
					gm_dest_suffix, 
					gm_date_closed,
					gm_time_closed_h,
					gm_time_closed_m

		display	vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to hw_date_closed,
					hw_time_closed_h,
					hw_time_closed_m

		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to ert_dest_ref,
					ert_dest_suffix, 
					ert_date_closed,
					ert_time_closed_h,
					ert_time_closed_m

		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to trade_dest_ref,
					trade_dest_suffix, 
					trade_date_closed,
					trade_time_closed_h,
					trade_time_closed_m

		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to agreq_dest_ref,
					agreq_dest_suffix, 
					agreq_date_closed,
					agreq_time_closed_h,
					agreq_time_closed_m

		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to meas_dest_ref,
					meas_dest_suffix, 
					meas_date_closed,
					meas_time_closed_h,
					meas_time_closed_m

		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to tree_dest_ref,
					tree_dest_suffix, 
					tree_date_closed,
					tree_time_closed_h,
					tree_time_closed_m

		display	vr_comp.dest_ref, 
					vr_comp.dest_suffix, 
					vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to sched_dest_ref,
					sched_dest_suffix, 
					sched_date_closed,
					sched_time_closed_h,
					sched_time_closed_m

		display vr_comp.date_closed,
					vr_comp.time_closed_h,
					vr_comp.time_closed_m
				to sl_date_closed,
					sl_time_closed_h,
					sl_time_closed_m

		call display_comp_action_text()

		case 
			when vr_comp.service_c = vg_weee_service
					and vg_weee_installation = "Y"
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.text_flag,
								vr_comp.postcode,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								remarks_line,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

			when vr_comp.service_c = vg_weee_sales_service
					and vg_sales_installation = "Y"
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.text_flag,
								vr_comp.postcode,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								remarks_line,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

			when vr_comp.service_c = vg_hway_service
					and vg_hway_installation = "Y"
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.comp_code,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.text_flag,
								vr_comp.postcode,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								remarks_line,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

			when vg_ms_installation = "Y"
			and vg_ms_fault_codes matches vl_comp_code
			and length(vr_comp.comp_code)
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_comp.postcode,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.item_ref,
								vr_comp.comp_code,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.entered_by,
								vr_comp.text_flag,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								remarks_line,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to generic_dest_ref,
						generic_dest_suffix, 
						generic_date_closed,
						generic_time_closed_h,
						generic_time_closed_m

				call display_comp_action_text()
}
	
			when vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
	
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.text_flag,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.postcode,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to av_dest_ref,
						av_dest_suffix, 
						av_date_closed,
						av_time_closed_h,
						av_time_closed_m

				call display_comp_action_text()
}

			when vr_comp.service_c = vg_trade_service
					and vg_trade_installation = "Y"

				select * into vr_comp_trade.* from comp_trade
					where complaint_no = vr_comp.complaint_no

				display by name vr_comp.complaint_no,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp_trade.site_name,
								vr_comp_trade.agreement_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
#								vr_comp.details_1,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

#				select trade_site.addr_4 
#					into vl_area
#				from trade_site, agreement
#					where agreement.agreement_no = vr_comp_trade.agreement_no
#					and trade_site.site_no = agreement.site_ref

				display vr_comp.build_name,
						vr_comp.build_no,
						vr_comp.location_desc,
						vr_comp.location_name,
						vr_comp.postcode,
						vr_comp.townname,
						vr_comp.area_ward_desc
					to trade_build_name,
						trade_build_no,
						trade_location_desc,
						trade_location_name,
						trade_postcode,
						trade_townname,
						trade_area_ward_desc

#				display vl_area to trade_area_ward_desc

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to trade_posttown
				else
					display vr_comp.posttown to trade_posttown
				end if
{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to trade_dest_ref,
						trade_dest_suffix, 
						trade_date_closed,
						trade_time_closed_h,
						trade_time_closed_m

				call display_comp_action_text()
}

# #############################################
			when vr_comp.service_c = vg_agreq_service
					and vg_agreq_installation = "Y"

				select * into vr_comp_agreq.* from comp_agreq
					where complaint_no = vr_comp.complaint_no

				display by name vr_comp.complaint_no,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp_agreq.contract_stage,
								vr_comp_agreq.site_name,
								vr_comp_agreq.agreement_name,
#								vr_comp.build_name,
#								vr_comp.build_no,
#								vr_comp.location_desc,
#								vr_comp.location_name,
#								vr_comp.area_ward_desc,
#								vr_comp.postcode,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
#								vr_comp.details_1,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.text_flag,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				initialize g_agreement_h.* to null
				if vr_comp_agreq.agreement_no_h
				then
					select * into g_agreement_h.* from agreement_h
						where agreement_no = vr_comp_agreq.agreement_no_h
					if g_agreement_h.live_site_ref
					then
						select trade_site.addr_4 into vl_area
							from trade_site
							where site_no = g_agreement_h.live_site_ref
					else
						select trade_site_h.addr_4 into vl_area
							from trade_site_h
							where site_no = g_agreement_h.site_ref
					end if
				else
					if vr_comp_agreq.site_no
					then
						select trade_site.addr_4 into vl_area
							from trade_site
							where site_no = vr_comp_agreq.site_no
					end if
					if vr_comp_agreq.site_no_h
					then
						select trade_site_h.addr_4 into vl_area
							from trade_site_h
							where site_no = vr_comp_agreq.site_no_h
					end if
				end if

				display vr_comp.details_1 to agreq_details_1

				display vr_comp.build_name,
						vr_comp.build_no,
						vr_comp.location_desc,
						vr_comp.location_name,
						vr_comp.postcode,
						vr_comp.townname,
						vr_comp.area_ward_desc
					to trade_build_name,
						trade_build_no,
						trade_location_desc,
						trade_location_name,
						trade_postcode,
						trade_townname,
						trade_area_ward_desc
#				display vl_area to trade_area_ward_desc
				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to trade_posttown
				else
					display vr_comp.posttown to trade_posttown
				end if

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to agreq_dest_ref,
						agreq_dest_suffix, 
						agreq_date_closed,
						agreq_time_closed_h,
						agreq_time_closed_m

				call display_comp_action_text()
}

			when vr_comp.service_c = vg_nappy_service
					and vg_nappy_installation = "Y"

				select site_name_1, site_name_2
					into vr_site.site_name_1, vr_site.site_name_2
				from site
					where site_ref = vr_comp.site_ref

				display by name vr_comp.complaint_no,
								vr_comp.item_ref,
								vr_comp.comp_code,
								vr_comp.recvd_by,
#								vr_site.site_name_1,
#								vr_site.site_name_2,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.text_flag,
								remarks_line,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				display vr_site.site_name_1, vr_site.site_name_2
					to nappy_site_name_1, nappy_site_name_2
{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to generic_dest_ref,
						generic_dest_suffix, 
						generic_date_closed,
						generic_time_closed_h,
						generic_time_closed_m

				call display_comp_action_text()
}

			when vr_comp.service_c = vg_clin_service
				and vg_clin_installation = "Y"

				select site_name_1, site_name_2
					into vr_site.site_name_1, vr_site.site_name_2
				from site
					where site_ref = vr_comp.site_ref

				display by name vr_comp.complaint_no,
								vr_comp.item_ref,
								vr_comp.comp_code,
								vr_comp.recvd_by,
								vr_site.site_name_1,
								vr_site.site_name_2,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.text_flag,
								remarks_line,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to generic_dest_ref,
						generic_dest_suffix, 
						generic_date_closed,
						generic_time_closed_h,
						generic_time_closed_m

				call display_comp_action_text()
}

			when vr_comp.service_c = vg_sl_service
					and vg_sl_installation = "Y"
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.postcode,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.entered_by,
								vr_comp.text_flag,
#								vr_comp.date_closed,
#								vr_comp.time_closed_h,
#								vr_comp.time_closed_m,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

			when vr_comp.service_c = vg_gm_service
					and vg_gm_installation = "Y"

				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.postcode,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.entered_by,
								vr_comp.text_flag,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to sl_dest_ref,
						sl_dest_suffix, 
						sl_date_closed,
						sl_time_closed_h,
						sl_time_closed_m

				call display_comp_action_text()
}

			when vr_comp.service_c = vg_enf_service
				and vg_enf_installation = "Y"
	
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.postcode,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.text_flag,
								vr_comp.postcode,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				display remarks_line to enf_remarks_line 
				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

			when vr_comp.service_c = vg_enf_trade_service
				and vg_enf_trade_installation = "Y"
	
				display by name vr_comp.complaint_no,
#								vr_comp.location_name,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.postcode,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.entered_by,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.text_flag,
								vr_comp.postcode,
#								vr_comp.build_no,
#								vr_comp.build_name,
#								vr_comp.area_ward_desc,
								remarks_line,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				select comp_enf.* into vr_comp_enf.* from comp_enf
					where complaint_no = vr_comp.complaint_no

#				select trade_site.addr_4 into vl_area
#					from trade_site, agreement
#					where agreement.agreement_no = vr_comp_enf.agreement_no
#					and trade_site.site_no = agreement.site_ref

				display vr_comp.build_name,
						vr_comp.build_no,
						vr_comp.location_desc,
						vr_comp.location_name,
						vr_comp.postcode,
						vr_comp.townname,
						vr_comp.area_ward_desc
					to trade_build_name,
						trade_build_no,
						trade_location_desc,
						trade_location_name,
						trade_postcode,
						trade_townname,
						trade_area_ward_desc

#				display vl_area to trade_area_ward_desc

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to trade_posttown
				else
					display vr_comp.posttown to trade_posttown
				end if

			when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "N"
					and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"

				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_comp.postcode,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.entered_by,
								vr_comp.text_flag,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end IF

                CALL initialize_collection_items()

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to sched_dest_ref,
						sched_dest_suffix, 
						sched_date_closed,
						sched_time_closed_h,
						sched_time_closed_m

				call display_comp_action_text()
}

			when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "Y"
					and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"

				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_comp.postcode,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.entered_by,
								vr_comp.text_flag,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to sched_dest_ref,
						sched_dest_suffix, 
						sched_date_closed,
						sched_time_closed_h,
						sched_time_closed_m

				call display_comp_action_text()
}

			when vr_comp.service_c = vg_ert_service
					and vg_ert_installation = "Y"
					and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
	
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_comp.postcode,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.item_ref,
								vr_comp.comp_code,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.entered_by,
								vr_comp.text_flag,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to ert_dest_ref,
						ert_dest_suffix, 
						ert_date_closed,
						ert_time_closed_h,
						ert_time_closed_m

				call display_comp_action_text()
}

			when vr_comp.service_c = vg_trees_service
				and vg_trees_installation = "Y"

				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_comp.postcode,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.item_ref,
								vr_comp.comp_code,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.entered_by,
								vr_comp.text_flag,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to tree_dest_ref,
						tree_dest_suffix, 
						tree_date_closed,
						tree_time_closed_h,
						tree_time_closed_m

				call display_comp_action_text()
}

			otherwise
				display by name vr_comp.complaint_no,
								vr_comp.location_name,
								vr_comp.postcode,
								vr_customer.compl_init,
								vr_customer.compl_name,
								vr_customer.compl_surname,
								vr_customer.compl_phone,
								vr_comp_clink.cust_satisfaction,
								vr_customer.int_ext_flag,
								vr_comp.item_ref,
								vr_comp.comp_code,
								vr_comp.service_c,
								vr_comp.recvd_by,
								vr_comp.date_entered,
								vr_comp.ent_time_h,
								vr_comp.ent_time_m,
								vr_comp.entered_by,
								vr_comp.text_flag,
								#ADJ GENERO
								#vr_comp.action_flag,
								vr_comp.build_no,
								vr_comp.build_name,
								vr_comp.location_desc,
								vr_comp.townname,
								vr_comp.posttown,
								vr_comp.area_ward_desc,
								vr_comp.exact_location,
								remarks_line,
								vr_customer.compl_business,
								vr_customer.compl_postcode,
								vr_customer.compl_build_no,
								vr_customer.compl_build_name,
								vr_customer.compl_addr2,
								vr_customer.compl_addr3,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6,
								vr_customer.compl_fax,
								vr_customer.compl_email,
								vr_customer.compl_mobile 

				if vg_disp_county_or_postal = "Y"
				then
					display vr_comp.countyname to posttown
				else
					display by name vr_comp.posttown
				end if

{
				display	vr_comp.dest_ref, 
						vr_comp.dest_suffix, 
						vr_comp.date_closed,
						vr_comp.time_closed_h,
						vr_comp.time_closed_m
					to generic_dest_ref,
						generic_dest_suffix,
						generic_date_closed,
						generic_time_closed_h,
						generic_time_closed_m

				call display_comp_action_text()
}
	 
		end case
		call display_status_info_box()

	end if

	call load_vm_attach() # BJG - 09/04/2008
	call load_vm_comp_text() # BJG - 09/04/2008
	call load_comp_text_array(vr_comp.complaint_no)
	if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
	then
		call load_comp_det_text_array() 
	end if
	call load_debtor_trade_site_arrays() # BJG - 09/04/2008
	call load_enf_action_array()
	call load_enf_costs_array()
	call load_av_status_array()
	call load_suspect_array()
	call load_evidence_array()
	call load_action_text_array()

	let vg_map_easting = vr_comp.easting
	let vg_map_northing = vr_comp.northing

	call display_map_tab("500", 
						"135", 
						vg_zoom, 
						vg_map_easting, 
						vg_map_northing, 
						"reset")
		returning vg_zoom, vg_map_easting, vg_map_northing

	let vg_new_flycomp = false
	return true
end function	# select_complain


function set_comp_options()			# sets-up the options for this module
	options 
		input wrap,
		display attribute (normal),
		input attribute (normal)

	let int_flag = false
end function	# set_comp_options


function set_add_comp_options()			# sets-up the options for this module
	options 
		input wrap,
		display attribute (normal),
		input attribute (normal)

	let int_flag = false

	#ADJ GENERO
	#whenever error continue
	#current window is iw_fastcomp
	#whenever error stop


#	call fgl_keysetlabel("f7", "History")
#	call fgl_keysetlabel("f8", "Detail")
#	call fgl_keysetlabel("f11", "Duplicate")
end function	# set_add_comp_options


function set_query_comp_options()	# sets-up the options for this module
	options 
		input wrap,
		display attribute (normal),
		input attribute (normal)

	let int_flag = false
	if vg_weee_installation = "Y"
	then
--#		call fgl_keysetlabel("f8", "")
	else
--#		call fgl_keysetlabel("f8", "Import")
	end if
end function	# set_query_comp_options


function set_add_comp_ant_options()		# sets-up the options for this module
	options input wrap,
			display attribute (normal),
			input attribute (normal)

	let int_flag = false
#	current window is iw_comp_ant
--#	call fgl_keysetlabel("f10", "Clear Address")
end function	# set_add_comp_ant_options


function insert_comp_diry()
	initialize vr_diry.* to null

	let vr_diry.diry_ref = 0
	let vr_diry.source_flag = "C"
	let vr_diry.source_ref = vr_comp.complaint_no
	let vr_diry.source_date = vr_comp.date_entered
	let vr_diry.source_time_h = vr_comp.ent_time_h
	let vr_diry.source_time_m = vr_comp.ent_time_m
	let vr_diry.source_user = vr_comp.entered_by
	let vr_diry.site_ref = vr_comp.site_ref
	let vr_diry.item_ref = vr_comp.item_ref
	
	if not length(vr_si_i.item_ref)
		and not length(vr_si_i.contract_ref)
		and not length(vr_si_i.feature_ref)
	then
		select contract_ref, pa_area
			into vr_diry.contract_ref, vr_diry.pa_area 
		from si_i
			where site_ref = vr_comp.site_ref
			and item_ref = vr_comp.item_ref
		if length(vr_site.site_cat)
		then
			let vr_diry.pa_area = vr_site.site_cat
		else
			let vr_diry.pa_area = vr_si_i.pa_area
		end if
	else	
		if length(vr_site.site_cat)
		then
			let vr_diry.pa_area = vr_site.site_cat
		else
			let vr_diry.pa_area = vr_si_i.pa_area
		end if
		let vr_diry.feature_ref = vr_si_i.feature_ref
		let vr_diry.contract_ref = vr_si_i.contract_ref
	end if

	if vr_comp.action_flag = "N"
	then		# if N(o further action) let diry.action_flag = C(lear)
		let vr_diry.action_flag = "C"
	else
		let vr_diry.action_flag = vr_comp.action_flag
	end if

	call insert_diry()

	return vr_diry.diry_ref
end function	# insert_comp_diry


function prompt_for_scroll(vl_menu_flag, vl_type)
	define
		vl_ans			char(1),
		vl_build_flag	smallint,
		vl_menu_flag 	smallint,
		vl_type			char(1),
		vl_null			smallint

	let vl_null = null

	if vl_type = "A"
	then
		case
			when vr_comp.location_name is null 
				and vr_customer.compl_addr2 is null
				call valid_error("",
					"A location OR a description must be selected", "")
				return	

			when vr_comp.location_name is not null 
				and vr_customer.compl_addr2 is null
				or vr_comp.location_name = vr_customer.compl_addr2
				call disp_comp_sc(true, 
								false,
								true)

			when vr_comp.location_name is null 
				and vr_customer.compl_addr2 is not null
				call disp_comp_sc(false,
								false,
								true)
				let vg_action_type = true
				return

			otherwise	
				call disp_comp_sc(false,
								false,
								true)
				let vg_action_type = true
				return
		end case
	else
		if not length(vr_comp.build_no)
		and not length(vr_comp.build_name)
		then
			let vl_build_flag = false
		else
			let vl_build_flag = true
		end if

		case vl_type 
			when "L"
				call disp_comp_sc(true,
								true,
								vl_build_flag)
			when "R"
				call disp_comp_sc(false,
								false,
								vl_build_flag)
		end case	
	end if
	let vg_action_type = true
end function	# prompt_for_scroll


function drive_enter_action(vl_diry_ref)
	define
		vl_diry_ref			like diry.diry_ref,
		vl_action_flag		like diry.action_flag,
		vl_comp_code		char(10)

	# If its a monitor then go down a different route ...

	let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
	if
		vg_allow_monitor = "Y" and
		vg_monitor_fault matches vl_comp_code and
		vg_monitor_source != vr_comp.recvd_by
	then
		let vr_comp.action_flag = "I"
		if continue_yn
			("You have chosen a Monitor action, are you sure you wish to continue")
		then
			call process_action(vl_diry_ref)
				returning vl_action_flag
	
			call set_comp_options()
	
			if vl_action_flag is null
			then
				return vl_action_flag
			else
				call enter_destination("A")
					returning vr_comp_destination.*
			end if
		else
			let vl_action_flag = null
			return vl_action_flag
		end if
	else
		while true 
			# If its an adhoc sample then go down a different route ...

			if skey_check("ALLOW_ADHOC_SAMPLES", "ALL") = "Y"
			and vr_comp.comp_code = 
				skey_check("ADHOC_SAMPLE_FAULT", "ALL")
			and not vr_comp.complaint_no # BJG This is an adhoc sample generator
			then
				call process_action(vl_diry_ref)
					returning vl_action_flag
		
				call set_comp_options()
	
				if vl_action_flag is null
				then
					continue while
				else
					call enter_destination("A")
						returning vr_comp_destination.*
					exit while
				end if
			else
				if enter_action(vl_diry_ref)
				then
					call set_comp_options()
	
					call process_action(vl_diry_ref)
						returning vl_action_flag
	
					call set_comp_options()
	
					if vl_action_flag is null
					then
						continue while
					else
						call enter_destination("A")
							returning vr_comp_destination.*
						exit while
					end if
				else
					let vl_action_flag = null
					exit while 
				end if
			end if
		end while
	end if

	call set_comp_options()

	return vl_action_flag
end function	# drive_enter_action


function enter_action(vp_diry_ref)
	define
		vp_diry_ref			like diry.diry_ref,
		vl_dest_ref			like diry.dest_ref,
		vl_action_flag		like comp.action_flag,
		vl_comp_code		char(10)

	call open_action_window()

	let int_flag = false

    while true

		input by name vr_comp.action_flag without defaults
			on action Text
				call text_yes_no()

			on action cancel
				let vl_action_flag = null
				let vr_comp.action_flag = ""
				let int_flag = true
				exit input

			on action close
				let vl_action_flag = null
				let vr_comp.action_flag = ""
				let int_flag = true
				exit input

			before field action_flag
				display by name vr_comp.action_flag

			after field action_flag
				if not length(vr_comp.action_flag)
				then
					call valid_error("",
						"A valid next action must be entered","")
					next field action_flag
				else
					if vr_comp.action_flag = "E"
					then
						if vg_enf_installation = "N"
						or not quiet_allow("enf_add_upd")
						then
							call valid_error("",
								"Enforce is not a valid next action","")
							next field action_flag
						end if
					end if
					if vr_comp.action_flag = "E"
					and vg_enforce_added
					then
						call valid_error("", 
				"An enforcement has already been raised for this enquiry", 
							"")
						next field action_flag
					end if
					if vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
					and skey_check("AV WO USED", "ALL") = "Y"	# 24/9/3
#					and vr_comp.action_flag not matches "[HIPNWX]" 
					then
						if vg_enf_installation = "Y"
						then
							if vr_comp.action_flag not matches "[EHIPNWX]"
							then
								call valid_error("",
										"Please Enter E, H, I, P, N, W or X", "")
								next field action_flag
							end if
						else
							if vr_comp.action_flag not matches "[HIPNWX]"
							then
								call valid_error("", 
										"Please Enter  H, I, P, N, W or X", "")
								next field action_flag
							end if
						end if
					else
						if vr_comp.service_c = vg_av_service
						and vg_av_installation = "Y"
						and skey_check("AV WO USED", "ALL") = "N"
						and vr_comp.action_flag matches "[XW]"
						then
							call valid_error("",
"The ability to progress an abandoned vehicle to works order is disabled", 
								"")
							next field action_flag
						end if
					end if
					let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
					if
						vg_allow_monitor = "Y" and
						vg_monitor_fault matches vl_comp_code and
						vg_monitor_source = vr_comp.recvd_by
					then
						if vr_comp.action_flag not matches "[HPNWX]"
						then
							call valid_error("", 
									"Please Enter  H, P, N, W or X", "")
							next field action_flag
						end if
					end if
					if vg_ms_installation = "Y"
					and length(vr_comp_measurement.priority)
					and vr_comp.action_flag = "X"
					then
						let vr_comp.action_flag = "W"
					end if
					exit input
				end if
				{ ADJ251103 }
				if vr_comp.action_flag not matches "[ADHIPNWQ]"
				then
					call valid_error("", 
						"Please Enter A, I, P, W, N, D, Q or H", "")
					next field action_flag
				end if

		end input

		if int_flag
		then
			exit while
		end if

		exit while

	end while

	close window dm_actwin

	if int_flag
	then 	
		let int_flag = false
		return false
	else
		return true
	end if

end function	# enter_action


function drive_process_action(vl_diry_ref)
	define
		vl_diry_ref			like diry.diry_ref,
		vl_action_flag		like diry.action_flag,
		vl_comp_code		char(10)

	# If its a monitor then go down a different route ...

	let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
	if
		vg_allow_monitor = "Y" and
		vg_monitor_fault matches vl_comp_code and
		vg_monitor_source != vr_comp.recvd_by
	then
		let vr_comp.action_flag = "I"
		if continue_yn
			("You have chosen a Monitor action, are you sure you wish to continue")
		then
			call process_action(vl_diry_ref)
				returning vl_action_flag
	
			call set_comp_options()
	
			if vl_action_flag is null
			then
#				return vl_action_flag
				return false
			else
				call enter_destination("A")
					returning vr_comp_destination.*
			end if
		else
			let vl_action_flag = null
#			return vl_action_flag
			return false
		end if
	else
		call process_action(vl_diry_ref)
			returning vl_action_flag
	
		call set_comp_options()
	
		if length(vl_action_flag)
		then
			call enter_destination("A")
				returning vr_comp_destination.*
		end if
	end if

	call set_comp_options()

#	return vl_action_flag

	if length(vl_action_flag)
	then
		return true
	else
		return false
	end if
end function	# drive_process_action


function process_action(vp_diry_ref)
	define
		vlr_comp_save		record like comp.*,
		vlr_customer_save	record like customer.*,
		vlr_diry_save		record like diry.*,
		vlr_si_i_save		record like si_i.*,
		vl_site_ref			like site.site_ref,
		vp_diry_ref			like diry.diry_ref,
		vl_dest_ref			like diry.dest_ref,
		vl_action_flag		like comp.action_flag,
		new_comp_no			like comp.complaint_no,
		new_wo_key			like wo_h.wo_key,
		new_wo_ref			like wo_h.wo_ref,
		new_wo_suffix		like wo_h.wo_suffix,
		vl_count			integer,
		vl_comp_code		char(10)

	let vl_action_flag = vr_comp.action_flag

	let vr_diry_upd.dest_date = ""

	case 
		when vr_comp.action_flag matches "[HP]"
			initialize vr_comp.dest_ref,
							vr_comp.dest_suffix,
							vr_diry.dest_ref to null

		when vr_comp.action_flag matches "[AD]"
			if not length(vr_comp.site_ref)
			then
				call valid_error("","A valid site must be entered", "")
				let vr_comp.action_flag = null
				let vl_action_flag = null
				exit case
			end if
			if not length(vr_si_i.item_ref)
			then
				call valid_error("", 
					"This record has no item reference", "")
				let vr_comp.action_flag = null
				let vl_action_flag = null
				exit case
			end if
			if not def_comp(vp_diry_ref)
			then
				initialize vr_diry.dest_flag to null
			end if
			if vr_comp.action_flag is null
			then
				let vl_action_flag = vr_comp.action_flag
			else
				if vl_action_flag = "A"
				then
					let vl_action_flag = "D"
				end if
				let vr_comp.action_flag = vl_action_flag
				let vr_diry_upd.action_flag = vl_action_flag
			end if

		when vr_comp.action_flag matches "W"
			if skey_check("W/O ONLY MANAGER", vr_comp.service_c) = "Y"
			or (vr_comp.service_c = vg_av_service
				and vg_av_installation = "Y"
				and skey_check("AV WO USED", "ALL") = "Y"
				and not quiet_allow("av_wo_add_upd") )
			then
				call valid_error
					("","You do not have permission to add a works order","")
				let vr_comp.action_flag = null
				let vl_action_flag = null
			else
				call add_comp_wo_h(vp_diry_ref)
					returning new_wo_ref
				if new_wo_ref is null or new_wo_ref = 0
				then		# User not entered W/O check if save for another day
					let vr_comp.action_flag = null
					let vl_action_flag = null
				else 		# New W/O HAS been entered, remember the action flag
					let vr_diry_upd.action_flag = "W"
				end if
			end if

		when vr_comp.action_flag matches "X"
			if skey_check("W/O ONLY MANAGER", vr_comp.service_c) = "Y"
			or (vr_comp.service_c = vg_av_service
				and vg_av_installation = "Y"
				and skey_check("AV WO USED", "ALL") = "Y"
				and not quiet_allow("av_wo_add_upd") )
			then
				call valid_error
					("","You do not have permission to add a works order","")
				let vr_comp.action_flag = null
				let vl_action_flag = null
			else
				call auto_add_comp_wo_h(vp_diry_ref)
					returning new_wo_ref
				if new_wo_ref is null or new_wo_ref = 0
				then		# User not entered W/O check if save for another day
					let vr_comp.action_flag = null
					let vl_action_flag = null
				else 		# New W/O HAS been entered, remember the action flag
					let vr_comp.action_flag = "W"
					let vl_action_flag = "W"
					let vr_diry_upd.action_flag = "W"
				end if
			end if

		{ ADJ251103
		when vr_comp.action_flag = "M"
			if not continue_yn
				("Are you sure you want to select management decision")
			then
				let vr_comp.action_flag = null
				let vl_action_flag = null
			end if
		}

		when vr_comp.action_flag = "N"
			if not continue_yn
				("Are you sure you want to select no further action")
			then
				let vr_comp.action_flag = null
				let vl_action_flag      = null
			end if

		when vr_comp.action_flag = "E"
			#ADJ ENFTR is it a TRADE enforcement???
			if vg_enf_installation = "N"
				or not quiet_allow("enf_add_upd")
			then
				call valid_error("",
					"You do not have permission to add enforcements", "")
				let vr_comp.action_flag = null
				let vl_action_flag      = null
			else
				let new_comp_no = 0
				{ADJBJG
				if continue_yn
					("This cannot be interrupted. Are you sure you want continue")
				then
				}

				let vlr_comp_save.* = vr_comp.*
				let vlr_customer_save.* = vr_customer.*
				let vlr_diry_save.* = vr_diry.*
				let vlr_si_i_save.* = vr_si_i.*
				call history_save_text(true)	
				let vg_allow_text_clear = true
				call add_enf_complain(vp_diry_ref)
					returning vl_action_flag
				let vg_allow_text_clear = false
				let vr_comp.* = vlr_comp_save.*
				let vr_customer.* = vlr_customer_save.*
				let vr_diry.* = vlr_diry_save.*
				let vr_si_i.* = vlr_si_i_save.*
				call history_save_text(false)	
				if vl_action_flag = "I"
				then
					let vl_action_flag = null
					return vl_action_flag
				end if
				let vl_action_flag = "E"
				let vg_enforce_added = true

				{ADJBJG 
					call add_comp_enf(vp_diry_ref)
						returning new_comp_no
				end if

				if new_comp_no is null or new_comp_no = 0
				then		# User not entered ENF check if save for another day
					let vr_comp.action_flag = null
					let vl_action_flag = null
				else 		# New ENF HAS been entered, remember the action flag
					#ADJBJG let vr_diry_upd.action_flag = "E"
					#ADJBJG let vr_diry_upd.dest_flag = "C"
					#ADJBJG let vr_diry_upd.dest_ref = new_comp_no
					#ADJBJG let vr_comp.dest_ref = new_comp_no
					#ADJBJG let vr_comp.action_flag = "E"
					let vl_action_flag = "H"
				end if
				}

			end if

		#ADJ ADHOC SAMPLES
		when vr_comp.action_flag = "I"
			if skey_check("ALLOW_ADHOC_SAMPLES", "ALL") = "Y"
			and vr_comp.comp_code = skey_check("ADHOC_SAMPLE_FAULT", "ALL")
			then
				let vr_comp_adhoc_sample.start_date = today
				let vr_comp_adhoc_sample.duration_days = null
				let vr_comp_adhoc_sample.occur_days = "MTWTFSS"
				let vr_comp_adhoc_sample.next_date = null
				let vr_comp_adhoc_sample.end_date = null

				if not adhoc_sample_info()
				then
					let vr_comp.action_flag = null
					let vl_action_flag = null
					exit case
				end if
			end if

			let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"

			if
				vg_allow_monitor = "Y" and
				vg_monitor_fault matches vl_comp_code
			then
				let vr_comp_monitor.start_date = today
				let vr_comp_monitor.duration_days = null
				let vr_comp_monitor.occur_days = "MTWTFSS"
				let vr_comp_monitor.next_date = null
				let vr_comp_monitor.end_date = null

				call start_wait()

                CALL va_site_select.clear()
				{for vl_count = 1 to 1001
					initialize va_site_select[vl_count].* to null
				end for}

				let vl_count = 0

				declare c_mon_site cursor for
					select site_ref from site
					where location_c = vr_comp.location_c
				
				foreach c_mon_site into vl_site_ref
					if vl_site_ref = vr_comp.site_ref
					then
						continue foreach
					end if

					select count(*)
						into vl_count
					from si_i
						where si_i.site_ref = vl_site_ref
						and si_i.item_ref = vr_comp.item_ref
					if vl_count
					then
						exit foreach
					end if
				end foreach

				call end_wait()

				if vl_count
				then
					if continue_yn
			("Do you wish to select additional sites as part of this monitor")
					THEN
						if not postcode_select
							(vr_comp.site_ref, vr_comp.item_ref, true)
						then
#							call set_add_comp_options()
							call set_comp_options()
							let vr_comp.action_flag = null
							let vl_action_flag = null
							exit case
						end IF
                        
                        CALL va_site_select.appendElement()
						let va_site_select[va_site_select.getLength()].site_ref = vr_comp.site_ref
						let va_site_select[va_site_select.getLength()].select_yn = "Y"


#						call set_add_comp_options()
						call set_comp_options()
					end if
				end if

				if not monitor_info()
				then
					let vr_comp.action_flag = null
					let vl_action_flag = null
					exit case
				end if
			end if

		when vr_comp.action_flag = "R"
			if not continue_yn
				("Are you sure you want to create prospective agreement details")
			then
				let vr_comp.action_flag = null
				let vl_action_flag      = null
			else
				# insert into holding area and update comp_agreq
				call agreq_insert(vr_comp.complaint_no)
			end if

	end case

# update diry
	#ADJBJG if vl_action_flag matches "[ADEW]"
	if vl_action_flag matches "[ADW]"
	then
#test
		update diry
			set next_record = vr_diry_upd.next_record,
			action_flag = vr_diry_upd.action_flag,
			dest_flag = vr_diry_upd.dest_flag,
			dest_ref = vr_diry_upd.dest_ref,
			dest_date = vr_diry_upd.dest_date,
			dest_time_h = vr_diry_upd.dest_time_h,
			dest_time_m = vr_diry_upd.dest_time_m,
			dest_user = vr_diry_upd.dest_user
			where diry_ref = vp_diry_ref
{
			set (next_record, action_flag, dest_flag, dest_ref,
				dest_date, dest_time_h, dest_time_m, dest_user)
				end if
			= (vr_diry_upd.next_record, vr_diry_upd.action_flag,
				vr_diry_upd.dest_flag, vr_diry_upd.dest_ref,
				vr_diry_upd.dest_date, vr_diry_upd.dest_time_h,
				vr_diry_upd.dest_time_m, vr_diry_upd.dest_user)
}
	end if		
	return vl_action_flag

end function	# process_action


function delete_complain()

	define
		vl_ignore_flag,
		vl_boolean			smallint,
		vl_ans				char(1),
		vl_work_sched_hdr	record like work_sched_hdr.*,
		vl_work_schedule	record like work_schedule.*,
		vl_work_alg			record like work_alg.*,
		vl_quantity			like work_schedule.quantity,
		vl_wo_key			like wo_h.wo_key,
		vl_wo_type_f		like wo_h.wo_type_f

	if skey_check("ALLOW_COMP_DELETE","ALL") = "N"
	then
		return false
	end if

	if not get_passwd()
	then
		return false
	end if

	if vg_passwd = skey_check("COMPLAIN_PW", "ALL")
	then
		case
      		when (vr_comp.service_c = vg_enf_service
				and vg_enf_installation = "Y")
				or (vr_comp.service_c = vg_enf_trade_service
				and vg_enf_trade_installation = "Y")

				select count(*) into vl_boolean from enf_action
					where complaint_no = vr_comp.complaint_no
				if vl_boolean then
					call valid_error("",
								"Deletion not allowed as dependant Action","")
					return false
				end if
		end case

		open window iw_del_win at 11, 19 with 1 rows, 46 columns

		initialize vl_ans to null

		while vl_ans is null
			prompt " Please confirm this is to be deleted (Y/N):"
				for char vl_ans
				#ADJ GENERO
				{
				on key(f6)
					call join()
					call set_comp_options()
				}

				on action f2_lookup
					error " There is no lookup available for this entry"

			end prompt

		end while

		close window iw_del_win

		if vl_ans not matches "[Yy]"
		then
			return false
		end if

		call mstart_wait("Deleting, Please Wait ...")
		let vl_ignore_flag = true

		while true
			select comp.*, comp_destination.*
				into vr_comp.*, vr_comp_destination.*
				from comp, comp_destination
				where comp.complaint_no = vr_comp.complaint_no
				and comp_destination.complaint_no = comp.complaint_no

			if status = notfound
			then
				error "The selected record no longer exists."
				exit while
			else
				delete from comp_text
					where complaint_no = vr_comp.complaint_no

				delete from comp
					where complaint_no = vr_comp.complaint_no

				if sqlca.sqlcode < 0
				then			# rollback work
					if errtst()
					then		
						return false
					else
						continue while
					end if
				end if

				#ADJ GENERO
				#display "" at 23, 1
				call mess(" The selected record has been deleted")
				sleep 0.5
				exit while
			end if
		end while

		case
     		when (vr_comp.service_c = vg_enf_service
				and vg_enf_installation = "Y")
				or (vr_comp.service_c = vg_enf_trade_service
				and vg_enf_trade_installation = "Y")
				while true
					select comp_enf.* into g_comp_enf.* from comp_enf
						where complaint_no = vr_comp.complaint_no

					if status = notfound then
						error 
							"The selected enforcement record no longer exists."
						exit while
					else
						delete from comp_enf
						where complaint_no = vr_comp.complaint_no

						if sqlca.sqlcode < 0 then # rollback work
							if errtst() then 
								return false
							else
								continue while
							end if
						end if
						exit while
					end if
				end while

#			when vr_comp.service_c = skey_check("SCHED_SERVICE", "ALL")
#				and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
			when vr_comp.service_c = vg_sched_service
				and vg_sched_installation = "Y"
				# and vg_weee_installation = "Y" or "N"
				and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"

				select wo_key, wo_type_f into vl_wo_key, vl_wo_type_f from wo_h
					where wo_ref = vr_comp.dest_ref and
					wo_suffix = vr_comp.dest_suffix

				delete from wo_h where wo_key = vl_wo_key
				delete from wo_i where wo_ref = vl_wo_key
				select * into vl_work_alg.* from work_alg
					where wo_type_f = vl_wo_type_f
				select * into vl_work_schedule.* from work_schedule
					where wo_key = vl_wo_key
				select * into vl_work_sched_hdr.* from work_sched_hdr
					where schedule_ref = vl_work_schedule.schedule_ref
				if vl_work_alg.qty_flag = "Y" then
					let vl_quantity = vl_work_schedule.quantity
				else
					let vl_quantity = 1
				end if
				let vl_work_sched_hdr.record_count =
					vl_work_sched_hdr.record_count - vl_quantity
				update work_sched_hdr
					set record_count =
					vl_work_sched_hdr.record_count
					where schedule_ref =
					vl_work_sched_hdr.schedule_ref
				delete from work_schedule where wo_key = vl_wo_key
				call reorder_sched( vl_work_sched_hdr.schedule_ref )
				delete from diry where source_ref = vl_wo_key
					and source_flag = "W"
				delete from diry where source_ref = vr_comp.complaint_no
					and source_flag = "C"
		end case

		delete from comp_flycap where complaint_no = vr_comp.complaint_no
		delete from comp_flycap_addw where complaint_no = vr_comp.complaint_no

		call end_wait()

		clear form
		call complain_labels()
#		display "Reference" to reference_label
#		display "History" to history_title
		return true
	else
		call valid_error("","The entered password is incorrect","")
		return false
	end if

end function	# delete_complain


function add_comp_wo_h(vp_diry_ref)
	define
		vp_diry_ref			like diry.diry_ref,
		new_wo_key			like wo_h.wo_key,
		new_wo_ref			like wo_h.wo_ref,
		new_wo_suffix		like wo_h.wo_suffix,
		vl_user				char(8),
		vl_done_time_h,
		vl_done_time_m		char(2)

	call get_time()
		returning vl_done_time_h, vl_done_time_m

	let vl_user = get_user()
	let vl_user = upshift(vl_user)

	if check_copy_comp_text_to_wo_key(vr_comp.service_c)
	then
		call copy_comp_text_to_wo()
	end IF

    SELECT * INTO vr_si_i.* FROM si_i
        WHERE site_ref=vr_comp.site_ref
        AND item_ref=vr_comp.item_ref
        AND feature_ref=vr_comp.feature_ref

	call wo_h_of()
	call wo_h_add(vp_diry_ref, vr_comp.service_c)
		returning new_wo_ref
	call wo_h_cf()

	return new_wo_ref
end function	# add_comp_wo_h


function auto_add_comp_wo_h(vp_diry_ref)
	define
		vp_diry_ref			like diry.diry_ref,
		new_wo_key			like wo_h.wo_key,
		new_wo_ref			like wo_h.wo_ref,
		new_wo_suffix		like wo_h.wo_suffix,
		vl_user				char(8),
		vl_done_time_h,
		vl_done_time_m		char(2)

	call get_time()
		returning vl_done_time_h, vl_done_time_m

	let vl_user = get_user()
	let vl_user = upshift(vl_user)

	if check_copy_comp_text_to_wo_key(vr_comp.service_c)
	then
		call copy_comp_text_to_wo()
	end if

	call auto_wo_h_add(vp_diry_ref, vr_comp.service_c)
		returning new_wo_ref

	return new_wo_ref
end function	# auto_add_comp_wo_h


function find_fault_num()
	define
		vl_fault_num		like allk.lookup_num

	let vl_fault_num = null

	select lookup_num
		into vl_fault_num
	from allk
		where lookup_code = vr_comp.comp_code
		and lookup_func = "DEFRN"

	return vl_fault_num
end function	# find_fault_num


function comp_check_site(vl_site_ref,
						vl_postcode,
						vl_build_no,
						vl_build_name,
						vl_location_name,
						vl_location_desc)
	define
		vl_site_ref			like site.site_ref,
		vl_postcode			like site.postcode,	
		vl_build_no			like site.build_no,
		vl_site_build_name,
		vl_build_name		like site.build_name,
		vl_location_name	like locn.location_name,
		vl_location_desc	like comp.location_desc,
		vl_site				record like site.*,
		vl_location_primary like locn.location_c,
		vl_compare1			char(200),
		vl_compare2			char(200),
		vl_rec_count		integer,
		vl_build_sub_no	like comp.build_sub_no

	if length(vl_build_name)
	then
		let vl_compare1 = "comp:",
						vl_build_name clipped,
						"*",
						vl_build_no clipped, 
						vl_postcode clipped
	else
		let vl_compare1 = "comp:",
						vl_build_no clipped, 
						vl_postcode clipped
	end if

	select site.* 
		into vl_site.* 
	from site
		where site_ref = vl_site_ref

	if not length(vl_site.site_ref)
	then
		return false
	end if

	if skey_check("COMP_BUILD_NO_DISP", "ALL") = "Y" 
	then
		let vl_site.build_sub_no = vl_site.build_sub_no_disp
	end if

	if length(vl_site.build_sub_no)
	then
		let vl_site_build_name = vl_site.build_sub_no clipped
		if length(vl_site.build_sub_name)
		then
			let vl_site_build_name = vl_site_build_name clipped, ", ",
												vl_site.build_sub_name clipped
			if length(vl_site.build_name)
			then
				let vl_site_build_name = vl_site_build_name clipped, ", ",
					vl_site.build_name
			end if
		else
			let vl_site_build_name = vl_site_build_name clipped, ", ",
												vl_site.build_name clipped
		end if
	else
		if length(vl_site.build_sub_name)
		then
			let vl_site_build_name = vl_site.build_sub_name clipped

			if length(vl_site.build_name)
			then
				let vl_site_build_name = vl_site_build_name clipped, ", ",
					vl_site.build_name
			end if
		else
			let vl_site_build_name = vl_site.build_name
		end if
	end if

{ This should now be taken care of when building vl_site_build_name #######
	if length(vl_site.build_sub_name)
	then
		let vl_compare2 = "comp:",
						vl_site.build_sub_name clipped

		if length(vl_site_build_name)
		then
			if skey_check("COMP_BUILD_NO_DISP", "ALL") = "Y" 
			then
				let vl_compare2 = vl_compare2 clipped, ", ",
							vl_site_build_name clipped,
							vl_site.build_no_disp clipped, 
							vl_site.postcode clipped
			else
				let vl_compare2 = vl_compare2 clipped, ", ",
							vl_site_build_name clipped,
							vl_site.build_no clipped, 
							vl_site.postcode clipped
			end if
		else
			if skey_check("COMP_BUILD_NO_DISP", "ALL") = "Y" 
			then
				let vl_compare2 = vl_compare2 clipped,
							vl_site.build_no_disp clipped, 
							vl_site.postcode clipped
			else
				let vl_compare2 = vl_compare2 clipped,
							vl_site.build_no clipped, 
							vl_site.postcode clipped
			end if
		end if
	else
}
		if skey_check("COMP_BUILD_NO_DISP", "ALL") = "Y" 
		then
			let vl_compare2 = "comp:",
						vl_site_build_name clipped,
						vl_site.build_no_disp clipped, 
						vl_site.postcode clipped
		else
			let vl_compare2 = "comp:",
						vl_site_build_name clipped,
						vl_site.build_no clipped, 
						vl_site.postcode clipped
		end if
#	end if
#  Debug code - uncomment to check comparison errors if required - BJG #####
{
display vl_compare1
display vl_compare2
call fgl_winmessage("Compare 1", vl_compare1, "info")
call fgl_winmessage("Compare 2", vl_compare2, "info")
}

	if vl_compare2 clipped not matches vl_compare1 clipped
	then
		return false
	end if
	if length(vl_location_desc)
	then
#		if length(vl_site.site_section) and vl_site.site_ref matches "*[SG]"
		if length(vl_site.site_section) and vl_site.site_c matches "[SG]"
		then
			if vl_location_desc != vl_site.site_section
			then
				return false
			else
				return true
			end if
		else
			# What about the town

			if vg_comp_loc_desc_town = "Y" # ADJ 25/04/2007
			then
				if vr_comp.location_desc != vl_site.townname 
				then
					return false
				end if
				
				select count(*) 
					into vl_rec_count
				from locn
					where location_c = vl_site.location_c
					and location_name = vl_location_name
			else
				select count(*)
					into vl_rec_count
				from locn
					where location_c = vl_site.location_c
					and location_name = vl_location_desc
			end if	
		end if
	else
		select count(*) 
			into vl_rec_count
		from locn
			where location_c = vl_site.location_c
			and location_name = vl_location_name
	end if
	if vl_rec_count > 0
	then
		if length(vl_location_desc)
		then
			{ ADJ TODO
			select count(*)
				into vl_rec_count
			from locn
				where location_c = vl_site.location_primary
				and location_name = vl_location_name
			}

			if vl_rec_count > 0
			then
				return true
			else
				return false
			end if
		else
			call end_wait()
			return true
		end if
	else
		call end_wait()
		return false
	end if
end function	# comp_check_site


function comp_check_sites_items(si_i_rec_defined, vl_comp_date, vl_f2)
	define
		vl_comp_date        DATE,
		vl_rec_count		integer,
		vl_si_i_count,	
		vl_f2,
		si_i_rec_defined	smallint,
		vl_service_c		like item.service_c,
		vl_task_ref			like task.task_ref,
		vl_agreement_no	like agree_task.agreement_no

	# If the system key for auto insertion of single site item is set...
	# Just retrieve the site item into the add_comp screen with no lookup

	initialize vl_service_c to null
	initialize vl_task_ref to null
	initialize vl_agreement_no to null

	if skey_check("AUTO_SINGLE_SI_I", "ALL") = "Y" and not vl_f2
	then
		let	vl_si_i_count = 0

		select count(*) 
			into vl_si_i_count
		from si_i, item
			where site_ref = vr_comp.site_ref
			and   item.service_c = vr_comp.service_c
			and   item.item_ref = si_i.item_ref
			and   item.contract_ref = si_i.contract_ref

		if not vl_si_i_count
		then
			let si_i_rec_defined = false
#			return si_i_rec_defined
			return si_i_rec_defined, vl_service_c, vl_task_ref, vl_agreement_no
		else
			if vl_si_i_count = 1 
			then
				select si_i.* into vr_si_i.*
					from si_i, item
				where site_ref = vr_comp.site_ref
					and   item.service_c = vr_comp.service_c
					and   item.item_ref = si_i.item_ref
					and   item.contract_ref = si_i.contract_ref

				let si_i_rec_defined = true
#				return si_i_rec_defined
				return si_i_rec_defined, vl_service_c, vl_task_ref, vl_agreement_no
			end if	
		end if
	end if

	if skey_check("OCCUR_DAY_WARNING","ALL") = "Y"
	then 
		call si_i_look_chk(vr_comp.site_ref,
						   vr_comp.service_c, 
						   vl_comp_date) 
			returning vr_si_i.item_ref, vr_si_i.feature_ref,
						vr_si_i.contract_ref
	else
		call si_i_look(vr_comp.site_ref, vr_comp.service_c, vl_f2) 
			returning
						vr_si_i.site_ref,
						vr_si_i.item_ref, vr_si_i.feature_ref,
						vr_si_i.contract_ref,
						vl_service_c, vl_task_ref, vl_agreement_no
	end if				

	if length(vl_service_c)
	and vl_service_c != vr_comp.service_c
	then
		# Service code change
		let si_i_rec_defined = 2

{ BJG 02/07/2009 - This code causes change to TRADE to fail as si_i will
                   never exist but we need to return si_i_rec_defined=2.

		select si_i.*
			into vr_si_i.*
		from si_i
			where site_ref = vr_si_i.site_ref
			and item_ref = vr_si_i.item_ref
			and contract_ref = vr_si_i.contract_ref
			and feature_ref = vr_si_i.feature_ref

		if status = notfound
		then
			let si_i_rec_defined = false
		end if

# BJG 02/07/2009 - Use the following code instead.....
}
		if not (vl_service_c = vg_trade_service
		and vg_trade_installation = "Y")
		then
			select si_i.*
				into vr_si_i.*
			from si_i
				where site_ref = vr_si_i.site_ref
				and item_ref = vr_si_i.item_ref
				and contract_ref = vr_si_i.contract_ref
				and feature_ref = vr_si_i.feature_ref

			if status = notfound
			then
				let si_i_rec_defined = false
			end if
		end if

	else
		select si_i.*
			into vr_si_i.*
		from si_i
#			where site_ref = vr_comp.site_ref
			where site_ref = vr_si_i.site_ref
			and item_ref = vr_si_i.item_ref
			and contract_ref = vr_si_i.contract_ref
			and feature_ref = vr_si_i.feature_ref

		if status = notfound
		then
			let si_i_rec_defined = false
		else
			let si_i_rec_defined = true
		end if
	end if

#	return si_i_rec_defined
	return si_i_rec_defined, vl_service_c, vl_task_ref, vl_agreement_no

end function	# comp_check_sites_items


function draw_down_area_c(locn_rec_defined, vl_location_c)

	define
		vl_location_c		like locn.location_c,
		vl_area_c			like locn.area_c,
		locn_rec_defined	smallint

	if skey_check("DRAW DOWN AREA_C", vr_comp.service_c) = "Y"
	and vl_location_c is not null
	then
		select area_c
			into vl_area_c
			from locn
			where locn.location_c = vl_location_c

		select *
			into vr_area.*
			from area
			where area.area_c = vl_area_c

		return vr_area.area_name
	else
		return ""
	end if

end function	# draw_down_area_c


function comp_check_locn(locn_rec_defined,
						site_rec_defined,
						vl_location_name,
						from_location_name)
# check the location name entered in the complaint add screen called from
# add_comp after field location_name
	define
		vl_location_name	like comp.location_name,
		vl_rec_count		integer,
		locn_rec_defined,
		site_rec_defined,
		from_location_name,
		vl_rec_count2,
		locn_length			smallint,
		temp_desc			char(20)

	select count(*)
		into vl_rec_count
		from locn
		where location_name = vl_location_name

	case

		when vl_rec_count < 1
			call valid_error("Warning",
				"That location name has not been defined yet", "I")
			let locn_rec_defined = false

		when vl_rec_count > 1
--#			if not fgl_fglgui()
--#			then
				error " There is more than one location by that name ..."
--#			end if

# call pop-up window with RESTRICTED list i.e ALL records from locn with the
# location name matching the one typed in by user

			if from_location_name
			then
				call clocn_look(vl_location_name, vr_comp.service_c)
					returning vl_location_name,
							vr_comp.location_c,
							vr_comp.site_ref,
							vr_comp.location_desc,
							temp_desc

				if vl_location_name is null
					or vl_location_name = ""
				then
					let vl_rec_count = 0
					let locn_rec_defined = false
				else
					let locn_rec_defined = true

# Must be updated as can have duplicates!
					select *
						into vr_locn.*
						from locn
						where location_c = vr_comp.location_c

					select *
						into vr_site.*
						from site
						where site_ref = vr_comp.site_ref

					let site_rec_defined = true
				end if
			else
				call clocn_look(vl_location_name, vr_comp.service_c)
					returning vl_location_name,
							vr_comp.location_c,
							temp_desc,
							temp_desc,
							temp_desc

				if vl_location_name is null
					or vl_location_name = ""
				then
					let vl_rec_count = 0
					let locn_rec_defined = false
				else
					let locn_rec_defined = true

# Must be updated as can have duplicates!
					select *
						into vr_locn.*
						from locn
						where location_c = vr_comp.location_c
				end if
			end if

		when vl_rec_count = 1
			let locn_rec_defined = true

			select *
				into vr_locn.*
				from locn
				where location_name = vl_location_name

			let site_rec_defined = false

	end case	

	if from_location_name and locn_rec_defined 
	then

		let vr_comp.location_c = vr_locn.location_c
		let locn_rec_defined = true

		if site_rec_defined = false
		then
# check for many sites related to the location

			select count(*)
				into vl_rec_count2
				from site
				where site.location_c = vr_comp.location_c

			case 
				when vl_rec_count2 > 1		# many sites have been found

--#					if not fgl_fglgui()
--#					then
						error " More than one site for location ", 
							vr_comp.location_name clipped
--#					end if

					call clocn_look(vr_comp.location_name, vr_comp.service_c)
						returning vr_comp.location_name,
								vr_comp.location_c,
								vr_comp.site_ref,
								vr_comp.location_desc,
								temp_desc

					if vl_location_name is null
							or vl_location_name = ""
					then
						let vl_rec_count = 0
						let locn_rec_defined = false
						let site_rec_defined = false
					else
						select *
							into vr_site.*
							from site
							where site_ref = vr_comp.site_ref

						let site_rec_defined = true
						let locn_rec_defined = true
					end if

				when vl_rec_count2 = 0 
					error "DATA ERROR"
					let locn_rec_defined = false
					let site_rec_defined = false

				when vl_rec_count2 = 1
					select *
						into vr_site.*
						from site
						where location_c = vr_comp.location_c
					let site_rec_defined = true

			end case
		end if

		if site_rec_defined
		then
			let vr_comp.site_ref = vr_site.site_ref
			let vr_comp.location_c = vr_site.location_c
			let vr_comp.location_desc = vr_site.site_name_1
			let temp_desc = vr_site.site_name_2
		end if		

	end if

#	call set_add_comp_options()
	return locn_rec_defined, site_rec_defined, vl_location_name, vl_rec_count

end function	# comp_check_locn


function def_comp(vp_diry_ref)
	define
		vl_act_flag			like diry.action_flag,
		vp_diry_ref			like diry.diry_ref,
		vl_comp_no			like comp.complaint_no,
		newdef_no			like diry.source_ref,
		vl_fault_num		like allk.lookup_num,
		vl_notice_type		like allk.lookup_num,
		vl_comp_code		like comp.comp_code,
		vl_upd_flag			integer,
		vl_tmp_char			char(80),
		vl_user,
		vl_done_time_h,
		vl_done_time_m		char(2)

	let vr_diry.diry_ref = vp_diry_ref
	call get_time()
		returning vl_done_time_h, vl_done_time_m

	let vl_user = get_user()
	let vl_user = upshift(vl_user)

	let vr_diry.dest_flag = "D"			# Next action is DEFAULT ...
	let g_comp_def_text = false

	if check_copy_comp_text_to_def_key(vr_comp.service_c)
	then
		if copy_comp_text_to_defs()
		then
			let g_comp_def_text = true
		end if
	end if

	if vr_comp.action_flag = "A"
	then
		let vl_notice_type = find_fault_num()

		if vl_notice_type is null
		then
			let vr_comp.action_flag = "D"
		end if
	end if

#ADJ TODO
{
	if chk_volume(vr_comp.site_ref,
				vr_comp.item_ref,
				vr_si_i.contract_ref,
				vr_si_i.feature_ref)
	then
		call valid_error("",
			"The whole volume for this site item has been defaulted", "")
		let vr_comp.action_flag = null
		return false
	end if	
}
	# If we have a Trade Complaint then make sure we have a complaint code

	if vr_comp.service_c = vg_trade_service
		and vg_trade_installation = "Y"
	then
		declare c_comp_tr_x scroll cursor for
			select comp_code from comp_tr
				where complaint_no = vr_comp.complaint_no
				and comp_code is not null
				and comp_code != " "
		open c_comp_tr_x
		fetch first c_comp_tr_x into vl_comp_code
		close c_comp_tr_x
		free c_comp_tr_x
		if length(vl_comp_code)
		then
			let vr_comp.comp_code = vl_comp_code
		end if
	end if

	# We need to check that a default reason exists for this complaint code
	# if linked
	if skey_check("COMP CODE>DEFRN LINK", "ALL")
	then
		if not check_def_alg_and_reason(vr_comp.comp_code, 
										vr_comp.item_ref,
										vr_si_i.feature_ref,
										vr_si_i.contract_ref)
		then
			let vr_comp.action_flag = ""
			return false
		end if
	end if

	if vr_comp.action_flag = "D"
	then
		call add_default("",
						"C",
						vp_diry_ref,
						today,
						vl_done_time_h,
						vl_done_time_m,
						vr_comp.site_ref,
						vr_si_i.contract_ref,
						vr_comp.item_ref,
						vr_si_i.feature_ref,
						vr_comp.comp_code,
						false)
			returning vl_upd_flag
	else
		let vr_comp.action_flag = "D"					
		call add_default("",
						"C",
						vp_diry_ref,
						today,
						vl_done_time_h,
						vl_done_time_m,
						vr_comp.site_ref,
						vr_si_i.contract_ref,
						vr_comp.item_ref,
						vr_si_i.feature_ref,
						vr_comp.comp_code,
						true)
			returning vl_upd_flag
	end if

	call set_comp_options()

	if int_flag or not vl_upd_flag
	then			
		let vr_comp.action_flag = null
		let int_flag = false
		return false
	end if

	if not vg_print_def_rep
	then			# the existing default has not been amended ...
		let vr_comp.action_flag = null
		return false
	end if

	if vr_diry.diry_ref = vp_diry_ref
	then			
		let vr_diry.diry_ref = null
	end if

	call start_wait()
	update diry
		set next_record = vr_diry_upd.next_record,
			action_flag = vr_comp.action_flag,
			dest_flag = vr_diry.dest_flag,
			dest_date = vr_diry.source_date,
			dest_ref = newdef_no,
			dest_time_h = vr_diry.source_time_h,
			dest_time_m = vr_diry.source_time_m,
			dest_user = vr_diry.source_user
		where diry_ref = vp_diry_ref
	call end_wait()

	if status != 0
	then
		call valid_error("",
"The diary table could not be updated. Please contact the system administrator",
			"")
		return false
	end if

	return true
end function	# def_comp


function upd_clear_comp(vp_comp_no)
	define
		vp_comp_no			like comp.complaint_no,
		vl_next_rec			like diry.next_record,
		vl_act				char(30),
		vl_ans				char(1)

# Find the associated diry record ...
	select *
		into vr_diry.*
	from diry
		where source_flag = "C"
		and source_ref = vp_comp_no

# Store the next link in the diry table
	let vl_next_rec = vr_diry.next_record

# Find the last record in the diry link
	while vl_next_rec is not null
		select *
			into vr_diry.*
		from diry
			where diry_ref = vl_next_rec

		let vl_next_rec = vr_diry.next_record
	end while

	case vr_diry.action_flag
		when "M"
			let vl_act = "Managers' Decision"

		when "W"
			error "This record is awaiting a work order"
			sleep 0.5
			return false

		when "I"
			if vr_diry.inspect_ref is null
			then
				error "This record is awaiting an inspection"
				sleep 0.5
				return false
			else
				let vl_act = "Inspection"
			end if

		otherwise
			error "Next action is ", vr_diry.action_flag, " not cleared"
			sleep 0.5
			return false
	end case

	while true
		prompt "The next action for this record is ", vl_act clipped,
			", O.K to Clear ?" for char vl_ans

		let vl_ans = upshift(vl_ans)

		if vl_ans = "N"
		then
			return false
		else
			if vl_ans != "Y"
			then
				error " Please reply Y(es) or N(o)"
				sleep 0.5
			else
				call clear_next_act(vr_diry.diry_ref, vr_diry.action_flag)
				exit while
			end if
		end if
	end while

	return true

end function	# upd_clear_comp


function clear_next_act(vp_diry_ref, vp_action_flag)
	define
		vp_diry_ref				like diry.diry_ref,
		vp_action_flag			like diry.action_flag,
		vl_user					like diry.dest_user,
		vl_time_h,
		vl_time_m				char(2)

	call get_time()
		returning vl_time_h, vl_time_m

	call get_user()
		returning vl_user

	let vl_user = upshift(vl_user)

	case vp_action_flag
		when "M"
			call mess(" Clearing the managers action ...")
			update diry
				set dest_flag = "C",
					dest_time_h = vl_time_h,
					dest_time_m = vl_time_m,
					dest_user = vl_user,
					dest_date = today
				where diry_ref = vp_diry_ref

		when "I"
			call mess(" Clearing the inspection ...")
			update diry
				set dest_flag = "C",
					dest_time_h = vl_time_h,
					dest_time_m = vl_time_m,
					dest_user = vl_user,
					dest_date = today
				where diry_ref = vp_diry_ref

		otherwise
			error " No more"
			sleep 0.5
	end case

end function	# clear_next_act


function init_comp_values()
	define
		vl_service_c		like comp.service_c,
		vl_time_h,
		vl_time_m			char(2)

	let vl_service_c = vr_comp.service_c

	if vg_comp_init_variables
	then
		initialize vr_comp.* to null
		call reset_text()
	end if

	call get_time()
		returning vl_time_h, vl_time_m

	let vr_comp.ent_time_h = vl_time_h
	let vr_comp.ent_time_m = vl_time_m

	let vr_comp.date_entered = today
#	initialize vr_comp.complaint_no to null # BJG - This value is used by sched.
	initialize vr_comp.action_flag to null
	initialize vr_comp.dest_ref to null
	initialize vr_comp.dest_suffix to null
	initialize vr_comp.date_closed to null
	initialize vr_comp.time_closed_h to null
	initialize vr_comp.time_closed_m to null
	if vg_dart_installation = "Y"
	then
		call init_dart_values()
	end if
	if vg_ert_installation = "Y"
	and vg_ert_detailed_info = "Y"
	then
		call init_ert_values()
	end if
	if vg_sw_installation = "Y"
	then
		call init_sw_values()
	end if

    initialize vlr_comp_flycap.* to NULL
	if vg_comp_init_variables
	then
		if vg_add_multi_complaints = "Y"
		then
			let vg_comp_init_variables = false
		end if
		let remarks_line = null

		initialize vr_si_i.* to null
		initialize vg_null to null
		if not vg_customer_retain
		then
	#		Only clear customer details if retain flag is false
			initialize vr_customer.* to null
			initialize vr_comp_clink.* to NULL
			let vr_customer.int_ext_flag = skey_check("INT_EXT_FLAG", "ALL")
			if vr_customer.int_ext_flag not matches "[IE]"
			then
				let vr_customer.int_ext_flag = "E"
			end if
			let vr_comp_clink.cust_satisfaction = vg_cs_flag
		end if
		initialize vr_comp_destination.* to NULL

		call get_user()
			returning vr_comp.entered_by

		let vr_comp.entered_by = upshift(vr_comp.entered_by)

		whenever error continue
		select lookup_code
			into vr_comp.recvd_by
		from allk
			where lookup_func = "CTSRC"
			and lookup_num = 1

		if status < 0
		then
			error " More than one default Source is set"
			let vr_comp.recvd_by = null
		end if
		whenever error stop

		if length(vl_service_c)
		then
			let vr_comp.service_c = vl_service_c
		else
	#		let vr_comp.service_c = skey_check("DEFAULT SERVICE", "ALL")
			let vr_comp.service_c = vg_default_service
		end if

		let vr_comp.action_flag = "H"
		let vr_comp.notice_type = "N"
		let vr_comp.text_flag = "N"
		let vr_comp.item_ref = null
		let vr_comp.comp_code = null
{ These always need to be initialized - BJG ......
		if vg_dart_installation = "Y"
		then
			call init_dart_values()
		end if
		if vg_ert_installation = "Y"
		and vg_ert_detailed_info = "Y"
		then
			call init_ert_values()
		end if
}
	end if
end function	# init_comp_values


{
function add_comp_of()
	define 
		vl_item_desc	char(80)

#	ADJ GENERO
#	current window is iw_complain

	call set_add_comp_options()

	open form if_fastcomp from "add_comp"
	display form if_fastcomp

	#ADJ GENERO
	let vl_item_desc = upshift(vg_compln_title) clipped, " INFORMATION"
	if downshift(vg_position_title) != "position"
	then
		display vg_position_title at 13, 2
	end if
	call centre(14, 2, vl_item_desc)
	let vl_item_desc = "ITEM/", upshift(vg_fault_title) clipped
	call centre(16, 2, vl_item_desc)
	display vg_fault_title clipped at 18, 2

	if vg_disp_ward_or_area = "N"
	then
		display "Ward" at 12, 2
	end if

--#	call fgl_keysetlabel("f3", vg_compln_title)
--#	call fgl_keysetlabel("f7","History")

end function	# add_comp_of
}


function drive_destination_display()
	define
		vl_act_flag_save	like comp.action_flag,
		vl_enforcement_ref	like comp_enf.source_ref,
		v_action_flag		like diry.action_flag,
		v_dest_ref			like diry.dest_ref,
		v_dest_flag			like diry.dest_flag,
		v_diry_ref			like diry.diry_ref,
		v_next_record		like diry.next_record,
		v_inspect_ref		like diry.inspect_ref,
		v_source_ref		like diry.source_ref,
		v_po_code			like diry.po_code,		# Added by Andy Jones
		v_date_done			like diry.date_done,    # Inspections - 14-07-97
		v_po_name			like patr.po_name,      # .....
		vl_comp_code		char(10),
		vl_s_menu_desc		char(80),
		vl_e_menu_desc		char(80),
		vl_runstr			char(80),
		vl_dest_flag		char(1),
		vl_po_desc			char(40),
		vl_count				integer

	let vl_enforcement_ref = 0
	if vg_enf_installation = "Y"
	or vg_enf_trade_installation = "Y"
	then
		# Find out if the complaint has a related enforcement
{		# BJG 12/08/2008 - modified to use new comp_enf_link table
		select complaint_no
			into vl_enforcement_ref
		from comp_enf
			where source_ref = vr_comp.complaint_no
}
		if (vr_comp.service_c = vg_enf_service
		and vg_enf_installation = "Y")
		or (vr_comp.service_c = vg_enf_trade_service
		and vg_enf_trade_installation = "Y")
		then
			call drive_enforce_destination()
			return
		else
			select enf_complaint_no
				into vl_enforcement_ref
			from comp_enf_link
				where source_complaint = vr_comp.complaint_no
		end if
	end if
	if not vl_enforcement_ref
	then
		case vr_comp.action_flag
			when ""
				call valid_error("",
					"DATA ERROR: There is no next action flag!","")
				return
			when "N"
				let vg_title = "The selected ", 
					downshift(vg_record_title) clipped, 
					" has no further action."
				call valid_error("", vg_title, "")
				return
			when "H"
				let vg_title = "The selected ", 
					downshift(vg_record_title) clipped, 
					" is currently on hold."
				call valid_error("", vg_title, "")
				return
			when "M"
				let vg_title = "The selected ", 
					downshift(vg_record_title) clipped, 
					" is awaiting a management decision."
				call valid_error("", vg_title, "")
				return
			when "P"
				let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
				if
					vg_allow_monitor = "Y" and
					vg_monitor_fault matches vl_comp_code and
					vr_comp.recvd_by = vg_monitor_source
				then		
					let vg_title = ""
				else
					let vg_title = "The selected ", 
						downshift(vg_record_title)
						clipped, " is currently pending."
					call valid_error("", vg_title, "")
					return
				end if
		end case
	end if

	call start_wait()
	
	initialize v_action_flag to null
	initialize v_dest_ref to null
	initialize v_dest_flag to null
	initialize v_diry_ref to null
	initialize v_next_record to null
	initialize v_po_code to null
	initialize v_date_done to null
	initialize v_po_name to null

	select diry_ref,
			action_flag,
			dest_flag,
			dest_ref,
			next_record,
			inspect_ref,
			po_code,
			date_done
	into v_diry_ref,
			v_action_flag,
			v_dest_flag,
			v_dest_ref,
			v_next_record,
			v_inspect_ref,
			v_po_code,    # Andy Jones
			v_date_done   # 15/07/1997
	from diry
		where source_flag = "C"
	and source_ref = vr_comp.complaint_no

	if status = notfound
	then
		call valid_error("", 
			"DATA ERROR: The diary information for this record does not exist!",
			"")
		call end_wait()
		return
	end if

	call end_wait()

	case 
		when v_action_flag = ""
			call valid_error("",
				"ERROR: There is no destination flag in the diary", 
				"")
			return

		when v_action_flag = "P" and vr_comp.action_flag != "P"
		or v_action_flag = "M" and vr_comp.action_flag != "M"
		or v_action_flag = "H" and vr_comp.action_flag != "H"
		or v_action_flag = "N" and vr_comp.action_flag != "N"
			call valid_error("",
				"ERROR: The next action flags in complaints and diary differ",
				"")
			return
	end case

	let vl_dest_flag = true
	while true
		let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
		if vl_enforcement_ref
		then
			if vr_comp.action_flag matches "[NPMH]"
			then
				let vl_runstr = 
					"exec fglgo_complain X X X X X ", vl_enforcement_ref
				call os_exec(vl_runstr, false)
				let vl_dest_flag = false
			else
				# We need a menu
				let vl_s_menu_desc = 
					"Display the destination of the selected ",
					downshift(vg_record_title) clipped, "."
				let vl_e_menu_desc = 
					"Display the enforcement related to the selected ",
					downshift(vg_record_title) clipped, "."

				menu "Show-Dest"
					command "Destination" vl_s_menu_desc
						let vl_dest_flag = true
						exit menu
					command key ("F") "enForcement" vl_e_menu_desc
						let vl_runstr = 
							"exec fglgo_complain X X X X X ", vl_enforcement_ref
						call os_exec(vl_runstr, false)
					on action about
						call os_exec("exec fglgo_about", 1)
					on action Exit
						let vl_dest_flag = false
						exit menu
					on action close
						let vl_dest_flag = false
						exit menu
				end menu
			end if
		end if

		if vl_dest_flag
		then
			case v_action_flag
				when "P"
					let vg_title = "The selected ", 
						downshift(vg_record_title)
						clipped, " is currently pending."
					call valid_error("", vg_title, "")
				when "I"
					#ADJ ADHOC
					if skey_check("ALLOW_ADHOC_SAMPLES", "ALL") = "Y"
					and vr_comp.comp_code = 
						skey_check("ADHOC_SAMPLE_FAULT", "ALL")
					then
						select *
							into vr_comp_adhoc_sample.*
						from comp_adhoc_sample
							where complaint_no = vr_comp.complaint_no

						open window iw_adhoc_sample_info at 8, 28
							with form "comp_adhoc_sample" 

#						display "INSPECTION INFORMATION" at 1, 2 

						display by name vr_comp_adhoc_sample.start_date,
										vr_comp_adhoc_sample.duration_days,
										vr_comp_adhoc_sample.occur_days,
										vr_comp_adhoc_sample.next_date, 
										vr_comp_adhoc_sample.end_date 
						menu " "
#							on action about
#								call os_exec("exec fglgo_about", 1)
							on action accept
								exit menu
							on action close
								exit menu
						end menu
						close window iw_adhoc_sample_info
						return
					end if

					let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
					if
						vg_allow_monitor = "Y" and
						vg_monitor_fault matches vl_comp_code
					then
						select *
							into vr_comp_monitor.*
						from comp_monitor
							where complaint_no = vr_comp.complaint_no
						open window iw_monitor_info at 8, 28
							with form "comp_monitor" 

#						display "MONITOR INFORMATION" at 1, 2 

						display by name vr_comp_monitor.start_date,
										vr_comp_monitor.duration_days,
										vr_comp_monitor.occur_days,
										vr_comp_monitor.next_date, 
										vr_comp_monitor.end_date 
						menu "Show-dest"
							on action about
								call os_exec("exec fglgo_about", 1)
							on action Exit
								exit menu
							on action close
								exit menu
						end menu
						close window iw_monitor_info
						return
					end if

					if v_dest_ref is not null
					then
						if v_dest_flag matches "D" then
							error "DESTINATION:", 
								  " Inspection List No. ", v_inspect_ref,
								  " -> Default No. ", v_dest_ref
							sleep 0.5
							let vl_runstr = "exec fglgo_default x ", 
								v_dest_ref using "<<<<<<<"
							call os_exec(vl_runstr, false)
						else
{ BJG 29/09/2005 This code commented to resolve bug 10.10 AV Inspection Screen.
							call insp_display(v_diry_ref)
#							current window is iw_complain
						end if
}
# BJG 29/09/2005 The code below copied from the dest_ref is null section...
							if v_inspect_ref is not null
							then
								call insp_display(v_diry_ref)
#								current window is iw_complain
							else
								if change_comp_inspection(vr_comp.complaint_no)
								then
									call get_diry_ref()
										returning vr_diry.diry_ref,
												vr_si_i.item_ref,
												vr_si_i.contract_ref,
												vr_si_i.feature_ref
									if vr_diry.diry_ref is null
									then
										call valid_error ("",
									"The selected record could not be updated",
											"")
										sleep 0.5
										let int_flag = true
									end if

									let vl_act_flag_save = vr_comp.action_flag

									let vr_comp.item_ref = vr_si_i.item_ref

{ BJG - This input needs to be from a selection of screen fields subject
        to service code and x,y co-ord (comp_code) requirements.
        A new function created to handle this .....

									call populate_action_combo
										(
										"U",
										"ADWXHPIN",
										"generic_action_text"
										)
									#ADJ ACTION_TEXT TODO
									let generic_action_text = vr_comp.action_flag
									input by name generic_action_text without defaults
									let vr_comp.action_flag = generic_action_text
}
									let vr_comp.action_flag = change_action()

									let vr_comp.action_flag =	
										process_action(vr_diry.diry_ref)

									#ADJ GENERO
									#let vr_comp.action_flag = 
									#	drive_enter_action(vr_diry.diry_ref)
										
									if not length(vr_comp.action_flag)
									then
										let vr_comp.action_flag = 
											vl_act_flag_save
										return
									end if
# find out whether the destination of this complaint was cleared
									call check_comp_cleared()
									let vr_diry.action_flag = 
										vr_comp.action_flag
##By steven
									if vr_comp.action_flag matches "[NHP]"
									then
										initialize vr_comp.dest_ref,
														vr_comp.dest_suffix to null
									end if
									if vr_comp.action_flag = "I"
									then
										initialize vr_comp.dest_suffix to null
									end if
									update comp set 
										action_flag = vr_comp.action_flag,
										dest_ref    = vr_comp.dest_ref,
										dest_suffix = vr_comp.dest_suffix,
										date_closed = vr_comp.date_closed,
										time_closed_h = vr_comp.time_closed_h, 
										time_closed_m = vr_comp.time_closed_m 
									where complaint_no = vr_comp.complaint_no
# BJG 14/04/2011 - If we are here the action_flag must have changed, so if it
#                  is now "N" we need to save a new text line to detail who
#                  set this action
                                    IF vr_comp.action_flag = "N"
                                    AND vr_comp.action_flag != vl_act_flag_save
                                    THEN
                                        CALL record_nfa_text(vr_comp.complaint_no)
                                    END IF
									call update_complaint_source()
									call notify_customer
									(
										vr_comp.complaint_no,
										"",
										"",
										""
									)

									if vg_crm_enhanced = "Y"
									then
										call pop_ci_export_variables(vr_comp.complaint_no)
										let vr_crm_import_export.transaction_type = "C"
										call unload_crm_export_file
																	(vr_crm_import_export.*)
									end if

									call ws_ext_integration
										(vr_comp.complaint_no, "", "", "")

									if vr_comp.action_flag != "N"
									then	
										update diry set 
											action_flag = vr_comp.action_flag,
											dest_ref = vr_comp.dest_ref
										where diry_ref = vr_diry.diry_ref
									else
										let vr_diry.action_flag = "C"
										let vr_diry.dest_flag = "C"
										let vr_diry.dest_ref = null
										let vr_diry.dest_date = today
										let vr_diry.dest_time_h = 
											extend(current, hour to hour)
										let vr_diry.dest_time_m = 
											extend(current, minute to minute)
										let vr_diry.dest_user = get_user()
										let vr_diry.dest_user = 
											upshift(vr_diry.dest_user)

										update diry set 
											action_flag = vr_diry.action_flag,
											dest_flag = vr_diry.dest_flag,  
											dest_ref = vr_diry.dest_ref,
											dest_date = vr_diry.dest_date,
											dest_time_h = vr_diry.dest_time_h,
											dest_time_m = vr_diry.dest_time_m,
											dest_user = vr_diry.dest_user
										where diry_ref = vr_diry.diry_ref
									end if 	

#									current window is iw_complain

									let generic_action_text = vr_comp.action_flag

#									display vr_comp.dest_ref
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to generic_dest_ref,
												generic_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to av_dest_ref,
												av_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to gm_dest_ref,
												gm_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to ert_dest_ref,
												ert_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to trade_dest_ref,
												trade_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to agreq_dest_ref,
												agreq_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to meas_dest_ref,
												meas_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to tree_dest_ref,
												tree_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to sched_dest_ref,
												sched_dest_suffix

									call display_comp_action_text()
								end if
							end if
						end if
					else
# Added by Andy Jones - 15/07/1997 - Cleared Inspections now work...!
						if v_dest_flag is not null
						then
							select po_name
							into v_po_name
							from patr
							where patr.po_code = v_po_code

						 let vl_po_desc = skey_check("PO_DESC", "ALL")
						 error 
				"CLEARED- Inspection List no.", v_inspect_ref using "<<<<<<<<", 
				", ", vl_po_desc clipped, ":", v_po_name clipped,", Date:",
				v_date_done
#					******
# CLEARED- Inspection List no.999, Patrol Officer:David Hopkins, Date:04/03/1997
#					******
						else
							if v_inspect_ref is not null
							then
								call insp_display(v_diry_ref)
#								current window is iw_complain
							else
								if change_comp_inspection(vr_comp.complaint_no)
								then
									call get_diry_ref()
										returning vr_diry.diry_ref,
												vr_si_i.item_ref,
												vr_si_i.contract_ref,
												vr_si_i.feature_ref
									if vr_diry.diry_ref is null
									then
										call valid_error ("",
									"The selected record could not be updated",
											"")
										sleep 0.5
										let int_flag = true
									end if

									let vl_act_flag_save = vr_comp.action_flag

									let vr_comp.item_ref = vr_si_i.item_ref

{ BJG - This input needs to be from a selection of screen fields subject
        to service code and x,y co-ord (comp_code) requirements.
        A new function created to handle this .....

									call populate_action_combo
										(
										"U",
										"ADWXHPIN",
										"generic_action_text"
										)
									let generic_action_text = vr_comp.action_flag
									input by name generic_action_text without defaults
									let vr_comp.action_flag = generic_action_text
}
									let vr_comp.action_flag = change_action()

									let vr_comp.action_flag =	
										process_action(vr_diry.diry_ref)

									#ADJ GENERO
									#let vr_comp.action_flag = 
									#	drive_enter_action(vr_diry.diry_ref)
										
									if not length(vr_comp.action_flag)
									then
										let vr_comp.action_flag = 
											vl_act_flag_save
										return
									end if
# find out whether the destination of this complaint was cleared
									call check_comp_cleared()
									let vr_diry.action_flag = 
										vr_comp.action_flag
##By steven
									if vr_comp.action_flag matches "[NHP]"
									then
										initialize vr_comp.dest_ref,
														vr_comp.dest_suffix to null
									end if
									if vr_comp.action_flag = "I"
									then
										initialize vr_comp.dest_suffix to null
									end if
									update comp set 
										action_flag = vr_comp.action_flag,
										dest_ref    = vr_comp.dest_ref,
										dest_suffix = vr_comp.dest_suffix,
										date_closed = vr_comp.date_closed,
										time_closed_h = vr_comp.time_closed_h, 
										time_closed_m = vr_comp.time_closed_m 
									where complaint_no = vr_comp.complaint_no
# BJG 14/04/2011 - If we are here the action_flag must have changed, so if it
#                  is now "N" we need to save a new text line to detail who
#                  set this action
                                    IF vr_comp.action_flag = "N"
                                    AND vr_comp.action_flag != vl_act_flag_save
                                    THEN
                                        CALL record_nfa_text(vr_comp.complaint_no)
                                    END IF
									call update_complaint_source()
									call notify_customer
									(
										vr_comp.complaint_no,
										"",
										"",
										""
									)

									if vg_crm_enhanced = "Y"
									then
										call pop_ci_export_variables(vr_comp.complaint_no)
										let vr_crm_import_export.transaction_type = "C"
										call unload_crm_export_file
																	(vr_crm_import_export.*)
									end if

									call ws_ext_integration
										(vr_comp.complaint_no, "", "", "")

									if vr_comp.action_flag != "N"
									then	
										update diry set 
											action_flag = vr_comp.action_flag,
											dest_ref = vr_comp.dest_ref
										where diry_ref = vr_diry.diry_ref
									else
										let vr_diry.action_flag = "C"
										let vr_diry.dest_flag = "C"
										let vr_diry.dest_ref = null
										let vr_diry.dest_date = today
										let vr_diry.dest_time_h = 
											extend(current, hour to hour)
										let vr_diry.dest_time_m = 
											extend(current, minute to minute)
										let vr_diry.dest_user = get_user()
										let vr_diry.dest_user = 
											upshift(vr_diry.dest_user)

										update diry set 
											action_flag = vr_diry.action_flag,
											dest_flag = vr_diry.dest_flag,  
											dest_ref = vr_diry.dest_ref,
											dest_date = vr_diry.dest_date,
											dest_time_h = vr_diry.dest_time_h,
											dest_time_m = vr_diry.dest_time_m,
											dest_user = vr_diry.dest_user
										where diry_ref = vr_diry.diry_ref
									end if 	

#									current window is iw_complain

#									display by name vr_comp.dest_ref
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to generic_dest_ref,
												generic_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to av_dest_ref,
												av_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to gm_dest_ref,
												gm_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to ert_dest_ref,
												ert_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to trade_dest_ref,
												trade_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to agreq_dest_ref,
												agreq_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to meas_dest_ref,
												meas_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to tree_dest_ref,
												tree_dest_suffix
									display vr_comp.dest_ref,
												vr_comp.dest_suffix
										 	to sched_dest_ref,
												sched_dest_suffix

									call display_comp_action_text()
								end if
							end if
						end if
					end if

				when "W" #v_dest_ref is W/O key NOT wo_ref - wo_ref not unique
#					call wo_h_main(v_dest_ref, true)
					if vg_act = "r"
					then
						let vl_runstr = "exec fglgo_wk_ord r x x ", 
							v_dest_ref using "<<<<<<<"
					else
						let vl_runstr = "exec fglgo_wk_ord x x x ", 
							v_dest_ref using "<<<<<<<"
					end if
					call os_exec(vl_runstr, false)

				when "D"
#					call upd_def(v_dest_ref)
					let vl_runstr = "exec fglgo_default x ", 
						v_dest_ref using "<<<<<<<"
					call os_exec(vl_runstr, false)

				{ADJ BJG
				when "E"
					if vg_enf_installation = "Y"
					and length(v_dest_ref)
					then
						let vl_runstr = "exec fglgo_complain X X X X X ",
														v_dest_ref
						call os_exec(vl_runstr, false)
					else
						call valid_error("",
							"The destination flag is invalid.", "")
					end if
				}

				otherwise
					call valid_error("",
						"The destination flag is invalid.", "")
			end case
			if vl_enforcement_ref
			then
				continue while
			end if
		end if 
		exit while
	end while 

end function	# drive_destination_display


function get_diry_ref()
	define
		vl_item_ref			  like diry.item_ref,
		vl_contract_ref		like diry.contract_ref,
		vl_feature_ref		like diry.feature_ref,
		vl_diry_ref,
		vl_comp_no_char		char(12)

	call start_wait()

	select *
		into vr_diry.*
	from diry
		where source_flag = "C"
		and source_ref = vr_comp.complaint_no

	call end_wait()

	if status = notfound
	then
		error "No diry_ref could be found for this record."
		sleep 0.5
		return "", "", "", ""
	end if

	let vl_diry_ref = vr_diry.diry_ref
	let vl_item_ref = vr_diry.item_ref
	let vl_contract_ref = vr_diry.contract_ref
	let vl_feature_ref = vr_diry.feature_ref

	return vl_diry_ref, vl_item_ref, vl_contract_ref, vl_feature_ref

end function	# get_diry_ref


function open_action_window()
	if  vr_comp.service_c = vg_av_service
	and vg_av_installation = "Y"
	and skey_check("AV WO USED", "ALL") = "Y" 
	then
		open window dm_actwin at 8, 28 with form "comp_act_av"

		display "SELECT ACTION" at 1,2
		display "OK" TO btok
#		display "Cancel" TO btcan #cancel

		display "E-Enforce Action     " TO bte
		display "H-Hold               " TO bth
		display "I-Inspection         " TO bti
		{ ADJ251103
		display "M-Management Decision" TO btm
		}
		display "P-Pending            " To btp
		display "N-No Further Action  " To btn
		display "W-Works Order        " TO btw
		display "X-eXpress Works Order" TO btq
	else
		open window dm_actwin at 8, 28 with form "comp_act"

		#ADJ GENERO
		{
		display "SELECT ACTION" at 1,2
		display "OK" TO btok
#		display "Cancel" TO btcan #cancel

		display "A-Auto Default       " TO bta
		display "D-Manual Default     " TO btr
		display "E-Enforce Action     " TO bte
		display "H-Hold               " TO bth
		display "I-Inspection         " TO bti
		display "P-Pending            " To btp
		display "N-No Further Action  " To btn
		display "W-Works Order        " TO btw
		display "X-eXpress Works Order" TO btx
		}
	end if

end function	# open_action_window


function disp_last_complain(vl_site_ref)
	define
		vl_site_ref			like diry.site_ref,
		vl_site_date		like diry.dest_date,
		vl_reply			char(1)

	declare qc_disp_comp cursor for
	select dest_date
		from diry
		where dest_flag is not null
		and dest_flag != "X"
		and site_ref = vl_site_ref
		and dest_date is not null
		order by dest_date desc

	open qc_disp_comp
	fetch qc_disp_comp into vl_site_date

	if status = notfound
	then
		error " Last inspection cannot be found for this site"
		sleep 0.5
	else
		display vl_site_date to site_date
		prompt " Press return when finished" for vl_reply
	end if

	close qc_disp_comp

end function	# disp_last_complain


function open_disp_comp_wind()
	open window disp_comp_wind at 12, 24 with 4 rows, 36 columns

	open form f_disp_comp from "disp_comp"
	display form f_disp_comp

end function	# open_disp_comp_wind


function close_disp_comp_wind()
	close window disp_comp_wind
end function	# close_disp_comp_wind


function complaint_history()
	if not check_history_system_key(vr_comp.service_c)
	then
		call valid_error("",
			"Hidden text is not available for the selected service", "")
		return
	end if 
	if vg_act = "r"
	then
		call valid_error("",
			"Hidden text is not available", "")
		return
	end if 
	if vr_comp.complaint_no is not null
	and vr_comp.complaint_no != 0
	then
		call history_text_yes_no(vr_comp.complaint_no, "CT")
	else
		error
" Sorry cannot enter hidden text against an unknown reference number"
		prompt
		"Please enter a reference number leave blank to return to menu"
			for vr_comp.complaint_no
		if vr_comp.complaint_no is not null
		and vr_comp.complaint_no != 0
		then
			call history_text_yes_no(vr_comp.complaint_no, "CT")
			let vr_comp.complaint_no = 0
		end if
	end if

	{
	menu "Hidden-text"
		before menu
			if not quiet_allow("display_hist_text")
			then
				hide option "Display"
			end if
			if not quiet_allow("ad/upd/dispy_hist_text")
			then
				hide option "Add/update"
			end if
			#if not quiet_allow("prnt_hist_text")
			#then
			#	hide option "Print report"
			#end if
			#

		command "Display" "Display hidden text."
			if vr_comp.complaint_no is not null
			and vr_comp.complaint_no != 0
			then
				call disp_scroll_history_txt_n("CT", vr_comp.complaint_no) 
				exit menu
			else
				error
	" Sorry cannot display hidden text against an unknown reference number"
				prompt
			" Please enter a reference number or leave blank to return to menu"
					for vr_comp.complaint_no
				if vr_comp.complaint_no is not null
				and vr_comp.complaint_no != 0
				then
					call disp_scroll_history_txt_n("CT", vr_comp.complaint_no) 
					let vr_comp.complaint_no = 0
					exit menu
				end if
			end if

		command "Add/update" "Add, Update or display hidden Text."
			if vr_comp.complaint_no is not null
			and vr_comp.complaint_no != 0
			then
				call history_text_yes_no(vr_comp.complaint_no, "CT")
				exit menu
			else
				error
	" Sorry cannot enter hidden text against an unknown reference number"
				prompt
				"Please enter a reference number leave blank to return to menu"
					for vr_comp.complaint_no
				if vr_comp.complaint_no is not null
				and vr_comp.complaint_no != 0
				then
					call history_text_yes_no(vr_comp.complaint_no, "CT")
					let vr_comp.complaint_no = 0
					exit menu
				end if
			end if

		command "Print report" "Print all hidden Text."
			if vr_comp.complaint_no is not null
			and vr_comp.complaint_no != 0
			then
				call history_text_yes_no(vr_comp.complaint_no, "CT")
			else
				error
	" Sorry cannot print hidden text against an unknown reference number"
				prompt
				" Please enter a reference number leave blank to return to menu"
					for vr_comp.complaint_no
				if vr_comp.complaint_no is not null
				and vr_comp.complaint_no != 0
				then
					call comp_hist_txt(vr_comp.complaint_no)
					let vr_comp.complaint_no = 0
				end if
			end if

		on action about
			call os_exec("exec fglgo_about", 1)

		on action Exit
			exit menu

		on action close
			exit menu
	end menu
	}
end function	# complaint_history


function comp_hist_txt(vl_complaint_no)
	define
		rpt_row	record
			  lookup_code		char(6),
			  lookup_text		char(40),
			  complaint_no		integer,
			  location_name,
			  location_desc,
			  compl_name		char(40),
			  compl_build_no	char(10),
			  compl_build_name,
			  compl_addr2,
			  compl_addr3		char(40),
			  compl_phone		char(20),
			  seq				integer,
			  txt				char(50),
			  doe				date,
			  username			char(12)
		end record,
		vl_complaint_no	 	like comp.complaint_no,
		f_rows				INTEGER
    DEFINE vl_file_number           LIKE s_no.serial_no
    DEFINE vl_output_file           STRING
        

	declare comp_h_tx_cur cursor for
	select 
	    allk.lookup_code,
			allk.lookup_text,
			comp.complaint_no,
			comp.location_name,
			comp.location_desc,
			customer.compl_name,
			customer.compl_build_no,
			customer.compl_build_name,
			customer.compl_addr2,
			customer.compl_addr3,
			customer.compl_phone,
			history_txt.seq,
			history_txt.txt,
			history_txt.doe,
			history_txt.username
		from allk, comp, history_txt, customer, comp_clink
		where history_txt.func = "CT"
		and allk.lookup_func = "COMPLA"
		and allk.lookup_code = comp.comp_code
		and comp.complaint_no = vl_complaint_no
		and comp.complaint_no = history_txt.reference
		and customer.customer_no = comp_clink.customer_no
		and comp_clink.complaint_no = comp.complaint_no
		and comp_clink.seq_no = 1
		order by history_txt.doe, history_txt.username,
		history_txt.seq

	select count(*)
		into f_rows
		from allk, comp, history_txt
		where history_txt.func = "CT"
		and allk.lookup_func = "COMPLA"
		and allk.lookup_code = comp.comp_code
		and comp.complaint_no = vl_complaint_no
		and comp.complaint_no = history_txt.reference

	if f_rows > 0 THEN
        CALL get_report_filename("comp_hist_txt") RETURNING vl_output_file,vl_file_number
        start report comp_h_tx_rpt to vl_output_file
		foreach comp_h_tx_cur into rpt_row.*
			output to report comp_h_tx_rpt(rpt_row.*)
		end foreach
		finish report comp_h_tx_rpt
        CALL print_it("comp_hist_txt", vl_file_number)
	else
		error " Sorry no Text to Print"
	end if

end function	# comp_hist_txt


report comp_h_tx_rpt(lookup_code,		# Report : receives each row from query
					lookup_text,
					complaint_no,
					location_name,
					location_desc,
					compl_name,
					compl_build_no,
					compl_build_name,
					compl_addr2,
					compl_addr3,
					compl_phone,
					seq,
					txt,
					doe,
					username)

	define
		doe					date,
		complaint_no,
		seq					integer,
		txt					char(50),
		lookup_text,
		location_name,
		location_desc,
		compl_name,
		compl_surname,
		compl_build_name,
		compl_addr2,
		compl_addr3			char(40),
		compl_phone			char(20),
		username			char(12),
		compl_build_no		char(10),
		lookup_code			char(6)

	output
		top margin 0
		bottom margin 0
		left margin 0
		right margin 0
		page length 64

	order external by doe, username

	format
		first page header
			print column 1, "Complaint Number :",
				column 20, complaint_no using "-,---,--&",
				column 37, "Report Date:",
				column 50, today using "dd/mm/yyyy",
				column 68, "Page:",
				column 74, pageno using "<<<<"
			print column 1, "========================================",
				column 41, "========================================"
			skip 1 lines
			print column 6, "Complainant:",
				column 20, compl_name clipped, " ", compl_surname
			print column 3, "House no./name:",
				column 20, compl_build_no,
				column 32, compl_build_name
			print column 10, "Address:",
				column 20, compl_addr2
			print column 20, compl_addr3
			print column 8, "Telephone:",
				column 20, compl_phone
			skip 1 lines
			print column 3, "Fault Location:",
				column 20, location_name
			print column 20, location_desc
			print column 12, "Fault:",
				column 20, lookup_code,
				column 28, lookup_text
			skip 1 lines
			print column 1, "Date",
				column 13, "User",
				column 25, "Text"
			print column 1, "----------------------------------------",
				column 41, "----------------------------------------"

		page header
			print column 1, "Complaint Number :",
				column 20, complaint_no using "-,---,--&",
				column 39, "Report Date:",
				column 52, today using "dd/mm/yyyy",
				column 68, "Page:",
				column 74, pageno using "<<<<"
			print column 1, "========================================",
				column 41, "========================================"
			skip 2 lines

		before group of doe
			print column 2, doe using "dd/mm/yyyy";

		before group of username
			print " ", username clipped;

		after group of doe
			skip 1 line

		on every row
			print column 26, txt

end report	# comp_h_tx_rpt


function display_comp_code_info()
	define
		f_text				char(40)

	if vr_comp.comp_code is null
		or vr_comp.comp_code = ""
	then
		let f_text = ""
	else
		select lookup_text
			into f_text
			from allk
			where lookup_func = "COMPLA"
			and lookup_code = vr_comp.comp_code
	end if

	display by name vr_comp.comp_code
	display vr_comp.comp_code to gm_comp_code
	display vr_comp.comp_code to tree_comp_code
	display f_text to fault_desc
	display f_text to meas_fault_desc
	display f_text to gm_fault_desc
	display f_text to tree_fault_desc
	display f_text to ert_fault_desc

end function	# display_comp_code_info


function display_recvd_info()
	define
		f_text				char(40)
	if vr_comp.recvd_by is null
		or vr_comp.recvd_by = ""
	then
		let f_text = ""
	else
		select lookup_text
			into f_text
			from allk
			where lookup_func = "CTSRC"
			and lookup_code = vr_comp.recvd_by
	end if

	display f_text to lookup_char
end function	# display_recvd_info


function display_status_info_box()
	if vr_comp.complaint_no
	then
		if vr_comp.text_flag = "N"
		then
			display "N" to text_flag
		else
			display "Y" to text_flag attribute(yellow, reverse)
		end if
		if not length(vr_comp.date_closed)
		or (vr_comp.service_c = vg_av_service
			and skey_check("AV_ALWAYS_DISP_RUN", "ALL") = "Y")
		then
			display "RUNNING" to comp_status attribute(green, reverse)
		else
			display "CLOSED" to comp_status attribute(red, reverse)
		end if
		call show_attach_flag()
		call disp_complaint_history_text()
	else
		if m_comp_arr_count = 0
		then
			display "N" to text_flag
		else
			display "Y" to text_flag attribute(reverse, yellow)
		end if
		display "" to comp_status
		display "N" to history_txt_flag
        LET va_attachment_flag[1].attachment_flag="0"
		display "0" to attachment_flag
	end if
end function


function display_stage_info()
	define
		f_text				char(40)
	if vr_comp_agreq.contract_stage is null
		or vr_comp_agreq.contract_stage = ""
	then
		let f_text = ""
	else
		select lookup_text
			into f_text
			from allk
			where lookup_func = "TRCSTG"
			and lookup_code = vr_comp_agreq.contract_stage
	end if

	display f_text to contract_stage_desc

end function	# display_stage_info


function display_service_info()
	define
		vl_service_desc 	like keys.c_field		

	if length(vr_comp.service_c)
	then
		select keydesc
			into vl_service_desc
		from keys
			where service_c = vr_comp.service_c
			and keyname = "HEADER"
	else
		let vl_service_desc = null
	end if
#	display vl_service_desc to service_desc
end function


function display_recvd()
	define
		f_text				char(40)
	if vr_comp.recvd_by is null
		or vr_comp.recvd_by = ""
	then
		let f_text = ""
	else
		select lookup_text
			into f_text
			from allk
			where lookup_func = "CTSRC"
			and lookup_code = vr_comp.recvd_by
	end if

end function

function enter_destination(vl_flag)
	define
		f_comp_destination	record like comp_destination.*,
		vl_flag				char(1)

	let f_comp_destination.* = vr_comp_destination.* 

	if f_comp_destination.destination_date is null
	or f_comp_destination.destination_date < "01/01/1900"
	then
		let f_comp_destination.destination_date = today
	end if

	if check_dest_system_key(vr_comp.service_c)
	then
		open window iw_destination at 18, 2 with form "comp_dest"

		if vl_flag = "D"
		then
			display by name f_comp_destination.destination,
						f_comp_destination.destination_date 

			menu "Allocation"
				command "Update" "Update the displayed allocation."
					let vl_flag = "U"
					exit menu
				on action about
					call os_exec("exec fglgo_about", 1)
				on action Exit
					exit menu
				on action close
					exit menu
			end menu
		end if

#		call clear_menu()

		if vl_flag != "D"
		then
#			display "COMPLAINT ALLOCATION" at 1,1
			input by name f_comp_destination.destination,
						f_comp_destination.destination_date without defaults
				on action about
					call os_exec("exec fglgo_about", 1)
				on action cancel
					let int_flag = true
					exit input 
				on action close
					let int_flag = true
					exit input 
			end input	
		end if

		close window iw_destination

		if int_flag
		then
			let int_flag = false
			return vr_comp_destination.*
		else
			if vl_flag = "U"
			then
				update comp_destination set 
					destination = f_comp_destination.destination,
					destination_date = f_comp_destination.destination_date
						where complaint_no = vr_comp_destination.complaint_no
			end if
			let vr_comp_destination.* = f_comp_destination.*
			return vr_comp_destination.*
		end if
	else
		initialize vr_comp_destination.* to null
		return vr_comp_destination.*
	end if

end function	# enter_destination


function check_dest_system_key(f_service_code)
	define
		f_keys				record like keys.*,
		f_service_code		like keys.service_c,
		ret_code			integer

	if f_service_code is null
	then
#		let f_service_code = skey_check("DEFAULT SERVICE", "ALL")
		let f_service_code = vg_default_service
	end if

	select *
		into f_keys.*
		from keys
		where keyname = "DESTN-INFO"
		and service_c = f_service_code

	if status = notfound
	then
		insert into keys (service_c, keyname, keydesc, c_field)
			values (f_service_code,
					"DESTN-INFO",
					"Is destination entry available ?",
					"N")

		select *
			from skop
			where keyname = "DESTN-INFO"
			and field_type = "C"

		if status = notfound
		then
			insert into skop values ("DESTN-INFO", "C")
		end if

		let ret_code = false
	else
		if f_keys.c_field = "Y"
		then
			let ret_code = true
		else
			let ret_code = false
		end if
	end if

	return ret_code

end function	# check_dest_system_key


function check_comp_action_system_key(f_service_code)
	define
		f_keys				record like keys.*,
		f_service_code		like keys.service_c,
		ret_code			integer

	if f_service_code is null
	then
#		let f_service_code = skey_check("DEFAULT SERVICE", "ALL")
		let f_service_code = vg_default_service
	end if

	select *
		into f_keys.*
		from keys
		where keyname = "COMPLAINT ACTION"
		and service_c = f_service_code

	if status = notfound
	then
		insert into keys (service_c, keyname, keydesc, c_field)
			values (f_service_code,
					"COMPLAINT ACTION",
					"Default Complaint Next Action",
					"H")

		select *
			from skop
			where keyname = "COMPLAINT ACTION"
			and field_type = "C"

		if status = notfound
		then
			insert into skop values ("COMPLAINT ACTION", "C")
		end if

		let f_keys.c_field = "H"
	end if

	return f_keys.c_field

end function	# check_comp_action_system_key


function check_both_reps_comp_wo_key(f_service_code)
	define
		f_keys				record like keys.*,
		f_service_code		like keys.service_c,
		ret_code			smallint

	let ret_code = false

	if f_service_code is null
	then
#		let f_service_code = skey_check("DEFAULT SERVICE", "ALL")
		let f_service_code = vg_default_service
	end if

	select *
		into f_keys.*
		from keys
		where keyname = "BOTH REPS COMP/WO"
		and service_c = f_service_code

	if status = notfound
	then
		insert into keys (service_c, keyname, keydesc, c_field)
			values (f_service_code,
					"BOTH REPS COMP/WO",
					"Print both Works Order/Complaint",
					"Y")

		select *
			from skop
			where keyname = "BOTH REPS COMP/WO"
			and field_type = "C"

		if status = notfound
		then
			insert into skop values ("BOTH REPS COMP/WO", "C")
		end if
	end if

	if f_keys.c_field = "Y"
	then
		let ret_code = true
	end if

	return ret_code

end function	# check_both_reps_comp_wo_key


function check_copy_comp_text_to_wo_key(f_service_code)
	define
		f_keys				record like keys.*,
		f_service_code		like keys.service_c,
		ret_code			smallint

	let ret_code = false

	if f_service_code is null
	then
#		let f_service_code = skey_check("DEFAULT SERVICE", "ALL")
		let f_service_code = vg_default_service
	end if

	select *
		into f_keys.*
		from keys
		where keyname = "COMP_TEXT TO WO"
		and service_c = f_service_code

	if status = notfound
	then
		insert into keys (service_c, keyname, keydesc, c_field)
			values (f_service_code,
					"COMP_TEXT TO WO",
					"Copy Complaint Text to Works Order",
					"N")

		select *
			from skop
			where keyname = "COMP_TEXT TO WO"
			and field_type = "C"

		if status = notfound
		then
			insert into skop values ("COMP_TEXT TO WO", "C")
		end if
	end if

	if f_keys.c_field = "Y"
	then
		let ret_code = true
	end if

	return ret_code

end function	# check_copy_comp_text_to_wo_key


function check_copy_comp_text_to_def_key(f_service_code)
	define
		f_keys				record like keys.*,
		f_service_code		like keys.service_c,
		ret_code			smallint

	let ret_code = false

	if f_service_code is null
	then
#		let f_service_code = skey_check("DEFAULT SERVICE", "ALL")
		let f_service_code = vg_default_service
	end if

	select *
		into f_keys.*
		from keys
		where keyname = "COMP_TEXT TO DEFS"
		and service_c = f_service_code

	if status = notfound
	then
		insert into keys (service_c, keyname, keydesc, c_field)
			values (f_service_code,
					"COMP_TEXT TO DEFS",
					"Copy Complaint Text to Defaults",
					"N")

		select *
			from skop
			where keyname = "COMP_TEXT TO DEFS"
			and field_type = "C"

		if status = notfound
		then
			insert into skop values ("COMP_TEXT TO DEFS", "C")
		end if
	end if

	if f_keys.c_field = "Y"
	then
		let ret_code = true
	end if

	return ret_code

end function	# check_copy_comp_text_to_def_key


function check_comp_cleared()
# This function checks the complaint record and sees whether the complaint
# has gone to a destination which has been cleared, if so the complaint
# record is set with the clear_date and time
# It is up to the calling function to update the comp table, this function
# purely updates the record
	define
		vl_match			char(3),
		vl_status_change	char(22),
		vl_wo_stat			record like wo_stat.*

	case			# Is this complaint completed?
		when vr_comp.action_flag = "N"			# This record is closed
			case 
				when  vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
# BJG only leave running if NOT using enhanced AV..........
					and skey_check("AV WO USED", "ALL") = "N"

				when vr_comp.service_c = vg_enf_service
					and vg_enf_installation = "Y"

				when vr_comp.service_c = vg_enf_trade_service
					and vg_enf_trade_installation = "Y"

				otherwise
					let vr_comp.dest_ref = 0
					let vr_comp.date_closed = today
					let vr_comp.time_closed_h = extend(current, hour to hour)
					let vr_comp.time_closed_m = extend(current, minute to minute)
			end case

		when vr_comp.action_flag = "D"
			if vr_defh.cust_def_no is null or vr_defh.cust_def_no = 0
			then
				call valid_error("",
					"There is no default no.  Contact the system administrator",
					"")
			else
				let vr_comp.dest_ref = vr_defh.cust_def_no
			end if

			select *
				from defh
			where cust_def_no = vr_defh.cust_def_no
				and default_status = "N"

			if status != notfound
			then			
				let vr_comp.date_closed = today
				let vr_comp.time_closed_h = extend(current, hour to hour)
				let vr_comp.time_closed_m = extend(current, minute to minute)
			end if

		when vr_comp.action_flag = "W"
			let vr_comp.dest_ref = vr_wo_h.wo_ref
			let vr_comp.dest_suffix = vr_wo_h.wo_suffix
			select wo_h_stat
				into vr_wo_h.wo_h_stat
			from wo_h
				where wo_h.wo_key = vr_wo_h.wo_key
			if skey_check("WO_STAT_ENHANCEMENTS", "ALL") = "Y"
			then
				select * into vl_wo_stat.* from wo_stat
					where wo_h_stat = vr_wo_h.wo_h_stat
				if vl_wo_stat.close_comp = "Y"
				then
					let vr_comp.date_closed = vr_wo_h.wo_date_compl
					let vr_comp.time_closed_h = extend
					(
						current,
						hour to hour
					)
					let vr_comp.time_closed_m = extend
					(
						current,
						minute to minute
					)
				end if
			else
				if vr_wo_h.wo_h_stat matches "[CX]"
				then
					let vr_comp.date_closed = vr_wo_h.wo_date_compl
					let vr_comp.time_closed_h = extend
					(
						current,
						hour to hour
					)
					let vr_comp.time_closed_m = extend
					(
						current,
						minute to minute
					)
				end if
			end if

		when vr_comp.action_flag = "I"		# This is not done properly yet
			let vr_comp.dest_ref = vr_diry.diry_ref
	end case

end function	# check_comp_cleared

{------------------------------------------------------------------------------}

function check_comp_exist(vg_progress)
	define
		vg_progress integer

	if not select_complain(vg_progress)
	then
		call valid_error("", 
			"The selected record has been deleted by another user", "")
		return false
	end if

	return true

end function	# check_comp_exist


function run_word(vl_complaint_no)
	define	vl_complaint_no,	
			DDEstatus	integer,
			mess,
			data,
			ExecStr		char(255),
			UserName	char(40)

	let UserName = get_user()
	let ExecStr = "c:\\\\Conten~1\\\\Startw~1\\\\starword.exe -tC -n", 
		vl_complaint_no, " -u", UserName
	let DDEstatus = WinExec( ExecStr )
	if DDEstatus = false 
	then
		call DDEGeterror() returning mess
		call fgl_winmessage( "DDE error", mess, "stop" )
	end if
end function	# run_word


FUNCTION WordAddLine( Text )
DEFINE	Text 		CHAR(128)
DEFINE	mess		CHAR (255)
DEFINE	DDEStatus	INTEGER

	CALL DDEPoke
	( 
		"winword", 
		"Document1", 
		"\\\\EndOfDoc", 
		Text 
	) RETURNING DDEstatus
	IF DDEstatus = FALSE THEN
		CALL DDEGeterror() RETURNING mess
		CALL fgl_winmessage( "DDE error poke", mess, "stop" )
	END IF

END FUNCTION	# WordAddLine


function print_comp_notice(vl_complaint_no)
	define 	
		print_action		char(1),
		vl_null				char(1),
		vl_cont_prmpt		char(1),
		vl_message			char(80),
		vl_tmp_char			char(80),
		vl_user				char(8),
		vl_device_name		like device_def.device_name,
		vl_device_str		like device_def.device_str,
		vl_complaint_no		like comp.complaint_no,
		vl_contract_ref		like comp.contract_ref,
		vl_contractor_ref	like comp_hway.contractor_ref,
		vl_default_status	like defh.default_status

	let vl_message = "Printing ", downshift(vg_record_title) clipped, " ",
		vl_complaint_no using "<<<<<<<<", ", Please Wait ..."

	if vr_comp.service_c = vg_hway_service
		and vg_hway_installation = "Y"
	then
		select contractor_ref 
			into vl_contractor_ref
		from comp_hway
			where complaint_no = vl_complaint_no
		
		if vl_contractor_ref = "TRANSPORTATION"
		then
			let vl_tmp_char = "exec fglgo_hway_pcomp ",
									vr_comp.contract_ref clipped, " z ", 
									vl_complaint_no using "<<<<<<<<"

			call mstart_wait(vl_message)
			call os_exec(vl_tmp_char, false)
			call end_wait()
			return
		end if
	end if

	# Do we use a menu to select the print destination
	if skey_check("PRINT_COMP_OPT", "ALL") = "N"  
	then
		# We dont so set print action to client only ( as before )

		let print_action = " "

		let vl_user = get_user()

		let vl_tmp_char = "fglgo_pcomp ", 
			vr_comp.contract_ref clipped, " z ", 
			vl_complaint_no using "<<<<<<<<"

		case vr_diry.action_flag
			when "D"
				if skey_check("TWO NOTICES", vr_comp.service_c) = "Y" 
				then   # Print complaint as well as default
					if skey_check("COMP_PRINTING_MENU", "ALL") = "Y"
					then
						call device_look(vg_comp_title)
							returning vl_device_name, vl_device_str
						call set_comp_options()

						let vl_tmp_char = vl_tmp_char clipped,
							" '", vl_device_name clipped, "'"
					end if
					call mstart_wait(vl_message)
					call os_exec(vl_tmp_char, false)
					call end_wait()
				end if

				let vl_tmp_char = "exec fglgo_def_prnt ",
					vr_si_i.contract_ref clipped, " ", 
					vr_defh.cust_def_no 

				if skey_check("PRINT_CLEARED_DEF", "ALL") = "N"
				then
					#check if the default is cleared
					select default_status
						into vl_default_status
					from defh
						where cust_def_no = vr_defh.cust_def_no
					
					if vl_default_status = "Y"
					then
						call mstart_wait(vl_message)
						call os_exec(vl_tmp_char, false) 
						call end_wait()
					end if
				else
					call mstart_wait(vl_message)
					call os_exec(vl_tmp_char, false) 
					call end_wait()
				end if

			when "W"
				if check_both_reps_comp_wo_key(vr_comp.service_c)
				then   # Print complaint as well as works order
					call mstart_wait(vl_message)
					call os_exec(vl_tmp_char, false)
					call end_wait()
				end if
				# ADJ MOVE WO PRINT
				if vg_sched_installation = "Y"
				and vr_comp.service_c = vg_sched_service
				and skey_check("SCHED_PRINT_WO", "ALL") = "N"
				then
					# Do not print schedule works orders.	
				else
					call print_works_order_notice(vr_comp.dest_ref,
												vr_comp.dest_suffix)
				end if

			when "E"
				# Print the original complaint.......
				call mstart_wait(vl_message)
				call os_exec(vl_tmp_char, false)
				call end_wait()

				# Now print the Enforcement complaint......
				select contract_ref into vl_contract_ref from comp
					where complaint_no = vr_diry.dest_ref
				let vl_tmp_char = "exec fglgo_pcomp ", 
				vl_contract_ref clipped, " z ", 
				vr_diry.dest_ref using "<<<<<<<<"
				call mstart_wait(vl_message)
				call os_exec(vl_tmp_char, false)
				call end_wait()

			otherwise
				call mstart_wait(vl_message)
				call os_exec(vl_tmp_char, false)
				call end_wait()
		end case
	else
		# Prompt the user for the type of print to do

		call complaint_print_confirm() returning print_action

		let vl_user = get_user()

		case
			when print_action = "C" 
				# client print

				let vl_tmp_char = "fglgo_pcomp ",
					vr_comp.contract_ref clipped, " C ", vl_complaint_no
				call mstart_wait(vl_message)
				call os_exec(vl_tmp_char, false)
				call end_wait()

			when print_action = "T"
				# contractor print
				#let vl_tmp_char = "exec fglgo_pcomp T ", vl_complaint_no

				let vl_tmp_char = "fglgo_pcompT ",
					vr_comp.contract_ref clipped, " T ", vl_complaint_no
				call mstart_wait(vl_message)
				call os_exec(vl_tmp_char, false)
				call end_wait()

			when print_action = "B" 
				# client print
				let vl_tmp_char = "fglgo_pcomp ",
					vr_comp.contract_ref clipped, " C ", vl_complaint_no
				call mstart_wait(vl_message)
				call os_exec(vl_tmp_char, false)
				call end_wait()

				# contractor print
				#let vl_tmp_char = "exec fglgo_pcomp T ", vl_complaint_no

				let vl_tmp_char = "fglgo_pcompT ",
					vr_comp.contract_ref clipped, " T ", vl_complaint_no
				call mstart_wait(vl_message)
				call os_exec(vl_tmp_char, false)
				call end_wait()
		end case

		case vr_diry.action_flag
			when "D"
				#ADJ REMOTE_PRINTING removal
				let vl_tmp_char = "exec fglgo_def_prnt ",
					vr_si_i.contract_ref clipped, " ", vr_defh.cust_def_no
				#ADJ REMOTE_PRINTING removal end

				if skey_check("PRINT_CLEARED_DEF", "ALL") = "N"
				then
					#check if the default is cleared
					select default_status
						into vl_default_status
					from defh
						where cust_def_no = vr_defh.cust_def_no
					
					if vl_default_status = "Y"
					then
						call mstart_wait(vl_message)
						call os_exec(vl_tmp_char, false) 
						call end_wait()
					end if
				else
					call mstart_wait(vl_message)
					call os_exec(vl_tmp_char, false) 
					call end_wait()
				end if

			when "W"
				# ADJ MOVE WO PRINT
				if vg_sched_installation = "Y"
				and vr_comp.service_c = vg_sched_service
				and skey_check("SCHED_PRINT_WO", "ALL") = "N"
				then
					# Do not print schedule works orders.	
				else
					call print_works_order_notice(vr_comp.dest_ref,
												vr_comp.dest_suffix)
				end if
		end case
	end if
	whenever error continue
	call end_wait()
	whenever error stop

end function	# print_comp_notice


function set_notice_type()

	define
		f_lookup_num like allk.lookup_num

	select lookup_num
		into f_lookup_num
		from allk
	where lookup_code = vr_comp.comp_code
		and lookup_func = "COMPLA"

	case f_lookup_num	# Set the notice type to default value
		when 1
			let vr_comp.notice_type = "O"

		when 2
			let vr_comp.notice_type = "P"

		otherwise
			let vr_comp.notice_type = "N"
	end case

end function	# set_notice_type


function display_item_info()
	define 	vl_item_info 	char(22),
			vl_comma		smallint,
			new_day			char(7),
			f_text			char(40)

	if not length(vr_comp.item_ref)
	then
		display "","","" to item_desc, item_info1, item_info2
		display "","" to rect_item_desc, rect_item_info1

#		if vr_comp.service_c = vg_nappy_service
#			and vg_nappy_installation = "Y"
#		then
			display "" to item_ref
			display "" to rect_item_ref
#		else
#			display "" to item_ref
#			display "" to rect_item_ref
#		end if
#		if vr_comp.service_c = vg_clin_service
#			and vg_clin_installation = "Y"
#		then
#			display "" to item_ref
#			display "" to rect_item_ref
#		else
#			display "" to item_ref
#			display "" to rect_item_ref
#		end if
		return
	else
		if vg_item_use_contract = "Y" then
			if length(vr_comp.contract_ref) 
			then
				select unique item_desc
					into f_text
				from item
					where item_ref = vr_comp.item_ref
					and service_c = vr_comp.service_c
					and contract_ref = vr_comp.contract_ref
			else
				select unique item_desc
					into f_text
				from item
					where item_ref = vr_comp.item_ref
					and service_c = vr_comp.service_c
					and contract_ref = vr_si_i.contract_ref
			end if
		else
			select unique item_desc
				into f_text
			from item
				where item_ref = vr_comp.item_ref
				and service_c = vr_comp.service_c
		end if
	end if

	let vl_comma = false

	call set_occur_day(vr_comp.occur_day)
		returning new_day

	if length(new_day)
	then
		if vl_comma
		then
			let vl_item_info = vl_item_info clipped, " Occ:",
				new_day clipped
		else
			let vl_item_info = "Occ:", new_day clipped
			let vl_comma = true
		end if
	end if

	if skey_check("DISPLAY ROUND_C", vr_comp.service_c) = "Y"
	then
		if vr_comp.round_c is not null
		then
			if vl_comma
			then
				let vl_item_info = vl_item_info clipped, " Rnd:", 
					vr_comp.round_c clipped
			else
				let vl_item_info = "Rnd:", vr_comp.round_c clipped
				let vl_comma = true
			end if
		end if
	else 
		if length(vr_si_i.pa_area)
		then
			if vl_comma
			then
				let vl_item_info = vl_item_info clipped, 
					" Ptl:", vr_si_i.pa_area
			else
				let vl_item_info = "Ptl:", vr_si_i.pa_area clipped
				let vl_comma = true
			end if
		end if
	end if

{
	if vr_comp.service_c = vg_nappy_service
		and vg_nappy_installation = "Y"
	then
		display by name vr_comp.item_ref
		display vr_comp.item_ref to rect_item_ref
	else
		display by name vr_comp.item_ref
		display vr_comp.item_ref to rect_item_ref
	end if
	if vr_comp.service_c = vg_clin_service
		and vg_clin_installation = "Y"
	then
}
		display by name vr_comp.item_ref
		display vr_comp.item_ref to rect_item_ref
		display vr_comp.item_ref to ert_item_ref
		display vr_comp.item_ref to meas_item_ref
		display vr_comp.item_ref to tree_item_ref
#	else
#		display by name vr_comp.item_ref
#		display vr_comp.item_ref to rect_item_ref
#		display vr_comp.item_ref to ert_item_ref
#		display vr_comp.item_ref to meas_item_ref
#		display vr_comp.item_ref to tree_item_ref
#	end if
	display f_text to item_desc
	display f_text to rect_item_desc
	display f_text to ert_item_desc
	display f_text to meas_item_desc
	display f_text to tree_item_desc

	if length(vl_item_info) < 12
	then
		display vl_item_info to item_info1
		display "" to item_info2
		display vl_item_info to rect_item_info1
		display vl_item_info to ert_item_info1
		display "" to ert_item_info2
		display vl_item_info to meas_item_info1
		display "" to meas_item_info2
		display vl_item_info to tree_item_info1
		display "" to tree_item_info2
	else
		call format_field(11,2,vl_item_info)
			returning vl_item_info[1,11],
						vl_item_info[12,22],
						vg_null_val, vg_null_val, vg_null_val
		display vl_item_info[1,11] to item_info1
		display vl_item_info[12,22] to item_info2
		display vl_item_info[1,11] to rect_item_info1
		display vl_item_info[1,11] to ert_item_info1
		display vl_item_info[12,22] to ert_item_info2
		display vl_item_info[1,11] to meas_item_info1
		display vl_item_info[12,22] to meas_item_info2
		display vl_item_info[1,11] to tree_item_info1
		display vl_item_info[12,22] to tree_item_info2
	end if
	initialize vg_null to null

end function	# display_item_info


function qrymenu_of()
	open window iw_menu at 1,1 with 2 rows, 79 columns
end function	# qrymenu_of


function qrymenu_cf()
	#ADJ GENERO
	#close window iw_menu
end function	# qrymenu_cf


function get_sl_info() 
	define
		vl_null,
		vl_none,
		vl_sc,
		vl_ac			smallint,
		vlr_disp_sl_sf			record 
			unit_no				like sl_sf.unit_no,
			furniture_desc		like sl_furniture.furniture_desc,
			unit_position		like sl_sf.unit_position,
			comp_code			like comp_sl.comp_code,
			repair_type			like sl_sf_hist.repair_type,
			out_of_lighting	char(1),
			sl_status			like comp_sl.sl_status
				end record,
		vlr_hidden_sl_sf		record
			inv_id				like sl_sf.inv_id,
			seq_no				smallint,
			lookup_text			like allk.lookup_text,
			sent_date			like comp_sl.sent_date,
			sent_time_h			char(5),
			sent_time_m			char(5)
				end record

	call get_site_pa_area(vr_comp.site_ref, vr_comp.service_c)
		returning vr_site.site_cat, vl_null
	display vr_site.site_cat to pa_area

	call vg_disp_sl_sf.clear()
	call vg_hidden_sl_sf.clear()

	declare c_sl_sf cursor for
		select sl_sf.unit_no, 
			sl_furniture.furniture_desc,
			sl_sf.unit_position,
			comp_sl.comp_code,
			sl_sf_hist.repair_type,
			comp_sl.out_of_lighting,
			comp_sl.sl_status,
			sl_sf.inv_id,
			comp_sl.seq_no,
			comp_sl.notes,
			comp_sl.sent_date,
			comp_sl.sent_time_h,
			comp_sl.sent_time_m
		from comp_sl, sl_sf, sl_furniture, sl_sf_hist
			where comp_sl.inv_id = sl_sf.inv_id
			and sl_sf.furniture_type = sl_furniture.furniture_type
			and comp_sl.complaint_no = vr_comp.complaint_no
			and sl_sf_hist.complaint_no = vr_comp.complaint_no
			and sl_sf_hist.inv_id = sl_sf.inv_id

	foreach c_sl_sf into vlr_disp_sl_sf.*, 
							vlr_hidden_sl_sf.*
		call vg_disp_sl_sf.appendelement()
		call vg_hidden_sl_sf.appendelement()
		let vg_sl_count = vg_disp_sl_sf.getlength()
		let vg_disp_sl_sf[vg_sl_count].* = vlr_disp_sl_sf.*
		let vg_hidden_sl_sf[vg_sl_count].* = vlr_hidden_sl_sf.*
{
		let vg_hidden_sl_sf[vg_sl_count].sent_time_h = 
			vg_hidden_sl_sf[vg_sl_count].sent_time_h[1,2]
		let vg_hidden_sl_sf[vg_sl_count].sent_time_m = 
			vg_hidden_sl_sf[vg_sl_count].sent_time_m[4,5]
}
		if vg_disp_sl_sf[vg_sl_count].out_of_lighting
		then
			let vg_disp_sl_sf[vg_sl_count].out_of_lighting = "Y"
		else
			let vg_disp_sl_sf[vg_sl_count].out_of_lighting = "N"
		end if
	end foreach
	let vg_sl_count = vg_disp_sl_sf.getlength()

{
	let vl_none = false
	if vg_sl_count = 0
	then
		let vl_none = true
		let vg_sl_count = 1
	end if

	display array vg_disp_sl_sf to sa_sl_sf.*
		before row
			exit display
	end display
}

	if not vg_sl_line
	and vg_sl_count
	then
		let vg_sl_line = 1
	end if
	if vg_sl_line > vg_sl_count
	then
		let vg_sl_line = vg_sl_count
	end if
	if vg_sl_line
	then
		display vg_hidden_sl_sf[vg_sl_line].inv_id, 
				vg_hidden_sl_sf[vg_sl_line].lookup_text,
				vg_hidden_sl_sf[vg_sl_line].sent_date,
				vg_hidden_sl_sf[vg_sl_line].sent_time_h,
				vg_hidden_sl_sf[vg_sl_line].sent_time_m
			to inv_id, 
				sl_fault_desc, 
				sent_date,
				sent_time_h,
				sent_time_m

		if skey_check("SL_ENHANCEMENTS","ALL") = "Y"
		then
			if vg_hidden_sl_sf[vg_sl_line].sent_date is null
			then
				display "WAITING" to sent_to_dw
			else
				display "SENT" to sent_to_dw
			end if
		else
			display "SENT" to sent_to_dw
		end if
	end if

{
	if vl_none
	then	
		let vg_sl_count = 0
		let vg_ac_line = 0
		let vg_sc_line = 0
	else
		let vg_ac_line = 1
		let vg_sc_line = 1
	end if
}
end function	# get_sl_info 


function get_gm_info()
	define	
		vl_comp_gm		record like comp_gm.*,
		vl_c_sf			record like c_sf.*,
		vl_c_si			record like c_si.*,
		vl_feature_desc	like feat.feature_desc,
		vl_item_desc	like item.item_desc

	select * into vl_comp_gm.* from comp_gm
		where complaint_no = vr_comp.complaint_no
	select * into vl_c_sf.* from c_sf where c_sf_id = vl_comp_gm.c_sf_id
	select * into vl_c_si.* from c_si where c_si_id = vl_comp_gm.c_si_id

	display by name
		vr_comp.comp_code,
		vl_c_sf.c_sf_id,
		vl_c_sf.c_sf_desc,
		vl_c_sf.c_sf_position,
		vl_c_si.c_si_id,
		vl_c_si.c_si_desc

	display vl_c_sf.feature_ref to gm_feature_ref
	display vl_c_si.item_ref to gm_item_ref

	select item_desc into vl_item_desc from item
		where item_ref = vl_c_si.item_ref
			and service_c = vr_comp.service_c
			and contract_ref = vr_comp.contract_ref
	display vl_item_desc to gm_item_desc

	select feature_desc into vl_feature_desc from feat
		where feature_ref = vl_c_sf.feature_ref
	display vl_feature_desc to feature_desc

	call display_comp_code_info()
end function


function get_ert_info()
	define
		vlr_comp_ert_tags	array[100] of record 
			tag				like comp_ert_tags.tag,
			username		like comp_ert_tags.username,
			doa				like comp_ert_tags.doa,
			details			like comp_ert_tags.details
		end record,
		vl_loop				smallint

	initialize vr_comp_ert to null

	select *
		into vr_comp_ert.*
	from comp_ert
		where complaint_no = vr_comp.complaint_no

	display by name vr_comp_ert.graffiti_sqmtr,
					vr_comp_ert.s12_notice_type,
					vr_comp_ert.s12_notice_date

	declare c_comp_ert_tags cursor for
		select tag, username, doa, details, seq_no
			from comp_ert_tags
		where complaint_no = vr_comp.complaint_no
			order by seq_no

	let vl_loop = 1
	foreach c_comp_ert_tags into vlr_comp_ert_tags[vl_loop].*
		let vl_loop = vl_loop + 1
	end foreach

	let vl_loop = vl_loop - 1
	call set_count(vl_loop)
	display array vlr_comp_ert_tags to sa_ert_tags.*
		before display
			exit display
	end display

end function


function get_tree_info()
	initialize vr_comp_tree.* to null

	select *
		into vr_comp_tree.*
	from comp_tree
		where complaint_no = vr_comp.complaint_no

	display by name vr_comp_tree.tree_ref

	# Species, Position etc
end function


function get_av_info() 
	define
		vl_status_ref		like comp_av_hist.status_ref,
		vl_status_desc		like allk.lookup_text,
		vl_class_desc		like av_class.class_desc,
		vl_null				smallint,
		vl_text				char(40),
		vl_loc_change		smallint,
		vl_off_change		smallint,
		vl_char_6			char(6)
	
	initialize vg_av_arr.* to null

	select car_id,
			generated_no,
			car_id,
			make_ref,
			model_ref,
			colour_ref,
			date_stickered,
			time_stickered_h,
			time_stickered_m,
			vehicle_class,
			officer_id,
			road_fund_flag,
			road_fund_valid,
			dho_rep,
			dho_cc_building,
			how_long_there,
			vin
		into vg_av_arr.car_id,
			vg_av_arr.generated_no,
			vg_av_arr.car_id,
			vg_av_arr.make_ref,
			vg_av_arr.model_ref,
			vg_av_arr.colour_ref,
			vg_av_arr.date_stickered,
			vg_av_arr.time_stickered_h,
			vg_av_arr.time_stickered_m,
			vg_av_arr.vehicle_class,
			vg_av_arr.officer_id,
			vg_av_arr.road_fund_flag,
			vg_av_arr.road_fund_valid,
			vg_av_arr.dho_rep,
			vg_av_arr.dho_cc_building,
			vg_av_arr.how_long_there,
			vg_av_arr.vin
		from comp_av
			where vr_comp.complaint_no = comp_av.complaint_no	

	display by name vg_av_arr.generated_no,
					vg_av_arr.car_id

	display by name vg_av_arr.date_stickered,
					vg_av_arr.time_stickered_h,
					vg_av_arr.time_stickered_m,
					vg_av_arr.vehicle_class,
					vg_av_arr.how_long_there,
					vg_av_arr.road_fund_flag,
					vg_av_arr.road_fund_valid,
					vg_av_arr.vin

	select class_desc into vl_class_desc
		from av_class
	where class_ref = vg_av_arr.vehicle_class

	display vl_class_desc to class_desc

	select make_desc into vg_av_arr.make_desc
		from makes
	where make_ref = vg_av_arr.make_ref

	display by name vg_av_arr.make_desc

	select unique (model_desc) into vg_av_arr.model_desc
		from models
	where model_ref = vg_av_arr.model_ref
		and make_ref = vg_av_arr.make_ref

	display by name vg_av_arr.model_desc

	select colour_desc into vg_av_arr.colour_desc
		from colour
	where colour_ref = vg_av_arr.colour_ref

	display by name vg_av_arr.colour_desc

	select initials, officer_name into 
		vg_av_arr.initials, vg_av_arr.officer_name
	from officers
		where officer_ref = vg_av_arr.officer_id

	display by name vg_av_arr.initials

	select count(*) into vl_loc_change
		from comp_av_hist
	where complaint_no = vr_comp.complaint_no
		and status_ref = "LOC_CH"	

	if vl_loc_change > 0
	then
		let vg_loc_change = true
		display "Y" to alt_location	
	else
		let vg_loc_change = false
		display "N" to alt_location	
	end if	
	
	select count(*) into vl_off_change
		from comp_av_hist
	where complaint_no = vr_comp.complaint_no
		and status_ref = "OFF_CH"	

	if vl_off_change > 0
	then
		let vg_off_change = true
		display "Y" to alt_officer	
	else
		let vg_off_change = false
		display "N" to alt_officer	
	end if	

	call display_av_status()
	call get_site_pa_area(vr_comp.site_ref,vr_comp.service_c)
		returning vr_site.site_cat, vl_null
	display vr_site.site_cat to pa_area
	let vl_text =
		get_allk_desc(vr_site.site_cat,"PATRL")
	display vl_text to pa_area_desc

# 1/10/3
	if skey_check("AV WO USED","ALL") = "Y" then
		let av_action_text = vr_comp.action_flag
		display	av_action_text,
				vr_comp.dest_ref, 
				vr_comp.dest_suffix, 
				vr_comp.date_closed,
				vr_comp.time_closed_h,
				vr_comp.time_closed_m
			to av_action_text,
				av_dest_ref,
				av_dest_suffix, 
				av_date_closed,
				av_time_closed_h,
				av_time_closed_m

	call display_comp_action_text()
#		display " " to result_flag
	end if

# Display Title "Car ID" as "Reg No"	 13/10/3
	let vl_char_6 = get_allk_desc("Car ID","AVCODE")
	if length(vl_char_6) > 0 then
		display vl_char_6 at 17, 2
	end if

end function	# get_av_info 


function get_sched_info()
	define	
		vlr_work_schedule	record like work_schedule.*,
		vlr_wo_type			record like wo_type.*,
		vl_wo_key			like wo_h.wo_key,
		vl_wo_h_stat		like wo_h.wo_h_stat,
		vl_wo_type_f		like wo_h.wo_type_f

	if vr_comp.action_flag = "H"
	or vr_comp.action_flag = "P"
	or vr_comp.action_flag = "N"
	then
		initialize vlr_work_schedule.* to null

		select wo_type_f
			into vl_wo_type_f
		from comp_sched
			where complaint_no = vr_comp.complaint_no

		call pop_comp_disp_collection_items()
			returning vlr_work_schedule.waste_type, 
						vlr_work_schedule.quantity, 
						vg_null, vg_null
	else
		select wo_key, wo_h_stat, wo_type_f
			into vl_wo_key, vl_wo_h_stat, vl_wo_type_f
		from wo_h
			where wo_h.wo_ref = vr_comp.dest_ref 
			and wo_h.wo_suffix = vr_comp.dest_suffix

		select *
			into vlr_work_schedule.* 
		from work_schedule
			where work_schedule.wo_key = vl_wo_key
	end if

	select wo_type.* 
		into vlr_wo_type.* 
	from wo_type
		where wo_type.wo_type_f = vl_wo_type_f

	display by name vlr_wo_type.wo_type_f, 
					vlr_wo_type.wo_type_desc,
					vlr_work_schedule.collection_date,
					vlr_work_schedule.schedule_ref,
					vlr_work_schedule.quantity,
					vlr_work_schedule.waste_type

	if vg_weee_installation = "N"
	then
		display vl_wo_h_stat to wo_h_stat
	end if

end function	# get_sched_info


function get_weee_sched_info()

define	vlr_work_schedule	record like work_schedule.*
define	vlr_wo_type			record like wo_type.*

	select work_schedule.* into vlr_work_schedule.* from work_schedule, wo_h
		where work_schedule.wo_key = wo_h.wo_key and
		wo_h.wo_ref = vr_comp.dest_ref and
		wo_h.wo_suffix = vr_comp.dest_suffix

	select wo_type.* into vlr_wo_type.* from wo_type, wo_h
		where wo_type.wo_type_f = wo_h.wo_type_f and
		wo_h.wo_ref = vr_comp.dest_ref and
		wo_h.wo_suffix = vr_comp.dest_suffix

	display by name vlr_wo_type.wo_type_f, vlr_wo_type.wo_type_desc
	display by name
		vlr_work_schedule.collection_date,
		vlr_work_schedule.schedule_ref,
		vlr_work_schedule.quantity,
		vlr_work_schedule.waste_type
	display vlr_work_schedule.location to exact_location

end function	# get_weee_sched_info


function get_nappy_info()
	define
		vr_nappy_site		record like nappy_site.*,
		vr_nappy_item		record like nappy_item.*,
		vl_diry_ref			like diry.diry_ref,
		vl_user				like diry.dest_user,
		vl_location_name	like comp.location_name,
		vl_location_desc	like comp.location_desc,
		vl_nappy_site		like customer.compl_build_name,
		vl_nappy_ref		like nappy_site.nappy_ref,
		vl_agreement_no		like agreement.agreement_no,
		vl_area_name 		like area.area_name,
		new_day				char(7),
		vl_rec_count,		# count No. occurences of location_name
		locn_length,
		vl_null,
		vl_cont_prmpt		char(1)

	select * into vr_nappy_site.*, vr_comp_nappy.*
		from nappy_site, comp_nappy
	where nappy_site.nappy_ref = comp_nappy.nappy_ref
		and comp_nappy.complaint_no = vr_comp.complaint_no

	 declare c_nappyy cursor for
		select si_i.*
			from si_i, item
		where site_ref = vr_nappy_site.site_ref
			and item.service_c = vg_nappy_service 
			and si_i.contract_ref = vr_comp.contract_ref
			and si_i.item_ref = item.item_ref

	foreach c_nappyy into vr_si_i.*
	end foreach
 
{
	display by name
		vr_nappy_site.receive_name,
		vr_nappy_site.nappy_ref
}
	display vr_nappy_site.receive_name to nappy_site.receive_name
	display vr_nappy_site.nappy_ref to nappy_site.nappy_ref
 
	display by name
		vr_nappy_site.chargeable,
		vr_nappy_site.receive_phone_no,
		vr_nappy_site.receive_fax_no,
		vr_nappy_site.receive_email,
		vr_nappy_site.current_status

	display "" to receive_mobile

	case vr_nappy_site.current_status
		when "L"
			display "LIVE  " to status_desc1
		when "C"
			display "CLOSED" to status_desc1
		otherwise
			display "      " to status_desc1
	end case
end function	# get_nappy_info


function get_clin_info()
	define
		vr_clin_site		record like clin_site.*,
		vr_clin_item		record like clin_item.*,
		vl_diry_ref			like diry.diry_ref,
		vl_user				like diry.dest_user,
		vl_location_name	like comp.location_name,
		vl_location_desc	like comp.location_desc,
		vl_clin_site		like customer.compl_build_name,
		vl_clinical_ref		like clin_site.clinical_ref,
		vl_agreement_no		like agreement.agreement_no,
		vl_area_name 		like area.area_name,
		new_day				char(7),
		vl_rec_count,		# count No. occurences of location_name
		locn_length,
		vl_null,
		vl_cont_prmpt		char(1),
		vl_status_desc		like allk.lookup_text

	select * into vr_clin_site.*, vr_comp_clin.*
		from clin_site, comp_clin
	where clin_site.clinical_ref = comp_clin.clinical_ref
		and comp_clin.complaint_no = vr_comp.complaint_no

	declare c_conty cursor for
		select si_i.* 
			from si_i, item
		where site_ref = vr_clin_site.site_ref
			and service_c = vg_clin_service
			and si_i.item_ref = item.item_ref
			and si_i.contract_ref = vr_comp.contract_ref
	foreach c_conty into vr_si_i.*
	end foreach
 
	display by name
		vr_clin_site.receive_name,
		vr_clin_site.clinical_ref
 
	display by name
		vr_clin_site.chargeable,
		vr_clin_site.receive_phone_no,
		vr_clin_site.receive_fax_no,
		vr_clin_site.receive_email,
		vr_clin_site.current_status

	display "" to receive_mobile

	select lookup_text into vl_status_desc from allk
		where lookup_func = "CLSTAT" and
		lookup_code = vr_clin_site.current_status
	if vr_clin_site.current_status = "L" then
		display vl_status_desc to status_desc1
			attribute(green, reverse)
	else
		if vr_clin_site.current_status = "C" then
			display vl_status_desc to status_desc1
				attribute(red, reverse)
		else
			if vr_clin_site.current_status = "S" then
				display vl_status_desc to status_desc1
					attribute(yellow, reverse)
			else
				display vl_status_desc to status_desc1
			end if
		end if
	end if

end function	# get_clin_info


function show_attach_flag()
	define 
		vl_attach_count	smallint

	#current window is iw_fastcomp

    IF vg_replication = "N"
    THEN
        select count(*) into vl_attach_count
            from attachments
        where type = "C"
            and source_no = vr_comp.complaint_no
    ELSE
        LET vl_attach_count = 0
    END IF

    if vl_attach_count
	then
		display vl_attach_count to attachment_flag attribute(yellow, reverse)
        LET va_attachment_flag[1].attachment_flag=vl_attach_count
        LET va_attachment_flag_color[1].attachment_flag="yellow reverse"
	else
		display vl_attach_count to attachment_flag
        LET va_attachment_flag[1].attachment_flag=vl_attach_count
        LET va_attachment_flag_color[1].attachment_flag=""
	end if
end function	# show_attach_flag


function change_comp_inspection(vp_comp_no)
	define 	vl_insp_date	date,
			vp_comp_no		like comp.complaint_no,
			vl_change_flag	smallint,
			vl_offset		like keys.n_field

	let vl_offset = skey_check("DEFAULT_INSP_DATE","ALL")
	let vl_change_flag = false
	let int_flag = false

	select *
		into vr_diry.*
	from diry
		where source_flag = "C"
		and source_ref = vp_comp_no

	if vr_diry.inspect_ref is null
	then
#		open window iw_comp_insp at 8,35 with form "comp_insp"
		open window iw_comp_insp with form "comp_insp"

{
--#		IF fgl_fglgui() THEN
--#			DISPLAY "OK" TO btok
#--#			DISPLAY "Cancel" TO btcan #cancel
--#			DISPLAY "Change Action" TO btch
--#		END IF
}
		if vr_diry.date_due < today
		then
			let vr_diry.date_due = today + vl_offset
		end if

		input vr_diry.date_due without defaults 
			from insp_date

			after field insp_date
				let vr_diry.date_due = get_fldbuf(insp_date)
				if not length(vr_diry.date_due)
				or vr_diry.date_due is null
				then
					call valid_error("","A valid date must be entered","")
					next field insp_date
				end if

			on action cancel
				let int_flag = true
				exit input

			on action close
				let int_flag = true
				exit input

			on action changeaction
				let vl_change_flag = true	
				exit input

#			on action accept
			after input
#				let vr_diry.date_due = get_fldbuf(insp_date)
				if vr_diry.date_due < today
				then
					call valid_error("","Date cannot be in the past","")
					let vr_diry.date_due = today + vl_offset
					next field insp_date
				end if
				let vl_change_flag = false
				exit input

		end input

		close window iw_comp_insp

		if vl_change_flag = true
		then
			return true	
		end if			

		if int_flag
		then
			let int_flag = false
			return false
		else
			update comp set action_flag = "I"
				where complaint_no = vp_comp_no

			update diry
				set date_due = vr_diry.date_due,
				action_flag = "I"
			where diry_ref = vr_diry.diry_ref
		end if

	else
		call valid_error("",
			"The selected destination cannot be updated", "")
	end if

	return false

end function	# change_comp_inspection


function change_action()
	define
		vl_comp_code		char(10)

	let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
	case
		when vg_ms_installation = "Y"
		and vg_ms_fault_codes matches vl_comp_code
		and length(vr_comp.comp_code)
			call populate_action_combo
				(
				"U",
				"ADWHPIN",
				"meas_action_text"
				)

			let meas_action_text = vr_comp.action_flag
			input by name meas_action_text without defaults
			let vr_comp.action_flag = meas_action_text

		when vr_comp.service_c = vg_agreq_service
		and vg_agreq_installation = "Y"
			call populate_action_combo
				(
				"U", 
				"HPRIN", 
				"agreq_action_text"
				)

			let agreq_action_text = vr_comp.action_flag
			input by name agreq_action_text without defaults
			let vr_comp.action_flag = agreq_action_text

		when vr_comp.service_c = vg_av_service
		and vg_av_installation = "Y"
			call populate_action_combo
				(
				"U", 
				"WXHPIN",
				"av_action_text"
				)

			let av_action_text = vr_comp.action_flag
			input by name av_action_text without defaults
			let vr_comp.action_flag = av_action_text

		when vr_comp.service_c = vg_gm_service
		and vg_gm_installation = "Y"
			call populate_action_combo
				(
				"U", 
				"ADWXHPIN",
				"gm_action_text"
				)

			let gm_action_text = vr_comp.action_flag
			input by name gm_action_text without defaults
			let vr_comp.action_flag = gm_action_text

		when vr_comp.service_c = vg_ert_service
		and vg_ert_installation = "Y"
		and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
			call populate_action_combo
				(
				"U", 
				"ADWXHPIN",
				"ert_action_text"
				)

			let ert_action_text = vr_comp.action_flag
			input by name ert_action_text without defaults
			let vr_comp.action_flag = ert_action_text

		when vr_comp.service_c = vg_trade_service
		and vg_trade_installation = "Y"
			call populate_action_combo
				(
				"U", 
				"ADWXHPIN",
				"trade_action_text"
				)

			let trade_action_text = vr_comp.action_flag
			input by name trade_action_text without defaults
			let vr_comp.action_flag = trade_action_text

		when vr_comp.service_c = vg_trees_service
		and vg_trees_installation = "Y"
			call populate_action_combo
				(
				"U", 
				"ADWXHPIN",
				"tree_action_text"
				)

			let tree_action_text = vr_comp.action_flag
			input by name tree_action_text without defaults
			let vr_comp.action_flag = tree_action_text

		when vr_comp.service_c = vg_sched_service
		and vg_sched_installation = "Y"
			call populate_action_combo
				(
				"U", 
				"ADWXHPIN",
				"sched_action_text"
				)

			let sched_action_text = vr_comp.action_flag
			input by name sched_action_text without defaults
			let vr_comp.action_flag = sched_action_text

		otherwise
			call populate_action_combo
				(
				"U",
				"ADWXHPIN",
				"generic_action_text"
				)

			let generic_action_text = vr_comp.action_flag
			input by name generic_action_text without defaults
			let vr_comp.action_flag = generic_action_text
	end case

	return vr_comp.action_flag
end function


function display_allocated_inspection()
end function	# display_allocated_inspection


function update_hold_complain()			# Update the comp table
	define
		f_comp_destination	record
			destination			like comp_destination.destination,
			destination_date	like comp_destination.destination_date
					end record,
		vl_date_entered		like comp.date_entered,
		vl_sav_site_ref		like site.site_ref,
		vl_diry_ref			like diry.diry_ref,
		vl_user				like diry.dest_user,
		vl_build_no			like comp.build_no,
		vl_build_name		like comp.build_name,
		vl_location_name	like comp.location_name,
		vl_location_desc	like comp.location_desc,
		vl_item_ref			like comp.item_ref,
		vl_postcode			like comp.postcode,
		vl_comp_cde			like comp.comp_code,
		vl_orig_comp_code	like comp.comp_code,
		vl_site_ref			like site.site_ref,
		vl_addr_exists,		
		locn_length,
		vl_count,
		vl_rec_count,			# count No. occurences of location_name
		from_location_name,
		locn_rec_defined,
		site_rec_defined,
		vl_serv_cnt,
		vl_ignore_flag,
		si_i_rec_defined	smallint,
		remarks_line		char(210),
		vl_tmp_char			char(80),
		vl_mess				char(75),
		vl_district			char(40),
		temp_desc			char(20),
		f_lastfield,
		vl_comp_char,
		temp_code			char(12),
		vl_time_h,
		vl_time_m			char(2),
		vl_hours			char(2),
		vl_mins				char(2),
		print_action,
		vl_null,
		vl_exit_flag 		char(1),
		vl_cont_prmpt		char(1),
		vl_ans 				char(1),
		vl_search			char(100),
		vl_cc_flag			char(1),
		vl_act_flag,
		vl_act_flag_save	like comp.action_flag,
		vl_lookup_text		like allk.lookup_text

	let vl_orig_comp_code = vr_comp.comp_code
	initialize vg_null to null

#	message "Press ESC to update record data; Interrupt(Ctrl C) to abort"
	
	let int_flag = false
	let vg_f3_pressed = true
	let	vl_sav_site_ref	= vr_comp.site_ref
	let vl_act_flag_save = vr_comp.action_flag
	let vl_date_entered = vr_comp.date_entered
	let vl_hours = vr_comp.ent_time_h
	let vl_mins = vr_comp.ent_time_m

	let f_comp_destination.destination = 
		vr_comp_destination.destination
	let f_comp_destination.destination_date = 
		vr_comp_destination.destination_date
{
    let remarks_line = vr_comp.details_1 clipped, # " ",
						vr_comp.details_2 clipped, # " ",
						vr_comp.details_3 clipped
}                        
    let remarks_line = form_remarks(vr_comp.details_1, vr_comp.details_2, vr_comp.details_3) 
	display vr_comp.complaint_no to complaint_no
	call populate_action_combo
		(
		"U",
		"ADWXHPIN",
		"generic_action_text"
		)
	let generic_action_text = vr_comp.action_flag
	
	call before_update_correspond()
#	call gl_showpage("fold","generic_page")

	input by name vr_comp.date_entered,
				vr_comp.ent_time_h,
				vr_comp.ent_time_m,
				vr_comp.recvd_by,
				vr_comp.build_no,
				vr_comp.build_name,
				vr_comp.location_name,
				vr_comp.location_desc,
				vr_comp.postcode,
				vr_comp.exact_location,
				vr_customer.compl_init,
				vr_customer.compl_name,
				vr_customer.compl_surname,
				vr_customer.compl_phone,
				vr_comp_clink.cust_satisfaction,
				vr_customer.int_ext_flag,
				vr_comp.item_ref,
				vr_comp.comp_code,
				remarks_line,
				generic_action_text,
				vr_customer.compl_business,
				vr_customer.compl_postcode,
				vr_customer.compl_build_no,
				vr_customer.compl_build_name,
				vr_customer.compl_addr2,
				vr_customer.compl_addr3,
				vr_customer.compl_addr5,
				vr_customer.compl_addr6,
				vr_customer.compl_addr4,
				vr_customer.compl_fax,
				vr_customer.compl_email,
				vr_customer.compl_mobile,
				vr_comp_correspond.corr_entered,
				vr_comp_correspond.date_due,
				vr_comp_correspond.date_response,
				vr_comp_correspond.assigned_to
				without defaults

		before INPUT
			if skey_check("ALLOW_COMP_BACKDATE", "ALL") = "N"
			then
				call dialog.setFieldActive("date_entered", false)
				call dialog.setFieldActive("ent_time_h", false)
				call dialog.setFieldActive("ent_time_m", false)
			end if
            IF NOT check_install("BSP")
            THEN
                call dialog.setActionHidden("bsp", true)
                call dialog.setActionActive("bsp", false)
            END IF 
            IF NOT check_install("GIS")
            THEN
                call dialog.setActionHidden("gis", true)
                call dialog.setActionActive("gis", false)
            END IF 
            

		on key(control-t)
			call complaint_history()
			call disp_complaint_history_text()

		on action cancel
			let vg_title = "Abort ", vg_comp_title clipped, " Update"
			if continue_yn(vg_title)
			then
				let int_flag = true
				exit input
			end if

		on action close
			let vg_title = "Abort ", vg_comp_title clipped, " Update"
			if continue_yn(vg_title)
			then
				let int_flag = true
				exit input
			end if

		on action f2_lookup
			let vr_comp.build_no = get_fldbuf(build_no)
			let vr_comp.build_name = get_fldbuf(build_name)
			let vr_comp.location_name = get_fldbuf(location_name)
			let vr_comp.location_desc = get_fldbuf(location_desc)
			let vr_comp.item_ref = get_fldbuf(item_ref)
			case
				when infield(assigned_to)
					call correspond_assign_lookup()
				when infield(recvd_by)
					call allk_look("CTSRC", "", "Y") returning vr_comp.recvd_by
					display vr_comp.recvd_by to recvd_by
					next field recvd_by

				when infield(postcode)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"P",
												true)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"P",
												true)
								returning vl_site_ref
						end if

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_postcode = "NULL" 
						else 
							let vl_postcode = vr_comp.postcode 
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
							#call disp_hist_message()
						end if 
						call set_comp_options()
						next field postcode
					end if

				when infield(build_no)
					if vg_property_on 
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"B#",
												true)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"B#",
												true)
								returning vl_site_ref
						end if

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_build_no = "NULL" 
						else 
							let vl_build_no = vr_comp.build_no 
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
							#call disp_hist_message()
						end if 
						call set_comp_options()
						next field build_no
					end if

				when infield(build_name)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"BN",
												true)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"BN",
												true)
								returning vl_site_ref
						end if

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_build_name = "NULL" 
						else 
							let vl_build_name = vr_comp.build_name 
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
							#call disp_hist_message()
						end if 

						call set_comp_options()
						next field build_name
					end if

				when infield(location_name)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"L",
												true)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"L",
												true)
								returning vl_site_ref
						end if

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_location_name = "NULL" 
						else 
							let vl_location_name = vr_comp.location_name 
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
							#call disp_hist_message()
						end if 

						call set_comp_options()
						next field location_name
					else
						call clocn_look(vg_null, vr_comp.service_c)
							returning vr_comp.location_name,
									vr_comp.location_c,
									vr_comp.site_ref,
									vr_comp.location_desc,
									vl_district
						call set_comp_options()

						let locn_length = length(vr_comp.location_desc)

						call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null

					end if

				when infield(location_desc)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(	vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"L",
												true)
								returning vl_site_ref
						else
							call postcode_look(	vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"L",
												true)
								returning vl_site_ref
						end if

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_location_desc = "NULL" 
						else 
							let vl_location_desc = vr_comp.location_desc
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
							#call disp_hist_message()
						end if 

						call set_comp_options()
						next field location_name
					else
						call real_site_look(vr_comp.service_c, vl_null, vl_null)
							returning vr_comp.location_desc, vr_comp.site_ref

						select locn.location_c,
								locn.location_name,
								site.site_name_2
							into vr_comp.location_c,
								vr_comp.location_name,
								vl_district
							from locn, site
							where locn.location_c = site.location_c
							and site.site_ref = vr_comp.site_ref
						let locn_length = length(vr_comp.location_desc)

						if vl_district is not null and vl_district[1] != " "
							and locn_length < 20
						then
							let vl_district = draw_down_area_c(locn_rec_defined,
															vr_comp.location_c)
						end if

						call set_comp_options()
						call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
					end if

				when infield(compl_init)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(1)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_name)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(2)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_surname)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(3)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_business)
				or infield(compl_postcode)
				or infield(compl_build_no)
				or infield(compl_build_name)
				or infield(compl_addr2)
				or infield(compl_addr3)
				or infield(compl_addr4)
				or infield(compl_addr5)
				or infield(compl_addr6)
				or infield(compl_fax)
				or infield(compl_email)
				or infield(compl_mobile)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(4)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_query_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if
					next field compl_name

				when infield(item_ref)
					if not length(vr_comp.site_ref)
					then
						call item_look("","", vr_comp.service_c)
							returning vr_comp.item_ref, vg_null
						call set_comp_options()
						call display_item_info()
					else
#						call get_comp_site_items(true)
						if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
						then
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
						else
							call get_comp_site_items(true)
								returning vg_null, vg_null, vg_null, vg_null
						end if
 					end if
					next field item_ref

				when infield(comp_code)
					let vr_comp.comp_code = list_flt_codes
									(vr_comp.service_c, vr_comp.item_ref, "Y", "")
					call set_comp_options()
					call set_notice_type()
					call display_comp_code_info()
					next field comp_code

				otherwise
					call valid_error("","No lookup available on this field","")
			end case

		{
		on action Customer
			# ADJ V5
			# This is where the complainant information screen should be 
			# available

			let vr_comp.recvd_by = get_fldbuf(recvd_by)
			let vr_comp.postcode = get_fldbuf(postcode)
			let vr_comp.build_no = get_fldbuf(build_no)
			let vr_comp.build_name = get_fldbuf(build_name)
			let vr_comp.location_name = get_fldbuf(location_name)
			let vr_comp.location_desc = get_fldbuf(location_desc)
			let vr_comp.exact_location = get_fldbuf(exact_location)
			let vr_customer.compl_init = get_fldbuf(compl_init)
			let vr_customer.compl_name = get_fldbuf(compl_name)
			let vr_customer.compl_surname = get_fldbuf(compl_surname)
			let vr_customer.compl_phone = get_fldbuf(compl_phone)
			let vr_comp_clink.cust_satisfaction = get_fldbuf(cust_satisfaction)
			let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
			let vr_comp.item_ref = get_fldbuf(item_ref)
			let vr_comp.comp_code = get_fldbuf(comp_code)

			call display_add_comp_info(false)

			if not vg_f3_pressed
			then
				let vg_f3_pressed = true
				let vr_customer.compl_postcode = vr_comp.postcode
				let vr_customer.compl_build_no = vr_comp.build_no
				let vr_customer.compl_build_name = vr_comp.build_name
				let vr_customer.compl_site_ref = vr_comp.site_ref
			end if

			if not add_complainant(true, false, "U")
			then
				call display_add_comp_info(true)

				let vg_title = "Abort new ", 
					downshift(vg_comp_title) clipped, " entry"
				if continue_yn(vg_title)
				then
					call reset_text()
					let int_flag = true
					exit input
				end if
			else
				call display_add_comp_info(true)
			end if
			}

		#ADJ GENERO
		{
		on key(f6)
			call join()
			call set_comp_options()
		}

		on action History
			let vr_comp.location_name = get_fldbuf(location_name)
			let vr_comp.location_desc = get_fldbuf(location_desc)
			if field_touched(build_no)
			then
				let vr_comp.build_no = get_fldbuf(build_no) 
				if not length(vr_comp.build_no)
				then
					initialize vr_comp.build_no to null
				end if
			else
				initialize vr_comp.build_no to null
			end if
			if field_touched(build_name)
			then
				let vr_comp.build_name = get_fldbuf(build_name)
				if not length(vr_comp.build_name)
				then
					initialize vr_comp.build_name to null
				end if
			else
				initialize vr_comp.build_name to null
			end if
			if length(vr_comp.location_name)
			then
				let vg_comp_save.* = vr_comp.*
				let vg_customer_save.* = vr_customer.*
				call history_save_text(true)	
				let m_comp_arr_count = 0

				call prompt_for_scroll(false,"L")

				let vr_comp.* = vg_comp_save.*
				let vr_customer.* = vg_customer_save.*
				call history_save_text(false)	
			else
				call valid_error("",
					"A valid location must be entered to view the history.",
					"")	
			end if
			let vg_show_source = false
			let vg_action_type = true

{
		on action Text
			call text_yes_no()
}
        ON ACTION bsp
            CALL view_bsp(vr_comp.service_c, vr_comp.item_ref, vr_comp.comp_code)

        ON ACTION gis
            CALL view_gis(vr_comp.site_ref, vr_comp.service_c, vr_comp.item_ref, vr_comp.comp_code)
            
		after field date_entered
			if length(vr_comp.date_entered)
			then
				if vr_comp.date_entered < (vl_date_entered - 7) 
				then
					call valid_error("", 
"The date entered cannot be backdated more than seven days from original date", 
						"")
					next field date_entered
				end if	
				if vr_comp.date_entered > vl_date_entered
				then
					call valid_error("", 
				"The date entered cannot exceed the original date", 
						"")
					next field date_entered
				end if
			else
				call valid_error("", "A valid date must be entered", "")
				next field date_entered
			end if

		after field ent_time_h
			if length(vr_comp.ent_time_h) then
				if vr_comp.date_entered = vl_date_entered
				then
					if vr_comp.ent_time_h > vl_hours
					then
						call valid_error("",
							"The time entered cannot exceed the original time", 
							"")
						next field ent_time_h
					end if
				end if
			else
				call valid_error("", "A valid time must be entered", "")
				next field ent_time_h
			end if


		after field ent_time_m
			if length(vr_comp.ent_time_m) then
				if vr_comp.date_entered = vl_date_entered
				then
					if vr_comp.ent_time_h = vl_hours
					then
						if vr_comp.ent_time_m > vl_mins
						then
							call valid_error("",
								"The time entered cannot exceed the original time", 
								"")
							next field ent_time_m
						end if
					end if
				end if
			else
				call valid_error("", "A valid time must be entered", "")
				next field ent_time_m
			end if


		after field corr_entered
			if not after_field_correspond("date_entered","U") then
				next field corr_entered
			end if
		after field date_due
			if not after_field_correspond("date_due","U") then
				next field date_due
			end if
		after field date_response
			if not after_field_correspond("date_response","U") then
				next field date_response
			end if
		after field assigned_to
			if not after_field_correspond("assigned_to","U") then
				next field assigned_to
			end if

 		after field recvd_by
 			if length(vr_comp.recvd_by)
 			then
 				let vl_search = "lookup_func = 'CTSRC' and lookup_code = '", 
 					vr_comp.recvd_by clipped, "'", "and status_yn = 'Y'"

 				if no_of_rows("allk", vl_search, "") = 0
				then
 					let vl_mess = " The source code ", vr_comp.recvd_by clipped,
 						" does not exist"
					call valid_error("", vl_mess, "")		
					next field recvd_by
				end if
				initialize vl_lookup_text to null
				select lookup_text into vl_lookup_text from allk
					where lookup_func = "CTSRC"
					and lookup_code = vr_comp.recvd_by
				display vl_lookup_text to lookup_char
			end if

		before field postcode
			if vr_comp.postcode is null 
			then 
				let vl_postcode = "NULL" 
			else 
				let vl_postcode = vr_comp.postcode 
			end if 

		after field postcode
			if vr_comp.postcode is not null
			then
				if vl_postcode != vr_comp.postcode
				then
					if vg_property_on
					then
						# The postcode has changed .. we should perform an
						# automatic lookup on this postcode
						
						call postcode_look(vr_comp.postcode, 
											 "", "", "", "", true, "P", true)
							returning vl_site_ref

						call set_comp_options()

						call find_and_display_property(vl_site_ref, true)

						if not length(vl_site_ref)
						then
							let vr_comp.site_ref = null
							let vr_comp.location_c = null
							next field postcode
						else
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
							#call disp_hist_message()
						end if
					end if
				end if
			end if

		before field build_no
			if vr_comp.build_no is null 
			then 
				let vl_build_no = "NULL" 
			else 
				let vl_build_no = vr_comp.build_no 
			end if 

		after field build_no
			if vr_comp.build_no is not null
			then
				if vl_build_no != vr_comp.build_no
				then
					if vg_property_on
					then
#						if length(vr_comp.postcode) 
						if length(vr_comp.location_name)
						then
							if length(vr_comp.location_desc)
							and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
							then
								call postcode_look("",
													vr_comp.build_no,
													#vr_comp.build_name,
													"",
													vr_comp.location_desc,
													vr_comp.service_c,
													true,
													"B#", 
													true)
								returning vl_site_ref
							else
								call postcode_look("",
													vr_comp.build_no,
													#vr_comp.build_name,
													"",
													vr_comp.location_name,
													vr_comp.service_c,
													true,
													"B#", 
													true)
									returning vl_site_ref
							end if

							call set_comp_options()

							if length(vl_site_ref)
							then
								call find_and_display_property(vl_site_ref,true)
								call get_comp_site_items(false)
									returning vg_null, vg_null, vg_null, vg_null
								#call disp_hist_message()
							else
								let vr_comp.site_ref = null
								let vr_comp.location_c = null
								next field build_no
							end if
						end if
					end if

					if not vg_f3_pressed
					then
						if skey_check
							("SELECTIVE_DRAWDOWN", vr_comp.service_c) = "Y"
						then #copy down house number if it starts with a numeric
							if vr_comp.build_no[1] matches "[0-9]"
							then
								let vr_customer.compl_build_no = vr_comp.build_no
							else
								let vr_customer.compl_build_no = ""
							end if
						else
							let vr_customer.compl_build_no = vr_comp.build_no
						end if
					end if
				end if
			end if

		before field build_name
			if vr_comp.build_name is null 
			then 
				let vl_build_name = "NULL" 
			else 
				let vl_build_name = vr_comp.build_name
			end if 

		after field build_name
			if vr_comp.build_name is not null
			then
				if vr_comp.build_name != vl_build_name
				then
					if vg_property_on	
					then
						if length(vr_comp.location_name)
						then
							if length(vr_comp.location_desc)
							and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
							then
								call postcode_look("",
													"",
													vr_comp.build_name,
													vr_comp.location_desc,
													vr_comp.service_c,
													true,
													"BN", 
													true)
									returning vl_site_ref
								else
									call postcode_look("",
														"",
														vr_comp.build_name,
														vr_comp.location_name,
														vr_comp.service_c,
														true,
														"BN", 
														true)
										returning vl_site_ref
							end if

							call set_comp_options()

							if length(vl_site_ref)
							then
								call find_and_display_property(vl_site_ref,true)
								call get_comp_site_items(false)
									returning vg_null, vg_null, vg_null, vg_null
								#call disp_hist_message()
							else
								let vr_comp.site_ref = null
								let vr_comp.location_c = null
								next field build_name
							end if
						end if	
					end if

					if not vg_f3_pressed
					then
						let vr_customer.compl_build_name = vr_comp.build_name
					end if
				end if
			end if

      before field location_name 
			if vr_comp.location_name is null 
			then 
				let vl_location_name = "NULL" 
			else 
				let vl_location_name = vr_comp.location_name 
			end if 

		after field location_name
			if vr_comp.location_name is not null
			then
				if vl_location_name != vr_comp.location_name
				then
					if vg_property_on
					then
						if length(vr_comp.build_no) 
							or length(vr_comp.build_name)
						then
							if length(vr_comp.location_desc)
							and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
							then
								call postcode_look(vr_comp.postcode,
													vr_comp.build_no,
													vr_comp.build_name,
													vr_comp.location_desc,
													vr_comp.service_c,
													true,
													"L", 
													true)
									returning vl_site_ref
							else
								call postcode_look(vr_comp.postcode,
													vr_comp.build_no,
													vr_comp.build_name,
													vr_comp.location_name,
													vr_comp.service_c,
													true,
													"L", 
													true)
								returning vl_site_ref
							end if

							call set_comp_options()

							if length(vl_site_ref)
							then
								call find_and_display_property(vl_site_ref,true)
								call get_comp_site_items(false)
									returning vg_null, vg_null, vg_null, vg_null
								#call disp_hist_message()
							else
								let vr_comp.site_ref = null
								let vr_comp.location_c = null
								next field location_name
							end if
						else
							select count(*) 
								into vl_rec_count
							from locn
								where location_name = vr_comp.location_name

							case vl_rec_count 
								when 0
									call valid_error("",
										"A valid road name must be entered", "")
									next field location_name
								when 1
									select locn.* into vr_locn.*
										from locn 
									where location_name = vr_comp.location_name

									select site.* into vr_site.*
										from site
									where location_c = vr_locn.location_c
#										and site_ref matches "*S"
										and site_c = "S"
										and site_status = "L"

									if status != notfound
									then
										call find_and_display_property
											(vr_site.site_ref, true)

										if length(vr_comp.location_desc)
										and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
										then
											let vl_mess = 
												"Select items of work for ", 
												vr_comp.location_desc clipped
										else	
											let vl_mess = 
												"Select items of work for ", 
												vr_comp.location_name clipped
										end if
										if continue_yn(vl_mess)
										then
											call get_comp_site_items(false)
												returning vg_null, vg_null, vg_null, vg_null
											#call disp_hist_message()
										end if
									end if
										
								otherwise
									call postcode_look("",
														"",
														"",
														vr_comp.location_name,
														vr_comp.service_c,
														true,
														"L", 
														true)
										returning vl_site_ref

									call set_comp_options()

									if length(vl_site_ref)
									then
										call find_and_display_property
											(vl_site_ref,true)
										call get_comp_site_items(false)
												returning vg_null, vg_null, vg_null, vg_null
										#call disp_hist_message()
									else
										let vr_comp.site_ref = null
										let vr_comp.location_c = null
										next field location_desc
									end if
							end case
						end if	
					end if
				end if
			end if

		before field location_desc
			if vr_comp.location_desc is null 
			then 
				let vl_location_desc = "NULL"
			else 
				let vl_location_desc = vr_comp.location_desc 
			end if 

		after field location_desc
			if vr_comp.location_desc is not null
			then
				if vr_comp.location_desc != vl_location_desc
				then
					if vg_property_on
					then
						call postcode_look(vr_comp.postcode,
											vr_comp.build_no,
											vr_comp.build_name,
											vr_comp.location_desc,
											vr_comp.service_c,
											true,
											"L", 
											true)
							returning vl_site_ref

						call set_comp_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref,true)
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
							#call disp_hist_message()
						else
							let vr_comp.site_ref = null
							let vr_comp.location_c = null
							next field location_desc
						end if
					end if
				end if	
			end if
 
		before field item_ref
			if vl_item_ref != "ERROR"
			or vl_item_ref is null
			then
				if vr_comp.item_ref is null 
				then 
					let vl_item_ref = "NULL" 
				else 
					let vl_item_ref = vr_comp.item_ref 
				end if 
			end if

		after field item_ref 
			 if length(vr_comp.item_ref)
			 then	 
				if vl_item_ref != vr_comp.item_ref
				then
					let vl_search = "item_ref = '", 
						vr_comp.item_ref clipped, "'"

					if no_of_rows("item", vl_search, "") = 0 
					then 
						let vl_mess = " The site item ", 
							vr_comp.item_ref clipped, " does not exist" 
						call valid_error("",vl_mess,"")
						next field item_ref 
					end if 

					let vl_rec_count = get_si_i()
					case 
						when vl_rec_count = 0
							call valid_error("",
		"A valid item must be selected for this site and service", "")
							initialize vr_si_i.* to null
							next field item_ref
						when vl_rec_count > 1
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
						otherwise
							# We have vr_si_i populated
					end case

					select customer_care_yn into vl_cc_flag from item
						where item_ref = vr_si_i.item_ref
						and contract_ref = vr_si_i.contract_ref

					if vl_cc_flag = "N"
					or status = notfound
					then
						call valid_error("",
							"This item cannot be accessed in this module",
							"")
						let vl_item_ref = "ERROR" 
						next field item_ref
					end if

					select count(*)
						into vl_rec_count
					from perm_items
						where ugroup = vg_ugroup
						and item_ref = vr_si_i.item_ref
						and contract_ref = vr_si_i.contract_ref

					if vl_rec_count
					then
						call valid_error("",
							"You do not have permission to select this item",
							"")
						let vl_item_ref = "ERROR" 
						next field item_ref
					end if
				end if
			else
				initialize vr_si_i.* to null
			end if 
			let vl_item_ref = null

			call display_item_info() 

		before field comp_code
			if length(vr_comp.comp_code)
			then
				let vl_comp_cde = vr_comp.comp_code
			else
				let vl_comp_cde = " "
			end if

		after field comp_code
			let vl_ans = null
			if vr_comp.comp_code is not null
			then
				if vl_orig_comp_code != vr_comp.comp_code
				then
					if skey_check("ALLOW_ADHOC_SAMPLES", "ALL") = "Y"
					and vl_orig_comp_code = skey_check("ADHOC_SAMPLE_FAULT", "ALL")
					then
						select count(*) into vl_count from comp_adhoc_sample
							where complaint_no = vr_comp.complaint_no
						if vl_count
						then
							let vl_mess =
								"The fault code cannot be altered for an adhoc sample"
							call valid_error("", vl_mess, "")
							let vr_comp.comp_code = vl_orig_comp_code
							call display_comp_code_info()
							next field comp_code
						end if
					end if
					if skey_check("ALLOW_ADHOC_SAMPLES", "ALL") = "Y"
					and vr_comp.comp_code = skey_check("ADHOC_SAMPLE_FAULT", "ALL")
					then
						let vl_mess =
						"The fault code cannot be changed to create an adhoc sample"
						call valid_error("", vl_mess, "")
						let vr_comp.comp_code = vl_orig_comp_code
						call display_comp_code_info()
						next field comp_code
					end if
				end if
				if vl_comp_cde != vr_comp.comp_code
				then
					display "" to fault_desc 
					if skey_check("LIST_COMP_CODES", vr_comp.service_c) = "N"
					then			
						select count(*) 
							into vl_count
						from allk
							where lookup_func = "COMPLA"
							and lookup_code = vr_comp.comp_code
							and service_c = vr_comp.service_c
							and status_yn = "Y"

						if not vl_count 
						then
							let vl_mess = "The fault ", 
								vr_comp.comp_code clipped,
								" has not been set up for the service", 
								vr_comp.service_c

							call valid_error("", vl_mess, "")
							next field comp_code
						end if
					end if

					select status_yn
						into vl_ans
					from allk
						where lookup_func = "COMPLA"
						and lookup_code = vr_comp.comp_code

					case vl_ans
						when "Y"
							if skey_check("COMP CODE>ITEM LINK", "ALL" ) = "Y" 
								and length(vr_comp.item_ref)
							then
								select count(*)
									into vl_count
								from it_c
									where it_c.item_ref = vr_comp.item_ref
										and it_c.comp_code = vr_comp.comp_code

								if not vl_count
								then
									let vl_mess = "The Fault Code ", 
										vr_comp.comp_code clipped, 
										" is not valid ",
										"for the selected item ", 
										vr_si_i.item_ref clipped , "."
					
									call valid_error("",vl_mess,"")
									next field comp_code
								end if
							end if
							call set_notice_type()
						when "N"
							let vl_mess = "The fault code '", 
								vr_comp.comp_code clipped, 
								"' exists but has been disabled."

							call valid_error("",vl_mess,"")
							next field comp_code
						otherwise
							let vl_mess = "The fault code '", 
								vr_comp.comp_code clipped, 
								"' does not exist.  A valid code must be entered"
							call valid_error("",vl_mess,"")
							next field comp_code
					end case
					call display_comp_code_info()
				end if
			end if
 
# ++++ BJG test phone number validation
			after field compl_phone
				if length(vr_customer.compl_phone)
				then
					call validate_phone_number("H","U",vr_customer.compl_phone)
						returning vl_count, vr_customer.compl_phone
					display by name vr_customer.compl_phone
					if not vl_count
					then
						next field compl_phone
					end if
				end if
# ++++ BJG test phone number validation

			after input
				if not validate_correspond("U") then
					next field corr_entered
				end if
				if not length(vr_comp.recvd_by)
				then
					call valid_error("", 
						"A valid source must be entered ", "")
					next field recvd_by
				else
					let vl_search = "lookup_func = 'CTSRC' and lookup_code = '", 
						vr_comp.recvd_by clipped, "'", " and status_yn = 'Y'"

					if no_of_rows("allk", vl_search, "") = 0
					then
						let vl_mess = " The source code ", 
							vr_comp.recvd_by clipped,
							" does not exist"
						call valid_error("", vl_mess,"")
						next field recvd_by
					end if
				end if

				if length(vr_comp.site_ref)
					and	vl_sav_site_ref	!= vr_comp.site_ref
				then
					# Just make sure that the site relates to the entered fields
					if not length(vr_comp.location_name)
					then
						call valid_error("", 
							"A valid road name must be entered", "")
						next field location_name
					else
						if not comp_check_site(vr_comp.site_ref,
												vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.location_desc)
						then 
							let vr_comp.site_ref = null
							let vr_comp.location_c = null
						end if	
					end if
				end if

				if not length(vr_comp.site_ref)
				then
					if not length(vr_comp.postcode) 
						and not length(vr_comp.build_no)
						and not length(vr_comp.build_name)
					then
						select count(*) 
							into vl_rec_count
						from locn
							where location_name = vr_comp.location_name 
								or location_name = vr_comp.location_desc

						if not vl_rec_count	
						then
							call valid_error("",
								"A valid road name must be entered","")
							next field location_name
						else
							if vl_rec_count = 1
							then
								select location_c into vr_comp.location_c
									from locn
								where location_name = vr_comp.location_name
									or location_name = vr_comp.location_desc

								select site_ref into vr_comp.site_ref
									from site
								where location_c = vr_comp.location_c
#									and site_ref matches "*S"
									and site_c = "S"
									and site_status = "L"

								call find_and_display_property(vr_comp.site_ref, 
									true)
								call get_comp_site_items(false)
									returning vg_null, vg_null, vg_null, vg_null
							else
								if length(vr_comp.location_desc)
								and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
								then
									call postcode_look(vr_comp.postcode,
														vr_comp.build_no,
														vr_comp.build_name,
														vr_comp.location_desc,
														vr_comp.service_c,
														true,
														"L", 
														true)
									returning vl_site_ref
								else
									call postcode_look(vr_comp.postcode,
														vr_comp.build_no,
														vr_comp.build_name,
														vr_comp.location_name,
														vr_comp.service_c,
														true,
														"L", 
														true)
									returning vl_site_ref
								end if

								call set_comp_options()

								if length(vl_site_ref)
								then
									call find_and_display_property
										(vl_site_ref, true)
									call get_comp_site_items(false)
										returning vg_null, vg_null, vg_null, vg_null
								else
									next field postcode
								end if
							end if
						end if
					else
						case 
							when length(vr_comp.location_desc)
								call postcode_look(vr_comp.postcode,
													vr_comp.build_no,
													vr_comp.build_name,
													vr_comp.location_desc,
													vr_comp.service_c,
													true,
													"L", 
													true)
										returning vl_site_ref
								exit case

							when length(vr_comp.location_name)
								call postcode_look(vr_comp.postcode,
													vr_comp.build_no,
													vr_comp.build_name,
													vr_comp.location_name,
													vr_comp.service_c,
													true,
													"L", 
													true)
										returning vl_site_ref
								exit case
							
							when length(vr_comp.build_no)
								call postcode_look("",
													vr_comp.build_no,
													"",
													vr_comp.location_name,
													vr_comp.service_c,
													true,
													"B#", 
													true)
										returning vl_site_ref
								exit case

							when length(vr_comp.build_name)
								call postcode_look("",
													vr_comp.build_name,
													"",
													vr_comp.location_name,
													vr_comp.service_c,
													true,
													"BN", 
													true)
									returning vl_site_ref
								exit case

							otherwise
								call valid_error("",
									"A valid property must be entered", "")
								let vl_site_ref = null
						end case

						call set_comp_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref, true)
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
						else
							next field postcode
						end if
					end if
				end if
		 
				if not length(vr_comp.item_ref)
				then
					call valid_error("Information", 
	"WARNING: An Item of work must be entered to raise a rectification or inspection",
							"")
					next field item_ref
				else
					let vl_search = "item_ref = '", 
						vr_comp.item_ref clipped, "'"

					if no_of_rows("item", vl_search, "") = 0 
					then 
						let vl_mess = " The site item ", 
							vr_comp.item_ref clipped, " does not exist" 
						call valid_error("",vl_mess,"")
						next field item_ref 
					end if 

					let vl_rec_count = get_si_i()
					case 
						when vl_rec_count = 0
							call valid_error("",
					"A valid item must be selected for this site and service", 
								"")
							initialize vr_si_i.* to null
							next field item_ref
						when vl_rec_count > 1
							call get_comp_site_items(false)
								returning vg_null, vg_null, vg_null, vg_null
						otherwise
							# We have vr_si_i populated
					end case
				end if 

				if not length(vr_comp.comp_code)
				then
					call valid_error("", 
						"A valid fault code must be entered", "")
					next field comp_code
				else
					if skey_check("LIST_COMP_CODES", vr_comp.service_c) = "N"
					then			
						select count(*) 
							into vl_count
						from allk
							where lookup_func = "COMPLA"
							and lookup_code = vr_comp.comp_code
							and service_c = vr_comp.service_c
							and status_yn = "Y"

						if not vl_count 
						then
							let vl_mess = "The fault ", 
								vr_comp.comp_code clipped,
								" has not been set up for the service", 
								vr_comp.service_c

							call valid_error("", vl_mess, "")
							next field comp_code
						end if
					end if

					select status_yn
						into vl_ans
					from allk
						where lookup_func = "COMPLA"
						and lookup_code = vr_comp.comp_code

					case vl_ans
						when "Y"
							if skey_check("COMP CODE>ITEM LINK", "ALL" ) = "Y" 
								and length(vr_comp.item_ref)
							then
								select count(*)
									into vl_count
								from it_c
									where it_c.item_ref = vr_comp.item_ref
									and it_c.comp_code = vr_comp.comp_code

								if not vl_count
								then
									let vl_mess = "The Fault Code ", 
										vr_comp.comp_code clipped, 
										" is not valid ",
										"for the selected item ", 
										vr_si_i.item_ref clipped , "."
					
									call valid_error("",vl_mess,"")
									next field comp_code
								end if
							end if
							call set_notice_type()
						when "N"
							let vl_mess = "The fault code '", 
								vr_comp.comp_code clipped, 
								"' exists but has been disabled."

							call valid_error("",vl_mess,"")
							next field comp_code

						otherwise
							let vl_mess = "The fault code '", 
								vr_comp.comp_code clipped, 
								"' does not exist. A valid code must be entered"
							call valid_error("",vl_mess,"")
						next field comp_code
				end case
				call display_comp_code_info()
			end if
	 
	end input

	if int_flag
	then
		let int_flag = false
		call valid_error("", "The selected record has NOT been updated", "")
		return
	end if

	let vr_comp.action_flag = generic_action_text

	display vr_comp.complaint_no to complaint_no
	call format_field(70,3,remarks_line)
		returning vr_comp.details_1,
					vr_comp.details_2,
					vr_comp.details_3,
					vg_null_val, vg_null_val

	while true			# begin work
		update comp
			set date_entered = vr_comp.date_entered,
				ent_time_h = vr_comp.ent_time_h,
				ent_time_m = vr_comp.ent_time_m,
				site_ref = vr_comp.site_ref,
				location_c = vr_comp.location_c,
				recvd_by = vr_comp.recvd_by,
				postcode = vr_comp.postcode,
				build_no = vr_comp.build_no,
				build_name = vr_comp.build_name,
				location_name = vr_comp.location_name,
				location_desc = vr_comp.location_desc,
				townname = vr_comp.townname,
				countyname = vr_comp.countyname,
				posttown = vr_comp.posttown,
				area_ward_desc = vr_comp.area_ward_desc, # BJG - 22/01/2008
				exact_location = vr_comp.exact_location,
				item_ref = vr_comp.item_ref,
				comp_code = vr_comp.comp_code,
				details_1 = vr_comp.details_1,
				details_2 = vr_comp.details_2,
				details_3 = vr_comp.details_3,
				pa_area = vr_comp.pa_area,
				round_c = vr_comp.round_c,
				occur_day = vr_comp.occur_day,
				feature_ref = vr_comp.feature_ref,
				contract_ref = vr_comp.contract_ref
			where complaint_no = vr_comp.complaint_no
        if vr_comp.service_c = vg_sched_service then
            update comp
                set pa_area = null,
	                round_c = null
                where complaint_no = vr_comp.complaint_no
        end if

#		call update_complaint_source()

        call check_action("Enquiry:Update", vr_comp.complaint_no)

		update comp_destination
			set destination = f_comp_destination.destination,
				destination_date = f_comp_destination.destination_date
			where complaint_no = vr_comp.complaint_no

		#ADJ DEBUG
#		display "ADJ DEBUG: vr_customer.customer_no:", vr_customer.customer_no

		update customer 
			set customer.* = vr_customer.*
		where customer_no = vr_customer.customer_no

		update diry 
			set source_date = vr_comp.date_entered,
				source_time_h = vr_comp.ent_time_h,
				source_time_m = vr_comp.ent_time_m,
				site_ref = vr_comp.site_ref,
				item_ref = vr_comp.item_ref,
				contract_ref = vr_si_i.contract_ref,
				feature_ref = vr_si_i.feature_ref,
				pa_area = vr_si_i.pa_area
			where source_ref = vr_comp.complaint_no
				and source_flag = "C"

		call update_complaint_source()

		if sqlca.sqlcode < 0
		then
			if errtst()
			then			# user selects to ignore error
				exit while
			else			# user selects to retry
				continue while
			end if
		end if

		exit while
	end while

	if skey_check("FC_ENHANCED","ALL") = "Y"
	then
		select count(*) into vl_count from allk
			where lookup_func = "FCCOMP"
			and lookup_code = vr_comp.comp_code
			and status_yn = "Y"
		if not vl_count
		then
# Flycapture stats not allowed for this comp_code
			delete from comp_flycap
				where complaint_no = vr_comp.complaint_no
			delete from comp_flycap_addw
				where complaint_no = vr_comp.complaint_no
		end if
	end if

	if vg_crm_enhanced = "Y"
	then
		call pop_ci_export_variables(vr_comp.complaint_no)
		let vr_crm_import_export.transaction_type = "C"
		call unload_crm_export_file (vr_crm_import_export.*)
	end if

	call ws_ext_integration(vr_comp.complaint_no, "", "", "")

	if vr_comp.action_flag != vl_act_flag_save
	then
		select diry_ref
			into vl_diry_ref
		from diry
			where source_ref = vr_comp.complaint_no
				and source_flag = "C"
		let vr_comp.action_flag = process_action(vl_diry_ref)

		if vr_comp.action_flag = "E"
		then
			#ADJBJG Enforce
			if vg_enforce_added
			then
				call update_comp_enf_source_ref(vl_diry_ref)
			end if

			let vr_comp.action_flag = 
				check_comp_action_system_key(vr_comp.service_c)
		end if
		let vr_comp.dest_ref = vr_diry.dest_ref

		if not length(vr_comp.action_flag)
		or vr_comp.action_flag = vl_act_flag_save
		then
			let vr_comp.action_flag = vl_act_flag_save
			let vg_enforce_added = false
			return
		end if

		# find out whether the destination of this complaint was cleared
		call check_comp_cleared()

		# find out whether the destination of this complaint was cleared

		update comp set dest_ref = vr_comp.dest_ref,
							dest_suffix = vr_comp.dest_suffix,
							action_flag = vr_comp.action_flag
		where complaint_no = vr_comp.complaint_no
				
		if vr_comp.action_flag != "N" 
		then	
			if vr_comp.action_flag != "W"  # BJG - not sure about other actions!
			then
				update diry set 
					action_flag = vr_comp.action_flag,
					dest_ref = vr_comp.dest_ref
				where diry_ref = vr_diry.diry_ref
			end if
		else					
			let vr_diry.action_flag = "C"
			let vr_diry.dest_flag = "C"
			let vr_diry.dest_ref = null
			let vr_diry.dest_date = today
			let vr_diry.dest_time_h = 
				extend(current, hour to hour)
			let vr_diry.dest_time_m = 
				extend(current, minute to minute)
			let vr_diry.dest_user = get_user()
			let vr_diry.dest_user = 
				upshift(vr_diry.dest_user)

			update diry set 
				action_flag = vr_diry.action_flag,
				dest_flag = vr_diry.dest_flag,  
				dest_ref = vr_diry.dest_ref,
				dest_date = vr_diry.dest_date,
				dest_time_h = vr_diry.dest_time_h,
				dest_time_m = vr_diry.dest_time_m,
				dest_user = vr_diry.dest_user
			where diry_ref = vr_diry.diry_ref

# BJG 14/04/2011 - If we are here the action_flag must have changed, so if it
#                  is now "N" we need to save a new text line to detail who
#                  set this action
            CALL record_nfa_text(vr_comp.complaint_no)
		end if
			
		call update_complaint_source()

		call display_comp_action_text()
		display vr_comp.dest_ref, vr_comp.dest_suffix
			to generic_dest_ref, generic_dest_suffix

		display vr_comp.dest_ref, vr_comp.dest_suffix
			to meas_dest_ref, meas_dest_suffix

		let vr_diry.action_flag = vr_comp.action_flag

		if vr_comp.action_flag = "I"
		then
			if change_comp_inspection(vr_comp.complaint_no)
			then
				# Change selected
			end if	
		end if

		if vr_comp.action_flag = "D"
			and vl_act_flag_save != vr_comp.action_flag
		then			# print out the default notice
			call print_comp_notice(vr_comp.complaint_no)
		end if

		# BJG - This should print WO when Comp destination updated to W
		if vr_comp.action_flag = "W"
			and vl_act_flag_save != vr_comp.action_flag
		then			# print out the works order notice
			# ADJ MOVE WO PRINT
			if vg_sched_installation = "Y"
			and vr_comp.service_c = vg_sched_service
			and skey_check("SCHED_PRINT_WO", "ALL") = "N"
			then
				# Do not print schedule works orders.	
			else
				call print_works_order_notice(vr_comp.dest_ref,
											vr_comp.dest_suffix)
			end if
		end if

		if vg_crm_enhanced = "Y"
		then
			call pop_ci_export_variables(vr_comp.complaint_no)
			let vr_crm_import_export.transaction_type = "C"
			call unload_crm_export_file(vr_crm_import_export.*)
		end if

		call ws_ext_integration(vr_comp.complaint_no, "", "", "")

	end if

	# find out whether the destination of this complaint was cleared
	call check_comp_cleared()

	if vr_comp.date_closed is not null
	then
		display vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
			to generic_date_closed, generic_time_closed_h, generic_time_closed_m
		display vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
			to meas_date_closed, meas_time_closed_h, meas_time_closed_m
		update comp 
			set date_closed = vr_comp.date_closed,
				time_closed_h = vr_comp.time_closed_h,
				time_closed_m = vr_comp.time_closed_m
		where complaint_no = vr_comp.complaint_no	

		if vl_act_flag_save = "H" then
			call notify_customer(vr_comp.complaint_no, "", "", "")
		end if
		call update_complaint_source()

		if vg_crm_enhanced = "Y"
		then
			call pop_ci_export_variables(vr_comp.complaint_no)
			let vr_crm_import_export.transaction_type = "C"
			call unload_crm_export_file(vr_crm_import_export.*)
		end if

		call ws_ext_integration(vr_comp.complaint_no, "", "", "")
	end if		

	call valid_error("", "The selected record has been updated", "")

	call save_correspond()
	call set_comp_options()

end function	# update_hold_complain


{
add_complain()
		before field compl_addr2
			if vr_comp.compl_addr2 is null
			then
				let vl_location_name = "NULL"
			else
				let vl_location_name = vr_comp.compl_addr2
			end if

		after field compl_addr2
			if vr_comp.compl_addr2 is not null
			then
				if vr_comp.compl_addr2 != vl_location_name
				then
					if vr_comp.compl_addr2 != vr_comp.location_name
						or vr_comp.location_name is null
					then
						let from_location_name = false

						call comp_check_locn(locn_rec_defined,
											site_rec_defined,
											vr_comp.compl_addr2,
											from_location_name)
							returning locn_rec_defined,
									site_rec_defined,
									vr_comp.compl_addr2,
									vl_rec_count
# ADJV6
						if vl_rec_count > 0
						then
							let vr_comp.compl_addr3 =
								draw_down_area_c(locn_rec_defined,
												vr_locn.location_c)
							display by name vr_comp.compl_addr3
						else
							initialize vr_comp.compl_addr3 to null
							display by name vr_comp.compl_addr3
						end if
					else
						select count(*)
							into vl_rec_count
							from locn
							where location_name = vr_comp.location_name
						
						if vl_rec_count > 1
						then
							let from_location_name = false

							call comp_check_locn(locn_rec_defined,
												site_rec_defined,
												vr_comp.compl_addr2,
												from_location_name)
								returning locn_rec_defined,
										site_rec_defined,
										vr_comp.compl_addr2,
										vl_rec_count

							if vl_rec_count > 0
							then
								let vr_comp.compl_addr3 =
									draw_down_area_c(locn_rec_defined,
													vr_locn.location_c)
								display by name vr_comp.compl_addr3 
							else
								initialize vr_comp.compl_addr3 to null
								display by name vr_comp.compl_addr3 
							end if
						else

							let vr_comp.compl_addr3 =
								draw_down_area_c(locn_rec_defined,
												vr_locn.location_c)
							display by name vr_comp.compl_addr3
						end if		
					end if
				end if
			end if
	(f2)
				when infield(compl_addr2)
					call clocn_look(vg_null, vr_comp.service_c)
					returning vr_comp.compl_addr2,
							temp_code,
							temp_code,
							temp_desc,
							temp_desc
					display by name vr_comp.compl_addr2
					call set_add_comp_options()
					message vl_mess
					next field compl_addr2
	(f3) 
			if vr_comp.site_ref is not null
			then
				if not infield(service_c)
				and not infield(location_name)
				then
					call open_disp_comp_wind()
					call disp_last_complain(vr_comp.site_ref)
					call close_disp_comp_wind()
				else
					call valid_error("",
						"F3 lookup not available in this field", "")
				end if
			else
				call valid_error("",
					"F3 lookup not available without location name", "")
			end if
			let int_flag = false
}
{
(f7)
				if infield(compl_init)
					or infield(compl_name)
					or infield(compl_surname)
					or infield(compl_build_name)
					or infield(compl_addr2)
					or infield(compl_addr3)
					or infield(compl_build_no)
				then
					let vr_comp.compl_addr2 = get_fldbuf(compl_addr2)
					if field_touched(compl_build_no)
					then
						let vr_comp.compl_build_no = get_fldbuf(compl_build_no)
					else
						initialize vr_comp.compl_build_no to null
					end if
					if field_touched(compl_build_name)
					then
						let vr_comp.compl_build_name = get_fldbuf(compl_build_name)
					else
						initialize vr_comp.compl_build_name to null
					end if
					if length(vr_comp.compl_addr2) > 0
					then
						call prompt_for_scroll(false,"R")
					else
						call valid_error("", 
	"A location must be entered to view the history.", "")
					end if
}


function add_complainant(vl_flag, vl_window, vl_mode)
	define 
		vl_site_ref			like site.site_ref,
		vl_compl_init		like customer.compl_init,
		vl_build_no			like comp.build_no,
		vl_build_name		like comp.build_name,
		vl_location_name	like comp.location_name,
		vl_location_desc	like comp.location_desc,
		vl_postcode			like site.postcode,
		vl_count,
		vl_rec_count		integer,
		vl_window			smallint,
		vl_flag				smallint,
		vl_customer_s1 		char(1000),
		vl_customer_s2		char(1000),
		vl_mode				char(1),
		vlr_customer		record like customer.*,
		vlr_comp				record like comp.*,
		vl_changed			smallint

	if vl_flag
	then
#		call comp_ant_of(vl_window)
--#		call fgl_keysetlabel("f3", vg_compln_title)
--#		call fgl_keysetlabel("f10", "Clear Address")

		if not length(vr_customer.int_ext_flag)
		then
			let vr_customer.int_ext_flag = skey_check("INT_EXT_FLAG", "ALL")
			if vr_customer.int_ext_flag not matches "[IE]"
			then
				let vr_customer.int_ext_flag = "E"
			end if
		end if
		if not length(vr_comp_clink.cust_satisfaction)
		then
			let vr_comp_clink.cust_satisfaction = vg_cs_flag
			if not length(vr_comp_clink.cust_satisfaction)
			then
				let vr_comp_clink.cust_satisfaction = "N"
			end if
		end if
		let vl_customer_s1 = "1", vr_customer.compl_postcode clipped,
								vr_customer.compl_build_no clipped,
								vr_customer.compl_build_name clipped,
								vr_customer.compl_addr2 clipped,
								vr_customer.compl_addr3 clipped,
								vr_customer.compl_addr4,
								vr_customer.compl_addr5,
								vr_customer.compl_addr6

		if vg_use_business_name = "Y"
		then
#			input by name vr_customer.compl_business,
			input vr_customer.compl_business,
						vr_customer.compl_init,
						vr_customer.compl_name,
						vr_customer.compl_surname,
						vr_customer.compl_phone,
						vr_comp_clink.cust_satisfaction,
						vr_customer.int_ext_flag,
						vr_customer.compl_postcode,
						vr_customer.compl_build_no,
						vr_customer.compl_build_name,
						vr_customer.compl_addr2,
						vr_customer.compl_addr3,
						vr_customer.compl_addr5,
						vr_customer.compl_addr6,
						vr_customer.compl_addr4,
						vr_customer.compl_fax,
						vr_customer.compl_email, 
						vr_customer.compl_mobile without defaults
					from
						sa_customer[vl_window].compl_business,
						sa_customer[vl_window].compl_init,
						sa_customer[vl_window].compl_name,
						sa_customer[vl_window].compl_surname,
						sa_customer[vl_window].compl_phone,
						sa_customer[vl_window].cust_satisfaction,
						sa_customer[vl_window].int_ext_flag,
						sa_customer[vl_window].compl_postcode,
						sa_customer[vl_window].compl_build_no,
						sa_customer[vl_window].compl_build_name,
						sa_customer[vl_window].compl_addr2,
						sa_customer[vl_window].compl_addr3,
						sa_customer[vl_window].compl_addr5,
						sa_customer[vl_window].compl_addr6,
						sa_customer[vl_window].compl_addr4,
						sa_customer[vl_window].compl_fax,
						sa_customer[vl_window].compl_email, 
						sa_customer[vl_window].compl_mobile
			
				on action cancel
					let vr_customer.compl_business = get_fldbuf(compl_business)
					let vr_customer.compl_init = get_fldbuf(compl_init)
					let vr_customer.compl_surname = get_fldbuf(compl_surname)
					let vr_customer.compl_name = get_fldbuf(compl_name)
					let vr_customer.compl_phone = get_fldbuf(compl_phone)
					let vr_comp_clink.cust_satisfaction = 
						get_fldbuf(cust_satisfaction)
					let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
					let vr_customer.compl_postcode = get_fldbuf(compl_postcode)
					let vr_customer.compl_build_no = get_fldbuf(compl_build_no)
					let vr_customer.compl_build_name = 
						get_fldbuf(compl_build_name)
					let vr_customer.compl_addr2 = get_fldbuf(compl_addr2)
					let vr_customer.compl_addr3 = get_fldbuf(compl_addr3)
					let vr_customer.compl_addr4 = get_fldbuf(compl_addr4)
					let vr_customer.compl_addr5 = get_fldbuf(compl_addr5)
					let vr_customer.compl_addr6 = get_fldbuf(compl_addr6)
					let vr_customer.compl_fax = get_fldbuf(compl_fax)
					let vr_customer.compl_email = get_fldbuf(compl_email)
					let vr_customer.compl_mobile = get_fldbuf(compl_mobile)
					exit input
				
				on action close
					let vr_customer.compl_business = get_fldbuf(compl_business)
					let vr_customer.compl_init = get_fldbuf(compl_init)
					let vr_customer.compl_surname = get_fldbuf(compl_surname)
					let vr_customer.compl_name = get_fldbuf(compl_name)
					let vr_customer.compl_phone = get_fldbuf(compl_phone)
					let vr_comp_clink.cust_satisfaction = 
						get_fldbuf(cust_satisfaction)
					let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
					let vr_customer.compl_postcode = get_fldbuf(compl_postcode)
					let vr_customer.compl_build_no = get_fldbuf(compl_build_no)
					let vr_customer.compl_build_name = 
						get_fldbuf(compl_build_name)
					let vr_customer.compl_addr2 = get_fldbuf(compl_addr2)
					let vr_customer.compl_addr3 = get_fldbuf(compl_addr3)
					let vr_customer.compl_addr4 = get_fldbuf(compl_addr4)
					let vr_customer.compl_addr5 = get_fldbuf(compl_addr5)
					let vr_customer.compl_addr6 = get_fldbuf(compl_addr6)
					let vr_customer.compl_fax = get_fldbuf(compl_fax)
					let vr_customer.compl_email = get_fldbuf(compl_email)
					let vr_customer.compl_mobile = get_fldbuf(compl_mobile)
					exit input
				
				on action f2_lookup
					case
						when infield(compl_business)
							let vg_comp_save.* = vr_comp.*
							let vg_customer_save.* = vr_customer.*

							call customer_look(4)
								returning vr_customer.customer_no

							if vg_comp_cust_sc_open
							then
								current window is iw_comp_cust_sc_2
							end if
#							current window is iw_comp_ant

							let vr_comp.* = vg_comp_save.*
							call set_add_comp_ant_options()
							if vr_customer.customer_no
							then
								select * 
									into vr_customer.*
								from customer
									where customer_no = vr_customer.customer_no
							
#								display by name vr_customer.compl_init,
								display vr_customer.compl_init,
												vr_customer.compl_name,
												vr_customer.compl_surname,
												vr_customer.compl_phone,
												vr_customer.int_ext_flag,
												vr_customer.compl_business,
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_customer.compl_addr3,
												vr_customer.compl_addr4,
												vr_customer.compl_addr5,
												vr_customer.compl_addr6,
												vr_customer.compl_fax,
												vr_customer.compl_email,
												vr_customer.compl_mobile 
										to sa_customer[vl_window].compl_init,
												sa_customer[vl_window].compl_name,
												sa_customer[vl_window].compl_surname,
												sa_customer[vl_window].compl_phone,
												sa_customer[vl_window].int_ext_flag,
												sa_customer[vl_window].compl_business,
												sa_customer[vl_window].compl_postcode,
												sa_customer[vl_window].compl_build_no,
												sa_customer[vl_window].compl_build_name,
												sa_customer[vl_window].compl_addr2,
												sa_customer[vl_window].compl_addr3,
												sa_customer[vl_window].compl_addr4,
												sa_customer[vl_window].compl_addr5,
												sa_customer[vl_window].compl_addr6,
												sa_customer[vl_window].compl_fax,
												sa_customer[vl_window].compl_email,
												sa_customer[vl_window].compl_mobile 
								next field compl_business
							else
								let vr_customer.* = vg_customer_save.*
							end if

						when infield(compl_init)
							let vg_comp_save.* = vr_comp.*
							let vg_customer_save.* = vr_customer.*

							call customer_look(1)
								returning vr_customer.customer_no

							if vg_comp_cust_sc_open
							then
								current window is iw_comp_cust_sc_2
							end if
#							current window is iw_comp_ant

							let vr_comp.* = vg_comp_save.*
							call set_add_comp_ant_options()
							if vr_customer.customer_no
							then
								select * 
									into vr_customer.*
								from customer
									where customer_no = vr_customer.customer_no
							
#								display by name vr_customer.compl_init,
								display vr_customer.compl_init,
												vr_customer.compl_name,
												vr_customer.compl_surname,
												vr_customer.compl_phone,
												vr_customer.int_ext_flag,
												vr_customer.compl_business,
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_customer.compl_addr3,
												vr_customer.compl_addr4,
												vr_customer.compl_addr5,
												vr_customer.compl_addr6,
												vr_customer.compl_fax,
												vr_customer.compl_email,
												vr_customer.compl_mobile 
										to sa_customer[vl_window].compl_init,
												sa_customer[vl_window].compl_name,
												sa_customer[vl_window].compl_surname,
												sa_customer[vl_window].compl_phone,
												sa_customer[vl_window].int_ext_flag,
												sa_customer[vl_window].compl_business,
												sa_customer[vl_window].compl_postcode,
												sa_customer[vl_window].compl_build_no,
												sa_customer[vl_window].compl_build_name,
												sa_customer[vl_window].compl_addr2,
												sa_customer[vl_window].compl_addr3,
												sa_customer[vl_window].compl_addr4,
												sa_customer[vl_window].compl_addr5,
												sa_customer[vl_window].compl_addr6,
												sa_customer[vl_window].compl_fax,
												sa_customer[vl_window].compl_email,
												sa_customer[vl_window].compl_mobile 
								next field compl_init
							else
								let vr_customer.* = vg_customer_save.*
							end if

						when infield(compl_name)
							let vg_comp_save.* = vr_comp.*
							let vg_customer_save.* = vr_customer.*

							call customer_look(2)
								returning vr_customer.customer_no

							if vg_comp_cust_sc_open
							then
								current window is iw_comp_cust_sc_2
							end if
#							current window is iw_comp_ant

							let vr_comp.* = vg_comp_save.*
							call set_add_comp_ant_options()
							if vr_customer.customer_no
							then
								select * 
									into vr_customer.*
								from customer
									where customer_no = vr_customer.customer_no
							
#								display by name vr_customer.compl_init,
								display vr_customer.compl_init,
												vr_customer.compl_name,
												vr_customer.compl_surname,
												vr_customer.compl_phone,
												vr_customer.int_ext_flag,
												vr_customer.compl_business,
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_customer.compl_addr3,
												vr_customer.compl_addr4,
												vr_customer.compl_addr5,
												vr_customer.compl_addr6,
												vr_customer.compl_fax,
												vr_customer.compl_email,
												vr_customer.compl_mobile 
										to sa_customer[vl_window].compl_init,
												sa_customer[vl_window].compl_name,
												sa_customer[vl_window].compl_surname,
												sa_customer[vl_window].compl_phone,
												sa_customer[vl_window].int_ext_flag,
												sa_customer[vl_window].compl_business,
												sa_customer[vl_window].compl_postcode,
												sa_customer[vl_window].compl_build_no,
												sa_customer[vl_window].compl_build_name,
												sa_customer[vl_window].compl_addr2,
												sa_customer[vl_window].compl_addr3,
												sa_customer[vl_window].compl_addr4,
												sa_customer[vl_window].compl_addr5,
												sa_customer[vl_window].compl_addr6,
												sa_customer[vl_window].compl_fax,
												sa_customer[vl_window].compl_email,
												sa_customer[vl_window].compl_mobile 
								next field compl_name
							else
								let vr_customer.* = vg_customer_save.*
							end if

						when infield(compl_surname)
							let vg_comp_save.* = vr_comp.*
							let vg_customer_save.* = vr_customer.*

							call customer_look(3)
								returning vr_customer.customer_no

							if vg_comp_cust_sc_open
							then
								current window is iw_comp_cust_sc_2
							end if
#							current window is iw_comp_ant

							let vr_comp.* = vg_comp_save.*
							call set_add_comp_ant_options()
							if vr_customer.customer_no
							then
								select * 
									into vr_customer.*
								from customer
									where customer_no = vr_customer.customer_no
							
#								display by name vr_customer.compl_init,
								display vr_customer.compl_init,
												vr_customer.compl_name,
												vr_customer.compl_surname,
												vr_customer.compl_phone,
												vr_customer.int_ext_flag,
												vr_customer.compl_business,
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_customer.compl_addr3,
												vr_customer.compl_addr4,
												vr_customer.compl_addr5,
												vr_customer.compl_addr6,
												vr_customer.compl_fax,
												vr_customer.compl_email,
												vr_customer.compl_mobile 
										to sa_customer[vl_window].compl_init,
												sa_customer[vl_window].compl_name,
												sa_customer[vl_window].compl_surname,
												sa_customer[vl_window].compl_phone,
												sa_customer[vl_window].int_ext_flag,
												sa_customer[vl_window].compl_business,
												sa_customer[vl_window].compl_postcode,
												sa_customer[vl_window].compl_build_no,
												sa_customer[vl_window].compl_build_name,
												sa_customer[vl_window].compl_addr2,
												sa_customer[vl_window].compl_addr3,
												sa_customer[vl_window].compl_addr4,
												sa_customer[vl_window].compl_addr5,
												sa_customer[vl_window].compl_addr6,
												sa_customer[vl_window].compl_fax,
												sa_customer[vl_window].compl_email,
												sa_customer[vl_window].compl_mobile 
								next field compl_surname
							else
								let vr_customer.* = vg_customer_save.*
							end if

						when infield(compl_postcode)		
							if vg_property_on
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr3,
												vr_comp.service_c,
												false,
												"P", 
												true)
										returning vl_site_ref
								else
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_comp.service_c,
												false,
												"P", 
												true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, 
																false)

								if vr_customer.compl_postcode is null 
								then 
									let vl_postcode = "NULL" 
								else 
									let vl_postcode = vr_customer.compl_postcode 
								end if 
								next field compl_postcode
							end if

						when infield(compl_build_no)
							if vg_property_on 
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr3,
												vr_comp.service_c,
												false,
												"B#", 
												true)
										returning vl_site_ref
								else
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_comp.service_c,
												false,
												"B#", 
												true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, 
															false)

								next field compl_build_no
							end if

						when infield(compl_build_name)
							if vg_property_on 
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr3,
												vr_comp.service_c,
												false,
												"BN", 
												true)
										returning vl_site_ref
								else
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_comp.service_c,
												false,
												"BN", 
												true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, 
																false)

								next field compl_build_name
							end if

						when infield(compl_addr2)
							if vg_property_on 
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr3,
												vr_comp.service_c,
												false,
												"L", 
												true)
										returning vl_site_ref
								else
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_comp.service_c,
												false,
												"L", 
												true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, 
																false)
								
								next field compl_addr2
							end if

						when infield(compl_addr3)
							if vg_property_on 
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr3,
												vr_comp.service_c,
												false,
												"L", 
												true)
										returning vl_site_ref
								else
									call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_comp.service_c,
												false,
												"L", 
												true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, 
																false)
								
								next field compl_addr3
							end if
					end case

				on action Customer
					let vr_customer.compl_business = get_fldbuf(compl_business)
					let vr_customer.compl_init = get_fldbuf(compl_init)
					let vr_customer.compl_name = get_fldbuf(compl_name)
					let vr_customer.compl_surname = get_fldbuf(compl_surname)
					let vr_customer.compl_phone = get_fldbuf(compl_phone)
					let vr_comp_clink.cust_satisfaction = 
						get_fldbuf(cust_satisfaction)
					let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
					let vr_customer.compl_postcode = get_fldbuf(compl_postcode)
					let vr_customer.compl_build_no = get_fldbuf(compl_build_no)
					let vr_customer.compl_build_name = 
						get_fldbuf(compl_build_name)
					let vr_customer.compl_addr2 = get_fldbuf(compl_addr2)
					let vr_customer.compl_addr3 = get_fldbuf(compl_addr3)
					let vr_customer.compl_addr4 = get_fldbuf(compl_addr4)
					let vr_customer.compl_addr5 = get_fldbuf(compl_addr5)
					let vr_customer.compl_addr6 = get_fldbuf(compl_addr6)
					let vr_customer.compl_fax = get_fldbuf(compl_fax)
					let vr_customer.compl_email = get_fldbuf(compl_email)
					let vr_customer.compl_mobile = get_fldbuf(compl_mobile)

					let vl_customer_s2 = "1",vr_customer.compl_postcode clipped,
										vr_customer.compl_build_no clipped,
										vr_customer.compl_build_name clipped,
										vr_customer.compl_addr2 clipped,
										vr_customer.compl_addr3 clipped,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6 
					if vl_customer_s1 = vl_customer_s2
					then
						exit input
					end if

					if length(vr_customer.compl_site_ref)
					then
						if comp_check_site(vr_customer.compl_site_ref,
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_customer.compl_addr3)
						then
							exit input
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					end if

					if length(vr_customer.compl_addr2)
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr3,
												vr_comp.service_c,
												true,
												"B#",
												true)
								returning vl_site_ref
						else
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr2,
												vr_comp.service_c,
												true,
												"B#", 
												true)
							returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref, false)
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					else
						let vr_customer.compl_site_ref = null
						let vr_customer.compl_location_c = null
					end if

					exit input

				on key(f10)
					let vr_customer.compl_site_ref = null
					let vr_customer.compl_location_c = null
					let vr_customer.compl_build_no = null
					let vr_customer.compl_build_name = null
					let vr_customer.compl_addr2 = null
					let vr_customer.compl_addr3 = null
					let vr_customer.compl_addr4 = null
					let vr_customer.compl_addr5 = null
					let vr_customer.compl_addr6 = null
					let vr_customer.compl_postcode = null
#					display by name vr_customer.compl_business,
					display vr_customer.compl_business,
							vr_customer.compl_init,
							vr_customer.compl_name,
							vr_customer.compl_surname,
							vr_customer.compl_phone,
							vr_customer.int_ext_flag,
							vr_customer.compl_postcode,
							vr_customer.compl_build_no,
							vr_customer.compl_build_name,
							vr_customer.compl_addr2,
							vr_customer.compl_addr3,
							vr_customer.compl_addr4,
							vr_customer.compl_addr5,
							vr_customer.compl_addr6,
							vr_customer.compl_fax,
							vr_customer.compl_email,
							vr_customer.compl_mobile
						to sa_customer[vl_window].compl_init,
							sa_customer[vl_window].compl_name,
							sa_customer[vl_window].compl_surname,
							sa_customer[vl_window].compl_phone,
							sa_customer[vl_window].int_ext_flag,
							sa_customer[vl_window].compl_business,
							sa_customer[vl_window].compl_postcode,
							sa_customer[vl_window].compl_build_no,
							sa_customer[vl_window].compl_build_name,
							sa_customer[vl_window].compl_addr2,
							sa_customer[vl_window].compl_addr3,
							sa_customer[vl_window].compl_addr4,
							sa_customer[vl_window].compl_addr5,
							sa_customer[vl_window].compl_addr6,
							sa_customer[vl_window].compl_fax,
							sa_customer[vl_window].compl_email,
							sa_customer[vl_window].compl_mobile 

				on action Text
					let vlr_comp.* = vr_comp.*
					if vr_comp.complaint_no
					then
						let g_text_update = true
						let vg_customer_save.* = vr_customer.*
					end if
					open window iw_complain_txt with form "comp_nbdisp"
					call text_yes_no()
					close window iw_complain_txt
					if vlr_comp.complaint_no
					then
						let vr_comp.* = vlr_comp.*
						let g_text_update = false
						let vr_customer.* =  vg_customer_save.*
					end if

				after field int_ext_flag
					if length(vr_customer.int_ext_flag)
					then
						if vr_customer.int_ext_flag not matches "[IE]"
						then
							call valid_error("",
								"A valid value must be entered", "")
							next field int_ext_flag
						end if
					else
						call valid_error("",
							"A valid value must be entered", "")
						next field int_ext_flag
					end if

				after field cust_satisfaction
					if length(vr_comp_clink.cust_satisfaction)
					then
						if vg_cs_update = "Y"
						and vg_cs_installation = "Y"
						then
							if vr_comp_clink.cust_satisfaction 
								not matches "[YN]"
							then
								call valid_error("",
									"A valid value must be entered", "")
								next field cust_satisfaction
							end if
						else
							if vr_comp_clink.cust_satisfaction != vg_cs_flag
							then
								call valid_error("",
	"The customer satisfaction survey flag cannot be changed at this point", 
									"")
								let vr_comp_clink.cust_satisfaction = vg_cs_flag
#								display by name vr_comp_clink.cust_satisfaction
								display vr_comp_clink.cust_satisfaction
									to sa_customer[vl_window].cust_satisfaction
							end if
						end if
					else
						call valid_error("",
							"A valid value must be entered", "")
						next field cust_satisfaction
					end if

	# compl_addr3 We need to check addresses as they are typed CRMMM
				before field compl_postcode
					if vr_customer.compl_postcode is null 
					then 
						let vl_postcode = "NULL" 
					else 
						let vl_postcode = vr_customer.compl_postcode 
					end if 

				after field compl_postcode
					if vr_customer.compl_postcode is not null
					then
						if vl_postcode != vr_customer.compl_postcode
						then
							if vg_property_on
							then
								# The postcode has changed .. 
								# we should perform an
								# automatic lookup on this postcode
								
								call postcode_look(vr_customer.compl_postcode, 
											 "", "", "", "", true, "P", true)
									returning vl_site_ref

								call set_add_comp_ant_options()
								if length(vl_site_ref)
								then
									call find_and_display_property(vl_site_ref,
																	false)
								end if
							end if
						end if
					end if

				before field compl_build_no
					if vr_customer.compl_build_no is null 
					then 
						let vl_build_no = "NULL" 
					else 
						let vl_build_no = vr_customer.compl_build_no 
					end if 

				after field compl_build_no
					if vr_customer.compl_build_no is not null
					then
						if vl_build_no != vr_customer.compl_build_no
						then
							if vg_property_on
							then
								if length(vr_customer.compl_addr2)
								then
									if length(vr_customer.compl_addr3)
									and vg_comp_loc_desc_town = "N"
									then
										call postcode_look("",
													vr_customer.compl_build_no,
													"",
													vr_customer.compl_addr3,
													"",
													true,
													"B#",
													true)
										returning vl_site_ref
									else
										call postcode_look("",
													vr_customer.compl_build_no,
													"",
													vr_customer.compl_addr2,
													"",
													true,
													"B#", 
													true)
											returning vl_site_ref
									end if
									call set_add_comp_ant_options()
									if length(vl_site_ref)
									then
										call find_and_display_property(
																	vl_site_ref,
																	false)
									end if
								end if
							end if
						end if
					end if

				before field compl_build_name
					if vr_customer.compl_build_name is null 
					then 
						let vl_build_name = "NULL" 
					else 
						let vl_build_name = vr_customer.compl_build_name
					end if 

				after field compl_build_name
					if vr_customer.compl_build_name is not null
					then
						if vr_customer.compl_build_name != vl_build_name
						then
							if vg_property_on	
							then
								if length(vr_customer.compl_addr2)
								then
									if length(vr_customer.compl_addr3)
									and vg_comp_loc_desc_town = "N"
									then
										call postcode_look("",
												"",
												vr_customer.compl_build_name,
												vr_customer.compl_addr3,
												"",
												true,
												"BN", 
												true)
											returning vl_site_ref
									else
										call postcode_look("",
												"",
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												"",
												true,
												"BN", 
												true)
											returning vl_site_ref
									end if
									call set_add_comp_ant_options()
									if length(vl_site_ref)
									then
										call find_and_display_property
																(vl_site_ref,
																	false)
									end if
								end if	
							end if
						end if
					end if

				before field compl_addr2 
					if not length(vr_customer.compl_addr2)
					then 
						let vl_location_name = "NULL" 
					else 
						let vl_location_name = vr_customer.compl_addr2 
					end if 

				after field compl_addr2
					if length(vr_customer.compl_addr2)
					then
						if vl_location_name != vr_customer.compl_addr2
						then
							if vg_property_on
							then
								if length(vr_customer.compl_build_no) 
									or length(vr_customer.compl_build_name)
								then
									if length(vr_customer.compl_addr3)
									and vg_comp_loc_desc_town = "N"
									then
										call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr3,
												"",
												true,
												"L", 
												true)
											returning vl_site_ref
									else
										call postcode_look(
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												"",
												true,
												"L", 
												true)
										returning vl_site_ref
									end if
									call set_add_comp_ant_options()
									if length(vl_site_ref)
									then
										call find_and_display_property(
											vl_site_ref,
											false)
									end if
								else
									select count(*) into vl_rec_count
										from locn
									where location_name 
										= vr_customer.compl_addr2

									if vl_rec_count = 1
									then
										select locn.* into vr_locn.*
											from locn 
										where location_name = 
											vr_customer.compl_addr2

										select site.* into vr_site.*
											from site
										where location_c = vr_locn.location_c
#											and site_ref matches "*S"
											and site_c = "S"
											and site_status = "L"

										if status != notfound
										then
											call find_and_display_property
												(vr_site.site_ref, false)
										end if
									end if
								end if	
							end if
						end if
					end if

				before field compl_addr3
					if vr_customer.compl_addr3 is null 
					then 
						let vl_location_desc = "NULL"
					else 
						let vl_location_desc = vr_customer.compl_addr3 
					end if 

				after field compl_addr3
					if vr_customer.compl_addr3 is not null
					then
						if vr_customer.compl_addr3 != vl_location_desc
						then
							if vg_property_on
							then
								call postcode_look(vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr3,
												"",
												true,
												"L", 
												true)
									returning vl_site_ref

								call set_add_comp_ant_options()

								if length(vl_site_ref)
								then
									call find_and_display_property(vl_site_ref,
										false)
								end if
							end if
						end if	
					end if

# ++++ BJG test phone number validation
				after field compl_phone
					if length(vr_customer.compl_phone)
					then
						call validate_phone_number("H",vl_mode,vr_customer.compl_phone)
							returning vl_count, vr_customer.compl_phone
#						display by name vr_customer.compl_phone
						display vr_customer.compl_phone
							to sa_customer[vl_window].compl_phone
						if not vl_count
						then
							next field compl_phone
						end if
					end if
# ++++ BJG test phone number validation

# ++++ BJG test fax number validation
				after field compl_fax
					if length(vr_customer.compl_fax)
					then
						call validate_phone_number("F",vl_mode,vr_customer.compl_fax)
							returning vl_count, vr_customer.compl_fax
#						display by name vr_customer.compl_fax
						display vr_customer.compl_fax
							to sa_customer[vl_window].compl_fax
						if not vl_count
						then
							next field compl_fax
						end if
					end if
# ++++ BJG test fax number validation

# ++++ BJG test mobile number validation
				after field compl_mobile
					if length(vr_customer.compl_mobile)
					then
						call validate_phone_number("M",vl_mode,vr_customer.compl_mobile)
							returning vl_count, vr_customer.compl_mobile
#						display by name vr_customer.compl_mobile
						display vr_customer.compl_mobile
							to sa_customer[vl_window].compl_mobile
						if not vl_count
						then
							next field compl_mobile
						end if
					end if
# ++++ BJG test mobile number validation

				after input
					let vr_customer.compl_business = get_fldbuf(compl_business)
					let vr_customer.compl_init = get_fldbuf(compl_init)
					let vr_customer.compl_name = get_fldbuf(compl_name)
					let vr_customer.compl_surname = get_fldbuf(compl_surname)
					let vr_customer.compl_phone = get_fldbuf(compl_phone)
					let vr_comp_clink.cust_satisfaction = 
						get_fldbuf(cust_satisfaction)
					let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
					let vr_customer.compl_postcode = get_fldbuf(compl_postcode)
					let vr_customer.compl_build_no = get_fldbuf(compl_build_no)
					let vr_customer.compl_build_name = 
						get_fldbuf(compl_build_name)
					let vr_customer.compl_addr2 = get_fldbuf(compl_addr2)
					let vr_customer.compl_addr3 = get_fldbuf(compl_addr3)
					let vr_customer.compl_addr4 = get_fldbuf(compl_addr4)
					let vr_customer.compl_addr5 = get_fldbuf(compl_addr5)
					let vr_customer.compl_addr6 = get_fldbuf(compl_addr6)
					let vr_customer.compl_fax = get_fldbuf(compl_fax)
					let vr_customer.compl_email = get_fldbuf(compl_email)
					let vr_customer.compl_mobile = get_fldbuf(compl_mobile)

					let vl_customer_s2 = "1",vr_customer.compl_postcode clipped,
										vr_customer.compl_build_no clipped,
										vr_customer.compl_build_name clipped,
										vr_customer.compl_addr2 clipped,
										vr_customer.compl_addr3 clipped,
										vr_customer.compl_addr4 clipped,
										vr_customer.compl_addr5 clipped,
										vr_customer.compl_addr6
					if vl_customer_s1 = vl_customer_s2
					then
						exit input
					end if

					if length(vr_customer.compl_site_ref)
					then
						if comp_check_site(vr_customer.compl_site_ref,
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_customer.compl_addr3)
						then
							exit input
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					end if

					if length(vr_customer.compl_addr2)
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr3,
												"",
												true,
												"B#",
												true)
								returning vl_site_ref
						else
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr2,
												"",
												true,
												"B#", 
												true)
							returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref, false)
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					else
						let vr_customer.compl_site_ref = null
						let vr_customer.compl_location_c = null
					end if

					exit input
			end input
		else
#			input by name vr_customer.compl_init,
			input vr_customer.compl_init,
						vr_customer.compl_name,
						vr_customer.compl_surname,
						vr_customer.compl_phone,
						vr_comp_clink.cust_satisfaction,
						vr_customer.int_ext_flag,
						vr_customer.compl_postcode,
						vr_customer.compl_build_no,
						vr_customer.compl_build_name,
						vr_customer.compl_addr2,
						vr_customer.compl_addr3,
						vr_customer.compl_addr5,
						vr_customer.compl_addr6,
						vr_customer.compl_addr4,
						vr_customer.compl_fax,
						vr_customer.compl_email, 
						vr_customer.compl_mobile without defaults
					from
						sa_customer[vl_window].compl_init,
						sa_customer[vl_window].compl_name,
						sa_customer[vl_window].compl_surname,
						sa_customer[vl_window].compl_phone,
						sa_customer[vl_window].cust_satisfaction,
						sa_customer[vl_window].int_ext_flag,
						sa_customer[vl_window].compl_postcode,
						sa_customer[vl_window].compl_build_no,
						sa_customer[vl_window].compl_build_name,
						sa_customer[vl_window].compl_addr2,
						sa_customer[vl_window].compl_addr3,
						sa_customer[vl_window].compl_addr5,
						sa_customer[vl_window].compl_addr6,
						sa_customer[vl_window].compl_addr4,
						sa_customer[vl_window].compl_fax,
						sa_customer[vl_window].compl_email, 
						sa_customer[vl_window].compl_mobile
			
			
				on action cancel
					let vr_customer.compl_init = get_fldbuf(compl_init)
					let vr_customer.compl_surname = get_fldbuf(compl_surname)
					let vr_customer.compl_name = get_fldbuf(compl_name)
					let vr_customer.compl_phone = get_fldbuf(compl_phone)
					let vr_comp_clink.cust_satisfaction = 
						get_fldbuf(cust_satisfaction)
					let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
					let vr_customer.compl_postcode = get_fldbuf(compl_postcode)
					let vr_customer.compl_build_no = get_fldbuf(compl_build_no)
					let vr_customer.compl_build_name = get_fldbuf(compl_build_name)
					let vr_customer.compl_addr2 = get_fldbuf(compl_addr2)
					let vr_customer.compl_addr3 = get_fldbuf(compl_addr3)
					let vr_customer.compl_addr4 = get_fldbuf(compl_addr4)
					let vr_customer.compl_addr5 = get_fldbuf(compl_addr5)
					let vr_customer.compl_addr6 = get_fldbuf(compl_addr6)
					let vr_customer.compl_fax = get_fldbuf(compl_fax)
					let vr_customer.compl_email = get_fldbuf(compl_email)
					let vr_customer.compl_mobile = get_fldbuf(compl_mobile)
					exit input
				
				on action close
					let vr_customer.compl_init = get_fldbuf(compl_init)
					let vr_customer.compl_surname = get_fldbuf(compl_surname)
					let vr_customer.compl_name = get_fldbuf(compl_name)
					let vr_customer.compl_phone = get_fldbuf(compl_phone)
					let vr_comp_clink.cust_satisfaction = 
						get_fldbuf(cust_satisfaction)
					let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
					let vr_customer.compl_postcode = get_fldbuf(compl_postcode)
					let vr_customer.compl_build_no = get_fldbuf(compl_build_no)
					let vr_customer.compl_build_name = get_fldbuf(compl_build_name)
					let vr_customer.compl_addr2 = get_fldbuf(compl_addr2)
					let vr_customer.compl_addr3 = get_fldbuf(compl_addr3)
					let vr_customer.compl_addr4 = get_fldbuf(compl_addr4)
					let vr_customer.compl_addr5 = get_fldbuf(compl_addr5)
					let vr_customer.compl_addr6 = get_fldbuf(compl_addr6)
					let vr_customer.compl_fax = get_fldbuf(compl_fax)
					let vr_customer.compl_email = get_fldbuf(compl_email)
					let vr_customer.compl_mobile = get_fldbuf(compl_mobile)
					exit input
				
				on action f2_lookup
					case
						when infield(compl_init)
							let vg_comp_save.* = vr_comp.*
							let vg_customer_save.* = vr_customer.*

							call customer_look(1)
								returning vr_customer.customer_no

							if vg_comp_cust_sc_open
							then
								current window is iw_comp_cust_sc_2
							end if
#							current window is iw_comp_ant

							let vr_comp.* = vg_comp_save.*
							call set_add_comp_ant_options()
							if vr_customer.customer_no
							then
								select * 
									into vr_customer.*
								from customer
									where customer_no = vr_customer.customer_no
							
#								display by name vr_customer.compl_init,
								display vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile
									to sa_customer[vl_window].compl_init,
										sa_customer[vl_window].compl_name,
										sa_customer[vl_window].compl_surname,
										sa_customer[vl_window].compl_phone,
										sa_customer[vl_window].int_ext_flag,
										sa_customer[vl_window].compl_postcode,
										sa_customer[vl_window].compl_build_no,
										sa_customer[vl_window].compl_build_name,
										sa_customer[vl_window].compl_addr2,
										sa_customer[vl_window].compl_addr3,
										sa_customer[vl_window].compl_addr4,
										sa_customer[vl_window].compl_addr5,
										sa_customer[vl_window].compl_addr6,
										sa_customer[vl_window].compl_fax,
										sa_customer[vl_window].compl_email,
										sa_customer[vl_window].compl_mobile 
							else
								let vr_customer.* = vg_customer_save.*
							end if

						when infield(compl_name)
							let vg_comp_save.* = vr_comp.*
							let vg_customer_save.* = vr_customer.*

							call customer_look(2)
								returning vr_customer.customer_no

							if vg_comp_cust_sc_open
							then
								current window is iw_comp_cust_sc_2
							end if
#							current window is iw_comp_ant

							let vr_comp.* = vg_comp_save.*
							call set_add_comp_ant_options()
							if vr_customer.customer_no
							then
								select * 
									into vr_customer.*
								from customer
									where customer_no = vr_customer.customer_no
							
#								display by name vr_customer.compl_init,
								display vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile
									to sa_customer[vl_window].compl_init,
										sa_customer[vl_window].compl_name,
										sa_customer[vl_window].compl_surname,
										sa_customer[vl_window].compl_phone,
										sa_customer[vl_window].int_ext_flag,
										sa_customer[vl_window].compl_postcode,
										sa_customer[vl_window].compl_build_no,
										sa_customer[vl_window].compl_build_name,
										sa_customer[vl_window].compl_addr2,
										sa_customer[vl_window].compl_addr3,
										sa_customer[vl_window].compl_addr4,
										sa_customer[vl_window].compl_addr5,
										sa_customer[vl_window].compl_addr6,
										sa_customer[vl_window].compl_fax,
										sa_customer[vl_window].compl_email,
										sa_customer[vl_window].compl_mobile 
							else
								let vr_customer.* = vg_customer_save.*
							end if

						when infield(compl_surname)
							let vg_comp_save.* = vr_comp.*
							let vg_customer_save.* = vr_customer.*

							call customer_look(3)
								returning vr_customer.customer_no

							if vg_comp_cust_sc_open
							then
								current window is iw_comp_cust_sc_2
							end if
#							current window is iw_comp_ant

							let vr_comp.* = vg_comp_save.*
							call set_add_comp_ant_options()
							if vr_customer.customer_no
							then
								select * 
									into vr_customer.*
								from customer
									where customer_no = vr_customer.customer_no
							
#								display by name vr_customer.compl_init,
								display vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile
									to sa_customer[vl_window].compl_init,
										sa_customer[vl_window].compl_name,
										sa_customer[vl_window].compl_surname,
										sa_customer[vl_window].compl_phone,
										sa_customer[vl_window].int_ext_flag,
										sa_customer[vl_window].compl_postcode,
										sa_customer[vl_window].compl_build_no,
										sa_customer[vl_window].compl_build_name,
										sa_customer[vl_window].compl_addr2,
										sa_customer[vl_window].compl_addr3,
										sa_customer[vl_window].compl_addr4,
										sa_customer[vl_window].compl_addr5,
										sa_customer[vl_window].compl_addr6,
										sa_customer[vl_window].compl_fax,
										sa_customer[vl_window].compl_email,
										sa_customer[vl_window].compl_mobile 
							else
								let vr_customer.* = vg_customer_save.*
							end if

						when infield(compl_postcode)		
							if vg_property_on
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr3,
													vr_comp.service_c,
													false,
													"P", 
													true)
										returning vl_site_ref
								else
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr2,
													vr_comp.service_c,
													false,
													"P", 
													true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, false)

								if vr_customer.compl_postcode is null 
								then 
									let vl_postcode = "NULL" 
								else 
									let vl_postcode = vr_customer.compl_postcode 
								end if 
								next field compl_postcode
							end if

						when infield(compl_build_no)
							if vg_property_on 
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr3,
													vr_comp.service_c,
													false,
													"B#", 
													true)
										returning vl_site_ref
								else
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr2,
													vr_comp.service_c,
													false,
													"B#", 
													true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, false)

								next field compl_build_no
							end if

						when infield(compl_build_name)
							if vg_property_on 
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr3,
													vr_comp.service_c,
													false,
													"BN", 
													true)
										returning vl_site_ref
								else
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr2,
													vr_comp.service_c,
													false,
													"BN", 
													true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, false)

								next field compl_build_name
							end if

						when infield(compl_addr2)
							if vg_property_on 
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr3,
													vr_comp.service_c,
													false,
													"L", 
													true)
										returning vl_site_ref
								else
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr2,
													vr_comp.service_c,
													false,
													"L", 
													true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, false)
								
								next field compl_addr2
							end if

						when infield(compl_addr3)
							if vg_property_on 
							or vg_use_property_lookups
							then
								if length(vr_customer.compl_addr3)
								and vg_comp_loc_desc_town = "N"
								then
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr3,
													vr_comp.service_c,
													false,
													"L", 
													true)
										returning vl_site_ref
								else
									call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr2,
													vr_comp.service_c,
													false,
													"L", 
													true)
										returning vl_site_ref
								end if

								call set_add_comp_ant_options()

								call find_and_display_property(vl_site_ref, false)
								
								next field compl_addr3
							end if
					end case

				on action Customer
					let vr_customer.compl_init = get_fldbuf(compl_init)
					let vr_customer.compl_name = get_fldbuf(compl_name)
					let vr_customer.compl_surname = get_fldbuf(compl_surname)
					let vr_customer.compl_phone = get_fldbuf(compl_phone)
					let vr_comp_clink.cust_satisfaction = 
						get_fldbuf(cust_satisfaction)
					let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
					let vr_customer.compl_postcode = get_fldbuf(compl_postcode)
					let vr_customer.compl_build_no = get_fldbuf(compl_build_no)
					let vr_customer.compl_build_name = get_fldbuf(compl_build_name)
					let vr_customer.compl_addr2 = get_fldbuf(compl_addr2)
					let vr_customer.compl_addr3 = get_fldbuf(compl_addr3)
					let vr_customer.compl_addr4 = get_fldbuf(compl_addr4)
					let vr_customer.compl_addr5 = get_fldbuf(compl_addr5)
					let vr_customer.compl_addr6 = get_fldbuf(compl_addr6)
					let vr_customer.compl_fax = get_fldbuf(compl_fax)
					let vr_customer.compl_email = get_fldbuf(compl_email)
					let vr_customer.compl_mobile = get_fldbuf(compl_mobile)

					let vl_customer_s2 = "1", vr_customer.compl_postcode clipped,
											vr_customer.compl_build_no clipped,
											vr_customer.compl_build_name clipped,
											vr_customer.compl_addr2 clipped,
											vr_customer.compl_addr3 clipped,
											vr_customer.compl_addr4 clipped,
											vr_customer.compl_addr5 clipped,
											vr_customer.compl_addr6 
					if vl_customer_s1 = vl_customer_s2
					then
						exit input
					end if

					if length(vr_customer.compl_site_ref)
					then
						if comp_check_site(vr_customer.compl_site_ref,
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_customer.compl_addr3)
						then
							exit input
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					end if

					if length(vr_customer.compl_addr2)
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr3,
												vr_comp.service_c,
												true,
												"B#",
												true)
								returning vl_site_ref
						else
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr2,
												vr_comp.service_c,
												true,
												"B#", 
												true)
							returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref, false)
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					else
						let vr_customer.compl_site_ref = null
						let vr_customer.compl_location_c = null
					end if

					exit input

				on key(f10)
					let vr_customer.compl_site_ref = null
					let vr_customer.compl_location_c = null
					let vr_customer.compl_build_no = null
					let vr_customer.compl_build_name = null
					let vr_customer.compl_addr2 = null
					let vr_customer.compl_addr3 = null
					let vr_customer.compl_addr4 = null
					let vr_customer.compl_addr5 = null
					let vr_customer.compl_addr6 = null
					let vr_customer.compl_postcode = null
#					display by name vr_customer.compl_init,
					display vr_customer.compl_init,
							vr_customer.compl_name,
							vr_customer.compl_surname,
							vr_customer.compl_phone,
							vr_customer.int_ext_flag,
							vr_customer.compl_postcode,
							vr_customer.compl_build_no,
							vr_customer.compl_build_name,
							vr_customer.compl_addr2,
							vr_customer.compl_addr3,
							vr_customer.compl_addr4,
							vr_customer.compl_addr5,
							vr_customer.compl_addr6,
							vr_customer.compl_fax,
							vr_customer.compl_email,
							vr_customer.compl_mobile
						to sa_customer[vl_window].compl_init,
							sa_customer[vl_window].compl_name,
							sa_customer[vl_window].compl_surname,
							sa_customer[vl_window].compl_phone,
							sa_customer[vl_window].int_ext_flag,
							sa_customer[vl_window].compl_postcode,
							sa_customer[vl_window].compl_build_no,
							sa_customer[vl_window].compl_build_name,
							sa_customer[vl_window].compl_addr2,
							sa_customer[vl_window].compl_addr3,
							sa_customer[vl_window].compl_addr4,
							sa_customer[vl_window].compl_addr5,
							sa_customer[vl_window].compl_addr6,
							sa_customer[vl_window].compl_fax,
							sa_customer[vl_window].compl_email,
							sa_customer[vl_window].compl_mobile 


				on action Text
					let vlr_comp.* = vr_comp.*
					if vr_comp.complaint_no
					then
						let g_text_update = true
						let vg_customer_save.* = vr_customer.*
                        open window iw_complain_txt with form "comp_nbdisp"
					end if
#					open window iw_complain_txt with form "comp_nbdisp"
					call text_yes_no()
#					close window iw_complain_txt
					if vlr_comp.complaint_no
					THEN
                        close window iw_complain_txt
						let vr_comp.* = vlr_comp.*
						let g_text_update = false
						let vr_customer.* =  vg_customer_save.*
					end if


				after field cust_satisfaction
					if length(vr_comp_clink.cust_satisfaction)
					then
						if vg_cs_update = "Y"
						and vg_cs_installation = "Y"
						then
							if vr_comp_clink.cust_satisfaction 
								not matches "[YN]"
							then
								call valid_error("",
									"A valid value must be entered", "")
								next field cust_satisfaction
							end if
						else
							if vr_comp_clink.cust_satisfaction != vg_cs_flag
							then
								call valid_error("",
	"The customer satisfaction survey flag cannot be changed at this point", 
									"")
								let vr_comp_clink.cust_satisfaction = vg_cs_flag
#								display by name vr_comp_clink.cust_satisfaction
								display vr_comp_clink.cust_satisfaction
									to sa_customer[vl_window].cust_satisfaction
							end if
						end if
					else
						call valid_error("",
							"A valid value must be entered", "")
						next field cust_satisfaction
					end if

				after field int_ext_flag
					if length(vr_customer.int_ext_flag)
					then
						if vr_customer.int_ext_flag not matches "[IE]"
						then
							call valid_error("",
								"A valid value must be entered", "")
							next field int_ext_flag
						end if
					else
						call valid_error("",
							"A valid value must be entered", "")
						next field int_ext_flag
					end if

	# compl_addr3 We need to check addresses as they are typed CRMMM
				before field compl_postcode
					if vr_customer.compl_postcode is null 
					then 
						let vl_postcode = "NULL" 
					else 
						let vl_postcode = vr_customer.compl_postcode 
					end if 

				after field compl_postcode
					if vr_customer.compl_postcode is not null
					then
						if vl_postcode != vr_customer.compl_postcode
						then
							if vg_property_on
							then
								# The postcode has changed .. we should perform an
								# automatic lookup on this postcode
								
								call postcode_look(vr_customer.compl_postcode, 
												 "", "", "", "", true, "P", true)
									returning vl_site_ref

								call set_add_comp_ant_options()
								if length(vl_site_ref)
								then
									call find_and_display_property(vl_site_ref,
																	false)
								end if
							end if
						end if
					end if

				before field compl_build_no
					if vr_customer.compl_build_no is null 
					then 
						let vl_build_no = "NULL" 
					else 
						let vl_build_no = vr_customer.compl_build_no 
					end if 

				after field compl_build_no
					if vr_customer.compl_build_no is not null
					then
						if vl_build_no != vr_customer.compl_build_no
						then
							if vg_property_on
							then
								if length(vr_customer.compl_addr2)
								then
									if length(vr_customer.compl_addr3)
									and vg_comp_loc_desc_town = "N"
									then
										call postcode_look("",
														vr_customer.compl_build_no,
														"",
														vr_customer.compl_addr3,
														"",
														true,
														"B#",
														true)
										returning vl_site_ref
									else
										call postcode_look("",
														vr_customer.compl_build_no,
														"",
														vr_customer.compl_addr2,
														"",
														true,
														"B#", 
														true)
											returning vl_site_ref
									end if
									call set_add_comp_ant_options()
									if length(vl_site_ref)
									then
										call find_and_display_property(vl_site_ref,
																		false)
									end if
								end if
							end if
						end if
					end if

				before field compl_build_name
					if vr_customer.compl_build_name is null 
					then 
						let vl_build_name = "NULL" 
					else 
						let vl_build_name = vr_customer.compl_build_name
					end if 

				after field compl_build_name
					if vr_customer.compl_build_name is not null
					then
						if vr_customer.compl_build_name != vl_build_name
						then
							if vg_property_on	
							then
								if length(vr_customer.compl_addr2)
								then
									if length(vr_customer.compl_addr3)
									and vg_comp_loc_desc_town = "N"
									then
										call postcode_look("",
													"",
													vr_customer.compl_build_name,
													vr_customer.compl_addr3,
													"",
													true,
													"BN", 
													true)
											returning vl_site_ref
									else
										call postcode_look("",
													"",
													vr_customer.compl_build_name,
													vr_customer.compl_addr2,
													"",
													true,
													"BN", 
													true)
											returning vl_site_ref
									end if
									call set_add_comp_ant_options()
									if length(vl_site_ref)
									then
										call find_and_display_property(vl_site_ref,
																		false)
									end if
								end if	
							end if
						end if
					end if

				before field compl_addr2 
					if not length(vr_customer.compl_addr2)
					then 
						let vl_location_name = "NULL" 
					else 
						let vl_location_name = vr_customer.compl_addr2 
					end if 

				after field compl_addr2
					if length(vr_customer.compl_addr2)
					then
						if vl_location_name != vr_customer.compl_addr2
						then
							if vg_property_on
							then
								if length(vr_customer.compl_build_no) 
									or length(vr_customer.compl_build_name)
								then
									if length(vr_customer.compl_addr3)
									and vg_comp_loc_desc_town = "N"
									then
										call postcode_look(
													vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr3,
													"",
													true,
													"L", 
													true)
											returning vl_site_ref
									else
										call postcode_look(
													vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr2,
													"",
													true,
													"L", 
													true)
										returning vl_site_ref
									end if
									call set_add_comp_ant_options()
									if length(vl_site_ref)
									then
										call find_and_display_property(vl_site_ref,
																		false)
									end if
								else
									select count(*) into vl_rec_count
										from locn
									where location_name 
										= vr_customer.compl_addr2

									if vl_rec_count = 1
									then
										select locn.* into vr_locn.*
											from locn 
										where location_name = 
											vr_customer.compl_addr2

										select site.* into vr_site.*
											from site
										where location_c = vr_locn.location_c
#											and site_ref matches "*S"
											and site_c = "S"
											and site_status = "L"

										if status != notfound
										then
											call find_and_display_property
												(vr_site.site_ref, false)
										end if
									end if
								end if	
							end if
						end if
					end if

				before field compl_addr3
					if vr_customer.compl_addr3 is null 
					then 
						let vl_location_desc = "NULL"
					else 
						let vl_location_desc = vr_customer.compl_addr3 
					end if 

				after field compl_addr3
					if vr_customer.compl_addr3 is not null
					then
						if vr_customer.compl_addr3 != vl_location_desc
						then
							if vg_property_on
							then
								call postcode_look(vr_customer.compl_postcode,
													vr_customer.compl_build_no,
													vr_customer.compl_build_name,
													vr_customer.compl_addr3,
													"",
													true,
													"L", 
													true)
									returning vl_site_ref

								call set_add_comp_ant_options()

								if length(vl_site_ref)
								then
									call find_and_display_property(vl_site_ref,
										false)
								end if
							end if
						end if	
					end if

# ++++ BJG test phone number validation
				after field compl_phone
					if length(vr_customer.compl_phone)
					then
						call validate_phone_number("H",vl_mode,vr_customer.compl_phone)
							returning vl_count, vr_customer.compl_phone
#						display by name vr_customer.compl_phone
						display vr_customer.compl_phone
							to sa_customer[vl_window].compl_phone
						if not vl_count
						then
							next field compl_phone
						end if
					end if
# ++++ BJG test phone number validation

# ++++ BJG test fax number validation
				after field compl_fax
					if length(vr_customer.compl_fax)
					then
						call validate_phone_number("F",vl_mode,vr_customer.compl_fax)
							returning vl_count, vr_customer.compl_fax
#						display by name vr_customer.compl_fax
						display vr_customer.compl_fax
							to sa_customer[vl_window].compl_fax
						if not vl_count
						then
							next field compl_fax
						end if
					end if
# ++++ BJG test fax number validation

# ++++ BJG test mobile number validation
				after field compl_mobile
					if length(vr_customer.compl_mobile)
					then
						call validate_phone_number("M",vl_mode,vr_customer.compl_mobile)
							returning vl_count, vr_customer.compl_mobile
#						display by name vr_customer.compl_mobile
						display vr_customer.compl_mobile
							to sa_customer[vl_window].compl_mobile
						if not vl_count
						then
							next field compl_mobile
						end if
					end if
# ++++ BJG test mobile number validation

				after input
					let vr_customer.compl_init = get_fldbuf(compl_init)
					let vr_customer.compl_name = get_fldbuf(compl_name)
					let vr_customer.compl_surname = get_fldbuf(compl_surname)
					let vr_customer.compl_phone = get_fldbuf(compl_phone)
					let vr_comp_clink.cust_satisfaction = 
						get_fldbuf(cust_satisfaction)
					let vr_customer.int_ext_flag = get_fldbuf(int_ext_flag)
					let vr_customer.compl_postcode = get_fldbuf(compl_postcode)
					let vr_customer.compl_build_no = get_fldbuf(compl_build_no)
					let vr_customer.compl_build_name = get_fldbuf(compl_build_name)
					let vr_customer.compl_addr2 = get_fldbuf(compl_addr2)
					let vr_customer.compl_addr3 = get_fldbuf(compl_addr3)
					let vr_customer.compl_addr4 = get_fldbuf(compl_addr4)
					let vr_customer.compl_addr5 = get_fldbuf(compl_addr5)
					let vr_customer.compl_addr6 = get_fldbuf(compl_addr6)
					let vr_customer.compl_fax = get_fldbuf(compl_fax)
					let vr_customer.compl_email = get_fldbuf(compl_email)
					let vr_customer.compl_mobile = get_fldbuf(compl_mobile)

					let vl_customer_s2 = "1", vr_customer.compl_postcode clipped,
											vr_customer.compl_build_no clipped,
											vr_customer.compl_build_name clipped,
											vr_customer.compl_addr2 clipped,
											vr_customer.compl_addr3 clipped,
											vr_customer.compl_addr4 clipped, 
											vr_customer.compl_addr5 clipped,
											vr_customer.compl_addr6 
					if vl_customer_s1 = vl_customer_s2
					then
						exit input
					end if

					if length(vr_customer.compl_site_ref)
					then
						if comp_check_site(vr_customer.compl_site_ref,
												vr_customer.compl_postcode,
												vr_customer.compl_build_no,
												vr_customer.compl_build_name,
												vr_customer.compl_addr2,
												vr_customer.compl_addr3)
						then
							exit input
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					end if

					if length(vr_customer.compl_addr2)
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr3,
												"",
												true,
												"B#",
												true)
								returning vl_site_ref
						else
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr2,
												"",
												true,
												"B#", 
												true)
							returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref, false)
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					else
						let vr_customer.compl_site_ref = null
						let vr_customer.compl_location_c = null
					end if

					exit input

			end input
		end if

		let vl_changed = false

		if vr_customer.customer_no is not null then
			select * into vlr_customer.* from customer
				where customer_no = vr_customer.customer_no
			if
				length(vr_customer.customer_ext_ref) <>
				length(vlr_customer.customer_ext_ref)
			then
				let vl_changed = true
			else
				if length(vr_customer.customer_ext_ref) > 0 then
					if
						vr_customer.customer_ext_ref <>
						vlr_customer.customer_ext_ref
					then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_business) <>
				length(vlr_customer.compl_business)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_business) > 0 then
					if
						vr_customer.compl_business <> vlr_customer.compl_business
					then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_init) <> length(vlr_customer.compl_init)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_init) > 0 then
					if vr_customer.compl_init <> vlr_customer.compl_init then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_name) <> length(vlr_customer.compl_name)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_name) > 0 then
					if vr_customer.compl_name <> vlr_customer.compl_name then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_surname) <>
				length(vlr_customer.compl_surname)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_surname) > 0 then
					if vr_customer.compl_surname <> vlr_customer.compl_surname then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_site_ref) <>
				length(vlr_customer.compl_site_ref)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_site_ref) > 0 then
					if
						vr_customer.compl_site_ref <>
						vlr_customer.compl_site_ref
					then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_location_c) <>
				length(vlr_customer.compl_location_c)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_location_c) > 0 then
					if
						vr_customer.compl_location_c <>
						vlr_customer.compl_location_c
					then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_build_no) <>
				length(vlr_customer.compl_build_no)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_build_no) > 0 then
					if
						vr_customer.compl_build_no <>
						vlr_customer.compl_build_no
					then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_build_name) <>
				length(vlr_customer.compl_build_name)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_build_name) > 0 then
					if
						vr_customer.compl_build_name <>
						vlr_customer.compl_build_name
					then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_addr2) <>
				length(vlr_customer.compl_addr2)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_addr2) > 0 then
					if vr_customer.compl_addr2 <> vlr_customer.compl_addr2 then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_addr3) <>
				length(vlr_customer.compl_addr3)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_addr3) > 0 then
					if vr_customer.compl_addr3 <> vlr_customer.compl_addr3 then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_addr4) <>
				length(vlr_customer.compl_addr4)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_addr4) > 0 then
					if vr_customer.compl_addr4 <> vlr_customer.compl_addr4 then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_addr5) <>
				length(vlr_customer.compl_addr5)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_addr5) > 0 then
					if vr_customer.compl_addr5 <> vlr_customer.compl_addr5 then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_addr6) <>
				length(vlr_customer.compl_addr6)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_addr6) > 0 then
					if vr_customer.compl_addr6 <> vlr_customer.compl_addr6 then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_postcode) <>
				length(vlr_customer.compl_postcode)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_postcode) then
					if
						vr_customer.compl_postcode <>
						vlr_customer.compl_postcode
					then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_phone) <>
				length(vlr_customer.compl_phone)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_phone) > 0 then
					if vr_customer.compl_phone <> vlr_customer.compl_phone then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_fax) <>
				length(vlr_customer.compl_fax)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_fax) > 0 then
					if vr_customer.compl_fax <> vlr_customer.compl_fax then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_mobile) <>
				length(vlr_customer.compl_mobile)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_mobile) > 0 then
					if vr_customer.compl_mobile <> vlr_customer.compl_mobile then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.compl_email) <>
				length(vlr_customer.compl_email)
			then
				let vl_changed = true
			else
				if length(vr_customer.compl_email) > 0 then
					if vr_customer.compl_email <> vlr_customer.compl_email then
						let vl_changed = true
					end if
				end if
			end if
			if
				length(vr_customer.int_ext_flag) <>
				length(vlr_customer.int_ext_flag)
			then
				let vl_changed = true
			else
				if length(vr_customer.int_ext_flag) > 0 then
					if vr_customer.int_ext_flag <> vlr_customer.int_ext_flag then
						let vl_changed = true
					end if
				end if
			end if

			if vl_changed = true then
				if vr_customer.customer_no is not null then
					update customer set * = vr_customer.*
					where customer_no = vr_customer.customer_no
				end if
			end if
		end if

#		call comp_ant_cf()

		if int_flag
		then
			let int_flag = false
			return false
		else
			return true
		end if
	else
		call disp_comp_cust_sc(vr_comp.complaint_no)

		return true
	end if

end function	# add_complainant


function comp_ant_of(vl_window)
	define 
		vl_item_desc	char(80),
		vl_window		smallint

	if vl_window
	then
		case 
			when vl_window = 1
				if vg_use_business_name = "Y"
				then
					open window iw_comp_ant at 2, 2 with form "comp_ant_bus" 
					if vg_disp_ward_or_area = "N"
					then
						display "Ward" at 10, 2
					end if
				else
					open window iw_comp_ant at 4, 2 with form "comp_ant" 
					if vg_disp_ward_or_area = "N"
					then
						display "Ward" at 7, 2
					end if
				end if
				let vl_item_desc = "UPDATE ", upshift(vg_compln_title) clipped 
				display vl_item_desc clipped at 2, 2

			when vl_window = 2
				if vg_use_business_name = "Y"
				then
					open window iw_comp_ant at 12, 2 with form "comp_ant_bus" 
					if vg_disp_ward_or_area = "N"
					then
						display "Ward" at 9, 2
					end if
				else
					open window iw_comp_ant at 14, 2 with form "comp_ant" 
					if vg_disp_ward_or_area = "N"
					then
						display "Ward" at 7, 2
					end if
				end if
				if vr_customer.customer_no
				then
					let vl_item_desc = "UPDATE ", 
						upshift(vg_compln_title) clipped 
					display vl_item_desc clipped at 1, 2
				else
					let vl_item_desc = "ADD ", upshift(vg_compln_title) clipped 
					display vl_item_desc clipped at 1, 2
				end if
			when vl_window = 3
				if vg_use_business_name = "Y"
				then
					open window iw_comp_ant at 12, 2 with form "comp_ant_bus"
					if vg_disp_ward_or_area = "N"
					then
						display "Ward" at 9, 2
					end if
				else
					open window iw_comp_ant at 14, 2 with form "comp_ant" 
					if vg_disp_ward_or_area = "N"
					then
						display "Ward" at 7, 2
					end if
				end if
				if vr_customer.customer_no
				then
					let vl_item_desc = "UPDATE ", 
						upshift(vg_compln_title) clipped 
					display vl_item_desc clipped at 1, 2
				else
					let vl_item_desc = "ADD ", upshift(vg_compln_title) clipped 
					display vl_item_desc clipped at 1, 2
				end if
		end case
	else
		if vg_use_business_name = "Y"
		then
			open window iw_comp_ant at 12, 1 with form "comp_ant_bus" 
			call fgl_drawbox(11, 79, 1, 1)
			if vg_disp_ward_or_area = "N"
			then
				display "Ward" at 9, 2
			end if
		else
			open window iw_comp_ant at 14, 1 with form "comp_ant" 
			if vg_disp_ward_or_area = "N"
			then
				display "Ward" at 7, 2
			end if
			call fgl_drawbox(9, 79, 1, 1)
		end if

		let vl_item_desc = upshift(vg_compln_title) clipped, " INFORMATION"
		call centre(1, 2, vl_item_desc)
	end if
end function	# comp_ant_of


function comp_ant_cf()
#	close window iw_comp_ant 
end function	# comp_ant_cf


function display_add_comp_info(vl_disp_flag)
	define
		vl_disp_flag	smallint

#	current window is iw_complain
	if vl_disp_flag
	then
		display by name	vr_comp.service_c,
		vr_comp.recvd_by,
		vr_comp.postcode,
		vr_comp.build_no,
		vr_comp.build_name,
		vr_comp.location_name,
		vr_comp.location_desc,
		vr_comp.exact_location,
		vr_customer.compl_init,
		vr_customer.compl_name,
		vr_customer.compl_surname,
		vr_customer.compl_phone,
		vr_comp_clink.cust_satisfaction,
		vr_customer.int_ext_flag

--#		call fgl_keysetlabel("f7", "History")
	else
		display by name	vr_comp.service_c,
			vr_comp.recvd_by,
			vr_comp.postcode,
			vr_comp.build_no,
			vr_comp.build_name,
			vr_comp.location_name,
			vr_comp.location_desc,
			vr_comp.exact_location
	end if

end function	# display_add_comp_info


function find_and_display_property(vl_site_ref, vl_addr_type)
	define 
		vl_site_ref				like site.site_ref,
		vl_area_ward_desc		like ward.ward_name,
		vl_townname				like site.townname,
		vl_location_primary		like locn.location_name,
		vl_addr_type			smallint,
		vl_build_sub_no			like site.build_sub_no

	if length(vl_site_ref)
	then
		select * into vr_site.*
			from site
		where site_ref = vl_site_ref

		select * into vr_site_detail.*
			from site_detail
		where site_ref = vl_site_ref

		select * into vr_locn.*
			from locn
		where locn.location_c = vr_site.location_c

		if vr_locn.locn_type > 1
		then
			call get_location_primary(vr_site.location_c)
				returning vg_null, vl_location_primary
		else
			let vl_location_primary = null
		end if
		
		if vg_disp_ward_or_area = "Y" 
		then
			select area_name
				into vl_area_ward_desc
			from area
				where area_c = vr_site.area_c
		else
			select ward_name
				into vl_area_ward_desc
			from ward
				where ward_code = vr_site.ward_code
		end if

		if vl_addr_type
		then
			let vr_comp.postcode = vr_site.postcode
			let vr_comp.site_ref = vr_site.site_ref
			let vr_comp.location_c = vr_site.location_c

			#ADJ TOWNNAME
			let vr_comp.townname = vr_site.townname
			let vr_comp.countyname = vr_site_detail.countyname
			let vr_comp.posttown = vr_site_detail.townname

			let vr_comp.easting = vr_site_detail.easting
			let vr_comp.northing = vr_site_detail.northing
			let	vr_comp.easting_end = vr_site_detail.easting_end
			let vr_comp.northing_end = vr_site_detail.northing_end
		else
			let vr_customer.compl_postcode = vr_site.postcode
			let vr_customer.compl_site_ref = vr_site.site_ref
			let vr_customer.compl_location_c = vr_site.location_c
			let vr_customer.compl_addr5 = vr_site.townname

			if vg_disp_county_or_postal = "Y"
			then
				let vr_customer.compl_addr6 = vr_site_detail.countyname
			else
				let vr_customer.compl_addr6 = vr_site_detail.townname
			end if
		end if
	else
        if vl_addr_type THEN
            initialize vr_site.* to null
            initialize vr_site_detail.* to null
            initialize vr_locn.* to null
            initialize vr_ward.* to null
            let vr_comp.site_ref = null
            let vr_comp.location_c = null
            let vr_comp.townname = null
            let vr_comp.countyname = null
            let vr_comp.posttown = NULL
        ELSE
            initialize vr_site.* to null
            initialize vr_site_detail.* to null
            initialize vr_locn.* to null
            initialize vr_ward.* to null
            LET vr_customer.compl_location_c = NULL
            LET vr_customer.compl_addr2=NULL
            LET vr_customer.compl_addr3=NULL
            LET vr_customer.compl_addr4=NULL
            LET vr_customer.compl_addr5=NULL
            LET vr_customer.compl_addr6=NULL
            LET vr_customer.compl_build_name=NULL
            LET vr_customer.compl_build_no=NULL
            LET vr_customer.compl_postcode=NULL
            LET vr_customer.compl_site_ref=NULL
        END IF 
	end if
		
{
	if vl_addr_type
	then
		let vr_comp.build_no = vr_site.build_no	
		let vr_comp.build_sub_no = vr_site.build_sub_no	
		let vr_comp.build_sub_name = vr_site.build_sub_name
		if length(vr_site.build_sub_name)
		then
			let vr_comp.build_name = vr_site.build_sub_name clipped

			if length(vr_site.build_name)
			then
				let vr_comp.build_name = vr_comp.build_name clipped, ", ",
					vr_site.build_name
			end if
		else
			let vr_comp.build_name = vr_site.build_name
		end if
}
		
# BJG - new piece of code
	if vl_addr_type
	then
		if skey_check("COMP_BUILD_NO_DISP", "ALL") = "Y" 
		then
			let vr_comp.build_no = vr_site.build_no_disp
			let vr_comp.build_sub_no = vr_site.build_sub_no_disp
		else
			let vr_comp.build_no = vr_site.build_no	
			let vr_comp.build_sub_no = vr_site.build_sub_no	
		end if
		let vr_comp.build_sub_name = vr_site.build_sub_name
		if length(vr_comp.build_sub_no)
		then
			let vr_comp.build_name = vr_comp.build_sub_no clipped
			if length(vr_site.build_sub_name)
			then
				let vr_comp.build_name = vr_comp.build_name clipped, ", ",
										vr_site.build_sub_name clipped
				if length(vr_site.build_name)
				then
					let vr_comp.build_name = vr_comp.build_name clipped, ", ",
						vr_site.build_name
				end if
			else
				let vr_comp.build_name = vr_comp.build_name clipped, ", ",
										vr_site.build_name clipped
			end if
		else
			if length(vr_site.build_sub_name)
			then
				let vr_comp.build_name = vr_site.build_sub_name clipped

				if length(vr_site.build_name)
				then
					let vr_comp.build_name = vr_comp.build_name clipped, ", ",
						vr_site.build_name
				end if
			else
				let vr_comp.build_name = vr_site.build_name
			end if
		end if
# BJG - end of new piece of code
		
		if length(vr_site.site_section)
#		and vr_site.site_ref matches "*[SG]"
		and vr_site.site_c matches "[SG]"
		then
			let vr_comp.location_name = vr_locn.location_name
			let vr_comp.location_desc = vr_site.site_section
		else
			if length(vl_location_primary)
			then
				let vr_comp.location_name = vl_location_primary
				let vr_comp.location_desc = vr_locn.location_name
			else
				let vr_comp.location_name = vr_locn.location_name
				if skey_check("COMP_LOC_DESC_TOWN","ALL") = "N"
				then
					let vr_comp.location_desc = null
				else
					# BJG 10/04/2007
					let vr_comp.location_desc = vr_site.townname 
				end if
			end if
		end if

		if not vg_f3_pressed
		then
			call drawdown_address(vl_area_ward_desc)
		end if

		let vr_comp.area_ward_desc = vl_area_ward_desc

		case
			when vr_comp.service_c = vg_agreq_service
			and vg_agreq_installation = "Y"
				display vr_comp.postcode,
							vr_comp.build_no, 
							vr_comp.build_name,
							vr_comp.location_name # ,
#							vr_comp.location_desc
					to trade_postcode,
						trade_build_no,
						trade_build_name,
						trade_location_name # ,
#						trade_location_desc
				display vr_comp.area_ward_desc to trade_area_ward_desc
				if vg_disp_townname_on_screen = "Y"
				then
					display vr_comp.townname to trade_townname
					if vg_disp_county_or_postal = "Y"
					then
						display vr_comp.countyname to trade_posttown
					else
						display vr_comp.posttown to trade_posttown
					end if
				end if

			otherwise
				display by name vr_comp.postcode,
								vr_comp.build_no, 
								vr_comp.build_name,
								vr_comp.location_name,
								vr_comp.location_desc
				display vr_comp.area_ward_desc to area_ward_desc
				if vg_disp_townname_on_screen = "Y"
				then
					display by name vr_comp.townname
					if vg_disp_county_or_postal = "Y"
					then
						display vr_comp.countyname to posttown
					else
						display by name vr_comp.posttown
					end if
				end if
		end case
	else
		if skey_check("COMP_BUILD_NO_DISP", "ALL") = "Y" 
		then
			let vr_customer.compl_build_no = vr_site.build_no_disp
			let vl_build_sub_no = vr_site.build_sub_no_disp
		else
			let vr_customer.compl_build_no = vr_site.build_no	
			let vl_build_sub_no = vr_site.build_sub_no	
		end if
		if length(vl_build_sub_no)
		then
			let vr_customer.compl_build_name = vl_build_sub_no clipped
			if length(vr_site.build_sub_name)
			then
				let vr_customer.compl_build_name =
					vr_customer.compl_build_name clipped, ", ",
					vr_site.build_sub_name clipped
				if length(vr_site.build_name)
				then
					let vr_customer.compl_build_name =
						vr_customer.compl_build_name clipped, ", ",
						vr_site.build_name
				end if
			else
				let vr_customer.compl_build_name =
					vr_customer.compl_build_name clipped, ", ",
					vr_site.build_name clipped
			end if
		else
			if length(vr_site.build_sub_name)
			then
				let vr_customer.compl_build_name = 
					vr_site.build_sub_name clipped

				if length(vr_site.build_name)
				then
					let vr_customer.compl_build_name = 
						vr_customer.compl_build_name clipped, 
						", ", vr_site.build_name
				end if
			else
				let vr_customer.compl_build_name = vr_site.build_name
			end if
		end if

		if length(vl_location_primary)
		then
			let vr_customer.compl_addr2 = vl_location_primary
			let vr_customer.compl_addr3 = vr_locn.location_name
		else
			let vr_customer.compl_addr2 = vr_locn.location_name
			let vr_customer.compl_addr3 = null
		end if

		let vr_customer.compl_addr4 = vl_area_ward_desc
		let vr_customer.compl_addr5 = vr_site.townname

		if length(vr_site.site_section)
		and vr_site.site_c matches "[SG]"
		then
			let vr_customer.compl_addr3 = vr_site.site_section
		else
			if skey_check("COMP_LOC_DESC_TOWN","ALL") = "Y"
			then
				let vr_customer.compl_addr3 = vr_site.townname 
			end if
		end if

		if vg_disp_county_or_postal = "Y"
		then
			let vr_customer.compl_addr6 = vr_site_detail.countyname
		else
			let vr_customer.compl_addr6 = vr_site_detail.townname
		end if

		display by name vr_customer.compl_postcode,
						vr_customer.compl_build_no, 
						vr_customer.compl_build_name,
						vr_customer.compl_addr2,
						vr_customer.compl_addr3,
						vr_customer.compl_addr4

		if vg_disp_townname_on_screen = "Y"
		then
			display by name vr_customer.compl_addr5,
							vr_customer.compl_addr6
		end IF
        LET vg_f3_pressed = true
	end if

	let vg_map_easting = vr_comp.easting
	let vg_map_northing = vr_comp.northing

	call display_map_tab("500", 
						"135", 
						vg_zoom, 
						vg_map_easting, 
						vg_map_northing, 
						"reset")
		returning vg_zoom, vg_map_easting, vg_map_northing

end function	# find_and_display_property


{
function check_property(vl_postcode,
					vl_build_no,
					vl_build_name,
					vl_location_name,
					vl_search_type)

	define vl_postcode 			like site.postcode,
			vl_build_no 		like site.build_no,
			vl_build_name 		like site.build_name,
			vl_location_name 	like locn.location_name,
			vl_site_ref 		like site.site_ref,
			vl_new_postcode 		like site.postcode,
			vl_new_build_no 		like site.build_no,
			vl_new_build_name 		like site.build_name,
			vl_new_location_name 	like locn.location_name,
			vl_new_site_ref 		like site.site_ref,
			vl_target			char(750),
			vl_search_type		char(2),
			vl_addr_flag		smallint,
			vl_property_count	smallint

	# Lets narrow down the search a bit.. if there is just a building no or name
	# then do NOT perform the search
	if not length(vl_postcode) and not length(vl_location_name)
	then
		return true, 
				vl_site_ref, 
				vl_postcode, 
				vl_build_no,
				vl_build_name, 
				vl_location_name
	end if

	if length(vl_postcode)
	then
		declare c_post1 cursor for 
			select site.site_ref
	end if

	if length(vl_location_name)
	then
		declare c_locn1 cursor for
			select locn.location_name. locn.location_c from locn
				where location_name = vl_location_name 

		let vl_property_count = 0
		foreach c_locn1 into vl_new_location_c, vl_new_location_name
		end foreach
	end if

	call mstart_wait("Validating Property, Please Wait ...")

	let vl_target = "select site_ref, postcode, build_no, build_name, ",
					"location_name from site, locn ",
					"where site.location_c = locn.location_c "

	if length(vl_postcode)
	then
		let vl_target = vl_target clipped, " and site.postcode = '", 
			vl_postcode clipped, "'"
	end if

	if length(vl_build_no)
	then
		let vl_target = vl_target clipped, " and site.build_no = '", 
			vl_build_no clipped, "'"
	end if

	if length(vl_build_name)
	then
		let vl_target = vl_target clipped, " and site.build_name = '", 
			vl_build_name clipped, "'"
	end if

	let vl_property_count = 0

	prepare ip_property_1 from vl_target
	declare c_property cursor for ip_property_1

	foreach c_property into vl_new_site_ref, 
							vl_new_postcode, 
							vl_new_build_no, 
							vl_new_build_name, 
							vl_new_location_name

		let vl_property_count = vl_property_count + 1

	end foreach

	call end_wait()

	case vl_property_count 
		when 0
			return false, "", "", "", "", ""
		when 1
			return true, 
					vl_new_site_ref, 
					vl_new_postcode, 
					vl_new_build_no, 
					vl_new_build_name,
					vl_new_location_name
		otherwise
			return true, 
					"", 
					vl_postcode, 
					vl_build_no, 
					vl_build_name,
					vl_location_name
	end case

#	case vl_search_type
#		when "P"
#			if length(vl_postcode)
#			then
#				select count(*) into vl_addr_flag
#					from site
#				where postcode = vl_postcode
#
#				if not vl_addr_flag
#				then
#					return false,"","","","",""
#				end if
#			end if
#		when "B#"
#			if length(vl_build_no)
#			then
#				select count(*) into vl_build_no
#					from site
#				where postcode = vl_postcode
#
#				if not vl_addr_flag
#				then
#					return false,"","","","",""
#				end if
#			end if
#		when "BN"
#			if length(vl_build_name)
#			then
#				select count(*) into vl_build_name
#					from site
#				where build_name = vl_build_name
#
#				if not vl_addr_flag
#				then
#					return false,"","","","",""
#				end if
#			end if
#		when "L"
#			if length(vl_location_name)
#			then
#				select count(*) into vl_location_name
#					from locn
#				where location_name = vl_location_name
#
#				if not vl_addr_flag
#				then
#					return false,"","","","",""
#				end if
#			end if
#		when
#
#	return vl_addr_flag,
#			vl_postcode,
#			vl_build_no,
#			vl_build_name,
#			vl_location_name,
#			vl_site_name
#

end function	# check_property

}

function get_comp_site_items(vl_f2)
	define 	
		new_day 			char(7),
		vl_f2,
		si_i_rec_defined	smallint,
		vl_service_c		like comp.service_c,
		vl_task_ref			like agree_task.task_ref,
		vl_agreement_no	like agree_task.agreement_no

	let si_i_rec_defined = false

	if length(vr_comp.site_ref)
	then
		if skey_check("COMP_SITE_ITEM_POPUP", "ALL") = "Y"
		then
#			if comp_check_sites_items(si_i_rec_defined,
			call comp_check_sites_items(si_i_rec_defined,
									vr_comp.date_entered,
									vl_f2)
				returning si_i_rec_defined, vl_service_c,
							vl_task_ref, vl_agreement_no
			if si_i_rec_defined = 1
			then
				let vr_comp.occur_day = vr_si_i.occur_day
				let vr_comp.round_c = vr_si_i.round_c
				let vr_comp.item_ref = vr_si_i.item_ref
				let vr_comp.pa_area = vr_si_i.pa_area
				let vr_comp.feature_ref = vr_si_i.feature_ref
				call display_item_info()
			end if
		end if
	end if	
	message " "
	return si_i_rec_defined, vl_service_c, vl_task_ref, vl_agreement_no

end function	# get_comp_site_items


function query_normal_complain(vl_lock_service_c)
	define 
		vl_comp_text			record like comp_text.*,
		vl_warden_item_type		like warden_item.warden_item_type,
		vl_lock_service_c		like keys.service_c,
		vl_ward_code			like ward.ward_code,
		vl_ward_name			like ward.ward_name,
		vl_area_code			like area.area_code,
		vl_area_name			like area.area_name,
		area_ward_desc			like ward.ward_name,
		vl_site_ref				like site.site_ref,
		vl_where_part			char(1000),
		vl_ret_where_part		char(1000),
		vl_ret_where_part_ii	char(1000),
		vl_det_where_part		char(1000),
		vl_det_where_part_ii	char(1000),
		vl_txt_part				char(150),
		vl_imp_part				char(150),
		vl_null					char(1),
		vl_change_service 		char(1),
		vl_count				smallint,
		vl_av_query				smallint,
		vl_weee_query			smallint,
		vl_weee_sales_query		smallint,
		vl_clin_query			smallint,
		vl_nappy_query			smallint,
		vl_trade_query			smallint,
#ADJ131003
		comp_status				char(7),
		remarks_line			char(70),
		vl_comp_code			char(10),
		vl_qry_string			char(100)

	define w	ui.Window
	define f	ui.Form

	let vl_change_service = false

	#ADJ GENERO
	#call icon_of()
	call qrycomp_of()
#	current window is iw_complain
	clear form
	call complain_labels()
#	display "Reference" to reference_label
#	display "History" to history_title

	if vl_lock_service_c
	then
		let vr_comp.service_c = vl_lock_service_c
		let vr_qry_comp.service_c = vl_lock_service_c
	else
		let vr_qry_comp.service_c = vr_comp.service_c
	end if

	let w = ui.Window.getCurrent()
	let f = w.getForm()

	call f.setElementHidden("import_page",false)
	call f.setElementHidden("text_page",true)
	call f.setElementHidden("text_query_page",false)

	# Address box
	call f.setElementHidden("generic_address",false) 
	call f.setElementHidden("clin_address",true) 
	call f.setElementHidden("nappy_address",true) 
	call f.setElementHidden("trade_address",true) 

	# Status and flags box
	call f.setElementHidden("formonly.related_flag",false)
	call f.setElementHidden("comp_enf.actions",true)
	call f.setElementHidden("formonly.evidence_flag",true)
	call f.setElementHidden("formonly.alt_location",true)
	call f.setElementHidden("formonly.history_title",true)
	call f.setElementHidden("formonly.enquiries_title",false)
	call f.setElementHidden("formonly.actions_title",true)
	call f.setElementHidden("formonly.evidence_title",true)

	# Screen Tabs 
	call f.setElementHidden("generic_page",false)
	call f.setElementHidden("av_page",true)
	call f.setElementHidden("gm_page",true)
	call f.setElementHidden("ert_page",true)
	call f.setElementHidden("hway_page",true)
	call f.setElementHidden("trade_page",true)
	call f.setElementHidden("trade_details_page",true)
	call f.setElementHidden("agreq_page",true)
	call f.setElementHidden("enf_page",true)
	call f.setElementHidden("meas_page",true)
	call f.setElementHidden("sl_page",true)
	call f.setElementHidden("tree_page",true)
	call f.setElementHidden("weee_page",true)
	call f.setElementHidden("weee_sales_ent_page",true)
	call f.setElementHidden("sched_page",true)
	call f.setElementHidden("works_order_page",true)
	call f.setElementHidden("rectifications_page",true)
	call f.setElementHidden("debtor_page",true)
	call f.setElementHidden("trade_site_page",true)
	call f.setElementHidden("actions_page",true)
	call f.setElementHidden("action_text_page",true)
	call f.setElementHidden("costs_page",true)
	call f.setElementHidden("suspect_page",true)
	call f.setElementHidden("evidence_page",true)
	call f.setElementHidden("attachments_page",false)

	call populate_action_combo("Q", "DWHPINR", "generic_action_text")

#	call gl_showpage("fold","generic_page")

	message "Enter query criteria"
#ADJ131003
	construct by name vl_where_part on 
					comp.complaint_no,
					comp.service_c,
					comp.date_entered,
					comp.ent_time_h,
					comp.ent_time_m,
					comp.entered_by,
					comp_status,
					comp.recvd_by,
					#ADJ GENERO
					#comp.action_flag,
					comp.text_flag,
					comp.build_no,
					comp.build_name,
					comp.location_name,
					comp.location_desc,
					comp.townname,
					comp.posttown,
					comp.area_ward_desc,
					comp.postcode,
					comp.exact_location,
					customer.compl_init,
					customer.compl_name,
					customer.compl_surname,
					customer.compl_phone,
					comp_clink.cust_satisfaction,
					customer.int_ext_flag,
					comp.item_ref,
					item_info1,
					comp.comp_code,
					item_info2,
					remarks_line,
					generic_action_text,
					generic_dest_ref, 
					generic_dest_suffix, 
					generic_date_closed,
					generic_time_closed_h,
					generic_time_closed_m,
					customer.compl_business,
					customer.compl_postcode,
					customer.compl_build_no,
					customer.compl_build_name,
					customer.compl_addr2,
					customer.compl_addr3,
					customer.compl_addr5,
					customer.compl_addr6,
					customer.compl_addr4,
					customer.compl_fax,
					customer.compl_email,
					customer.compl_mobile,
					formonly.qry_username,
					formonly.qry_doa,
					formonly.qry_txt,
					comp.incident_id,
					comp_import.import_date,
					comp_import.import_time,
					comp_correspond.corr_entered,
					comp_correspond.date_due,
					comp_correspond.date_response,
					comp_correspond.assigned_to

    
#					ward.ward_name,
#					comp.details_1
#					comp.pa_area,
#					comp.round_c,
#					comp.occur_day,

		before construct
#ADJ131003
			display by name vr_qry_comp.comp_status,
				vr_qry_comp.complaint_no,
				vr_qry_comp.service_c,
				vr_qry_comp.recvd_by,
				vr_qry_comp.date_entered,
				vr_qry_comp.ent_time_h,
				vr_qry_comp.ent_time_m,
				vr_qry_comp.entered_by,
				generic_action_text,
				#vr_qry_comp.action_flag,
				#ADJ 070908
				#vr_qry_comp.dest_ref, 
				#vr_qry_comp.dest_suffix, 
				#vr_qry_comp.date_closed,
				#vr_qry_comp.time_closed_h,
				#vr_qry_comp.time_closed_m,
				vr_qry_comp.text_flag,
				vr_qry_comp.build_no,
				vr_qry_comp.build_name,
				vr_qry_comp.location_name,
				vr_qry_comp.location_desc,
				vr_qry_comp.townname,
				vr_qry_comp.posttown,
				vr_qry_comp.area_ward_desc,
				vr_qry_comp.exact_location,
				vr_qry_comp.postcode,
				vr_qry_comp.compl_init,
				vr_qry_comp.compl_name,
				vr_qry_comp.compl_surname,
				vr_qry_comp.compl_phone,
				vr_qry_comp.cust_satisfaction,
				vr_qry_comp.int_ext_flag,
				vr_qry_comp.item_ref,
				vr_qry_comp.comp_code,
				vr_qry_comp.remarks_line

			if vg_dart_installation = "Y"
			or vg_ert_installation = "Y"
			or vg_sw_installation = "Y"
			then
				call dialog.setActionHidden("detail", false)
			else
				call dialog.setActionHidden("detail", true)
			end IF
            next field complaint_no # BJG 02/07/3012 - Workflow 3381

		after construct	
#ADJ131003
			let vr_qry_comp.comp_status = get_fldbuf(comp_status)
			let vr_qry_comp.complaint_no = get_fldbuf(complaint_no)
			let vr_qry_comp.service_c = get_fldbuf(service_c)
			let vr_qry_comp.recvd_by = get_fldbuf(recvd_by)
			let vr_qry_comp.date_entered = get_fldbuf(date_entered)
			let vr_qry_comp.ent_time_h = get_fldbuf(ent_time_h)
			let vr_qry_comp.ent_time_m = get_fldbuf(ent_time_m)
			let vr_qry_comp.entered_by = get_fldbuf(entered_by)

			let generic_action_text = get_fldbuf(generic_action_text)
			#let vr_qry_comp.action_flag = get_fldbuf(action_flag)
			#ADJ 070908
			#let vr_qry_comp.dest_ref = get_fldbuf(dest_ref)
			#let vr_qry_comp.dest_suffix = get_fldbuf(dest_suffix)
			#let vr_qry_comp.date_closed = get_fldbuf(date_closed)
			#let vr_qry_comp.time_closed_h = get_fldbuf(time_closed_h)
			#let vr_qry_comp.time_closed_m = get_fldbuf(time_closed_m)
			let vr_qry_comp.text_flag = get_fldbuf(text_flag)
			let vr_qry_comp.build_no = get_fldbuf(build_no)
			let vr_qry_comp.build_name = get_fldbuf(build_name)
			let vr_qry_comp.location_name = get_fldbuf(location_name)
			let vr_qry_comp.location_desc = get_fldbuf(location_desc)
			let vr_qry_comp.townname = get_fldbuf(townname)
			let vr_qry_comp.posttown = get_fldbuf(posttown)
			let vr_qry_comp.area_ward_desc = get_fldbuf(area_ward_desc)
			let vr_qry_comp.exact_location = get_fldbuf(exact_location)
			let vr_qry_comp.postcode = get_fldbuf(postcode)
			let vr_qry_comp.compl_init = get_fldbuf(compl_init)
			let vr_qry_comp.compl_name = get_fldbuf(compl_name)
			let vr_qry_comp.compl_surname = get_fldbuf(compl_surname)
			let vr_qry_comp.compl_phone = get_fldbuf(compl_phone)
			let vr_qry_comp.cust_satisfaction = get_fldbuf(cust_satisfaction)
			let vr_qry_comp.int_ext_flag = get_fldbuf(int_ext_flag)
			let vr_qry_comp.item_ref = get_fldbuf(item_ref)
			let vr_qry_comp.comp_code = get_fldbuf(comp_code)
			let vr_qry_comp.remarks_line = get_fldbuf(remarks_line)

#ADJ131003
		after field comp_status
			let vr_qry_comp.comp_status = get_fldbuf(comp_status)
			if length(vr_qry_comp.comp_status)
			then
				if vr_qry_comp.comp_status != "RUNNING"
				and vr_qry_comp.comp_status != "CLOSED"
				and vr_qry_comp.comp_status != "Y"
				and vr_qry_comp.comp_status != "N"
				then
					call valid_error("",
						"A valid status must be entered", "")
					next field comp_status
				end if
			end if

		after field service_c
			let vr_comp.service_c = get_fldbuf(service_c)
			let vr_qry_comp.service_c = get_fldbuf(service_c)
			display by name vr_qry_comp.service_c

			if length(vl_lock_service_c)
			then
				if vl_lock_service_c != vr_qry_comp.service_c
				then
					call valid_error("",
						"The service cannot be changed at this point", "")
					let vr_comp.service_c = vl_lock_service_c
					let vr_qry_comp.service_c = vl_lock_service_c
					display by name vr_qry_comp.service_c
					next field service_c
				end if
			end if
			if not valid_user_service(vr_comp.service_c)
			then
				next field service_c
			end if

			if get_fldbuf(service_c) = vg_hway_service
				and vg_hway_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_av_service
				and vg_av_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			# WEEE
			if get_fldbuf(service_c) = vg_weee_service
				and vg_weee_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			# WEEE SALES
			if get_fldbuf(service_c) = vg_weee_sales_service
				and vg_sales_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_sl_service
				and vg_sl_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_gm_service
				and vg_gm_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_ert_service
				and vg_ert_installation = "Y"
				and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_trees_service
				and vg_trees_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_enf_service
				and vg_enf_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_enf_trade_service
				and vg_enf_trade_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_nappy_service
				and vg_nappy_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_clin_service
				and vg_clin_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_trade_service
				and vg_trade_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
			if get_fldbuf(service_c) = vg_agreq_service
				and vg_agreq_installation = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
#			if get_fldbuf(service_c) = skey_check("SCHED_SERVICE", "ALL")
#				and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
			if get_fldbuf(service_c) = vg_sched_service
				and vg_sched_installation = "Y"
				and vg_weee_installation = "N"
				and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if
#			if get_fldbuf(service_c) = skey_check("SCHED_SERVICE", "ALL")
#				and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
			if get_fldbuf(service_c) = vg_sched_service
				and vg_sched_installation = "Y"
				and vg_weee_installation = "Y"
				and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
				and fgl_lastkey() != fgl_keyval("accept")
			then
				let vl_change_service = true
				exit construct
			end if

		after field comp_code
			let vr_qry_comp.comp_code = get_fldbuf(comp_code)
            LET vr_comp.comp_code = vr_qry_comp.comp_code
			if length(vr_qry_comp.comp_code)
			then
				let vl_comp_code = "*", vr_qry_comp.comp_code clipped, ",*"
				if vg_ms_installation = "Y"
				and vg_ms_fault_codes matches vl_comp_code
				and length(vr_comp.comp_code)
				then
					let vl_change_service = true
					exit construct
				end if
			end if

		on action cancel
			let vg_title = "Abort ", downshift(vg_comp_title) clipped, " query"
			if continue_yn(vg_title)
			then
				let int_flag = true
				exit construct
			else
				let int_flag = false
			end if

		on action close
			let vg_title = "Abort ", downshift(vg_comp_title) clipped, " query"
			if continue_yn(vg_title)
			then
				let int_flag = true
				exit construct
			else
				let int_flag = false
			end if

		on action f2_lookup
			let vr_comp.build_no = get_fldbuf(build_no)
			let vr_comp.build_name = get_fldbuf(build_name)
			let vr_comp.location_name = get_fldbuf(location_name)
			let vr_comp.location_desc = get_fldbuf(location_desc)
			let vr_comp.service_c = get_fldbuf(service_c) 
			let vr_comp.item_ref = get_fldbuf(item_ref)
			case
				when infield(assigned_to)
				   call correspond_assign_lookup()
				when infield(entered_by)
					let vr_comp.entered_by = userinfo_look()
					display vr_comp.entered_by to entered_by
					message " "
					call set_query_comp_options()
					next field entered_by

				when infield(postcode)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"P", 
												false)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"P", 
												false)
								returning vl_site_ref
						end if

						call set_query_comp_options()
						call find_and_display_property(vl_site_ref, true)

						next field postcode
					end if

				when infield(build_no)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"B#", 
												false)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"B#", 
												false)
								returning vl_site_ref
						end if

						call set_query_comp_options()
						call find_and_display_property(vl_site_ref, true)

						next field build_no
					end if

				when infield(build_name)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"BN", 
												false)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"BN", 
												false)
								returning vl_site_ref
						end if

						call set_query_comp_options()
						call find_and_display_property(vl_site_ref, true)

						next field build_name
					end if

				when infield(location_name)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"L", 
												false)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"L", 
												false)
								returning vl_site_ref
						end if

						call set_query_comp_options()
						call find_and_display_property(vl_site_ref, true)

						next field location_name
					end if

				when infield(location_desc)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"L", 
												false)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"L", 
												false)
								returning vl_site_ref
						end if

						call set_query_comp_options()
						call find_and_display_property(vl_site_ref, true)

						next field location_desc
					end if

				when infield(area_ward_desc)
					if skey_check("DISP_WARD_OR_AREA", "ALL") = "Y" 
					then
						let vl_area_code = general_look(
							"area",
							"area_c", "Area Code",
							"area_name", "Name"
							)
						if length(vl_area_code)
						then
							select area_name 
								into vr_qry_comp.area_ward_desc 
							from area
							where area_c = vl_area_code

							display by name vr_qry_comp.area_ward_desc
						end if
					else
						let vl_ward_code = general_look(
							"ward",
							"ward_code", "Ward Code",
							"ward_name", "Name"
							)
						if length(vl_ward_code)
						then
							select ward_name 
								into vr_qry_comp.area_ward_desc 
							from ward
							where ward_code = vl_ward_code

							display by name vr_qry_comp.area_ward_desc
						end if
					end if
					call set_query_comp_options()
					next field area_ward_desc

				when infield(comp_code)
					let vr_comp.comp_code = list_flt_codes("", "", "", "")
					display vr_comp.comp_code to comp_code
					message " "
					call set_query_comp_options()
					next field comp_code

				when infield(recvd_by)
					call allk_look("CTSRC", "", "")
						returning vr_comp.recvd_by
					display vr_comp.recvd_by to recvd_by
					message " "
					call set_query_comp_options()
					next field recvd_by

				when infield(service_c)
					let vr_qry_comp.service_c = get_fldbuf(service_c)
					let vg_comp_save.service_c = vr_qry_comp.service_c
					let vr_qry_comp.service_c = service_look()
					if not length(vr_qry_comp.service_c)
					then
						let vr_qry_comp.service_c = vg_comp_save.service_c
					end if
					display vr_qry_comp.service_c to service_c
					message " "
					call set_query_comp_options()
#					next field service_c
        			let vr_comp.service_c = get_fldbuf(service_c)
                    let vr_qry_comp.service_c = get_fldbuf(service_c)

                    display by name vr_qry_comp.service_c

                    if length(vl_lock_service_c)
                    THEN
                        if vl_lock_service_c != vr_qry_comp.service_c
                        THEN
                            call valid_error("",
                                "The service cannot be changed at this point", "")
                            let vr_comp.service_c = vl_lock_service_c
                            let vr_qry_comp.service_c = vl_lock_service_c
                            display by name vr_qry_comp.service_c
                            next field service_c
                        end IF
                    end IF
                    if not valid_user_service(vr_comp.service_c)
                    THEN
                        next field service_c
                    end IF

                    if vr_comp.service_c = vg_hway_service
                        and vg_hway_installation = "Y"
                    THEN
                        let vl_change_service = TRUE
                        exit CONSTRUCT
                    end IF
                    if vr_comp.service_c = vg_av_service
				        and vg_av_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        # WEEE
			        if vr_comp.service_c = vg_weee_service
				        and vg_weee_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        # WEEE SALES
			        if vr_comp.service_c = vg_weee_sales_service
				        and vg_sales_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_sl_service
				        and vg_sl_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_gm_service
				        and vg_gm_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_ert_service
				        and vg_ert_installation = "Y"
#				        and fgl_lastkey() != fgl_keyval("accept") # BJG 02/07/3012 - Workflow 3381
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_trees_service
				        and vg_trees_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_enf_service
				        and vg_enf_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_enf_trade_service
				        and vg_enf_trade_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_nappy_service
				        and vg_nappy_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_clin_service
				        and vg_clin_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_trade_service
				        and vg_trade_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_agreq_service
				        and vg_agreq_installation = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_sched_service
				        and vg_sched_installation = "Y"
				        and vg_weee_installation = "N"
				        and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end if
			        if vr_comp.service_c = vg_sched_service
				        and vg_sched_installation = "Y"
				        and vg_weee_installation = "Y"
				        and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
			        then
				        let vl_change_service = true
				        exit construct
			        end IF            
                    next field complaint_no # BJG 02/07/3012 - Workflow 3381

				when infield(item_ref)
					let vr_qry_comp.service_c = get_fldbuf(service_c)
					call item_look("","", vr_qry_comp.service_c)
						returning vr_qry_comp.item_ref, vg_null
					display vr_qry_comp.item_ref to item_ref
					message " "
					call set_query_comp_options()
					next field item_ref

				when infield(compl_init)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(1)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_query_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if
					next field compl_name
					
				when infield(compl_name)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(2)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_query_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if
					next field compl_name
					
				when infield(compl_surname)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(3)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_query_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if
					next field compl_name

				when infield(compl_business)
				or infield(compl_postcode)
				or infield(compl_build_no)
				or infield(compl_build_name)
				or infield(compl_addr2)
				or infield(compl_addr3)
				or infield(compl_addr4)
				or infield(compl_addr5)
				or infield(compl_addr6)
				or infield(compl_fax)
				or infield(compl_email)
				or infield(compl_mobile)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(4)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_query_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if
					next field compl_name
					
				otherwise
					call valid_error
						("","No lookup available on this field","")
			end case
		
		#ADJ GENERO
		{
		on key(f6)
			call join()
			call set_query_comp_options()
		}

		{
		on action import
			call query_import(true)
				returning vl_imp_part
			if int_flag
			then
				let int_flag = false
			end if
			call set_query_comp_options()

		on action import_page
			call query_import(true)
				returning vl_imp_part
			if int_flag
			then
				let int_flag = false
			end if
			call set_query_comp_options()
		}

		{
		on action Text
			if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
			then
				OPEN WINDOW iw_txt_qry AT 6,2 WITH FORM "comp_nbqry"
			else
				OPEN WINDOW iw_txt_qry AT 7,12 WITH FORM "comp_nb"
				display "OK" TO btok
			end if
#			display "OK" TO btok
#			display "Cancel" TO btcan #cancel
			let vg_title = upshift(vg_comp_title) clipped, " TEXT QUERY"
			display vg_title clipped at 1,2

			construct by name vl_txt_part on
								comp_text.username,
								comp_text.doa,
								comp_text.txt

				before construct
					if vl_comp_text.doa < "01/01/1900"
					then
						let vl_comp_text.doa = null
					end if
					display by name vl_comp_text.username,
									vl_comp_text.doa,
									vl_comp_text.txt
			
				after construct
					let vl_comp_text.username = get_fldbuf(username)
					let vl_comp_text.doa = get_fldbuf(doa)
					let vl_comp_text.txt = get_fldbuf(txt)

			end construct
			if int_flag
			then
				let int_flag = false
			end if
			close window iw_txt_qry 
		}

		on action Detail
			let vr_comp.service_c = get_fldbuf(service_c)
			if length(vr_comp.service_c)
			then
				if (vg_ert_installation = "Y" 
				and vr_comp.service_c = vg_ert_service)
				then
					let vl_ret_where_part = query_ert_information()
					if length(vl_ret_where_part)
					then
						let vl_det_where_part = vl_ret_where_part
					end if
				else
					if (vr_comp.service_c = vg_dart_service 
					and vg_dart_installation = "Y")
					then
						let vl_ret_where_part = query_dart_information()
						if length(vl_ret_where_part)
						then
							let vl_det_where_part = vl_ret_where_part
						end if
					else 
						if (vr_comp.service_c = vg_sw_service
						and vg_sw_installation = "Y")
						then
							let vr_qry_comp.item_ref = get_fldbuf(item_ref)

							select warden_item_type
								into vl_warden_item_type
							from warden_item
								where item_ref = vr_qry_comp.item_ref

							if vl_warden_item_type matches "[VLPC]"
							then
								let vl_ret_where_part =
									query_warden_information
									(vl_warden_item_type)
								if length(vl_ret_where_part)
								then
									let vl_det_where_part = vl_ret_where_part
								end if
							else
								let vr_qry_comp.date_entered = 
									get_fldbuf(date_entered)
								let vr_qry_comp.ent_time_h = 
									get_fldbuf(ent_time_h)
								let vr_qry_comp.ent_time_m = 
									get_fldbuf(ent_time_m)
								let vr_qry_comp.entered_by = 
									get_fldbuf(entered_by)
								let vr_qry_comp.recvd_by = 
									get_fldbuf(recvd_by)
								let vr_qry_comp.exact_location = 
									get_fldbuf(exact_location)
								call query_sw_information()
									returning vl_ret_where_part, 
											vl_ret_where_part_ii
								if length(vl_ret_where_part)
								or length(vl_ret_where_part_ii)
								then
									let vl_det_where_part = 
										vl_ret_where_part
									let vl_det_where_part_ii = 
										vl_ret_where_part_ii
									display by name vr_qry_comp.date_entered
									display by name vr_qry_comp.ent_time_h
									display by name vr_qry_comp.ent_time_m
									display by name vr_qry_comp.entered_by
									display by name vr_qry_comp.exact_location
								end if
							end if
						else
							call valid_error("", 
						"There is no detail associated with this service", "")
						end if
					end if
				end if
			else
				call valid_error("",
					"A valid service must be entered", "")
			end if

	end construct

	call f.setElementHidden("import_page",true)
	call f.setElementHidden("text_page",false)
	call f.setElementHidden("text_query_page",true)

	if int_flag
	then
		call set_comp_options()
		let int_flag = false
		return "", "", "", "", "", "I"
	end if
	call set_comp_options()

	if vl_change_service
	then
		return "", "", "", "", "", vr_comp.service_c
	end if	
	if vl_where_part matches "*comp.entered_by=*"
	then
		if length(vr_qry_comp.entered_by)
		then
			let vl_qry_string = "(comp.entered_by = '",
										downshift(vr_qry_comp.entered_by) clipped,
										"' or comp.entered_by='",
										upshift(vr_qry_comp.entered_by) clipped,
										"') and comp.site_ref !="
			let vl_where_part = 
				replace_string(vl_where_part, 
							"comp.entered_by=",
							vl_qry_string)
		end if
	end if
	return vl_where_part, 
			vl_txt_part, 
			vl_det_where_part, 
			vl_det_where_part_ii, 
			vl_imp_part, 
			"A"

end function	# query_normal_complain


function get_hway_info() 
	define 
		vl_text				char(60),
		vl_engineer_ref		like hway_status.engineer_ref

	initialize vr_comp_hway.* to null

	select * 
		into vr_comp_hway.*
	from comp_hway
		where complaint_no = vr_comp.complaint_no

#	display by name vr_comp_hway.current_status, 
	display by name vr_comp_hway.status_change_date, 
					vr_comp_hway.contractor_ref

	display vr_comp_hway.current_status to comp_hway.current_status

	display vr_comp_hway.pa_area to hway_pa_area

#	display vr_comp.date_closed using "dd/mm/yy" to status_change_date
	call show_attach_flag()

	let vl_text = get_allk_desc(vr_comp.comp_code, "HWYDEF")
	display vl_text to hway_fault_desc

	let vl_text = get_allk_desc(vr_comp_hway.pa_area, "PATRL")

	call get_site_pa_area(vr_comp.site_ref, "HWYENG")
		returning vl_engineer_ref, vg_null
	display vl_engineer_ref to engineer_ref
	let vl_text =
		get_allk_desc(vl_engineer_ref, "HWYENG")
	display vl_text to engineer_desc

	let vl_text = get_allk_desc(vr_comp_hway.current_status,"HWYST")
	display vl_text to hw_status_desc

end function	# get_hway_info 


function get_measurement_info() 
	define 
		vl_text				char(60)

	initialize vr_comp_measurement.* to null

	select * 
		into vr_comp_measurement.*
	from comp_measurement
		where complaint_no = vr_comp.complaint_no

	display by name vr_comp_measurement.x_value, 
					vr_comp_measurement.y_value, 
					vr_comp_measurement.linear_value,
					vr_comp_measurement.area_value,
					vr_comp_measurement.priority

end function	# get_measurement_info 


function get_si_i()
	define vl_count	smallint

	declare si_i_lk_curs cursor for
		select * 
			from si_i,item
		where site_ref = vr_comp.site_ref
			and item.service_c = vr_comp.service_c
			and item.item_ref = vr_comp.item_ref
			and item.item_ref = si_i.item_ref
			and item.contract_ref = si_i.contract_ref

	let vl_count = 0

	foreach si_i_lk_curs into vr_si_i.*
		let vl_count = vl_count + 1
	end foreach

	return vl_count

end function	# get_si_i


function disp_hist_message()
	if skey_check("AUTO_CHK_DUP_COMP","ALL") = "Y"
		and length(vr_comp.location_name)
	then
		let vg_comp_save.* = vr_comp.*
		let vg_customer_save.* = vr_customer.*
		call history_save_text(true)	
		let m_comp_arr_count = 0

		call prompt_for_scroll(false,"L")

		let vr_comp.* = vg_comp_save.*
		let vr_customer.* = vg_customer_save.*
		call history_save_text(false)	
		call set_add_comp_options()
		let vg_show_source = false
		let vg_action_type = true
	else
#		message "Press ESC to add data; Interrupt(Ctrl C) to abort"
		options error line 2
		let vg_title = 
			"Use F7 to display previous ", downshift(vg_record_title) clipped,
			" for this property/street."
		error vg_title
		options error line last
	end if	
end function	# disp_hist_message


function add_normal_complain(vl_comp_code_flag)
	define
		vlr_comp_ert_dtl_log	record like comp_ert_dtl_log.*,
		vlr_comp_dart_dtl_log	record like comp_dart_dtl_log.*,
		vl_diry_ref				like diry.diry_ref,
		vl_build_no				like comp.build_no,
		vl_build_name			like comp.build_name,
		vl_location_name		like comp.location_name,
		vl_location_desc		like comp.location_desc,
		vl_item_ref				like comp.item_ref,
		vl_postcode				like comp.postcode,
		vl_comp_cde				like comp.comp_code,
		vl_save_comp			like comp.complaint_no,
		vl_site_ref				like site.site_ref,
		vl_user					like diry.source_user,
		vl_service				like comp.service_c,
		vl_ward_code        	like ward.ward_code,
		vl_service_desc			like keys.c_field,
		f_loop					smallint,
		vl_service_change		smallint,
		vl_comp_code_change		smallint,
		vl_comp_code_flag		smallint,
		vl_addr_exists			smallint,		
		locn_length				smallint,
		vl_count				smallint,
		vl_loop					smallint,
		vl_rec_count			smallint,			
		from_location_name		smallint,
		locn_rec_defined		smallint,
		site_rec_defined		smallint,
		vl_serv_cnt				smallint,
		si_i_rec_defined		smallint,
#		vl_compln_flag 			smallint,
		vl_f43_pressed			smallint,
		vyyl_comp_code_flag		smallint,
		vl_first				smallint,
		vl_comp_code			char(10),
		vl_tmp_char				char(80),
		vl_mess					char(175),
		vl_district				char(40),
		temp_desc				char(20),
		f_lastfield				char(12),
		vl_comp_char			char(12),
		temp_code				char(12),
		vl_time_h				char(2),
		vl_time_m				char(2),
		print_action			char(1),
		vl_exit_flag			char(1),
		vl_null					char(1),
		vl_cont_prmpt			char(1),
		vl_cc_flag				char(1),
		vl_ans 					char(1),
		vl_search				char(100),
		vl_runstr				char(255),
		vl_area_flag        	char(1),
		vl_old_data				char(5000),
		vl_new_data				char(5000),
		vl_si_i_rec_defined		smallint,
		vl_service_c			like comp.service_c,
		vl_task_ref				like agree_task.task_ref,
		vl_agreement_no			like agree_task.agreement_no,
		vl_insp_item_flag		like item.insp_item_flag,
		f_action_flag			like comp_action.action_flag,
		f_save_action_flag	like comp_action.action_flag
#		cb 						ui.ComboBox

	define
		vl_ww_loop			smallint,
		vl_redisplay		smallint,	
		vl_arr_count		smallint,
		vl_ac				smallint,
		vl_sc				smallint,
		vl_lines			smallint,
		vl_hours			char(2),
		vl_mins				char(2),
		vl_tmp_txt			char(60),
		vl_wordwrap			char(60),
		vl_curs_pos			smallint,
		vl_seq				like comp_text.seq,
		vl_comp_text_seq	array[500] of integer,
		vl_comp_det_text_u	array[500] of record
			doa					date,
			username			like comp_text.username,
			txt					like comp_text.txt
		end record

	let vl_lines = 500
	call add_comp_of()
	clear form
	call complain_labels()

	let vl_seq = 0
	let vg_cur_pos = 1
	let vl_wordwrap = null
	let vl_curs_pos = 0
	let vl_null = null

	let locn_rec_defined = false
	let site_rec_defined = false
	let si_i_rec_defined = false
	let vg_location_flag = false
	let vg_f2_pressed = false
	let vl_f43_pressed = false
	if vg_customer_retain
	then
		let vg_f3_pressed = true
	else
		let vg_f3_pressed = false
	end if
#	let vl_compln_flag = false
	let vl_service_change = false
	let vl_comp_code_change = false


	if not vl_comp_code_flag
	then
		call init_comp_values()
		let vl_old_data = vr_comp.*, remarks_line, vr_customer.*

		if vg_add_multi_complaints = "Y"
		then
			call find_and_display_property(vr_comp.site_ref, true)
			call display_item_info() 
			call display_comp_code_info()
			if skey_check("MULTI_COMPLAINTS_TXT","ALL") = "N"
			and not vg_enforce_ref
			and vg_replication = "N"
			then
				call reset_text()
				let m_comp_arr_count = 0
			end if
		else
			if not vg_enforce_ref
			then
				call reset_text()
				let m_comp_arr_count = 0
			else
				call find_and_display_property(vr_comp.site_ref, true)
			end if
		end if
		for vl_loop = 1 to 100
			initialize va_comp_ert_detail[vl_loop].* to null
			initialize va_comp_ert_detail_func[vl_loop].* to null
		end for
		initialize vr_comp_ert_tags.* to null
		let vr_comp.action_flag = check_comp_action_system_key(vr_comp.service_c)
	else
		call find_and_display_property(vr_comp.site_ref, true)
		call display_item_info() 
		call display_comp_code_info()
{
		let remarks_line = vr_comp.details_1 clipped, # " ",
							vr_comp.details_2 clipped, # " ",
							vr_comp.details_3 CLIPPED
}                            
        let remarks_line = form_remarks(vr_comp.details_1, vr_comp.details_2, vr_comp.details_3) 
	end if

	display by name vr_comp.entered_by
	display by name vr_comp.date_entered
	display by name vr_comp.ent_time_h
	display by name vr_comp.ent_time_m
	display by name vr_comp.item_ref
	display by name vr_comp.comp_code
	if length(vr_comp.comp_code)
	then
		select action_flag into f_action_flag from comp_action
			where comp_code = vr_comp.comp_code
		if status = notfound
		then
			initialize f_action_flag to null
		end if
		if length(f_action_flag)
		then
			if f_action_flag != vr_comp.action_flag
			then
				let vr_comp.action_flag = f_action_flag
			end if
		end if
	end if

	call display_recvd_info()
	call display_service_info()
	call display_status_info_box()

{
	let vl_mess =
	"Press ESC to enter new data; Interrupt(Ctrl C) to abort; F9 for Text"
	message vl_mess
}

	let int_flag = false
	let vl_first = true

#	call reset_text()

	#let vg_new_flycomp = false
	if check_install("FC") then
--#		call fgl_keysetlabel("f42", "Fly Capture")
	else	
--#		call fgl_keysetlabel("f42", "")
	end if
	if vg_ert_installation = "Y"
	or vg_dart_installation = "Y"
	or vg_sw_installation = "Y"
	then
--#		call fgl_keysetlabel("f43", "Detail")
	else	
--#		call fgl_keysetlabel("f43", "")
	end if

# remove Service request right hand side button from trees complaint
#	if skey_check( "SCHEDULE_MODULE", "ALL" ) = "Y" and
#	   skey_check( "TREES_SERVICE","ALL")<>"TREES"
	if vg_sched_installation = "Y" and
	   vg_trees_service <>"TREES" # BJG - What is this about????????
	then
--#		call fgl_keysetlabel( "control-s", "Service Request" )
		let vl_area_flag = skey_check( "SCHED_WARD_AREA", "ALL" )
	else
--#		call fgl_keysetlabel( "control-s", "" )
	end if

	call populate_action_combo("A", "ADWXHPIN", "generic_action_text")

#	let vr_comp.action_flag = check_comp_action_system_key(vr_comp.service_c)
	let generic_action_text = vr_comp.action_flag
	display generic_action_text to generic_action_text

	if skey_check("USE_INSPECTION_ITEMS", "ALL") = "Y" then
--#		call fgl_keysetlabel("f44", "Edit Due Date")
	else
--#		call fgl_keysetlabel("f44", "")
	end if

	let vl_comp_cde = " "
	call before_add_correspond()

	dialog attributes(unbuffered)
		input by name vr_comp.service_c,
					vr_comp.date_entered,
					vr_comp.ent_time_h,
					vr_comp.ent_time_m,
					vr_comp.recvd_by,
					vr_comp.build_no,
					vr_comp.build_name,
					vr_comp.location_name,
					vr_comp.location_desc,
					vr_comp.postcode,
					vr_comp.exact_location,
					vr_customer.compl_init,
					vr_customer.compl_name,
					vr_customer.compl_surname,
					vr_customer.compl_phone,
					vr_comp_clink.cust_satisfaction,
					vr_customer.int_ext_flag,
					vr_comp.item_ref,
					vr_comp.comp_code,
					remarks_line,
					generic_action_text,
					vr_customer.compl_business,
					vr_customer.compl_postcode,
					vr_customer.compl_build_no,
					vr_customer.compl_build_name,
					vr_customer.compl_addr2,
					vr_customer.compl_addr3,
					vr_customer.compl_addr5,
					vr_customer.compl_addr6,
					vr_customer.compl_addr4,
					vr_customer.compl_fax,
					vr_customer.compl_email,
					vr_customer.compl_mobile,
					vr_comp_correspond.corr_entered,
					vr_comp_correspond.date_due,
					vr_comp_correspond.date_response,
					vr_comp_correspond.assigned_to
					attributes(without defaults)

		before input
			call dialog.setActionHidden("txtedit", true)
			call dialog.setActionActive("txtedit", false)
			call dialog.setActionHidden("clear", true)
			call dialog.setActionActive("clear", false)
			call dialog.setActionActive("clear", false)
			call dialog.setActionHidden("txtedit", true)
			call dialog.setActionActive("txtedit", false)
			if skey_check("ALLOW_COMP_BACKDATE", "ALL") = "N"
			then
				call dialog.setFieldActive("date_entered", false)
				call dialog.setFieldActive("ent_time_h", false)
				call dialog.setFieldActive("ent_time_m", false)
			end if

		before field service_c
			if vr_comp.service_c is null 
			then 
				let vl_service = "NULL" 
			else 
				let vl_service = vr_comp.service_c 
			end if 
			if vl_first and vl_comp_code_flag
			then
				let vl_first = false
				next field comp_code
			end if

		after field service_c
			if length(vr_comp.service_c)
			then 
				if vl_service != vr_comp.service_c
				then
					let vl_search = "keys.service_c = '", 
									vr_comp.service_c clipped, "'"

					if no_of_rows("keys", vl_search, "") = 0
					then 
						let vl_mess = " The Service code ", vr_comp.service_c, 
							" does not exist" 
						call valid_error("",vl_mess,"")
						let vr_comp.service_c = vl_service
						display by name vr_comp.service_c
						call display_service_info()
						next field service_c 
					else
						if not valid_user_service(vr_comp.service_c)
						then
							next field service_c
						end if
						display by name vr_comp.service_c
						# Only a service change if not a "normal" service
						case
								when vr_comp.service_c = vg_av_service
								and vg_av_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_weee_service
								and vg_weee_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_weee_sales_service
								and vg_sales_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_enf_service
								and vg_enf_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_enf_trade_service
								and vg_enf_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_sl_service
								and vg_sl_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_gm_service
								and vg_gm_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_ert_service
								and vg_ert_installation = "Y"
								and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_trees_service
								and vg_trees_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_hway_service
								and vg_hway_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_nappy_service
								and vg_nappy_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_clin_service
								and vg_clin_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_trade_service
								and vg_trade_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_agreq_service
								and vg_agreq_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_sched_service
								and vg_sched_installation = "Y"
								and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
									let vl_service_change = true

							otherwise
								let vl_service_change = false
								let vr_comp.action_flag =
										check_comp_action_system_key(vr_comp.service_c)
								let generic_action_text = vr_comp.action_flag
								display generic_action_text to generic_action_text
						end case	
						if vl_service_change
						then
							exit dialog
						end if
					end if
				end if
				call display_service_info()
			else
				let vl_mess = "A valid service must be entered"
				call valid_error("",vl_mess,"")
				call display_service_info()
				next field service_c
			end if 

		after field date_entered
			if length(vr_comp.date_entered)
			then
				if vr_comp.date_entered < (today-7) 
				then
					call valid_error("", 
				"The date entered cannot be backdated more than seven days", 
						"")
					next field date_entered
				end if	
				if vr_comp.date_entered > today
				then
					call valid_error("", 
				"The date entered cannot be a future date", 
						"")
					next field date_entered
				end if
			else
				call valid_error("", "A valid date must be entered", "")
				next field date_entered
			end if

		after field ent_time_h
			if length(vr_comp.ent_time_h) then
				if vr_comp.date_entered = today
				then
					call get_time()
						returning vl_hours, vl_mins
	
					if vr_comp.ent_time_h > vl_hours
					then
						call valid_error("",
							"The time entered cannot be a future time", "")
						next field ent_time_h
					end if
				end if
			else
				call valid_error("", "A valid time must be entered", "")
				next field ent_time_h
			end if


		after field ent_time_m
			if length(vr_comp.ent_time_m) then
				if vr_comp.date_entered = today
				then
					call get_time()
						returning vl_hours, vl_mins

					if vr_comp.ent_time_h = vl_hours
					then
						if vr_comp.ent_time_m > vl_mins
						then
							call valid_error("",
								"The time entered cannot be a future time", "")
							next field ent_time_m
						end if
					end if
				end if
			else
				call valid_error("", "A valid time must be entered", "")
				next field ent_time_m
			end if

		after field corr_entered
			if not after_field_correspond("date_entered","A") then
				next field corr_entered
			end if
		after field date_due
			if not after_field_correspond("date_due","A") then
				next field date_due
			end if
		after field date_response
			if not after_field_correspond("date_response","A") then
				next field date_response
			end if
		after field assigned_to
			if not after_field_correspond("assigned_to","A") then
				next field assigned_to
			end if

		after field recvd_by
			if length(vr_comp.recvd_by)
			then
				let vl_search = "lookup_func = 'CTSRC' and lookup_code = '", 
					vr_comp.recvd_by clipped, "'", "and status_yn = 'Y'"

				if no_of_rows("allk", vl_search, "") = 0
				then
					let vl_mess = " The source code ", vr_comp.recvd_by clipped,
						" does not exist"
					call valid_error("", vl_mess, "")		
					next field recvd_by
				end if
				call display_recvd_info()
			else
				#display " " to lookup_char
			end if
	#		call display_recvd_info()	

		before field postcode
			if vr_comp.postcode is null 
			then 
				let vl_postcode = "NULL" 
			else 
				let vl_postcode = vr_comp.postcode 
			end if 

		after field postcode
			if vr_comp.postcode is not null
			then
				if vl_postcode != vr_comp.postcode
				then
					if vg_property_on
					then
						# The postcode has changed .. we should perform an
						# automatic lookup on this postcode
						
						call postcode_look(vr_comp.postcode, 
											 "", "", "", "", true, "P", true)
							returning vl_site_ref

						call set_add_comp_options()

						call find_and_display_property(vl_site_ref, true)

						if not length(vl_site_ref)
						then
							let vr_comp.site_ref = null
							let vr_comp.location_c = null
							next field postcode
						else
	#						call get_comp_site_items(false)
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property(vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = true
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
							call disp_hist_message()
						end if
					end if
				end if
			# BJG - 12/02/2010 - start
			else
				if vl_postcode != "NULL"
				then
					# We did have a postcode but now have null
					let vr_comp.site_ref = null
					let vr_comp.location_c = null
#					next field postcode
				end if
				# BJG - 12/02/2010 - end
			end if

		before field build_no
			if vr_comp.build_no is null 
			then 
				let vl_build_no = "NULL" 
			else 
				let vl_build_no = vr_comp.build_no 
			end if 

		after field build_no
			if vr_comp.build_no is not null
			then
				if vl_build_no != vr_comp.build_no
				then
					if vg_property_on
					then
		#						if length(vr_comp.postcode) 
						if length(vr_comp.location_name)
						then
							if length(vr_comp.location_desc)
							and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
							then
								#call postcode_look(vr_comp.postcode,
								call postcode_look("",
													vr_comp.build_no,
													#vr_comp.build_name,
													"",
													vr_comp.location_desc,
													vr_comp.service_c,
													true,
													"B#",
													true)
								returning vl_site_ref
							else
								call postcode_look("",
													vr_comp.build_no,
													#vr_comp.build_name,
													"",
													vr_comp.location_name,
													vr_comp.service_c,
													true,
													"B#", 
													true)
									returning vl_site_ref
							end if

							call set_add_comp_options()

							if length(vl_site_ref)
							then
								call find_and_display_property(vl_site_ref,true)
	#							call get_comp_site_items(false)
								if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
								then
									call get_comp_site_items(true)
										returning vl_si_i_rec_defined, vl_service_c,
										vl_task_ref, vl_agreement_no
								else
									call get_comp_site_items(false)
										returning vl_si_i_rec_defined, vl_service_c,
										vl_task_ref, vl_agreement_no
								end if
								if vr_comp.site_ref != vr_si_i.site_ref
								then
									let vg_f3_pressed = true
									let vg_customer_retain = true
									call find_and_display_property(vr_si_i.site_ref, true)
								end if
								if vl_si_i_rec_defined = 2
								then
									let vl_service_change = true
									let vr_comp.service_c = vl_service_c
									exit dialog
								end if
								call disp_hist_message()
							else
								let vr_comp.site_ref = null
								let vr_comp.location_c = null
								next field build_no
							end if
						end if
					end if
				end if
			# BJG - 12/02/2010 - start
			else
				if vl_build_no != "NULL"
				then
					# We did have a build_no but now have null
					let vr_comp.site_ref = null
					let vr_comp.location_c = null
#					next field build_no
				end if
				# BJG - 12/02/2010 - end
			end if

		before field build_name
			if vr_comp.build_name is null 
			then 
				let vl_build_name = "NULL" 
			else 
				let vl_build_name = vr_comp.build_name
			end if 

		after field build_name
			if vr_comp.build_name is not null
			then
				if vr_comp.build_name != vl_build_name
				then
					if vg_property_on	
					then
						if length(vr_comp.location_name)
						then
							if length(vr_comp.location_desc)
							and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
							then
								call postcode_look("",
													"",
													vr_comp.build_name,
													vr_comp.location_desc,
													vr_comp.service_c,
													true,
													"BN", 
													true)
									returning vl_site_ref
								else
									call postcode_look("",
														"",
														vr_comp.build_name,
														vr_comp.location_name,
														vr_comp.service_c,
														true,
														"BN", 
														true)
										returning vl_site_ref
							end if

							call set_add_comp_options()

							if length(vl_site_ref)
							then
								call find_and_display_property(vl_site_ref,true)
	#							call get_comp_site_items(false)
								if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
								then
									call get_comp_site_items(true)
										returning vl_si_i_rec_defined, vl_service_c,
										vl_task_ref, vl_agreement_no
								else
									call get_comp_site_items(false)
										returning vl_si_i_rec_defined, vl_service_c,
										vl_task_ref, vl_agreement_no
								end if
								if vr_comp.site_ref != vr_si_i.site_ref
								then
									let vg_f3_pressed = true
									let vg_customer_retain = true
									call find_and_display_property(vr_si_i.site_ref, true)
								end if
								if vl_si_i_rec_defined = 2
								then
									let vl_service_change = true
									let vr_comp.service_c = vl_service_c
									exit dialog
								end if
								call disp_hist_message()
							else
								let vr_comp.site_ref = null
								let vr_comp.location_c = null
								next field build_name
							end if
						end if	
					end if
				end if
			# BJG - 12/02/2010 - start
			else
				if vl_build_name != "NULL"
				then
					# We did have a build_name but now have null
					let vr_comp.site_ref = null
					let vr_comp.location_c = null
#					next field build_name
				end if
				# BJG - 12/02/2010 - end
			end if

		before field location_name 
			if vr_comp.location_name is null 
			then 
				let vl_location_name = "NULL" 
			else 
				let vl_location_name = vr_comp.location_name 
			end if 

		after field location_name
			if vr_comp.location_name is not null
			then
				if vl_location_name != vr_comp.location_name
				then
					if vg_property_on
					then
						if length(vr_comp.build_no) 
							or length(vr_comp.build_name)
						then
							if length(vr_comp.location_desc)
							and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
							then
								call postcode_look(vr_comp.postcode,
													vr_comp.build_no,
													vr_comp.build_name,
													vr_comp.location_desc,
													vr_comp.service_c,
													true,
													"L", 
													true)
									returning vl_site_ref
							else
								call postcode_look(vr_comp.postcode,
													vr_comp.build_no,
													vr_comp.build_name,
													vr_comp.location_name,
													vr_comp.service_c,
													true,
													"L", 
													true)
								returning vl_site_ref
							end if

							call set_add_comp_options()

							if length(vl_site_ref)
							then
								call find_and_display_property(vl_site_ref,true)
	#							call get_comp_site_items(false)
								if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
								then
									call get_comp_site_items(true)
										returning vl_si_i_rec_defined, vl_service_c,
										vl_task_ref, vl_agreement_no
								else
									call get_comp_site_items(false)
										returning vl_si_i_rec_defined, vl_service_c,
										vl_task_ref, vl_agreement_no
								end if
								if vr_comp.site_ref != vr_si_i.site_ref
								then
									let vg_f3_pressed = true
									let vg_customer_retain = true
									call find_and_display_property(vr_si_i.site_ref, true)
								end if
								if vl_si_i_rec_defined = 2
								then
									let vl_service_change = true
									let vr_comp.service_c = vl_service_c
									exit dialog
								end if
								call disp_hist_message()
							else
								let vr_comp.site_ref = null
								let vr_comp.location_c = null
								next field location_name
							end if
						else
							select count(*) into vl_rec_count
								from locn
							where location_name = vr_comp.location_name

							case vl_rec_count 
								when 0
									call valid_error("",
										"A valid road name must be entered", "")
									next field location_name
								when 1
									select locn.* into vr_locn.*
										from locn 
									where location_name = vr_comp.location_name

									select site.* into vr_site.*
										from site
									where location_c = vr_locn.location_c
#										and site_ref matches "*S"
										and site_c = "S"
										and site_status = "L"

									if status != notfound
									then
										call find_and_display_property
											(vr_site.site_ref, true)
										if length(vr_comp.location_desc)
										and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
										then
											let vl_mess = 
												"Select items of work for ", 
												vr_comp.location_desc clipped
										else	
											let vl_mess = 
												"Select items of work for ", 
												vr_comp.location_name clipped
										end if
										if continue_yn(vl_mess)
										then
	#										call get_comp_site_items(false)
											if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
											then
												call get_comp_site_items(true)
													returning vl_si_i_rec_defined, vl_service_c,
													vl_task_ref, vl_agreement_no
											else
												call get_comp_site_items(false)
													returning vl_si_i_rec_defined, vl_service_c,
													vl_task_ref, vl_agreement_no
											end if
											if vr_comp.site_ref != vr_si_i.site_ref
											then
												let vg_f3_pressed = true
												let vg_customer_retain = true
												call find_and_display_property
																			(vr_si_i.site_ref, true)
											end if
											if vl_si_i_rec_defined = 2
											then
												let vl_service_change = true
												let vr_comp.service_c = vl_service_c
												exit dialog
											end if
											call disp_hist_message()
										end if
									end if
										
								otherwise
									call postcode_look("",
														"",
														"",
														vr_comp.location_name,
														vr_comp.service_c,
														true,
														"L", 
														true)
										returning vl_site_ref

									call set_add_comp_options()

									if length(vl_site_ref)
									then
										call find_and_display_property
											(vl_site_ref,true)
	#									call get_comp_site_items(false)
										if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
										then
											call get_comp_site_items(true)
												returning vl_si_i_rec_defined, vl_service_c,
												vl_task_ref, vl_agreement_no
										else
											call get_comp_site_items(false)
												returning vl_si_i_rec_defined, vl_service_c,
												vl_task_ref, vl_agreement_no
										end if
										if vr_comp.site_ref != vr_si_i.site_ref
										then
											let vg_f3_pressed = true
											let vg_customer_retain = true
											call find_and_display_property
																		(vr_si_i.site_ref, true)
										end if
										if vl_si_i_rec_defined = 2
										then
											let vl_service_change = true
											let vr_comp.service_c = vl_service_c
											exit dialog
										end if
										call disp_hist_message()
									else
										let vr_comp.site_ref = null
										let vr_comp.location_c = null
										next field location_desc
									end if
							end case
						end if	
					end if
				end if
			# BJG - 12/02/2010 - start
			else
				if vl_location_name != "NULL"
				then
					# We did have a postcode but now have null
					let vr_comp.site_ref = null
					let vr_comp.location_c = null
#					next field location_name
				end if
				# BJG - 12/02/2010 - end
			end if

		before field location_desc
			if vr_comp.location_desc is null 
			then 
				let vl_location_desc = "NULL"
			else 
				let vl_location_desc = vr_comp.location_desc 
			end if 

		after field location_desc
			if vr_comp.location_desc is not null
			then
				if vr_comp.location_desc != vl_location_desc
				then
					if vg_property_on
					then
						call postcode_look(vr_comp.postcode,
											vr_comp.build_no,
											vr_comp.build_name,
											vr_comp.location_desc,
											vr_comp.service_c,
											true,
											"L", 
											true)
							returning vl_site_ref

						call set_add_comp_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref,true)
	#						call get_comp_site_items(false)
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property (vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = true
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
							call disp_hist_message()
						else
							let vr_comp.site_ref = null
							let vr_comp.location_c = null
							next field location_desc
						end if
					end if
				end if	
			# BJG - 12/02/2010 - start
			else
				if vl_location_desc != "NULL"
				then
					# We did have a postcode but now have null
					let vr_comp.site_ref = null
					let vr_comp.location_c = null
#					next field location_desc
				end if
				# BJG - 12/02/2010 - end
			end if

		before field compl_init
			#ADJ GENERO
			{
			if vl_compln_flag
			then
				let vl_compln_flag = false
				if not add_complainant(true, false, "A")
				then
					call display_add_comp_info(true)
				end if
			end if
			}

		after field cust_satisfaction
			if length(vr_comp_clink.cust_satisfaction)
			then
				if vg_cs_update = "Y"
				and vg_cs_installation = "Y"
				then
					if vr_comp_clink.cust_satisfaction 
						not matches "[YN]"
					then
						call valid_error("",
							"A valid value must be entered", "")
						next field cust_satisfaction
					end if
				else
					if vr_comp_clink.cust_satisfaction != vg_cs_flag
					then
						call valid_error("",
	"The customer satisfaction survey flag cannot be changed at this point", 
							"")
						let vr_comp_clink.cust_satisfaction = vg_cs_flag
						display by name vr_comp_clink.cust_satisfaction
					end if
				end if
			else
				call valid_error("",
					"A valid value must be entered", "")
				next field cust_satisfaction
			end if

		after field int_ext_flag
			if length(vr_customer.int_ext_flag)
			then
				if vr_customer.int_ext_flag not matches "[IE]"
				then
					call valid_error("",
						"A valid value must be entered", "")
					next field int_ext_flag
				end if
			else
				call valid_error("",
					"A valid value must be entered", "")
				next field int_ext_flag
			end if

		before field item_ref
			if vl_item_ref != "ERROR"
			or vl_item_ref is null
			then
				if vr_comp.item_ref is null 
				then 
					let vl_item_ref = "NULL" 
				else 
					let vl_item_ref = vr_comp.item_ref 
				end if 
			end if

		after field item_ref 
			 if length(vr_comp.item_ref)
			 then	 
				if vl_item_ref != vr_comp.item_ref
				then
					let vl_search = "item_ref = '", 
						vr_comp.item_ref clipped, "'"

					if no_of_rows("item", vl_search, "") = 0 
					then 
						let vl_mess = " The site item ", 
							vr_comp.item_ref clipped, " does not exist" 
						call valid_error("",vl_mess,"")
						next field item_ref 
					end if 

					let vl_rec_count = get_si_i()
					case 
						when vl_rec_count = 0
							call valid_error("",
		"A valid item must be selected for this site and service", "")
							initialize vr_si_i.* to null
							next field item_ref
						when vl_rec_count > 1
	#						call get_comp_site_items(false)
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property (vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = true
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
						otherwise
							# We have vr_si_i populated
					end case

					select customer_care_yn into vl_cc_flag from item
						where item_ref = vr_si_i.item_ref
						and contract_ref = vr_si_i.contract_ref

					if vl_cc_flag = "N"
					or status = notfound
					then
						call valid_error("",
							"This item cannot be accessed in this module",
							"")
						let vl_item_ref = "ERROR" 
						next field item_ref
					end if

					select count(*)
						into vl_rec_count
					from perm_items
						where ugroup = vg_ugroup
						and item_ref = vr_si_i.item_ref
						and contract_ref = vr_si_i.contract_ref

					if vl_rec_count
					then
						call valid_error("",
							"You do not have permission to select this item",
							"")
						let vl_item_ref = "ERROR" 
						next field item_ref
					end if
				end if
			else
				initialize vr_si_i.* to null
			end if 
			let vl_item_ref = null

			call display_item_info() 

{
		before field comp_code
			if length(vr_comp.comp_code)
			then
				let vl_comp_cde = vr_comp.comp_code
			else
				let vl_comp_cde = " "
			end if
}

		after field comp_code
			let vl_ans = null
			if vr_comp.comp_code is not null
			then
				if vl_comp_cde != vr_comp.comp_code
				then
					display "" to fault_desc 
					if skey_check("LIST_COMP_CODES", vr_comp.service_c) = "N"
					then			
						select count(*) 
							into vl_count
						from allk
							where lookup_func = "COMPLA"
							and lookup_code = vr_comp.comp_code
							and service_c = vr_comp.service_c
							and status_yn = "Y"

						if not vl_count 
						then
							let vl_mess = "The fault ", 
								vr_comp.comp_code clipped,
								" has not been set up for the service", 
								vr_comp.service_c

							call valid_error("", vl_mess, "")
							next field comp_code
						end if
					end if

					select status_yn
						into vl_ans
					from allk
						where lookup_func = "COMPLA"
						and lookup_code = vr_comp.comp_code

					case vl_ans
						when "Y"
							if skey_check("COMP CODE>ITEM LINK", "ALL" ) = "Y" 
								and length(vr_comp.item_ref)
							then
								select count(*)
									into vl_count
								from it_c
									where it_c.item_ref = vr_comp.item_ref
										and it_c.comp_code = vr_comp.comp_code

								if not vl_count
								then
									let vl_mess = "The Fault Code ", 
										vr_comp.comp_code clipped, 
										" is not valid ",
										"for the selected item ", 
										vr_si_i.item_ref clipped , "."
					
									call valid_error("",vl_mess,"")
									next field comp_code
								end if
							end if
							call set_notice_type()
						when "N"
							let vl_mess = "The fault code '", 
								vr_comp.comp_code clipped, 
								"' exists but has been disabled."

							call valid_error("",vl_mess,"")
							next field comp_code
						otherwise
							let vl_mess = "The fault code '", 
								vr_comp.comp_code clipped, 
								"' does not exist.  A valid code must be entered"
							call valid_error("",vl_mess,"")
							next field comp_code
					end case
					call display_comp_code_info()

					#ADJ MEASUREMENT TODO
					let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
					if vg_ms_installation = "Y"
					and vg_ms_fault_codes matches vl_comp_code
					and length(vr_comp.comp_code)
					then
						let vl_comp_code_change = true
						exit dialog
					end if

					select action_flag into f_action_flag from comp_action
						where comp_code = vr_comp.comp_code
					if status = notfound
					then
						initialize f_action_flag to null
					end if
					if length(f_action_flag)
					then
						if f_action_flag != vr_comp.action_flag
						then
							let vr_comp.action_flag = f_action_flag
							let generic_action_text = vr_comp.action_flag
							display by name generic_action_text
						end if
					end if

				end if
			end if

	# ++++ BJG test phone number validation
		after field compl_phone
			if length(vr_customer.compl_phone)
			then
				call validate_phone_number("H","A",vr_customer.compl_phone)
					returning vl_count, vr_customer.compl_phone
				display by name vr_customer.compl_phone
				if not vl_count
				then
					next field compl_phone
				end if
			end if
	# ++++ BJG test phone number validation

	################################################################################
	# ADJ GENERO

		before field compl_postcode
			if vr_customer.compl_postcode is null 
			then 
				let vl_postcode = "NULL" 
			else 
				let vl_postcode = vr_customer.compl_postcode 
			end if 

		after field compl_postcode
			if vr_customer.compl_postcode is not null
			then
				if vl_postcode != vr_customer.compl_postcode
				then
					if vg_property_on
					then
						# The postcode has changed .. 
						# we should perform an
						# automatic lookup on this postcode
						
						call postcode_look(vr_customer.compl_postcode, 
									 "", "", "", "", true, "P", true)
							returning vl_site_ref

						call set_add_comp_ant_options()
						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref,
															false)
						end if
					end if
				end if
			end if

		before field compl_build_no
			if vr_customer.compl_build_no is null 
			then 
				let vl_build_no = "NULL" 
			else 
				let vl_build_no = vr_customer.compl_build_no 
			end if 

		after field compl_build_no
			if vr_customer.compl_build_no is not null
			then
				if vl_build_no != vr_customer.compl_build_no
				then
					if vg_property_on
					then
						if length(vr_customer.compl_addr2)
						then
							if length(vr_customer.compl_addr3)
							and vg_comp_loc_desc_town = "N"
							then
								call postcode_look("",
											vr_customer.compl_build_no,
											"",
											vr_customer.compl_addr3,
											"",
											true,
											"B#",
											true)
								returning vl_site_ref
							else
								call postcode_look("",
											vr_customer.compl_build_no,
											"",
											vr_customer.compl_addr2,
											"",
											true,
											"B#", 
											true)
									returning vl_site_ref
							end if
							call set_add_comp_ant_options()
							if length(vl_site_ref)
							then
								call find_and_display_property(
															vl_site_ref,
															false)
							end if
						end if
					end if
				end if
			end if

		before field compl_build_name
			if vr_customer.compl_build_name is null 
			then 
				let vl_build_name = "NULL" 
			else 
				let vl_build_name = vr_customer.compl_build_name
			end if 

		after field compl_build_name
			if vr_customer.compl_build_name is not null
			then
				if vr_customer.compl_build_name != vl_build_name
				then
					if vg_property_on	
					then
						if length(vr_customer.compl_addr2)
						then
							if length(vr_customer.compl_addr3)
							and vg_comp_loc_desc_town = "N"
							then
								call postcode_look("",
										"",
										vr_customer.compl_build_name,
										vr_customer.compl_addr3,
										"",
										true,
										"BN", 
										true)
									returning vl_site_ref
							else
								call postcode_look("",
										"",
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										"",
										true,
										"BN", 
										true)
									returning vl_site_ref
							end if
							call set_add_comp_ant_options()
							if length(vl_site_ref)
							then
								call find_and_display_property
														(vl_site_ref,
															false)
							end if
						end if	
					end if
				end if
			end if

		before field compl_addr2 
			if not length(vr_customer.compl_addr2)
			then 
				let vl_location_name = "NULL" 
			else 
				let vl_location_name = vr_customer.compl_addr2 
			end if 

		after field compl_addr2
			if length(vr_customer.compl_addr2)
			then
				if vl_location_name != vr_customer.compl_addr2
				then
					if vg_property_on
					then
						if length(vr_customer.compl_build_no) 
							or length(vr_customer.compl_build_name)
						then
							if length(vr_customer.compl_addr3)
							and vg_comp_loc_desc_town = "N"
							then
								call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr3,
										"",
										true,
										"L", 
										true)
									returning vl_site_ref
							else
								call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										"",
										true,
										"L", 
										true)
								returning vl_site_ref
							end if
							call set_add_comp_ant_options()
							if length(vl_site_ref)
							then
								call find_and_display_property(
									vl_site_ref,
									false)
							end if
						else
							select count(*) into vl_rec_count
								from locn
							where location_name 
								= vr_customer.compl_addr2

							if vl_rec_count = 1
							then
								select locn.* into vr_locn.*
									from locn 
								where location_name = 
									vr_customer.compl_addr2

								select site.* into vr_site.*
									from site
								where location_c = vr_locn.location_c
#									and site_ref matches "*S"
									and site_c = "S"
									and site_status = "L"

								if status != notfound
								then
									call find_and_display_property
										(vr_site.site_ref, false)
								end if
							end if
						end if	
					end if
				end if
			end if

		before field compl_addr3
			if vr_customer.compl_addr3 is null 
			then 
				let vl_location_desc = "NULL"
			else 
				let vl_location_desc = vr_customer.compl_addr3 
			end if 

		after field compl_addr3
			if vr_customer.compl_addr3 is not null
			then
				if vr_customer.compl_addr3 != vl_location_desc
				then
					if vg_property_on
					then
						call postcode_look(vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr3,
										"",
										true,
										"L", 
										true)
							returning vl_site_ref

						call set_add_comp_ant_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref,
								false)
						end if
					end if
				end if	
			end if

	# ++++ BJG test fax number validation
		after field compl_fax
			if length(vr_customer.compl_fax)
			then
				call validate_phone_number("F",
											"A",
											vr_customer.compl_fax)
					returning vl_count, vr_customer.compl_fax
				display by name vr_customer.compl_fax
				if not vl_count
				then
					next field compl_fax
				end if
			end if
	# ++++ BJG test fax number validation

	# ++++ BJG test mobile number validation
		after field compl_mobile
			if length(vr_customer.compl_mobile)
			then
				call validate_phone_number("M",
											"A",
											vr_customer.compl_mobile)
					returning vl_count, vr_customer.compl_mobile
				display by name vr_customer.compl_mobile
				if not vl_count
				then
					next field compl_mobile
				end if
			end if
# ++++ BJG test mobile number validation
# ADJ GENERO
################################################################################

		after field generic_action_text
			let vr_comp.action_flag = generic_action_text

		end input

################################################################################
		input array m_comp_det_text_u from sa_all_scroll.* 
			attributes(count=vl_lines, without defaults)

			before input
				call dialog.setActionHidden("delete", true)
				call dialog.setActionActive("delete", false)
				call dialog.setActionHidden("insert", true)
				call dialog.setActionActive("insert", false)
				call dialog.setActionHidden("append", true)
				call dialog.setActionActive("append", false)
				call dialog.setActionHidden("txtedit", false)
				call dialog.setActionActive("txtedit", true)
				call dialog.setActionHidden("clear", false)
				call dialog.setActionActive("clear", true)
				if vl_ac
				then
					if vl_ac < 13
					then
						if not vl_sc
						then
							let vl_sc = vl_ac
						end if
						call fgl_dialog_setcurrline(vl_sc, vl_ac)
					else
						if not vl_sc
						then
							let vl_sc = 8
						end if
						call fgl_dialog_setcurrline(vl_sc, vl_ac)
					end if
				end if

			after input
				for f_loop = 1 to 500
					let m_comp_text_u[f_loop].username = 
						m_comp_det_text_u[f_loop].username
					let m_comp_text_u[f_loop].doa =
						m_comp_det_text_u[f_loop].doa
					let m_comp_text[f_loop].txt = 
						m_comp_det_text_u[f_loop].txt

					if length(m_comp_text[f_loop].txt)
					then
						let m_comp_arr_count = f_loop
					end if
				end for
				call display_status_info_box()

			before field txt
				if arr_curr() > vl_ac + 1
				then
					call dialog.setCurrentRow("sa_all_scroll", vl_ac + 1)
					next field txt
				end if
				let vl_ac  = arr_curr()
				let vl_sc  = scr_line()
				if vl_curs_pos > 0 then
					call fgl_dialog_setcursor(vl_curs_pos)
				end if

				if m_comp_det_text_u[vl_ac].doa is null
				or m_comp_det_text_u[vl_ac].doa = "31/12/1899"
				or m_comp_det_text_u[vl_ac].doa = ""
				or m_comp_det_text_u[vl_ac].doa = " "
				then
					let m_comp_det_text_u[vl_ac].doa = TODAY
					display m_comp_det_text_u[vl_ac].doa 
						to sa_all_scroll[vl_sc].doa
				end if

				if m_comp_text_u[vl_ac].time_entered_h is null
				or m_comp_text_u[vl_ac].time_entered_h = ""
				or m_comp_text_u[vl_ac].time_entered_h = " "
				then
					call get_time() 
						returning m_comp_text_u[vl_ac].time_entered_h,
								m_comp_text_u[vl_ac].time_entered_m
				end if

				if vl_ac > vl_seq
				then
					display m_comp_det_text_u[vl_ac].doa 
						to sa_all_scroll[vl_sc].doa
				end if
					
#				if m_comp_det_text_u[vl_ac].username is null
				if not length(m_comp_det_text_u[vl_ac].username)
				then
					let m_comp_det_text_u[vl_ac].username = get_user()
					let m_comp_det_text_u[vl_ac].username = 
						upshift(m_comp_det_text_u[vl_ac].username)
					display m_comp_det_text_u[vl_ac].username
						to sa_all_scroll[vl_sc].username
# bjg - try this next block of code ------------------------------------
				else
					display m_comp_det_text_u[vl_ac].username
						to sa_all_scroll[vl_sc].username
# bjg - end of try this block of code ----------------------------------
				end if
				if vl_seq
				then
					if skey_check("OVERWRITE_COMP_TEXT", "ALL") = "N"
					then
						let vl_tmp_txt = m_comp_det_text_u[vl_ac].txt
# bjg - try this next block of code ------------------------------------
						if length(m_comp_det_text_u[vl_ac].txt)
						and vl_comp_text_seq[vl_ac]
						then
							let vl_ac = vl_ac + 1
							let vl_sc = vl_sc + 1
							if vl_ac < 13
							then
								if not vl_sc
								then
									let vl_sc = vl_ac
								end if
								call fgl_dialog_setcurrline(vl_sc, vl_ac)
								next field next
							else
								if not vl_sc
								then
									let vl_sc = 8
								end if
								call fgl_dialog_setcurrline(vl_sc, vl_ac)
								next field next
							end if
						end if
# bjg - end of try this block of code ----------------------------------

					end if
				end if
				let vl_arr_count = arr_count()
				call comp_text_disp_line(vl_ac, vl_arr_count)
				{
				if length(vg_disp_cust[vl_ac])
				then
					display vg_disp_cust[vl_ac] to cust_disp
				else
					display "" to cust_disp
				end if
				}
				if vg_wordwrap
				then
					if length(vl_wordwrap)
					then
						let m_comp_det_text_u[vl_ac].txt = vl_wordwrap 
						let vl_wordwrap = null
					end if
					display m_comp_det_text_u[vl_ac].txt
						to sa_all_scroll[vl_sc].txt
					if vg_cur_pos > 1
					then
						call fgl_dialog_setcursor(vg_cur_pos)
					else
						call fgl_dialog_setcursor(1)
					end if	
				else
					call fgl_dialog_setcursor(1)
				end if	

			after field txt
				let vl_ac = arr_curr()
				let vl_sc = scr_line()

				if skey_check("COMP_TEXT_BLANK_LINE","ALL") = "N"
					and fgl_lastkey() != fgl_keyval("up")
				then
					if m_comp_det_text_u[vl_ac].txt = "                                                  "
					or m_comp_det_text_u[vl_ac].txt is null
					then
						error "WARNING: Blank lines of text will NOT be saved"
						if fgl_lastkey() = fgl_keyval("down")
						then
							call dialog.setCurrentRow("sa_all_scroll", vl_ac)
							next field txt
						end if
					end if
				end if

				if vl_seq
				then
					if skey_check("OVERWRITE_COMP_TEXT", "ALL") = "N"
						and vl_comp_text_seq[vl_ac]
						and m_comp_det_text_u[vl_ac].txt != vl_tmp_txt 
					then
						error "Existing complaint text cannot be overwritten"
						let m_comp_det_text_u[vl_ac].txt = vl_tmp_txt 
						display m_comp_det_text_u[vl_ac].txt
							to sa_all_scroll[vl_sc].txt
					else
#						if length(vr_customer.customer_no)
						if vr_customer.customer_no
						then
							let m_comp_cust[vl_ac] = vr_customer.customer_no
						else
							initialize m_comp_cust[vl_ac] to null
						end if
					end if
				else
#					if length(vr_customer.customer_no)
					if vr_customer.customer_no
					then
						let m_comp_cust[vl_ac] = vr_customer.customer_no
					else
						initialize m_comp_cust[vl_ac] to null
					end if
				end if
				# This whole section will enable wordwrap !!!!! at last ...
				if vg_wordwrap
				then
					if m_comp_det_text_u[vl_ac].txt[60] != " "
					then
						# Carry the text down to the next line
						for vl_loop = 60 to 1 step -1
							if m_comp_det_text_u[vl_ac].txt[vl_loop] = " "
							then
								let vl_ww_loop = vl_loop + 1
								exit for
							end if
						end for
						if vl_loop
						then
							let vg_cur_pos = 1
							let vl_wordwrap = null
							for vl_loop = vl_ww_loop to 60
								let vl_wordwrap[vg_cur_pos] =
									m_comp_det_text_u[vl_ac].txt[vl_loop]
								let m_comp_det_text_u[vl_ac].txt[vl_loop] = " "
								let vg_cur_pos = vg_cur_pos + 1
							end for
							display m_comp_det_text_u[vl_ac].txt
								to sa_all_scroll[vl_sc].txt
						else
							let vl_wordwrap = null
							let vg_cur_pos = 0
						end if
					else
						let vl_wordwrap = null
						let vg_cur_pos = 0
					end if
					# This bit is fixed in the latest 4js BDL - 
					# can enable when this is being used
					#}
				end if	

			after insert
				if vl_seq
				then
					# if a line is entered we need to reshuffle the array
					let vl_ac = arr_curr()
					let vl_arr_count = arr_count()
					for vl_loop = (vl_arr_count + 1) to vl_ac step -1
						let vl_comp_text_seq[vl_loop] =
							vl_comp_text_seq[vl_loop - 1]
						let m_comp_cust[vl_loop] =
							m_comp_cust[vl_loop - 1]
					end for
					let vl_comp_text_seq[vl_ac] = 0
#					if length(vr_customer.customer_no)
					if vr_customer.customer_no
					then
						let m_comp_cust[vl_ac] = vr_customer.customer_no
					else
						initialize m_comp_cust[vl_ac] to null
					end if
				else
#					if length(vr_customer.customer_no)
					if vr_customer.customer_no
					then
						let m_comp_cust[vl_ac] = vr_customer.customer_no
					else
						initialize m_comp_cust[vl_ac] to null
					end if
				end if
				let vl_arr_count = arr_count()
				call comp_text_disp_line(vl_ac, vl_arr_count)
				{
				if length(vg_disp_cust[vl_ac])
				then
					display vg_disp_cust[vl_ac] to cust_disp
				else
					display "" to cust_disp
				end if
				}

			before delete
				if vl_seq
				then
					let vl_comp_det_text_u.* = m_comp_det_text_u.*
					let vl_arr_count = arr_count()
				end if

			after delete 
				if vl_seq
				then
					let vl_ac = arr_curr()
					if vl_comp_text_seq[vl_ac]
					then
						error "This line is protected and cannot be deleted"
						let vl_redisplay = true	
						let m_comp_det_text_u.* = vl_comp_det_text_u.*
						call set_count(vl_arr_count)
						continue dialog
					else
						let vl_arr_count = arr_count()
						for vl_loop = vl_ac to (vl_arr_count)
							let vl_comp_text_seq[vl_loop] = 
								vl_comp_text_seq[vl_loop + 1]
							let m_comp_cust[vl_loop] =
								m_comp_cust[vl_loop + 1]
						end for
					end if
				end if
				let vl_arr_count = arr_count()
				call comp_text_disp_line(vl_ac, vl_arr_count)
				{
				if length(vg_disp_cust[vl_ac])
				then
					display vg_disp_cust[vl_ac] to cust_disp
				else
					display "" to cust_disp
				end if
				}
		end input

		before dialog
			call dialog.setActionHidden("clear", true)
			call dialog.setActionActive("clear", false)
			call dialog.setActionHidden("txtedit", true)
			call dialog.setActionActive("txtedit", false)
            IF NOT check_install("BSP")
            THEN
                call dialog.setActionHidden("bsp", true)
                call dialog.setActionActive("bsp", false)
            END IF 

		on action generic_page
			call dialog.setActionHidden("clear", true)
			call dialog.setActionActive("clear", false)
			call dialog.setActionHidden("txtedit", true)
			call dialog.setActionActive("txtedit", false)

		on action customer_page
			call dialog.setActionHidden("clear", true)
			call dialog.setActionActive("clear", false)
			call dialog.setActionHidden("txtedit", true)
			call dialog.setActionActive("txtedit", false)

		on action text_page
			call dialog.setActionHidden("clear", false)
			call dialog.setActionActive("clear", true)
			call dialog.setActionHidden("txtedit", false)
			call dialog.setActionActive("txtedit", true)

		on action map_page
			call dialog.setActionHidden("clear", true)
			call dialog.setActionActive("clear", false)
			call dialog.setActionHidden("txtedit", true)
			call dialog.setActionActive("txtedit", false)

		on action f2_lookup
			let vr_comp.build_no = get_fldbuf(build_no)
			let vr_comp.build_name = get_fldbuf(build_name)
			let vr_comp.location_name = get_fldbuf(location_name)
			let vr_comp.location_desc = get_fldbuf(location_desc)
			let vr_comp.service_c = get_fldbuf(service_c) 
			let vr_comp.item_ref = get_fldbuf(item_ref)
			case
				when infield(assigned_to)
					call correspond_assign_lookup()
				when infield(service_c)
					let vr_comp.service_c = service_look()
					if not length(vr_comp.service_c)
					then
						let vr_comp.service_c = vl_service
					end if
					display by name vr_comp.service_c
					if vl_service != vr_comp.service_c
					then
						let vl_search = "keys.service_c = '", 
										vr_comp.service_c clipped, "'"

						if no_of_rows("keys", vl_search, "") = 0
						then 
							let vl_mess = " The Service code ", vr_comp.service_c, 
								" does not exist" 
							call valid_error("",vl_mess,"")
							let vr_comp.service_c = vl_service
							call set_add_comp_options()
							display by name vr_comp.service_c
							call display_service_info()
							next field service_c 
						else
							display by name vr_comp.service_c
							# Only a service change if not a "normal" service
							case
								when vr_comp.service_c = vg_av_service
								and vg_av_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_weee_service
								and vg_weee_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_weee_sales_service
								and vg_sales_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_enf_service
								and vg_enf_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_enf_trade_service
								and vg_enf_trade_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_sl_service
								and vg_sl_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_gm_service
								and vg_gm_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_ert_service
								and vg_ert_installation = "Y"
								and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_trees_service
								and vg_trees_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_hway_service
								and vg_hway_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_nappy_service
								and vg_nappy_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_clin_service
								and vg_clin_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_trade_service
								and vg_trade_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_agreq_service
								and vg_agreq_installation = "Y"
									let vl_service_change = true

								when vr_comp.service_c = vg_sched_service
								and vg_sched_installation = "Y"
								and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
									let vl_service_change = true

								otherwise
									let vl_service_change = false
									let vr_comp.action_flag =
										check_comp_action_system_key(vr_comp.service_c)
									let generic_action_text = vr_comp.action_flag
									display generic_action_text to generic_action_text
							end case	
							if vl_service_change
							then
								exit dialog
							end if
						end if
					end if
					call display_service_info()
					next field service_c

				when infield(recvd_by)
					call allk_look("CTSRC", "", "Y") returning vr_comp.recvd_by
					display vr_comp.recvd_by to recvd_by
					call display_recvd_info()
					next field recvd_by

				when infield(postcode)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"P", 
												true)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"P", 
												true)
								returning vl_site_ref
						end if

						call set_add_comp_options()

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_postcode = "NULL" 
						else 
							let vl_postcode = vr_comp.postcode 
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property(vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = true
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
							call disp_hist_message()
						end if 
						next field postcode
					end if

				when infield(build_no)
					if vg_property_on 
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"B#", 
												true)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"B#", 
												true)
								returning vl_site_ref
						end if

						call set_add_comp_options()

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_build_no = "NULL" 
						else 
							let vl_build_no = vr_comp.build_no 
	#						call get_comp_site_items(false)
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property(vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = true
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
							call disp_hist_message()
						end if 
						next field build_no
					end if

				when infield(build_name)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"BN", 
												true)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"BN", 
												true)
								returning vl_site_ref
						end if

						call set_add_comp_options()

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_build_name = "NULL" 
						else 
							let vl_build_name = vr_comp.build_name 
	#						call get_comp_site_items(false)
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property(vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = true
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
							call disp_hist_message()
						end if 

						next field build_name
					end if

				when infield(location_name)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"L", 
												true)
								returning vl_site_ref
						else
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"L", 
												true)
								returning vl_site_ref
						end if

						call set_add_comp_options()

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_location_name = "NULL" 
						else 
							let vl_location_name = vr_comp.location_name 
	#						call get_comp_site_items(false)
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property(vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = TRUE
                                IF vg_f3_pressed = TRUE
                                THEN
                                    LET vg_customer_retain = TRUE
                                END IF 
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
							call disp_hist_message()
						end if 
						next field location_name
					else
						call clocn_look(vg_null, vr_comp.service_c)
							returning vr_comp.location_name,
									vr_comp.location_c,
									vr_comp.site_ref,
									vr_comp.location_desc,
									vl_district
						call set_add_comp_options()
						let locn_length = length(vr_comp.location_desc)

	#					call get_comp_site_items(false)
						if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
						then
							call get_comp_site_items(true)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						else
							call get_comp_site_items(false)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						end if
						if vr_comp.site_ref != vr_si_i.site_ref
						then
							let vg_f3_pressed = true
							let vg_customer_retain = true
							call find_and_display_property(vr_si_i.site_ref, true)
						end if
						if vl_si_i_rec_defined = 2
						then
							let vl_service_change = true
							let vr_comp.service_c = vl_service_c
							exit dialog
						end if

					end if

				when infield(location_desc)
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_comp.location_desc)
						and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
						then
							call postcode_look(	vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												false,
												"L", 
												true)
								returning vl_site_ref
						else
							call postcode_look(	vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												false,
												"L", 
												true)
								returning vl_site_ref
						end if

						call set_add_comp_options()

						call find_and_display_property(vl_site_ref, true)

						if not length(vr_comp.site_ref)
						then 
							let vl_location_desc = "NULL" 
						else 
							let vl_location_desc = vr_comp.location_desc
	#						call get_comp_site_items(false)
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property(vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = true
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
							call disp_hist_message()
						end if 

						next field location_name
					else
						call real_site_look(vr_comp.service_c, vl_null, vl_null)
							returning vr_comp.location_desc, vr_comp.site_ref

						select locn.location_c,
								locn.location_name,
								site.site_name_2
							into vr_comp.location_c,
								vr_comp.location_name,
								vl_district
							from locn, site
							where locn.location_c = site.location_c
							and site.site_ref = vr_comp.site_ref
						let locn_length = length(vr_comp.location_desc)

						if vl_district is not null and vl_district[1] != " "
							and locn_length < 20
						then
							let vl_district = draw_down_area_c(locn_rec_defined,
															vr_comp.location_c)
						end if

						call set_add_comp_options()

	#					call get_comp_site_items(false)
						if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
						then
							call get_comp_site_items(true)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						else
							call get_comp_site_items(false)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						end if
						if vr_comp.site_ref != vr_si_i.site_ref
						then
							let vg_f3_pressed = true
							let vg_customer_retain = true
							call find_and_display_property(vr_si_i.site_ref, true)
						end if
						if vl_si_i_rec_defined = 2
						then
							let vl_service_change = true
							let vr_comp.service_c = vl_service_c
							exit dialog
						end if

					end if

				when infield(compl_init)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(1)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_add_comp_options()
					if vr_customer.customer_no
					then
						let vg_f3_pressed = true
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_name)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(2)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_add_comp_options()
					if vr_customer.customer_no
					then
						let vg_f3_pressed = true
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_surname)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(3)
						returning vr_customer.customer_no
					
					let vr_comp.* = vg_comp_save.*
					call set_add_comp_options()
					if vr_customer.customer_no
					then
						let vg_f3_pressed = true
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_business)
#				or infield(compl_postcode)
#				or infield(compl_build_no)
#				or infield(compl_build_name)
#				or infield(compl_addr2)
#				or infield(compl_addr3)
#				or infield(compl_addr4)
#				or infield(compl_addr5)
#				or infield(compl_addr6)
				or infield(compl_fax)
				or infield(compl_email)
				or infield(compl_mobile)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(4)
						returning vr_customer.customer_no

					let vr_comp.* = vg_comp_save.*
					call set_query_comp_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if
					next field compl_name
					
				when infield(item_ref)
					if not length(vr_comp.site_ref)
					then
						# BJG - 3/3/2010 - validate whatever address details we have
						if vg_property_on
						or vg_use_property_lookups
						then
							if length(vr_comp.postcode)
							then
								if length(vr_comp.location_desc)
								and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
								then
									call postcode_look(vr_comp.postcode,
														vr_comp.build_no,
														vr_comp.build_name,
														vr_comp.location_desc,
														vr_comp.service_c,
														false,
														"P", 
														true)
										returning vl_site_ref
								else
									call postcode_look(vr_comp.postcode,
														vr_comp.build_no,
														vr_comp.build_name,
														vr_comp.location_name,
														vr_comp.service_c,
														false,
														"P", 
														true)
										returning vl_site_ref
								end if
							else
								if length(vr_comp.build_no)
								then
									if length(vr_comp.location_desc)
									and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
									then
										call postcode_look(vr_comp.postcode,
															vr_comp.build_no,
															vr_comp.build_name,
															vr_comp.location_desc,
															vr_comp.service_c,
															false,
															"B#", 
															true)
											returning vl_site_ref
									else
										call postcode_look(vr_comp.postcode,
															vr_comp.build_no,
															vr_comp.build_name,
															vr_comp.location_name,
															vr_comp.service_c,
															false,
															"B#", 
															true)
											returning vl_site_ref
									end if
								else
									if length(vr_comp.location_desc)
									and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
									then
										call postcode_look(vr_comp.postcode,
															vr_comp.build_no,
															vr_comp.build_name,
															vr_comp.location_desc,
															vr_comp.service_c,
															false,
															"L", 
															true)
											returning vl_site_ref
									else
{
										call postcode_look(vr_comp.postcode,
															vr_comp.build_no,
															vr_comp.build_name,
															vr_comp.location_name,
															vr_comp.service_c,
															false,
															"L", 
															true)
											returning vl_site_ref
}
										# No Address details entered so show all items
										call item_look("","", vr_comp.service_c)
											returning vr_comp.item_ref, vg_null
										call set_add_comp_options()
										call display_item_info()
									end if
								end if
							end if
							call set_add_comp_options()
							if length(vl_site_ref)
							then
								call find_and_display_property(vl_site_ref, true)
							end if
						else
						# BJG - 3/3/2010 - validate whatever address END
							call item_look("","", vr_comp.service_c)
								returning vr_comp.item_ref, vg_null
							call set_add_comp_options()
							call display_item_info()
						end if
					end if

					if length(vr_comp.site_ref)
					then
	#					call get_comp_site_items(true)
						if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
						then
							call get_comp_site_items(true)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						else
							call get_comp_site_items(false)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						end if
						if vr_comp.site_ref != vr_si_i.site_ref
						then
							let vg_f3_pressed = true
							let vg_customer_retain = true
							call find_and_display_property(vr_si_i.site_ref, true)
						end if
						if vl_si_i_rec_defined = 2
						then
							let vl_service_change = true
							let vr_comp.service_c = vl_service_c
							exit dialog
						end if
					end if
					next field item_ref

				when infield(comp_code)
					let vr_comp.comp_code = list_flt_codes
									(vr_comp.service_c, vr_comp.item_ref, "Y", "")
					call set_notice_type()
					call display_comp_code_info()
					call set_add_comp_options()
					#ADJ MEASUREMENT TODO
					let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
					if vg_ms_installation = "Y"
					and vg_ms_fault_codes matches vl_comp_code
					and length(vr_comp.comp_code)
					then
						let vl_comp_code_change = true
						exit dialog
					end if
					next field comp_code

	################################################################################
	#ADJ GENERO
				when infield(compl_business)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(4)
						returning vr_customer.customer_no

					if vg_comp_cust_sc_open
					then
						current window is iw_comp_cust_sc_2
					end if
	#				current window is iw_comp_ant

					let vr_comp.* = vg_comp_save.*
					call set_add_comp_ant_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_init)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(1)
						returning vr_customer.customer_no

					if vg_comp_cust_sc_open
					then
						current window is iw_comp_cust_sc_2
					end if
	#				current window is iw_comp_ant

					let vr_comp.* = vg_comp_save.*
					call set_add_comp_ant_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_name)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(2)
						returning vr_customer.customer_no

					if vg_comp_cust_sc_open
					then
						current window is iw_comp_cust_sc_2
					end if
	#				current window is iw_comp_ant

					let vr_comp.* = vg_comp_save.*
					call set_add_comp_ant_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_surname)
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*

					call customer_look(3)
						returning vr_customer.customer_no

					if vg_comp_cust_sc_open
					then
						current window is iw_comp_cust_sc_2
					end if
	#				current window is iw_comp_ant

					let vr_comp.* = vg_comp_save.*
					call set_add_comp_ant_options()
					if vr_customer.customer_no
					then
						select * 
							into vr_customer.*
						from customer
							where customer_no = vr_customer.customer_no
					
						display by name vr_customer.compl_init,
										vr_customer.compl_name,
										vr_customer.compl_surname,
										vr_customer.compl_phone,
										vr_customer.int_ext_flag,
										vr_customer.compl_business,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3,
										vr_customer.compl_addr4,
										vr_customer.compl_addr5,
										vr_customer.compl_addr6,
										vr_customer.compl_fax,
										vr_customer.compl_email,
										vr_customer.compl_mobile 
					else
						let vr_customer.* = vg_customer_save.*
					end if

				when infield(compl_postcode)		
					if vg_property_on
					or vg_use_property_lookups
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr3,
										vr_comp.service_c,
										false,
										"P", 
										true)
								returning vl_site_ref
						else
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_comp.service_c,
										false,
										"P", 
										true)
								returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						call find_and_display_property(vl_site_ref, 
														false)

						if vr_customer.compl_postcode is null 
						then 
							let vl_postcode = "NULL" 
						else 
							let vl_postcode = vr_customer.compl_postcode 
						end if 
						next field compl_postcode
					end if

				when infield(compl_build_no)
					if vg_property_on 
					or vg_use_property_lookups
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr3,
										vr_comp.service_c,
										false,
										"B#", 
										true)
								returning vl_site_ref
						else
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_comp.service_c,
										false,
										"B#", 
										true)
								returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						call find_and_display_property(vl_site_ref, 
													false)

						next field compl_build_no
					end if

				when infield(compl_build_name)
					if vg_property_on 
					or vg_use_property_lookups
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr3,
										vr_comp.service_c,
										false,
										"BN", 
										true)
								returning vl_site_ref
						else
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_comp.service_c,
										false,
										"BN", 
										true)
								returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						call find_and_display_property(vl_site_ref, 
														false)

						next field compl_build_name
					end if

				when infield(compl_addr2)
					if vg_property_on 
					or vg_use_property_lookups
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr3,
										vr_comp.service_c,
										false,
										"L", 
										true)
								returning vl_site_ref
						else
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_comp.service_c,
										false,
										"L", 
										true)
								returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						call find_and_display_property(vl_site_ref, 
														false)
						
						next field compl_addr2
					end if

				when infield(compl_addr3)
					if vg_property_on 
					or vg_use_property_lookups
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr3,
										vr_comp.service_c,
										false,
										"L", 
										true)
								returning vl_site_ref
						else
							call postcode_look(
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_comp.service_c,
										false,
										"L", 
										true)
								returning vl_site_ref
						end if

						call set_add_comp_ant_options()

						call find_and_display_property(vl_site_ref, 
														false)
						
						next field compl_addr3
					end if
	#ADJ GENERO
	################################################################################
				otherwise
					call valid_error("","No lookup available on this field","")
			end case

		on action Customer
			let vg_f3_pressed = true
			next field compl_business
	{
		on key(control-s)
			if skey_check( "SCHEDULE_MODULE", "ALL" ) = "Y"
			then
				if length( vr_comp.site_ref ) > 0 then
					if vl_area_flag = "Y" then
						select area_c into vl_ward_code from site
							where site_ref = vr_comp.site_ref
					else
						select ward_code into vl_ward_code from site
							where site_ref = vr_comp.site_ref
					end if
				end if
				call sched_list ( vl_ward_code, vr_comp.site_ref, "")
			end if
	}

		on action History
			let vr_comp.postcode = get_fldbuf(postcode)
			let vr_comp.build_no = get_fldbuf(build_no)
			let vr_comp.build_name = get_fldbuf(build_name)
			let vr_comp.location_name = get_fldbuf(location_name)
			let vr_comp.location_desc = get_fldbuf(location_desc)

			if length(vr_comp.location_name)
			then
				if length(vr_comp.site_ref)
				then
					let vl_rec_count = 1
				else
					case 
						when length(vr_comp.location_desc)
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												true,
												"L", 
												true)
									returning vl_site_ref
								exit case

						when length(vr_comp.location_name)
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												true,
												"L", 
												true)
								returning vl_site_ref
							exit case
						
						when length(vr_comp.build_no)
							call postcode_look("",
												vr_comp.build_no,
												"",
												vr_comp.location_name,
												vr_comp.service_c,
												true,
												"B#", 
												true)
									returning vl_site_ref
							exit case

						when length(vr_comp.build_name)
							call postcode_look("",
												vr_comp.build_name,
												"",
												vr_comp.location_name,
												vr_comp.service_c,
												true,
												"BN", 
												true)
								returning vl_site_ref
							exit case

						otherwise
							call valid_error("",
								"A valid property must be entered", "")
							let vl_site_ref = null
					end case

					call set_add_comp_options()

					if length(vl_site_ref)
					then
						call find_and_display_property(vl_site_ref, true)
						let vl_rec_count = 1
					else
						let vl_rec_count = 0
					end if
				end if

				if vl_rec_count
				then
					let vg_comp_save.* = vr_comp.*
					let vg_customer_save.* = vr_customer.*
					call history_save_text(true)	
					let m_comp_arr_count = 0

					call prompt_for_scroll(false,"L")

					let vr_comp.* = vg_comp_save.*
					let vr_customer.* = vg_customer_save.*
					call history_save_text(false)	
				else
					call valid_error("",
		"A valid location must be entered to view the history.", "")	
				end if
			else
				call valid_error("",
		"A valid location must be entered to view the history.", "")	
			end if
			let vg_show_source = false
			let vg_action_type = true
			call set_add_comp_options()

		on action Text
			next field txt
			{
			call text_yes_no()
			call display_status_info_box()
			}

		on action Duplicate
			if length(vr_customer.compl_site_ref)
			then
				if vr_customer.compl_site_ref != vr_comp.site_ref
				or not length(vr_comp.site_ref)
				then
					let vl_site_ref = vr_customer.compl_site_ref
					call find_and_display_property(vl_site_ref, true)
					if not length(vl_site_ref)
					then
						let vr_comp.site_ref = null
						let vr_comp.location_c = null
						next field postcode
					else
	#					call get_comp_site_items(false)
						if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
						then
							call get_comp_site_items(true)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						else
							call get_comp_site_items(false)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						end if
						if vr_comp.site_ref != vr_si_i.site_ref
						then
							let vg_f3_pressed = true
							let vg_customer_retain = true
							call find_and_display_property(vr_si_i.site_ref, true)
						end if
						if vl_si_i_rec_defined = 2
						then
							let vl_service_change = true
							let vr_comp.service_c = vl_service_c
							exit dialog
						end if
						call disp_hist_message()
					end if
					call set_add_comp_options()
				end if
			else
				if not length(vr_customer.compl_addr2)
				then
					let vg_title = "A ", downshift(vg_compln_title) clipped,
						" has not been entered"
					call valid_error("", vg_title, "")
				else
					let vg_title = "The ", downshift(vg_compln_title) clipped,
						" address does not have a valid site reference"
					call valid_error("", vg_title, "")
				end if
			end if	

		on action Inspections
			let vl_runstr = "fglgo_list_lk '", 
				vr_comp.location_name clipped, "'"
			call os_exec(vl_runstr, false)
			call set_comp_options()

		on action Fly_Capture
			if skey_check("FC_ENHANCED","ALL") = "Y"
			then
				let vl_mess = "A valid ", 
					downshift(skey_check("FAULT_TITLE","ALL"))
				if not length(vr_comp.comp_code)
				then
					let vl_mess = vl_mess clipped, " code must be entered first"
					call valid_error("",vl_mess,"")
				else
					select count(*) into vl_count from allk
						where lookup_func = "FCCOMP"
						and lookup_code = vr_comp.comp_code
						and status_yn = "Y"
					if vl_count
					then
						if update_comp_flycapture(true) then end if
					else
						let vl_mess = vl_mess clipped, 
							" Code does not permit FlyCapture"
						call valid_error("",vl_mess,"")
					end if
				end if
			else
				if update_comp_flycapture(true) then end if
			end if

		on action Detail
			let vl_f43_pressed = true
			let vr_comp.service_c = get_fldbuf(service_c)
			if (vg_dart_installation = "Y" 
			and vr_comp.service_c = vg_dart_service)
			then 
				call dart_information_of()
				let vl_save_comp = vr_comp.complaint_no
				initialize vr_comp.complaint_no to null
				if update_dart_information() then end if
				call dart_information_cf()
				let vr_comp.complaint_no = vl_save_comp
			else
				if (vg_ert_installation = "Y" 
				and vr_comp.service_c = vg_ert_service)
				then
					call ert_information_of()
					let vl_save_comp = vr_comp.complaint_no
					initialize vr_comp.complaint_no to null
					if update_ert_information("ADD") then end if
					call ert_information_cf()
					let vr_comp.complaint_no = vl_save_comp
				else
					if (vg_sw_installation = "Y"
					and vr_comp.service_c = vg_sw_service)
					then
						#ADJ SWTODO
					else
						call valid_error("", 
							"There is no detail associated with this service", "")
					end if
				end if
			end if

        ON ACTION bsp
            CALL view_bsp(vr_comp.service_c, vr_comp.item_ref, vr_comp.comp_code)

        ON ACTION gis
            CALL view_gis(vr_comp.site_ref, vr_comp.service_c, vr_comp.item_ref, vr_comp.comp_code)
            
		on action reset
			let vg_map_easting = vr_comp.easting
			let vg_map_northing = vr_comp.northing
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"reset")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_zoom_in
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_zoom_in")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_zoom_out
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_zoom_out")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_up
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_up")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_down
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_down")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_left
			call display_map_tab("500", 
								"135", 
								vg_zoom, 
								vg_map_easting, 
								vg_map_northing, 
								"map_left")
				returning vg_zoom, vg_map_easting, vg_map_northing

		on action map_right
			call display_map_tab("500", 
							"135",
							vg_zoom, 
							vg_map_easting, 
							vg_map_northing, 
							"map_right")
			returning vg_zoom, vg_map_easting, vg_map_northing

		on action close
			let vg_title = 
				"Abort new ", downshift(vg_comp_title) clipped, " entry"

			if continue_yn(vg_title)
			then
				call reset_text()
				let int_flag = true
				exit dialog
			end if

		on action about
			call os_exec("exec fglgo_about", 1)
{
		on action add_exit
			let vg_title = 
				"Abort new ", downshift(vg_comp_title) clipped, " entry"

			if continue_yn(vg_title)
			then
				call reset_text()
				let int_flag = true
				exit dialog
			end if
}

		on action accept
			accept dialog

		after dialog
			if not validate_correspond("A") then
				next field corr_entered
			end if
#			let vr_comp.action_flag = get_fldbuf(generic_action_text)
#			display by name generic_action_text
			let m_comp_arr_count = 0
			for f_loop = 1 to 500
				let m_comp_text_u[f_loop].username = 
					m_comp_det_text_u[f_loop].username
				let m_comp_text_u[f_loop].doa =
					m_comp_det_text_u[f_loop].doa
				let m_comp_text[f_loop].txt = 
					m_comp_det_text_u[f_loop].txt

				if length(m_comp_text[f_loop].txt)
				then
					let m_comp_arr_count = f_loop
				end if
			end for	
			call display_status_info_box()

			if not length(vr_comp.recvd_by)
			then
				call valid_error("", "A valid source must be entered ", "")
				next field recvd_by
			else
				let vl_search = "lookup_func = 'CTSRC' and lookup_code = '", 
					vr_comp.recvd_by clipped, "'", " and status_yn = 'Y'"

				if no_of_rows("allk", vl_search, "") = 0
				then
					let vl_mess = " The source code ", vr_comp.recvd_by clipped,
						" does not exist"
					call valid_error("", vl_mess,"")
					next field recvd_by
				end if
			end if

			if length(vr_comp.site_ref)
			then
				# Just make sure that the site relates to the entered fields
				if not length(vr_comp.location_name)
				then
					call valid_error("", 
						"A valid road name must be entered", "")
					next field location_name
				else
					if not comp_check_site(vr_comp.site_ref,
											vr_comp.postcode,
											vr_comp.build_no,
											vr_comp.build_name,
											vr_comp.location_name,
											vr_comp.location_desc)
					then 
						let vr_comp.site_ref = null
						let vr_comp.location_c = null
					end if	
				end if
			end if

			if not length(vr_comp.site_ref)
			then
				if not length(vr_comp.postcode) 
					and not length(vr_comp.build_no)
					and not length(vr_comp.build_name)
				then
					select count(*) 
						into vl_rec_count
					from locn
						where location_name = vr_comp.location_name 
							or location_name = vr_comp.location_desc

					if not vl_rec_count	
					then
						call valid_error("",
							"A valid road name must be entered","")
						next field location_name
					else
						if vl_rec_count = 1
						then
							select location_c into vr_comp.location_c
								from locn
							where location_name = vr_comp.location_name

							select site_ref into vr_comp.site_ref
								from site
							where location_c = vr_comp.location_c
#								and site_ref matches "*S"
								and site_c = "S"
								and site_status = "L"

							call find_and_display_property(vr_comp.site_ref, 
								true)
	#						call get_comp_site_items(false)
							if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
							then
								call get_comp_site_items(true)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							else
								call get_comp_site_items(false)
									returning vl_si_i_rec_defined, vl_service_c,
									vl_task_ref, vl_agreement_no
							end if
							if vr_comp.site_ref != vr_si_i.site_ref
							then
								let vg_f3_pressed = true
								let vg_customer_retain = true
								call find_and_display_property 
									(vr_si_i.site_ref, true)
							end if
							if vl_si_i_rec_defined = 2
							then
								let vl_service_change = true
								let vr_comp.service_c = vl_service_c
								exit dialog
							end if
						else
							if length(vr_comp.location_desc)
							and vg_comp_loc_desc_town = "N" # BJG 11/04/2007
							then
								call postcode_look(vr_comp.postcode,
													vr_comp.build_no,
													vr_comp.build_name,
													vr_comp.location_desc,
													vr_comp.service_c,
													true,
													"L", 
													true)
								returning vl_site_ref
							else
								call postcode_look(vr_comp.postcode,
													vr_comp.build_no,
													vr_comp.build_name,
													vr_comp.location_name,
													vr_comp.service_c,
													true,
													"L", 
													true)
								returning vl_site_ref
							end if

							call set_add_comp_options()

							if length(vl_site_ref)
							then
								call find_and_display_property(vl_site_ref,true)
	#							call get_comp_site_items(false)
								if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
								then
									call get_comp_site_items(true)
										returning vl_si_i_rec_defined, vl_service_c,
										vl_task_ref, vl_agreement_no
								else
									call get_comp_site_items(false)
										returning vl_si_i_rec_defined, vl_service_c,
										vl_task_ref, vl_agreement_no
								end if
								if vr_comp.site_ref != vr_si_i.site_ref
								then
									let vg_f3_pressed = true
									let vg_customer_retain = true
									call find_and_display_property 
										(vr_si_i.site_ref, true)
								end if
								if vl_si_i_rec_defined = 2
								then
									let vl_service_change = true
									let vr_comp.service_c = vl_service_c
									exit dialog
								end if
							else
								next field postcode
							end if
						end if
					end if
				else
					case 
						when length(vr_comp.location_desc)
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_desc,
												vr_comp.service_c,
												true,
												"L", 
												true)
									returning vl_site_ref
							exit case

						when length(vr_comp.location_name)
							call postcode_look(vr_comp.postcode,
												vr_comp.build_no,
												vr_comp.build_name,
												vr_comp.location_name,
												vr_comp.service_c,
												true,
												"L", 
												true)
									returning vl_site_ref
							exit case
						
						when length(vr_comp.build_no)
							call postcode_look("",
												vr_comp.build_no,
												"",
												vr_comp.location_name,
												vr_comp.service_c,
												true,
												"B#", 
												true)
									returning vl_site_ref
							exit case

						when length(vr_comp.build_name)
							call postcode_look("",
												vr_comp.build_name,
												"",
												vr_comp.location_name,
												vr_comp.service_c,
												true,
												"BN", 
												true)
								returning vl_site_ref
							exit case

						otherwise
							call valid_error("",
								"A valid property must be entered", "")
							let vl_site_ref = null
					end case

					call set_add_comp_options()

					if length(vl_site_ref)
					then
						call find_and_display_property(vl_site_ref,true)
	#					call get_comp_site_items(false)
						if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
						then
							call get_comp_site_items(true)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						else
							call get_comp_site_items(false)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						end if
						if vr_comp.site_ref != vr_si_i.site_ref
						then
							let vg_f3_pressed = true
							let vg_customer_retain = true
							call find_and_display_property (vr_si_i.site_ref, true)
						end if
						if vl_si_i_rec_defined = 2
						then
							let vl_service_change = true
							let vr_comp.service_c = vl_service_c
							exit dialog
						end if
					else
						next field postcode
					end if
				end if
			end if

			if not length(vr_comp.item_ref)
			then
				call valid_error("Information", 
		"WARNING: An Item of work must be entered to raise a rectification or inspection",
						"")
				next field item_ref
			else
				let vl_search = "item_ref = '", 
					vr_comp.item_ref clipped, "'"

				if no_of_rows("item", vl_search, "") = 0 
				then 
					let vl_mess = " The site item ", 
						vr_comp.item_ref clipped, " does not exist" 
					call valid_error("",vl_mess,"")
					next field item_ref 
				end if 

				let vl_rec_count = get_si_i()
				case 
					when vl_rec_count = 0
						call valid_error("",
				"A valid item must be selected for this site and service", "")
						initialize vr_si_i.* to null
						next field item_ref
					when vl_rec_count > 1
	#					call get_comp_site_items(false)
						if skey_check("ENHANCED_SI_I_LK","ALL") = "Y"
						then
							call get_comp_site_items(true)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						else
							call get_comp_site_items(false)
								returning vl_si_i_rec_defined, vl_service_c,
								vl_task_ref, vl_agreement_no
						end if
						if vr_comp.site_ref != vr_si_i.site_ref
						then
							let vg_f3_pressed = true
							let vg_customer_retain = true
							call find_and_display_property (vr_si_i.site_ref, true)
						end if
						if vl_si_i_rec_defined = 2
						then
							let vl_service_change = true
							let vr_comp.service_c = vl_service_c
							exit dialog
						end if
					otherwise
						# We have vr_si_i populated
				end case
			end if 

			if not length(vr_comp.comp_code)
			then
				call valid_error("", "A valid fault code must be entered", "")
				next field comp_code
			else
				if skey_check("LIST_COMP_CODES", vr_comp.service_c) = "N"
				then			
					select count(*) 
						into vl_count
					from allk
						where lookup_func = "COMPLA"
						and lookup_code = vr_comp.comp_code
						and service_c = vr_comp.service_c
						and status_yn = "Y"

					if not vl_count 
					then
						let vl_mess = "The fault ", 
							vr_comp.comp_code clipped,
							" has not been set up for the service", 
							vr_comp.service_c

						call valid_error("", vl_mess, "")
						next field comp_code
					end if
				end if

				select status_yn
					into vl_ans
				from allk
					where lookup_func = "COMPLA"
					and lookup_code = vr_comp.comp_code

				case vl_ans
					when "Y"
						if skey_check("COMP CODE>ITEM LINK", "ALL" ) = "Y" 
							and length(vr_comp.item_ref)
						then
							select count(*)
								into vl_count
							from it_c
								where it_c.item_ref = vr_comp.item_ref
								and it_c.comp_code = vr_comp.comp_code

							if not vl_count
							then
								let vl_mess = "The Fault Code ", 
									vr_comp.comp_code clipped, 
									" is not valid ",
									"for the selected item ", 
									vr_si_i.item_ref clipped , "."
				
								call valid_error("",vl_mess,"")
								next field comp_code
							end if
						end if
						call set_notice_type()
					when "N"
						let vl_mess = "The fault code '", 
							vr_comp.comp_code clipped, 
							"' exists but has been disabled."

						call valid_error("",vl_mess,"")
						next field comp_code
					otherwise
						let vl_mess = "The fault code '", 
							vr_comp.comp_code clipped, 
							"' does not exist.  A valid code must be entered"
						call valid_error("",vl_mess,"")
						next field comp_code
				end case
				call display_comp_code_info()
			end if

	#CRM1
			if vr_customer.int_ext_flag = "E"
			then
				if not length(vr_customer.compl_name)
				and not length(vr_customer.compl_surname)
				then
					let vg_title =
						"A valid name must be entered for this external ",
						downshift(vg_compln_title)
					call valid_error("", vg_title, "")
					next field compl_name
				end if
				if not length(vr_customer.compl_build_no)
				and not length(vr_customer.compl_build_name)
				then
					let vg_title =
						"A valid property must be entered for this external ",
						downshift(vg_compln_title)
					call valid_error("", vg_title, "")
	#				let vl_compln_flag = true
					next field compl_init
				end if
				if not length(vr_customer.compl_addr2)
				and not length(vr_customer.compl_addr3)
				then
					let vg_title =
					"A valid road must be entered for this external ",
						downshift(vg_compln_title)
					call valid_error("", vg_title, "")
	#				let vl_compln_flag = true
					next field compl_init
				end if
			end if

	################################################################################
	# ADJ GENERO
			if length(vr_customer.compl_site_ref)
			then
				if not comp_check_site(vr_customer.compl_site_ref,
										vr_customer.compl_postcode,
										vr_customer.compl_build_no,
										vr_customer.compl_build_name,
										vr_customer.compl_addr2,
										vr_customer.compl_addr3)
				then
					let vr_customer.compl_site_ref = null
					let vr_customer.compl_location_c = null

					if length(vr_customer.compl_addr2)
					then
						if length(vr_customer.compl_addr3)
						and vg_comp_loc_desc_town = "N"
						then
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr3,
												"",
												true,
												"B#",
												true)
								returning vl_site_ref
						else
							call postcode_look("",
												vr_customer.compl_build_no,
												"",
												vr_customer.compl_addr2,
												"",
												true,
												"B#", 
												true)
							returning vl_site_ref
						end if
			
						call set_add_comp_ant_options()

						if length(vl_site_ref)
						then
							call find_and_display_property(vl_site_ref, false)
						else
							let vr_customer.compl_site_ref = null
							let vr_customer.compl_location_c = null
						end if
					else
						let vr_customer.compl_site_ref = null
						let vr_customer.compl_location_c = null
					end if
				end if
			end if

	# BJG - Extra confirm prompt - 26/10/2007
			if not length(vr_comp.action_flag)
			then
				call valid_error("","A valid next action must be entered","")
				next field generic_action_text
			end if

			let vl_mess = "Are you sure you wish to save this ",
				downshift(vg_record_title clipped), 
				" and progress to "
			case vr_comp.action_flag
				when "A"
					let vl_mess = vl_mess clipped,
						" auto rectification"
				when "D"
					let vl_mess = vl_mess clipped,
						" manual rectification"
				when "E"
					let vl_mess = vl_mess clipped,
						" enforcement"
				when "H"
					let vl_mess = vl_mess clipped,
						" hold"
				when "I"
					let vl_mess = vl_mess clipped,
						" inspection"
				when "P"
					let vl_mess = vl_mess clipped,
						" pending"
				when "N"
					let vl_mess = vl_mess clipped,
						" no further action"
				when "W"
					let vl_mess = vl_mess clipped,
						" works order"
				when "X"
					let vl_mess = vl_mess clipped,
						" express works order"
			end case

	#		let vl_mess = "Accept details and progress to action ",
	#							vr_comp.action_flag
			if not continue_yn(vl_mess)
			then
				next field generic_action_text
			end if

	# ADJ GENERO
	################################################################################

			let f_save_action_flag = vr_comp.action_flag
			initialize vr_comp.action_flag to null
			let vl_new_data = vr_comp.*, remarks_line, vr_customer.*
			let vr_comp.action_flag = f_save_action_flag
			if vl_new_data = vl_old_data
			then
				if skey_check("COMP_WARN_NOCHANGE","ALL") = "Y"
				then
					if not continue_yn
						("Details identical to previous entry. Continue")
					then
						next field service_c
					end if
				else
					call valid_error("",
						"Details must differ from previous entry","")
					next field service_c
				end if
			end if

	# BJG - Now check to see if flycapture is to be forced
			if skey_check("FC_PROMPT","ALL") = "Y"
			then
				if skey_check("FC_ENHANCED","ALL") = "Y"
				then
					select count(*) into vl_count from allk
						where lookup_func = "FCCOMP"
						and lookup_code = vr_comp.comp_code
						and status_yn = "Y"
				else
					let vl_count = 1
				end if
				if vl_count AND length(vlr_comp_flycap.landtype_ref)=0 THEN 
					if not update_comp_flycapture(2)
					then
						next field recvd_by
					end if
				end if
			end if
			if vg_ert_detailed_info = "Y"
			and vg_ert_installation = "Y"
			and vg_ert_service = vr_comp.service_c
			and not vl_f43_pressed
			then
				if continue_yn
			("Do you wish to add graffiti information to this enquiry")
				then
					while true
						call ert_information_of()
						if update_ert_information("ADD")
						then
							call ert_information_cf()
						else
							call ert_information_cf()
							next field service_c
						end if
						if vg_ert_t_and_c_info = "Y"
						then
							if not ert_information_pt2(0)
							then
								continue while
							end if
						end if
						exit while
					end while
				end if
			end if
			if vg_dart_installation = "Y"
			and vg_dart_service = vr_comp.service_c
			and not vl_f43_pressed
			then
				if continue_yn
			("Do you wish to add DART information to this enquiry")
				then
					initialize vr_comp.complaint_no to null
					call dart_information_of()
					if update_dart_information()
					then
						call dart_information_cf()
					else
						call dart_information_cf()
						next field service_c
					end if
				end if
			end if
			if vg_sw_installation = "Y"
			and vg_sw_service = vr_comp.service_c
			then
				select count(*)
					into vl_count
				from warden_item
					where warden_item_type = "V"
					and item_ref = vr_comp.item_ref
					and contract_ref = vr_si_i.contract_ref
				if vl_count
				and quiet_allow("sw_visits_display")
				then
					if continue_yn
					("Do you wish to add group visit information to this enquiry")
					then
						if not add_update_warden_info(false, "V")
						then
							next field service_c
						end if
					end if
				end if
				select count(*)
					into vl_count
				from warden_item
					where warden_item_type = "L"
					and item_ref = vr_comp.item_ref
					and contract_ref = vr_si_i.contract_ref
				if vl_count
				and quiet_allow("sw_leaflet_display")
				then
					if continue_yn
			("Do you wish to add leaflet distribution information to this enquiry")
					then
						if not add_update_warden_info(false, "L")
						then
							next field service_c
						end if
					end if
				end if

				select count(*)
					into vl_count
				from warden_item
					where warden_item_type = "P"
					and item_ref = vr_comp.item_ref
					and contract_ref = vr_si_i.contract_ref
				if vl_count
				and quiet_allow("sw_propmrk_display")
				then
					if continue_yn
				("Do you wish to add property marking information to this enquiry")
					then
						if not add_update_warden_info(false, "P")
						then
							next field service_c
						end if
					end if
				end if

				select count(*)
					into vl_count
				from warden_item
					where warden_item_type = "C"
					and item_ref = vr_comp.item_ref
					and contract_ref = vr_si_i.contract_ref
				if vl_count
				and quiet_allow("sw_cardrem_display")
				then
					if continue_yn
					("Do you wish to add card removal information to this enquiry")
					then
						if not add_update_warden_info(false, "C")
						then
							next field service_c
						end if
					end if
				end if

				select count(*)
					into vl_count
				from warden_item
					where warden_item_type = "I"
					and item_ref = vr_comp.item_ref
					and contract_ref = vr_si_i.contract_ref
				if vl_count
				and quiet_allow("sw_incident_display")
				then
					if continue_yn
		("Do you wish to add street warden incident information to this enquiry")
					then
						if not add_update_incident(false)
						then
#							current window is iw_complain
							next field service_c
						end if
#						current window is iw_complain
					end if
				end if
				select count(*)
					into vl_count
				from warden_item
					where warden_item_type = "R"
					and item_ref = vr_comp.item_ref
					and contract_ref = vr_si_i.contract_ref
				if vl_count
				and quiet_allow("sw_referral_display")
				then
					if continue_yn
					("Do you wish to add referral information to this enquiry")
					then
						if not add_update_referral(false)
						then
#							current window is iw_complain
							next field service_c
						end if
#						current window is iw_complain
					end if
				end if
			end if
					
			let vr_comp.complaint_no = 0

	{
			let vr_comp.action_flag =
				check_comp_action_system_key(vr_comp.service_c)
			display "action_flag 1:", vr_comp.action_flag
	}
			let vl_diry_ref = insert_comp_diry()
			call display_add_comp_info(false)

			# Not a measurement so ...
			initialize vr_comp_measurement.* to null

			while true
	#			let vr_comp.action_flag = drive_enter_action(vl_diry_ref)
				if not drive_process_action(vl_diry_ref)
				then
#					call valid_error("","This Action fails to process","")
					call start_wait()
					delete from diry where diry_ref = vl_diry_ref
					call end_wait()
					call display_add_comp_info(true)
					next field generic_action_text
				end if
				if vr_comp.action_flag = "E"
				then
					let vr_comp.action_flag = 
						check_comp_action_system_key(vr_comp.service_c)
					continue while
				end if
				exit while
			end while
			call set_add_comp_options()

			if not length(vr_comp.action_flag)
			then
				call start_wait()
				delete from diry where diry_ref = vl_diry_ref
				call end_wait()
				call display_add_comp_info(true)
				next field generic_action_text
			end if

			if vr_comp.action_flag = "N"
			then
				let vr_comp.date_closed = today
				let vr_comp.time_closed_h = extend(current, hour to hour)
				let vr_comp.time_closed_m = extend(current, minute to minute)
			end if
			let int_flag = false
#			accept dialog

		on action cancel
			let vg_title = 
				"Abort new ", downshift(vg_comp_title) clipped, " entry"

			if continue_yn(vg_title)
			then
				call reset_text()
				let int_flag = true
				exit dialog
			end if

		on key(f44)
			if length(vr_si_i.item_ref) then
				select insp_item_flag into vl_insp_item_flag from item
					where item_ref = vr_si_i.item_ref and
					contract_ref = vr_si_i.contract_ref
				if vl_insp_item_flag = "Y" then
					call upd_date_due
					(
						vr_si_i.item_ref,
						vr_si_i.site_ref,
						vr_si_i.feature_ref,
						vr_si_i.contract_ref
					)
				else
					call valid_error("", "This is not an inspection item", "")
				end if
			else
				call valid_error("", "You must enter an item first", "")
			end if

		on action Clear
			if continue_yn
				("Are you sure you want to delete all recent text")
			then
				let vl_arr_count = arr_count()

				if vg_allow_text_clear
				then
					let vl_ac = 1
				else
					let vl_ac = vl_seq + 1
					if not vl_ac 
					then
						let vl_ac = 1
					end if
				end if
				call set_count(vl_ac)
				for vl_loop = vl_ac to vl_arr_count
					initialize m_comp_det_text_u[vl_loop].* to null
					initialize m_comp_text[vl_loop].* to null
					let m_comp_cust[vl_loop] = null
					let vl_comp_text_seq[vl_loop] = null
					call comp_text_disp_line(vl_loop, vl_arr_count)
				end for
				if vg_allow_text_clear 
				then
					let vr_comp.complaint_no = null
				end if
				let vl_redisplay = true
				#ADJ 22/09/08
				#exit display
				let vl_ac  = 1
				let vl_sc  = 1
				call dialog.setCurrentRow("sa_all_scroll", vl_ac)
				next field txt
			end if

		on action txtedit
			let vl_ac = arr_curr()
			if vl_ac
			then
				let vl_curs_pos = fgl_getcursor()
				let m_comp_det_text_u[vl_ac].txt = get_fldbuf(txt)
				let vl_lines = comp_edit_text
					(
						"m_comp_det_text_u",
						vl_seq
					)
				if vl_lines > 0 then
					let vl_ac = vl_lines
					let vg_cur_pos = length(m_comp_det_text_u[vl_ac].txt) +1
					let vl_redisplay = true
					call dialog.setcurrentrow("sa_all_scroll",vl_lines)
					next field txt
					continue dialog
				end if
			end if

	
	end dialog

	if int_flag
	then
		let int_flag = false
		let vg_title = "The new ", downshift(vg_record_title) clipped,
			" has not been entered."
		call valid_error("", vg_title, "")
		#ADJ GENERO
		#close window iw_fastcomp
		#ADJ GENERO
		#close form if_fastcomp
		return "I"
	end if

	if vl_service_change or vl_comp_code_change
	then
	#		close window iw_fastcomp
	#		close form if_fastcomp
		initialize vg_agreement_no to null
		if vr_comp.site_ref != vr_si_i.site_ref
		then
			let vg_customer_retain = TRUE
        ELSE
            IF vg_f3_pressed
            THEN
                LET vg_customer_retain = TRUE
            END IF 
		end if
		if vl_si_i_rec_defined = 2
		then
			if vl_service_c = vg_trade_service
			or vl_service_c = vg_agreq_service
			then
				let vr_comp.contract_ref = null
				let vr_comp.comp_code = null
				let vr_comp.item_ref = null
				let vr_comp.feature_ref = null
				initialize vr_si_i.* to null
				let vg_agreement_no = vl_agreement_no
			else
				let vr_comp.contract_ref = vr_si_i.contract_ref
				let vr_comp.item_ref = vr_si_i.item_ref
				let vr_comp.feature_ref = vr_si_i.feature_ref
				let vr_comp.occur_day = vr_si_i.occur_day
				let vr_comp.round_c = vr_si_i.round_c

				#ADJ MEASUREMENT TODO
				if vl_comp_code_change
				then
					let vl_comp_code = vr_comp.comp_code
					return "S"
				else
					let vr_comp.comp_code = null
				end if
			end if
		else
			let vr_comp.contract_ref = null
			#ADJ MEASUREMENT TODO
			if vl_comp_code_change
			then
				let vl_comp_code = vr_comp.comp_code
				call format_field(70,3,remarks_line)
					returning vr_comp.details_1,
								vr_comp.details_2,
								vr_comp.details_3,
								vg_null_val, vg_null_val
				return "S"
			else
				let vr_comp.comp_code = null
				let vr_comp.item_ref = null
				let vr_comp.feature_ref = null
				initialize vr_si_i.* to null
			end if
		end if
		return "C"
	else
		# Sort out the complaint remarks lines
		call format_field(70,3,remarks_line)
			returning vr_comp.details_1,
						vr_comp.details_2,
						vr_comp.details_3,
						vg_null_val, vg_null_val

		call check_comp_cleared()

		if vr_comp.text_flag != "Y" 
		then
			let vr_comp.text_flag = "N"
		end if
		let vr_comp.pa_area = vr_si_i.pa_area
		let vr_comp.feature_ref = vr_si_i.feature_ref
		let vr_comp.contract_ref = vr_si_i.contract_ref

		select easting, northing, easting_end, northing_end
			into vr_comp.easting, vr_comp.northing,
					vr_comp.easting_end, vr_comp.northing_end
		from site_detail
			where site_ref = vr_comp.site_ref

		# If its a monitor then go down a different route ...

		let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
		if
			vg_allow_monitor = "Y" and
			vg_monitor_fault matches vl_comp_code
		then
			let vl_count = false
			for vl_loop = 1 to va_site_select.getLength()
				if va_site_select[vl_loop].select_yn = "Y"
				then
					let vl_count = true
					exit for
				end if
			end for	
			if vl_count
			then
				call insert_multi_monitor_records(vl_diry_ref)
				#close window iw_complain
				#close form if_complain
				return ""
			end if
		end if

		let vr_comp.complaint_no = get_next_s_no("COMP", "")

		#ADJ DEBUG
#		display "ADJ DEBUG: dest_ref = ", vr_comp.dest_ref

#		whenever error continue

		while true
			insert into comp values (vr_comp.*)
            if vr_comp.service_c = vg_sched_service then
                update comp
                    set pa_area = null,
                        round_c = null
                    where complaint_no = vr_comp.complaint_no
            end if

			if errtst()
			then
				exit while
			else
				select max(complaint_no) into vr_comp.complaint_no
					from comp
				if status = notfound
				then
					let vr_comp.complaint_no = 1
				else
					let vr_comp.complaint_no = vr_comp.complaint_no + 2
					update s_no set serial_no = vr_comp.complaint_no
						where sn_func = "COMP"
					let vr_comp.complaint_no = vr_comp.complaint_no - 1
				end if
			end if
		end while

#		whenever error stop

		if vg_replication != "N"
		then
			insert into comp_links
				values(vg_replicate_ref,vr_comp.complaint_no)
		end if
				
		insert into comp_destination
			values (vr_comp.complaint_no, 
					vr_comp_destination.destination,
					vr_comp_destination.destination_date)

		# ADJ - CRM
		call insert_comp_customer()

		#ADJBJG Enforce
		if vg_enforce_added
		then
			call update_comp_enf_source_ref(vl_diry_ref)
			let vg_enforce_added = false
		end if
		if vg_enforce_ref
		then
			call save_enforce_ref()
		end if

		#BJG Flycapture
		if vg_new_flycomp = true
		then
			let vg_new_flycomp = 2
			call update_flycap_tables(true)
		end if

		if vg_dart_installation = "Y"
		and vg_dart_service = vr_comp.service_c
		then
			let vr_comp_dart_header.complaint_no = vr_comp.complaint_no
			insert into comp_dart_header values(vr_comp_dart_header.*)
			insert into comp_dart_hdr_log values(vr_comp_dart_header.*,
												1,
												vr_comp.entered_by,
												vr_comp.date_entered,
												vr_comp.ent_time_h,
												vr_comp.ent_time_m)

			let vlr_comp_dart_dtl_log.log_username = get_user()
			let vlr_comp_dart_dtl_log.log_username = 
				upshift(vlr_comp_dart_dtl_log.log_username)
			let vlr_comp_dart_dtl_log.log_date = today
			call get_time()
				returning vlr_comp_dart_dtl_log.log_time_h,
							vlr_comp_dart_dtl_log.log_time_m

			let vl_count = 1
			for vl_loop = 1 to 100
				if va_cmp_dart_dtl[vl_loop].dart_result = "Y"
				then
					insert into comp_dart_detail values(vr_comp.complaint_no,
							va_cmp_dart_dtl_func[vl_loop].dart_lookup_func,
							va_cmp_dart_dtl[vl_loop].dart_lookup_code)
					insert into comp_dart_dtl_log values(vr_comp.complaint_no,
							va_cmp_dart_dtl_func[vl_loop].dart_lookup_func,
							va_cmp_dart_dtl[vl_loop].dart_lookup_code,
							vl_count,
							vlr_comp_dart_dtl_log.log_username,
							vlr_comp_dart_dtl_log.log_date,
							vlr_comp_dart_dtl_log.log_time_h,
							vlr_comp_dart_dtl_log.log_time_m)
					let vl_count = vl_count + 1
				end if
			end for
		end if

		if vg_ert_installation = "Y"
		and vg_ert_detailed_info = "Y"
		and vg_ert_service = vr_comp.service_c
		then
			let vr_comp_ert_header.complaint_no = vr_comp.complaint_no
			insert into comp_ert_header values(vr_comp_ert_header.*)
			let vr_comp_ert_tags.complaint_no = vr_comp.complaint_no
			let vr_comp_ert_tags.seq_no = 1
			let vr_comp_ert_tags.username = get_user()
			let vr_comp_ert_tags.doa = date
			let vr_comp_ert_tags.details = null
			insert into comp_ert_tags values(vr_comp_ert_tags.*)
			insert into comp_ert_tags_log values(vr_comp_ert_tags.*,
												1,
												vr_comp.entered_by,
												vr_comp.date_entered,
												vr_comp.ent_time_h,
												vr_comp.ent_time_m)
			insert into comp_ert_hdr_log values(vr_comp_ert_header.*,
												1,
												vr_comp.entered_by,
												vr_comp.date_entered,
												vr_comp.ent_time_h,
												vr_comp.ent_time_m)

			let vlr_comp_ert_dtl_log.log_username = get_user()
			let vlr_comp_ert_dtl_log.log_username = 
				upshift(vlr_comp_ert_dtl_log.log_username)
			let vlr_comp_ert_dtl_log.log_date = today
			call get_time()
				returning vlr_comp_ert_dtl_log.log_time_h,
							vlr_comp_ert_dtl_log.log_time_m

			let vl_count = 1
			for vl_loop = 1 to 100
				if va_comp_ert_detail[vl_loop].ert_result = "Y"
				then
					insert into comp_ert_detail values(vr_comp.complaint_no,
							va_comp_ert_detail_func[vl_loop].ert_lookup_func,
							va_comp_ert_detail[vl_loop].ert_lookup_code)
					insert into comp_ert_dtl_log values(vr_comp.complaint_no,
							va_comp_ert_detail_func[vl_loop].ert_lookup_func,
							va_comp_ert_detail[vl_loop].ert_lookup_code,
							vl_count,
							vlr_comp_ert_dtl_log.log_username,
							vlr_comp_ert_dtl_log.log_date,
							vlr_comp_ert_dtl_log.log_time_h,
							vlr_comp_ert_dtl_log.log_time_m)
					let vl_count = vl_count + 1
				end if
			end for
		end if
		if vg_sw_installation = "Y"
		and vg_sw_service = vr_comp.service_c
		then
			#ADJ SWTODO
			#insert into the relevant tables!
			select count(*)
				into vl_count
			from warden_item
				where warden_item_type in ("V", "L", "P", "C")
				and item_ref = vr_comp.item_ref
				and contract_ref = vr_si_i.contract_ref
			if vl_count
			then
				let vr_comp_warden.complaint_no = vr_comp.complaint_no
				insert into comp_warden values(vr_comp_warden.*)
			end if

			select count(*)
				into vl_count
			from warden_item
				where warden_item_type in ("I", "R")
				and item_ref = vr_comp.item_ref
				and contract_ref = vr_si_i.contract_ref

			if vl_count 
			then
				if not length(vr_client.client_ref)
				and (length(vr_client.client_name)
				or length(vr_client.client_surname)
				or length(vr_client.client_a_name)
				or length(vr_client.client_a_surname))
				then
					let vr_client.asbo_yn = "N"
					let vr_client.validated_yn = "N"
					let vr_client.referral_yn = vr_incident.referral_yn
					let vr_client.client_ref = get_next_s_no("client", "")
					insert into client values(vr_client.*)
				end if

				if vr_client.client_ref
				then
					insert into comp_client values(vr_comp.complaint_no,
													vr_client.client_ref)
					for vl_loop = 1 to vg_client_text_count
						if vl_loop = vg_client_text_count
						and not length(m_client_text[vl_loop].txt)
						then 
							exit for
						else
							insert into client_text values(
										vr_client.client_ref,
										#ADJ SERIALS
										vl_loop,
										m_client_text[vl_loop].username, 
										m_client_text[vl_loop].doa, 
										m_client_text[vl_loop].time_entered_h,
										m_client_text[vl_loop].time_entered_m,
										m_client_text[vl_loop].txt 
										)
						end if
					end for
				end if

				if length(vr_incident.incident_source)
				then
					if not length(vr_incident.confirmed_text)
					or vr_incident.confirmed_text is null
					then
						let vr_incident.confirmed_text = "N"
					end if
					if not length(vr_incident.referral_yn)
					or vr_incident.referral_yn is null
					then
						let vr_incident.referral_yn = "N"
					end if
					let vr_incident.incident_ref = get_next_s_no("incident", "")
					let vr_incident.client_ref = vr_client.client_ref

					insert into incident values(vr_incident.*)

					for vl_loop = 1 to vg_incident_text_count
						if vl_loop = vg_incident_text_count
						and not length(m_incident_text[vl_loop].txt)
						then 
							exit for
						else
							insert into incident_text values(
										vr_incident.incident_ref,
										#ADJ SERIALS
										vl_loop,
										m_incident_text[vl_loop].username, 
										m_incident_text[vl_loop].doa, 
										m_incident_text[vl_loop].time_entered_h,
										m_incident_text[vl_loop].time_entered_m,
										m_incident_text[vl_loop].txt 
										)
						end if
					end for

					insert into comp_incident values(vr_comp.complaint_no,
												vr_incident.incident_ref)
				end if

				if length(vr_referral.activity_type)
				then
					let vr_referral.referral_ref = get_next_s_no("referral", "")
					let vr_referral.incident_ref = vr_incident.incident_ref
					let vr_referral.client_ref = vr_client.client_ref
					insert into referral values(vr_referral.*)

					for vl_loop = 1 to vg_referral_text_count
						if vl_loop = vg_referral_text_count
						and not length(m_referral_text[vl_loop].txt)
						then 
							exit for
						else
							insert into referral_text values(
										vr_referral.referral_ref,
										#ADJ SERIALS
										vl_loop,
										m_referral_text[vl_loop].username, 
										m_referral_text[vl_loop].doa, 
										m_referral_text[vl_loop].time_entered_h,
										m_referral_text[vl_loop].time_entered_m,
										m_referral_text[vl_loop].txt 
										)
						end if
					end for

					insert into comp_referral values(vr_comp.complaint_no,
												vr_referral.referral_ref)
				end if
			end if
		end if

		if m_comp_arr_count > 0
		then
			for vl_count = 1 to m_comp_arr_count
				let m_comp_cust[vl_count] = vr_customer.customer_no
			end for
			let vr_comp.text_flag = "Y" 
			call write_to_comp_text(vr_comp.complaint_no)
		else
			let vr_comp.text_flag = "N"
		end if

		if vr_comp.action_flag = "N"
		then
			let vr_diry.action_flag = "C"
# BJG 14/04/2011 - If we are here the action_flag must
#                  is be "N" we need to save a new text line to detail who
#                  set this action
            CALL record_nfa_text(vr_comp.complaint_no)
		else
			let vr_diry.action_flag = vr_comp.action_flag
		end if

		case vr_diry.action_flag
			when "C"
				let vl_user = get_user()
				let vl_user = upshift(vl_user)
				call get_time()
					returning vl_time_h, vl_time_m
				update diry
					set action_flag = "C",
						source_ref = vr_comp.complaint_no,
						dest_flag = "C",
						date_due = null,
						dest_date = today,
						dest_time_h = vl_time_h,
						dest_time_m = vl_time_m,
						dest_user = vl_user
					where diry_ref = vl_diry_ref

			otherwise
				if vr_diry.action_flag = "I"
				then
					if skey_check("ALLOW_ADHOC_SAMPLES", "ALL") = "Y"
					and vr_comp.comp_code = 
						skey_check("ADHOC_SAMPLE_FAULT", "ALL")
					then
						let vr_comp_adhoc_sample.complaint_no = 
							vr_comp.complaint_no
						insert into comp_adhoc_sample 
							values(vr_comp_adhoc_sample.*)
						let vr_diry.date_due = vr_comp_adhoc_sample.next_date
						if vr_comp_adhoc_sample.next_date = today
						then
							#create a sample NOW!
							let vl_runstr = "exec fglgo_adhoc_insp ", 
								vr_comp.complaint_no
							call os_exec(vl_runstr, true)
						end if
					else
						let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
						if
							vg_allow_monitor = "Y" and
							vg_monitor_fault matches vl_comp_code
						then
							let vr_comp_monitor.complaint_no = 
								vr_comp.complaint_no
							insert into comp_monitor 
								values(vr_comp_monitor.*)
							let vr_diry.date_due = vr_comp_monitor.next_date
							if vr_comp_monitor.next_date = today
							then
								#create a sample NOW!
								let vl_runstr = "exec fglgo_monitor_insp ", 
									vr_comp.complaint_no
								call os_exec(vl_runstr, false)
							end if
						else
							call diry_date_due()
						end if
					end if
				else
					let vr_diry.date_due = today
				end if
				update diry
					set action_flag = vr_diry.action_flag,
						date_due = vr_diry.date_due,
						source_ref = vr_comp.complaint_no
					where diry_ref = vl_diry_ref
		end case

		if vg_crm_enhanced = "Y"
		then
			call pop_ci_export_variables(vr_comp.complaint_no)
			let vr_crm_import_export.transaction_type = "I"
			call unload_crm_export_file(vr_crm_import_export.*)
		end if

		call check_action("Enquiry:Add", vr_comp.complaint_no)
		call ws_ext_integration(vr_comp.complaint_no, "", "", "")

		call save_correspond()
		call set_comp_options()

		call print_comp_notice(vr_comp.complaint_no)

		call display_status_info_box()

		display	vr_comp.dest_ref, 
				vr_comp.dest_suffix, 
				vr_comp.date_closed,
				vr_comp.time_closed_h,
				vr_comp.time_closed_m
			to generic_dest_ref,
				generic_dest_suffix, 
				generic_date_closed,
				generic_time_closed_h,
				generic_time_closed_m

#		call gl_showpage("fold","generic_page")

		if vg_add_multi_complaints = "Y"
		and vg_replication = "N"
		then
			let vl_mess = "The new ", downshift(vg_record_title) clipped,
				" has been saved."

			if vg_record_title matches "[Cc]omplaint"
			then
				let vl_mess = vl_mess clipped,
					"  The complaint number is ", 
					vr_comp.complaint_no using "<<<<<<<<"
			else		
				let vl_mess = vl_mess clipped,
					"  The reference number is ", 
					vr_comp.complaint_no using "<<<<<<<<"
			end if

			let vl_mess = vl_mess clipped,
				".\nAdd another ", downshift(vg_record_title) clipped,
				" using the current information"

			if continue_yn(vl_mess)
			then
				let vg_customer_retain = true
				let vl_exit_flag = "C"
				call reset_comp_form_variables()	
			else
				let vl_exit_flag = ""
				let vg_customer_retain = false
			end if

		else
			let vl_mess = "The new ", downshift(vg_record_title) clipped,
				" has been saved."

			if vg_record_title matches "[Cc]omplaint"
			then
				let vl_mess = vl_mess clipped,
					"  The complaint number is ", 
					vr_comp.complaint_no using "<<<<<<<<"
			else		
				let vl_mess = vl_mess clipped,
					"  The reference number is ", 
					vr_comp.complaint_no using "<<<<<<<<"
			end if

--#			if fgl_fglgui() 
--# 		then
--#				call valid_error("Information", vl_mess, "I")
--# 		else
				prompt vl_mess clipped for vl_ans
--# 		end if
			let vl_exit_flag = ""
		end if

		#ADJ GENERO
		#close window iw_fastcomp

		#close form if_fastcomp
		return vl_exit_flag
	end if

end function	# add_normal_complain


function display_comp_action_text()
	define 
		w	ui.Window,
		f	ui.Form

	let w = ui.Window.getCurrent()
	let f = w.getForm()

	let generic_action_text = vr_comp.action_flag
	call populate_action_combo("Q", "DWHPINR", "generic_action_text")
	call populate_action_combo("Q", "DWHPINR", "av_action_text")
	call populate_action_combo("Q", "DWHPINR", "gm_action_text")
	call populate_action_combo("Q", "DWHPINR", "ert_action_text")
	call populate_action_combo("Q", "DWHPINR", "trade_action_text")
	call populate_action_combo("Q", "DWHPINR", "agreq_action_text")
	call populate_action_combo("Q", "DWHPINR", "meas_action_text")
	call populate_action_combo("Q", "DWHPINR", "tree_action_text")
	call populate_action_combo("Q", "DWHPINR", "sched_action_text")

	display by name generic_action_text
	display generic_action_text to av_action_text
	display generic_action_text to gm_action_text
	display generic_action_text to ert_action_text
	display generic_action_text to trade_action_text
	display generic_action_text to agreq_action_text
	display generic_action_text to meas_action_text
	display generic_action_text to tree_action_text
	display generic_action_text to sched_action_text

	case
		when vr_comp.action_flag = "D"
			call show_rectifications_tab(vr_comp.dest_ref, false)

		when vr_comp.action_flag = "W"
			call show_works_order_tab(vr_comp.dest_ref, 
										vr_comp.dest_suffix,
										false)

		otherwise
			call f.setElementHidden("rectifications_page",true)
			call f.setElementHidden("works_order_page",true)
	end case

	{
	case vr_comp.action_flag
		when "D"
			display "DEFAULT" to action_text 
		when "E"
			display "ENFORCE" to action_text 
		when "W"
			display "W/ORDER" to action_text 
		when "I"
			display "INSPECT" to action_text 
		when "H"
			display "HOLD   " to action_text 
		when "M"
			display "M/MENT " to action_text 
		when "P"
			display "PENDING" to action_text 
		when "N"
			display "NONE   " to action_text 
		otherwise
			display "       " to action_text 
	end case
	}
end function	# display_comp_action_text


function update_comp_destination()
	define
		vl_enforcement_ref	like comp_enf.source_ref,
		vl_dest_ref			like comp.dest_ref,
		vl_act_flag_save 	like comp.action_flag,
		vl_diry_ref			like diry.diry_ref,
		vl_comp_code		char(10),
		vl_time_h       	char(2),
		vl_time_m       	char(2),
		vl_runstr			char(80),
		vl_count,
		vl_loop				integer

	let vg_enforce_added = false
	if vg_enf_installation = "Y"
	or vg_enf_trade_installation = "Y"
	then
		# Find out if the complaint has a related enforcement
		select complaint_no
			into vl_enforcement_ref
		from comp_enf
			where source_ref = vr_comp.complaint_no
		if vl_enforcement_ref
		then
			let vg_enforce_added = true
		end if
	end if

   call get_time()
		returning vl_time_h, vl_time_m

	if not length(vr_comp.action_flag)
	then
		let vr_comp.action_flag = "H"
	else
		case vr_comp.action_flag 
			when "N"
				let vg_title = 
					" This ", downshift(vg_record_title) clipped,
					" has been closed and cannot be updated" 
				call valid_error("Information", vg_title, "")
				return
			when "E"
				let vg_title = 
					" This ", downshift(vg_record_title) clipped,
					" has been passed to Enforcement Officers and cannot",
					" be updated" 
				call valid_error("Information", vg_title, "")
				return
			when "M"
				if not allow("Man")
				then
					return
				end if	
		end case
	end if	

	case 
		when vr_comp.action_flag matches "D"
			if allow("ammend_def")
			then
#				call upd_def(vr_comp.dest_ref)
				let vl_runstr = "exec fglgo_default x ", 
					vr_comp.dest_ref using "<<<<<<<"
				call os_exec(vl_runstr, false)
				select * into vr_defh.* from defh
					where cust_def_no = vr_comp.dest_ref
			end if

		when vr_comp.action_flag matches "W"
			select dest_ref
				into vl_dest_ref
			from diry
				where source_flag = "C"
				and source_ref = vr_comp.complaint_no

#			call wo_h_display(vl_dest_ref, "U")
#			call wo_h_main(vl_dest_ref, true)
			if vg_act = "r"
			then
				let vl_runstr = "exec fglgo_wk_ord r x x ", 
					vl_dest_ref using "<<<<<<<"
			else
				let vl_runstr = "exec fglgo_wk_ord x x x ", 
					vl_dest_ref using "<<<<<<<"
			end if
			call os_exec(vl_runstr, false)
			let vr_wo_h.wo_ref = vr_comp.dest_ref
			let vr_wo_h.wo_suffix = vr_comp.dest_suffix

		when vr_comp.action_flag matches "I"
			#ADJ ADHOC
			if skey_check("ALLOW_ADHOC_SAMPLES", "ALL") = "Y"
			and vr_comp.comp_code = skey_check("ADHOC_SAMPLE_FAULT", "ALL")
			then
				select *
					into vr_comp_adhoc_sample.*
				from comp_adhoc_sample
					where complaint_no = vr_comp.complaint_no
				if adhoc_sample_info()
				then
					let vr_diry.date_due = vr_comp_adhoc_sample.next_date
					select *
						into vr_diry.*
					from diry
						where source_flag = "C"
						and source_ref = vr_comp.complaint_no

					update diry
						set date_due = vr_diry.date_due,
						action_flag = "I"
					where diry_ref = vr_diry.diry_ref
				end if
			else
				#ADJ TODO MONITOR
				let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"

				if
					vg_allow_monitor = "Y" and
					vg_monitor_fault matches vl_comp_code
				then
					select *
						into vr_comp_monitor.*
					from comp_monitor
						where complaint_no = vr_comp.complaint_no
					if monitor_info()
					then
						let vr_diry.date_due = vr_comp_monitor.next_date
						select *
							into vr_diry.*
						from diry
							where source_flag = "C"
							and source_ref = vr_comp.complaint_no

						update diry
							set date_due = vr_diry.date_due,
							action_flag = "I"
						where diry_ref = vr_diry.diry_ref
					end if
				else
					if change_comp_inspection(vr_comp.complaint_no)
					then
						call get_diry_ref()
							returning vl_diry_ref,
									vr_si_i.item_ref,
									vr_si_i.contract_ref,
									vr_si_i.feature_ref

						if vl_diry_ref is null
						then
							call valid_error("",
		"This record cannot be updated ... contact the system administrator","")
							return	
						end if

						let vl_act_flag_save = vr_comp.action_flag

						if not length(vr_si_i.item_ref)
						then	
							let vr_si_i.item_ref = vr_comp.item_ref
						end if	

						while true

{ BJG - This input needs to be from a selection of screen fields subject
        to service code and x,y co-ord (comp_code) requirements.
        A new function created to handle this .....

							if vr_comp.service_c = vg_agreq_service
							and vg_agreq_installation = "Y"
							then
								call populate_action_combo
									(
									"U", 
									"HPRIN", 
									"agreq_action_text"
									)
							else
								call populate_action_combo
									(
									"U",
									"ADWXHPIN",
									"generic_action_text"
									)
							end if
							let generic_action_text = vr_comp.action_flag
							input by name generic_action_text without defaults
							let vr_comp.action_flag = generic_action_text
}
							let vr_comp.action_flag = change_action()
                                
                            IF vr_comp.action_flag = "W" OR vr_comp.action_flag = "X" THEN 
                                let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
                                IF vg_ms_installation = "Y" and vg_ms_fault_codes matches vl_comp_code and length(vr_comp.comp_code) THEN
                                    IF length(vr_comp_measurement.x_value)=0 OR length(vr_comp_measurement.y_value)=0 THEN
                                        call valid_error("", "Measurement information must be provided.", "")
                                        RETURN 
                                    END IF
                                END IF
                            END IF

							let vr_comp.action_flag =	
								process_action(vl_diry_ref)

							#ADJ GENERO
							#let vr_comp.action_flag = 
							#	drive_enter_action(vl_diry_ref)

							#ADJ DEBUG
							# call valid_error("", generic_action_text, "")
							# call valid_error("", vr_comp.action_flag, "")
							if vr_comp.action_flag = "E"
							then
								#ADJBJG Enforce
								if vg_enforce_added
								then
									call update_comp_enf_source_ref(vl_diry_ref)
								end if

								let vr_comp.action_flag = 
									check_comp_action_system_key
									(vr_comp.service_c)
								continue while
							end if
							exit while
						end while
						let vr_comp.dest_ref = vr_diry.dest_ref

						if not length(vr_comp.action_flag)
						or vr_comp.action_flag = vl_act_flag_save
						then
							let vr_comp.action_flag = vl_act_flag_save
							let vg_enforce_added = false
							return
						end if
						# find out whether the destination of this complaint 
						# was cleared
						call check_comp_cleared()
						if vr_comp.action_flag matches "[NHP]"
						then
							initialize vr_comp.dest_ref,
											vr_comp.dest_suffix to null
						end if
						if vr_comp.action_flag = "I"
						then
							initialize vr_comp.dest_suffix to null
						end if
						update comp set dest_ref = vr_comp.dest_ref,
										dest_suffix = vr_comp.dest_suffix,
										action_flag = vr_comp.action_flag
							where complaint_no = vr_comp.complaint_no
				
						if vr_comp.action_flag != "N" 
						then
							update diry set 
								action_flag = vr_comp.action_flag,
								dest_ref = vr_comp.dest_ref
							where diry_ref = vr_diry.diry_ref
						else
# BJG 14/04/2011 - If we are here the action_flag must have changed, and
#                  is now "N" we need to save a new text line to detail who
#                  set this action
                            CALL record_nfa_text(vr_comp.complaint_no)
							let vr_diry.action_flag = "C"
							let vr_diry.dest_flag = "C"
							let vr_diry.dest_ref = null
							let vr_diry.dest_date = today
							let vr_diry.dest_time_h = 
								extend(current, hour to hour)
							let vr_diry.dest_time_m = 
								extend(current, minute to minute)
							let vr_diry.dest_user = get_user()
							let vr_diry.dest_user = 
								upshift(vr_diry.dest_user)

							update diry set 
								action_flag = vr_diry.action_flag,
								dest_flag = vr_diry.dest_flag,  
								dest_ref = vr_diry.dest_ref,
								dest_date = vr_diry.dest_date,
								dest_time_h = vr_diry.dest_time_h,
								dest_time_m = vr_diry.dest_time_m,
								dest_user = vr_diry.dest_user
							where diry_ref = vr_diry.diry_ref
						end if				
						
						call update_complaint_source()
						call display_comp_action_text()

{
						let generic_action_text = vr_comp.action_flag
						display by name generic_action_text,
									vr_comp.dest_ref, 
									vr_comp.dest_suffix
}
						let generic_action_text = vr_comp.action_flag
						display generic_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to generic_action_text,
								generic_dest_ref,
								generic_dest_suffix
						let av_action_text = vr_comp.action_flag
						display av_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to av_action_text,
								av_dest_ref,
								av_dest_suffix
						let gm_action_text = vr_comp.action_flag
						display gm_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to gm_action_text,
								gm_dest_ref,
								gm_dest_suffix
						let ert_action_text = vr_comp.action_flag
						display ert_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to ert_action_text,
								ert_dest_ref,
								ert_dest_suffix
						let trade_action_text = vr_comp.action_flag
						display trade_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to trade_action_text,
								trade_dest_ref,
								trade_dest_suffix
						let agreq_action_text = vr_comp.action_flag
						display agreq_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to agreq_action_text,
								agreq_dest_ref,
								agreq_dest_suffix
						let meas_action_text = vr_comp.action_flag
						display meas_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to meas_action_text,
								meas_dest_ref,
								meas_dest_suffix
						let tree_action_text = vr_comp.action_flag
						display tree_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to tree_action_text,
								tree_dest_ref,
								tree_dest_suffix
						let sched_action_text = vr_comp.action_flag
						display sched_action_text,
									vr_comp.dest_ref,
									vr_comp.dest_suffix
							to sched_action_text,
								sched_dest_ref,
								sched_dest_suffix

						let vr_diry.action_flag = vr_comp.action_flag

						if vr_comp.action_flag = "I"
						then
							if change_comp_inspection(vr_comp.complaint_no)
							then
								# Change selected
							end if	
						end if

						if vr_comp.action_flag = "D"
							and vl_act_flag_save != vr_comp.action_flag
						then			# print out the default notice
							call print_comp_notice(vr_comp.complaint_no)
						end if
					end if
				end if
			end if

			if vg_crm_enhanced = "Y"
			then
				call pop_ci_export_variables(vr_comp.complaint_no)
				let vr_crm_import_export.transaction_type = "C"
				call unload_crm_export_file(vr_crm_import_export.*)
			end if

			call ws_ext_integration(vr_comp.complaint_no, "", "", "")

		when vr_comp.action_flag matches "[PHM]"
			call get_diry_ref()
				returning vl_diry_ref,
						vr_si_i.item_ref,
						vr_si_i.contract_ref,
						vr_si_i.feature_ref
			if vl_diry_ref is null
			then
				call valid_error("", 
	"This record cannot be updated ... contact the system administrator", "")
				return
			end if

			let vl_act_flag_save = vr_comp.action_flag

			if not length(vr_si_i.item_ref)
			then	
				let vr_si_i.item_ref = vr_comp.item_ref
			end if	

			while true
				#ADJ TODO

{ BJG - This input needs to be from a selection of screen fields subject
        to service code and x,y co-ord (comp_code) requirements.
        A new function created to handle this .....

				case 
					when vr_comp.service_c = vg_agreq_service
					and vg_agreq_installation = "Y"
						call populate_action_combo
							(
							"U", 
							"HPRIN", 
							"agreq_action_text"
							)
						let agreq_action_text = vr_comp.action_flag
						input by name agreq_action_text without defaults
						let vr_comp.action_flag = agreq_action_text

					when vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
						call populate_action_combo
							(
							"U",
							"ADWXHPIN",
							"av_action_text"
							)
						let av_action_text = vr_comp.action_flag
						input by name av_action_text without defaults
						let vr_comp.action_flag = av_action_text

					otherwise
						call populate_action_combo
							(
							"U",
							"ADWXHPIN",
							"generic_action_text"
							)
						let generic_action_text = vr_comp.action_flag
						input by name generic_action_text without defaults
						let vr_comp.action_flag = generic_action_text
				end case
}
				if vg_act = "o" # from av_overview so can only be W
				then
					let vr_comp.action_flag = "W"
				else
					let vr_comp.action_flag = change_action()
				end IF
                IF vr_comp.action_flag = "W" OR vr_comp.action_flag = "X" THEN 
                    let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
                    IF vg_ms_installation = "Y" and vg_ms_fault_codes matches vl_comp_code and length(vr_comp.comp_code) THEN
                        IF length(vr_comp_measurement.x_value)=0 OR length(vr_comp_measurement.y_value)=0 THEN
                            call valid_error("", "Measurement information must be provided.", "")
                            RETURN 
                        END IF
                    END IF
                END IF
				let vr_comp.action_flag =	
					process_action(vl_diry_ref)

				if vr_comp.action_flag = "E"
				then
					#ADJBJG Enforce
					if vg_enforce_added
					then
						call update_comp_enf_source_ref(vl_diry_ref)
					end if

					let vr_comp.action_flag = 
						check_comp_action_system_key(vr_comp.service_c)
					continue while
				end if
				exit while
			end while
			let vr_comp.dest_ref = vr_diry.dest_ref

			if not length(vr_comp.action_flag)
			or vr_comp.action_flag = vl_act_flag_save
			then
				let vr_comp.action_flag = vl_act_flag_save
				let vg_enforce_added = false
				return
			end if
	# find out whether the destination of this complaint was cleared
			call check_comp_cleared()

	# find out whether the destination of this complaint was cleared
     
			if vr_comp.action_flag matches "[NHP]"
			then
				initialize vr_comp.dest_ref,
								vr_comp.dest_suffix to null
			end if
			if vr_comp.action_flag = "I"
			then
				initialize vr_comp.dest_suffix to null
			end if
			update comp set dest_ref = vr_comp.dest_ref,
								dest_suffix = vr_comp.dest_suffix,
								action_flag = vr_comp.action_flag
			where complaint_no = vr_comp.complaint_no
					
			if vr_comp.action_flag != "N" 
			then	
				if vr_comp.action_flag != "W"  # BJG - not sure about other actions!
				then
					update diry set 
						action_flag = vr_comp.action_flag,
						dest_ref = vr_comp.dest_ref
					where diry_ref = vr_diry.diry_ref
				end if
			else					
# BJG 14/04/2011 - If we are here the action_flag must have changed, and
#                  is now "N" we need to save a new text line to detail who
#                  set this action
                CALL record_nfa_text(vr_comp.complaint_no)
				let vr_diry.action_flag = "C"
				let vr_diry.dest_flag = "C"
				let vr_diry.dest_ref = null
				let vr_diry.dest_date = today
				let vr_diry.dest_time_h = 
					extend(current, hour to hour)
				let vr_diry.dest_time_m = 
					extend(current, minute to minute)
				let vr_diry.dest_user = get_user()
				let vr_diry.dest_user = 
					upshift(vr_diry.dest_user)

				update diry set 
					action_flag = vr_diry.action_flag,
					dest_flag = vr_diry.dest_flag,  
					dest_ref = vr_diry.dest_ref,
					dest_date = vr_diry.dest_date,
					dest_time_h = vr_diry.dest_time_h,
					dest_time_m = vr_diry.dest_time_m,
					dest_user = vr_diry.dest_user
				where diry_ref = vr_diry.diry_ref
			end if
				
			call update_complaint_source()

# BJG - AV screen does not include action_flag or dest_ref etc.....
# It does now !!
#			if vr_comp.service_c != vg_av_service
#			then
			if vg_act != "o" # not from av_overview so display to comp window
			then
				call display_comp_action_text()
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to generic_dest_ref, generic_dest_suffix
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to av_dest_ref, av_dest_suffix
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to gm_dest_ref, gm_dest_suffix
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to ert_dest_ref, ert_dest_suffix
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to trade_dest_ref, trade_dest_suffix
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to agreq_dest_ref, agreq_dest_suffix
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to meas_dest_ref, meas_dest_suffix
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to tree_dest_ref, tree_dest_suffix
				display vr_comp.dest_ref, vr_comp.dest_suffix
					to sched_dest_ref, sched_dest_suffix
			end if

			let vr_diry.action_flag = vr_comp.action_flag

			if vr_comp.action_flag = "I"
			then
				if change_comp_inspection(vr_comp.complaint_no)
				then
					# Change selected
				end if	
			end if

			if vr_comp.action_flag = "D"
				and vl_act_flag_save != vr_comp.action_flag
			then			# print out the default notice
				call print_comp_notice(vr_comp.complaint_no)
			end if

			# BJG - This should print WO when Comp destination updated to W
			if vr_comp.action_flag = "W"
				and vl_act_flag_save != vr_comp.action_flag
			then			# print out the works order notice
				# ADJ MOVE WO PRINT
				if vg_sched_installation = "Y"
				and vr_comp.service_c = vg_sched_service
				and skey_check("SCHED_PRINT_WO", "ALL") = "N"
				then
					# Do not print schedule works orders.	
				else
					call print_works_order_notice(vr_comp.dest_ref,
												vr_comp.dest_suffix)
				end if
			end if

			if vg_crm_enhanced = "Y"
			then
				call pop_ci_export_variables(vr_comp.complaint_no)
				let vr_crm_import_export.transaction_type = "C"
				call unload_crm_export_file(vr_crm_import_export.*)
			end if

			call ws_ext_integration(vr_comp.complaint_no, "", "", "")
	end case

	# find out whether the destination of this complaint was cleared
	call check_comp_cleared()

	if vr_comp.date_closed is not null
	then
		if vg_act != "o" # not from av_overview so display to comp window
		then
#			display by name vr_comp.date_closed, vr_comp.time_closed_h,
#				vr_comp.time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to generic_date_closed, generic_time_closed_h, generic_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to av_date_closed, av_time_closed_h, av_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to gm_date_closed, gm_time_closed_h, gm_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to ert_date_closed, ert_time_closed_h, ert_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to trade_date_closed, trade_time_closed_h, trade_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to agreq_date_closed, agreq_time_closed_h, agreq_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to meas_date_closed, meas_time_closed_h, meas_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to sl_date_closed, sl_time_closed_h, sl_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to tree_date_closed, tree_time_closed_h, tree_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to sched_date_closed, sched_time_closed_h, sched_time_closed_m
			display
				vr_comp.date_closed, vr_comp.time_closed_h, vr_comp.time_closed_m
				to hw_date_closed, hw_time_closed_h, hw_time_closed_m
		end if
		update comp 
			set date_closed = vr_comp.date_closed,
				time_closed_h = vr_comp.time_closed_h,
				time_closed_m = vr_comp.time_closed_m
		where complaint_no = vr_comp.complaint_no	
		call notify_customer(vr_comp.complaint_no, "", "", "")
		call update_complaint_source()

		if vg_crm_enhanced = "Y"
		then
			call pop_ci_export_variables(vr_comp.complaint_no)
			let vr_crm_import_export.transaction_type = "C"
			call unload_crm_export_file(vr_crm_import_export.*)
		end if

		call ws_ext_integration(vr_comp.complaint_no, "", "", "")

		#call clear_diry(vr_diry.source_flag, vr_diry.source_ref)
	end if		

	if vr_comp.text_flag = "Y" and g_comp_text_flag = "Y"
	then
		call update_comp_text()
	end if
	let vg_enforce_added = false
end function	# update_comp_destination


function history_save_text(vl_save_flag)	
	define
		vl_save_flag,
		vl_loop			smallint

	if vl_save_flag
	then
		let m_comp_save_arr_count = m_comp_arr_count

		for vl_loop = 1 to 500
			let m_comp_save_text[vl_loop].* = m_comp_text[vl_loop].*
			let m_comp_save_text_u[vl_loop].* = m_comp_text_u[vl_loop].* 
			let m_comp_det_text_us[vl_loop].* = m_comp_det_text_u[vl_loop].* 
		end for
	else
		let m_comp_arr_count = m_comp_save_arr_count

		for vl_loop = 1 to 500
			let m_comp_text[vl_loop].* = m_comp_save_text[vl_loop].*
			let m_comp_text_u[vl_loop].* = m_comp_save_text_u[vl_loop].* 
			let m_comp_det_text_u[vl_loop].* = m_comp_det_text_us[vl_loop].* 
		end for
	end if
end function	# history_save_text	


function disp_current_comp_screen(vl_disp_type)
	define
		vl_comp_code	char(10),
		vl_disp_type	char(1)


{
#ADJ GENERO
	let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
	# Display the relevant screen
	case
		when vg_ms_installation = "Y"
			and vg_ms_fault_codes matches vl_comp_code
			and length(vr_comp.comp_code)

			whenever error continue
			if vl_disp_type = "A"
			then
				current window is iw_measurement_fastcomp 
			else
				current window is iw_measurement_qrycomp 
			end if
			whenever error stop

		when vr_comp.service_c = vg_weee_service
			and vg_weee_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_weee_fastcomp 
			else
				current window is iw_weeeqrycomp 
			end if

		when vr_comp.service_c = vg_weee_sales_service
			and vg_sales_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_sales_fastcomp 
			else
				current window is iw_weee_sales_qrycomp 
			end if

#		when vr_comp.service_c = skey_check("SCHED_SERVICE", "ALL")
#			and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
		when vr_comp.service_c = vg_sched_service
			and vg_sched_installation = "Y"
			and vg_weee_installation = "N"
			and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_sched_fastcomp 
			else
				current window is iw_qry_sched_comp 
			end if

#		when vr_comp.service_c = skey_check("SCHED_SERVICE", "ALL")
#			and skey_check("SCHEDULE_MODULE", "ALL") = "Y"
		when vr_comp.service_c = vg_sched_service
			and vg_sched_installation = "Y"
			and vg_weee_installation = "Y"
			and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_sched_fastcomp 
			else
				current window is iw_qry_weee_sched_comp 
			end if

		when vr_comp.service_c = vg_av_service
			and vg_av_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_av_fastcomp 
			else
				current window is iw_avqrycomp 
			end if

		when vr_comp.service_c = vg_enf_service
			and vg_enf_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_enf_fastcomp 
			else
				current window is iw_enfqrycomp 
			end if

		when vr_comp.service_c = vg_enf_trade_service
			and vg_enf_trade_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_enftr_fastcomp 
			else
				current window is iw_enftrqrycomp 
			end if

		when vr_comp.service_c = vg_sl_service
			and vg_sl_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_sl_fastcomp 
			else
				current window is iw_slqrycomp 
			end if

		when vr_comp.service_c = vg_gm_service
			and vg_gm_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_gm_fastcomp
			else
				current window is iw_gmqrycomp
			end if

		when vr_comp.service_c = vg_ert_service
			and vg_ert_installation = "Y"
			and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_ert_fastcomp
			else
				current window is iw_ertqrycomp
			end if

		when vr_comp.service_c = vg_trees_service
			and vg_trees_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_tree_fastcomp
			else
				current window is iw_treeqrycomp
			end if

		when vr_comp.service_c = vg_trade_service
			and vg_trade_installation="Y"
			if vl_disp_type = "A"
			then
				current window is iw_tr_fastcomp
			else
				current window is iw_trqrycomp
			end if

		when vr_comp.service_c = vg_nappy_service
			and vg_nappy_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_nappy_fastcomp 
			else
				current window is iw_npqrycomp 
			end if

		when vr_comp.service_c = vg_clin_service
			and vg_clin_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_clin_fastcomp
			else
				current window is iw_clqrycomp 
			end if

		when vr_comp.service_c = vg_hway_service
			and vg_hway_installation = "Y"
			if vl_disp_type = "A"
			then
				current window is iw_hway_fastcomp
			else
				current window is iw_hwayqrycomp
			end if

		otherwise 
			if vl_disp_type = "A"
			then
				current window is iw_fastcomp 
			else
#				current window is iw_complain
			end if
	end case
#ADJ GENERO
}
end function	# disp_current_comp_screen("U")


function show_comp_source()
	define
		vl_prev_record	like diry.prev_record,
		vl_import_key	integer,
		vl_runstr		char(80),
		vl_source_flag	like diry.source_flag,
		vl_source_ref	like diry.source_ref

	call start_wait()
	select prev_record 
		into vl_prev_record from diry
	where source_ref = vr_comp.complaint_no and
		source_flag = "C"
	call end_wait()

	if vl_prev_record
	then
		if (vg_enf_installation = "Y"
		and vg_enf_service = vr_comp.service_c)
		or (vg_enf_trade_installation = "Y"
		and vg_enf_trade_service = vr_comp.service_c)
		then
			select source_flag, source_ref into vl_source_flag, vl_source_ref
				from diry where diry_ref = vl_prev_record
			if vl_source_flag != "C"
			then
				call insp_display( vl_prev_record )
			else
#				let vl_runstr = "exec fglgo_complain X X X X X ",
#												vl_source_ref
#				call os_exec(vl_runstr, false)
				let vg_title = "There is no source for the selected ",
					downshift(vg_record_title) clipped
				call valid_error("", vg_title, "")
			end if
		else
			call insp_display( vl_prev_record )
		end if
	else
		if vg_ci_installation = "Y"
		then
			call start_wait()
			select import_key 
				into vl_import_key
			from comp_import
				where complaint_no = vr_comp.complaint_no
			call end_wait()

			if vl_import_key
			then
				let vl_runstr = "exec fglgo_comp_import ", 
					vl_import_key using "<<<<<<<"
				call os_exec(vl_runstr, false)
			else
				let vg_title = "There is no source for the selected ",
					downshift(vg_record_title) clipped
				call valid_error("", vg_title, "")
			end if
		else
			let vg_title = "There is no source for the selected ",
				downshift(vg_record_title) clipped
			call valid_error("", vg_title, "")
		end if	
	end if

end function	# show_comp_source


function query_import(vl_flag)
	define
		vl_flag		smallint,
		vl_bracket	smallint,
		waiting		char(1),
		live		char(1),
		discarded 	char(1),
		vl_imp_part	char(150)

define w	ui.Window
define f	ui.Form

	let w = ui.Window.getCurrent()
	let f = w.getForm()

#	call set_comp_options()

#	call qry_import_of()
	call f.setElementHidden("import_page",false) # Show Import Tab of Folder

	if vg_weee_installation = "Y"
	then
--#		call fgl_keysetlabel("f8", "")
	else
--#		call fgl_keysetlabel("f8", "Import")
	end if

	construct by name vl_imp_part on comp.incident_id,
									comp_import.import_date,
									comp_import.import_time

		before construct
			display vr_qry_import.import_ref to incident_id
			display by name vr_qry_import.import_date
			display by name vr_qry_import.import_time

{
		on key(f8)
			let vr_qry_import.import_ref = get_fldbuf(incident_id)
			let vr_qry_import.import_date = get_fldbuf(import_date)
			let vr_qry_import.import_time = get_fldbuf(import_time)

			exit construct
}

		after construct
			let vr_qry_import.import_ref = get_fldbuf(incident_id)
			let vr_qry_import.import_date = get_fldbuf(import_date)
			let vr_qry_import.import_time = get_fldbuf(import_time)

		on action cancel
			let int_flag = true
			exit construct

		on action close
			let int_flag = true
			exit construct

	end construct

#	call qry_import_cf()
	call f.setElementHidden("import_page",true) # Hide Import Tab of Folder

	if int_flag
	then
		return ""
	end if

	return vl_imp_part

end function	# query_import


function update_complaint_source()
	define 
		vl_import_key	integer,
		vl_make_desc	like makes.make_desc,
		vl_model_desc	like models.model_desc,
		vl_colour_desc	like colour.colour_desc,
		vl_time_closed	like comp_import.time_closed

	if vg_ci_installation != "Y"
	then
		return
	end if

	if vg_crm_enhanced = "Y"
	then
		call pop_ci_export_variables(vr_comp.complaint_no)
	end if

	select import_key 
		into vl_import_key
	from comp_import
		where complaint_no = vr_comp.complaint_no

	if not vl_import_key
	then
		return
	else
		let vl_time_closed = vr_comp.time_closed_h, ":", vr_comp.time_closed_m
		update comp_import 
			set recvd_by = vr_comp.recvd_by,
				location_c = vr_comp.location_c,
				site_ref = vr_comp.site_ref,
				item_ref = vr_comp.item_ref,
				round_c = vr_comp.round_c,
				occur_day = vr_comp.occur_day,
				build_no = vr_comp.build_no,
				build_sub_no = vr_comp.build_sub_no,
				build_name = vr_comp.build_name,
				build_sub_name = vr_comp.build_sub_name,
				location_name = vr_comp.location_name,
				location_desc = vr_comp.location_desc,
				townname = vr_comp.townname,
				countyname = vr_comp.countyname,
				posttown = vr_comp.posttown,
				area_ward_desc = vr_comp.area_ward_desc,
				postcode = vr_comp.postcode,
				exact_location = vr_comp.exact_location,
				action_flag = vr_comp.action_flag,
				dest_ref = vr_comp.dest_ref,
				date_closed = vr_comp.date_closed,
				time_closed = vl_time_closed
			where import_key = vl_import_key

		if vr_comp.service_c = vg_av_service
			and vg_av_installation = "Y"
		then
			select make_desc 
				into vl_make_desc
			from makes
				where make_ref = vg_av_arr.make_ref

			select model_desc 
				into vl_model_desc
			from models
				where model_ref = vg_av_arr.model_ref

			select colour_desc 
				into vl_colour_desc
			from colour
				where colour_ref = vg_av_arr.colour_ref

			update comp_av_import
				set car_id = vg_av_arr.car_id,
					generated_no = vg_av_arr.generated_no,
					vin = vg_av_arr.vin,
					make_ref = vg_av_arr.make_ref,
					make_desc = vl_make_desc,
					model_ref = vg_av_arr.model_ref,
					model_desc = vl_model_desc,
					colour_ref = vg_av_arr.colour_ref,
					colour_desc = vl_colour_desc,
					date_stickered = vg_av_arr.date_stickered,
					time_stickered_h = vg_av_arr.time_stickered_h,
					time_stickered_m = vg_av_arr.time_stickered_m,
					officer_id = vg_av_arr.officer_id,	
					road_fund_flag = vg_av_arr.road_fund_flag,
					road_fund_valid = vg_av_arr.road_fund_valid,
					vehicle_class = vg_av_arr.vehicle_class,
					dho_rep = vg_av_arr.dho_rep,
					dho_cc_building = vg_av_arr.dho_cc_building,
					how_long_there = vg_av_arr.how_long_there
				where import_key = vl_import_key

			if vg_crm_enhanced = "Y"
			then
				let vr_crm_import_export.make_desc = vg_av_arr.make_desc
				let vr_crm_import_export.model_desc = vg_av_arr.model_desc
				let vr_crm_import_export.colour_desc = vg_av_arr.colour_desc
				let vr_crm_import_export.car_id = vg_av_arr.car_id
				let vr_crm_import_export.vin = vg_av_arr.vin
				let vr_crm_import_export.road_fund_valid = 
					vg_av_arr.road_fund_valid
				let vr_crm_import_export.road_fund_flag = 
					vg_av_arr.road_fund_flag
				let vr_crm_import_export.vehicle_class = 
					vg_av_arr.vehicle_class
				let vr_crm_import_export.date_stickered = 
					vg_av_arr.date_stickered
				let vr_crm_import_export.time_stickered_h = 
					vg_av_arr.time_stickered_h
				let vr_crm_import_export.time_stickered_m = 
					vg_av_arr.time_stickered_m
				let vr_crm_import_export.how_long_there = 
					vg_av_arr.how_long_there
			end if	
		end if
	end if

end function	# update_complaint_source


function drawdown_address(vl_area_ward_desc)
	define
		vl_area_ward_desc		char(40)

	if length(vr_comp.build_no) or length(vr_comp.build_name)
	then
		let vr_customer.compl_build_no = vr_comp.build_no
		let vr_customer.compl_build_name = vr_comp.build_name
		let vr_customer.compl_addr2 = vr_comp.location_name
		let vr_customer.compl_addr3 = vr_comp.location_desc
		let vr_customer.compl_addr4 = vl_area_ward_desc
		let vr_customer.compl_addr5 = vr_comp.townname

		if vg_disp_county_or_postal = "Y"
		then
			let vr_customer.compl_addr6 = vr_comp.countyname
		else
			let vr_customer.compl_addr6 = vr_comp.posttown
		end if

		let vr_customer.compl_postcode = vr_comp.postcode
		let vr_customer.compl_site_ref = vr_comp.site_ref
		let vr_customer.compl_location_c = vr_comp.location_c
	end if	
end function	# drawdown_address

#MAB comp_correspond functions
function correspond_assign_lookup()
	define vl_field_ok integer
	let vr_comp_correspond.assigned_to=general_look(
			"user_info", "username", "Login ID", "fullname", "Login Name")
	display vr_comp_correspond.assigned_to to comp_correspond.assigned_to
	let vl_field_ok=after_field_correspond("assigned_to","U")

end function

function before_add_correspond()
	initialize vr_comp_correspond.* to null
	#Bug 3.25.3 Correspondence date field should be empty by default
	--let vr_comp_correspond.corr_entered=today
	let vgs_comp_correspond.*=vr_comp_correspond.*
end function

function before_update_correspond()
	call get_correspond_info()
end function

function check_correspond_password()
	if get_passwd() then
		#Bug 3.25.2   Update problem with Password
		if vg_passwd = skey_check("COMPLAIN_PW", "ALL") then
			return true
		end if
	end if
	return false
end function

function validate_correspond(vl_mode)
	define vl_mode char(30)

	if not skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
		return true
	end if
	if not after_field_correspond("assigned_to",vl_mode) then
		return false
	end if
	return true
end function

function after_field_correspond(vl_field_name,vl_mode)
	define vl_fullname	like user_info.fullname
	define vl_field_name char(30)
	define vl_mode char(30)
	define vl_field_ok integer

	if not skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
		return true
	end if
	let vl_field_ok=true
	case 
		when vl_field_name="date_entered"
			if vl_mode="U" then
				if vr_comp_correspond.corr_entered!=
						vgs_comp_correspond.corr_entered then
					if not check_correspond_password() then
						let vr_comp_correspond.corr_entered=
							vgs_comp_correspond.corr_entered
						let vl_field_ok=false
						exit case
					end if
				end if
			end if
			if vr_comp_correspond.corr_entered = 
					vgs_comp_correspond.corr_entered then
				return true
			end IF
            IF skey_check("CORRESPOND_IN_PAST","ALL") <> "Y" then
                if vr_comp_correspond.corr_entered<today then
                    let vr_comp_correspond.corr_entered=
                        vgs_comp_correspond.corr_entered
                    call valid_error("",
                    "Correspondence date entered can not be in the past","")
                    let vl_field_ok=false
                    exit case
                end IF
            END IF
			#Bug 3.25.1   Due Date  field - Limit future Date Entry
			if vr_comp_correspond.corr_entered>today then
				let vr_comp_correspond.corr_entered=
					vgs_comp_correspond.corr_entered
				call valid_error("",
				"Correspondence date entered can not be in the future"
					,"")
				let vl_field_ok=false
				exit case
			end if
		when vl_field_name="date_due"
			if vl_mode="U" then
				if vr_comp_correspond.date_due!=
						vgs_comp_correspond.date_due then
					if not check_correspond_password() then
						let vr_comp_correspond.date_due=
							vgs_comp_correspond.date_due
						let vl_field_ok=false
						exit case
					end if
				end if
			end if
			if vr_comp_correspond.date_due=vgs_comp_correspond.date_due then
				return true
			end if
			if vr_comp_correspond.date_due<today then
				let vr_comp_correspond.date_due=vgs_comp_correspond.date_due
				call valid_error("",
					"Correspondence due date must be in the future","")
				let vl_field_ok=false
				exit case
			end if
			#Bug 3.25.1   Due Date  field - Limit future Date Entry
			if vr_comp_correspond.date_due>(today+300) then
				let vr_comp_correspond.date_due=vgs_comp_correspond.date_due
				call valid_error("",
				"Correspondence due date can not be that far in the future"
					,"")
				let vl_field_ok=false
				exit case
			end if
		when vl_field_name="date_response"
			if vr_comp_correspond.date_response!=
					vgs_comp_correspond.date_response then
				if vl_mode="U" then
					if not check_correspond_password() then
					let vr_comp_correspond.date_response=
						vgs_comp_correspond.date_response
						let vl_field_ok=false
						exit case
					end if
				end if
			end if
			if vr_comp_correspond.date_response=
					vgs_comp_correspond.date_response then
				return true
			end if
			if vr_comp_correspond.date_response<today then
				let vr_comp_correspond.date_response=
					vgs_comp_correspond.date_response
				call valid_error("",
					"Correspondence response date must be in the future","")
				let vl_field_ok=false
				exit case
			end if
			#Bug 3.25.1   Due Date  field - Limit future Date Entry
			if vr_comp_correspond.date_response>(today+300) then
				let vr_comp_correspond.date_response=
					vgs_comp_correspond.date_response
				call valid_error("",
			"Correspondence response date can not be that far in the future"
					,"")
				let vl_field_ok=false
				exit case
			end if
		when vl_field_name="assigned_to"
			if length(vr_comp_correspond.assigned_to)=0 then
				display " " to fullname
                IF skey_check("CORRESPOND_IN_PAST","ALL") <> "Y" then
                    if not vr_comp_correspond.date_due is null
                            or not vr_comp_correspond.corr_entered is null then
                        call valid_error("",
                "Assigned to can not be blank if date entered or date due are set"
                        ,"")
                        let vl_field_ok=false
                        return false
                    else
                        return true
                    end IF
                ELSE
                    return true
				end if
			end if
			select fullname into vl_fullname
				from user_info
				where username=vr_comp_correspond.assigned_to
			if status=0 then
				display vl_fullname to fullname
			else
				call valid_error("",
					"Correspondence assigned to must be a valid user","")
				let vl_field_ok=false
				exit case
			end if

	end case
	return vl_field_ok
end function

function save_correspond()
	define vl_row_count integer

	if not skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
		return
	end if

	select count(*) into vl_row_count
		from comp_correspond
		where comp_correspond.complaint_no	= vr_comp.complaint_no

	if vl_row_count=0 then
		let vr_comp_correspond.complaint_no = vr_comp.complaint_no
		insert into comp_correspond values(vr_comp_correspond.*)
	else
		update comp_correspond set *=vr_comp_correspond.*
			where comp_correspond.complaint_no	= vr_comp.complaint_no
	end if
		
end function

function get_correspond_info()
	define vl_fullname	like user_info.fullname

	initialize vr_comp_correspond.* to null
	initialize vgs_comp_correspond.* to null

	if not skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
		return
	end if
	select * into vr_comp_correspond.*
		from comp_correspond
		where comp_correspond.complaint_no	= vr_comp.complaint_no

	let vgs_comp_correspond.*=vr_comp_correspond.*

	display
		vr_comp_correspond.corr_entered,
		vr_comp_correspond.date_due,
		vr_comp_correspond.date_response,
		vr_comp_correspond.assigned_to
		to
		corr_entered,
		date_due,
		date_response,
		assigned_to

	if length(vr_comp_correspond.assigned_to)>0 then
		select fullname into vl_fullname
			from user_info
			where username=vr_comp_correspond.assigned_to

		display vl_fullname to fullname
	else
		display " " to fullname
	end if
--call valid_error("MAB:Debug","q3","")
end function
#MAB end comp_correspond functions

function get_enf_info() 
	define
		vl_loc_change		smallint,
		vl_null				smallint,
		vl_action_seq		integer,
		vl_related_count	integer,
		vlr_enf_offence	record like enf_offence.*,
		vl_term_desc		like allk.lookup_text,
		vl_invoff_func		like keys.c_field

	let vl_invoff_func = skey_check("ENF_INVOFF_FUNC","ALL")

	initialize vg_enf_arr.* to null

	select comp_enf.complaint_no,
			comp_enf.law_ref,
			comp_enf.offence_ref,
			comp_enf.offence_date,
			comp_enf.offence_time_h,
			comp_enf.offence_time_m,
			comp_enf.inv_officer,
			comp_enf.enf_officer,
			comp_enf.enf_status,
			comp_enf.suspect_ref,
			comp_enf.evidence,
			comp_enf.actions,
			comp_enf.action_seq,
			comp_enf.car_id,
			comp_enf.inv_period_start,
			comp_enf.inv_period_finish
		into
			vg_enf_arr.complaint_no,
			vg_enf_arr.law_ref,
			vg_enf_arr.offence_ref,
			vg_enf_arr.offence_date,
			vg_enf_arr.offence_time_h,
			vg_enf_arr.offence_time_m,
			vg_enf_arr.inv_officer,
			vg_enf_arr.enf_officer,
			vg_enf_arr.enf_status,
			vg_enf_arr.suspect_ref,
			vg_enf_arr.evidence,
			vg_enf_arr.actions,
			vl_action_seq,
			vg_enf_arr.car_id,
			vg_enf_arr.inv_period_start,
			vg_enf_arr.inv_period_finish
	from comp_enf
		where vr_comp.complaint_no = comp_enf.complaint_no	

	display by name vg_enf_arr.complaint_no,
					vg_enf_arr.suspect_ref

	display by name vg_enf_arr.inv_period_start,
					vg_enf_arr.inv_period_finish

	display by name vg_enf_arr.law_ref,
					vg_enf_arr.offence_ref,
					vg_enf_arr.offence_date,
					vg_enf_arr.offence_time_h,
					vg_enf_arr.offence_time_m,
					vg_enf_arr.inv_officer,
					vg_enf_arr.enf_officer,
					vg_enf_arr.enf_status,
					vg_enf_arr.actions

	display vg_enf_arr.car_id to comp_enf.car_id

	if length(vg_enf_arr.law_ref) then
		select lookup_text into vg_enf_arr.law_desc from allk
			where lookup_code = vg_enf_arr.law_ref
			and lookup_func = "ENFLAW"
	else
		let vg_enf_arr.law_ref = null
	end if
	display by name vg_enf_arr.law_desc

	initialize vlr_enf_offence.* to null
	initialize vl_term_desc to null
	if length(vg_enf_arr.offence_ref) then
#		select lookup_text into vg_enf_arr.offence_desc from allk
#			where lookup_code = vg_enf_arr.offence_ref
#			and lookup_func = "ENFDET"
		select * into vlr_enf_offence.* from enf_offence
			where offence_ref = vg_enf_arr.offence_ref
		let vg_enf_arr.offence_desc = vlr_enf_offence.offence_desc
		select lookup_text into vl_term_desc from allk
			where lookup_code = vlr_enf_offence.offence_term
			and lookup_func = "ENFTRM"
	else
		let vg_enf_arr.offence_ref = null
	end if
	display by name vg_enf_arr.offence_desc
	display by name vlr_enf_offence.offence_term,
							vlr_enf_offence.offence_cost
	display vl_term_desc to offence_term_desc

	if length(vg_enf_arr.inv_officer) then
		select lookup_text into vg_enf_arr.inv_off_name from allk
			where lookup_code = vg_enf_arr.inv_officer
#			and lookup_func = "ENFOFF"
			and lookup_func = vl_invoff_func
	else
		let vg_enf_arr.inv_officer = null
	end if
	display by name vg_enf_arr.inv_off_name

	if length(vg_enf_arr.enf_officer) then
		select lookup_text into vg_enf_arr.enf_off_name from allk
			where lookup_code = vg_enf_arr.enf_officer
			and lookup_func = "ENFOFF"
	else
		let vg_enf_arr.enf_officer = null
	end if
	display by name vg_enf_arr.enf_off_name

	if length(vg_enf_arr.enf_status) then
		select lookup_text into vg_enf_arr.enf_st_desc from allk
			where lookup_code = vg_enf_arr.enf_status
			and lookup_func = "ENFST"
	else
		let vg_enf_arr.enf_status = null
	end if
	display by name vg_enf_arr.enf_st_desc

	call get_site_pa_area(vr_comp.site_ref,vr_comp.service_c)
		returning vr_site.site_cat, vl_null
	display vr_site.site_cat to pa_area

	select count(*) into vl_loc_change
		from comp_enf_hist
	where complaint_no = vr_comp.complaint_no

	if vl_loc_change > 0
	then
		let vg_loc_change = true
		display "Y" to alt_location	
	else
		let vg_loc_change = false
		display "N" to alt_location	
	end if	
	
	display vm_total_costs to total_cost

	select count(*) into vl_related_count from comp_enf_link
		where enf_complaint_no = vr_comp.complaint_no
	display vl_related_count to related_flag

	call disp_evidence_flag()
end function	# get_enf_info 


function get_enftr_info() 
	define
		vl_null				smallint,
		vl_action_seq		integer,
		vl_related_count	integer,
		vlr_enf_offence	record like enf_offence.*,
		vl_term_desc		like allk.lookup_text,
		vl_invoff_func		like keys.c_field

	let vl_invoff_func = skey_check("ENF_INVOFF_FUNC","ALL")

	initialize vg_enf_arr.* to null

	select comp_enf.complaint_no,
			comp_enf.law_ref,
			comp_enf.offence_ref,
			comp_enf.offence_date,
			comp_enf.offence_time_h,
			comp_enf.offence_time_m,
			comp_enf.inv_officer,
			comp_enf.enf_officer,
			comp_enf.enf_status,
			comp_enf.suspect_ref,
			comp_enf.evidence,
			comp_enf.actions,
			comp_enf.action_seq,
			comp_enf.car_id,
			comp_enf.inv_period_start,
			comp_enf.inv_period_finish,
			comp_enf.agreement_no,
			comp_enf.agreement_name,
			comp_enf.site_name
		into
			vg_enf_arr.complaint_no,
			vg_enf_arr.law_ref,
			vg_enf_arr.offence_ref,
			vg_enf_arr.offence_date,
			vg_enf_arr.offence_time_h,
			vg_enf_arr.offence_time_m,
			vg_enf_arr.inv_officer,
			vg_enf_arr.enf_officer,
			vg_enf_arr.enf_status,
			vg_enf_arr.suspect_ref,
			vg_enf_arr.evidence,
			vg_enf_arr.actions,
			vl_action_seq,
			vg_enf_arr.car_id,
			vg_enf_arr.inv_period_start,
			vg_enf_arr.inv_period_finish,
			vr_comp_enf.agreement_no,
			vr_comp_enf.agreement_name,
			vr_comp_enf.site_name
	from comp_enf
		where vr_comp.complaint_no = comp_enf.complaint_no	

	display by name vg_enf_arr.complaint_no,
					vg_enf_arr.suspect_ref,
					vg_enf_arr.inv_period_start,
					vg_enf_arr.inv_period_finish,
					vg_enf_arr.law_ref,
					vg_enf_arr.offence_ref,
					vg_enf_arr.offence_date,
					vg_enf_arr.offence_time_h,
					vg_enf_arr.offence_time_m,
					vg_enf_arr.inv_officer,
					vg_enf_arr.enf_officer,
					vg_enf_arr.enf_status,
					vg_enf_arr.actions,
					vg_enf_arr.car_id,
					vr_comp_enf.agreement_name,
					vr_comp_enf.site_name

	if length(vg_enf_arr.law_ref) then
		select lookup_text into vg_enf_arr.law_desc from allk
			where lookup_code = vg_enf_arr.law_ref
			and lookup_func = "ENFLAW"
	else
		let vg_enf_arr.law_ref = null
	end if
	display by name vg_enf_arr.law_desc

	initialize vlr_enf_offence.* to null
	initialize vl_term_desc to null
	if length(vg_enf_arr.offence_ref) then
#		select lookup_text into vg_enf_arr.offence_desc from allk
#			where lookup_code = vg_enf_arr.offence_ref
#			and lookup_func = "ENFDET"
		select * into vlr_enf_offence.* from enf_offence
			where offence_ref = vg_enf_arr.offence_ref
		let vg_enf_arr.offence_desc = vlr_enf_offence.offence_desc
		select lookup_text into vl_term_desc from allk
			where lookup_code = vlr_enf_offence.offence_term
			and lookup_func = "ENFTRM"
	else
		let vg_enf_arr.offence_ref = null
	end if
	display by name vg_enf_arr.offence_desc
	display by name vlr_enf_offence.offence_term,
							vlr_enf_offence.offence_cost
	display vl_term_desc to offence_term_desc

	if length(vg_enf_arr.inv_officer) then
		select lookup_text into vg_enf_arr.inv_off_name from allk
			where lookup_code = vg_enf_arr.inv_officer
#			and lookup_func = "ENFOFF"
			and lookup_func = vl_invoff_func
	else
		let vg_enf_arr.inv_officer = null
	end if
	display by name vg_enf_arr.inv_off_name

	if length(vg_enf_arr.enf_officer) then
		select lookup_text into vg_enf_arr.enf_off_name from allk
			where lookup_code = vg_enf_arr.enf_officer
			and lookup_func = "ENFOFF"
	else
		let vg_enf_arr.enf_officer = null
	end if
	display by name vg_enf_arr.enf_off_name

	if length(vg_enf_arr.enf_status) then
		select lookup_text into vg_enf_arr.enf_st_desc from allk
			where lookup_code = vg_enf_arr.enf_status
			and lookup_func = "ENFST"
	else
		let vg_enf_arr.enf_status = null
	end if
	display by name vg_enf_arr.enf_st_desc

	call get_site_pa_area(vr_comp.site_ref,vr_comp.service_c)
		returning vr_site.site_cat, vl_null
	display vr_site.site_cat to pa_area

	display vm_total_costs to total_cost

	select count(*) into vl_related_count from comp_enf_link
		where enf_complaint_no = vr_comp.complaint_no
	display vl_related_count to related_flag

	call disp_evidence_flag()
end function	# get_enf_info 


function get_weee_info()
	define
		vr_weee_source		record like weee_source.*

	if vr_comp.recvd_by = skey_check("WEEE_PUBLIC", "ALL")
	then
		let vr_weee_source.source_name = skey_check("WEEE_PUBLIC_DESC", "ALL")
	else
		select *
			into vr_weee_source.*
		from weee_source
			where code = vr_comp.recvd_by
	end if
#	display vr_weee_source.source_name to source_name
	display vr_weee_source.source_name to lookup_char
	display by name vr_comp.action_flag
end function	# get_weee_info


function get_weee_sales_info()
	define
		vr_weee_centre		record like weee_centre.*,
		vr_weee_proof		record like weee_proof.*,
		vl_proof_desc		like allk.lookup_text,
		vl_diry_ref			like diry.diry_ref

	initialize vr_comp_weee_sale.* to null
	initialize vr_weee_centre.* to null
	initialize vr_weee_proof.* to null

	select * 
		into vr_comp_weee_sale.*
	from comp_weee_sale
		where comp_weee_sale.sale_no = vr_comp.complaint_no

	if status != notfound
	then
		if vr_comp_weee_sale.centre_code = skey_check("WEEE_PUBLIC", "ALL")
		then
			let vr_weee_centre.centre_name = 
				skey_check("WEEE_PUBLIC_DESC", "ALL")
		else
			select *
				into vr_weee_centre.*
			from weee_centre
				where code = vr_comp_weee_sale.centre_code
		end if

 		if vg_weee_sales_entitlement = "Y"
		then
			select *
				into vr_weee_proof.*
			from weee_proof
				where customer_no = vr_customer.customer_no

			if status != notfound
			then
				display by name vr_weee_proof.proof,
								vr_weee_proof.date_seen,
								vr_weee_proof.proof_no
				display vr_weee_proof.username to weee_proof.username

				select lookup_text
					into vl_proof_desc
				from allk
					where lookup_func = "WEEPRO"
					and lookup_code = vr_weee_proof.proof

				display vl_proof_desc to proof_desc
			end if
		end if
	end if

#	display by name vr_comp_weee_sale.centre_code
#	display vr_weee_centre.centre_name to centre_name
	display vr_comp_weee_sale.centre_code to sale_centre_code
	display vr_weee_centre.centre_name to sale_centre_name
	display vr_comp.action_flag to sale_action_flag
end function


function update_comp_contract_ref_wo()				# 14/11/03 AV
	define vl_contract_ref		like comp.contract_ref

	if  vr_comp.service_c = vg_av_service
	and vg_av_installation = "Y"
	and skey_check("AV WO USED", "ALL") = "Y"
	and ( vr_comp.action_flag = "W" or vr_comp.action_flag = "X" ) then
		select contract_ref into vl_contract_ref from wo_h
			where wo_ref = vr_comp.dest_ref
			and wo_suffix = vr_comp.dest_suffix
		if status != notfound
		and length(vl_contract_ref)
		and ( vl_contract_ref != vr_comp.contract_ref
			  or length(vr_comp.contract_ref) = 0 ) then
			let vr_comp.contract_ref = vl_contract_ref
			update comp
				set contract_ref = vr_comp.contract_ref
				where complaint_no = vr_comp.complaint_no
		end if
	end if
end function	# update_comp_contract_ref_wo


function save_wo_del_contact()			# 17/11/03
	if  vr_comp.service_c = vg_av_service
	and vg_av_installation = "Y" then
		select officer_id into vg_av_arr.officer_id
			from comp_av
			where complaint_no = vr_comp.complaint_no
	end if
end function	# save_wo_del_contact


function update_complain_menu()
	define
		vlr_comp_save			record like comp.*,
		vlr_customer_save		record like customer.*,
		vlr_diry_save			record like diry.*,
		vlr_si_i_save			record like si_i.*,
		vl_diry_ref				like diry.diry_ref,
		vl_evidence				like comp_enf.evidence,
		vl_enforcement_ref		like comp_enf.source_ref,
		vl_wo_h_stat			like wo_h.wo_h_stat,
		vl_wo_type_f			like wo_h.wo_type_f,
		vl_wo_type_f_new		like wo_h.wo_type_f,
		vl_contract_ref			like wo_h.contract_ref,
		vl_wo_key				like wo_h.wo_key,
		vl_comp_text			like work_schedule.waste_type,
		vl_quantity				like work_schedule.quantity,
		vl_weighting_total		like work_schedule.weighting_total,
		vl_runcomm			    char(100),						
		vl_h_menu_desc		  	char(80),
		vl_c_menu_desc		  	char(80),
		vl_d_menu_desc		  	char(80),
		vl_t_menu_desc		  	char(80),
		vl_e_menu_desc		  	char(80),
		vl_text				    char(80),						
		vl_comp_code			char(10),
		vl_count				integer,
		vl_action_flag		    char(1),	
		vl_del_flag			    smallint,	
		vl_q_flag			    smallint,
		vl_wo_stat				record like wo_stat.*

	let vg_work_alg_items_count = 0 # Force reload of va_work_alg_items

	let vl_h_menu_desc = 
		"Update the header information of the selected ", 
		downshift(vg_record_title) clipped, "."
	let vl_c_menu_desc = 
		"Update the ", downshift(vg_compln_title) clipped,
		" information of the selected ", 
		downshift(vg_record_title) clipped, "."
	let vl_d_menu_desc = 
		"Update the destination of the selected ",
		downshift(vg_record_title) clipped, "."
	let vl_t_menu_desc = 
		"Update the text for the selected ",
		downshift(vg_record_title) clipped, "."
	let vl_e_menu_desc = 
		"Add/Update the enforcement related to the selected ",
		downshift(vg_record_title) clipped, "."

	let vg_title = vg_comp_title clipped, " Update"
#	menu vg_title
	menu "Update"
		before menu
			hide option "Destination"
			hide option "Status"
			hide option "Clinical Information"
			hide option "Nappy Information"
			hide option "DHO Information"
			hide option "Action"
			hide option "taGs"
			hide option "Suspect"
			hide option "eVidence text"
			hide option "Items"
			hide option "Add sale items"
			hide option "Close sale"
			hide option "tRee"
#			if (vg_enf_installation != "Y" and vg_enf_trade_installation != "Y")
#			or (vg_enf_installation = "Y" 
#			and vr_comp.service_c = vg_enf_service)
#			or (vg_enf_trade_installation = "Y" 
#			and vr_comp.service_c = vg_enf_trade_service)
#			or vr_comp.service_c = vg_sched_service
#			then
#				hide option "enForcement"
#			end if
			if NOT check_install("FC") then
				hide option "flYcapture"
			else
				if skey_check("FC_ENHANCED","ALL") = "Y"
				then
					if vr_comp.service_c = vg_trade_service
					and vg_trade_installation = "Y"
					then
						let vl_count = count_trade_fccomp()
					else
						if vr_comp.service_c = vg_sl_service
						and vg_sl_installation = "Y"
						then
							let vl_count = count_sl_fccomp()
						else
							if vr_comp.service_c = vg_agreq_service
							and vg_agreq_installation = "Y"
							then
								let vl_count = 0
							else
								select count(*) into vl_count from allk
									where lookup_func = "FCCOMP"
									and lookup_code = vr_comp.comp_code
									and status_yn = "Y"
							end if
						end if
					end if
					if not vl_count
					then
						hide option "flYcapture"
					end if
				end if
			end if
			case 
				when vr_comp.service_c = vg_hway_service
					and vg_hway_installation = "Y"
					show option "Status"

				when (vr_comp.service_c = vg_enf_service
					and vg_enf_installation = "Y")
					or (vr_comp.service_c = vg_enf_trade_service
					and vg_enf_trade_installation = "Y")
					show option "Action"
					show option "Suspect"
					show option "eVidence text"

				when vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
					show option "Status"
					if skey_check("AV WO USED", "ALL") = "Y"	# 1/10/3
					or vg_enf_installation = "Y"
					or vg_enf_trade_installation = "Y"
					then
						show option "Destination"
					end if 
					if skey_check("AV_DHO_ACTIVE", "ALL") = "Y"	# 1/10/3
					then
						select count(*) into vl_count from dho
							where dho_code = vr_comp.recvd_by
						if vl_count
						then
							show option "DHO Information"
						end if
					end if 
					
				when vr_comp.service_c = vg_nappy_service
					and vg_nappy_installation = "Y"
					show option "Nappy Information"
					show option "Destination"

				when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "Y"
					hide option "Header"
					hide option "Destination"

					if vg_sched_collect_items = "Y"
					then
						select wo_key, 
								wo_h_stat, 
								wo_type_f, 
								contract_ref
							into vl_wo_key, 
								vl_wo_h_stat, 
								vl_wo_type_f, 
								vl_contract_ref
						from wo_h
							where wo_ref = vr_comp.dest_ref
							and wo_suffix = vr_comp.dest_suffix

						select * into vl_wo_stat.* from wo_stat
							where wo_h_stat = vl_wo_h_stat
						if vl_wo_stat.assessment = "Y"
						or skey_check("SCHED_UPDATE_ITEMS", "ALL") = "Y"
						then
							show option "Items"
						end if

						if vr_comp.action_flag = "H"
						then
							select wo_type_f
								into vl_wo_type_f
							from comp_sched
								where complaint_no = vr_comp.complaint_no
							show option "Destination"
							show option "Header"
							show option "Items"
						end if
					end if
					
				when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "N"
					and vg_sched_collect_items = "Y"

					select wo_key, 
							wo_h_stat, 
							wo_type_f, 
							contract_ref
						into vl_wo_key, 
							vl_wo_h_stat, 
							vl_wo_type_f, 
							vl_contract_ref
					from wo_h
						where wo_ref = vr_comp.dest_ref
						and wo_suffix = vr_comp.dest_suffix

					select * into vl_wo_stat.* from wo_stat
						where wo_h_stat = vl_wo_h_stat
					if vl_wo_stat.assessment = "Y"
					or vr_comp.action_flag = "H"
					or skey_check("SCHED_UPDATE_ITEMS", "ALL") = "Y"
					then
						show option "Items"
					end if

					if vr_comp.action_flag = "H"
					then
						select wo_type_f
							into vl_wo_type_f
						from comp_sched
							where complaint_no = vr_comp.complaint_no
						show option "Destination"
						show option "Header"
					end if
					
				when vr_comp.service_c = vg_weee_service
					and vg_weee_installation = "Y"
					hide option "Header"
					hide option "Destination"
					
				when vr_comp.service_c = vg_weee_sales_service
					and vg_sales_installation = "Y"
					hide option "Header"
					hide option "Destination"
					if vr_comp.action_flag = "H"
					then
						show option "Add sale items"
						show option "Close sale"
					end if
					
				when vr_comp.service_c = vg_clin_service
					and vg_clin_installation = "Y"
					show option "Clinical Information"
					show option "Destination"
					
				when vr_comp.service_c = vg_sl_service
					and vg_sl_installation = "Y"

				when vr_comp.service_c = vg_gm_service
					and vg_gm_installation = "Y"
					show option "Destination"

				when vr_comp.service_c = vg_ert_service
					and vg_ert_installation = "Y"
					and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
					show option "Destination"
					show option "taGs"

				when vr_comp.service_c = vg_trees_service
					and vg_trees_installation = "Y"
					show option "Destination"
					show option "tRee"
				
				otherwise
					if not vg_show_source or vg_runner_call
					then
						show option "Destination"
					end if
			end case
			if check_dest_system_key(vr_comp.service_c)
			then
				show option "allOcation"
			else
				hide option "allOcation"
			end if

		{
		command key(H) "Header" vl_h_menu_desc
			call check_comp_exist(vg_progress)
				returning vl_del_flag
			if not vl_del_flag
			then
				let vl_q_flag = 1
				exit menu
			end if
			if vr_comp.date_closed is not null
			then
				# Only allow closed complaints to be updated
				# by an authorized user.
				# Unless its AV and AV WO USED = N, then let anyone update.
				let vl_del_flag = true
				if vg_av_installation = "Y"
				and vr_comp.service_c = vg_av_service
				and skey_check("AV WO USED", "ALL") = "N"
				then
					let vl_del_flag = false
				else
					if get_passwd()
					then
						if vg_passwd = skey_check("COMPLAIN_PW", "ALL")
						then
							let vl_del_flag = false
						end if
					end if
				end if
			else
				let vl_del_flag = false
			end if
			if not vl_del_flag
			then
				call set_comp_options()

--#				call fgl_keysetlabel("f7","History")
--#				call fgl_keysetlabel("f3","Customer")

				let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
				case
					when vg_ms_installation = "Y"
					and vg_ms_fault_codes matches vl_comp_code
					and length(vr_comp.comp_code)
						if vr_comp.action_flag matches "[HPI]"
						then
							call update_measurement_hold_complain()
						else
							call update_measurement_complain()
						end if

					when vr_comp.service_c = vg_av_service
						and vg_av_installation = "Y"
						call update_av_complain(vr_comp.complaint_no)

					when vr_comp.service_c = vg_enf_service
						and vg_enf_installation = "Y"
						call update_enf_complain(vr_comp.complaint_no, "X")

					when vr_comp.service_c = vg_enf_trade_service
						and vg_enf_trade_installation = "Y"
						call update_enf_trade_complain
							(vr_comp.complaint_no, "X")

					when vr_comp.service_c = vg_sl_service
						and vg_sl_installation = "Y"
						if vg_hidden_sl_sf[1].sent_date is null
						then
							call update_sl_complain(m_curr_row)
						else
							if vg_hidden_sl_sf[1].sent_date is not null
							then
								display "SENT" to sent_to_dw 
							end if
							call update_sent_sl_complain(m_curr_row)
						end if

					when vr_comp.service_c = vg_gm_service
						and vg_gm_installation = "Y"
						call update_gm_complain(vr_comp.complaint_no)

					when vr_comp.service_c = vg_ert_service
						and vg_ert_installation = "Y"
						and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
						call update_ert_complain(m_curr_row)
						
					when vr_comp.service_c = vg_trees_service
						and vg_trees_installation= "Y"
						if vr_comp.action_flag matches "[HPI]"
						then
							call update_tree_hold_complain(m_curr_row)
						else
							call update_tree_complain(m_curr_row)
						end if

					when vr_comp.service_c = vg_trade_service
						and vg_trade_installation="Y"
						call update_trade_complain(m_curr_row)

					when vr_comp.service_c = vg_agreq_service
						and vg_agreq_installation="Y"
						call update_agreq_complain(m_curr_row)

					when vr_comp.service_c = vg_nappy_service
						and vg_nappy_installation="Y"
						call update_nappy_complain(m_curr_row)

					when vr_comp.service_c = vg_clin_service
						and vg_clin_installation="Y"
						call update_clin_complain(m_curr_row)

					when vr_comp.service_c = vg_hway_service
						and vg_hway_installation="Y"
						call update_hway_complain(m_curr_row)

					when vr_comp.service_c = vg_sched_service
						and vg_sched_installation="Y"
						if vr_comp.action_flag = "H"
						then
							call update_sched_hold_complain()
						else
							call update_sched_complain(m_curr_row)
						end if

					otherwise 
						if vr_comp.action_flag matches "[HPI]"
						then
							call update_hold_complain()
						else
							call update_complain()
						end if
				end case

				call select_complain(vg_progress)
					returning vl_del_flag

				if vl_del_flag
				then
					exit menu
				end if

				call disp_comp_count()
				call disp_comp_looks()
				exit menu
			end if
		}
		
		command key(G) "taGs" 
			call update_comp_tags(vr_comp.complaint_no, 0, 0)

		command key(C) vg_compln_title vl_c_menu_desc
			if vr_comp.service_c = vg_hway_service
				and vg_hway_installation="Y" 
				and vr_comp.date_closed is not null 
			then
				call valid_error("",
			"This highways enquiry is closed and cannot be updated ",
					"")
			else
				if vr_comp.service_c = vg_av_service
					and vg_av_installation="Y" # 1/10/3
					and	skey_check("AV WO USED", "ALL") = "Y"
					and vr_comp.date_closed is not null 
				then
					call valid_error("",
				"This AV enquiry is closed and cannot be updated ","")
				else
					call check_comp_exist(vg_progress)
						returning vl_del_flag
					if not vl_del_flag
					then
						let vl_q_flag = 1
						exit menu
					else  
						call set_comp_options()

						if not add_complainant(false, false, "U") then end if
						call set_comp_options()

						call update_complaint_source()

						call select_complain(vg_progress)
							returning vl_del_flag

						if vl_del_flag
						then
							exit menu
						end if

						call disp_comp_count()
						call disp_comp_looks()
						exit menu
					end if	
				end if
			end if

		command key(S) "Status" 
			"Add/Update status information" 
			if vr_comp.service_c = vg_hway_service
				and vg_hway_installation = "Y"
			then
				call show_hway_status()
				select current_status into vr_comp_hway.current_status
					from comp_hway
				where complaint_no = vr_comp.complaint_no

				current window is iw_hwayqrycomp
				display by name vr_comp_hway.current_status
				let vl_text = 
					get_allk_desc(vr_comp_hway.current_status,"HWYST")
				display vl_text to status_desc
			else
				call show_av_status()
				call display_av_status()
			end if

		command key(A) "Action"
			"Add/Update actions" 
			if length(vg_enf_arr.suspect_ref) then
				call enf_action(14,vr_comp.complaint_no)
				call display_enf_status()
				call set_comp_options()
				call get_complain_row(vg_progress, 0)
			else
				call valid_error
					("",
					"Please add suspect details before adding any Actions",
					"I")
			end if

		command key(A) "Add sale items" "Add details of items sold to customer"
			call update_weee_sales_complain()
			call set_comp_options()
			call get_complain_row(vg_progress, 0)
			exit menu

		command key(C) "Close sale" "Close this sales request"
			call close_weee_sales_complain()
			call set_comp_options()
			if vr_comp.action_flag = "N"
			then
				call get_complain_row(vg_progress, 0)
				exit menu
			end if

		command key(S) "Suspect"  "Suspect details"
			call enf_suspect("S",9,vr_comp.complaint_no)
				returning g_enf_suspect.suspect_ref
			call display_enf_status()
			call set_comp_options()

		command key(V) "eVidence text"  "Update Evidence"
{
			call enf_evidence_upd(14, vg_enf_arr.evidence)
				returning vl_evidence
			if vl_evidence != "NULL" then
				let vg_enf_arr.evidence = vl_evidence
				update comp_enf
					set evidence = vl_evidence
					where complaint_no = vr_comp.complaint_no
			end if
}
			call enter_evidence(vr_comp.complaint_no)
			call set_comp_options()

		command key(I) "Nappy Information"
			let vl_runcomm = "exec fglgo_nappy_disp ",
				vr_comp_nappy.nappy_ref using "<<<<<<<<", " A"
			call os_exec(vl_runcomm, false)

		command key(I) "Clinical Information"
			let vl_runcomm = "exec fglgo_clin_disp ",
				vr_comp_clin.clinical_ref using "<<<<<<<<", " A"
			call os_exec(vl_runcomm, false)

		command key(I) "DHO Information"
			select * into vr_comp_av.* from comp_av
				where complaint_no = vr_comp.complaint_no
			call add_dho(vr_comp.recvd_by,
					vr_comp_av.dho_rep, vr_comp_av.dho_cc_building)
				returning vg_av_arr.dho_rep, vg_av_arr.dho_cc_building
			call set_comp_options()
			if vg_av_arr.dho_rep is not null
			then
				update comp_av
					set dho_rep = vg_av_arr.dho_rep,
						dho_cc_building = vg_av_arr.dho_cc_building
					where complaint_no = vr_comp.complaint_no
			end if

		command key(O) "allOcation" 
			"Display/Update allocation information."
			call enter_destination("U")
				returning vr_comp_destination.*

		command key(D) "Destination" vl_d_menu_desc
			call load_comp_text_array(vr_comp.complaint_no)
			if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
			then
				call load_comp_det_text_array() 
			end if
			call save_wo_del_contact()		# 17/11/03

			if vr_comp.service_c = vg_sched_service
			and vg_sched_installation = "Y"
			and vg_sched_collect_items = "Y"
			then
				call update_comp_sched_destination(vl_wo_type_f)
			else
				call update_comp_destination()
			end if

			call update_comp_contract_ref_wo()		# 14/11/03 AV
			if vr_comp.text_flag = "N"
			then
				select count(*)
					into vl_count
				from comp_text
					where complaint_no = vr_comp.complaint_no

				if vl_count
				then
					let vr_comp.text_flag = "Y"
					update comp 
						set text_flag = "Y"
					where complaint_no = vr_comp.complaint_no
					display by name vr_comp.text_flag
				end if
			end if
			
			if vr_comp.date_closed is null
			or (vr_comp.service_c = vg_av_service
				and skey_check("AV_ALWAYS_DISP_RUN", "ALL") = "Y")
			then
				display "RUNNING" to comp_status attribute(green, reverse)
			else
				display "CLOSED" to comp_status attribute(red, reverse)
			end if
			exit menu

		{
		command key(T) "Text" vl_t_menu_desc
			let g_text_update = true
			let vg_customer_save.* = vr_customer.*
			initialize vr_customer.* to null
			call text_yes_no()
			let g_text_update = false
			call set_comp_options()
			let vr_customer.* = vg_customer_save.*
			display by name vr_comp.text_flag
		}

		{
		command key(F) "enForcement" vl_e_menu_desc
			# Find out if the complaint has a related enforcement

# BJG - Changed to use new table which allows multiple links from enforcements.
#		NOTE: One enforcement per complaint but many complaints per enforcement.
#
#			select complaint_no
#				into vl_enforcement_ref
#			from comp_enf
#				where source_ref = vr_comp.complaint_no
#
			select enf_complaint_no into vl_enforcement_ref
				from comp_enf_link
				where source_complaint = vr_comp.complaint_no
			if vl_enforcement_ref
			then
				let vl_runcomm = 
					"exec fglgo_complain U X X X X ", vl_enforcement_ref
				call os_exec(vl_runcomm, false)
			else
				if allow("enf_add_upd")
				then
					call start_wait()
					call load_comp_text_array(vr_comp.complaint_no) # BJG 21/01/08
					select diry_ref
						into vl_diry_ref
					from diry
						where source_ref = vr_comp.complaint_no
						and source_flag = "C"
					call end_wait()
					if vl_diry_ref 
					then
						let vlr_comp_save.* = vr_comp.*
						let vlr_customer_save.* = vr_customer.*
						let vlr_diry_save.* = vr_diry.*
						let vlr_si_i_save.* = vr_si_i.*
						call history_save_text(true)	
						let vg_allow_text_clear = true
						open window iw_complain_2 at 1,1 with 20 rows, 90 columns
						#ADJ/BJG ENFTR Trade enforcement.
						if vr_comp.service_c = vg_trade_service
						and vg_trade_installation = "Y"
						then
							call add_enf_trade_complain(vl_diry_ref)
								returning vl_action_flag
						else
							call add_enf_complain(vl_diry_ref)
								returning vl_action_flag
						end if
						close window iw_complain_2
						let vg_allow_text_clear = false
						let vr_comp.* = vlr_comp_save.*
						let vr_customer.* = vlr_customer_save.*
						let vr_diry.* = vlr_diry_save.*
						let vr_si_i.* = vlr_si_i_save.*
						call history_save_text(false)	
						if vl_action_flag != "I"
						then
							call update_comp_enf_source_ref(vl_diry_ref)
						end if
						exit menu # This should force screen refresh.
					else
						call valid_error("", 
							"ERROR: The complaint source cannot be found", "")
					end if
				end if
			end if	
			}

		command key(Y) "flYcapture" "Update flycapture statistics"
			if update_comp_flycapture(true) then end if

		command key(I) "Items" "Update schedule collection items"
			call item_sched_comp(vl_wo_type_f, vl_contract_ref, "U")
				returning vl_wo_type_f_new, vg_null 
			if length(vl_wo_type_f_new)
			then
				delete from comp_sched_item 
					where complaint_no = vr_comp.complaint_no
				call populate_comp_sched_item()
				call pop_display_collection_items()
					returning vl_comp_text, vl_quantity, vl_weighting_total, vg_null
				select * into vl_wo_stat.* from wo_stat
					where wo_h_stat = vl_wo_h_stat
				if vl_wo_stat.assessment = "Y"
				or vr_comp.action_flag = "H"
				or skey_check("SCHED_UPDATE_ITEMS","ALL") = "Y" # BJG
				then
					update work_schedule set 
						waste_type = vl_comp_text,
						quantity = vl_quantity,
						weighting_total = vl_weighting_total
					where wo_key = vl_wo_key
				else
					update work_schedule set 
						waste_type = vl_comp_text
					where wo_key = vl_wo_key
				end if

				call set_comp_options()
				display vl_quantity to quantity
				display vl_comp_text to waste_type
			end if

		command key(R) "tRee" "Update the tree details"
			call comp_update_tree_detail
			(
				vr_comp_tree.tree_ref,
				vr_comp.site_ref,
				vr_comp.item_ref,
				vr_comp.feature_ref,
				vr_comp.contract_ref
			)

		command key(control-t)
			call complaint_history()
			call get_complain_row(vg_progress, 0) whenever error continue

		on action about
			call os_exec("exec fglgo_about", 1)

		on action Exit
			#let vg_q_flag = 0
			exit menu

		on action close
			#let vg_q_flag = 0
			exit menu
	end menu
end function


function create_temp_comp_01_02()
	whenever error continue
	if vg_action_type
	then
		drop table comp_01
		create temp table comp_01
		(
		complaint_no	integer,
		service_c		char(6),
		pos				integer 
		)
	else
		drop table comp_02
		create temp table comp_02
		(
		complaint_no	integer,
		service_c		char(6),
		pos				integer
		)
	end if

	whenever error stop
end function


function select_complain_rows()
	define
		vl_match_service	char(10)

	call create_temp_comp_01_02()

	call mstart_wait(vg_title clipped)
    
	call errorlog(vg_query_text)
	prepare ip_statement_1 from vg_query_text			
	declare c_complain_rows cursor for ip_statement_1

	if vg_action_type
	then
		prepare ip_complain_insert_01 from 
			"insert into comp_01 values (?, ?, ?)" 
	else
		prepare ip_complain_insert_02 from 
			"insert into comp_02 values (?, ?, ?)" 
	end if

	let vg_tot_in_list = 1

	foreach c_complain_rows into vr_comp.complaint_no, vr_comp.service_c
		if length(vg_user_allowed_services)
		then
			let vl_match_service = "*", vr_comp.service_c clipped, ",*"
			if vg_user_allowed_services not matches vl_match_service
			then
				continue foreach
			end if
		end if

		if vg_action_type
		then
			execute ip_complain_insert_01 using vr_comp.complaint_no, 
												vr_comp.service_c,
												vg_tot_in_list
		else
			execute ip_complain_insert_02 using vr_comp.complaint_no, 
												vr_comp.service_c,
												vg_tot_in_list
		end if
		let vg_tot_in_list = vg_tot_in_list + 1
	end foreach

	let vg_tot_in_list = vg_tot_in_list - 1

	if vg_action_type
	then
		create unique index idx_comp_01 on comp_01(pos)
	else
		create unique index idx_comp_02 on comp_02(pos)
	end if

	call end_wait()

end function


function comp_fly_of()
	open window iw_comp_fly with form "comp_flycap"
end function


function comp_fly_cf()
	close window iw_comp_fly
end function


function update_comp_flycapture(vl_input_flag)
	define
		vl_point,
		vl_count,
		vl_add_flag,
		vl_input_flag		integer

	call comp_fly_of()

	if not vg_new_flycomp
	then
		initialize vlr_comp_flycap.* to null
		let vl_count = 0
		let vl_addwaste_count = 0
		let vl_add_flag = false
		if length(vr_comp.complaint_no) AND NOT vg_customer_retain then
			select * into vlr_comp_flycap.* from comp_flycap
				where complaint_no = vr_comp.complaint_no

			if status = notfound
			then
				for vl_count = 1 to 50
					initialize vlr_addwaste[vl_count].* to null
				end for
				initialize vlr_fly_loads.* to null
				let vl_land_desc = null
				let vl_waste_desc = null

				let vl_add_flag = true
			else
                INITIALIZE vlr_comp_flycap.complaint_no TO null

				select lookup_text into vl_land_desc from allk
					where lookup_func = "FCLAND"
					and lookup_code = vlr_comp_flycap.landtype_ref
				select lookup_text into vl_waste_desc from allk
					where lookup_func = "FCWSTE"
					and lookup_code = vlr_comp_flycap.dominant_waste_ref
				select * into vlr_fly_loads.* from fly_loads
					where load_ref = vlr_comp_flycap.load_ref

				if vl_input_flag
				then
					call load_addwaste()
                    IF vl_input_flag = 2
                    THEN
                        # It gets here if called from add_normal_complain so we want to
                        # force insert of details but not use default values.
                        let vl_add_flag = 2
                    END if
				else
					call load_addwaste_disp()
				end if
			end if

		else
			for vl_count = 1 to 50
				initialize vlr_addwaste[vl_count].* to null
			end for

			initialize vlr_fly_loads.* to null
			let vl_land_desc = null
			let vl_waste_desc = null
			let vl_add_flag = true
			let vg_new_flycomp = true
		end if
	end IF

    IF length(vlr_comp_flycap.landtype_ref)=0 THEN
        LET vl_land_desc = NULL
    END IF
    IF length(vlr_comp_flycap.dominant_waste_ref)=0 THEN
        LET vl_waste_desc = NULL
    END IF
    IF length(vlr_comp_flycap.load_ref)=0 THEN
        INITIALIZE vlr_fly_loads.* to NULL
    END IF
	if vl_add_flag = 1
	then
		select lookup_code, lookup_text
			into vlr_comp_flycap.landtype_ref, vl_land_desc
			from allk
			where lookup_func = "FCLAND"
			and lookup_num = 1

		select lookup_code, lookup_text
			into vlr_comp_flycap.dominant_waste_ref, vl_waste_desc
			from allk
			where lookup_func = "FCWSTE"
			and lookup_num = 1

		if status != notfound
		then
			let vlr_comp_flycap.dominant_waste_qty = 1
		end if

		select * 
			into vlr_fly_loads.* 
		from fly_loads
			where sequence = 1

		if status != notfound
		then
			let vlr_comp_flycap.load_ref = vlr_fly_loads.load_ref
			let vlr_comp_flycap.load_unit_cost = vlr_fly_loads.unit_cost
			let vlr_comp_flycap.load_qty = vlr_fly_loads.default_qty
			let vlr_comp_flycap.load_est_cost = vlr_fly_loads.default_qty
												* vlr_fly_loads.unit_cost
		end if
	end if

	for vl_point = 1 to 3
		display vlr_addwaste[vl_point].waste_ref to
											sa_flycapture[vl_point].waste_ref
		display vlr_addwaste[vl_point].waste_desc to
											sa_flycapture[vl_point].waste_desc
		display vlr_addwaste[vl_point].waste_qty to
											sa_flycapture[vl_point].waste_qty
	end for

	display by name vlr_comp_flycap.landtype_ref,
							vlr_comp_flycap.dominant_waste_ref,
							vlr_comp_flycap.dominant_waste_qty,
							vlr_comp_flycap.load_ref,
							vlr_comp_flycap.load_unit_cost,
							vlr_comp_flycap.load_qty,
							vlr_comp_flycap.load_est_cost

	display by name vlr_fly_loads.load_desc
	display vl_land_desc to landtype_desc
	display vl_waste_desc to waste_type_desc

	if vl_input_flag
	then
		if not input_comp_flycapture(vl_add_flag)
		then
			call comp_fly_cf()
			return false
		end if
	else
		open window iw_fc_menu at 1, 1 with 2 rows, 79 columns
		menu "Fly capture Information"

			#ADJ GENERO
			{
			command key(f6)
				call join()

			command key(Escape)
				exit menu

			on action cancel
				exit menu
			}

			command "Scroll" "Scroll the additional waste information"
				current window is iw_comp_fly
				call set_count(vl_addwaste_count)
				display array vlr_addwaste to sa_flycapture.*
				current window is iw_fc_menu

			command "Update" "Update the fly capture information"
				current window is iw_comp_fly
				call load_addwaste()
				for vl_point = 1 to 3
					display vlr_addwaste[vl_point].waste_ref to
											sa_flycapture[vl_point].waste_ref
					display vlr_addwaste[vl_point].waste_desc to
											sa_flycapture[vl_point].waste_desc
					display vlr_addwaste[vl_point].waste_qty to
											sa_flycapture[vl_point].waste_qty
				end for
				if input_comp_flycapture(vl_add_flag)
				then
					let vl_add_flag = false
				end if
				call load_addwaste_disp()
				for vl_point = 1 to 3
					display vlr_addwaste[vl_point].waste_ref to
											sa_flycapture[vl_point].waste_ref
					display vlr_addwaste[vl_point].waste_desc to
											sa_flycapture[vl_point].waste_desc
					display vlr_addwaste[vl_point].waste_qty to
											sa_flycapture[vl_point].waste_qty
				end for
				current window is iw_fc_menu

			on action about
				call os_exec("exec fglgo_about", 1)

			on action Exit
				exit menu

			on action close
				exit menu

		end menu
		close window iw_fc_menu
	end if

	call comp_fly_cf()
	return true
end function


function load_addwaste()
	define
		vl_count				integer,
		vl_sequence			integer

	for vl_count = 1 to 50
		initialize vlr_addwaste[vl_count].* to null
	end for

	declare c_addwaste_1 cursor for
		select waste_ref, waste_qty, sequence from comp_flycap_addw
			where complaint_no = vr_comp.complaint_no order by sequence
	let vl_count = 1
	foreach c_addwaste_1 into vlr_addwaste[vl_count].waste_ref,
									vlr_addwaste[vl_count].waste_qty,
									vl_sequence
		select lookup_text into vlr_addwaste[vl_count].waste_desc from allk
			where lookup_func = "FCWSTE"
			and lookup_code = vlr_addwaste[vl_count].waste_ref
		let vl_count = vl_count + 1
	end foreach
	declare c_addwaste_2 cursor for
		select lookup_code, lookup_text from allk
			where lookup_func = "FCWSTE" and lookup_code not in (
			select waste_ref from comp_flycap_addw
			where complaint_no = vr_comp.complaint_no)
			and lookup_code != vlr_comp_flycap.dominant_waste_ref
			order by lookup_code
	foreach c_addwaste_2 into vlr_addwaste[vl_count].waste_ref,
										vlr_addwaste[vl_count].waste_desc
		let vlr_addwaste[vl_count].waste_qty = 0
		let vl_count = vl_count + 1
	end foreach
	let vl_count = vl_count - 1
	let vl_addwaste_count = vl_count
end function

function load_addwaste_disp()
	define
		vl_count				integer,
		vl_sequence			integer

	for vl_count = 1 to 50
		initialize vlr_addwaste[vl_count].* to null
	end for

	declare c_addwaste_3 cursor for
		select waste_ref, waste_qty, sequence from comp_flycap_addw
			where complaint_no = vr_comp.complaint_no order by sequence
	let vl_count = 1
	foreach c_addwaste_3 into vlr_addwaste[vl_count].waste_ref,
									vlr_addwaste[vl_count].waste_qty,
									vl_sequence
		select lookup_text into vlr_addwaste[vl_count].waste_desc from allk
			where lookup_func = "FCWSTE"
			and lookup_code = vlr_addwaste[vl_count].waste_ref
		let vl_count = vl_count + 1
	end foreach
	let vl_count = vl_count - 1
	let vl_addwaste_count = vl_count
end function


function input_comp_flycapture(vl_add_flag)
	define
		vl_return,
		vl_point,
		vl_add_flag					integer,
		vl_orig_dom_waste_ref	like comp_flycap.dominant_waste_ref,
		vl_orig_dom_waste_qty	like comp_flycap.dominant_waste_qty

--#	call fgl_keysetlabel("f12", "Additional Waste")

	let vl_orig_dom_waste_ref = vlr_comp_flycap.dominant_waste_ref
	let vl_orig_dom_waste_qty = vlr_comp_flycap.dominant_waste_qty

	input by name vlr_comp_flycap.landtype_ref,
						vlr_comp_flycap.dominant_waste_ref,
						vlr_comp_flycap.dominant_waste_qty,
						vlr_comp_flycap.load_ref,
						vlr_comp_flycap.load_qty without defaults

		on action cancel
			let int_flag = true
			exit input

		on action close
			let int_flag = true
			exit input

		on action f2_lookup
			case
				when infield(landtype_ref)
					let vlr_comp_flycap.landtype_ref = allk_look("FCLAND","", "Y")
					call set_comp_options()
					display by name vlr_comp_flycap.landtype_ref
					next field landtype_ref

				when infield(dominant_waste_ref)
					let vlr_comp_flycap.dominant_waste_ref =
												allk_look("FCWSTE","", "Y")
					call set_comp_options()
					display by name vlr_comp_flycap.dominant_waste_ref
					select lookup_text into vl_waste_desc from allk
						where lookup_func = "FCWSTE"
						and lookup_code = vlr_comp_flycap.dominant_waste_ref
					if status = notfound
					then
						let vl_waste_desc = null
					end if
					display vl_waste_desc to waste_type_desc
					if not length(vlr_comp_flycap.dominant_waste_qty)
					then
						let vlr_comp_flycap.dominant_waste_qty = 1
					end if
					if vlr_comp_flycap.dominant_waste_ref != vl_orig_dom_waste_ref
					and vl_addwaste_count > 0
					then
						call replace_addnl_waste(vlr_comp_flycap.dominant_waste_ref,
														vl_orig_dom_waste_ref,
														vl_orig_dom_waste_qty)
							returning vlr_comp_flycap.dominant_waste_qty
					end if
					display by name vlr_comp_flycap.dominant_waste_qty
					next field dominant_waste_ref

				when infield(load_ref)
					let vlr_comp_flycap.load_ref = fly_load_look()
					call set_comp_options()
					display by name vlr_comp_flycap.load_ref
					next field load_ref

				otherwise
					call valid_error("",
						"No lookup available on this field", "")
			end case

		on action fly_capture 	# update the additional waste types
			if not length(vlr_comp_flycap.dominant_waste_ref)
			then
				call valid_error("",
					"A dominant waste type must be identified first", "")
			else
				if vl_add_flag
				and not vl_addwaste_count
				then
					call load_addwaste()
				end if
				if vl_addwaste_count
				then
					call update_addwaste()
					if int_flag
					then
						let int_flag = false
					end if
					for vl_point = 1 to 3
						display vlr_addwaste[vl_point].waste_ref to
											sa_flycapture[vl_point].waste_ref
						display vlr_addwaste[vl_point].waste_desc to
											sa_flycapture[vl_point].waste_desc
						display vlr_addwaste[vl_point].waste_qty to
											sa_flycapture[vl_point].waste_qty
					end for
				else
					call valid_error("",
							"No other waste types have been defined", "")
				end if
			end if

		#ADJ GENERO
		{
		on key (f6)
			call join()
			call set_comp_options()
		}

		after field landtype_ref
			if length(vlr_comp_flycap.landtype_ref)
			then
				select lookup_text into vl_land_desc from allk
					where lookup_func = "FCLAND"
					and lookup_code = vlr_comp_flycap.landtype_ref
				if status = notfound
				then
					call valid_error("","A valid land type must be entered","")
					next field landtype_ref
				else
					display vl_land_desc to landtype_desc
				end if
			end if

		after field dominant_waste_ref
			if length(vlr_comp_flycap.dominant_waste_ref)
			then
				select lookup_text into vl_waste_desc from allk
					where lookup_func = "FCWSTE"
					and lookup_code = vlr_comp_flycap.dominant_waste_ref
				if status = notfound
				then
					call valid_error("","A valid waste type must be entered","")
					next field dominant_waste_ref
				else
					display vl_waste_desc to waste_type_desc
				end if
				if not length(vlr_comp_flycap.dominant_waste_qty)
				then
					let vlr_comp_flycap.dominant_waste_qty = 1
				end if
				if vlr_comp_flycap.dominant_waste_ref != vl_orig_dom_waste_ref
				and vl_addwaste_count > 0
				then
					call replace_addnl_waste(vlr_comp_flycap.dominant_waste_ref,
														vl_orig_dom_waste_ref,
														vl_orig_dom_waste_qty)
							returning vlr_comp_flycap.dominant_waste_qty
				end if
				display by name vlr_comp_flycap.dominant_waste_qty
			end if

		after field dominant_waste_qty
			if length(vlr_comp_flycap.dominant_waste_qty)
			then
				if vlr_comp_flycap.dominant_waste_qty < 1
				or vlr_comp_flycap.dominant_waste_qty > 999
				then
					call valid_error("",
								"Waste type qty must be between 1 and 999","")
					next field dominant_waste_qty
				end if
			end if

		after field load_ref
			if length(vlr_comp_flycap.load_ref)
			then
				select * into vlr_fly_loads.* from fly_loads
					where load_ref = vlr_comp_flycap.load_ref
				if status = notfound
				then
					call valid_error("","A valid load size must be entered","")
					next field load_ref
				else
					let vlr_comp_flycap.load_unit_cost = vlr_fly_loads.unit_cost
					let vlr_comp_flycap.load_qty = vlr_fly_loads.default_qty
					let vlr_comp_flycap.load_est_cost = vlr_fly_loads.unit_cost *
																	vlr_fly_loads.default_qty
					display by name vlr_fly_loads.load_desc,
											vlr_comp_flycap.load_unit_cost,
											vlr_comp_flycap.load_qty,
											vlr_comp_flycap.load_est_cost
				end if
			end if

		before field load_qty
			if not length(vlr_comp_flycap.load_ref)
			or vlr_fly_loads.default_qty = 1
			then
				next field next
			end if

		after field load_qty
			if length(vlr_comp_flycap.load_qty)
			and (vlr_comp_flycap.load_qty < vlr_fly_loads.default_qty
			or vlr_comp_flycap.load_qty > 999)
			then
				call valid_error("","Load size qty must be between 1 and 999","")
				next field load_qty
			else
				let vlr_comp_flycap.load_est_cost = vlr_fly_loads.unit_cost *
																	vlr_fly_loads.default_qty
				display by name vlr_comp_flycap.load_est_cost
			end if

		after input
			if int_flag
			then
				exit input
			end if

			if not length(vlr_comp_flycap.landtype_ref)
			then
				call valid_error("","A valid land type must be entered","")
				next field landtype_ref
			end if

{
# May want to comment out the following validation.
			if not length(vlr_comp_flycap.dominant_waste_ref)
			then
				call valid_error("",
					"A valid dominant waste type must be entered","")
				next field dominant_waste_ref
			end if
			if not vlr_comp_flycap.dominant_waste_qty
			then
				call valid_error("",
					"A valid dominant waste qty must be entered","")
				next field dominant_waste_qty
			end if
			if not length(vlr_comp_flycap.load_ref)
			then
				call valid_error("","A valid load size must be entered","")
				next field load_ref
			end if
			if vl_add_flag
			and not vl_addwaste_count
			then
				call load_addwaste()
				if vl_addwaste_count
				then
					call update_addwaste()
				end if
			end if
# 		......  end of possible comment out block.
}

	end input

	if int_flag
	then
		let int_flag = false
		if vg_new_flycomp
		then
			let vg_new_flycomp = false
		else
			call valid_error("",
							"The fly capture information has NOT been updated","")
		end if
		let vl_return = false
	ELSE
        IF vl_add_flag = 2
        THEN
            LET vg_new_flycomp = TRUE
        END if
		if vg_new_flycomp = FALSE
		then
			call update_flycap_tables(vl_add_flag)
		end if
		let vl_return = true
	end if

--#	call fgl_keysetlabel("f12", "")
	return vl_return

end function


function replace_addnl_waste(vl_new_waste_ref,vl_old_waste_ref,vl_old_qty)
	define
		vl_new_waste_ref		like comp_flycap.dominant_waste_ref,
		vl_old_waste_ref		like comp_flycap.dominant_waste_ref,
		vl_old_qty				like comp_flycap.dominant_waste_qty,
		vl_new_qty				like comp_flycap.dominant_waste_qty,
		vl_old_waste_desc		like allk.lookup_text,
		vl_index					integer

	select lookup_text into vl_old_waste_desc from allk
		where lookup_func = "FCWSTE" and lookup_code = vl_old_waste_ref

	let vl_new_qty = 0

	for vl_index = 1 to vl_addwaste_count
		if vlr_addwaste[vl_index].waste_ref = vl_new_waste_ref
		then
			let vl_new_qty = vlr_addwaste[vl_index].waste_qty
			let vlr_addwaste[vl_index].waste_ref = vl_old_waste_ref
			let vlr_addwaste[vl_index].waste_desc = vl_old_waste_desc
			let vlr_addwaste[vl_index].waste_qty = vl_old_qty
			if vl_index < 4
			then
				display vlr_addwaste[vl_index].waste_ref to
											sa_flycapture[vl_index].waste_ref
				display vlr_addwaste[vl_index].waste_desc to
											sa_flycapture[vl_index].waste_desc
				display vlr_addwaste[vl_index].waste_qty to
											sa_flycapture[vl_index].waste_qty
			end if
			exit for
		end if
	end for

	if vl_new_qty = 0
	then
		let vl_new_qty = 1
	end if
	return vl_new_qty
end function


function update_addwaste()
	define
		vl_arr_curr		integer,
		vl_scr_line		integer

	options delete key f40, insert key f41, accept key esc
	call fgl_keysetlabel("delete", "")
	call fgl_keysetlabel("insert", "")
	call set_count(vl_addwaste_count)

	input array vlr_addwaste without defaults from sa_flycapture.*

		on action cancel
			let int_flag = true
			exit input

		on action close
			let int_flag = true
			exit input

		before row
			let vl_arr_curr = arr_curr()
			let vl_scr_line = scr_line()
			if vl_arr_curr > vl_addwaste_count
			then
				let vl_arr_curr = vl_arr_curr -1
				let vl_scr_line = vl_scr_line -1
				error "There are no more rows in the direction you are going"
				call fgl_dialog_setcurrline(vl_scr_line, vl_arr_curr)
			end if

		before field waste_ref
			next field waste_qty

		before field waste_desc
			next field waste_qty

		after field waste_qty
			if vlr_addwaste[vl_arr_curr].waste_qty = ""
			or vlr_addwaste[vl_arr_curr].waste_qty < 0
			or vlr_addwaste[vl_arr_curr].waste_qty > 999
			then
				call valid_error("","Waste qty must be between 0 and 999","")
				next field waste_qty
			end if
	end input

	options delete key f8, insert key f7

end function


function update_flycap_tables(vl_add_flag)
	define
		vl_add_flag	smallint,
		vl_point		INTEGER
    DEFINE vl_count SMALLINT

    if skey_check("FC_ENHANCED","ALL") = "Y" then
        if length(vr_comp.comp_code)=0 THEN
            RETURN
        else
            select count(*) into vl_count from allk
                where lookup_func = "FCCOMP"
                and lookup_code = vr_comp.comp_code
                and status_yn = "Y"
            if vl_count=0 THEN
                RETURN 
            end if
        end if
    else
        
    end if
            
	if vl_add_flag
	then
		let vlr_comp_flycap.complaint_no = vr_comp.complaint_no
		insert into comp_flycap values (vlr_comp_flycap.*)
		if vg_new_flycomp != 2
		then
			call valid_error("",
						"The fly capture information has been added","")
		end if
	else
		update comp_flycap set
			landtype_ref = vlr_comp_flycap.landtype_ref,
			dominant_waste_ref = vlr_comp_flycap.dominant_waste_ref,
			dominant_waste_qty = vlr_comp_flycap.dominant_waste_qty,
			load_ref = vlr_comp_flycap.load_ref,
			load_unit_cost = vlr_comp_flycap.load_unit_cost,
			load_qty = vlr_comp_flycap.load_qty,
			load_est_cost = vlr_comp_flycap.load_est_cost
				where complaint_no = vr_comp.complaint_no
		call valid_error("",
						"The fly capture information has been updated","")
	end if
	create temp table sort_addwaste (
		waste_ref char(6),
		waste_qty smallint
		)
	if vl_addwaste_count
	then
		for vl_point = 1 to vl_addwaste_count
			insert into sort_addwaste values(
				vlr_addwaste[vl_point].waste_ref,
				vlr_addwaste[vl_point].waste_qty)
		end for
	end if

	delete from comp_flycap_addw
		where complaint_no = vr_comp.complaint_no

	declare c_sort_addwaste cursor for select * from sort_addwaste
		order by waste_ref

	let vl_point = 1

	foreach c_sort_addwaste into vlr_comp_addw.waste_ref,
											vlr_comp_addw.waste_qty
		if vlr_comp_addw.waste_qty
		then
			insert into comp_flycap_addw values(
					vr_comp.complaint_no,
					vl_point,
					vlr_comp_addw.waste_ref,
					vlr_comp_addw.waste_qty)
			let vl_point = vl_point + 1
		end if
	end foreach

	drop table sort_addwaste
end function


function count_trade_fccomp()
	define
		vl_count			integer,
		vl_comp_code	like comp.comp_code

	declare fc_trade_cursor cursor for
		select comp_code from comp_tr
			where complaint_no = vr_comp.complaint_no
	let vl_count = 0
	foreach fc_trade_cursor into vl_comp_code
		select count(*) into vl_count from allk
			where lookup_func = "FCCOMP"
			and lookup_code = vl_comp_code
			and status_yn = "Y"
		if vl_count
		then
			exit foreach
		end if
	end foreach
	return vl_count
end function


function count_sl_fccomp()
	define
		vl_count			integer,
		vl_comp_code	like comp.comp_code

	declare fc_sl_cursor cursor for
		select comp_code from comp_sl
			where complaint_no = vr_comp.complaint_no
	let vl_count = 0
	foreach fc_sl_cursor into vl_comp_code
		select count(*) into vl_count from allk
			where lookup_func = "FCCOMP"
			and lookup_code = vl_comp_code
			and status_yn = "Y"
		if vl_count
		then
			exit foreach
		end if
	end foreach
	return vl_count
end function


function show_bv199()
	define
		vlr_comp_bv199		record like comp_bv199.*,
		vlr_bv_transect		record like bv_transect.*,
		vl_continue			char(1),
		vl_landuse_desc		like allk.lookup_text,
		vl_measure_desc		like allk.lookup_text,
		vl_grade_flag		smallint,
		vl_litter_grade		char(3),
		vl_detritus_grade	char(3),
		vl_graffiti_grade	char(3),
		vl_flyposting_grade	char(3)

	call bv199_of()

	select * into vlr_comp_bv199.*, vlr_bv_transect.*
		from comp_bv199, outer bv_transect
		where comp_bv199.complaint_no = vr_comp.complaint_no
		and comp_bv199.transect_ref = bv_transect.transect_ref

	if status = notfound
	then
		initialize vlr_comp_bv199.* to null
		initialize vlr_bv_transect.* to null
	end if

	display by name vlr_comp_bv199.transect_ref,
						vlr_bv_transect.transect_date,
						vlr_bv_transect.start_ref,
						vlr_bv_transect.end_ref,
						vlr_bv_transect.description,
						vlr_bv_transect.ward_flag,
						vlr_bv_transect.lowdensity_flag

	select lookup_text into vl_landuse_desc from allk
		where lookup_func = "BVLAND"
		and lookup_code = vlr_bv_transect.land_use

	select lookup_text into vl_measure_desc from allk
		where lookup_func = "BVMEAS"
		and lookup_code = vlr_bv_transect.measure_method

	select lookup_text into vl_litter_grade from allk
		where lookup_func = "BVGRAD"
		and lookup_code = vlr_comp_bv199.litter_grade

	select lookup_text into vl_detritus_grade from allk
		where lookup_func = "BVGRAD"
		and lookup_code = vlr_comp_bv199.detritus_grade

	select lookup_text into vl_graffiti_grade from allk
		where lookup_func = "BVGRAD"
		and lookup_code = vlr_comp_bv199.graffiti_grade

	select lookup_text into vl_flyposting_grade from allk
		where lookup_func = "BVGRAD"
		and lookup_code = vlr_comp_bv199.flyposting_grade

	display vl_landuse_desc, vl_measure_desc
		to landuse_desc, measure_desc

{
	let vl_grade_flag = 1
	while int_flag = false
		case vl_grade_flag
			when 1
				display vl_detritus_grade, vl_graffiti_grade, vl_flyposting_grade
					to detritus_grade, graffiti_grade, flyposting_grade

				display vl_litter_grade to litter_grade
					attribute(reverse,yellow)

				display by name vlr_comp_bv199.litter_text

			when 2
				display vl_litter_grade, vl_graffiti_grade, vl_flyposting_grade
					to litter_grade, graffiti_grade, flyposting_grade

				display vl_detritus_grade to detritus_grade
					attribute(reverse, yellow)

				display vlr_comp_bv199.detritus_text to litter_text
			when 3
				display vl_litter_grade, vl_detritus_grade, vl_flyposting_grade
					to litter_grade, detritus_grade, flyposting_grade

				display vl_graffiti_grade to graffiti_grade
					attribute(reverse, yellow)

				display vlr_comp_bv199.graffiti_text to litter_text

			when 4
				display vl_litter_grade, vl_detritus_grade, vl_graffiti_grade
					to litter_grade, detritus_grade, graffiti_grade

				display vl_flyposting_grade to flyposting_grade
					attribute(reverse,yellow)

				display vlr_comp_bv199.flyposting_text to litter_text
		end case

		input vl_continue from btok
			on key("L", F40)
				let vl_grade_flag = 1
				exit input
			on key("D", F41)
				let vl_grade_flag = 2
				exit input
			on key("G", F42)
				let vl_grade_flag = 3
				exit input
			on key("F", F43)
				let vl_grade_flag = 4
				exit input
			on key(accept)
				let int_flag = true
				exit input
			on action cancel
				let int_flag = true
				exit input
			on action close
				let int_flag = true
				exit input
			on key(return)
				let int_flag = true
				exit input
		end input
	end while
}

	display vl_litter_grade,
				vl_detritus_grade,
				vl_graffiti_grade,
				vl_flyposting_grade
		to litter_grade,
			detritus_grade,
			graffiti_grade,
			flyposting_grade

	display by name vlr_comp_bv199.litter_text,
						vlr_comp_bv199.detritus_text,
						vlr_comp_bv199.graffiti_text,
						vlr_comp_bv199.flyposting_text

	menu "NI 195"
		on action accept
			let int_flag = true
			exit menu
		on action cancel
			let int_flag = true
			exit menu
		on action close
			let int_flag = true
			exit menu
	end menu
	let int_flag = false
	call bv199_cf()

end function


function bv199_of()
	open window iw_bv199 at 12, 1 with form "comp_bv199" 

{
	call fgl_drawbox(11, 79, 1, 1)
	display "BV199 INFORMATION" at 1,31
	display "Grades:" at 6,2
--#	call fgl_keysetlabel("f40","Litter")
--#	call fgl_keysetlabel("f41","Detritus")
--#	call fgl_keysetlabel("f42","Graffiti")
--#	call fgl_keysetlabel("f43","Flyposting")
}
end function

function bv199_cf()
{
--#	call fgl_keysetlabel("f40","")
--#	call fgl_keysetlabel("f41","")
--#	call fgl_keysetlabel("f42","")
--#	call fgl_keysetlabel("f43","")
}
	close window iw_bv199
end function



FUNCTION view_bsp(vl_service_c, vl_code, vl_fault) 
    DEFINE
        vl_service_c        LIKE comp.service_c,
        vl_code             LIKE bsp_rules.item_ref,
        vl_fault            LIKE bsp_rules.fault_code,
        vlr_bsp_rules       RECORD LIKE bsp_rules.*,
        vl_mess             char(250)

    INITIALIZE vlr_bsp_rules.* TO null
    IF length(vl_code)
    AND length(vl_fault)
    THEN
        SELECT * INTO vlr_bsp_rules.* FROM bsp_rules
            WHERE service_c = vl_service_c
            AND item_ref = vl_code
            AND fault_code = vl_fault
    END IF
    IF NOT length(vlr_bsp_rules.url_text)
    THEN
        IF length(vl_code)
        THEN
            SELECT * INTO vlr_bsp_rules.* FROM bsp_rules
                WHERE service_c = vl_service_c
                AND item_ref = vl_code
                AND fault_code IS NULL
        END IF
    END IF 
    IF NOT length(vlr_bsp_rules.url_text)
    THEN
        SELECT * INTO vlr_bsp_rules.* FROM bsp_rules
            WHERE service_c = vl_service_c
            AND item_ref IS NULL 
            AND fault_code IS NULL
    END IF 
    IF NOT length(vlr_bsp_rules.url_text)
    THEN
        IF vl_service_c = vg_trade_service
        AND vg_trade_installation = "Y"
        THEN
            LET vl_mess = "No BSP Rules could be found for Service '", vl_service_c clipped,
                        "', Task '", vl_code clipped, "', Fault '", vl_fault clipped, "'"
        ELSE
            LET vl_mess = "No BSP Rules could be found for Service '", vl_service_c clipped,
                        "', Item '", vl_code clipped, "', Fault '", vl_fault clipped, "'"
        END IF 
        CALL valid_error("",vl_mess, "")
    ELSE
        IF vlr_bsp_rules.url_text MATCHES "*$$1*"
        THEN
            LET vlr_bsp_rules.url_text = replace_all_string(vlr_bsp_rules.url_text, "$$1", vl_service_c)
        END IF 
        IF vlr_bsp_rules.url_text MATCHES "*$$2*"
        THEN
            LET vlr_bsp_rules.url_text = replace_all_string(vlr_bsp_rules.url_text, "$$2", vl_code)
        END IF 
        IF vlr_bsp_rules.url_text MATCHES "*$$3*"
        THEN
            LET vlr_bsp_rules.url_text = replace_all_string(vlr_bsp_rules.url_text, "$$3", vl_fault)
        END IF 
        call ui.Interface.frontCall
				(
					"standard",
					"shellexec",
					[vlr_bsp_rules.url_text],
					[]
				)
    END IF 

END FUNCTION



function disp_complaint_history_text()
	define
		vl_rec_count	smallint

	if check_history_system_key(vr_comp.service_c)
	then
		select count(*)
			into vl_rec_count
		from history_txt
			where func = "CT"
			and reference = vr_comp.complaint_no

		if vl_rec_count
		then
			display "Y" to history_txt_flag attribute(yellow, reverse)
		else
			display "N" to history_txt_flag
		end if
	else
		display "N" to history_txt_flag
	end if
end function


function disp_evidence_flag()
	define
		vl_rec_count	smallint

	select count(*)
		into vl_rec_count
	from evidence_text
		where complaint_no = vr_comp.complaint_no

	if vl_rec_count
	then
		display "Y" to evidence_flag
	else
		display "N" to evidence_flag
	end if
end function


function adhoc_sample_info()
	define
		vl_old_next_date	date,
		vl_runstr			char(100),
		vl_msg				char(100)

	let vl_old_next_date = vr_comp_adhoc_sample.next_date

	open window iw_adhoc_sample_info at 8, 28 with form "comp_adhoc_sample" 

#	display "INSPECTION INFORMATION" at 1, 2 

	display by name vr_comp_adhoc_sample.next_date, 
					vr_comp_adhoc_sample.end_date

	input by name vr_comp_adhoc_sample.start_date,
					vr_comp_adhoc_sample.duration_days,
					vr_comp_adhoc_sample.occur_days without defaults

		on action cancel
			let int_flag = true
			exit input

		on action close
			let int_flag = true
			exit input

		after field start_date
			call calc_adhoc_dates()

		after field duration_days
			call calc_adhoc_dates()

		after field occur_days
			if check_occ_day(vr_comp_adhoc_sample.occur_days)
			then
				call calc_adhoc_dates()
			else
				call valid_error("", 
					"A valid occur day pattern must be entered", "")
				let vr_comp_adhoc_sample.next_date = null
				let vr_comp_adhoc_sample.end_date = null
				display by name vr_comp_adhoc_sample.next_date, 
								vr_comp_adhoc_sample.end_date
				next field occur_days
			end if	

		after input
			if not vr_comp_adhoc_sample.start_date
			then
				call valid_error("",
					"A valid start date must be entered", "")
				next field start_date
			end if
			if not vr_comp_adhoc_sample.duration_days
			or vr_comp_adhoc_sample.duration_days is null
			then
				if not vr_comp.complaint_no 
				or vr_comp.complaint_no is null
				then
					call valid_error("",
						"A valid duration must be entered", "")
					next field duration_days
				else
					let vl_msg = "Are you sure you wish to close the ",
						vg_record_title clipped
					if continue_yn(vl_msg) then
						call get_time()
							returning vr_comp.time_closed_h,
							vr_comp.time_closed_m
						let vr_comp.date_closed = today
						update comp
							set date_closed = vr_comp.date_closed,
							time_closed_h = vr_comp.time_closed_h,
							time_closed_m = vr_comp.time_closed_m
							where complaint_no = 
								vr_comp_adhoc_sample.complaint_no
						call notify_customer(vr_comp.complaint_no, "", "", "")

						if vg_crm_enhanced = "Y"
						then
							call pop_ci_export_variables(vr_comp.complaint_no)
							let vr_crm_import_export.transaction_type = "C"
							call unload_crm_export_file(vr_crm_import_export.*)
						end if

						call ws_ext_integration(vr_comp.complaint_no,"", "", "")
					else
						next field duration_days
					end if
				end if
			end if
			if not vr_comp_adhoc_sample.occur_days
			then
				call valid_error("",
					"A valid occur day pattern must be entered", "")
				next field occur_days
			end if
			
	end input

	if int_flag 
	then
		let int_flag = false
		close window iw_adhoc_sample_info
		return false	
	end if

	if vr_comp.complaint_no
	then
		update comp_adhoc_sample set * = vr_comp_adhoc_sample.*
			where complaint_no = vr_comp.complaint_no
		if vr_comp_adhoc_sample.next_date = today
		and vl_old_next_date != vr_comp_adhoc_sample.next_date
		then
			let vl_runstr = "exec fglgo_adhoc_insp ", vr_comp.complaint_no
			call os_exec(vl_runstr, true)
		end if
	end if		
	close window iw_adhoc_sample_info

	return true

end function


function calc_adhoc_dates()
	define
		vl_loop			smallint

	if vr_comp_adhoc_sample.start_date
	and vr_comp_adhoc_sample.duration_days
	and vr_comp_adhoc_sample.occur_days
	then
		if vr_comp_adhoc_sample.start_date < today
		then
			let vr_comp_adhoc_sample.start_date = today
		end if

		let vr_comp_adhoc_sample.next_date =
			get_next_occur_date(vr_comp_adhoc_sample.occur_days,
								vr_comp_adhoc_sample.start_date)
 
		if vr_comp_adhoc_sample.start_date != vr_comp_adhoc_sample.next_date
		then
			call valid_error("",
		"The start date has been adjusted to match the occur day pattern", "")
			let vr_comp_adhoc_sample.start_date = vr_comp_adhoc_sample.next_date
		end if
		if vr_comp_adhoc_sample.duration_days = 1
		then
			let vr_comp_adhoc_sample.next_date =
				vr_comp_adhoc_sample.start_date
			let vr_comp_adhoc_sample.end_date =
				vr_comp_adhoc_sample.start_date
		else
			let vr_comp_adhoc_sample.next_date =
				vr_comp_adhoc_sample.start_date
			let vr_comp_adhoc_sample.end_date =
				vr_comp_adhoc_sample.start_date
			for vl_loop = 1 to (vr_comp_adhoc_sample.duration_days - 1)
				let vr_comp_adhoc_sample.end_date =
					vr_comp_adhoc_sample.end_date + 1
				let vr_comp_adhoc_sample.end_date =
					get_next_occur_date(vr_comp_adhoc_sample.occur_days,
										vr_comp_adhoc_sample.end_date)

			end for
		end if
	else
		let vr_comp_adhoc_sample.next_date = null
		let vr_comp_adhoc_sample.end_date = null
	end if
	display by name vr_comp_adhoc_sample.start_date
	display by name vr_comp_adhoc_sample.next_date, 
					vr_comp_adhoc_sample.end_date
end function


function monitor_info()
	define
		vl_old_next_date	date,
		vl_runstr			char(100),
		vl_msg				char(100)

	let vl_old_next_date = vr_comp_monitor.next_date

	open window iw_monitor_info with form "comp_monitor" 

#	display "MONITOR INFORMATION" at 1, 2 

	display by name vr_comp_monitor.next_date, 
					vr_comp_monitor.end_date

	input by name vr_comp_monitor.start_date,
					vr_comp_monitor.duration_days,
					vr_comp_monitor.occur_days without defaults

		on action cancel
			let int_flag = true
			exit input

		on action close
			let int_flag = true
			exit input

		after field start_date
			call calc_monitor_dates()

		after field duration_days
			call calc_monitor_dates()

		after field occur_days
			if check_occ_day(vr_comp_monitor.occur_days)
			then
				call calc_monitor_dates()
			else
				call valid_error("", 
					"A valid occur day pattern must be entered", "")
				let vr_comp_monitor.next_date = null
				let vr_comp_monitor.end_date = null
				display by name vr_comp_monitor.next_date, 
								vr_comp_monitor.end_date
				next field occur_days
			end if	

		after input
			if not vr_comp_monitor.start_date
			then
				call valid_error("",
					"A valid start date must be entered", "")
				next field start_date
			end if
			if not vr_comp_monitor.duration_days
			or vr_comp_monitor.duration_days is null
			then
				if not vr_comp.complaint_no 
				or vr_comp.complaint_no is null
				then
					call valid_error("",
						"A valid duration must be entered", "")
					next field duration_days
				else
					let vl_msg = "Are you sure you wish to close the ",
						vg_record_title clipped
					if continue_yn(vl_msg) then
						call get_time()
							returning vr_comp.time_closed_h,
							vr_comp.time_closed_m
						let vr_comp.date_closed = today
					else
						next field duration_days
					end if
				end if
			end if
			if not vr_comp_monitor.occur_days
			then
				call valid_error("",
					"A valid occur day pattern must be entered", "")
				next field occur_days
			end if
			
	end input

	if int_flag 
	then
		let int_flag = false
		close window iw_monitor_info
		return false	
	end if

	if vr_comp.complaint_no
	then
		update comp_monitor set * = vr_comp_monitor.*
			where complaint_no = vr_comp.complaint_no
		if vr_comp_monitor.next_date = today
		and vl_old_next_date != vr_comp_monitor.next_date
		then
			let vl_runstr = "exec fglgo_monitor_insp ", vr_comp.complaint_no
			call os_exec(vl_runstr, false)
		end if
	end if		
	close window iw_monitor_info

	return true

end function


function calc_monitor_dates()
	define
		vl_loop			smallint

	if vr_comp_monitor.start_date
	and vr_comp_monitor.duration_days
	and vr_comp_monitor.occur_days
	then
		if vr_comp_monitor.start_date < today
		then
			let vr_comp_monitor.start_date = today
		end if

		let vr_comp_monitor.next_date =
			get_next_occur_date(vr_comp_monitor.occur_days,
								vr_comp_monitor.start_date)
 
		if vr_comp_monitor.start_date != vr_comp_monitor.next_date
		then
			call valid_error("",
		"The start date has been adjusted to match the occur day pattern", "")
			let vr_comp_monitor.start_date = vr_comp_monitor.next_date
		end if
		if vr_comp_monitor.duration_days = 1
		then
			let vr_comp_monitor.next_date =
				vr_comp_monitor.start_date
			let vr_comp_monitor.end_date =
				vr_comp_monitor.start_date
		else
			let vr_comp_monitor.next_date =
				vr_comp_monitor.start_date
			let vr_comp_monitor.end_date =
				vr_comp_monitor.start_date
			for vl_loop = 1 to (vr_comp_monitor.duration_days - 1)
				let vr_comp_monitor.end_date =
					vr_comp_monitor.end_date + 1
				let vr_comp_monitor.end_date =
					get_next_occur_date(vr_comp_monitor.occur_days,
										vr_comp_monitor.end_date)
			end for
		end if
	else
		let vr_comp_monitor.next_date = null
		let vr_comp_monitor.end_date = null
	end if
	display by name vr_comp_monitor.start_date
	display by name vr_comp_monitor.next_date, vr_comp_monitor.end_date
end function


function insert_multi_monitor_records(vl_diry_ref)
	define	
		vlr_comp_ert_dtl_log	record like comp_ert_dtl_log.*,
		vlr_comp_dart_dtl_log	record like comp_dart_dtl_log.*,
		vl_diry_ref				like diry.diry_ref,
		vl_complaint_no			like comp.complaint_no,
		vl_start_comp			like comp.complaint_no,
		vl_end_comp				like comp.complaint_no,
		vl_runstr			    char(255),
		vl_mess					char(100),
		vl_count				integer,
		vl_first				smallint,
		vl_loop					smallint,
		vl_next_date			like comp_monitor.next_date # BJG 01/03/2007

	whenever error continue
	drop table mm_comp_01 # BJG 01/03/2007
	create temp table mm_comp_01
	(
	complaint_no integer
	)
	whenever error stop

	# Get the different site references ...

	let vl_first = true

	for vl_loop = 1 to va_site_select.getLength()
		if va_site_select[vl_loop].select_yn = "Y"
		and length(va_site_select[vl_loop].site_ref)
		then
			# Populate the site/location
			call find_and_display_property
				(va_site_select[vl_loop].site_ref, true)

			if vl_diry_ref
			then
				update diry set site_ref = va_site_select[vl_loop].site_ref
				where diry_ref = vl_diry_ref
				let vr_diry.site_ref = va_site_select[vl_loop].site_ref
			else
				let vr_comp.complaint_no = 0
				let vl_diry_ref = insert_comp_diry()
			end if

			let vr_comp.complaint_no = get_next_s_no("COMP", "")

			if vl_first
			then
				let vl_start_comp = vr_comp.complaint_no
				let vl_first = false
			end if

			while true
				insert into comp values (vr_comp.*)
                if vr_comp.service_c = vg_sched_service then
                    update comp
                        set pa_area = null,
                            round_c = null
                        where complaint_no = vr_comp.complaint_no
                end if

				if errtst()
				then
					insert into mm_comp_01 values(vr_comp.complaint_no)
					exit while
				else
					select max(complaint_no) into vr_comp.complaint_no
						from comp
					if status = notfound
					then
						let vr_comp.complaint_no = 1
					else
						let vr_comp.complaint_no = vr_comp.complaint_no + 2
						update s_no set serial_no = vr_comp.complaint_no
							where sn_func = "COMP"
						let vr_comp.complaint_no = vr_comp.complaint_no - 1
					end if
				end if
			end while

			insert into comp_destination
				values (vr_comp.complaint_no, 
						vr_comp_destination.destination,
						vr_comp_destination.destination_date)

			# ADJ - CRM
			call insert_comp_customer()

			#ADJBJG Enforce
			if vg_enforce_added
			then
				call update_comp_enf_source_ref(vl_diry_ref)
				let vg_enforce_added = false
			end if

			#BJG Flycapture
			if vg_new_flycomp = true
			then
				let vg_new_flycomp = 2
				call update_flycap_tables(true)
			end if

			if vg_dart_installation = "Y"
			and vg_dart_service = vr_comp.service_c
			then
				let vr_comp_dart_header.complaint_no = vr_comp.complaint_no
				insert into comp_dart_header values(vr_comp_dart_header.*)
				insert into comp_dart_hdr_log values(vr_comp_dart_header.*,
													1,
													vr_comp.entered_by,
													vr_comp.date_entered,
													vr_comp.ent_time_h,
													vr_comp.ent_time_m)

				let vlr_comp_dart_dtl_log.log_username = get_user()
				let vlr_comp_dart_dtl_log.log_username = 
					upshift(vlr_comp_dart_dtl_log.log_username)
				let vlr_comp_dart_dtl_log.log_date = today
				call get_time()
					returning vlr_comp_dart_dtl_log.log_time_h,
								vlr_comp_dart_dtl_log.log_time_m

				let vl_count = 1
				for vl_loop = 1 to 100
					if va_cmp_dart_dtl[vl_loop].dart_result = "Y"
					then
						insert into comp_dart_detail values
								(vr_comp.complaint_no,
								va_cmp_dart_dtl_func[vl_loop].dart_lookup_func,
								va_cmp_dart_dtl[vl_loop].dart_lookup_code)
						insert into comp_dart_dtl_log values
								(vr_comp.complaint_no,
								va_cmp_dart_dtl_func[vl_loop].dart_lookup_func,
								va_cmp_dart_dtl[vl_loop].dart_lookup_code,
								vl_count,
								vlr_comp_dart_dtl_log.log_username,
								vlr_comp_dart_dtl_log.log_date,
								vlr_comp_dart_dtl_log.log_time_h,
								vlr_comp_dart_dtl_log.log_time_m)
						let vl_count = vl_count + 1
					end if
				end for
			end if

			if vg_ert_installation = "Y"
			and vg_ert_detailed_info = "Y"
			and vg_ert_service = vr_comp.service_c
			then
				let vr_comp_ert_header.complaint_no = vr_comp.complaint_no
				insert into comp_ert_header values(vr_comp_ert_header.*)
				let vr_comp_ert_tags.complaint_no = vr_comp.complaint_no
				let vr_comp_ert_tags.seq_no = 1
				let vr_comp_ert_tags.username = get_user()
				let vr_comp_ert_tags.doa = date
				let vr_comp_ert_tags.details = null
				insert into comp_ert_tags values(vr_comp_ert_tags.*)
				insert into comp_ert_tags_log values(vr_comp_ert_tags.*,
													1,
													vr_comp.entered_by,
													vr_comp.date_entered,
													vr_comp.ent_time_h,
													vr_comp.ent_time_m)
				insert into comp_ert_hdr_log values(vr_comp_ert_header.*,
													1,
													vr_comp.entered_by,
													vr_comp.date_entered,
													vr_comp.ent_time_h,
													vr_comp.ent_time_m)

				let vlr_comp_ert_dtl_log.log_username = get_user()
				let vlr_comp_ert_dtl_log.log_username = 
					upshift(vlr_comp_ert_dtl_log.log_username)
				let vlr_comp_ert_dtl_log.log_date = today
				call get_time()
					returning vlr_comp_ert_dtl_log.log_time_h,
								vlr_comp_ert_dtl_log.log_time_m

				let vl_count = 1
				for vl_loop = 1 to 100
					if va_comp_ert_detail[vl_loop].ert_result = "Y"
					then
						insert into comp_ert_detail values(vr_comp.complaint_no,
							va_comp_ert_detail_func[vl_loop].ert_lookup_func,
							va_comp_ert_detail[vl_loop].ert_lookup_code)
						insert into comp_ert_dtl_log values
							(vr_comp.complaint_no,
							va_comp_ert_detail_func[vl_loop].ert_lookup_func,
							va_comp_ert_detail[vl_loop].ert_lookup_code,
							vl_count,
							vlr_comp_ert_dtl_log.log_username,
							vlr_comp_ert_dtl_log.log_date,
							vlr_comp_ert_dtl_log.log_time_h,
							vlr_comp_ert_dtl_log.log_time_m)
						let vl_count = vl_count + 1
					end if
				end for
			end if
			if vg_sw_installation = "Y"
			and vg_sw_service = vr_comp.service_c
			then
				#ADJ SWTODO
				#insert into the relevant tables!
				select count(*)
					into vl_count
				from warden_item
					where warden_item_type in ("V", "L", "P", "C")
					and item_ref = vr_comp.item_ref
					and contract_ref = vr_si_i.contract_ref
				if vl_count
				then
					let vr_comp_warden.complaint_no = vr_comp.complaint_no
					insert into comp_warden values(vr_comp_warden.*)
				end if

				select count(*)
					into vl_count
				from warden_item
					where warden_item_type in ("I", "R")
					and item_ref = vr_comp.item_ref
					and contract_ref = vr_si_i.contract_ref

				if vl_count 
				then
					if not length(vr_client.client_ref)
					and (length(vr_client.client_name)
					or length(vr_client.client_surname)
					or length(vr_client.client_a_name)
					or length(vr_client.client_a_surname))
					then
						let vr_client.asbo_yn = "N"
						let vr_client.validated_yn = "N"
						let vr_client.referral_yn = vr_incident.referral_yn
						let vr_client.client_ref = get_next_s_no("client", "")
						insert into client values(vr_client.*)
					end if

					if vr_client.client_ref
					then
						insert into comp_client values(vr_comp.complaint_no,
														vr_client.client_ref)
						for vl_loop = 1 to vg_client_text_count
							if vl_loop = vg_client_text_count
							and not length(m_client_text[vl_loop].txt)
							then 
								exit for
							else
								insert into client_text values(
										vr_client.client_ref,
										#ADJ SERIALS
										vl_loop,
										m_client_text[vl_loop].username, 
										m_client_text[vl_loop].doa, 
										m_client_text[vl_loop].time_entered_h,
										m_client_text[vl_loop].time_entered_m,
										m_client_text[vl_loop].txt 
										)
							end if
						end for
					end if

					if length(vr_incident.incident_source)
					then
						if not length(vr_incident.confirmed_text)
						or vr_incident.confirmed_text is null
						then
							let vr_incident.confirmed_text = "N"
						end if
						if not length(vr_incident.referral_yn)
						or vr_incident.referral_yn is null
						then
							let vr_incident.referral_yn = "N"
						end if
						let vr_incident.incident_ref = 
							get_next_s_no("incident", "")
						let vr_incident.client_ref = vr_client.client_ref

						insert into incident values(vr_incident.*)

						for vl_loop = 1 to vg_incident_text_count
							if vl_loop = vg_incident_text_count
							and not length(m_incident_text[vl_loop].txt)
							then 
								exit for
							else
								insert into incident_text values(
										vr_incident.incident_ref,
										#ADJ SERIALS
										vl_loop,
										m_incident_text[vl_loop].username, 
										m_incident_text[vl_loop].doa, 
										m_incident_text[vl_loop].time_entered_h,
										m_incident_text[vl_loop].time_entered_m,
										m_incident_text[vl_loop].txt 
										)
							end if
						end for

						insert into comp_incident values(vr_comp.complaint_no,
													vr_incident.incident_ref)
					end if

					if length(vr_referral.activity_type)
					then
						let vr_referral.referral_ref = 
							get_next_s_no("referral", "")
						let vr_referral.incident_ref = vr_incident.incident_ref
						let vr_referral.client_ref = vr_client.client_ref
						insert into referral values(vr_referral.*)

						for vl_loop = 1 to vg_referral_text_count
							if vl_loop = vg_referral_text_count
							and not length(m_referral_text[vl_loop].txt)
							then 
								exit for
							else
								insert into referral_text values(
										vr_referral.referral_ref,
										#ADJ SERIALS
										vl_loop,
										m_referral_text[vl_loop].username, 
										m_referral_text[vl_loop].doa, 
										m_referral_text[vl_loop].time_entered_h,
										m_referral_text[vl_loop].time_entered_m,
										m_referral_text[vl_loop].txt 
										)
							end if
						end for

						insert into comp_referral values(vr_comp.complaint_no,
													vr_referral.referral_ref)
					end if
				end if
			end if

			if m_comp_arr_count > 0
			then
				for vl_count = 1 to m_comp_arr_count
					let m_comp_cust[vl_count] = vr_customer.customer_no
				end for
				let vr_comp.text_flag = "Y" 
				call write_to_comp_text(vr_comp.complaint_no)
			else
				let vr_comp.text_flag = "N"
			end if

			if vr_comp.action_flag = "N"
			then
				let vr_diry.action_flag = "C"
			else
				let vr_diry.action_flag = vr_comp.action_flag
			end if

			let vr_comp_monitor.complaint_no = 
				vr_comp.complaint_no
			insert into comp_monitor values(vr_comp_monitor.*)
			let vr_diry.date_due = vr_comp_monitor.next_date

			update diry
				set action_flag = vr_diry.action_flag,
					date_due = vr_diry.date_due,
					source_ref = vr_comp.complaint_no
				where diry_ref = vl_diry_ref

			if vg_crm_enhanced = "Y"
			then
				call pop_ci_export_variables(vr_comp.complaint_no)
				let vr_crm_import_export.transaction_type = "C"
				call unload_crm_export_file(vr_crm_import_export.*)
			end if

			call ws_ext_integration(vr_comp.complaint_no, "", "", "")

			call set_comp_options()
			let vl_diry_ref = null
		end if
	end for

	let vl_end_comp = vr_comp.complaint_no

	declare c_mm_comp_01 cursor for
		select * from mm_comp_01
		order by complaint_no

	foreach c_mm_comp_01 into vl_complaint_no
		call print_comp_notice(vl_complaint_no)
		select next_date into vl_next_date from comp_monitor # BJG 01/03/2006
			where complaint_no = vl_complaint_no # BJG 01/03/2006
#		if vr_comp_monitor.next_date = today # BJG 01/03/2006
		if vl_next_date = today
		then
			#create a sample NOW!
			let vl_runstr = "exec fglgo_monitor_insp ", 
				vl_complaint_no
			call os_exec(vl_runstr, false)
		end if
	end foreach
	
	let vl_mess = "The new ", downshift(vg_record_title) clipped,
		" record(s) have been saved."

	if vl_start_comp = vl_end_comp
	then
		let vl_mess = vl_mess clipped,
			"  The reference number is ", 
			vl_start_comp using "<<<<<<<<"
	else
		let vl_mess = vl_mess clipped,
			"\nThe reference numbers range ", 
			vl_start_comp using "<<<<<<<", 
			" to ", vl_end_comp using "<<<<<<<"
	end if

	call valid_error("Information", vl_mess, "I")
end function


function populate_action_combo(vl_mode, vl_actions, vl_combo)
	define
		vl_mode		char(1),
		vl_actions	char(20),
		vl_combo	string

#	current window is iw_complain # BJG 23/11/2010 # BJG 23/01/2012 This looks VERY DODGY so commented as adding related comps goes to wrong window, needs iw_complain_2
	let cb = ui.ComboBox.forName(vl_combo)

	call cb.clear()

#	ADJ DEBUG
#	display vl_combo clipped
#	display vl_mode
#	display vl_actions
	if vl_actions matches "*A*"
	then
		call cb.addItem("A", "A - Auto Rectification")
	end if
	if vl_actions matches "*D*"
	then
		call cb.addItem("D", "D - Rectification")
	end if
	if vl_actions matches "*E*"
	then
		call cb.addItem("E", "E - Enforcement")
	end if
	if vl_actions matches "*H*"
	then
		call cb.addItem("H", "H - Hold")
	end if
	if vl_actions matches "*I*"
	then
		call cb.addItem("I", "I - Inspection")
	end if
	if vl_actions matches "*P*"
	then
		call cb.addItem("P", "P - Pending")
	end if
	if vl_actions matches "*N*"
	then
		call cb.addItem("N", "N - No Further Action")
	end if
	if vl_actions matches "*R*"
	then
		call cb.addItem("R", "R - Request Agreement")
	end if
	if vl_actions matches "*W*"
	then
		call cb.addItem("W", "W - Works Order")
	end if
	if vl_actions matches "*X*"
	then
		call cb.addItem("X", "X - eXpress Works Order")
	end if

	{
	case 
		when vl_mode = "Q"
			if vl_actions matches "*D*"
			then
				call cb.addItem("D", "Rectification")
			end if
			if vl_actions matches "*E*"
			then
				#display "Enforcement"
				call cb.addItem("E", "Enforcement")
			end if
			if vl_actions matches "*H*"
			then
				call cb.addItem("H", "Hold")
			end if
			if vl_actions matches "*I*"
			then
				call cb.addItem("I", "Inspection")
			end if
			if vl_actions matches "*P*"
			then
				call cb.addItem("P", "Pending")
			end if
			if vl_actions matches "*N*"
			then
				call cb.addItem("N", "No Further Action")
			end if
			if vl_actions matches "*R*"
			then
				call cb.addItem("R", "Request Agreement")
			end if
			if vl_actions matches "*W*"
			then
				call cb.addItem("W", "Works Order")
			end if
		when vl_mode = "A"
			if vl_actions matches "*A*"
			then
				call cb.addItem("A", "A - Auto Rectification")
			end if
			if vl_actions matches "*D*"
			then
				call cb.addItem("D", "D - Rectification")
			end if
			if vl_actions matches "*E*"
			then
				call cb.addItem("E", "E - Enforcement")
			end if
			if vl_actions matches "*H*"
			then
				call cb.addItem("H", "H - Hold")
			end if
			if vl_actions matches "*I*"
			then
				call cb.addItem("I", "I - Inspection")
			end if
			if vl_actions matches "*P*"
			then
				call cb.addItem("P", "P - Pending")
			end if
			if vl_actions matches "*N*"
			then
				call cb.addItem("N", "N - No Further Action")
			end if
			if vl_actions matches "*R*"
			then
				call cb.addItem("R", "R - Request Agreement")
			end if
			if vl_actions matches "*W*"
			then
				call cb.addItem("W", "W - Works Order")
			end if
			if vl_actions matches "*X*"
			then
				call cb.addItem("X", "X - eXpress Works Order")
			end if
		when vl_mode = "U"
			if vl_actions matches "*A*"
			then
				call cb.addItem("A", "A - Auto Rectification")
			end if
			if vl_actions matches "*D*"
			then
				call cb.addItem("D", "D - Rectification")
			end if
			if vl_actions matches "*E*"
			then
				call cb.addItem("E", "E - Enforcement")
			end if
			if vl_actions matches "*H*"
			then
				call cb.addItem("H", "H - Hold")
			end if
			if vl_actions matches "*I*"
			then
				call cb.addItem("I", "I - Inspection")
			end if
			if vl_actions matches "*P*"
			then
				call cb.addItem("P", "P - Pending")
			end if
			if vl_actions matches "*N*"
			then
				call cb.addItem("N", "N - No Further Action")
			end if
			if vl_actions matches "*R*"
			then
				call cb.addItem("R", "R - Request Agreement")
			end if
			if vl_actions matches "*W*"
			then
				call cb.addItem("W", "W - Works Order")
			end if
			if vl_actions matches "*X*"
			then
				call cb.addItem("X", "X - eXpress Works Order")
			end if
	end case
	}
end function


function upd_date_due(vl_item_ref, vl_site_ref, vl_feature_ref, vl_contract_ref)

define vl_item_ref		like si_i.item_ref
define vl_site_ref		like si_i.site_ref
define vl_feature_ref	like si_i.feature_ref
define vl_contract_ref	like si_i.contract_ref
define vlr_si_i			record like si_i.*
define vl_week_day		integer
define vl_today			like si_i.prev_date

	select * into vlr_si_i.* from si_i
		where item_ref = vl_item_ref and
		site_ref = vl_site_ref and
		feature_ref = vl_feature_ref and
		contract_ref = vl_contract_ref

	call upd_date_due_of()

	input by name vlr_si_i.date_due without defaults

		after field date_due
			if not length(vlr_si_i.date_due) then
				call valid_error("", "You must enter a due date", "")
				next field date_due
			else
				if vlr_si_i.date_due < today then
					call valid_error("", "Date must be today or later", "")
					next field date_due
				end if
				if length(vlr_si_i.occur_day) then
					let vl_week_day = weekday(vlr_si_i.date_due)
					if vl_week_day = 0 then
						let vl_week_day = 7
					end if
					if vlr_si_i.occur_day[vl_week_day] = "X" then
						call valid_error
						(
							"",
							"This is not an occur day for this item",
							""
						)
						next field date_due
					end if
				end if
			end if

	end input

	if not int_flag then
		let vl_today = today
		update si_i set date_due = vlr_si_i.date_due, prev_date = vl_today
			where item_ref = vl_item_ref and
			site_ref = vl_site_ref and
			feature_ref = vl_feature_ref and
			contract_ref = vl_contract_ref
		call valid_error("", "The date due has been updated", "")
	else
		call valid_error("", "The date due has NOT been updated", "")
	end if

	call upd_date_due_cf()

end function

function upd_date_due_of()

   open window iw_date_due with form "upd_date_due"

end function

function upd_date_due_cf()

	close window iw_date_due

end function


function load_vm_comp_text()
	define
		vl_complaint_no		like comp.complaint_no,
		vl_query_text		char(200),
		vl_loop				smallint,
		vlr_comp_text		record like comp_text.*,
		vl_compl_init		like customer.compl_init,
		vl_compl_name		like customer.compl_name,
		vl_compl_surname	like customer.compl_surname

	call vm_comp_text.clear()
	call vm_disp_cust.clear()

	let vl_query_text = "select * from",
			" comp_text where complaint_no = ", vr_comp.complaint_no, 
			" order by seq"

	prepare ip_vm_comp_text from vl_query_text
	declare ic_vm_comp_text cursor for ip_vm_comp_text

	foreach ic_vm_comp_text into vlr_comp_text.*
		call vm_comp_text.appendelement()
		call vm_disp_cust.appendelement()
		let vm_comp_text[vm_comp_text.getLength()].username =
																vlr_comp_text.username
		let vm_comp_text[vm_comp_text.getLength()].doa =
																vlr_comp_text.doa
		let vm_comp_text[vm_comp_text.getLength()].txt =
																vlr_comp_text.txt
		if vlr_comp_text.customer_no
		then
			select compl_init, compl_name, compl_surname
				into vl_compl_init, vl_compl_name, vl_compl_surname
			from customer
				where customer_no = vlr_comp_text.customer_no

			if length(vl_compl_init)
			then
				let vm_disp_cust[vm_disp_cust.getLength()] = vl_compl_init clipped
				if length(vl_compl_name)
				then
					let vm_disp_cust[vm_disp_cust.getLength()] =
							vm_disp_cust[vm_disp_cust.getLength()] clipped, " ",
							vl_compl_name clipped, " ",
							vl_compl_surname clipped
				else
					let vm_disp_cust[vm_disp_cust.getLength()] =
							vm_disp_cust[vm_disp_cust.getLength()] clipped, " ",
							vl_compl_surname clipped
				end if
			else
				if length(vl_compl_name)
				then
					let vm_disp_cust[vm_disp_cust.getLength()] =
						vl_compl_name clipped, " ", vl_compl_surname clipped
				else
					let vm_disp_cust[vm_disp_cust.getLength()] =
																vl_compl_surname clipped
				end if
			end if
		end if
	end foreach

end function


function load_vm_attach()
	define
		vl_select			char(250),
		vl_i				integer,
		vl_attach 			record
			orig_file_name 		like attachments.orig_file_name,
			comment 			like attachments.comment,
			doa 				like attachments.doa,
			username 			like attachments.username
		end record,
		vl_attach_no 		like attachments.attach_no,
		m_count				smallint

	call vm_attach_no.clear()
	call vm_attach.clear()

	let vl_select = "select attachments.attach_no,",
		" attachments.orig_file_name, attachments.comment,",
		" attachments.doa, attachments.username ",
		" from attachments",
		" where attachments.source_no = ", 
		vr_comp.complaint_no using "<<<<<<<<&", 
		" and attachments.type = 'C'",
		" order by attach_no desc"

	prepare ip_attach_s1 from vl_select
	declare ic_attach_1 cursor for ip_attach_s1

	foreach ic_attach_1 into vl_attach_no, vl_attach.*
		call vm_attach_no.appendelement()
		let vm_attach_no[vm_attach_no.getLength()] = vl_attach_no

		call vm_attach.appendelement()
		let vm_attach[vm_attach.getLength()].orig_file_name = 
			vl_attach.orig_file_name
		let vm_attach[vm_attach.getLength()].comment = 
			vl_attach.comment
		let vm_attach[vm_attach.getLength()].doa = 
			vl_attach.doa
		let vm_attach[vm_attach.getLength()].username = 
			vl_attach.username

	end foreach

end function


function load_enf_action_array()
	define
		vlr_enf_action			record like enf_action.*,
		vl_count					integer

	call va_actions.clear()
	call va_actions_color.clear()

	initialize vlr_enf_action.* to null

	if (vr_comp.service_c = vg_enf_service
	and vg_enf_installation = "Y")
	or (vr_comp.service_c = vg_enf_trade_service
	and vg_enf_trade_installation = "Y")
	then
		declare c_load_enfact cursor for
			select * from enf_action
				where complaint_no = vr_comp.complaint_no
				order by action_seq

		foreach c_load_enfact into vlr_enf_action.*
			call va_actions.appendelement()
			call va_actions_color.appendelement()
			let va_actions[va_actions.getLength()].act_seq =
																	va_actions.getLength()
			let va_actions[va_actions.getLength()].action_ref =
																	vlr_enf_action.action_ref
			let va_actions[va_actions.getLength()].action_date =
																	vlr_enf_action.action_date
			if length(vlr_enf_action.action_time_h)
			or length(vlr_enf_action.action_time_m)
			then
				let va_actions[va_actions.getLength()].action_time =
															vlr_enf_action.action_time_h, ":",
															vlr_enf_action.action_time_m
			end if
			let va_actions[va_actions.getLength()].due_date =
																	vlr_enf_action.due_date
			let va_actions[va_actions.getLength()].paid_date =
																	vlr_enf_action.paid_date
			let va_actions[va_actions.getLength()].act_enf_status =
																	vlr_enf_action.enf_status
			let va_actions[va_actions.getLength()].aut_officer =
																	vlr_enf_action.aut_officer
			let va_actions[va_actions.getLength()].act_text_flag =
																	vlr_enf_action.text_flag
			let va_actions[va_actions.getLength()].plea =
																	vlr_enf_action.plea
			let va_actions[va_actions.getLength()].judgement =
																	vlr_enf_action.judgement
			let va_actions[va_actions.getLength()].penalty =
																	vlr_enf_action.penalty_ref
			let va_actions[va_actions.getLength()].costs =
																	vlr_enf_action.costs
			let va_actions[va_actions.getLength()].fine =
																	vlr_enf_action.fine
			let va_actions[va_actions.getLength()].suspect_ref =
																	vlr_enf_action.suspect_ref
			if length(vlr_enf_action.due_date)
			then
				if vlr_enf_action.due_date = today
				then
					let va_actions[va_actions.getLength()].days = "TODAY"
					let va_actions_color[va_actions_color.getLength()].days =
																				"yellow reverse"
					let va_actions_color[va_actions_color.getLength()].act_seq =
																				"yellow reverse"
				else
					let vl_count = today - vlr_enf_action.due_date
					if vl_count < 0
					then
						let va_actions[va_actions.getLength()].days = "-",
																		vl_count using "<<<&"
						let va_actions_color[va_actions_color.getLength()].days =
																				"green reverse"
						let va_actions_color[va_actions_color.getLength()].act_seq =
																				"green reverse"
					else
						let va_actions[va_actions.getLength()].days = "+",
																		vl_count using "<<<&"
						let va_actions_color[va_actions_color.getLength()].days =
																				"red reverse"
						let va_actions_color[va_actions_color.getLength()].act_seq =
																				"red reverse"
					end if
				end if
			end if
		end foreach
	end if
end function


function load_enf_costs_array()
	define
		vlr_enf_cost_trans	record like enf_cost_trans.*,
		vl_count					integer

	call va_costs.clear()

	initialize vlr_enf_cost_trans.* to null

	if (vr_comp.service_c = vg_enf_service
	and vg_enf_installation = "Y")
	or (vr_comp.service_c = vg_enf_trade_service
	and vg_enf_trade_installation = "Y")
	then
		declare c_load_enfcosts cursor for
			select * from enf_cost_trans
				where complaint_no = vr_comp.complaint_no
				order by sequence

		foreach c_load_enfcosts into vlr_enf_cost_trans.*
			call va_costs.appendelement()
			let va_costs[va_costs.getLength()].action_code =
																vlr_enf_cost_trans.action_code
			let va_costs[va_costs.getLength()].rate_code =
																vlr_enf_cost_trans.rate_code
			let va_costs[va_costs.getLength()].qty =
																vlr_enf_cost_trans.qty
			let va_costs[va_costs.getLength()].unit_price =
																vlr_enf_cost_trans.unit_price
			let va_costs[va_costs.getLength()].value =
																vlr_enf_cost_trans.value
			let va_costs[va_costs.getLength()].text =
																vlr_enf_cost_trans.text
			let va_costs[va_costs.getLength()].username =
																vlr_enf_cost_trans.username
			let va_costs[va_costs.getLength()].cost_date =
																vlr_enf_cost_trans.cost_date
		end foreach
		select sum(value) into vm_total_costs from enf_cost_trans
			where complaint_no = vr_comp.complaint_no
	end if
end function


function load_debtor_trade_site_arrays()
	define
		vlr_agreement			record like agreement.*

	call va_debtor.clear()
	call va_trade_site.clear()

	initialize vlr_agreement.* to null
	initialize vr_trade_site.* to null
	initialize vr_trade_site_h.* to null
	initialize vr_debtor.* to null
	initialize vr_debtor_h.* to null

	if vr_comp.service_c = vg_trade_service
	and vg_trade_installation = "Y"
	then
		if not vr_comp_trade.agreement_no
		then
			return
		end if

		select * into vlr_agreement.* from agreement
			where agreement_no = vr_comp_trade.agreement_no
		select * into vr_trade_site.* from trade_site
			where site_no = vlr_agreement.site_ref
		select * into vr_debtor.* from debtor
			where debtor_ref = vr_trade_site.debtor_ref

	else
		if not g_agreement_h.agreement_no
		and not g_agreement_h.live_agreement_no
		then
			return
		end if

		if not length(vr_comp_agreq.agreement_no_h)
		then
			if length(vr_comp_agreq.site_no)
			then
				select * into vr_trade_site.* from trade_site
					where site_no = vr_comp_agreq.site_no
				select * into vr_debtor.* from debtor
					where debtor_ref = vr_trade_site.debtor_ref
			end if
			if length(vr_comp_agreq.site_no_h)
			then
				select * into vr_trade_site_h.* from trade_site_h
					where site_no = vr_comp_agreq.site_no_h
				if length(vr_trade_site_h.live_debtor_ref)
				then
					select * into vr_debtor.* from debtor
						where debtor_ref = vr_trade_site_h.live_debtor_ref
				else
					if length(vr_trade_site_h.live_debtor_ref)
					then
						select * into vr_debtor_h.* from debtor_h
							where debtor_ref = vr_trade_site_h.debtor_ref
					end if
				end if
			end if
		else
			if length(g_agreement_h.live_agreement_no)
			then
				select * into vlr_agreement.* from agreement
					where agreement_no = g_agreement_h.live_agreement_no
				if length(vlr_agreement.site_ref)
				then
					select * into vr_trade_site.* from trade_site
						where site_no = vlr_agreement.site_ref
					select * into vr_debtor.* from debtor
						where debtor_ref = vr_trade_site.debtor_ref
				end if
			else
				if length(g_agreement_h.live_site_ref)
				then
					select * into vr_trade_site.* from trade_site
						where site_no = g_agreement_h.live_site_ref
					select * into vr_debtor.* from debtor
						where debtor_ref = vr_trade_site.debtor_ref
				else
					select * into vr_trade_site_h.* from trade_site_h
						where site_no = g_agreement_h.site_ref
					if length(vr_trade_site_h.live_debtor_ref)
					then
						select * into vr_debtor.* from debtor
							where debtor_ref = vr_trade_site_h.live_debtor_ref
					else
						if length(vr_trade_site_h.debtor_ref)
						then
							select * into vr_debtor_h.* from debtor_h
								where debtor_ref = vr_trade_site_h.debtor_ref
						end if
					end if
				end if
			end if
		end if
	end if
	
	if length(vr_debtor.debtor_ref)
	and vr_debtor.debtor_ref > 0
	then
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Debtor"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.debtor_ref
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Account"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.account_ref
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Charity"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.charity_no
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Name"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.debtor_name
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Trading"
		let va_debtor[va_debtor.getLength()].column_value =
																	vr_debtor.debtor_name2
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Building"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.building
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Property"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.addr_num
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = ""
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.addr_1
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Road"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.addr_2
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Location"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.addr_3
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Area"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.addr_4 

		if vg_disp_townname_on_screen = "Y"
		then
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Town"
			let va_debtor[va_debtor.getLength()].column_value = vr_debtor.addr_5

			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "County"
			let va_debtor[va_debtor.getLength()].column_value = vr_debtor.addr_6

			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Post Town"
			let va_debtor[va_debtor.getLength()].column_value = vr_debtor.addr_7
		end if

		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Postcode"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.postcode 

		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Telephone"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.telephone
		call va_debtor.appendelement()

		let va_debtor[va_debtor.getLength()].column_name = "Fax"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.fax_num
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Contact Name"
		let va_debtor[va_debtor.getLength()].column_value = 
			vr_debtor.contact_name
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Contact Title"
		let va_debtor[va_debtor.getLength()].column_value = 
			vr_debtor.contact_title
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Contact Tel"
		let va_debtor[va_debtor.getLength()].column_value =vr_debtor.contact_tel
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Contact Fax"
		let va_debtor[va_debtor.getLength()].column_value = 
			vr_debtor.contact_fax 
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Contact Email"
		let va_debtor[va_debtor.getLength()].column_value = 
			vr_debtor.contact_email
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Co. Status"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.co_status
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Co. Reg"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.co_reg
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Vat Reg"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.vat_reg
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Start Date"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.start_date
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Review Date"
		let va_debtor[va_debtor.getLength()].column_value = 
			vr_debtor.review_date
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Close Date"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.close_date
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Status"
		let va_debtor[va_debtor.getLength()].column_value = vr_debtor.status_ref
		call va_debtor.appendelement()
		let va_debtor[va_debtor.getLength()].column_name = "Progress"
		let va_debtor[va_debtor.getLength()].column_value = "LIVE"
	else
		if length(vr_debtor_h.debtor_ref)
		and vr_debtor_h.debtor_ref > 0
		then
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Debtor"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.debtor_ref
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Account"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.account_ref
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Charity"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.charity_no
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Name"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.debtor_name
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Trading"
			let va_debtor[va_debtor.getLength()].column_value = 
				vr_debtor_h.debtor_name2
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Building"
			let va_debtor[va_debtor.getLength()].column_value = 
				vr_debtor_h.building
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Property"
			let va_debtor[va_debtor.getLength()].column_value = 
				vr_debtor_h.addr_num
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = ""
			let va_debtor[va_debtor.getLength()].column_value = 
				vr_debtor_h.addr_1
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Road"
			let va_debtor[va_debtor.getLength()].column_value = 
				vr_debtor_h.addr_2
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Location"
			let va_debtor[va_debtor.getLength()].column_value = 
				vr_debtor_h.addr_3
			if vg_disp_townname_on_screen = "Y"
			then
				call va_debtor.appendelement()
				let va_debtor[va_debtor.getLength()].column_name = "Town"
				let va_debtor[va_debtor.getLength()].column_value = 
					vr_debtor_h.addr_5
				call va_debtor.appendelement()
				let va_debtor[va_debtor.getLength()].column_name = "County"
				let va_debtor[va_debtor.getLength()].column_value = 
					vr_debtor_h.addr_6
				call va_debtor.appendelement()
				let va_debtor[va_debtor.getLength()].column_name = "Post Town"
				let va_debtor[va_debtor.getLength()].column_value = 
					vr_debtor_h.addr_7
			end if
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Area"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.addr_4 
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Postcode"
			let va_debtor[va_debtor.getLength()].column_value = 
				vr_debtor_h.postcode 
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Telephone"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.telephone
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Fax"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.fax_num
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Contact Name"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.contact_name
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Contact Title"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.contact_title
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Contact Tel"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.contact_tel
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Contact Fax"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.contact_fax 
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Contact Email"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.contact_email
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Co. Status"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.co_status
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Co. Reg"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.co_reg
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Vat Reg"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.vat_reg
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Start Date"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.start_date
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Review Date"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.review_date
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Close Date"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.close_date
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Status"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.status_ref
			call va_debtor.appendelement()
			let va_debtor[va_debtor.getLength()].column_name = "Progress"
			let va_debtor[va_debtor.getLength()].column_value =
				vr_debtor_h.import_status
			if length(vr_debtor_h.import_status)
			then
				if vr_debtor_h.import_status = "D"
				then
					let va_debtor[va_debtor.getLength()].column_value = "DISCARDED"
				else
					if vr_debtor_h.import_status = "L"
					then
						let va_debtor[va_debtor.getLength()].column_value = "LIVE"
					else
						let va_debtor[va_debtor.getLength()].column_value = "WAITING"
					end if
				end if
			else
				let va_debtor[va_debtor.getLength()].column_value = "WAITING"
			end if
		end if
	end if

	if length(vr_trade_site.site_no)
	and vr_trade_site.site_no > 0
	then
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Site"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.site_no
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Business"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.bus_category
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Name"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.site_name
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Trading"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.ta_name
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Building"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.building
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Property"
		let va_trade_site[va_trade_site.getLength()].trst_column_value =
			vr_trade_site.addr_num
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = ""
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.addr_1
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Road"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.addr_2
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Location"
		let va_trade_site[va_trade_site.getLength()].trst_column_value =
			vr_trade_site.addr_3

		if vg_disp_townname_on_screen = "Y"
		then
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Town"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site.addr_5 

			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"County"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site.addr_6
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Post Town"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site.addr_7
		end if
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name =
			"Area"
		let va_trade_site[va_trade_site.getLength()].trst_column_value =
			vr_trade_site.addr_4 
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Postcode"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.postcode 
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Telephone"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.telephone
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Fax"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.fax_num
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Contact Name"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.contact_name
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Contact Title"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.contact_title
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Contact Tel"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.contact_tel
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Contact Fax"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.contact_fax 
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Start Date"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.start_date
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name =
			"Close Date"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.close_date
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name = 
			"Status"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			vr_trade_site.status_ref
		call va_trade_site.appendelement()
		let va_trade_site[va_trade_site.getLength()].trst_column_name =
			"Progress"
		let va_trade_site[va_trade_site.getLength()].trst_column_value = 
			"LIVE"
	else
		if length(vr_trade_site_h.site_no)
		and vr_trade_site_h.site_no > 0
		then
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name = 
				"Site"
			let va_trade_site[va_trade_site.getLength()].trst_column_value = 
				vr_trade_site_h.site_no
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name = 
				"Business"
			let va_trade_site[va_trade_site.getLength()].trst_column_value = 
				vr_trade_site_h.bus_category
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name = 
				"Name"
			let va_trade_site[va_trade_site.getLength()].trst_column_value = 
				vr_trade_site_h.site_name
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name = 
				"Trading"
			let va_trade_site[va_trade_site.getLength()].trst_column_value = 
				vr_trade_site_h.ta_name
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name = 
				"Building"
			let va_trade_site[va_trade_site.getLength()].trst_column_value = 
				vr_trade_site_h.building
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name = 
				"Property"
			let va_trade_site[va_trade_site.getLength()].trst_column_value = 
				vr_trade_site_h.addr_num
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name = 
				""
			let va_trade_site[va_trade_site.getLength()].trst_column_value = 
				vr_trade_site_h.addr_1
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name = 
				"Road"
			let va_trade_site[va_trade_site.getLength()].trst_column_value = 	
				vr_trade_site_h.addr_2
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Location"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.addr_3
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Area"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.addr_4 
			if vg_disp_townname_on_screen = "Y"
			then
				call va_trade_site.appendelement()
				let va_trade_site[va_trade_site.getLength()].trst_column_name =
					"Town"
				let va_trade_site[va_trade_site.getLength()].trst_column_value =
					vr_trade_site_h.addr_5 

				call va_trade_site.appendelement()
				let va_trade_site[va_trade_site.getLength()].trst_column_name =
					"County"
				let va_trade_site[va_trade_site.getLength()].trst_column_value =
					vr_trade_site_h.addr_6
				call va_trade_site.appendelement()
				
				let va_trade_site[va_trade_site.getLength()].trst_column_name =
					"Post Town"
				let va_trade_site[va_trade_site.getLength()].trst_column_value =
					vr_trade_site_h.addr_7
			end if
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Postcode"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.postcode 
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Telephone"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.telephone
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Fax"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.fax_num
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Contact Name"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.contact_name
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Contact Title"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.contact_title
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Contact Tel"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.contact_tel
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Contact Fax"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.contact_fax 
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Start Date"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.start_date
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Close Date"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.close_date
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Status"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.status_ref
			call va_trade_site.appendelement()
			let va_trade_site[va_trade_site.getLength()].trst_column_name =
				"Progress"
			let va_trade_site[va_trade_site.getLength()].trst_column_value =
				vr_trade_site_h.import_status
			if length(vr_debtor_h.import_status)
			then
				if vr_trade_site_h.import_status = "D"
				then
					let va_trade_site[va_trade_site.getLength()].trst_column_value = "DISCARDED"
				else
					if vr_trade_site_h.import_status = "L"
					then
						let va_trade_site[va_trade_site.getLength()].trst_column_value
																					= "LIVE"
					else
						let va_trade_site[va_trade_site.getLength()].trst_column_value
																					= "WAITING"
					end if
				end if
			else
				let va_trade_site[va_trade_site.getLength()].trst_column_value =
					"WAITING"
			end if
		end if
	end if
end function



function load_suspect_array()
	define
		vlr_comp_enf				record like comp_enf.*,
		vlr_enf_suspect			record like enf_suspect.*,
		vlr_enf_company			record like enf_company.*

	call va_suspect.clear()

	initialize vlr_enf_suspect.* to null
	initialize vlr_enf_company.* to null

	if (vr_comp.service_c = vg_enf_service
	and vg_enf_installation = "Y")
	or (vr_comp.service_c = vg_enf_trade_service
	and vg_enf_trade_installation = "Y")
	then
		select * into vlr_comp_enf.* from comp_enf 
			where complaint_no = vr_comp.complaint_no
		if not length(vlr_comp_enf.suspect_ref)
		then
			return
		end if

		select * into vlr_enf_suspect.* from enf_suspect
			where suspect_ref = vlr_comp_enf.suspect_ref
		select * into vlr_enf_company.* from enf_company
			where company_ref = vlr_enf_suspect.company_ref
	else
		return
	end if
	
	if length(vlr_enf_suspect.company_ref)
	and vlr_enf_suspect.company_ref > 0
	then
		call va_suspect.appendelement()
		let va_suspect[va_suspect.getLength()].susp_column_name = "Company"
		let va_suspect[va_suspect.getLength()].susp_column_value =
																	vlr_enf_company.company_name
	end if
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Name"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.title clipped,
																" ",
																vlr_enf_suspect.fstname clipped,
																" ",
																vlr_enf_suspect.midname clipped,
																" ",
																vlr_enf_suspect.surname clipped
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Building"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.build_name
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Property"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.build_no
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = ""
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.addr1
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = ""
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.addr2
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = ""
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.addr3
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Postcode"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.postcode
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Home Telephone"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.home_phone
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Work Telephone"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.work_phone
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Mobile"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.mobile
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Email"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.email
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Est. Age"
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.est_age
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "D.O.B."
	let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.dob
	call va_suspect.appendelement()
	let va_suspect[va_suspect.getLength()].susp_column_name = "Gender"
#	let va_suspect[va_suspect.getLength()].susp_column_value =
#																vlr_enf_suspect.sex
	select lookup_text into
		va_suspect[va_suspect.getLength()].susp_column_value
		from allk
		where lookup_code = vlr_enf_suspect.sex
		and lookup_func = "GENDER"
	if status = notfound
	then
		let va_suspect[va_suspect.getLength()].susp_column_value =
																vlr_enf_suspect.sex
	end if
end function


function load_evidence_array()
	define
		vlr_evidence_text			record like evidence_text.*,
		vl_loop						integer

	call va_evidence.clear()

	initialize vlr_evidence_text.* to null

	if (vr_comp.service_c = vg_enf_service
	and vg_enf_installation = "Y")
	or (vr_comp.service_c = vg_enf_trade_service
	and vg_enf_trade_installation = "Y")
	then
		declare c_evidence cursor for
			select * from evidence_text
				where complaint_no =  vr_comp.complaint_no 
				order by seq

		foreach c_evidence into vlr_evidence_text.*
			call va_evidence.appendelement()
			let va_evidence[va_evidence.getlength()].username =
															vlr_evidence_text.username
			let va_evidence[va_evidence.getlength()].doa =
															vlr_evidence_text.doa
			let va_evidence[va_evidence.getlength()].txt =
															vlr_evidence_text.txt
		end foreach
	end if

end function



function load_action_text_array()
	define
		vlr_enf_act_text			record like enf_act_text.*,
		vl_loop						integer

	call va_action_text.clear()

	initialize vlr_enf_act_text.* to null

	if (vr_comp.service_c = vg_enf_service
	and vg_enf_installation = "Y")
	or (vr_comp.service_c = vg_enf_trade_service
	and vg_enf_trade_installation = "Y")
	then
		declare c_enf_act_text cursor for
			select * from enf_act_text
				where complaint_no =  vr_comp.complaint_no 
				order by action_seq, seq

		foreach c_enf_act_text into vlr_enf_act_text.*
			call va_action_text.appendelement()
			let va_action_text[va_action_text.getlength()].action_date =
				vlr_enf_act_text.action_date
			let va_action_text[va_action_text.getlength()].action_ref =
				vlr_enf_act_text.action_ref
			let va_action_text[va_action_text.getlength()].username =
				vlr_enf_act_text.username
			let va_action_text[va_action_text.getlength()].doa =
				vlr_enf_act_text.doa
			let va_action_text[va_action_text.getlength()].txt =
				vlr_enf_act_text.txt
		end foreach
	end if

end function



function set_actions_step(d)

define
	d							ui.Dialog,
	vl_enforcement_ref	like comp_enf.source_ref,
	vl_insp_item_flag		like item.insp_item_flag,
	vl_count					integer,
	vl_lookup_text			like keys.c_field,
	vl_wo_key				like wo_h.wo_key, 
	vl_wo_h_stat			like wo_h.wo_h_stat, 
	vl_wo_type_f			like wo_h.wo_type_f, 
	vl_contract_ref		like wo_h.contract_ref,
	vlr_wo_stat				record like wo_stat.*,
	vl_comp_code			char(10)

define w	ui.Window
define f	ui.Form

	let w = ui.Window.getCurrent()
	let f = w.getForm()

	call f.setElementHidden("trade_page",true) 
	call f.setElementHidden("import_page",true) 
	call f.setElementHidden("debtor_page",true) 
	call f.setElementHidden("trade_site_page",true) 
	call f.setElementHidden("actions_page",true)
	call f.setElementHidden("suspect_page",true)
	call f.setElementHidden("evidence_page",true)
	call f.setElementHidden("action_text_page",true)
	call f.setElementHidden("costs_page",true)
	call f.setElementHidden("status_page",true)

{ BJG 04/07/2012 - workflow 3348 - this should only take place if current_page is attachments
	if vr_comp.service_c = vg_enf_service
	and not quiet_allow("enf_comp_attachments")
	then
		call d.setActionActive("attachadd", false)
		call d.setActionHidden("attachadd", true)
		call d.setActionActive("attachdelete", false)
		call d.setActionHidden("attachdelete", true)
		call d.setActionActive("attachshow", false)
		call d.setActionHidden("attachshow", true)
	end if
}    
	call d.setActionActive("dest", false)
	call d.setActionHidden("dest", true)
	call d.setActionActive("related", false)
	call d.setActionHidden("related", true)
	call d.setActionActive("detail", false)
	call d.setActionHidden("detail", true)
	call d.setActionActive("detailup", false)
	call d.setActionHidden("detailup", true)
	call d.setActionActive("viewload", false)
	call d.setActionHidden("viewload", true)
	call d.setActionActive("clininfo", false)
	call d.setActionHidden("clininfo", true)
	call d.setActionActive("nappyinfo", false)
	call d.setActionHidden("nappyinfo", true)
	call d.setActionActive("treeinfo", false)
	call d.setActionHidden("treeinfo", true)
	call d.setActionActive("agmtshow", false)
	call d.setActionHidden("agmtshow", true)
	call d.setActionActive("trstshow", false)
	call d.setActionHidden("trstshow", true)
#	call d.setActionActive("trstshow2", false)
#	call d.setActionHidden("trstshow2", true)
	call d.setActionActive("dbtrshow", false)
	call d.setActionHidden("dbtrshow", true)
#	call d.setActionActive("dbtrshow2", false)
#	call d.setActionHidden("dbtrshow2", true)
	call d.setActionActive("inventory", false)
	call d.setActionHidden("inventory", true)
	call d.setActionActive("tags", false)
	call d.setActionHidden("tags", true)
	call d.setActionActive("flycapture", false)
	call d.setActionHidden("flycapture", true)
	call d.setActionActive("bv199", false)
	call d.setActionHidden("bv199", true)
	call d.setActionActive("officer", false)
	call d.setActionHidden("officer", true)
	call d.setActionActive("location", false)
	call d.setActionHidden("location", true)
	call d.setActionActive("avemailp", false)
	call d.setActionHidden("avemailp", true)
	call d.setActionActive("avemailf", false)
	call d.setActionHidden("avemailf", true)
	call d.setActionActive("avemailh", false)
	call d.setActionHidden("avemailh", true)
	call d.setActionActive("hpicheck", false)
	call d.setActionHidden("hpicheck", true)
	call d.setActionActive("enforcement", false)
	call d.setActionHidden("enforcement", true)
	call d.setActionActive("dhoinfo", false)
	call d.setActionHidden("dhoinfo", true)
	call d.setActionActive("dhoupdate", false)
	call d.setActionHidden("dhoupdate", true)
	call d.setActionActive("evidence", false)
	call d.setActionHidden("evidence", true)
	call d.setActionActive("addaction", false)
	call d.setActionHidden("addaction", true)
	call d.setActionActive("addcost", false)
	call d.setActionHidden("addcost", true)
	call d.setActionActive("suspect", false)
	call d.setActionHidden("suspect", true)
	call d.setActionActive("actions", false)
	call d.setActionHidden("actions", true)
	call d.setActionActive("costs", false)
	call d.setActionHidden("costs", true)
	call d.setActionActive("saleinfo", false)
	call d.setActionHidden("saleinfo", true)
	call d.setActionActive("worksched", false)
	call d.setActionHidden("worksched", true)
	call d.setActionActive("tandc", false)
	call d.setActionHidden("tandc", true)
	call d.setActionActive("tandcup", false)
	call d.setActionHidden("tandcup", true)
	call d.setActionActive("createload", false)
	call d.setActionHidden("createload", true)
	call d.setActionActive("addsale", false)
	call d.setActionHidden("addsale", true)
	call d.setActionActive("closesale", false)
	call d.setActionHidden("closesale", true)
#	call d.setActionActive("previous", false)
#	call d.setActionHidden("previous", true)
#	call d.setActionActive("next", false)
#	call d.setActionHidden("next", true)
	call d.setActionActive("update_header", true)
	call d.setActionHidden("update_header", false)
	call d.setActionActive("scheditems", false)
	call d.setActionHidden("scheditems", true)
	call d.setActionActive("replicate", false)
	call d.setActionHidden("replicate", true)
	call d.setActionActive("replicated", false)
	call d.setActionHidden("replicated", true)

	if skey_check("REPLICATE_SERVICE",vr_comp.service_c) = "Y"
	THEN
        SELECT site_status INTO vr_site.site_status FROM site
            WHERE site_ref = vr_comp.site_ref

        IF vr_site.site_status = "L"
        THEN
            # BJG 02/07/2012 - Workflow 3629 - disable replicate if site is now ended.
            call d.setActionActive("replicate", true)
            call d.setActionHidden("replicate", false)
        END IF 
	end if
	if vg_related_count
	then
		call d.setActionActive("replicated", true)
		call d.setActionHidden("replicated", false)
	end if

#	if not ((vr_comp.service_c = vg_enf_service
#	and vg_enf_installation = "Y")
#	or (vr_comp.service_c = vg_enf_trade_service
#	and vg_enf_trade_installation = "Y"))
{
	if (vr_comp.service_c != vg_enf_service
	and vg_enf_installation = "Y")
	or (vr_comp.service_c != vg_enf_trade_service
	and vg_enf_trade_installation = "Y")
}
# BJG - 16/04/2009
	if (vr_comp.service_c = vg_enf_service
	or vr_comp.service_c = vg_enf_trade_service)
	or (vr_comp.service_c = vg_trade_service
	and vg_enf_trade_installation = "N")
	or vg_enf_installation = "N"
	then
		# Leave action enforce hidden
	else
		# Check to see if enforcement already raised
		select enf_complaint_no into vl_enforcement_ref
			from comp_enf_link
			where source_complaint = vr_comp.complaint_no
		if not vl_enforcement_ref
		then
			if quiet_allow("enf_add_upd")
			then
				call d.setActionActive("enforcement", true)
				call d.setActionHidden("enforcement", false)
			end if
		end if
	end if

	case 
		when vr_comp.service_c = vg_sl_service
		and vg_sl_installation = "Y"
			call d.setActionActive("detail", true)
			call d.setActionHidden("detail", false)
			call d.setActionActive("detailup", true)
			call d.setActionHidden("detailup", false)
			if vg_sl_count > 3
			then
				call d.setActionActive("inventory", true)
				call d.setActionHidden("inventory", false)
#				call d.setActionActive("previous", true)
#				call d.setActionHidden("previous", false)
#				call d.setActionActive("next", true)
#				call d.setActionHidden("next", false)
			end if

		when vr_comp.service_c = vg_gm_service
		and vg_gm_installation = "Y"
#			call d.setActionActive("inventory", true)
#			call d.setActionHidden("inventory", false)
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)

		when vr_comp.service_c = vg_ert_service
		and vg_ert_installation = "Y"
		and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
			if vg_ert_detailed_info = "Y"
			then
				call d.setActionActive("detail", true)
				call d.setActionHidden("detail", false)
				call d.setActionActive("detailup", true)
				call d.setActionHidden("detailup", false)
				call d.setActionActive("dest", true)
				call d.setActionHidden("dest", false)
			else
				call d.setActionActive("dest", true)
				call d.setActionHidden("dest", false)
			end if
			call d.setActionActive("tags", true)
			call d.setActionHidden("tags", false)

		when vr_comp.service_c = vg_ert_service
		and vg_ert_installation = "Y"
		and skey_check("ERT_COMPLAINTS", "ALL") = "N"
			if vg_ert_detailed_info = "Y"
			then
				call d.setActionActive("detail", true)
				call d.setActionHidden("detail", false)
				call d.setActionActive("detailup", true)
				call d.setActionHidden("detailup", false)
				call d.setActionActive("dest", true)
				call d.setActionHidden("dest", false)
			else
				call d.setActionActive("dest", true)
				call d.setActionHidden("dest", false)
			end if
			call d.setActionActive("tandc", true)
			call d.setActionHidden("tandc", false)
			call d.setActionActive("tandcup", true)
			call d.setActionHidden("tandcup", false)

		when vr_comp.service_c = vg_trees_service
		and vg_trees_installation = "Y"
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)
			call d.setActionActive("treeinfo", true)
			call d.setActionHidden("treeinfo", false)

		when vr_comp.service_c = vg_weee_service
		and vg_weee_installation = "Y"
			call d.setActionActive("viewload", true)
			call d.setActionHidden("viewload", false)
			call d.setActionActive("update_header", false)
			call d.setActionHidden("update_header", true)
			select count(*)
				into vl_count
			from weee_load_hdr
				where source_ref = vr_comp.complaint_no
			if vl_count
			then
				call d.setActionActive("createload", false)
				call d.setActionHidden("createload", true)
				call d.setActionActive("viewload", true)
				call d.setActionHidden("viewload", false)
			else
				call d.setActionActive("createload", true)
				call d.setActionHidden("createload", false)
				call d.setActionActive("viewload", false)
				call d.setActionHidden("viewload", true)
			end if

		when vr_comp.service_c = vg_weee_sales_service
		and vg_sales_installation = "Y"
{
			if vr_comp.action_flag != "W"		
			then
#				call d.setActionActive("detail", true)
#				call d.setActionHidden("detail", false)
				call d.setActionActive("addsale", true)
				call d.setActionHidden("addsale", false)
			else
				call d.setActionActive("saleinfo", true)
				call d.setActionHidden("saleinfo", false)
				call d.setActionActive("worksched", true)
				call d.setActionHidden("worksched", false)
			end if
}
			call d.setActionActive("update_header", false)
			call d.setActionHidden("update_header", true)

			case vr_comp.action_flag
				when "W"
					call d.setActionActive("saleinfo", true)
					call d.setActionHidden("saleinfo", false)
					call d.setActionActive("worksched", true)
					call d.setActionHidden("worksched", false)
					call d.setActionActive("closesale", true)
					call d.setActionHidden("closesale", false)
				when "N"
					# No extra actions
				otherwise
					call d.setActionActive("addsale", true)
					call d.setActionHidden("addsale", false)
					call d.setActionActive("closesale", true)
					call d.setActionHidden("closesale", false)
			end case

		when vr_comp.service_c = vg_sched_service
		and vg_sched_installation = "Y"
		and vg_weee_installation = "Y"
			call d.setActionActive("viewload", true)
			call d.setActionHidden("viewload", false)
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)
			call d.setActionActive("update_header", false)
			call d.setActionHidden("update_header", true)

			if vg_sched_collect_items = "Y"
			then
				select wo_key, 
						wo_h_stat, 
						wo_type_f, 
						contract_ref
					into vl_wo_key, 
						vl_wo_h_stat, 
						vl_wo_type_f, 
						vl_contract_ref
				from wo_h
					where wo_ref = vr_comp.dest_ref
					and wo_suffix = vr_comp.dest_suffix

				initialize vlr_wo_stat.* to null
				select * into vlr_wo_stat.* from wo_stat
					where wo_h_stat = vl_wo_h_stat

				if vlr_wo_stat.assessment = "Y"
				or skey_check("SCHED_UPDATE_ITEMS", "ALL") = "Y"
				then
					call d.setActionActive("scheditems", true)
					call d.setActionHidden("scheditems", false)
				end if
			end if

					
		when vr_comp.service_c = vg_sched_service
		and vg_sched_installation = "Y"
		and vg_weee_installation = "N"
		and vg_sched_collect_items = "Y"
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)

			select wo_key, 
					wo_h_stat, 
					wo_type_f, 
					contract_ref
				into vl_wo_key, 
					vl_wo_h_stat, 
					vl_wo_type_f, 
					vl_contract_ref
				from wo_h
				where wo_ref = vr_comp.dest_ref
				and wo_suffix = vr_comp.dest_suffix

			initialize vlr_wo_stat.* to null
			select * into vlr_wo_stat.* from wo_stat
				where wo_h_stat = vl_wo_h_stat

			if vlr_wo_stat.assessment = "Y"
			or vr_comp.action_flag = "H"
			or skey_check("SCHED_UPDATE_ITEMS", "ALL") = "Y"
			then
				call d.setActionActive("scheditems", true)
				call d.setActionHidden("scheditems", false)
			end if


		when vr_comp.service_c = vg_av_service
		and vg_av_installation = "Y"
			call f.setElementHidden("status_page",false)
			select count(*) into vg_loc_change from comp_av_hist
			where complaint_no = vr_comp.complaint_no
				and status_ref = "LOC_CH"

			select count(*) into vg_off_change from comp_av_hist
			where complaint_no = vr_comp.complaint_no
				and status_ref = "OFF_CH"

			let vl_lookup_text = skey_check("AV HPI WEB", "ALL")

			if not vg_loc_change and not vg_off_change 
			and (length(skey_check("AV POLICE EMAIL", "ALL")) = 0
				or not quiet_allow("av_police_email"))
			and (length(skey_check("AV_FIRE_EMAIL", "ALL")) = 0
				or not quiet_allow("av_fire_email"))
			and (length(skey_check("AV_HOUSING_EMAIL", "ALL")) = 0
				or not quiet_allow("av_housing_email"))
			and length(vl_lookup_text) = 0
			and skey_check("AV WO USED","ALL") != "Y"
			then
				call d.setActionActive("av_status", true)
				call d.setActionHidden("av_status", false)
			else
				if vg_off_change 
				then
					call d.setActionActive("officer", true)
					call d.setActionHidden("officer", false)
				end if
				if vg_loc_change 
				then
					call d.setActionActive("location", true)
					call d.setActionHidden("location", false)
				end if
				let vl_lookup_text =
						skey_check("AV HPI WEB", "ALL")
				if length(vl_lookup_text)
				then
					call d.setActionActive("hpicheck", true)
					call d.setActionHidden("hpicheck", false)
				end if
				if skey_check("AV_DHO_ACTIVE","ALL") = "Y"
				then
					select count(*) into vl_count from dho
						where dho_code = vr_comp.recvd_by
					if vl_count
					then
						call d.setActionActive("dhoinfo", true)
						call d.setActionHidden("dhoinfo", false)
						call d.setActionActive("dhoupdate", true)
						call d.setActionHidden("dhoupdate", false)
					end if
				end if
				call d.setActionActive("av_status", true)
				call d.setActionHidden("av_status", false)

{
				let vl_lookup_text =
						skey_check("AV HPI WEB", "ALL")
				let vl_hpi_menu_desc = "HPI Check Web Link.",
												"             ",
												vl_lookup_text

				let vl_wo_menu_desc =
							"Show Works Order Destination"
}
				if skey_check("AV WO USED","ALL") = "Y"
				then
					call d.setActionActive("dest", true)
					call d.setActionHidden("dest", false)
				else
					call d.setActionActive("dest", true)
					call d.setActionHidden("dest", false)
				end if
{
				let vl_enforcement_ref = 0
				if vg_enf_installation = "Y"
				then
					# Find out if the complaint has a 
					# related enforcement
					select complaint_no
						into vl_enforcement_ref
					from comp_enf
						where source_ref = vr_comp.complaint_no
				end if
				if not vl_enforcement_ref
				then
					call d.setActionActive("showenf", false)
					call d.setActionHidden("showenf", true)
				else
					call d.setActionActive("showenf", true)
					call d.setActionHidden("showenf", false)
					let vl_e_menu_desc = 
						"Display the enforcement ",
						"related to the selected ",
						downshift(vg_record_title) clipped, "."
				end if
}
				# BJG - 06/10/2009
				if (length(skey_check("AV POLICE EMAIL", "ALL"))
				and quiet_allow("av_police_email"))
				then
					call d.setActionActive("avemailp", true)
					call d.setActionHidden("avemailp", false)
				end if
				if (length(skey_check("AV_FIRE_EMAIL", "ALL"))
				and quiet_allow("av_fire_email"))
				then
					call d.setActionActive("avemailf", true)
					call d.setActionHidden("avemailf", false)
				end if
				if (length(skey_check("AV_HOUSING_EMAIL", "ALL"))
				and quiet_allow("av_housing_email"))
				then
					call d.setActionActive("avemailh", true)
					call d.setActionHidden("avemailh", false)
				end if
				# BJG - 06/10/2009
			end if

		when (vr_comp.service_c = vg_enf_service
		and vg_enf_installation = "Y")
		or (vr_comp.service_c = vg_enf_trade_service
		and vg_enf_trade_installation = "Y")
			call f.setElementHidden("actions_page",0)
			call f.setElementHidden("suspect_page",0)
			call f.setElementHidden("evidence_page",0)
			call f.setElementHidden("action_text_page",0)
			if check_install("ENF_COST") then
				call f.setElementHidden("costs_page",0)
			end if
			call d.setActionActive("evidence", true)
			call d.setActionHidden("evidence", false)
			call d.setActionActive("actions", true)
			call d.setActionHidden("actions", false)
			call d.setActionActive("suspect", true)
			call d.setActionHidden("suspect", false)
#			call d.setActionActive("dest", true)
#			call d.setActionHidden("dest", false)
			call d.setActionActive("related", true)
			call d.setActionHidden("related", false)
			if vg_loc_change 
			and vr_comp.service_c = vg_enf_service
			and vg_enf_installation = "Y"
			then
				call d.setActionActive("location", true)
				call d.setActionHidden("location", false)
			end if
			if (vr_comp.date_closed < "01011900"
			or length(vr_comp.date_closed) = 0)
			then
				if quiet_allow("enf_act_add")
				then
					call d.setActionActive("addaction", true)
					call d.setActionHidden("addaction", false)
				end if
				if check_install("ENF_COST")
				and quiet_allow("enfcost_trans_upd")
				then
					call d.setActionActive("addcost", true)
					call d.setActionHidden("addcost", false)
					call d.setActionActive("costs", true)
					call d.setActionHidden("costs", false)
				end if
			end if

		when vr_comp.service_c = vg_trade_service
		and vg_trade_installation = "Y"
			call f.setElementHidden("trade_page",0) # Show Trade Task Tab of Folder
			call f.setElementHidden("debtor_page",0) # Show Debtor Tab of Folder
			call f.setElementHidden("trade_site_page",0) # Show Trade Site Tab of Folder
			call d.setActionActive("trstshow", true)
			call d.setActionHidden("trstshow", false)
#			call d.setActionActive("trstshow2", true)
#			call d.setActionHidden("trstshow2", false)
			call d.setActionActive("dbtrshow", true)
			call d.setActionHidden("dbtrshow", false)
#			call d.setActionActive("dbtrshow2", true)
#			call d.setActionHidden("dbtrshow2", false)
			if vr_comp_trade.agreement_no
			then
				call d.setActionActive("agmtshow", true)
				call d.setActionHidden("agmtshow", false)
			end if
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)

		when vr_comp.service_c = vg_agreq_service
		and vg_agreq_installation = "Y"
			call f.setElementHidden("debtor_page",0) # Show Debtor Tab of Folder
			call f.setElementHidden("trade_site_page",0) # Show Trade Site Tab of Folder
			if vr_comp.action_flag = "R"
			then
				call d.setActionActive("agmtshow", true)
				call d.setActionHidden("agmtshow", false)
				call d.setActionActive("trstshow", true)
				call d.setActionHidden("trstshow", false)
#				call d.setActionActive("trstshow2", true)
#				call d.setActionHidden("trstshow2", false)
				call d.setActionActive("dbtrshow", true)
				call d.setActionHidden("dbtrshow", false)
#				call d.setActionActive("dbtrshow2", true)
#				call d.setActionHidden("dbtrshow2", false)
			else
				call d.setActionActive("agmtshow", false)
				call d.setActionHidden("agmtshow", true)
				call d.setActionActive("trstshow", false)
				call d.setActionHidden("trstshow", true)
#				call d.setActionActive("trstshow2", false)
#				call d.setActionHidden("trstshow2", true)
				call d.setActionActive("dbtrshow", false)
				call d.setActionHidden("dbtrshow", true)
#				call d.setActionActive("dbtrshow2", false)
#				call d.setActionHidden("dbtrshow2", true)
			end if

{
			if vr_comp_agreq.agreement_no_h
			then
				call d.setActionActive("trstshow", true)
				call d.setActionHidden("trstshow", false)
				call d.setActionActive("dbtrshow", true)
				call d.setActionHidden("dbtrshow", false)
				call d.setActionActive("agmtshow", true)
				call d.setActionHidden("agmtshow", false)
			end if
}
#			call d.setActionActive("dest", true)
#			call d.setActionHidden("dest", false)

		when vr_comp.service_c = vg_nappy_service
		and vg_nappy_installation = "Y"
			call d.setActionActive("nappyinfo", true)
			call d.setActionHidden("nappyinfo", false)
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)

		when vr_comp.service_c = vg_clin_service
		and vg_clin_installation = "Y"
			call d.setActionActive("clininfo", true)
			call d.setActionHidden("clininfo", false)
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)

		when vr_comp.service_c = vg_dart_service
		and vg_dart_installation = "Y"
			call d.setActionActive("detail", true)
			call d.setActionHidden("detail", false)
			call d.setActionActive("detailup", true)
			call d.setActionHidden("detailup", false)
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)

		when vr_comp.service_c = vg_sw_service
		and vg_sw_installation = "Y"
			call d.setActionActive("detail", true)
			call d.setActionHidden("detail", false)
			call d.setActionActive("detailup", true)
			call d.setActionHidden("detailup", false)
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)

		otherwise
			call d.setActionActive("dest", true)
			call d.setActionHidden("dest", false)
	end case

	if check_history_system_key(vr_comp.service_c)
	then
		call d.setActionActive("hiddentxt", true)
		call d.setActionHidden("hiddentxt", false)
	else
		call d.setActionActive("hiddentxt", false)
		call d.setActionHidden("hiddentxt", true)
	end if

	if check_dest_system_key(vr_comp.service_c)
	then
		call d.setActionActive("alloc", true)
		call d.setActionHidden("alloc", false)
	else
		call d.setActionActive("alloc", false)
		call d.setActionHidden("alloc", true)
	end if

	let vl_enforcement_ref = 0
	if vg_enf_installation = "Y"
	or vg_enf_trade_installation = "Y"
	then
		# Find out if the complaint has a 
		# related enforcement
{
		select complaint_no
			into vl_enforcement_ref
		from comp_enf
			where source_ref = vr_comp.complaint_no
}
		select enf_complaint_no
			into vl_enforcement_ref
		from comp_enf_link
			where source_complaint = vr_comp.complaint_no
	end if
	if not vl_enforcement_ref
	then
		call d.setActionActive("showenf", false)
		call d.setActionHidden("showenf", true)
	else
		call d.setActionActive("showenf", true)
		call d.setActionHidden("showenf", false)
{
		let vl_e_menu_desc = 
			"Display the enforcement ",
			"related to the selected ",
			downshift(vg_record_title) clipped, "."
}
	end if
	if vg_show_source
	then
		#ADJrunner
		if not vg_runner_call
		then
			call d.setActionActive("dest", false)
			call d.setActionHidden("dest", true)
			call d.setActionActive("history", false)
			call d.setActionHidden("history", true)
		else
			call d.setActionActive("history", true)
			call d.setActionHidden("history", false)
		end if
		call d.setActionActive("query", false)
		call d.setActionHidden("query", true)
	else
		call d.setActionActive("history", true)
		call d.setActionHidden("history", false)
	end if

	if vg_fc_installation = "Y"
	and skey_check("FC_ENHANCED","ALL") = "Y"
	then
		if vr_comp.service_c = vg_trade_service
		and vg_trade_installation = "Y"
		then
			let vl_count = count_trade_fccomp()
		else
			if vr_comp.service_c = vg_sl_service
			and vg_sl_installation = "Y"
			then
				let vl_count = count_sl_fccomp()
			else
				if vr_comp.service_c = vg_agreq_service
				and vg_agreq_installation = "Y"
				then
					let vl_count = 0
				else
					select count(*) into vl_count from allk
						where lookup_func = "FCCOMP"
						and lookup_code = vr_comp.comp_code
						and status_yn = "Y"
				end if
			end if
		end if
		if not vl_count
		then
			call d.setActionActive("flycapture", false)
			call d.setActionHidden("flycapture", true)
		else
			call d.setActionActive("flycapture", true)
			call d.setActionHidden("flycapture", false)
		end if
	end if

	if vg_bv199_installed = "Y"
	and vr_comp.item_ref = vg_bv199_item
	then
		call d.setActionActive("bv199", true)
		call d.setActionHidden("bv199", false)
	else
		call d.setActionActive("bv199", false)
		call d.setActionHidden("bv199", true)
	end if

	if skey_check("USE_INSPECTION_ITEMS", "ALL") = "Y"
	then
		select insp_item_flag into vl_insp_item_flag from item
		where item_ref = vr_comp.item_ref and
		contract_ref = vr_comp.contract_ref
		if vl_insp_item_flag = "Y"
		and not length(vr_comp.date_closed)
		then
			call d.setActionActive("duedate", true)
			call d.setActionHidden("duedate", false)
		else
			call d.setActionActive("duedate", false)
			call d.setActionHidden("duedate", true)
		end if
	else
		call d.setActionActive("duedate", false)
		call d.setActionHidden("duedate", true)
	end if

#	call d.setActionActive("duedate", false)
#	call d.setActionHidden("duedate", true)

	case 
		when vr_comp.action_flag = "D"
			if chk_header_stat (vr_comp.dest_ref)
			then
				call d.setActionHidden("def_redefault", false)
				call d.setActionHidden("def_credit", false)
				call d.setActionHidden("def_creditall", false)
				call d.setActionHidden("def_clear", false)
				call d.setActionHidden("def_management", false)
				call d.setActionHidden("def_actioned", false)
				call d.setActionHidden("def_notactioned", false)
				call d.setActionHidden("def_unjustified", false)
				call d.setActionHidden("def_completion", false)
				call d.setActionHidden("def_void", false)
				call d.setActionActive("def_redefault", true)
				call d.setActionActive("def_credit", true)
				call d.setActionActive("def_creditall", true)
				call d.setActionActive("def_clear", true)
				call d.setActionActive("def_management", true)
				call d.setActionActive("def_actioned", true)
				call d.setActionActive("def_notactioned", true)
				call d.setActionActive("def_unjustified", true)
				call d.setActionActive("def_completion", true)
				call d.setActionActive("def_void", true)
			else
				call d.setActionHidden("def_redefault", true)
				call d.setActionHidden("def_credit", true)
				call d.setActionHidden("def_creditall", true)
				call d.setActionHidden("def_clear", true)
				call d.setActionHidden("def_management", true)
				call d.setActionHidden("def_actioned", true)
				call d.setActionHidden("def_notactioned", true)
				call d.setActionHidden("def_unjustified", true)
				call d.setActionHidden("def_completion", true)
				call d.setActionHidden("def_void", true)
				call d.setActionActive("def_redefault", false)
				call d.setActionActive("def_credit", false)
				call d.setActionActive("def_creditall", false)
				call d.setActionActive("def_clear", false)
				call d.setActionActive("def_management", false)
				call d.setActionActive("def_actioned", false)
				call d.setActionActive("def_notactioned", false)
				call d.setActionActive("def_unjustified", false)
				call d.setActionActive("def_completion", false)
				call d.setActionActive("def_void", false)
			end if
#			call d.setActionHidden("def_redefault", false)
			call d.setActionHidden("def_conthist", false)
#			call d.setActionHidden("def_actioned", false)
#			call d.setActionHidden("def_notactioned", false)
#			call d.setActionHidden("def_unjustified", false)
#			call d.setActionHidden("def_completion", false)
#			call d.setActionHidden("def_void", false)
			call d.setActionHidden("print_default", false)
			call d.setActionHidden("print_works_order", true)
			call d.setActionActive("def_conthist", true)
#			call d.setActionActive("def_actioned", true)
#			call d.setActionActive("def_notactioned", true)
#			call d.setActionActive("def_unjustified", true)
#			call d.setActionActive("def_completion", true)
#			call d.setActionActive("def_void", true)
			call d.setActionActive("print_default", true)
			call d.setActionActive("print_works_order", false)

			call d.setActionHidden("wo_status", true)
			call d.setActionActive("wo_status", false)
			call d.setActionHidden("wo_payinfo", true)
			call d.setActionActive("wo_payinfo", false)
			call d.setActionHidden("wo_delinv", true)
			call d.setActionActive("wo_delinv", false)
			call d.setActionHidden("wo_addinfo", true)
			call d.setActionActive("wo_addinfo", false)
			call d.setActionHidden("wo_taskdets", true)
			call d.setActionActive("wo_taskdets", false)
			call d.setActionHidden("wo_payinfo_v", true)
			call d.setActionActive("wo_payinfo_v", false)
			call d.setActionHidden("wo_delinv_v", true)
			call d.setActionActive("wo_delinv_v", false)
			call d.setActionHidden("wo_addinfo_v", true)
			call d.setActionActive("wo_addinfo_v", false)
			call d.setActionHidden("wo_taskdets_v", true)
			call d.setActionActive("wo_taskdets_v", false)

		when vr_comp.action_flag = "W"
			call d.setActionActive("def_credit", false)
			call d.setActionActive("def_creditall", false)
			call d.setActionActive("def_clear", false)
			call d.setActionActive("def_redefault", false)
			call d.setActionActive("def_management", false)
			call d.setActionActive("def_conthist", false)
			call d.setActionActive("def_actioned", false)
			call d.setActionActive("def_notactioned", false)
			call d.setActionActive("def_unjustified", false)
			call d.setActionActive("def_completion", false)
			call d.setActionActive("def_void", false)
			call d.setActionActive("print_default", false)
			call d.setActionHidden("def_credit", true)
			call d.setActionHidden("def_creditall", true)
			call d.setActionHidden("def_clear", true)
			call d.setActionHidden("def_redefault", true)
			call d.setActionHidden("def_management", true)
			call d.setActionHidden("def_conthist", true)
			call d.setActionHidden("def_actioned", true)
			call d.setActionHidden("def_notactioned", true)
			call d.setActionHidden("def_unjustified", true)
			call d.setActionHidden("def_completion", true)
			call d.setActionHidden("def_void", true)
			call d.setActionHidden("print_default", true)

			if vr_comp.date_closed is null
			then
# +++++ what about camden style with no access to status ??? - BJG.
				call d.setActionHidden("wo_status", false)
				call d.setActionActive("wo_status", true)
			else
				call d.setActionHidden("wo_status", true)
				call d.setActionActive("wo_status", false)
			end if

			call d.setActionHidden("wo_payinfo", false)
			call d.setActionActive("wo_payinfo", true)
			call d.setActionHidden("wo_delinv", false)
			call d.setActionActive("wo_delinv", true)
			call d.setActionHidden("wo_payinfo_v", false)
			call d.setActionActive("wo_payinfo_v", true)
			call d.setActionHidden("wo_delinv_v", false)
			call d.setActionActive("wo_delinv_v", true)
			call d.setActionHidden("print_works_order", false)
			call d.setActionActive("print_works_order", true)

			if skey_check("USE_WO_H_EXTRA_TABLE", "ALL") = "Y"
			then
				call d.setActionHidden("wo_addinfo", false)
				call d.setActionActive("wo_addinfo", true)
				call d.setActionHidden("wo_addinfo_v", false)
				call d.setActionActive("wo_addinfo_v", true)
			else	
				call d.setActionHidden("wo_addinfo", true)
				call d.setActionActive("wo_addinfo", false)
				call d.setActionHidden("wo_addinfo_v", true)
				call d.setActionActive("wo_addinfo_v", false)
			end if
			call d.setActionHidden("wo_taskdets", false)
			call d.setActionActive("wo_taskdets", true)
			call d.setActionHidden("wo_taskdets_v", false)
			call d.setActionActive("wo_taskdets_v", true)

		otherwise
			call d.setActionActive("def_credit", false)
			call d.setActionActive("def_creditall", false)
			call d.setActionActive("def_clear", false)
			call d.setActionActive("def_redefault", false)
			call d.setActionActive("def_management", false)
			call d.setActionActive("def_conthist", false)
			call d.setActionActive("def_actioned", false)
			call d.setActionActive("def_notactioned", false)
			call d.setActionActive("def_unjustified", false)
			call d.setActionActive("def_completion", false)
			call d.setActionActive("def_void", false)
			call d.setActionActive("print_default", false)
			call d.setActionActive("print_works_order", false)
			call d.setActionHidden("def_credit", true)
			call d.setActionHidden("def_creditall", true)
			call d.setActionHidden("def_clear", true)
			call d.setActionHidden("def_redefault", true)
			call d.setActionHidden("def_management", true)
			call d.setActionHidden("def_conthist", true)
			call d.setActionHidden("def_actioned", true)
			call d.setActionHidden("def_notactioned", true)
			call d.setActionHidden("def_unjustified", true)
			call d.setActionHidden("def_completion", true)
			call d.setActionHidden("def_void", true)
			call d.setActionHidden("print_default", true)
			call d.setActionHidden("print_works_order", true)

			call d.setActionHidden("wo_status", true)
			call d.setActionActive("wo_status", false)
			call d.setActionHidden("wo_payinfo", true)
			call d.setActionActive("wo_payinfo", false)
			call d.setActionHidden("wo_delinv", true)
			call d.setActionActive("wo_delinv", false)
			call d.setActionHidden("wo_addinfo", true)
			call d.setActionActive("wo_addinfo", false)
			call d.setActionHidden("wo_taskdets", true)
			call d.setActionActive("wo_taskdets", false)
			call d.setActionHidden("wo_payinfo_v", true)
			call d.setActionActive("wo_payinfo_v", false)
			call d.setActionHidden("wo_delinv_v", true)
			call d.setActionActive("wo_delinv_v", false)
			call d.setActionHidden("wo_addinfo_v", true)
			call d.setActionActive("wo_addinfo_v", false)
			call d.setActionHidden("wo_taskdets_v", true)
			call d.setActionActive("wo_taskdets_v", false)
			
	end case

################################################################################
	#ADJ 25SEP2008
	call d.setActionHidden("update_destination", true)
	call d.setActionActive("update_destination", false)
	call d.setActionHidden("hway_status", true)
	call d.setActionActive("hway_status", false)
	call d.setActionHidden("av_status", true)
	call d.setActionActive("av_status", false)
	#call d.setActionHidden("update_evidence", true)
	#call d.setActionActive("update_evidence", false)

	case
		when vr_comp.service_c = vg_av_service
		and vg_av_installation = "Y"
			call d.setActionHidden("av_status", false)
			call d.setActionActive("av_status", true)
			if skey_check("AV_ENHANCED", "ALL") = "N"
			then
				call d.setActionHidden("update_destination", false)
				call d.setActionActive("update_destination", true)
			else
				if skey_check("AV WO USED", "ALL") = "Y"
				then
					call d.setActionHidden("update_destination", false)
					call d.setActionActive("update_destination", true)
				end if
			end if

		when vr_comp.service_c = vg_hway_service
		and vg_hway_installation = "Y"
			call d.setActionHidden("hway_status", false)
			call d.setActionActive("hway_status", true)
			if vr_comp.date_closed is not null
			then
				call d.setActionHidden("update_header", true)
				call d.setActionActive("update_header", false)
			end if

		when vr_comp.service_c = vg_enf_service
		and vg_enf_installation = "Y"
			#call d.setActionHidden("update_suspect", false)
			#call d.setActionActive("update_suspect", true)
			#call d.setActionHidden("update_evidence", false)
			#call d.setActionActive("update_evidence", true)

		when vr_comp.service_c = vg_enf_trade_service
		and vg_enf_trade_installation = "Y"
			#call d.setActionHidden("update_suspect", false)
			#call d.setActionActive("update_suspect", true)
			#call d.setActionHidden("update_evidence", false)
			#call d.setActionActive("update_evidence", true)

		otherwise
			call d.setActionHidden("update_destination", false)
			call d.setActionActive("update_destination", true)
	end case

	if vr_comp.service_c = vg_sched_service
	and vg_sched_installation = "Y"
	and vg_weee_installation = "Y"
	then
		call d.setActionHidden("update_destination", true)
		call d.setActionActive("update_destination", false)

		if vg_sched_collect_items = "Y"
		then
			if vr_comp.action_flag = "H"
			then
				call d.setActionHidden("update_destination", false)
				call d.setActionActive("update_destination", true)
			end if
		end if
	end if
					
	if vr_comp.service_c = vg_sched_service
	and vg_sched_installation = "Y"
	and vg_weee_installation = "N"
	and vg_sched_collect_items = "Y"
	then
		call d.setActionHidden("update_destination", true)
		call d.setActionActive("update_destination", false)

		if vr_comp.action_flag = "H"
		then
			call d.setActionHidden("update_destination", false)
			call d.setActionActive("update_destination", true)
		end if
	end if
					
	let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
	if
		vg_allow_monitor = "Y" and
		vg_monitor_fault matches vl_comp_code and
		vr_comp.recvd_by = vg_monitor_source
	then
		call d.setActionHidden("monitorresults", false)
		call d.setActionActive("monitorresults", true)
	else
		call d.setActionHidden("monitorresults", true)
		call d.setActionActive("monitorresults", false)
	end if

	if not quiet_allow("complain_update") 
	then
		# BJG 01/09/2010 - disable all update actions !
		call d.setActionActive("update_header", false)
		call d.setActionActive("update_destination", false)
		call d.setActionActive("detailup", false)
		call d.setActionActive("dhoupdate", false)
		call d.setActionActive("tandcup", false)
		call d.setActionActive("def_credit", false)
		call d.setActionActive("def_creditall", false)
		call d.setActionActive("def_clear", false)
		call d.setActionActive("def_redefault", false)
		call d.setActionActive("def_management", false)
		call d.setActionActive("def_actioned", false)
		call d.setActionActive("def_notactioned", false)
		call d.setActionActive("def_unjustified", false)
		call d.setActionActive("def_completion", false)
		call d.setActionActive("def_void", false)
		call d.setActionActive("wo_status", false)
		call d.setActionActive("wo_payinfo", false)
		call d.setActionActive("wo_delinv", false)
		call d.setActionActive("wo_addinfo", false)
		call d.setActionActive("wo_taskdets", false)
		call d.setActionActive("hway_status", false)
		call d.setActionActive("av_status", false)
		call d.setActionActive("scheditems", false)
	end if
{
			hide option "Clinical Information"
			hide option "Nappy Information"
			hide option "Action"
			hide option "taGs"
			hide option "Items"
			hide option "Add sale items"
			hide option "Close sale"
			hide option "tRee"
			if (vg_enf_installation != "Y" and vg_enf_trade_installation != "Y")
			or (vg_enf_installation = "Y" 
			and vr_comp.service_c = vg_enf_service)
			or (vg_enf_trade_installation = "Y" 
			and vr_comp.service_c = vg_enf_trade_service)
			or vr_comp.service_c = vg_sched_service
			then
				hide option "enForcement"
			end if
			if not check_install("FC") then
				hide option "flYcapture"
			else
				if skey_check("FC_ENHANCED","ALL") = "Y"
				then
					if vr_comp.service_c = vg_trade_service
					and vg_trade_installation = "Y"
					then
						let vl_count = count_trade_fccomp()
					else
						if vr_comp.service_c = vg_sl_service
						and vg_sl_installation = "Y"
						then
							let vl_count = count_sl_fccomp()
						else
							if vr_comp.service_c = vg_agreq_service
							and vg_agreq_installation = "Y"
							then
								let vl_count = 0
							else
								select count(*) into vl_count from allk
									where lookup_func = "FCCOMP"
									and lookup_code = vr_comp.comp_code
									and status_yn = "Y"
							end if
						end if
					end if
					if not vl_count
					then
						hide option "flYcapture"
					end if
				end if
			end if
			case 
				when vr_comp.service_c = vg_hway_service
					and vg_hway_installation = "Y"
					show option "Status"

				when (vr_comp.service_c = vg_enf_service
					and vg_enf_installation = "Y")
					or (vr_comp.service_c = vg_enf_trade_service
					and vg_enf_trade_installation = "Y")
					show option "Action"
					show option "Suspect"
					show option "eVidence text"

				when vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
					show option "Status"
					if skey_check("AV WO USED", "ALL") = "Y"	# 1/10/3
					or vg_enf_installation = "Y"
					or vg_enf_trade_installation = "Y"
					then
						show option "Destination"
					end if 
					if skey_check("AV_DHO_ACTIVE", "ALL") = "Y"	# 1/10/3
					then
						select count(*) into vl_count from dho
							where dho_code = vr_comp.recvd_by
						if vl_count
						then
							show option "DHO Information"
						end if
					end if 
					
				when vr_comp.service_c = vg_nappy_service
					and vg_nappy_installation = "Y"
					show option "Nappy Information"
					show option "Destination"

				when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "Y"
					hide option "Header"
					hide option "Destination"

					if vg_sched_collect_items = "Y"
					then
						select wo_key, 
								wo_h_stat, 
								wo_type_f, 
								contract_ref
							into vl_wo_key, 
								vl_wo_h_stat, 
								vl_wo_type_f, 
								vl_contract_ref
						from wo_h
							where wo_ref = vr_comp.dest_ref
							and wo_suffix = vr_comp.dest_suffix

						select * into vl_wo_stat.* from wo_stat
							where wo_h_stat = vl_wo_h_stat
						if vl_wo_stat.assessment = "Y"
						or skey_check("SCHED_UPDATE_ITEMS", "ALL") = "Y"
						then
							show option "Items"
						end if

						if vr_comp.action_flag = "H"
						then
							select wo_type_f
								into vl_wo_type_f
							from comp_sched
								where complaint_no = vr_comp.complaint_no
							show option "Destination"
							show option "Header"
							show option "Items"
						end if
					end if
					
				when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "N"
					and vg_sched_collect_items = "Y"

					select wo_key, 
							wo_h_stat, 
							wo_type_f, 
							contract_ref
						into vl_wo_key, 
							vl_wo_h_stat, 
							vl_wo_type_f, 
							vl_contract_ref
					from wo_h
						where wo_ref = vr_comp.dest_ref
						and wo_suffix = vr_comp.dest_suffix

					select * into vl_wo_stat.* from wo_stat
						where wo_h_stat = vl_wo_h_stat
					if vl_wo_stat.assessment = "Y"
					or vr_comp.action_flag = "H"
					or skey_check("SCHED_UPDATE_ITEMS", "ALL") = "Y"
					then
						show option "Items"
					end if

					if vr_comp.action_flag = "H"
					then
						select wo_type_f
							into vl_wo_type_f
						from comp_sched
							where complaint_no = vr_comp.complaint_no
						show option "Destination"
						show option "Header"
					end if
					
				when vr_comp.service_c = vg_weee_service
					and vg_weee_installation = "Y"
					hide option "Header"
					hide option "Destination"
					
				when vr_comp.service_c = vg_weee_sales_service
					and vg_sales_installation = "Y"
					hide option "Header"
					hide option "Destination"
					if vr_comp.action_flag = "H"
					then
						show option "Add sale items"
						show option "Close sale"
					end if
					
				when vr_comp.service_c = vg_clin_service
					and vg_clin_installation = "Y"
					show option "Clinical Information"
					show option "Destination"
					
				when vr_comp.service_c = vg_sl_service
					and vg_sl_installation = "Y"

				when vr_comp.service_c = vg_gm_service
					and vg_gm_installation = "Y"
					show option "Destination"

				when vr_comp.service_c = vg_ert_service
					and vg_ert_installation = "Y"
					and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
					show option "Destination"
					show option "taGs"

				when vr_comp.service_c = vg_trees_service
					and vg_trees_installation = "Y"
					show option "Destination"
					show option "tRee"
				
				otherwise
					if not vg_show_source or vg_runner_call
					then
						show option "Destination"
					end if
			end case
			if check_dest_system_key(vr_comp.service_c)
			then
				show option "allOcation"
			else
				hide option "allOcation"
			end if
################################################################################
}

# DISPLAY "PAGE = ", vm_current_page
    IF vm_current_page = "attachments_page" THEN
        # BJG 04/07/2012 - workflow 3348 - only show add attach if page is attachments and only if allowed for enforcements
        if vr_comp.service_c = vg_enf_service
        and not quiet_allow("enf_comp_attachments")
        THEN
# DISPLAY "Service is ENFORCE and NOT allow enf_comp_attachments"        
            call d.setActionHidden("attachadd", true)
            call d.setActionActive("attachadd", false)
        ELSE
# DISPLAY "Service is ENFORCE and allow enf_comp_attachments OR service is NOT ENFORCE"        
            call d.setActionHidden("attachadd", false)
            call d.setActionActive("attachadd", true)
        end if
    ELSE
        call d.setActionHidden("attachadd", true)
        call d.setActionActive("attachadd", false)
    END IF
# DISPLAY "There are ", vm_attach.getLength(), " attachments."    
    IF vm_current_page = "attachments_page"  AND vm_attach.getlength() > 0 THEN
        # BJG 04/07/2012 - workflow 3348 - only show delete and show attach if page is attachments and only if allowed for enforcements
        if vr_comp.service_c = vg_enf_service
        and not quiet_allow("enf_comp_attachments")
        THEN
# DISPLAY "Service is ENFORCE and NOT allow enf_comp_attachments"        
            call d.setActionActive("attachdelete", false)
            call d.setActionHidden("attachdelete", true)
            call d.setActionActive("attachshow", false)
            call d.setActionHidden("attachshow", true)
        ELSE
# DISPLAY "Service is ENFORCE and allow enf_comp_attachments OR service is NOT ENFORCE"        
            call d.setActionHidden("attachdelete", false)
            call d.setActionActive("attachdelete", true)
            call d.setActionHidden("attachshow", false)
            call d.setActionActive("attachshow", true)
        end if
    ELSE
        call d.setActionHidden("attachdelete", true)
        call d.setActionActive("attachdelete", false)
        call d.setActionHidden("attachshow", true)
        call d.setActionActive("attachshow", false)
    END IF

end function


function drive_enforce_destination()
	DEFINE
        vl_save_agreement_no    LIKE agreement.agreement_no,
        vlr_comp_save		record like comp.*,
		vlr_customer_save	record like customer.*,
		vlr_diry_save		record like diry.*,
		vlr_si_i_save		record like si_i.*,
		vl_count				integer,
		vl_complaint_no	like comp.complaint_no,
		vl_service_c		like comp.service_c,
		vla_complaint		dynamic array of record
			complaint_no	like comp.complaint_no,
			service_c		like comp.service_c,
			address			char(100),
			date_entered	like comp.date_entered,
			comp_code		like comp.comp_code,
			action_flag		like comp.action_flag,
			status			char(7)
		end record,
		vl_runstr			char(100),
		vl_add_flag,
		vl_exit_flag,
		vl_ac					smallint,
		vl_save_page		char(20),
        vl_loop				smallint
        
	let vl_exit_flag = false
	let vl_add_flag = false
	while true
		call vla_complaint.clear()
		declare c_complaint_list cursor for
			select source_complaint from comp_enf_link
				where enf_complaint_no = vr_comp.complaint_no
				order by source_complaint
		foreach c_complaint_list into vl_complaint_no
			call vla_complaint.appendelement()
			let vla_complaint[vla_complaint.getlength()].complaint_no =
																				vl_complaint_no
			select * into vlr_comp_save.* from comp
				where complaint_no =
						vla_complaint[vla_complaint.getlength()].complaint_no
			let vla_complaint[vla_complaint.getlength()].service_c =
																		vlr_comp_save.service_c
			if length(vlr_comp_save.build_no)
			then
				let vla_complaint[vla_complaint.getlength()].address =
														vlr_comp_save.build_no clipped,
														" ",
														vlr_comp_save.location_name clipped
			else
				let vla_complaint[vla_complaint.getlength()].address =
																	vlr_comp_save.location_name
			end if
			let vla_complaint[vla_complaint.getlength()].date_entered =
																		vlr_comp_save.date_entered
			let vla_complaint[vla_complaint.getlength()].comp_code =
																		vlr_comp_save.comp_code
			let vla_complaint[vla_complaint.getlength()].action_flag =
																		vlr_comp_save.action_flag
			if length(vlr_comp_save.date_closed)
			then
				let vla_complaint[vla_complaint.getlength()].status = "CLOSED"
			else
				let vla_complaint[vla_complaint.getlength()].status = "RUNNING"
			end if
		end foreach
		let vl_complaint_no = 0

		if vla_complaint.getlength()
		then
			open window iw_related with form "related_comps"
			display array vla_complaint to sa_complaint_list.*
				before row
					let vl_ac = arr_curr()

				on action cancel
					let vl_exit_flag = true
					exit display

				on action accept
					let vl_exit_flag = true
					exit display

				on action close
					let vl_exit_flag = true
					exit display

				on action detail
					let vl_complaint_no = vla_complaint[vl_ac].complaint_no
					let vl_runstr = 
						"exec fglgo_complain X X X X X ", vl_complaint_no
					call os_exec(vl_runstr, false)
					exit display

				on action addenq
					let vl_add_flag = true
					exit display
			end display
			close window iw_related
			if vl_add_flag
			then
				# Add a related complaint
				call load_comp_text_array(vr_comp.complaint_no) # BJG 21/01/08
				if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
				then
					call load_comp_det_text_array() 
				end if
				let vlr_comp_save.* = vr_comp.*
				let vlr_customer_save.* = vr_customer.*
				let vlr_diry_save.* = vr_diry.*
				let vlr_si_i_save.* = vr_si_i.*
                LET vl_save_agreement_no = vg_agreement_no
                INITIALIZE vr_comp_trade.* TO null
                INITIALIZE vg_agreement_no TO NULL
                IF vr_comp.service_c = vg_enf_trade_service
				and vg_enf_trade_installation = "Y"
                THEN
                    SELECT agreement_no INTO vg_agreement_no FROM comp_enf
                        WHERE complaint_no = vr_comp.complaint_no
                ELSE
                    IF vr_comp.service_c = vg_trade_service
                    AND vg_trade_installation = "Y"
                    THEN
                        SELECT agreement_no INTO vg_agreement_no FROM comp_trade
                            WHERE complaint_no = vr_comp.complaint_no
                    END IF
                END IF
                IF vg_agreement_no
                THEN
                    LET vr_comp_trade.agreement_no = vg_agreement_no
                    SELECT * INTO g_agreement.* FROM agreement
                        WHERE agreement_no = vg_agreement_no
                    IF STATUS = 0
                    THEN
                        SELECT * INTO g_trade_site.* FROM trade_site
                            WHERE site_no = g_agreement.site_ref
                    END IF 
                END IF 

                
				call history_save_text(true)	
				let vg_allow_text_clear = true
				let vg_enforce_ref = vr_comp.complaint_no
#				current window is iw_complain
				call load_comp_text_array(vr_comp.complaint_no)
				if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
				then
					call load_comp_det_text_array() 
				end if
				let vl_save_page = vm_current_page
#				open window iw_complain_2 at 1,1 with 20 rows, 90 columns
                INITIALIZE vr_comp.item_ref TO NULL
                INITIALIZE vr_comp.comp_code TO NULL
                INITIALIZE vr_comp.feature_ref TO NULL
                for vl_loop = 1 to 500
                    initialize m_comp_det_text_u[vl_loop].* to null
                end FOR
                LET vr_comp.text_flag = "N"
				open window iw_complain_2 with form "complain"
				call complain_labels()
				call save_comp_form_variables()
				call reset_comp_form_variables()
				call qrycomp_of()
				call addwindow_of()
				call add_complain()
				close window iw_complain_2
				let vm_current_page = vl_save_page
				call restore_comp_form_variables()
				let vg_allow_text_clear = false
				let vr_comp.* = vlr_comp_save.*
				let vr_customer.* = vlr_customer_save.*
				let vr_diry.* = vlr_diry_save.*
				let vr_si_i.* = vlr_si_i_save.*
                LET vg_agreement_no = vl_save_agreement_no
				call history_save_text(false)	
				let vl_exit_flag = true
			end if
			if vl_exit_flag
			then
				exit while
			end if
		else
			if continue_yn("No related enquiries exist. Do you wish to add one")
			then
				# Add a related complaint
				#call load_comp_text_array(vr_comp.complaint_no) # BJG 21/01/08
				#if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
				#then
				#	call load_comp_det_text_array() 
				#end if
                let g_trade_site.site_name=vr_comp_enf.site_name
                SELECT max(site_no) INTO g_trade_site.site_no FROM trade_site WHERE site_ref=vr_comp.site_ref
                let g_agreement.agreement_no=vr_comp_enf.agreement_no
                let g_agreement.agreement_name=vr_comp_enf.agreement_name
                
				let vlr_comp_save.* = vr_comp.*
				let vlr_customer_save.* = vr_customer.*
				let vlr_diry_save.* = vr_diry.*
				let vlr_si_i_save.* = vr_si_i.*
				call history_save_text(true)	
				let vg_customer_retain = true
				let vg_allow_text_clear = true
				let vg_enforce_ref = vr_comp.complaint_no
                LET vg_add_multi_complaints="Y"
#				current window is iw_complain
				#if skey_check("DETAIL_TEXT_SCREEN","ALL") = "Y"
				#then
				#	call load_comp_det_text_array() 
				#end IF
                INITIALIZE vr_comp.item_ref TO NULL
                INITIALIZE vr_comp.comp_code TO NULL
                INITIALIZE vr_comp.feature_ref TO NULL
                for vl_loop = 1 to 500
                    initialize m_comp_det_text_u[vl_loop].* to null
                end FOR
                LET vr_comp.text_flag = "N"
#				open window iw_complain_2 at 1,1 with 20 rows, 90 columns
				open window iw_complain_2 with form "complain"
				call complain_labels()
				call save_comp_form_variables()
				call reset_comp_form_variables()
				call qrycomp_of()
                call load_comp_text_array(0)
				call addwindow_of()
				call add_complain()
				close window iw_complain_2
                LET vg_add_multi_complaints="N"
                LET vg_agreement_no=null
                let g_trade_site.site_name=NULL
                let g_trade_site.site_no=NULL
                let g_agreement.agreement_no=NULL
                let g_agreement.agreement_name=NULL
				call restore_comp_form_variables()
				let vg_allow_text_clear = false
				let vr_comp.* = vlr_comp_save.*
				let vr_customer.* = vlr_customer_save.*
				let vr_diry.* = vlr_diry_save.*
				let vr_si_i.* = vlr_si_i_save.*
				call history_save_text(false)	
				exit while
			else
				exit while
			end if
		end if
	end while
end function


function save_enforce_ref()
	insert into comp_enf_link values
		(
			vg_enforce_ref,
			vr_comp.complaint_no
		)
end function


function load_rectification_array(vl_default_no)
    define
		vl_default_no	like defh.cust_def_no,
        vlr_deft        record like deft.*,
        vl_loop         smallint

	call va_deft.clear()
	call va_disp_deft.clear()

	if vl_default_no is null or vl_default_no = 0
	then
		return
	end if

    declare ic_dis_def_i cursor for
        select *
            from deft
        where deft.default_no = vl_default_no
            order by default_no,
                    seq_no desc

    let vl_loop = 1

    foreach ic_dis_def_i into vlr_deft.*
        let va_deft[vl_loop].* = vlr_deft.*
        let vl_loop = vl_loop + 1
    end foreach

    let vg_deft_count = vl_loop - 1

    call set_count(vg_deft_count)

    for vl_loop = 1 to vg_deft_count
        let va_disp_deft[vl_loop].def_seq_no = va_deft[vl_loop].seq_no

        case va_deft[vl_loop].action_flag
            when "D"
				if skey_check("DEF_1_RECT", "ALL") = "Y" then
					if va_deft[vl_loop].default_level = 1 then
						let va_disp_deft[vl_loop].def_action_desc = "RECTIFICATION"
					else
						if
							va_deft[vl_loop].points > 0 or
							va_deft[vl_loop].value > 0
						then
							let va_disp_deft[vl_loop].def_action_desc = "DEFAULT"
						else
							let va_disp_deft[vl_loop].def_action_desc = "RECTIFICATION"
						end if
					end if
				else
					let va_disp_deft[vl_loop].def_action_desc = "DEFAULT"
				end if
                select rectify_date, rectify_time_h, rectify_time_m
                    into va_disp_deft[vl_loop].def_rectify_date,
                        va_disp_deft[vl_loop].def_rectify_time_h,
                        va_disp_deft[vl_loop].def_rectify_time_m
                from defi_rect
                    where default_no = vl_default_no
                        and seq_no = va_deft[vl_loop].seq_no
            when "R"
                let va_disp_deft[vl_loop].def_action_desc = "REDEFAULT"
                select rectify_date, rectify_time_h, rectify_time_m
                    into va_disp_deft[vl_loop].def_rectify_date,
                        va_disp_deft[vl_loop].def_rectify_time_h,
                        va_disp_deft[vl_loop].def_rectify_time_m
                from defi_rect
                    where default_no = vl_default_no
                        and seq_no = va_deft[vl_loop].seq_no
            when "Z"
                let va_disp_deft[vl_loop].def_action_desc = "CREDIT"
                let va_disp_deft[vl_loop].def_rectify_date = null
                let va_disp_deft[vl_loop].def_rectify_time_h = null
                let va_disp_deft[vl_loop].def_rectify_time_m = null
            when "C"
                let va_disp_deft[vl_loop].def_action_desc = "CLEAR"
                let va_disp_deft[vl_loop].def_rectify_date = null
                let va_disp_deft[vl_loop].def_rectify_time_h = null
                let va_disp_deft[vl_loop].def_rectify_time_m = null
            when "I"
                let va_disp_deft[vl_loop].def_action_desc = "INSPECTION"
                let va_disp_deft[vl_loop].def_rectify_date = null
                let va_disp_deft[vl_loop].def_rectify_time_h = null
                let va_disp_deft[vl_loop].def_rectify_time_m = null
            when "M"
                let va_disp_deft[vl_loop].def_action_desc = "MAN ACTION"
                let va_disp_deft[vl_loop].def_rectify_date = null
                let va_disp_deft[vl_loop].def_rectify_time_h = null
                let va_disp_deft[vl_loop].def_rectify_time_m = null
            otherwise
                let va_disp_deft[vl_loop].def_action_desc = "UNKNOWN"
                let va_disp_deft[vl_loop].def_rectify_date = null
                let va_disp_deft[vl_loop].def_rectify_time_h = null
                let va_disp_deft[vl_loop].def_rectify_time_m = null
        end case

        let va_disp_deft[vl_loop].def_action_date = va_deft[vl_loop].trans_date
        let va_disp_deft[vl_loop].def_action_time_h = va_deft[vl_loop].time_h
        let va_disp_deft[vl_loop].def_action_time_m = va_deft[vl_loop].time_m
        let va_disp_deft[vl_loop].def_action_user =
#            upshift(va_deft[vl_loop].username) # BJG 05/07/2012 - Workflow 3527
                                                va_deft[vl_loop].username
        let va_disp_deft[vl_loop].def_points = va_deft[vl_loop].points
        let va_disp_deft[vl_loop].def_value = va_deft[vl_loop].value
    end for

end function


function comp_show_action(vl_default_no)
	define
		vl_default_no			like defh.cust_def_no,
		vlr_login_name 			like def_cont_i.compl_by,
		vlr_action 				char(50),
		vlr_def_cont_i 			record like def_cont_i.*,
		vlr_defh					record like defh.*,
		vlr_defi					record like defi.*,
        vl_reason_desc          LIKE allk.lookup_text

	select *
		into vlr_defh.*
	from defh
		where cust_def_no = vl_default_no

	display by name vlr_defh.cum_points, vlr_defh.cum_value

	select *
		into vlr_defi.*
	from defi
		where default_no = vl_default_no

	display by name vlr_defi.volume

	select *
		into vlr_def_cont_i.*
	from def_cont_i
		where def_cont_i.cust_def_no = vl_default_no
		and def_cont_i.item_ref = vr_comp.item_ref
		and	def_cont_i.feature_ref = vr_comp.feature_ref

	if status != 0 
	then
		let vlr_def_cont_i.action = ' '
	end if

	case 
		when vlr_def_cont_i.action = 'A'
			let vlr_action = "Actioned By ",
			vlr_def_cont_i.compl_by clipped,
			vlr_def_cont_i.date_actioned using " on DD/MM/YY at ",
			vlr_def_cont_i.time_actioned_h clipped,":",
			vlr_def_cont_i.time_actioned_m

		when vlr_def_cont_i.action = 'N'
			let vlr_action = "NOT Actioned By ",
			vlr_def_cont_i.compl_by clipped,
			vlr_def_cont_i.date_actioned using " on DD/MM/YY at ",
			vlr_def_cont_i.time_actioned_h clipped,":",
			vlr_def_cont_i.time_actioned_m

		when vlr_def_cont_i.action = 'U'
			let vlr_action = "Un_Justified By ",
			vlr_def_cont_i.compl_by clipped,
			vlr_def_cont_i.date_actioned using " on DD/MM/YY at ",
			vlr_def_cont_i.time_actioned_h clipped,":",
			vlr_def_cont_i.time_actioned_m

		otherwise
			let vlr_action = "Not Recorded Yet"

	end case		

	display vlr_def_cont_i.completion_date,
			vlr_def_cont_i.completion_time_h,
			vlr_def_cont_i.completion_time_m,
            vlr_def_cont_i.unjust_reason
		to def_cont_i.completion_date,
			def_cont_i.completion_time_h,
			def_cont_i.completion_time_m,
            def_cont_i.unjust_reason

	case 
		when vlr_def_cont_i.action = "U"
			display vlr_action to action attribute(reverse, red)
            SELECT lookup_text INTO vl_reason_desc FROM allk
                WHERE lookup_func = "UNJUST"
                AND lookup_code = vlr_def_cont_i.unjust_reason
            IF STATUS = NOTFOUND
            THEN
                DISPLAY " " TO reason_desc
            ELSE
                DISPLAY vl_reason_desc TO reason_desc
            END IF 
            
		when vlr_def_cont_i.action = "A"
			display vlr_action to action attribute(reverse, green)
            DISPLAY " " TO reason_desc
		when vlr_def_cont_i.action = "N"
			display vlr_action to action attribute(reverse, yellow)
            DISPLAY " " TO reason_desc
		otherwise
			display vlr_action to action
            DISPLAY " " TO reason_desc
	end case

end function


function show_rectifications_tab(vl_default_no, vl_disp_flag)
	define 
		vl_default_no	like defh.cust_def_no,
		w				ui.Window,
		f				ui.Form,
		vl_disp_flag	smallint	

	let w = ui.Window.getCurrent()
	let f = w.getForm()

	call f.setElementHidden("rectifications_page",false)
	call f.setElementHidden("works_order_page",true)

	call load_rectification_array(vl_default_no)

	display vr_comp.comp_code to rect_comp_code
	display vr_comp.pa_area to rect_patrol_area

	call display_rectify_info(vl_default_no,
							vr_comp.item_ref,
							vr_comp.feature_ref)

	call comp_show_action(vl_default_no)

	if vl_disp_flag
	then
		display array va_disp_deft to sa_defi.*
			before display
				exit display
		end display

		display va_disp_deft[1].* to sa_defi[1].*
	end if
end function


function show_works_order_tab(vl_wo_ref, vl_wo_suffix, vl_disp_flag)
	define 
		vlr_wo_cont_h	record like wo_cont_h.*,
		vl_wo_ref		like wo_h.wo_ref,
		vl_wo_suffix	like wo_h.wo_suffix,
		vl_count			smallint,
		vl_disp_flag	smallint,
		vl_match			char(3),
		vl_status_change	char(22),	
		vl_tot_vol			decimal(10,2),
		vl_task_desc	like task.task_desc,
		f				ui.Form,
		w				ui.Window,
		vl_wo_stat		record like wo_stat.*

	let w = ui.Window.getCurrent()
	let f = w.getForm()

	call f.setElementHidden("rectifications_page",true)
	call f.setElementHidden("works_order_page",false)

	call load_works_order_array(vl_wo_ref, vl_wo_suffix)

	display vr_comp.contract_ref to wo_h.contract_ref

	select wo_h.*
		into vr_wo_h.*
	from wo_h
		where wo_ref = vl_wo_ref
		and wo_suffix = vl_wo_suffix

	select wo_cont_h.*
		into vlr_wo_cont_h.*
	from wo_cont_h
		where wo_ref = vl_wo_ref
		and wo_suffix = vl_wo_suffix

	display by name vr_wo_h.wo_date_due,
					vr_wo_h.wo_h_stat,
					vr_wo_h.wo_date_compl

	display vr_wo_h.wo_type_f to wo_h.wo_type_f

	display by name vlr_wo_cont_h.compl_by

	display vlr_wo_cont_h.completion_date to formonly.completion_date
	display vlr_wo_cont_h.completion_time_h to formonly.completion_time_h
	display vlr_wo_cont_h.completion_time_m to formonly.completion_time_m

	if disp_wo_h_stat() then end if
	if disp_wo_type() then end if

	if skey_check("WO_STAT_ENHANCEMENTS", "ALL") = "Y"
	then
		select * into vl_wo_stat.* from wo_stat
			where wo_h_stat = vr_wo_h.wo_h_stat
		if vl_wo_stat.estimate = "Y"
		then
			display vr_wo_h.wo_est_value to wo_act_value
		else
			display vr_wo_h.wo_act_value to wo_act_value
		end if
	else
		if vr_wo_h.wo_h_stat = "E"
		then
			display vr_wo_h.wo_est_value to wo_act_value
		else
			display vr_wo_h.wo_act_value to wo_act_value
		end if
	end if

	let vl_tot_vol = 0
	if vg_wo_count
	then
		for vl_count = 1 to vg_wo_count
			let vl_tot_vol = vl_tot_vol + va_works_order[vl_count].woi_volume
		end for
	end if
	display vl_tot_vol to tot_quantity

	if vg_wo_count
	then
		if vg_wo_line > vg_wo_count
		then
			let vg_wo_line = vg_wo_count
		end if
		if not vg_wo_line
		then
			let vg_wo_line = 1
		end if
		display va_works_order[vg_wo_line].woi_task_ref to formonly.task_ref

		select task_desc 
			into vl_task_desc
		from task
			where task_ref = va_works_order[vg_wo_line].woi_task_ref
	else
		initialize vl_task_desc to null
		display vl_task_desc to formonly.task_ref
	end if

	display vl_task_desc to wo_task_desc

{
g013a 				= formonly.type_desc,
g022a				= formonly.tot_quantity,
g023a				= formonly.wo_act_value,
g014a 				= formonly.stat_desc,
g015aa				= formonly.task_desc,

Type[g7 |g013a       ][g022a  |g023a      |g024a       ]
Task    [g015a        |g015aa                                                 ]
Status  [g8|g014a     ]Actioned[g019    |g020    ]Completion[g022       |w3|w4]
}

	if vl_disp_flag
	then
		display array va_works_order to sa_wo_i.*
			before display
				let vg_wo_line = arr_curr()
				exit display
		end display

		display va_works_order[1].* to sa_wo_i[1].*
	end if
end function


function load_works_order_array(vl_wo_ref, vl_wo_suffix)
    define
		vl_wo_ref		like wo_h.wo_ref,
		vl_wo_suffix	like wo_h.wo_suffix,
		vlr_deft			record like deft.*,
		vl_loop			smallint,
		vlr_wo_i			record like wo_i.*

	call va_works_order.clear()

	if vl_wo_ref is null or vl_wo_ref = 0
	then
		return
	end if

    declare ic_dis_wo_i cursor for
		select * from wo_i
			where wo_i.wo_ref = vl_wo_ref
			and wo_i.wo_suffix = vl_wo_suffix
			order by woi_no


	foreach ic_dis_wo_i into vlr_wo_i.*
		call va_works_order.appendelement()
		let vl_loop = va_works_order.getlength()
		let va_works_order[vl_loop].woi_no = vlr_wo_i.woi_no
		let va_works_order[vl_loop].woi_site_ref = vlr_wo_i.woi_site_ref
		let va_works_order[vl_loop].woi_task_ref = vlr_wo_i.woi_task_ref
		let va_works_order[vl_loop].woi_item_price = vlr_wo_i.woi_item_price
		let va_works_order[vl_loop].woi_volume = vlr_wo_i.woi_volume
		let va_works_order[vl_loop].woi_line_total = vlr_wo_i.woi_line_total
		let va_works_order[vl_loop].woi_comp_date = vlr_wo_i.woi_comp_date
  	end foreach

	let vg_wo_count = va_works_order.getlength()

end function



function set_def_cont_i_comp(vdef_no,vaction, v_unjust_reason)

	define  
		vdef_no			integer,
		vaction			char(1),
		theuser			like def_cont_i.compl_by,
		fv_def_cont_i	record like def_cont_i.*,
		number			integer,
		todays_time_h,
		todays_time_m	char(2),
		gv_action		char(50),
		vl_save_action	char(50),
		vl_completion_date	like def_cont_i.completion_date,
		vl_completion_time_h	like def_cont_i.completion_time_h,
		vl_completion_time_m	like def_cont_i.completion_time_m,
		f_complaint_no	like comp.complaint_no,
        v_unjust_reason LIKE def_cont_i.unjust_reason

	select *
	into fv_def_cont_i.*
	from def_cont_i
	where 	cust_def_no = vdef_no
	and		item_ref = gv_saved_item
	and 	feature_ref = gv_saved_feature

	if status = 100 
	then

		# call ins_def_cont_h(vdef_no)
		# We need to insert into def_cont_i really
		insert into def_cont_i
		values
			(	vdef_no,
				gv_saved_item,
				gv_saved_feature, 
				NULL,						# Action
				user,					# compl_by
				NULL,						# printed
				NULL,						# Clear_credit
				today,					#date actioned
				"00",					# time_action_h
				"00", 					# time_action_m
				NULL,
				NULL,
				NULL,
				NULL
			)

		select *
			into fv_def_cont_i.*
		from def_cont_i
			where 	cust_def_no = vdef_no
			and		item_ref = gv_saved_item
			and 	feature_ref = gv_saved_feature
	end if

	call get_time() returning
		todays_time_h, todays_time_m

	if vaction = "A"
	then
		let vl_save_action = gv_action
#		let gv_action = "Actioned By ",
#			get_user() clipped,
#			today using " on DD/MM/YY at ",
#			todays_time_h clipped,":",
#			todays_time_m
		let gv_action = "Actioned"

#		display gv_action to def_cont_i.action attribute(reverse, green)
		display vaction
			to action attribute(reverse, green)
		let theuser = get_user()
		display theuser
			to compl_by attribute(reverse, green)
		display gv_action
			to def_cont_i.action attribute(reverse, green)

		call get_completion(fv_def_cont_i.*)
			returning fv_def_cont_i.completion_date,
						fv_def_cont_i.completion_time_h,
						fv_def_cont_i.completion_time_m
		if fv_def_cont_i.completion_date is null
		then
			initialize vaction to null
			let gv_action = vl_save_action
		end if
	else
		initialize fv_def_cont_i.completion_date, 
				fv_def_cont_i.completion_time_h, 
				fv_def_cont_i.completion_time_m to null
	end if

	if vaction is not null
	then
		let theuser = get_user()
		update def_cont_i
		set	compl_by = theuser,
			Action = vaction,
			date_actioned = today,
			time_actioned_h = todays_time_h,
			time_actioned_m = todays_time_m,
			completion_date = fv_def_cont_i.completion_date,
			completion_time_h = fv_def_cont_i.completion_time_h,
			completion_time_m = fv_def_cont_i.completion_time_m,
            unjust_reason = v_unjust_reason
		where cust_def_no = vdef_no
			and	item_ref = gv_saved_item
			and	feature_ref = gv_saved_feature

		if status != 0 
		then
			message "Failed to Update contractor record"
			sleep 2
		end if

		call def_act_hist(vdef_no, vaction, v_unjust_reason)

		if vg_crm_enhanced = "Y"
		then
			select complaint_no into f_complaint_no from comp
				where dest_ref = vdef_no
					and action_flag = "D"
			call pop_ci_export_variables(f_complaint_no)
			let vr_crm_import_export.transaction_type = "C"
			call unload_crm_export_file(vr_crm_import_export.*)
		end if

		call ws_ext_integration(0, vdef_no, "", "D")

	end if

end function


function drive_show_replications()
	define
		vlr_comp_save		record like comp.*,
		vlr_customer_save	record like customer.*,
		vlr_diry_save		record like diry.*,
		vlr_si_i_save		record like si_i.*,
		vl_count				integer,
		vl_complaint_no	like comp.complaint_no,
		vl_service_c		like comp.service_c,
		vla_complaint		dynamic array of record
			relationship	char(12),
			complaint_no	like comp.complaint_no,
			service_c		like comp.service_c,
			address			char(100),
			date_entered	like comp.date_entered,
			comp_code		like comp.comp_code,
			action_flag		like comp.action_flag,
			det_action_desc char(20),
			status			char(7)
		end record,
		vla_complaint_color		dynamic array of record
			relationship	string,
			complaint_no	string,
			service_c		string,
			address			string,
			date_entered	string,
			comp_code		string,
			action_flag		string,
			det_action_desc string,
			status			string
		end record,
		vl_status			char(7),
		vl_address			char(100),
		vl_runstr			char(100),
		vl_add_flag,
		vl_exit_flag,
		vl_ac					smallint,
		vl_save_page		char(20)

	let vl_exit_flag = false
	let vl_add_flag = false
	while true
		call vla_complaint.clear()
		call vla_complaint_color.clear()
		declare c_source_list cursor for
			select source_comp from comp_links
				where destination_comp = vr_comp.complaint_no
				order by source_comp
		foreach c_source_list into vl_complaint_no
			call vla_complaint.appendelement()
			call vla_complaint_color.appendelement()
			let vla_complaint[vla_complaint.getlength()].relationship =
																				"SOURCE"
			let vla_complaint[vla_complaint.getlength()].complaint_no =
																				vl_complaint_no
			select * into vlr_comp_save.* from comp
				where complaint_no =
						vla_complaint[vla_complaint.getlength()].complaint_no
			let vla_complaint[vla_complaint.getlength()].service_c =
																		vlr_comp_save.service_c
			if length(vlr_comp_save.build_no)
			then
				let vla_complaint[vla_complaint.getlength()].address =
														vlr_comp_save.build_no clipped,
														" ",
														vlr_comp_save.location_name clipped
			else
				let vla_complaint[vla_complaint.getlength()].address =
																	vlr_comp_save.location_name
			end if
			let vla_complaint[vla_complaint.getlength()].date_entered =
																		vlr_comp_save.date_entered
			let vla_complaint[vla_complaint.getlength()].comp_code =
																		vlr_comp_save.comp_code
			let vla_complaint[vla_complaint.getlength()].action_flag =
																		vlr_comp_save.action_flag
			case
				when vla_complaint[vla_complaint.getlength()].action_flag = "W"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Works Order"
				when vla_complaint[vla_complaint.getlength()].action_flag = "D"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Rectification"
				when vla_complaint[vla_complaint.getlength()].action_flag = "I"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Inspection"
				when vla_complaint[vla_complaint.getlength()].action_flag = "H"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Hold"
				when vla_complaint[vla_complaint.getlength()].action_flag = "P"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Pending"
				when vla_complaint[vla_complaint.getlength()].action_flag = "R"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Request Agreement"
				when vla_complaint[vla_complaint.getlength()].action_flag = "N"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"No Further Action"
			end case
			if length(vlr_comp_save.date_closed)
			then
				let vla_complaint[vla_complaint.getlength()].status = "CLOSED"
				let vla_complaint_color[vla_complaint.getlength()].status =
																					"reverse red"
			else
				let vla_complaint[vla_complaint.getlength()].status = "RUNNING"
				let vla_complaint_color[vla_complaint.getlength()].status =
																					"reverse green"
			end if
		end foreach
		declare c_destination_list cursor for
			select destination_comp from comp_links
				where source_comp = vr_comp.complaint_no
				order by destination_comp
		foreach c_destination_list into vl_complaint_no
			call vla_complaint.appendelement()
			call vla_complaint_color.appendelement()
			let vla_complaint[vla_complaint.getlength()].relationship =
																				"DESTINATION"
			let vla_complaint[vla_complaint.getlength()].complaint_no =
																				vl_complaint_no
			select * into vlr_comp_save.* from comp
				where complaint_no =
						vla_complaint[vla_complaint.getlength()].complaint_no
			let vla_complaint[vla_complaint.getlength()].service_c =
																		vlr_comp_save.service_c
			if length(vlr_comp_save.build_no)
			then
				let vla_complaint[vla_complaint.getlength()].address =
														vlr_comp_save.build_no clipped,
														" ",
														vlr_comp_save.location_name clipped
			else
				let vla_complaint[vla_complaint.getlength()].address =
																	vlr_comp_save.location_name
			end if
			let vla_complaint[vla_complaint.getlength()].date_entered =
																		vlr_comp_save.date_entered
			let vla_complaint[vla_complaint.getlength()].comp_code =
																		vlr_comp_save.comp_code
			let vla_complaint[vla_complaint.getlength()].action_flag =
																		vlr_comp_save.action_flag
			case
				when vla_complaint[vla_complaint.getlength()].action_flag = "W"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Works Order"
				when vla_complaint[vla_complaint.getlength()].action_flag = "D"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Rectification"
				when vla_complaint[vla_complaint.getlength()].action_flag = "I"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Inspection"
				when vla_complaint[vla_complaint.getlength()].action_flag = "H"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Hold"
				when vla_complaint[vla_complaint.getlength()].action_flag = "P"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Pending"
				when vla_complaint[vla_complaint.getlength()].action_flag = "R"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"Request Agreement"
				when vla_complaint[vla_complaint.getlength()].action_flag = "N"
					let vla_complaint[vla_complaint.getlength()].det_action_desc =
																		"No Further Action"
			end case
			if length(vlr_comp_save.date_closed)
			then
				let vla_complaint[vla_complaint.getlength()].status = "CLOSED"
				let vla_complaint_color[vla_complaint.getlength()].status =
																					"reverse red"
			else
				let vla_complaint[vla_complaint.getlength()].status = "RUNNING"
				let vla_complaint_color[vla_complaint.getlength()].status =
																					"reverse green"
			end if
		end foreach
		let vl_complaint_no = 0

		if vla_complaint.getlength()
		then
			open window iw_related with form "replicated_comps"
			display by name vr_comp.complaint_no,
								vr_comp.service_c,
								vr_comp.date_entered,
								vr_comp.comp_code,
								vr_comp.action_flag

			case vr_comp.action_flag
				when "W"
					display "Works Order" to action_desc
				when "D"
					display "Rectification" to action_desc
				when "I"
					display "Inspection" to action_desc
				when "H"
					display "Hold" to action_desc
				when "P"
					display "Pending" to action_desc
				when "R"
					display "Request Agreement" to action_desc
				when "N"
					display "No Further Action" to action_desc
				otherwise
					display " " to action_desc
			end case
			if length(vr_comp.build_no)
			then
				let vl_address = vr_comp.build_no clipped,
										" ",
										vr_comp.location_name clipped
			else
				let vl_address = vr_comp.location_name
			end if
			display vl_address to head_address
			if length(vr_comp.date_closed)
			then
				display "CLOSED" to head_status
									attribute(reverse,red)
			else
				display "RUNNING" to head_status
									attribute(reverse,green)
			end if

			dialog attributes(unbuffered)
				display array vla_complaint to sa_complaint_list.*
					before row
						let vl_ac = arr_curr()
						message "Enquiry ", vl_ac using "<<<<&", " of ",
									vla_complaint.getlength() using "<<<<&"
				end display

				on action accept
					let vl_exit_flag = true
					exit dialog

				on action cancel
					let vl_exit_flag = true
					exit dialog

				on action close
					let vl_exit_flag = true
					exit dialog

				on action detail
					let vl_complaint_no = vla_complaint[vl_ac].complaint_no
					let vl_runstr = 
						"exec fglgo_complain X X X X X ", vl_complaint_no
					call os_exec(vl_runstr, false)
					exit dialog

				before dialog
					call dialog.setArrayAttributes
									("sa_complaint_list", vla_complaint_color)

			end dialog
			close window iw_related
			if vl_exit_flag
			then
				exit while
			end if
		else
			call valid_error("","No replicated enquiry details exist","")
			exit while
		end if
	end while
end function


function get_repl_info(vl_disp_flag)
	define
		vl_disp_flag,
		vl_count,
		vl_related_count	integer

	select count(*) into vl_related_count from comp_links
		where source_comp = vr_comp.complaint_no
	select count(*) into vl_count from comp_links
		where destination_comp = vr_comp.complaint_no
	let vg_related_count = vl_related_count + vl_count

	if vl_disp_flag
	then
		display vg_related_count to related_flag
	end if

end function


function add_comp_while_loop()
	define
		vl_trade_site_no	like agreement.site_ref,
		vl_comp_code		char(10),
		vl_centre_code		char(10),
		vl_mess				char(80),
		vl_search			char(80),
		vl_comp_code_flag	smallint,
		vl_exit_flag	char(1)

	while true 
		let vl_comp_code = "*", vr_comp.comp_code clipped, ",*"
		case 
			when vg_ms_installation = "Y"
					and vg_ms_fault_codes matches vl_comp_code
					and length(vr_comp.comp_code)
				call add_measurement_complain(vl_comp_code_flag)
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					let vl_comp_code_flag = false
					continue while
				else
					if vl_exit_flag = "S"
					then
						let vl_comp_code_flag = true
						continue while
					else
						return
					end if
				end if

			when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "N"
					and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
				if vg_sched_collect_items = "Y"
				then
					call add_sched_item_complain()
						returning vl_exit_flag
				else
					call add_sched_complain()
						returning vl_exit_flag
				end if
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_sched_service
					and vg_sched_installation = "Y"
					and vg_weee_installation = "Y"
					and skey_check("SCHED_COMP_SCREEN", "ALL") = "Y"
				if vg_sched_collect_items = "Y"
				then
					call add_weee_sched_item_complain("")
						returning vl_exit_flag
				else
					call add_weee_sched_complain("")
						returning vl_exit_flag
				end if
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_nappy_service
					and vg_nappy_installation = "Y"
				call add_nappy_complain("")
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_clin_service
					and vg_clin_installation = "Y"
				call add_clin_complain("")
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_weee_service
					and vg_weee_installation = "Y"
				call add_weee_complain("")
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_weee_sales_service
					and vg_sales_installation = "Y"
#				if skey_check("WEEE_ENTITLEMENT", "ALL") = "Y"
				if vg_weee_sales_entitlement = "Y"
				then
#					call add_weee_sales_ent_complain("")
#						returning vl_exit_flag
					call add_weee_sales_ent_complain(vl_centre_code)
						returning vl_exit_flag, vl_centre_code
				else
#					call add_weee_sales_complain("")
#						returning vl_exit_flag
					call add_weee_sales_complain(vl_centre_code)
						returning vl_exit_flag, vl_centre_code
				end if
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_trade_service
					and vg_trade_installation = "Y"
				if vg_agreement_no then
					select site_ref into vl_trade_site_no
						from agreement
						where agreement_no = vg_agreement_no
					call add_trade_complain(vl_trade_site_no,vg_agreement_no)
						returning vl_exit_flag
				else
					call add_trade_complain("","")
						returning vl_exit_flag
				end if
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_enf_service
					and vg_enf_installation = "Y"
				if quiet_allow("enf_add_upd")
				and not vg_enforce_ref # cannot raise enforcement from enforcement
				then
					call add_enf_complain(0)
						returning vl_exit_flag
					if vl_exit_flag = "C"
					then
						continue while
					else
						return
					end if
				else
					let vr_comp.service_c = vg_default_service
					continue while
				end if
#ADJ ENFTR			
			when vr_comp.service_c = vg_enf_trade_service
					and vg_enf_trade_installation = "Y"
				if quiet_allow("enf_add_upd")
				and not vg_enforce_ref # cannot raise enforcement from enforcement
				then
					call add_enf_trade_complain(0)
						returning vl_exit_flag
					if vl_exit_flag = "C"
					then
						continue while
					else
						return
					end if
				else
					let vr_comp.service_c = vg_default_service
					continue while
				end if

			when vr_comp.service_c = vg_av_service
					and vg_av_installation = "Y"
				call add_av_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_hway_service
				and vg_hway_installation = "Y"
				call add_hway_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_sl_service
				and vg_sl_installation = "Y"
				call add_sl_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

#ADJ211003GM
			when vr_comp.service_c = vg_gm_service
				and vg_gm_installation = "Y"
				call add_gm_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
#ADJ138104ERT
			when vr_comp.service_c = vg_ert_service
				and vg_ert_installation = "Y"
				and skey_check("ERT_COMPLAINTS", "ALL") = "Y"
				call add_ert_complain()
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if
#ADJTREES120104
			when vr_comp.service_c = vg_trees_service
				and vg_trees_installation = "Y"
				call add_tree_complain("", "")
					returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			when vr_comp.service_c = vg_agreq_service
					and vg_agreq_installation = "Y"
				call add_agreq_complain()
						returning vl_exit_flag
				if vl_exit_flag = "C"
				then
					continue while
				else
					return
				end if

			otherwise
				# Just make sure the service exists then normal add
				let vl_search = "keys.service_c = '", 
								vr_comp.service_c clipped, "'"

				if no_of_rows("keys", vl_search, "") = 0
				then 
					let vl_mess = " The Service code ", vr_comp.service_c, 
						" does not exist" 
					call valid_error("",vl_mess,"")
					return
				else
					call add_normal_complain(vl_comp_code_flag)
						returning vl_exit_flag
					if vl_exit_flag = "C"
					then
						let vl_comp_code_flag = FALSE
                        #LET vg_new_flycomp = FALSE
						continue while
					else
						if vl_exit_flag = "S"
						then
							let vl_comp_code_flag = true
							continue while
						else
							return
						end if
					end if
				end if
		end case

		exit while

	end while 
end function


function load_av_status_array()
	define
		vlr_comp_av_hist		record like comp_av_hist.*,
		vl_count					integer

	call va_av_status.clear()

	initialize vlr_comp_av_hist.* to null

	if vr_comp.service_c = vg_av_service
	and vg_av_installation = "Y"
	then
		declare c_load_av_status cursor for
			select * from comp_av_hist
				where complaint_no = vr_comp.complaint_no
				and comp_av_hist.status_ref not in ('LOC_CH', 'OFF_CH')
				order by seq

		foreach c_load_av_status into vlr_comp_av_hist.*
			call va_av_status.appendelement()
			let va_av_status[va_av_status.getLength()].av_status_ref =
																	vlr_comp_av_hist.status_ref
			select description into
								va_av_status[va_av_status.getLength()].av_status_desc
				from av_status
				where status_ref = vlr_comp_av_hist.status_ref
			let va_av_status[va_av_status.getLength()].av_username =
																	vlr_comp_av_hist.username
			let va_av_status[va_av_status.getLength()].av_status_date =
																	vlr_comp_av_hist.status_date
			if length(vlr_comp_av_hist.status_time_h)
			or length(vlr_comp_av_hist.status_time_m)
			then
				let va_av_status[va_av_status.getLength()].av_status_time =
														vlr_comp_av_hist.status_time_h, ":",
														vlr_comp_av_hist.status_time_m
			end if
			let va_av_status[va_av_status.getLength()].av_position =
															vlr_comp_av_hist.vehicle_position
			let va_av_status[va_av_status.getLength()].av_notes =
																	vlr_comp_av_hist.notes
		end foreach
	end if
end function


function set_vg_act(vl_act)
	define vl_act	char(1)

	let vg_act = vl_act
end FUNCTION


FUNCTION record_nfa_text(vl_complaint_no)
# BJG 14/04/2011 - If we are here the action_flag must have changed, and
#                  is now "N" we need to save a new text line to detail who
#                  set this action
    DEFINE
        vl_complaint_no     LIKE comp.complaint_no,
        vlr_user_info       RECORD LIKE user_info.*,
        vlr_comp            RECORD LIKE comp.*,
        vl_user             LIKE user_info.username,
        vl_seq              integer,
        vl_txt1             LIKE comp_text.txt,
        vl_txt2             LIKE comp_text.txt,
        vl_txt              char(100),
        vl_null             INTEGER

    IF skey_check("COMP_NFA_TEXT","ALL") = "N"
    THEN
        return 
    END IF
    INITIALIZE vl_null TO null
    LET vl_user = upshift(vg_username)
    INITIALIZE vlr_user_info.* TO NULL
    LET vlr_user_info.fullname = upshift(vl_user)
    SELECT * INTO vlr_user_info.* FROM user_info
        WHERE username = vg_username

    SELECT * INTO vlr_comp.* FROM comp
        WHERE complaint_no = vl_complaint_no

    IF STATUS = NOTFOUND
    OR length(vlr_comp.date_closed) = 0
    OR length(vlr_comp.time_closed_h) = 0
    OR length(vlr_comp.time_closed_m) = 0
    THEN
		let vlr_comp.date_closed = today
		let vlr_comp.time_closed_h = 
			extend(current, hour to hour)
		let vlr_comp.time_closed_m = 
			extend(current, minute to minute)
    END IF

    SELECT MAX(seq) INTO vl_seq FROM comp_text
        WHERE complaint_no = vl_complaint_no

    IF NOT vl_seq
    OR NOT length(vl_seq)
    THEN
        LET vl_seq = 1
    ELSE
        LET vl_seq = vl_seq + 1
    END IF

    LET vl_txt = "Enquiry set to NO FURTHER ACTION by ", upshift(vlr_user_info.fullname)
	call format_field(60,2,vl_txt)
		returning vl_txt1,
					vl_txt2,
					vg_null_val, vg_null_val, vg_null_val
    INSERT INTO comp_text
        (
        complaint_no,
        seq,
        username,
        doa,
        time_entered_h,
        time_entered_m,
        txt,
        customer_no
        )
        VALUES
        (
        vl_complaint_no,
        vl_seq,
        vl_user,
        vlr_comp.date_closed,
        vlr_comp.time_closed_h,
        vlr_comp.time_closed_m,
        vl_txt1,
        vl_null
        )

    IF length(vl_txt2)
    THEN
        LET vl_seq = vl_seq + 1
        INSERT INTO comp_text
        (
        complaint_no,
        seq,
        username,
        doa,
        time_entered_h,
        time_entered_m,
        txt,
        customer_no
        )
        VALUES
        (
        vl_complaint_no,
        vl_seq,
        vl_user,
        vlr_comp.date_closed,
        vlr_comp.time_closed_h,
        vlr_comp.time_closed_m,
        vl_txt2,
        vl_null
        )
    END IF 
        
	update comp 
		set text_flag = "Y"
		where complaint_no = vl_complaint_no
END FUNCTION

FUNCTION record_reopen_text(vl_complaint_no)
# BJG 14/04/2011 - If we are here the action_flag must have changed, and
#                  is now no longer "N" we need to save a new text line to detail who
#                  set this as re-opened
    DEFINE
        vl_complaint_no     LIKE comp.complaint_no,
        vlr_user_info       RECORD LIKE user_info.*,
        vlr_comp            RECORD LIKE comp.*,
        vl_user             LIKE user_info.username,
        vl_seq              integer,
        vl_txt1             LIKE comp_text.txt,
        vl_txt2             LIKE comp_text.txt,
        vl_txt              char(100),
        vl_null             INTEGER

    IF skey_check("COMP_NFA_TEXT","ALL") = "N"
    THEN
        return 
    END IF
    INITIALIZE vl_null TO null
    LET vl_user = upshift(vg_username)
    INITIALIZE vlr_user_info.* TO NULL
    LET vlr_user_info.fullname = upshift(vl_user)
    SELECT * INTO vlr_user_info.* FROM user_info
        WHERE username = vg_username

    SELECT * INTO vlr_comp.* FROM comp
        WHERE complaint_no = vl_complaint_no

    IF STATUS = NOTFOUND
    OR length(vlr_comp.date_closed) = 0
    OR length(vlr_comp.time_closed_h) = 0
    OR length(vlr_comp.time_closed_m) = 0
    THEN
		let vlr_comp.date_closed = today
		let vlr_comp.time_closed_h = 
			extend(current, hour to hour)
		let vlr_comp.time_closed_m = 
			extend(current, minute to minute)
    END IF

    SELECT MAX(seq) INTO vl_seq FROM comp_text
        WHERE complaint_no = vl_complaint_no

    IF NOT vl_seq
    OR NOT length(vl_seq)
    THEN
        LET vl_seq = 1
    ELSE
        LET vl_seq = vl_seq + 1
    END IF

    LET vl_txt = "Enquiry has been RE-OPENED by ", upshift(vlr_user_info.fullname)
	call format_field(60,2,vl_txt)
		returning vl_txt1,
					vl_txt2,
					vg_null_val, vg_null_val, vg_null_val
    INSERT INTO comp_text
        (
        complaint_no,
        seq,
        username,
        doa,
        time_entered_h,
        time_entered_m,
        txt,
        customer_no
        )
        VALUES
        (
        vl_complaint_no,
        vl_seq,
        vl_user,
        vlr_comp.date_closed,
        vlr_comp.time_closed_h,
        vlr_comp.time_closed_m,
        vl_txt,
        vl_null
        )

    IF length(vl_txt2)
    THEN
        LET vl_seq = vl_seq + 1
        INSERT INTO comp_text
        (
        complaint_no,
        seq,
        username,
        doa,
        time_entered_h,
        time_entered_m,
        txt,
        customer_no
        )
        VALUES
        (
        vl_complaint_no,
        vl_seq,
        vl_user,
        vlr_comp.date_closed,
        vlr_comp.time_closed_h,
        vlr_comp.time_closed_m,
        vl_txt2,
        vl_null
        )
    END IF 
        
	update comp 
		set text_flag = "Y"
		where complaint_no = vl_complaint_no
END FUNCTION
                            
# End of complain.4gl __________________________________________________________

