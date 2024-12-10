#!/bin/bash
#######################################################################
#                                                          			  #
#       DESCRIPTION : Automate the Oracle CPU Patching Activity       #
#       AUTHOR		: MOHIT CHAUDHARY                          		  #
#       Version 	: 1.0                                  			  #
#       Date 		: 20-05-2024                               		  #
#                                                          			  #
#######################################################################


#------------------------------
# EDIT Below ORACLE HOME Paths
#------------------------------
echo
echo "Exporting all the ORACLE_HOME Paths"

export PATCH_DIRECTORY=/web/workspace/DONOT_DELETED_SCRIPTS/DND_ORACLE_PATCHES
export JAVA_HOME_LOC=/web/bea/
export WEBLOGIC_HOME=/web/bea/Middleware
export OHS_HOME=/web/bea/OHS_HOME_12c
export PEGA_HOME=/web/bea/Pega_Middleware
export DBCLIENT_HOME=/web/workspace/baseinstall/oracle/19.3.0

#--------------------------------
# PARAMS
#--------------------------------

CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")
JAVA_CHECKER=TRUE_FALSE
WEBLOGIC_CHECKER=TRUE_FALSE
OHS_CHECKER=TRUE_FALSE
touch COMPONENT_NAME.log
touch PATCH_STATUS.log
touch OLD_lspatches.html
touch NEW_lspatches.html
touch Patching_logs.html
touch patching_status.html
echo

#------------------------
# JAVA Patching Function
#------------------------
java_patch() {

cd $PATCH_DIRECTORY
echo "JAVA" >> COMPONENT_NAME.log
echo
echo "BACKUP OF Existing JAVA is in Progress"
cd $JAVA_HOME_LOC
mv JAVA JAVA_$CURRENT_TIME
tar -czf JAVA_$CURRENT_TIME.tar.gz JAVA_$CURRENT_TIME
if [ $? -eq 0 ]; then
	echo "BACKUP of Existing JAVA is Completed"
else
	echo "BACKUP of Existing JAVA is Failed. Skipping Java Patch Now!"
	mv JAVA_$CURRENT_TIME JAVA
	echo "FAILED" >> PATCH_STATUS.log
	return 1
fi
 
echo "APPLYING JAVA PATCH"
cd $PATCH_DIRECTORY/JAVA/
JAVA_PATCH_NAME=$(ls -ltrh | awk '{print $9}' |  awk 'NR!=1 {print}' | cut -d '.' -f1)
unzip "$JAVA_PATCH_NAME".zip -d $JAVA_PATCH_NAME > /dev/null
cd $JAVA_PATCH_NAME
JDK_TAR=$(ls -ltrh | grep -E "jdk*" | grep -E "*.tar.gz" | awk '{print $9}')
mkdir JAVA_TEMP_LOC
tar -xzf $JDK_TAR -C JAVA_TEMP_LOC
cd JAVA_TEMP_LOC
JAVA_TEMP_DIR=$(ls -ltrh | awk '{print $9}' |  awk 'NR!=1 {print}')
mv $JAVA_TEMP_DIR JAVA
cp -r JAVA $JAVA_HOME_LOC
if [ $? -eq 0 ]; then
	echo "JAVA Patch is applied succesfully"
	JAVA_CHECKER=COMPLETED
	cd $PATCH_DIRECTORY
	echo "COMPLETED" >> PATCH_STATUS.log
	cd $JAVA_HOME_LOC
	rm -rf JAVA_$CURRENT_TIME
else
	echo "Java Patch is Failed. Exiting now from script."
	JAVA_CHECKER=FALSE
	cd $JAVA_HOME_LOC
	mv JAVA_$CURRENT_TIME JAVA
	cd $PATCH_DIRECTORY
	echo "FAILED" >> PATCH_STATUS.log
	return 1
fi

cd $PATCH_DIRECTORY/JAVA/
rm -rf $JAVA_PATCH_NAME

}


#----------------------------
# Weblogic Patching Function
#----------------------------

