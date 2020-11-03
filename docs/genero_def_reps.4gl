# def_reps.4gl "Version %I%"

database universe

globals "../UTILS/globals.4gl"

define 
	vlr_hlocn 			record like locn.*,
	vlr_hward 			record like ward.*,
	vl_contract_ref  	like defh.contract_ref,
	vg_cum_points 		like defi.cum_points,
	orig_notice_ref 	like deft.notice_ref,
	vl_not_count 		smallint


function get_correct_by_dates(vlr_defp,
								vl_date,
								vl_time_h,
								vl_time_m,
								vp_item_ref)
  	define   
		vlr_defp				record like defp.*,
      	vl_date      			date,
      	vl_new_date      		date,
      	i,x,y          			smallint,
      	vp_item_ref      		like defi.item_ref,
      	vp_contract_ref    		like defh.contract_ref,
      	time_delay      		like defp.time_delay,
		time_delay_char			char(7),
		time_delay_mins			char(2),
		vl_working_week			char(7),
      	vl_time_h    			char(2),
      	vl_time_m    			char(2),
      	vl_new_time_h			char(2),
      	vl_new_time_m     		char(2),
      	vl_new_time_h_int		integer,
      	vl_new_time_m_int		integer,
      	vl_time_h_int			integer,
      	vl_time_m_int			integer,
		vl_end_range_hrs		integer,
		vl_end_range_mins		integer,
      	vl_rby_int_mins1		integer,
      	vl_rby_int_mins2		integer,
      	vl_rby_int_mins3		integer,
      	vl_cby_int_mins1		integer,
      	vl_cby_int_mins2		integer,
      	vl_cby_int_mins3		integer,
      	vl_rby_int_hrs1			integer,
      	vl_rby_int_hrs2			integer,
      	vl_rby_int_hrs3			integer,
      	vl_cby_int_hrs1			integer,
      	vl_cby_int_hrs2			integer,
      	vl_cby_int_hrs3  		integer,
		time_delay_mins_int		integer,
		vl_clock_start_hrs		integer,
		vl_clock_start_mins		integer,
		vl_clock_stop_hrs		integer,
		vl_clock_stop_mins		integer,
		vl_cut_off_hrs			integer,
		vl_cut_off_mins			integer
			
	# put all the char held values into integers for comparisons
	let vp_contract_ref	= vlr_defp.contract_ref
	let vl_new_date = vl_date
	let vl_new_time_h = vl_time_h
	let vl_new_time_m = vl_time_m
	let vl_new_time_h_int = vl_time_h
	let vl_new_time_m_int = vl_time_m
	let vl_time_h_int = vl_time_h
	let vl_time_m_int = vl_time_m
	let vl_rby_int_hrs1 = vr_defp_dtl_cb.report_by_hrs1
	let vl_rby_int_hrs2 = vr_defp_dtl_cb.report_by_hrs2
	let vl_rby_int_hrs3 = vr_defp_dtl_cb.report_by_hrs3
	let vl_rby_int_mins1 = vr_defp_dtl_cb.report_by_mins1
	let vl_rby_int_mins2 = vr_defp_dtl_cb.report_by_mins2
	let vl_rby_int_mins3 = vr_defp_dtl_cb.report_by_mins3
	let vl_cby_int_hrs1 = vr_defp_dtl_cb.correct_by_hrs1
	let vl_cby_int_hrs2 = vr_defp_dtl_cb.correct_by_hrs2
	let vl_cby_int_hrs3 = vr_defp_dtl_cb.correct_by_hrs3
	let vl_cby_int_mins1 = vr_defp_dtl_cb.correct_by_mins1
	let vl_cby_int_mins2 = vr_defp_dtl_cb.correct_by_mins2
	let vl_cby_int_mins3 = vr_defp_dtl_cb.correct_by_mins3
	let vl_working_week = vr_defp_dtl_cb.working_week
	let vl_clock_start_hrs = vr_defp_dtl_cb.clock_start_hrs
	let vl_clock_start_mins = vr_defp_dtl_cb.clock_start_mins
	let vl_clock_stop_hrs = vr_defp_dtl_cb.clock_stop_hrs
	let vl_clock_stop_mins = vr_defp_dtl_cb.clock_stop_mins
	let vl_cut_off_hrs = vr_defp_dtl_cb.cut_off_hrs
	let vl_cut_off_mins = vr_defp_dtl_cb.cut_off_mins
	
	if vl_working_week is not null		
	then
		# if (defp4.working_week) then check that today is a valid working day!

		let vl_new_date = johns_week(vl_date, vl_working_week)

		if vl_new_date != vl_date # It's Not!
		then
			if vl_clock_start_hrs is not null
			then
				let vl_time_h_int = vl_clock_start_hrs
				let vl_time_m_int = vl_clock_start_mins
			else
				let vl_time_h_int = 0
				let vl_time_m_int = 0
			end if
		end if
	end if

	# if the time_delay is set then use that as an increment to the current date
	# and time, else use the report by, correct by fields

	if vlr_defp.time_delay is null or vlr_defp.time_delay = 0
	then
		case
			when vl_rby_int_hrs1 > vl_time_h_int
				or (vl_rby_int_hrs1 = vl_time_h_int
				and vl_rby_int_mins1 > vl_time_m_int)

				let vl_time_h_int = vl_cby_int_hrs1
				let vl_time_m_int = vl_cby_int_mins1
				let vl_end_range_hrs = vl_rby_int_hrs1
				let vl_end_range_mins = vl_rby_int_mins1
				exit case

			when vl_rby_int_hrs2 > vl_time_h_int
				or (vl_rby_int_hrs2 = vl_time_h_int
				and vl_rby_int_mins2 > vl_time_m_int)

				let vl_time_h_int = vl_cby_int_hrs2
				let vl_time_m_int = vl_cby_int_mins2
				let vl_end_range_hrs = vl_rby_int_hrs2
				let vl_end_range_mins = vl_rby_int_mins2
				exit case

			otherwise
				let vl_time_h_int = vl_cby_int_hrs3
				let vl_time_m_int = vl_cby_int_mins3
				let vl_end_range_hrs = vl_rby_int_hrs3
				let vl_end_range_mins = vl_rby_int_mins3
				exit case

		end case

		# if the new time is less than ( or = to ) 
		# the END RANGE (NOT current) time then it must mean tommorow

		if vl_time_h_int < vl_end_range_hrs
		then
			let vl_new_date = vl_new_date + 1
		else
			if vl_time_h_int = vl_end_range_hrs
			and vl_time_m_int <= vl_end_range_mins
			then
				let vl_new_date = vl_new_date + 1
			end if
		end if

		if vl_working_week is null
		then
			let vl_new_date = 
				check_for_weekends(vl_new_date, vp_item_ref, vp_contract_ref)
		else
			let vl_new_date = johns_week(vl_new_date, vl_working_week)
		end if
													
		let vl_new_time_h = vl_time_h_int
		let vl_new_time_m = vl_time_m_int

	else
		# the time_delay is set ( this is in hours )
		let time_delay = vlr_defp.time_delay
		let time_delay_char = time_delay
		let x = length(time_delay_char)
		let time_delay_mins = time_delay_char[x-1,x]
		let time_delay_mins_int	= time_delay_mins

		if vr_defp_dtl_cb.clock_start_hrs is null
		then
			while time_delay - 24 > 0
				let time_delay = time_delay - 24
				let vl_new_date = vl_new_date + 1
				if vl_working_week is null
				then
					let vl_new_date = check_for_weekends(vl_new_date,
														vp_item_ref,
														vp_contract_ref)
				else
					let vl_new_date = johns_week(vl_new_date, vl_working_week)
				end if
			end while

			# ok we are now down to less than 24 hours

			while time_delay > 0

				# We must cater for minutes, as requested by Camden

				if time_delay < 1
				then
					case
						when time_delay = 0.30
							if (vl_time_m_int + 30) < 60
							then
								let vl_time_m_int = vl_time_m_int + 30
							else
								let vl_time_h_int = vl_time_h_int + 1
								let vl_time_m_int = 
									((vl_time_m_int + 30) - 60)
							end if		

						when time_delay = 0.15
							if (vl_time_m_int + 15) < 60
							then
								let vl_time_m_int = vl_time_m_int + 15
							else
								let vl_time_h_int = vl_time_h_int + 1
								let vl_time_m_int = 
									((vl_time_m_int + 15) - 60)
							end if
					end case
					let time_delay = 0
					exit while
				else
					let time_delay = time_delay - 1
					let vl_time_h_int = vl_time_h_int + 1

					if vl_time_h_int >= 24
					then
						let vl_time_h_int = vl_time_h_int - 24
						let vl_new_date = vl_new_date + 1
						if vl_working_week is null
						then
							let vl_new_date = check_for_weekends(vl_new_date,
																vp_item_ref,
																vp_contract_ref)
						else
							let vl_new_date = johns_week(vl_new_date, 
														vl_working_week)
						end if
					end if
				end if

			end while
		else
			# Clock Start / Clock Stop code follows

			let vl_time_h_int = (vl_time_h_int + time_delay)

			let vl_time_m_int = vl_time_m_int + time_delay_mins_int
			if vl_time_m_int >= 60
			then
				let vl_time_h_int = vl_time_h_int + 1
				let vl_time_m_int = vl_time_m_int - 60
			end if

			if vl_cut_off_hrs is null
			then
				while vl_time_h_int > vl_clock_stop_hrs
					let vl_new_date = vl_new_date + 1

					if vl_working_week is null
					then
						let vl_new_date = check_for_weekends (vl_new_date,
															vp_item_ref,
															vp_contract_ref)
					else
						let vl_new_date = johns_week(vl_new_date, 
													vl_working_week)
					end if

					let y = vl_time_h_int - vl_clock_stop_hrs
					let vl_time_h_int = vl_clock_start_hrs + y

					if vl_time_h_int = vl_clock_stop_hrs
					then
						if vl_time_m_int <= vl_clock_stop_mins
						then
							exit while
						else
							let vl_new_date = vl_new_date + 1
							let vl_time_h_int = vl_clock_start_hrs

							if vl_working_week is null
							then
								let vl_new_date = 
											check_for_weekends(vl_new_date,
															vp_item_ref,
															vp_contract_ref)
							else
								let vl_new_date = 
											johns_week(vl_new_date,
															vl_working_week)
							end if
							
						end if
					end if

				end while
			else
				while true
					# Rectify time is in normal working hours
					if (vl_time_h_int < vl_clock_stop_hrs
							or 
							(
							vl_time_h_int = vl_clock_stop_hrs
							and vl_time_m_int <= vl_clock_stop_mins
							)
						)
					# The actual time before delay is added
					and (vl_new_time_h_int < vl_clock_stop_hrs
							or	
							(
							vl_new_time_h_int = vl_clock_stop_hrs
							and vl_new_time_m_int <= vl_clock_stop_mins
							)
						)
					then
						exit while # So we leave the rectification time as is!
					end if
						
					# Passed clock stop but not reached Shut Off
					if (vl_time_h_int > vl_clock_stop_hrs
							or 	
							(
							vl_time_h_int = vl_clock_stop_hrs
							and vl_time_m_int > vl_clock_stop_mins
							)
						)
					and (vl_cut_off_hrs > vl_time_h_int
							or 	
							(
							vl_cut_off_hrs = vl_time_h_int
							and vl_cut_off_mins > vl_time_m_int
							)
						)
					then
						exit while # So we leave the rectification time as is!
					end if

					# Both Clock Stop and Cut Off have been passed!
					if (vl_time_h_int > vl_clock_stop_hrs
							or 	
							(
							vl_time_h_int = vl_clock_stop_hrs
							and vl_time_m_int > vl_clock_stop_mins
							)
						)
					and ( vl_time_h_int > vl_cut_off_hrs
							or 
							(
							vl_time_h_int = vl_cut_off_hrs
							and vl_time_m_int > vl_cut_off_mins
							)
						)
					and vl_cut_off_hrs > vl_clock_stop_hrs
					then
						# let rectify time = Cut Off Time
						let vl_time_h_int = vl_clock_stop_hrs
						let vl_time_m_int = vl_clock_stop_mins
						exit while
					end if

					# The Clock Stop has been passed but 
					# the Cut Off is less than Clock Stop
					# i.e. Clock Stop in evening Cut Off in Morning
					if (vl_time_h_int > vl_clock_stop_hrs
							or  
							(
							vl_time_h_int = vl_clock_stop_hrs
							and vl_time_m_int > vl_clock_stop_mins
							)
						)
					and (vl_cut_off_hrs < vl_clock_stop_hrs
							or	
							(
							vl_cut_off_hrs = vl_clock_stop_hrs
							and vl_cut_off_mins < vl_clock_stop_hrs
							)
						)
					then
						let vl_time_h_int = vl_time_h_int - vl_clock_stop_hrs
						let vl_time_m_int = vl_time_m_int - vl_clock_stop_mins

						case   
							when vl_time_m_int >= 60
								let vl_time_h_int = vl_time_h_int + 1
								let vl_time_m_int = vl_time_m_int - 60
							when vl_time_m_int < 0
								let vl_time_h_int = vl_time_h_int - 1
								let vl_time_m_int = 60 - vl_time_m_int
						end case

						let vl_time_h_int = vl_clock_start_hrs + vl_time_h_int
						let vl_time_m_int = vl_clock_start_mins + vl_time_m_int
						let vl_new_date = vl_new_date + 1

						if vl_working_week is null
						then
							let vl_new_date = check_for_weekends (vl_new_date,
																vp_item_ref,
																vp_contract_ref)
						else
							let vl_new_date = johns_week(vl_new_date, 
														vl_working_week)
						end if
				
						# The Cut Off is greater than the new rectify time
						if vl_time_h_int < vl_cut_off_hrs
						then
							exit while
						end if

						#The rectify time has exceeded the Cut Off
						if vl_time_h_int > vl_cut_off_hrs
							or	
							(
							vl_time_h_int = vl_cut_off_hrs
							and vl_time_m_int > vl_cut_off_mins
							)
						then
							let vl_time_h_int = vl_cut_off_hrs
							let vl_time_m_int = vl_cut_off_mins
							exit while
						end if
					end if
				end while
			end if
		end if
	end if

	let vl_new_time_h = vl_time_h_int
	let vl_new_time_m = vl_time_m_int

	return vl_new_date,vl_new_time_h,vl_new_time_m
