# Signals
set top [list u_cdc_4phase.src_clk_i u_cdc_4phase.dst_clk_i  u_cdc_4phase.src_rst_ni u_cdc_4phase.dst_rst_ni]
set signals_to_add {
    {"i_src.state_q" Yellow}
    {"i_src.valid_i" Blue}
    {"i_src.req_src_q" Indigo}
    {"i_src.ack_synced" Violet}
    {"i_dst.state_q" Yellow}
    {"i_dst.ready_i" Blue}
    {"i_dst.req_synced" Indigo}
    {"i_dst.async_ack_o" Violet}
}

# File filters
set state_map_dict {
    "i_src.state_q" "./GTKWave/FSM_src.txt"
    "i_dst.state_q" "./GTKWave/FSM_dst.txt"
}

# variables
set states [dict keys $state_map_dict]
set nsigs [ gtkwave::getNumFacs ]

# Customize view settings
gtkwave::nop
gtkwave::/Edit/Set_Trace_Max_Hier 2
# gtkwave::/View/Show_Filled_High_Values 1
gtkwave::/View/Show_Wave_Highlight 1
# gtkwave::/View/Show_Mouseover 1

gtkwave::/Edit/Insert_Comment "Clock & Reset"
gtkwave::addSignalsFromList $top
gtkwave::highlightSignalsFromList $top
# gtkwave::/Edit/Color_Format/Indigo
gtkwave::/Edit/UnHighlight_All
gtkwave::/Edit/Insert_Blank

proc translate {element_list element mapping_file} {
    set iselement 0

    foreach e $element_list {
        if {[ string first $e $element ] != -1} {
            set iselement 1
        }
    }
    if {$iselement == 1 } {
        gtkwave::highlightSignalsFromList "$element"
        gtkwave::installFileFilter $mapping_file
        gtkwave::/Edit/UnHighlight_All
    }
    # return $iselement
}

proc add_signals { filter color} {
    global nsigs
    global states
    global state_map_dict

    set filterKeyword $filter
    set filterCondition "_hi_"
    set monitorSignals [list]
    for {set i 0} {$i < $nsigs } {incr i} {
        set facname [ gtkwave::getFacName $i ]
        set index [ string first $filterKeyword $facname  ]
        set index2 [ string first $filterCondition $facname  ]

        if {$index != -1 && $index2 == -1} {
            lappend monitorSignals "$facname"
        }
    }
    # gtkwave::/Edit/Insert_Comment $filter
    gtkwave::addSignalsFromList $monitorSignals
    # gtkwave::/Edit/Insert_Blank
    foreach v $monitorSignals {
        set a [split $v .]
        set a [lindex $a end]
        gtkwave::highlightSignalsFromList $v
    }
    gtkwave::/Edit/Color_Format/$color
    gtkwave::/Edit/UnHighlight_All

    foreach v $monitorSignals {
        if {[info exists states]} {
            foreach state $states {
                if {[string first $state $v] != -1} {
                    set state_map [ gtkwave::setCurrentTranslateFile [dict get $state_map_dict $state] ]
                    translate $states $v $state_map
                }
            }
        }
    }
    ## This sets the register signal names to be aliased to the register name
    foreach v $monitorSignals {
        if {[string first regs_ $v] != -1} {
        set name [string range [lsearch -inline [split $v .] {regs_*}] 5 end]
        gtkwave::highlightSignalsFromList "$v"
        gtkwave::/Edit/Alias_Highlighted_Trace x$name
        gtkwave::/Edit/UnHighlight_All

        }
    }
}

# Zoom all
gtkwave::/Time/Zoom/Zoom_Full


# Add signals
gtkwave::/Edit/Insert_Comment "Signals"

foreach s $signals_to_add {
    puts $s
    add_signals [lindex $s 0] [lindex $s 1]
}