weblogic_patch() {

cd $PATCH_DIRECTORY
echo "WEBLOGIC" >> COMPONENT_NAME.log
echo
export ORACLE_HOME=$WEBLOGIC_HOME

echo "Applying SBP Patch on "$ORACLE_HOME""
cd $PATCH_DIRECTORY/WEBLOGIC/SBP
SBP_PATCH_NAME=$(ls -ltrh | awk '{print $9}' |  awk 'NR!=1 {print}' | cut -d '.' -f1)
unzip "$SBP_PATCH_NAME".zip -d $SBP_PATCH_NAME > /dev/null
cd $SBP_PATCH_NAME
SBP_DIR_NAME=$(ls -ltrh | awk '{print $9}' | awk 'NR!=1 {print}')
#$SBP_DIR_NAME/tools/spbat/generic/SPBAT/spbat.sh -version
#$SBP_DIR_NAME/tools/spbat/generic/SPBAT/spbat.sh -phase precheck -oracle_home $ORACLE_HOME
$SBP_DIR_NAME/tools/spbat/generic/SPBAT/spbat.sh -phase apply -oracle_home $ORACLE_HOME
if [ $? -eq 0 ]; then
	echo "SBP Patch is succesfully applied."
	WEBLOGIC_CHECKER=TRUE
	cd $PATCH_DIRECTORY
	echo "COMPLETED" >> PATCH_STATUS.log
else
	echo "SBP Patch is Failed. Exiting now from script."
	WEBLOGIC_CHECKER=FALSE
	cd $PATCH_DIRECTORY
	echo "FAILED" >> PATCH_STATUS.log
	exit 1
fi

cd $PATCH_DIRECTORY/WEBLOGIC/SBP
rm -rf $SBP_PATCH_NAME

echo
echo "Applying GENERIC Patches on "$ORACLE_HOME""
cd $PATCH_DIRECTORY/WEBLOGIC/GENERIC

ls -ltrh | awk '{print $9}' | awk 'NR!=1 {print}' | grep -E "*.zip" > PATCH_LIST
if [[ $(wc -c < PATCH_LIST) -gt 0 ]];then
	for GEN_PATCH in $(cat PATCH_LIST)
	do
			PATCH_NUM=$(echo $GEN_PATCH | cut -d '_' -f1 | cut -d 'p' -f2)
			unzip $GEN_PATCH -d $PATCH_NUM > /dev/null
			cd $PATCH_NUM/$PATCH_NUM
#			$ORACLE_HOME/OPatch/opatch version
			yes | $ORACLE_HOME/OPatch/opatch apply 
            if [[ $? -eq 0 ]];then
				echo "Patch $GEN_PATCH is succesfully applied"
			else
				echo "Patch $GEN_PATCH is Failed. Skipping this Patch, Kindly check."
			fi
			cd $PATCH_DIRECTORY/WEBLOGIC/GENERIC
			rm -rf $PATCH_NUM
	done
else
	echo "There are NO GENERIC Patches to be Processed."
fi
rm -rf PATCH_LIST

cd $PATCH_DIRECTORY
$ORACLE_HOME/OPatch/opatch lspatches > n_weblogic_lspatches_temp.log
cat n_weblogic_lspatches_temp.log | head -n -2 > NEW_WEBLOGIC_lspatches_temp.log

}


#-----------------------
# OHS Patching Function
#-----------------------