end function



function check_for_weekends (vl_date,vp_item_ref,vp_contract_ref)
  	define 
		vl_date 			date,
      	vp_item_ref 		like defi.item_ref,
      	vp_contract_ref 	like defh.contract_ref

  	let vl_date = get_working_week_record(vp_item_ref, vp_contract_ref, vl_date)

  	return vl_date
end function


function get_working_week_record(vp_item_ref, vp_contract_ref, vl_date)
	define
  		vp_item_ref  	like defi.item_ref,
		vp_contract_ref like defh.contract_ref,
		vl_work_week 	like ww.work_week,
		vl_date  		date,
		vl_count		smallint,
		vl_dow 			smallint,
		vl_mess			string

    let vl_mess = "FUNCTION get_working_week_record(vp_item_ref, vp_contract_ref, vl_date)"
    display vl_mess

	display "vp_item_ref = ", vp_item_ref
	display "vp_contract_ref = ", vp_contract_ref
	display "vl_date = ", vl_date

    select work_week 
		into vl_work_week 
	from ww, item, fr_i, pa_i 
		where item.contract_ref = vp_contract_ref 
		and item.item_ref = vp_item_ref 
		and item.pattern_code = fr_i.freq_ref 
		and fr_i.date_ref = pa_i.pattern_code 
		and pa_i.start_date <= vl_date 
		and pa_i.finish_date >= vl_date 
		and ww.ww_type = fr_i.ww_type
	if status = notfound
	THEN
		let vl_mess = "Unable to locate working week for item ",
							vp_item_ref clipped, " contract ",
							vp_contract_ref clipped, " date ",
							vl_date using "dd/mm/yyyy"
