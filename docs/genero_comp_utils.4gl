# comp_utils.4gl " Version 6.32"

# Contender V6

# Modified:
# 02/10/03  KJ  V6.22	Islington AV upgrade: av_qrycomp_b.per for "Brent".

database universe

globals "../UTILS/globals.4gl"

define
	vg_title						char(80),
	s_normalform_open			smallint,
	s_sched_form_open			smallint,
	s_weee_sched_form_open	smallint,
	s_trform_open				smallint,
	s_agreqform_open			smallint,
	s_npform_open				smallint,
	s_clform_open				smallint,
	s_avform_open				smallint,
	s_hwayform_open			smallint,
	s_slform_open				smallint,
	s_enfform_open				smallint,
	s_enftrform_open			smallint,
	s_weeeform_open			smallint,
	s_gmform_open				smallint,
	s_ertform_open				smallint,
	s_treeform_open			smallint,
	s_measurementform_open	smallint,
	s_weee_sales_form_open	smallint

define w	ui.Window
define f	ui.Form


function qrycomp_of()

	if not m_normalform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","generic_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_normalform_open = true
	end if
end function


function qrycomp_cf()
	whenever error continue
	close window iw_complain
	whenever error stop
end function


function sched_qrycomp_of()
	if not m_sched_form_open
	then
		#ADJ DEBUG
		#current window is iw_complain
		#call close_forms()
		#open form if_qry_sched_comp from "qry_sched_comp"
		#display form if_qry_sched_comp

		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_sched")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("sched_page",false)
		call f.setElementHidden("formonly.prev_collects_title",true)
		call f.setElementHidden("formonly.prev_collections",true)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","sched_page")

#		display "Reference" to reference_label
#		display "Prev.Collects" to prev_collects_title
		call complain_labels()
		let m_sched_form_open = true
	end if
end function


function sched_qrycomp_cf()
end function


function weee_sched_qrycomp_of()
	if not m_weee_sched_form_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_weee_sched")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("sched_page",false)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","sched_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_weee_sched_form_open = true
	end if
end function


function weee_sched_qrycomp_cf()
end function


function tr_qrycomp_of()
	if not m_trform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_trade")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

		# Address box
		call f.setElementHidden("trade_address",false) 
		call f.setElementHidden("generic_address",true) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",false)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",false)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("trade_page",false)
		call f.setElementHidden("trade_details_page",false)
		call f.setElementHidden("debtor_page",false)
		call f.setElementHidden("trade_site_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","trade_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_trform_open = true
	end if
end function


function tr_qrycomp_cf()
end function


function agreq_qrycomp_of()
	if not m_agreqform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_agreq")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

		# Address box
		call f.setElementHidden("trade_address",false) 
		call f.setElementHidden("generic_address",true) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",false)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",false)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("agreq_page",false)
		call f.setElementHidden("debtor_page",false)
		call f.setElementHidden("trade_site_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("enf_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","agreq_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_agreqform_open = true
	end if

end function


function agreq_qrycomp_cf()
end function


function np_qrycomp_of()
	if not m_npform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_nappy")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

		# Address box
		call f.setElementHidden("nappy_address",false) 
		call f.setElementHidden("generic_address",true) 
		call f.setElementHidden("clin_address",true) 
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
		display "Enquiries" to enquiries_title

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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","generic_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_npform_open = true
	end if
end function


function np_qrycomp_cf()
end function


function cl_qrycomp_of()
	if not m_clform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_clin")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

		# Address box
		call f.setElementHidden("clin_address",false) 
		call f.setElementHidden("generic_address",true) 
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
		display "Enquiries" to enquiries_title

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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","generic_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_clform_open = true
	end if
end function


function cl_qrycomp_cf()
end function


function av_qrycomp_of()
	define 
		vl_char_6	char(7),
		vl_char_13	char(13),
		vg_title	char(80)
	if not m_avform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_av")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",false)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",false)
		call f.setElementHidden("formonly.history_title",false)
		call f.setElementHidden("formonly.enquiries_title",false)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("av_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","av_page")

#		display "History" to history_title
#		display "Reference" to reference_label
		call complain_labels()
		let m_avform_open = true
	end if	