ohs_patch() {

cd $PATCH_DIRECTORY
echo "OHS" >> COMPONENT_NAME.log
echo

if [[ -d $OHS_HOME ]]; then
        echo "OHS_HOME is Present"
		OHS_CHECKER=TRUE
		
else
        echo "OHS_Component is NOT Available"
		OHS_CHECKER=FALSE
		echo "COMPONENT NOT EXIST" >> PATCH_STATUS.log
		return 1
fi

echo

cd $PATCH_DIRECTORY/OHS/OPATCH
export ORACLE_HOME=$OHS_HOME

echo "Upgrading Opatch on "$ORACLE_HOME""
OLD_OPATCH_VERSION=$($ORACLE_HOME/OPatch/opatch version)
OPATCH_PATCH=$(ls -ltrh | awk '{print $9}' | awk 'NR!=1 {print}')
unzip $OPATCH_PATCH > /dev/null
cd 6880880
#$ORACLE_HOME/OPatch/opatch version
$JAVA_HOME/bin/java -Djava.io.tmpdir=$(pwd) -jar opatch_generic.jar -silent oracle_home=$ORACLE_HOME
if [ $? -eq 0 ]; then
	echo "OPATCH is succesfully Upgraded on "$ORACLE_HOME""
	cd $PATCH_DIRECTORY
	echo "COMPLETED" >> PATCH_STATUS.log
else
	echo "OPATCH Upgrade is Failed. Exiting now from script."
	cd $PATCH_DIRECTORY
	echo "FAILED" >> PATCH_STATUS.log
	exit 1
fi

cd $PATCH_DIRECTORY/OHS/OPATCH
rm -rf 6880880

NEW_OPATCH_VERSION=$($ORACLE_HOME/OPatch/opatch version)
echo "OLD_OPATCH_VERSION: "$OLD_OPATCH_VERSION""
echo "NEW_OPATCH_VERSION: "$NEW_OPATCH_VERSION""

echo
echo "Applying OHS Bundle and Generic Patches on "$ORACLE_HOME""
cd $PATCH_DIRECTORY/OHS/GENERIC
ls -ltrh | awk '{print $9}' | awk 'NR!=1 {print}' | grep -E "*.zip" > PATCH_LIST
if [[ $(wc -c < PATCH_LIST) -gt 0 ]];then
	for GEN_PATCH in $(cat PATCH_LIST)
	do
			PATCH_NUM=$(echo $GEN_PATCH | cut -d '_' -f1 | cut -d 'p' -f2)
			unzip $GEN_PATCH -d $PATCH_NUM > /dev/null
			cd $PATCH_NUM/$PATCH_NUM
#			$ORACLE_HOME/OPatch/opatch version
			yes | $ORACLE_HOME/OPatch/opatch apply
			if [[ $? -eq 0 ]];then
				echo "OHS Patch $GEN_PATCH is succesfully applied"
			else
				echo "OHS Patch $GEN_PATCH is Failed. Skipping this Patch, Kindly check."
				return 1
			fi 
			sleep 3s
			cd $PATCH_DIRECTORY/OHS/GENERIC
			rm -rf $PATCH_NUM
	done
else
	echo "There are No GENERIC Patches to be processed."

fi
rm -rf PATCH_LIST

cd $PATCH_DIRECTORY
$ORACLE_HOME/OPatch/opatch lspatches > n_ohs_lspatches_temp.log
cat n_ohs_lspatches_temp.log | head -n -2 > NEW_OHS_lspatches_temp.log

}


#-----------------------
# PEGA Patching Function
#-----------------------
pega_patch() {

cd $PATCH_DIRECTORY
echo "PEGA_HOME" >> COMPONENT_NAME.log
echo

if [[ -d $PEGA_HOME ]]; then
        echo "PEGA_HOME is Present"
		
else
        echo "PEGA_HOME is NOT Available"
		echo "COMPONENT NOT EXIST" >> PATCH_STATUS.log
		return 1
fi

echo

export ORACLE_HOME=$PEGA_HOME

echo "Applying SBP Patch on "$ORACLE_HOME""
cd $PATCH_DIRECTORY/PEGA/SBP
SBP_PATCH_NAME=$(ls -ltrh | awk '{print $9}' |  awk 'NR!=1 {print}' | cut -d '.' -f1)
unzip "$SBP_PATCH_NAME".zip -d $SBP_PATCH_NAME > /dev/null
cd $SBP_PATCH_NAME
SBP_DIR_NAME=$(ls -ltrh | awk '{print $9}' | awk 'NR!=1 {print}')
#$SBP_DIR_NAME/tools/spbat/generic/SPBAT/spbat.sh -version
#$SBP_DIR_NAME/tools/spbat/generic/SPBAT/spbat.sh -phase precheck -oracle_home $ORACLE_HOME
$SBP_DIR_NAME/tools/spbat/generic/SPBAT/spbat.sh -phase apply -oracle_home $ORACLE_HOME
if [ $? -eq 0 ]; then
	echo "SBP Patch is succesfully applied."
	cd $PATCH_DIRECTORY
	echo "COMPLETED" >> PATCH_STATUS.log
else
	echo "SBP Patch is Failed. Exiting now from script."
	cd $PATCH_DIRECTORY
	echo "FAILED" >> PATCH_STATUS.log
	exit 1
fi

cd $PATCH_DIRECTORY/PEGA/SBP
rm -rf $SBP_PATCH_NAME

cd $PATCH_DIRECTORY
$ORACLE_HOME/OPatch/opatch lspatches > n_pega_lspatches_temp.log
cat n_pega_lspatches_temp.log | head -n -2 > NEW_PEGA_lspatches_temp.log

}

