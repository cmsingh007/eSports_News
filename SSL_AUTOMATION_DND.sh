#!/bin/bash
#############################################################################################
#                                                                                           #
# DESCRIPTION: Automate the SSL Certificate Renewal Activity                                #
# CREATED ON:  Tue Mar 26 08:16:15 EDT 2024                                                 #
# AUTHOR:      MOHIT CHAUDHARY                                                              #
# SUPERVISOR:  SRITAMA MAJUMDER, HARSHIT GOEL                                               #
# VERSION:     1.0                                                                          #
#                                                                                           #
#############################################################################################


#----------------------------------------
# SSL FILE LOCATIONS
#----------------------------------------

PFXSSLDir_location="/web/workspace/DONOT_DELETED_SCRIPTS/SSLAutomation/PFXSSLDir"
PEMSSLDir_location="/web/workspace/DONOT_DELETED_SCRIPTS/SSLAutomation/PEMSSLDir"
archive_location="/web/workspace/DONOT_DELETED_SCRIPTS/SSLAutomation/archive"

ls -ltrh $PFXSSLDir_location | awk '{print $9}' | awk 'NR!=1 {print}' | grep -E "*.pfx" > $PFXSSLDir_location/PFX_Files
ls -ltrh $PEMSSLDir_location | awk '{print $9}' | awk 'NR!=1 {print}' | grep -E "*.pem" > $PEMSSLDir_location/PEM_Files



#----------------------------------------
# Variables
#----------------------------------------

PK=private_key
CERT=Main_Certificate
CHAIN=Chain_Certificate
IDEN=ident_cert
CN=commonName
backupDate=$(date '+%Y-%m-%d_%H:%M:%S')
aliasHolder=alias_name
temp_alias=temporary_aliases_name
keystorePass=gatewayd139store
password=importSSLPassword
temp_key=tempPrivateKey
id_temp=tempOldValidity
password_file=pfxPasswordFile
pfxInput=pfxFileName
pemInput=pemFileName
greenStatus=renewedSSLStatus
redStatus=failedSSLStatus
identRedStatus=failSSLinIdentity
greenStatusUniq=renewedSSLStatusUniq
redStatusUniq=failedSSLStatusUniq
identRedStatusUniq=failSSLinIdentityUniq




#---------------------------------------------------------------------
# Cleanup function to remove the files after SSL Renewal is completed
#---------------------------------------------------------------------

filesRemoval() {
echo
echo "Cleaning up the Files..."
rm -rf "$CHAIN".cer "$CERT".crt "$PK".key $output_file "$aliasHolder".txt "$temp_key".key "$id_temp".txt "$IDEN".pfx
rm -rf "$temp_alias".txt id_temp.txt
echo "Cleanup of the Files Completed!"
}




#-------------------------------------------------------
# FUNCTION FOR SSL RENEWAL IN TRUST & IDENTIY KEYSTORE
#-------------------------------------------------------