end function


function hway_qrycomp_of()
	if not m_hwayform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_hway")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("hway_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","hway_page")


#		display "Reference" to reference_label
		call complain_labels()
		let m_hwayform_open = true
	end if
end function


function sl_qrycomp_of()
	if not m_slform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_sl")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("sl_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("enf_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","sl_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_slform_open = true
	end if
end function


function enf_qrycomp_of()
	define 
		vg_title	char(80)

	if not m_enfform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_enf")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",false)
		call f.setElementHidden("comp_enf.actions",false)
		call f.setElementHidden("formonly.evidence_flag",false)
		call f.setElementHidden("formonly.alt_location",false)
		call f.setElementHidden("formonly.history_title",false)
		call f.setElementHidden("formonly.enquiries_title",false)
		call f.setElementHidden("formonly.actions_title",false)
		call f.setElementHidden("formonly.evidence_title",false)

		display "History" to history_title
		display "Enquiries" to enquiries_title
		display "Actions" to actions_title
		display "Evidence" to evidence_title

		# Screen Tabs 
		call f.setElementHidden("enf_page",false)
		call f.setElementHidden("actions_page",false)
		call f.setElementHidden("action_text_page",false)
		call f.setElementHidden("suspect_page",false)
		call f.setElementHidden("evidence_page",false)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		if NOT check_install("ENF_COST") then
			call f.setElementHidden("costs_page",true) 
		else	
			call f.setElementHidden("costs_page",false) 
		end if

		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","enf_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_enfform_open = true
	end if
end function


function enf_trade_qrycomp_of()
	define 
		vg_title	char(80)

	if not m_enftrform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_trade_enf")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

		# Address box
		call f.setElementHidden("trade_address",false) 
		call f.setElementHidden("generic_address",true) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",false)
		call f.setElementHidden("comp_enf.actions",false)
		call f.setElementHidden("formonly.evidence_flag",false)
		call f.setElementHidden("formonly.alt_location",false)
		call f.setElementHidden("formonly.history_title",false)
		call f.setElementHidden("formonly.enquiries_title",false)
		call f.setElementHidden("formonly.actions_title",false)
		call f.setElementHidden("formonly.evidence_title",false)

		display "History" to history_title
		display "Enquiries" to enquiries_title
		display "Actions" to actions_title
		display "Evidence" to evidence_title

		# Screen Tabs 
		call f.setElementHidden("enf_page",false)
		call f.setElementHidden("actions_page",false)
		call f.setElementHidden("action_text_page",false)
		call f.setElementHidden("suspect_page",false)
		call f.setElementHidden("evidence_page",false)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		if NOT check_install("ENF_COST") then
			call f.setElementHidden("costs_page",true) 
		else	
			call f.setElementHidden("costs_page",false) 
		end if

		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","enf_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_enftrform_open = true
	end if
end function


function weee_qrycomp_of()
	if not m_weeeform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_weee")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("weee_page",false)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("enf_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","weee_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_weeeform_open = true
	end if
end function


function gm_qrycomp_of()
	if not m_gmform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_gm")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("gm_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","gm_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_gmform_open = true
	end if
end function


function ert_qrycomp_of()
	if not m_ertform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_ert")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("ert_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","ert_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_ertform_open = true
	end if
end function


function tree_qrycomp_of()
	if not m_treeform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_tree")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("tree_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","tree_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_treeform_open = true
	end if
end function


function tree_qrycomp_cf()
end function


function weee_sales_qrycomp_of()
	define
		vl_proof_title		char(10)

	if not m_weee_sales_form_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_weee_sales")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("weee_sales_ent_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","weee_sales_ent_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_weee_sales_form_open = true
	end if
end function