#----------------------------
# DBCLIENT Patching Function
#----------------------------
dbclient_patch() {

cd $PATCH_DIRECTORY
echo "DBCLIENT_HOME" >> COMPONENT_NAME.log
echo

if [[ -d $DBCLIENT_HOME ]]; then
        echo "DBCLIENT_HOME is Present"
		
else
        echo "DBCLIENT_HOME is NOT Available"
		echo "COMPONENT NOT EXIST" >> PATCH_STATUS.log
		return 1
fi

echo
export ORACLE_HOME=$DBCLIENT_HOME

echo "Upgrading OPatch on "$ORACLE_HOME""
echo
echo "Taking Backup of $ORACLE_HOME OPatch"
cd $ORACLE_HOME
mv OPatch OPatch_$CURRENT_TIME
tar -czf OPatch_$CURRENT_TIME.tar.gz OPatch_$CURRENT_TIME
if [ $? -eq 0 ]; then
	echo "BACKUP of Existing OPatch is Completed"
else
	echo "BACKUP of Existing OPatch is Failed. Skipping DBCLIENT Patch!"
	mv OPatch_$CURRENT_TIME OPatch
	cd $PATCH_DIRECTORY
	echo "FAILED" >> PATCH_STATUS.log
	return 1
fi

cd $PATCH_DIRECTORY/DBCLIENT/OPATCH
OPATCH_PATCH=$(ls -ltrh | awk '{print $9}' | awk 'NR!=1 {print}')
unzip $OPATCH_PATCH > /dev/null
mv OPatch $ORACLE_HOME/
$ORACLE_HOME/OPatch/opatch version
if [ $? -eq 0 ]; then
	echo "Upgrade of DBCLIENT OPatch is Completed"
	cd $ORACLE_HOME
	rm -rf OPatch_$CURRENT_TIME
else
	echo "Upgrade of DBCLIENT OPatch is Failed. Skipping DBCLIENT Patch!"
	rm -rf OPatch
	cd $ORACLE_HOME
	mv OPatch_$CURRENT_TIME OPatch
	cd $PATCH_DIRECTORY
	echo "FAILED" >> PATCH_STATUS.log
	return 1
fi

echo
echo "Applying DBCLIENT Patches on $ORACLE_HOME"
echo
echo "Un-Linking $ORACLE_HOME jdk"
cd $ORACLE_HOME
unlink jdk
echo "Un-Linking of $ORACLE_HOME jdk is completed"
echo
cd $PATCH_DIRECTORY/DBCLIENT/PATCHES
DB_PATCH_ZIP=$(ls -ltrh | awk '{print $9}' | awk 'NR!=1 {print}')
DB_PATCH_NUM=$(ls -ltrh | awk '{print $9}' | awk 'NR!=1 {print}' | cut -d '_' -f1 | cut -d 'p' -f2)
unzip $DB_PATCH_ZIP -d $DB_PATCH_NUM > /dev/null
cd $DB_PATCH_NUM/$DB_PATCH_NUM
#$ORACLE_HOME/OPatch/opatch version
yes | $ORACLE_HOME/OPatch/opatch apply
if [ $? -eq 0 ]; then
	echo "DBCLIENT Patch is Applied"
	cd $ORACLE_HOME
	echo "Re-Linking $ORACLE_HOME jdk"
	mv jdk jdk_$CURRENT_TIME
	tar -czf jdk_$CURRENT_TIME.tar.gz jdk_$CURRENT_TIME
	rm -rf jdk_$CURRENT_TIME
	ln -s /web/bea/oltd139/JAVA jdk
	echo "Re-Linking $ORACLE_HOME jdk is completed"
	echo
	cd $PATCH_DIRECTORY
	echo "COMPLETED" >> PATCH_STATUS.log
else
	echo "DBCLIENT Patch is Failed. Skipping DBCLIENT Patch!"
	cd $ORACLE_HOME
	ln -s /web/bea/oltd139/JAVA jdk
	cd $PATCH_DIRECTORY
	echo "FAILED" >> PATCH_STATUS.log
fi

cd $PATCH_DIRECTORY/DBCLIENT/PATCHES
rm -rf $DB_PATCH_NUM

cd $PATCH_DIRECTORY
$ORACLE_HOME/OPatch/opatch lspatches > n_dbclient_lspatches_temp.log
cat n_dbclient_lspatches_temp.log | head -n -2 > NEW_DBCLIENT_lspatches_temp.log

}