trustIdentitySSLRenewal() {
echo
echo "#########################################################"
echo "###        SSL Renewal in Trust Store Started         ###"
echo "#########################################################"
echo
password=$1

if [[ -f trust.pkx ]]; then
        echo "trust.pkx keystore is available. Procedding with next steps..."
else
        echo "Not Able to Find trust.pkx keystore. SSL Renewal is Aborted. Exiting now from script..."
        echo "SSL Renewal of CN=$CN is failed."
        echo "Please check the path for trust.pkx keystore"
        echo $CN >> "$redStatus".txt
        filesRemoval
        exit 1
fi
echo




#keytool -list -v -keystore trust.pkx -storepass $keystorePass | grep  "Owner: CN=" | grep "$CN" | awk '{print $2}' | cut -d '=' -f 2 | cut -d ',' -f 1 > "$temp_alias".txt

#if [[ $(wc -c < "$temp_alias".txt) -gt 0 ]];then

#keytool -list -v -keystore trust.pkx -storepass $keystorePass | grep  "Alias name\|Owner: CN="$(cat "$temp_alias".txt)"" | grep "$CN" -B1 | grep "Alias name:" | awk '{print $3}' > "$aliasHolder".txt

keytool -list -v -keystore trust.pkx -storepass $keystorePass | grep  "Alias name\|Owner: CN=$CN" | grep "$CN" -B1 | grep "Alias name:" | awk '{print $3}' > "$aliasHolder".txt

        if [[ $(wc -c < "$aliasHolder".txt) -gt 0 ]];then
                echo "Alias: "$(cat "$aliasHolder".txt)" is Present in trust.pkx keystore. Going ahead with the SSL Renewal Steps..."
        else
                echo "Not Able to Find Alias Name in trust.pkx keystore."
                filesRemoval
                echo "SSL Renewal of CN=$CN is failed."
                echo $CN >> "$redStatus".txt
                return 1
                #exit 1
        fi

#else
#    echo "Not Able to Find Alias Name in trust.pkx keystore."
#    filesRemoval
#    echo "SSL Renewal of CN=$CN is failed."
#    echo $CN >> "$redStatus".txt
#    return 1
#    #exit 1

#fi



#cp trust.pkx trust.pkx_$backupDate
#echo "Backup of trust.pkx is successfully taken."
echo

echo "###OLD Certificate Validity###"
keytool -v -list -alias "$(cat $aliasHolder.txt)" -keystore trust.pkx -storepass $keystorePass | grep "Valid from:"

#condition to be added

echo
keytool -delete -alias "$(cat $aliasHolder.txt)" -keystore trust.pkx -storepass $keystorePass
keytool -importcert -trustcacerts -alias "$(cat $aliasHolder.txt)" -file "$CHAIN".cer -keystore trust.pkx -storepass $keystorePass

if [ $? -eq 0 ]; then
    echo "Certificate Import Completed in trust.pkx keystore"
else
    echo "Not Able to Import/Renew the SSL Certificate of $CN in trust.pkx keystore."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$redStatus".txt
    return 1

fi

echo
echo "###NEW Certificate Validity###"
keytool -v -list -alias "$(cat $aliasHolder.txt)" -keystore trust.pkx -storepass $keystorePass | grep "Valid from:"


echo
echo "#########################################################"
echo "###       SSL Renewal in Trust Store Completed        ###"
echo "#########################################################"
echo

echo
echo "#########################################################"
echo "###      SSL Renewal in Identity Store Started        ###"
echo "#########################################################"
echo

if [[ -f identity.pkx ]]; then
        echo "identity.pkx keystore is available. Procedding with next steps..."
else
        echo "Not Able to Find identity.pkx keystore. SSL Renewal is Aborted. Exiting now from script..."
        echo "SSL Renewal of CN=$CN is failed."
        echo "Please check the path for identity.pkx keystore"
        echo $CN >> "$identRedStatus".txt
        filesRemoval
        exit 1
fi

echo



#keytool -list -v -keystore identity.pkx -storepass $keystorePass | grep  "Owner: CN=" | grep "$CN" | awk '{print $2}' | cut -d '=' -f 2 | cut -d ',' -f 1 > "$temp_alias".txt

#if [[ $(wc -c < "$temp_alias".txt) -gt 0 ]];then

#keytool -list -v -keystore identity.pkx -storepass $keystorePass | grep  "Alias name\|Owner: CN="$(cat "$temp_alias".txt)"" | grep "$CN" -B1 | grep "Alias name:" | awk '{print $3}' > "$aliasHolder".txt

keytool -list -v -keystore identity.pkx -storepass $keystorePass | grep  "Alias name\|Owner: CN=$CN" | grep "$CN" -B1 | grep "Alias name:" | awk '{print $3}' > "$aliasHolder".txt

        if [[ $(wc -c < "$aliasHolder".txt) -gt 0 ]];then
                echo "Alias: "$(cat "$aliasHolder".txt)" is Present in identity.pkx keystore. Going ahead with the SSL Renewal Steps..."
        else
                echo "Alias Name: "$(cat "$aliasHolder".txt)" is NOT present in identity.pkx keystore. SSL Renewal of $CN is completed only in trust.pkx keystore."
                echo $CN >> "$identRedStatus".txt
                filesRemoval
                return 1
        fi

#else
#    echo "Alias Name: "$(cat "$aliasHolder".txt)" is NOT present in identity.pkx keystore. SSL Renewal of $CN is completed only in trust.pkx keystore."
#    filesRemoval
#    return 1

#fi


echo
#cp identity.pkx identity.pkx_$backupDate
#echo "Backup of identity.pkx is successfully taken."
echo



echo "###OLD Certificate Validity###"
keytool -v -list -alias "$(cat $aliasHolder.txt)" -keystore identity.pkx -storepass $keystorePass | grep "Valid from:" > "$id_temp".txt
echo $(awk 'NR==1 {print; exit}' "$id_temp".txt)
#echo $(head -n 1 id_temp.txt)
echo



/usr/bin/openssl pkcs12 -export -out "$IDEN".pfx -inkey "$PK".key -in "$CHAIN".cer -passout "pass:$password"

if [ $? -eq 0 ]; then
    echo "Identity_Certificate.pfx certificate is converted. Proceeding with the Import..."
else
    echo "Not Able to create Identity_Certificate.pfx certificate."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$identRedStatus".txt
    filesRemoval
    return 1
fi



keytool -delete -alias "$(cat $aliasHolder.txt)" -keystore identity.pkx -storepass $keystorePass

echo -e "$password" | keytool -v -importkeystore -srckeystore "$IDEN".pfx  -destkeystore identity.pkx -deststoretype pkcs12 -srcalias 1 -destalias "$(cat $aliasHolder.txt)" -deststorepass $keystorePass -destkeypass $keystorePass

if [ $? -eq 0 ]; then
    echo "Certificate Import Completed in identity.pkx keystore"
else
    echo "Not Able to Import/Renew the SSL Certificate of $CN in identity.pkx keystore."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$identRedStatus".txt
    filesRemoval
    return 1
fi


echo
echo "###NEW Certificate Validity###"
keytool -v -list -alias "$(cat $aliasHolder.txt)" -keystore identity.pkx -storepass $keystorePass | grep "Valid from:" > id_temp.txt
echo $(awk 'NR==1 {print; exit}' id_temp.txt)
echo

echo
echo "#########################################################"
echo "###     SSL Renewal in Identity Store Completed       ###"
echo "#########################################################"
echo

echo
echo
echo
echo "########################################################################################"
echo "#######              SSL Renewal of CN=$CN is Completed                    #############"
echo "########################################################################################"
echo
echo

echo $CN >> "$greenStatus".txt

if [[ -f $PFXSSLDir_location/$pfxInput ]];then
        #change to mv command during live mode
        cp $PFXSSLDir_location/$pfxInput "$archive_location/$pfxInput"_PROCESSED
#       cp $PFXSSLDir_location/"${pfxInput%.*}".txt $archive_location/"${pfxInput%.*}".txt_PROCESSED
fi

if [[ -f $PEMSSLDir_location/$pemInput ]];then
        #change to mv command during live mode
        cp $PEMSSLDir_location/$pemInput "$archive_location/$pemInput"_PROCESSED
fi



filesRemoval

}