#		call valid_error("",vl_mess,"")
        display vl_mess
		return ""
	end if

	while true
		let vl_dow = get_occur_day_pos(vl_date)

		while vl_work_week[vl_dow] = "N"
			let vl_date = vl_date + 1
			let vl_dow = get_occur_day_pos(vl_date)
		end while

		# ADJ EXCLUSION
		if vg_wb_installation = "Y"
		then
			# Does the date land on an exclusion date?
			select count(*)
				into vl_count
			from whiteboard_dtl
				where calendar_date = vl_date
				and exclusion_yn = "Y"

			if vl_count
			then
				let vl_date = vl_date + 1
				continue while
			end if
		end if
	end while

	return vl_date
end function


function get_occur_day_pos(vl_date)
  	define 
		vl_date 	date,
    	vl_pos 		smallint

	let vl_pos = weekday(vl_date)

	if vl_pos = 0
	then
		let vl_pos = 7
	end if

	return vl_pos
end function


function johns_week(vl_date, vl_working_week)
	define
		vl_count			smallint,
		vl_dow				smallint,
		vl_date				date,
		vl_working_week		char(7)

	# ADJ EXCLUSION
	while true
		let vl_dow = get_occur_day_pos(vl_date)

		while vl_working_week[vl_dow] = "N"
			let vl_date = vl_date + 1
			let vl_dow = get_occur_day_pos(vl_date)
		end while

		# ADJ EXCLUSION
		if vg_wb_installation = "Y"
		then
			# Does the date land on an exclusion date?
			select count(*)
				into vl_count
			from whiteboard_dtl
				where calendar_date = vl_date
				and exclusion_yn = "Y"

			if vl_count
			then
				let vl_date = vl_date + 1
				continue while
			end if
		end if

		exit while

	end while

	return vl_date
end function