function weee_sales_ent_qrycomp_of()
	define
		vl_proof_title		char(10)

	if not m_weee_sales_form_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_weee_sales")

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("weee_sales_ent_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","weee_sales_ent_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_weee_sales_form_open = true
	end if
end function


function measurement_qrycomp_of()
	if not m_measurementform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.loadTopMenu("complain_query_measurement")
        IF NOT check_install("BSP")
        THEN
            CALL gl_hideTopMenuCommand("bsp", true)
        END IF 
        IF NOT check_install("GIS")
        THEN
            CALL gl_hideTopMenuCommand("gis", true)
        END IF 

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
		display "Enquiries" to enquiries_title

		# Screen Tabs 
		call f.setElementHidden("meas_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("enf_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("text_query_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",false)
        call gl_showpage("fold","meas_page")

#		display "Reference" to reference_label
		call complain_labels()
		let m_measurementform_open = true
	end if
end function


function reset_comp_form_variables()	
	let m_normalform_open = false
	let m_sched_form_open = false
	let m_weee_sched_form_open = false
	let m_trform_open = false
	let m_agreqform_open = false
	let m_npform_open = false
	let m_clform_open = false
	let m_avform_open = false
	let m_hwayform_open = false
	let m_slform_open = false
	let m_enfform_open = false
	let m_enftrform_open = false
	let m_weeeform_open = false
	let m_gmform_open = false
	let m_ertform_open = false
	let m_treeform_open = false
	let m_measurementform_open = false
	let m_weee_sales_form_open = FALSE
    LET vg_new_flycomp=true
end function


function save_comp_form_variables()	
	let s_normalform_open = m_normalform_open
	let s_sched_form_open = m_sched_form_open
	let s_weee_sched_form_open = m_weee_sched_form_open
	let s_trform_open = m_trform_open
	let s_agreqform_open = m_agreqform_open
	let s_npform_open = m_npform_open
	let s_clform_open = m_clform_open
	let s_avform_open = m_avform_open
	let s_hwayform_open = m_hwayform_open
	let s_slform_open = m_slform_open
	let s_enfform_open = m_enfform_open
	let s_enftrform_open = m_enftrform_open
	let s_weeeform_open = m_weeeform_open
	let s_gmform_open = m_gmform_open
	let s_ertform_open = m_ertform_open
	let s_treeform_open = m_treeform_open
	let s_measurementform_open = m_measurementform_open
	let s_weee_sales_form_open = m_weee_sales_form_open
end function


function restore_comp_form_variables()	
	let m_normalform_open = s_normalform_open
	let m_sched_form_open = s_sched_form_open
	let m_weee_sched_form_open = s_weee_sched_form_open
	let m_trform_open = s_trform_open
	let m_agreqform_open = s_agreqform_open
	let m_npform_open = s_npform_open
	let m_clform_open = s_clform_open
	let m_avform_open = s_avform_open
	let m_hwayform_open = s_hwayform_open
	let m_slform_open = s_slform_open
	let m_enfform_open = s_enfform_open
	let m_enftrform_open = s_enftrform_open
	let m_weeeform_open = s_weeeform_open
	let m_gmform_open = s_gmform_open
	let m_ertform_open = s_ertform_open
	let m_treeform_open = s_treeform_open
	let m_measurementform_open = s_measurementform_open
	let m_weee_sales_form_open = s_weee_sales_form_open
end function


function add_enf_cost_admin(vl_complaint_no)
	define
		vl_complaint_no		like comp.complaint_no,
		vlr_enf_cost_trans	record like enf_cost_trans.*

	initialize vlr_enf_cost_trans.* to null
	let vlr_enf_cost_trans.complaint_no = vl_complaint_no
	let vlr_enf_cost_trans.rate_code = skey_check("ENF_COST_ADMIN_CODE","ALL")
	let vlr_enf_cost_trans.qty = 1
	select unit_price, description
		into vlr_enf_cost_trans.unit_price,
				vlr_enf_cost_trans.text
		from enf_cost_rates
		where rate_code = vlr_enf_cost_trans.rate_code
	let vlr_enf_cost_trans.value = vlr_enf_cost_trans.unit_price
	let vlr_enf_cost_trans.username = get_user()
	let vlr_enf_cost_trans.cost_date = today
	let vlr_enf_cost_trans.cost_time_h = extend(current, hour to hour)
	let vlr_enf_cost_trans.cost_time_m = extend(current, minute to minute)
	select max(sequence) into vlr_enf_cost_trans.sequence
		from enf_cost_trans
		where complaint_no = vl_complaint_no
	if vlr_enf_cost_trans.sequence = 0
	or length(vlr_enf_cost_trans.sequence) = 0
	then
		let vlr_enf_cost_trans.sequence = 1
	else
		let vlr_enf_cost_trans.sequence = vlr_enf_cost_trans.sequence + 1
	end if
	insert into enf_cost_trans values(vlr_enf_cost_trans.*)
end function


function add_comp_of()
	call set_add_comp_options()

	if not m_normalform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)
		call f.setElementHidden("text_query_page",true)

		call complain_labels()
		let m_normalform_open = true
	end if
end function


function add_sched_comp_of()
	call set_add_comp_options()

	if not m_sched_form_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("sched_page",false)
		call f.setElementHidden("formonly.prev_collects_title",false)
		call f.setElementHidden("formonly.prev_collections",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		display "Prev.Collects" to prev_collects_title
		call complain_labels()
		let m_sched_form_open = true
	end if
end function


function add_schedcomp_cf()
end function


function add_weee_sched_comp_of()
	call set_add_comp_options()

	if not m_sched_form_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("sched_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_sched_form_open = true
	end if
end function


function weee_sched_addcomp_of()
	call set_add_comp_options()
	if not m_weee_sched_form_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("sched_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_weee_sched_form_open = true
	end if
end function


function weee_sched_addcomp_cf()
end function


function trade_add_of()
	call set_add_comp_options()
	if not m_trform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("trade_address",false) 
		call f.setElementHidden("generic_address",true) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("trade_page",false)
		call f.setElementHidden("trade_details_page",false)
		call f.setElementHidden("debtor_page",false)
		call f.setElementHidden("trade_site_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_trform_open = true
	end if
end function


function tr_addcomp_cf()
end function


function agreq_add_of()
	call set_add_comp_options()
	if not m_agreqform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("trade_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("generic_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("agreq_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("enf_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

#		display "Reference" to reference_label
		call complain_labels()
		let m_agreqform_open = true
	end if
end function


function agreq_add_cf()
end function


function nappy_add_of()
	call set_add_comp_options()
	if not m_npform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("nappy_address",false) 
		call f.setElementHidden("generic_address",true) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_npform_open = true
	end if
end function


function np_add_cf()
end function


function clin_add_of()
	call set_add_comp_options()
	if not m_clform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("clin_address",false) 
		call f.setElementHidden("generic_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_clform_open = true
	end if
end function


function cl_add_cf()
end function


function av_add_of()
	define 
		vl_char_6	char(7),
		vl_char_13	char(13),
		vg_title	char(80)

	call set_add_comp_options()
	if not m_avform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("av_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_avform_open = true
	end if	
end function


function av_add_cf()
end function


function hway_add_of()
	call set_add_comp_options()
	if not m_hwayform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("hway_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_hwayform_open = true
	end if
end function


function hway_add_cf()
end function


function sl_add_of()
	call set_add_comp_options()
	if not m_slform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("sl_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("enf_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_slform_open = true
	end if
end function


function enf_add_of()
	define 
		vg_title	char(80)

	call set_add_comp_options()

	if not m_enfform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()
		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)

		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("enf_page",false)
		call f.setElementHidden("evidence_page",false)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("costs_page",true) 

		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_enfform_open = true
	end if
end function


function enf_trade_add_of()
	define 
		vg_title	char(80)

	call set_add_comp_options()

	if not m_enftrform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("trade_address",false) 
		call f.setElementHidden("generic_address",true) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		display "History" to history_title
		display "Enquiries" to enquiries_title
		display "Actions" to actions_title
		display "Evidence" to evidence_title

		# Screen Tabs 
		call f.setElementHidden("enf_page",false)
		call f.setElementHidden("actions_page",false)
		call f.setElementHidden("action_text_page",false)
		call f.setElementHidden("suspect_page",false)
		call f.setElementHidden("evidence_page",false)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		if NOT check_install("ENF_COST") then
			call f.setElementHidden("costs_page",true) 
		else	
			call f.setElementHidden("costs_page",false) 
		end if

		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("meas_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_enftrform_open = true
	end if
end function


function weee_add_of()
	call set_add_comp_options()

	if not m_weeeform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("weee_page",false)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_weeeform_open = true
	end if
end function


function weee_add_cf()
end function


function gm_add_of()
	call set_add_comp_options()

	if not m_gmform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("gm_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_gmform_open = true
	end if
end function


function ert_add_of()
	call set_add_comp_options()

	if not m_ertform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("ert_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
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
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_ertform_open = true
	end if
end function


function ert_add_cf()
end function


function tree_add_of()
	call set_add_comp_options()

	if not m_treeform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("tree_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_treeform_open = true
	end if
end function


function weee_sales_add_of()
	define
		vl_proof_title		char(10)

	call set_add_comp_options()

	if not m_weee_sales_form_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("weee_sales_ent_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_weee_sales_form_open = true
	end if
end function


function weee_sales_ent_add_of()
	define
		vl_proof_title		char(10)

	call set_add_comp_options()

	if not m_weee_sales_form_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("weee_sales_ent_page",false)
		call f.setElementHidden("generic_page",true)
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
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_weee_sales_form_open = true
	end if
end function


function measurement_add_of()
	call set_add_comp_options()

	if not m_measurementform_open
	then
		call reset_comp_form_variables()	

		let w = ui.Window.getCurrent()
		let f = w.getForm()

		# Address box
		call f.setElementHidden("generic_address",false) 
		call f.setElementHidden("clin_address",true) 
		call f.setElementHidden("nappy_address",true) 
		call f.setElementHidden("trade_address",true) 

		# Status and flags box
		call f.setElementHidden("formonly.related_flag",true)
		call f.setElementHidden("comp_enf.actions",true)
		call f.setElementHidden("formonly.evidence_flag",true)
		call f.setElementHidden("formonly.alt_location",true)
		call f.setElementHidden("formonly.history_title",true)
		call f.setElementHidden("formonly.enquiries_title",true)
		call f.setElementHidden("formonly.actions_title",true)
		call f.setElementHidden("formonly.evidence_title",true)

		# Screen Tabs 
		call f.setElementHidden("meas_page",false)
		call f.setElementHidden("generic_page",true)
		call f.setElementHidden("av_page",true)
		call f.setElementHidden("gm_page",true)
		call f.setElementHidden("ert_page",true)
		call f.setElementHidden("hway_page",true)
		call f.setElementHidden("trade_page",true)
		call f.setElementHidden("trade_details_page",true)
		call f.setElementHidden("agreq_page",true)
		call f.setElementHidden("enf_page",true)
		call f.setElementHidden("sl_page",true)
		call f.setElementHidden("tree_page",true)
		call f.setElementHidden("weee_page",true)
		call f.setElementHidden("weee_sales_ent_page",true)
		call f.setElementHidden("sched_page",true)
		call f.setElementHidden("works_order_page",true)
		call f.setElementHidden("rectifications_page",true)
		call f.setElementHidden("import_page",true)
		call f.setElementHidden("debtor_page",true)
		call f.setElementHidden("trade_site_page",true)
		call f.setElementHidden("actions_page",true)
		call f.setElementHidden("action_text_page",true)
		call f.setElementHidden("costs_page",true)
        call f.setElementHidden("status_page",true)
		call f.setElementHidden("suspect_page",true)
		call f.setElementHidden("evidence_page",true)
		if skey_check("USE_CORRESPONDENCE", "ALL") = "Y" then
			call f.setElementHidden("correspondence_page",false)
		else
			call f.setElementHidden("correspondence_page",true)
		end if
		call f.setElementHidden("attachments_page",true)

		call complain_labels()
		let m_measurementform_open = true
	end if
end function


function measurement_add_cf()
end function


function addwindow_of()
	call reset_comp_form_variables()	
	clear form

	let w = ui.Window.getCurrent()
	let f = w.getForm()
	call f.loadTopMenu("complain_add")
	call f.loadToolbar("complain_add")
    IF NOT check_install("BSP")
    THEN
        CALL gl_hideTopMenuCommand("bsp", true)
        CALL gl_hideToolBarItem("bsp", true)
    END IF 
    IF NOT check_install("GIS")
    THEN
        CALL gl_hideTopMenuCommand("gis", true)
        CALL gl_hideToolBarItem("gis", true)
    END IF 
	call f.setFieldHidden("comp.complaint_no",true)
	call f.setFieldHidden("formonly.reference_label",true)
	call f.setElementHidden("formonly.reference_label",true)

end function


function updatewindow_of()
	call reset_comp_form_variables()	
	let w = ui.Window.getCurrent()
	let f = w.getForm()
	call f.loadToolbar("complain_add")
    IF NOT check_install("BSP")
    THEN
        CALL gl_hideToolBarItem("bsp", true)
    END IF 
	call f.setFieldHidden("comp.complaint_no",true)
	call f.setFieldHidden("formonly.reference_label",true)
	call f.setElementHidden("formonly.reference_label",true)
end function


function qrywindow_of()
	call reset_comp_form_variables()	
	clear form

	let w = ui.Window.getCurrent()
	let f = w.getForm()
	call f.loadTopMenu("complain_query")
	if vg_show_update_on_toolbar = "Y"
	then
		call f.loadToolbar("complain_query")
	else
		call f.loadToolbar("complain_query_no_update")
	end if
    IF NOT check_install("BSP")
    THEN
        CALL gl_hideTopMenuCommand("bsp", true)
        CALL gl_hideToolBarItem("bsp", true)
    END IF 
    IF NOT check_install("GIS")
    THEN
        CALL gl_hideTopMenuCommand("gis", true)
        CALL gl_hideToolBarItem("gis", true)
    END IF 
	call f.setElementHidden("query_header",false) 
	call f.setElementHidden("add_header",true)
	call f.setFieldHidden("comp.complaint_no",false)
	call f.setFieldHidden("formonly.reference_label",false)
	call f.setElementHidden("formonly.reference_label",false)
	call f.setElementText("formonly.reference_label","Reference")
	display "Reference" to reference_label

end function


function get_default_allk_code(f_lookup_func)
	define
		f_lookup_func		like allk.lookup_func
end function


# A blank code returns true
function valid_allk_code (f_allk_code,f_allk_func )
	define
		f_allk_code			like allk.lookup_code,
		f_allk_func			like allk.lookup_func,
		f_ret_stat			smallint

	if not length(f_allk_code)
	then
		let f_ret_stat = true
	else
		select * 
			from allk
		where lookup_code = f_allk_code
			and lookup_func = f_allk_func
			and status_yn = "Y"

		if status = notfound
		then
			return false
		else
			return true
		end if
	end if

	return f_ret_stat

end function


# This function checks default reasons exist for linked fault codes
function check_def_alg_and_reason(vl_comp_code, 
								vl_item_ref,
								vl_feature_ref,
								vl_contract_ref)
	define
		vr_allk				record like allk.*,
		vl_comp_code		like comp.comp_code,
		vl_item_ref			like item.item_ref,
		vl_item_type		like item.item_type,
		vl_feature_ref		like feat.feature_ref,
		vl_contract_ref		like cont.contract_ref,
		vl_mess				char(200),
		vl_count			smallint,
		vl_ans				char(1)

	select status_yn
		into vl_ans
	from allk
		where lookup_func = "DEFRN"
		and lookup_code = vl_comp_code

	case vl_ans
		when "Y"
			# A code exists and is enabled
		when "N"
			let vl_mess = "The rectification reason '", vl_comp_code clipped, 
				"' exists but has been disabled."

			call valid_error("",vl_mess,"")
			return false
		otherwise
			let vl_mess = "The rectification reason '", 
				vl_comp_code clipped, 
				"' does not exist.  A rectification cannot be raised."
			call valid_error("",vl_mess,"")
			return false
	end case
	
	select item_type
		into vl_item_type
	from item
		where item_ref = vl_item_ref
		and contract_ref = vl_contract_ref

	if status = notfound
	then
		call valid_error("", 
			"A valid fault/request must be entered for the select item", "")
		return false
	end if

	select * into vr_allk.*
		from allk 
	where lookup_func = "DEFRN" 
		and status_yn = "Y"
		and lookup_code = vl_comp_code

	select count(*) 
		into vl_count
	from defa
		where notice_rep_no = vr_allk.lookup_num
			and item_type = vl_item_type

	if vl_count = 0
	then
		let vl_mess = "No algorithms exist for item:", vl_item_ref clipped,
			" and code:", vl_comp_code clipped
		call valid_error("", vl_mess, "")
		return false
	else
		return true
	end if

end function


function complain_labels()
	define 
		vl_char_10		char(10),
		vl_char_13		char(13)

	display "Reference" to reference_label
	display "History" to history_title
	display "Prev.Collects" to prev_collects_title
	display "Enquiries" to enquiries_title
	display "Actions" to actions_title
	display "Evidence" to evidence_title

	let vl_char_10 = skey_check("AV CAR ID TITLE", "ALL")
	if not length(vl_char_10)
	then
		let vl_char_10 = "Car ID"
	end if
	display vl_char_10 to reg_title

	let vl_char_13 = skey_check("AV ROADFEE TITLE","ALL")
	if not length(vl_char_13)
	then
		let vl_char_13 = "Road Fund"
	end if
	display vl_char_13 to roadfee_title
	if vg_disp_ward_or_area = "N"
	then
		display "Ward" to ward_area_title
	else
		display "Area" to ward_area_title
	end if
	display vg_position_title to position_title
	if vg_disp_townname_on_screen = "Y"
	then
		display "Town" to townname_label
		if vg_disp_county_or_postal = "Y"
		then
			display "County" to posttown_label
			display "County" to cust_posttown_label
		else
			display "Post Town" to posttown_label
			display "Post Town" to cust_posttown_label
		end if
		display "Town" to cust_townname_label
		display " 2" to trade_addr_label_2
		display " 3" to trade_addr_label_3
		display " 4" to trade_addr_label_4
	else
		let w = ui.Window.getCurrent()
		let f = w.getForm()

		call f.setFieldHidden("comp.townname",true)
		call f.setFieldHidden("comp.posttown",true)
		call f.setFieldHidden("customer.compl_addr5",true)
		call f.setFieldHidden("customer.compl_addr6",true)
		call f.setFieldHidden("formonly.trade_townname", true)
		call f.setFieldHidden("formonly.trade_posttown", true)

		call f.setElementHidden("formonly.townname_label",true)
		call f.setElementHidden("formonly.posttown_label",true)
		call f.setElementHidden("formonly.cust_townname_label",true)
		call f.setElementHidden("formonly.cust_posttown_label",true)
		call f.setElementHidden("formonly.trade_addr_label_3", true)

		display " 2" to trade_addr_label_2
		display " 3" to trade_addr_label_4
	end if 
end FUNCTION


FUNCTION form_remarks (vl_details_1, vl_details_2, vl_details_3)

    DEFINE
        vl_details_1    LIKE comp.details_1,
        vl_details_2    LIKE comp.details_2,
        vl_details_3    LIKE comp.details_3,
        remarks_line    char(210),
        vl_length_1     integer,
        vl_length_2     integer,
        vl_length_3     INTEGER

    LET vl_length_1 = length(vl_details_1)
    LET vl_length_2 = length(vl_details_2)
    LET vl_length_3 = length(vl_details_3)

    INITIALIZE remarks_line TO NULL

    IF vl_length_1 = 0
    AND vl_length_2 = 0
    AND vl_length_3 = 0
    THEN
        RETURN remarks_line
    END IF

    IF vl_length_1
    AND vl_details_1[vl_length_1] != "\n"
#    AND vl_length_1 < 70
    THEN
        LET remarks_line = vl_details_1 clipped, " ", vl_details_2
    ELSE
        LET remarks_line = vl_details_1 clipped, vl_details_2
    END IF

    IF vl_length_2
    AND vl_length_2 > 0
    THEN
        IF vl_details_2[vl_length_2] != "\n"
#        AND vl_length_2 < 70
        THEN
            LET remarks_line = remarks_line clipped, " ", vl_details_3
        ELSE
            LET remarks_line = remarks_line clipped, vl_details_3
        END IF
    ELSE 
        LET remarks_line = remarks_line clipped, " ", vl_details_3
    END IF

    RETURN remarks_line

END FUNCTION


# End of comp_utils.4gl ________________________________________________________