#----------------------------------------
# FUNCTION FOR PFX CONVERSION
#----------------------------------------

pfxSSLRenewal() {

pfxInput=$1

CN=${pfxInput%.*}
input_file=$PFXSSLDir_location/$pfxInput
output_file="${pfxInput%.*}".pem
password_file=$PFXSSLDir_location/"${pfxInput%.*}".txt
password=$(cat $password_file)


echo
echo
echo "##################################################################################"
echo "#######           SSL Renewal of CN=$CN is Started                         #######"
echo "##################################################################################"
echo
echo

echo "PFX file location is $input_file"
echo "Password file location is $password_file"
echo

if [ ! -f "$input_file" ]; then
    echo "Input file '$input_file' does not exist."
    echo $CN >> "$redStatus".txt
    return 1
fi

if [ ! -f "$password_file" ]; then
    echo "Input file '$password_file' does not exist."
    echo $CN >> "$redStatus".txt
    return 1
fi



echo "#########################################################"
echo "###           SSL PFX Conversion Started              ###"
echo "#########################################################"
echo


#Convert .pfx to .pem
openssl pkcs12 -in "$input_file" -out "$output_file" -passin "pass:$password" -passout "pass:$password"


# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "PFX to PEM Conversion is successful. Output file: $output_file"
else
    echo "PFX to PEM Conversion failed."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$redStatus".txt
    return 1
fi


#Convert PEM into CRT
openssl x509 -outform der -in "$output_file" -out "$CERT".crt



# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "PEM to CRT Conversion successful. Output file: "$CERT".crt"
else
    echo "PEM to CRT Conversion failed."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$redStatus".txt
    return 1
fi


# Chain SSL Creation
sed -n '/BEGIN CERTIFICATE/, /END CERTIFICATE/p' "$output_file" > "$CHAIN".cer

# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "Chain SSL is successfully created. Output file: "$CHAIN".cer"
else
    echo "PEM to CHAIN Conversion failed."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$redStatus".txt
    return 1
fi



#Private_key conversion
openssl pkcs12 -in "$input_file" -nocerts -out "$temp_key".key -passin "pass:$password" -nodes
sleep 1s
sed -n '/BEGIN PRIVATE KEY/, /END PRIVATE KEY/p' "$temp_key".key > "$PK".key

if [ $? -eq 0 ]; then
    echo "Private key conversion is successful. Output file: "$PK".key"
else
    echo "Private key Conversion failed."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$redStatus".txt
    return 1

fi

echo
echo "#########################################################"
echo "###           SSL PFX Conversion Completed            ###"
echo "#########################################################"


trustIdentitySSLRenewal $password

}