#---------------------------
# OLD Patches List Function
#---------------------------

old_lspatches_list() {

export ORACLE_HOME=$WEBLOGIC_HOME
$ORACLE_HOME/OPatch/opatch lspatches > o_weblogic_lspatches_temp.log
cat o_weblogic_lspatches_temp.log | head -n -2 > OLD_WEBLOGIC_lspatches_temp.log

if [[ -d $OHS_HOME ]];then
	export ORACLE_HOME=$OHS_HOME
	$ORACLE_HOME/OPatch/opatch lspatches > o_ohs_lspatches_temp.log
	cat o_ohs_lspatches_temp.log | head -n -2 > OLD_OHS_lspatches_temp.log
fi

if [[ -d $PEGA_HOME ]];then
	export ORACLE_HOME=$PEGA_HOME
	$ORACLE_HOME/OPatch/opatch lspatches > o_pega_lspatches_temp.log
	cat o_pega_lspatches_temp.log | head -n -2 > OLD_PEGA_lspatches_temp.log
fi

if [[ -d $DBCLIENT_HOME ]];then
	export ORACLE_HOME=$DBCLIENT_HOME
	$ORACLE_HOME/OPatch/opatch lspatches > o_dbclient_lspatches_temp.log
	cat o_dbclient_lspatches_temp.log | head -n -2 > OLD_DBCLIENT_lspatches_temp.log
fi

}


#------------------------
# Validating Home Paths
#------------------------
echo "----Validating ORACLE_HOME Paths----"
if [[ -d $JAVA_HOME_LOC ]];then
	echo "JAVA_HOME Path: $JAVA_HOME_LOC exists"
else
	echo "JAVA_HOME Path: $JAVA_HOME_LOC does NOT exists"
fi

if [[ -d $WEBLOGIC_HOME ]];then
	echo "WEBLOGIC_HOME Path: $WEBLOGIC_HOME exists"
else
	echo "WEBLOGIC_HOME Path: $WEBLOGIC_HOME does NOT exists"
fi

if [[ -d $OHS_HOME ]];then
	echo "OHS_HOME Path: $OHS_HOME exists"
else
	echo "OHS_HOME Path: $OHS_HOME does NOT exists"
fi

if [[ -d $PEGA_HOME ]];then
	echo "PEGA_HOME Path: $PEGA_HOME exists"
else
	echo "PEGA_HOME Path: $PEGA_HOME does NOT exists"
fi

if [[ -d $DBCLIENT_HOME ]];then
	echo "DBCLIENT_HOME Path: $DBCLIENT_HOME exists"
else
	echo "DBCLIENT_HOME Path: $DBCLIENT_HOME does NOT exists"
fi


#-----------------------------
# Verifying Patch Directories
#-----------------------------
echo
echo "----Verifying Patches----"
[ "$(ls -A $PATCH_DIRECTORY/JAVA/)" ] && echo "JAVA Patch Exists" || echo "JAVA Patch Does NOT Exists"
[ "$(ls -A $PATCH_DIRECTORY/WEBLOGIC/SBP)" ] && echo "Weblogic SBP Patch Exists" || echo "Weblogic SBP Patch Does NOT Exists"
[ "$(ls -A $PATCH_DIRECTORY/WEBLOGIC/GENERIC)" ] && echo "Weblogic GENERIC Patch Exists" || echo "Weblogic GENERIC Patch Does NOT Exists"
[ "$(ls -A $PATCH_DIRECTORY/OHS/OPATCH)" ] && echo "OPATCH Patch Exists" || echo "OPATCH Patch Does NOT Exists"
[ "$(ls -A $PATCH_DIRECTORY/OHS/GENERIC)" ] && echo "OHS Patches Exists" || echo "OHS Patches Does NOT Exists"
[ "$(ls -A $PATCH_DIRECTORY/PEGA/SBP)" ] && echo "PEGA SBP Patch Exists" || echo "PEGA SBP Patch Does NOT Exists"
[ "$(ls -A $PATCH_DIRECTORY/DBCLIENT/OPATCH)" ] && echo "DBCLIENT OPATCH Patch Exists" || echo "DBCLIENT OPATCH Does NOT Exists"
[ "$(ls -A $PATCH_DIRECTORY/DBCLIENT/PATCHES)" ] && echo "DBCLIENT Patches Exists" || echo "DBCLIENT Patches Does NOT Exists"


