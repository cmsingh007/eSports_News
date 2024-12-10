#######################################################################
#                                                          			  #
#       DESCRIPTION : Automate the Oracle CPU Patching Activity       #
#       AUTHOR		: MOHIT CHAUDHARY                          		  #
#       Version 	: 1.0                                  			  #
#       Date 		: 20-05-2024                               		  #
#                                                          			  #
#######################################################################

import os
import sys
import itertools

fo = open("/web/workspace/DONOT_DELETED_SCRIPTS/DND_ORACLE_PATCHES/patching_status.html", "wb+")

fo.write('<html>')
fo.write('<body>')

fo.write('<table style="font:normal 12px verdana, arial, helvetica, sans-serif; border:1px solid #1B2E5A;text-align:center" bgcolor="#D7DEEC" width="1000" border="0">')
fo.write('<caption style="font-weight:bold; letter-spacing:10px; border:1px solid #1B2E5A">CPU PATCHING STATUS</caption>')
fo.write('<tr align="center" bgcolor="#5F86CF"><td>SR NO.</td><td>COMPONENT NAME</td><td>STATUS</td></tr>')

component_name = 'COMPONENT_NAME.log'
patch_status = 'PATCH_STATUS.log'

sr_no = 1;

try:
    with open(component_name, 'r') as cn_file:
        cn_list = cn_file.readlines()

    with open(patch_status, 'r') as patch_status_file:
        patch_status_code = patch_status_file.readlines()

        for cn_names, status_code in zip(cn_list, patch_status_code):
            comp_name = cn_names.strip()
            code = status_code.strip()
            
            if code == 'COMPLETED':
                hcolor = 'green'
            if code == 'FAILED':
                hcolor = 'red'
            if code == 'COMPONENT NOT EXIST':
                hcolor = '#6CC2F6'

            sr_v = str(sr_no)
            fo.write('<tr align="center" bgcolor=#D7DEEC><td>' + sr_v + '</td><td> ' + comp_name  + ' </td><td style="background-color:' + hcolor + ';"><b>' + code + ' </b></td></tr> ')
            
            sr_no += 1

except Exception as e:
        print("Error: {e}")

fo.write("</table><br/><br/>")