#----------------------------------------
# FUNCTION FOR PEM CONVERSION
#----------------------------------------


pemSSLRenewal() {

pemInput=$1

CN=${pemInput%.*}
input_file=$PEMSSLDir_location/$pemInput
password=$(date +%s)


echo
echo
echo "##################################################################################"
echo "#######           SSL Renewal of CN=$CN is Started                         #######"
echo "##################################################################################"
echo
echo

echo "PEM file location is $input_file"
echo
echo "#########################################################"
echo "###           SSL PEM Conversion Started              ###"
echo "#########################################################"
echo

#Convert PEM into CRT
openssl x509 -outform der -in "$input_file" -out "$CERT".crt


# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "PEM to CRT Conversion successful. Output file: "$CERT".crt"
else
    echo "PEM to CRT Conversion failed."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$redStatus".txt
    return 1
fi


# Chain SSL Creation
sed -n '/BEGIN CERTIFICATE/, /END CERTIFICATE/p' "$input_file" > "$CHAIN".cer

# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "Chain SSL is successfully created. Output file: "$CHAIN".cer"
else
    echo "PEM to CHAIN Conversion failed."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$redStatus".txt
    return 1
fi


#Private_key conversion
sed -n '/BEGIN PRIVATE KEY/, /END PRIVATE KEY/p' "$input_file" > "$PK".key

if [ $? -eq 0 ]; then
    echo "Private key conversion is successful. Output file: "$PK".key"
else
    echo "Private key Conversion for $CN failed."
    echo "SSL Renewal of CN=$CN is failed."
    echo $CN >> "$redStatus".txt
    return 1
fi


echo
echo "#########################################################"
echo "###           SSL PEM Conversion Completed            ###"
echo "#########################################################"
echo

trustIdentitySSLRenewal $password

}


#----------------------------------------------------------
# PXF SSL FILES ARE PROCEESED ONE BY ONE USING BELOW LOGIC
#----------------------------------------------------------