#------------------------------
# PRE-Checks & Case Statements
#------------------------------
echo
echo "Kindly cross-verify all the above Paths and then Select appropriate option for the Patching!"
echo "Press 1 for JAVA Patching [EMAIL NOT Integrated]"
echo "Press 2 for WEBLOGIC Patching [EMAIL NOT Integrated]"
echo "Press 3 for OHS Patching [EMAIL NOT Integrated]"
echo "Press 4 for Combined Patching of JAVA, WEBLOGIC, OHS, PEGA & DBCLIENT [EMAIL Integrated]"
echo "Press 5 to Exit!"
echo


read choice
case $choice in
    1)
		exec >> CPU_PATCHING."$CURRENT_TIME".log
		echo "Proceeding with the JAVA Patching"
		java_patch
		rm -rf *.log *.html
		exit 1
        ;;
	2)	
		exec >> CPU_PATCHING."$CURRENT_TIME".log
		echo "Proceeding with the WEBLOGIC Patching"
		weblogic_patch
		rm -rf *.log *.html
		exit 1
		;;
	3)	
		exec >> CPU_PATCHING."$CURRENT_TIME".log
		echo "Proceeding with the OHS Patching"
		ohs_patch
		rm -rf *.log *.html
		exit 1
		;;
    4)	
		exec >> CPU_PATCHING."$CURRENT_TIME".log
		echo "Proceeding with the JAVA, WEBLOGIC, OHS & DBCLIENT Patching. Please wait for sometime."
		old_lspatches_list
		java_patch
		weblogic_patch
		ohs_patch
		pega_patch
		dbclient_patch
		;;		
	5)  
		echo "Exiting from the Script!"
		exit 1
		;;
    *) 
		echo "Wrong Input! Please Enter the Correct Input. Exiting from the Script!"
		exit 1
		;;
esac


cd $PATCH_DIRECTORY

echo '<html>' >> OLD_lspatches.html
echo '<body>' >> OLD_lspatches.html
echo '<table style="font:normal 12px verdana, arial, helvetica, sans-serif; border:1px solid #1B2E5A;text-align:center" bgcolor="#D7DEEC" width="1000" border="0">' >> OLD_lspatches.html
echo '<PRE><FONT FACE='CONSOLAS'>' >> OLD_lspatches.html
echo '<b>----PREVIOUS CYCLE WEBLOGIC PATCHES----</b>' >> OLD_lspatches.html
echo >> OLD_lspatches.html
cat $PATCH_DIRECTORY/OLD_WEBLOGIC_lspatches_temp.log >> OLD_lspatches.html

if [[ -d $OHS_HOME ]];then
	echo >> OLD_lspatches.html
	echo >> OLD_lspatches.html
	echo '<b>----PREVIOUS CYCLE OHS PATCHES----</b>' >> OLD_lspatches.html
	echo >> OLD_lspatches.html
	cat $PATCH_DIRECTORY/OLD_OHS_lspatches_temp.log >> OLD_lspatches.html
fi

if [[ -d $PEGA_HOME ]];then
	echo >> OLD_lspatches.html
	echo >> OLD_lspatches.html
	echo '<b>----PREVIOUS CYCLE PEGA PATCHES----</b>' >> OLD_lspatches.html
	echo >> OLD_lspatches.html
	cat $PATCH_DIRECTORY/OLD_PEGA_lspatches_temp.log >> OLD_lspatches.html
fi

if [[ -d $DBCLIENT_HOME ]];then
	echo >> OLD_lspatches.html
	echo >> OLD_lspatches.html
	echo '<b>----PREVIOUS CYCLE DBCLIENT PATCHES----</b>' >> OLD_lspatches.html
	echo >> OLD_lspatches.html
	cat $PATCH_DIRECTORY/OLD_DBCLIENT_lspatches_temp.log >> OLD_lspatches.html