pfxitems="$PFXSSLDir_location/PFX_Files"
if [[ $(wc -c < "$PFXSSLDir_location/PFX_Files") -gt 0 ]];then
#       echo "Calling pfxSSLRenewal function..."

        for ipfx in $(cat $pfxitems)
        do
#               echo "pfxSSLRenewal function is called..."
                echo
                pfxSSLRenewal $ipfx
        done

else
        echo "There are No SSL Files present to be processed for the Renewal in PFX Directory."
        rm -rf $PFXSSLDir_location/PFX_Files
        echo
fi
filesRemoval
rm -rf $PFXSSLDir_location/PFX_Files





#----------------------------------------------------------
# PEM SSL FILES ARE PROCEESED ONE BY ONE USING BELOW LOGIC
#----------------------------------------------------------

pemitems="$PEMSSLDir_location/PEM_Files"
if [[ $(wc -c < "$PEMSSLDir_location/PEM_Files") -gt 0 ]];then
#        echo "Calling pemSSLRenewal function..."

        for ipem in $(cat $pemitems)
        do
#               echo "pemSSLRenewal function is called..."
                pemSSLRenewal $ipem
        done

else
        echo "There are No SSL Files present to be processed for the Renewal in PEM Directory. "
        rm -rf $PEMSSLDir_location/PEM_Files
fi


filesRemoval
rm -rf $PEMSSLDir_location/PEM_Files


#Removing Duplicates and Blank Lines
if [[ -f "$greenStatus".txt  ]];then
awk '!a[$0]++' "$greenStatus".txt > "$greenStatusUniq".txt
sed '/^[[:space:]]*$/d' "$greenStatusUniq".txt > greenSSLStatus.txt
fi
if [[ -f "$redStatus".txt ]];then
awk '!a[$0]++' "$redStatus".txt > "$redStatusUniq".txt
sed '/^[[:space:]]*$/d' "$redStatusUniq".txt > redSSLStatus.txt
fi
if [[ -f "$identRedStatus".txt ]];then
awk '!a[$0]++' "$identRedStatus".txt > "$identRedStatusUniq".txt
fi


echo
echo
echo "#########################################################"
echo "###         SSL Renewal Successfull Report            ###"
echo "#########################################################"
echo
echo


#cat "$greenStatusUniq".txt
cat greenSSLStatus.txt

echo
echo
echo "#########################################################"
echo "###         SSL Renewal Failed Report                 ###"
echo "#########################################################"
echo
echo

#if [[ -f "$redStatusUniq".txt ]];then
if [[ -f redSSLStatus.txt ]];then
        cat "$redStatusUniq".txt
else
        echo "There are NO Failed SSL Renewals."
fi

#++++++++++++++++++++++++++++++++++
touch monitorstatus.html

python2 dataForEmail.py
sleep 1s
#    echo '</div>' >> ${SCRIPT_PATH}/monitorstatus.html
    echo '</body>' >> monitorstatus.html
    echo '</html>' >> monitorstatus.html

#----------------------------------------
    # Send email
    #----------------------------------------
    CONTENT=monitorstatus.html
    SUBJECT="SSL RENEWAL AUTOMATION ON `hostname` | Part 1"
    ( echo "Subject: $SUBJECT"
    echo "To:mohit.chaudhary@mmc.com"
    echo "MIME-Version: 1.0"
    echo "Content-Type: text/html; charset=ISO-8859-1"
    echo "Content-Disposition: inline"
    cat $CONTENT)| /usr/sbin/sendmail -t
sleep 2s

#+++++++++++++++++++++++++++++++++++


#rm -rf greenSSLStatus.txt redSSLStatus.txt monitorstatus.html

#rm -rf "$greenStatus".txt
#rm -rf "$redStatus".txt "$identRedStatus".txt "$greenStatusUniq".txt "$redStatusUniq".txt "$identRedStatusUniq".txt
#rm -rf $PEMSSLDir_location/PEM_Files
exit 1