fi

echo '</FONT></PRE>' >> OLD_lspatches.html
echo '</table><br/>' >> OLD_lspatches.html
echo '</body>' >> OLD_lspatches.html
echo '</html>' >> OLD_lspatches.html



echo '<html>' >> NEW_lspatches.html
echo '<body>' >> NEW_lspatches.html
echo '<table style="font:normal 12px verdana, arial, helvetica, sans-serif; border:1px solid #1B2E5A;text-align:center" bgcolor="#D7DEEC" width="1000" border="0">' >> NEW_lspatches.html
echo '<PRE><FONT FACE='CONSOLAS'>' >> NEW_lspatches.html
echo '<b>----LATEST WEBLOGIC PATCHES----</b>' >> NEW_lspatches.html
echo >> NEW_lspatches.html
cat $PATCH_DIRECTORY/NEW_WEBLOGIC_lspatches_temp.log >> NEW_lspatches.html

if [[ -d $OHS_HOME ]];then
	echo >> NEW_lspatches.html
	echo >> NEW_lspatches.html
	echo '<b>----LATEST OHS PATCHES----</b>' >> NEW_lspatches.html
	echo >> NEW_lspatches.html
	cat $PATCH_DIRECTORY/NEW_OHS_lspatches_temp.log >> NEW_lspatches.html
fi

if [[ -d $PEGA_HOME ]];then
	echo >> NEW_lspatches.html
	echo >> NEW_lspatches.html
	echo '<b>----LATEST PEGA PATCHES----</b>' >> NEW_lspatches.html
	echo >> NEW_lspatches.html
	cat $PATCH_DIRECTORY/NEW_PEGA_lspatches_temp.log >> NEW_lspatches.html
fi

if [[ -d $DBCLIENT_HOME ]];then
	echo >> NEW_lspatches.html
	echo >> NEW_lspatches.html
	echo '<b>----LATEST DBCLIENT PATCHES----</b>' >> NEW_lspatches.html
	echo >> NEW_lspatches.html
	cat $PATCH_DIRECTORY/NEW_DBCLIENT_lspatches_temp.log >> NEW_lspatches.html
fi

echo '</FONT></PRE>' >> NEW_lspatches.html
echo '</table><br/>' >> NEW_lspatches.html
echo '</body>' >> NEW_lspatches.html
echo '</html>' >> NEW_lspatches.html



echo '<html>' >> Patching_logs.html
echo '<body>' >> Patching_logs.html
echo '<table style="font:normal 12px verdana, arial, helvetica, sans-serif; border:1px solid #1B2E5A;text-align:center" bgcolor="#D7DEEC" width="1000" border="0">' >> Patching_logs.html
echo '<PRE><FONT FACE='CONSOLAS'>' >> Patching_logs.html
echo '<b>----CPU PATCHING LOGS----</b>' >> Patching_logs.html
echo >> Patching_logs.html
cat $PATCH_DIRECTORY/CPU_PATCHING."$CURRENT_TIME".log >> Patching_logs.html
echo '</FONT></PRE>' >> Patching_logs.html
echo '</table><br/>' >> Patching_logs.html
echo '</body>' >> Patching_logs.html
echo '</html>' >> Patching_logs.html



python2 PATCHING_STATUS.py
echo '</body>' >> patching_status.html
echo '</html>' >> patching_status.html

CONTENT1=patching_status.html
CONTENT2=OLD_lspatches.html
CONTENT3=NEW_lspatches.html
CONTENT4=Patching_logs.html
SUBJECT="Oracle CPU Patching Status on `hostname` - $USER"
( echo "Subject: $SUBJECT"
echo "To:email_id@email.com"
echo "MIME-Version: 1.0"
echo "Content-Type: text/html; charset=ISO-8859-1"
echo "Content-Disposition: inline"
cat $CONTENT1
cat $CONTENT2
cat $CONTENT3
cat $CONTENT4)| /usr/sbin/sendmail -t

cd $PATCH_DIRECTORY
rm -rf *.log *.html
echo "The Script Execution is completed. Details are shared over Email. Thank You!"