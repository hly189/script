#! /bin/ksh

###########################################################
# FUNCTION FOR DEPLOYING BACKUPS AND FILES, CREATING BACKUP
###########################################################
function deploy_backup_files {
	while getopts "b:d:" opt
	do
	     case $opt in
		 b|--backup)
		     backup_ans=$OPTARG
		     ;;
		 d|--deploy)
		     deploy_ans=$OPTARG
		     ;;
		 ?)
		     shift; break
		     ;;
	     esac
	done
	shift $(( OPTIND - 1 ))
	
	file_info=$1
	flag=$2
	full_file=`echo $file_info | cut -d: -f1`
	cksum_number=`echo $file_info | cut -d: -f2`
	permission=`echo $file_info | cut -d: -f3`
	file_group=`echo $file_info | cut -d: -f4`
	date_time=`echo $file_info | cut -d: -f5`
        
        path=`dirname $full_file`
        full_name=`basename $full_file`
        file_name=${full_name}
	bak=$file_name.jic
	
	if [ "$backup_ans" == "y" ]; then
		if [[ -s $path/$file_name ]]; then
			if [[ ! -s $path/$bak ]]; then
				copy $path/$file_name $path/$bak b
				echo Checksum $bak: `cksum $path/$bak | awk '{print $1}'`
			else
				if [[ -s /tmp/$full_name ]]; then
					current_file=`cksum $path/$file_name | awk '{print $1}'`
					CHECKSUM_TEMP=`cksum /tmp/$full_name | awk '{print $1}'`;
					if [[ $CHECKSUM_TEMP -ne $current_file ]]; then
						copy $path/$file_name $path/$bak b
						echo Checksum $bak: `cksum $path/$bak | awk '{print $1}'`
					else 
						echo "Backup existed: `ls -l $path/$bak`"
						echo Checksum $bak: `cksum $path/$bak | awk '{print $1}'`
					fi
				else
					copy $path/$file_name $path/$bak b
					echo Checksum $bak: `cksum $path/$bak | awk '{print $1}'`
				fi
			fi
		else
			echo "File not existed, can't create backup: $path/$file_name"
			
		fi
	fi
	
	if [ "$deploy_ans" == "y" ]; then
		#Check cksum and deploy $full_name
		if [[ -s /tmp/$full_name ]]; then
			CHECKSUM_TEMP=`cksum /tmp/$full_name | awk '{print $1}'`;
			if [[ -s $path/$file_name ]]; then 
				current_file=`cksum $path/$file_name | awk '{print $1}'`
				if [[ $CHECKSUM_TEMP -eq $current_file ]]; then
					echo "File already deployed:" `ls -l $path/$file_name`
					echo "Checksum $file_name: $current_file"
					return 0
				fi
			fi	
			if [[ $CHECKSUM_TEMP -eq $cksum_number ]]; then
				copy /tmp/$full_name $path/$file_name
				chmod $permission $path/$file_name
				chgrp $file_group $path/$file_name
				if [[ ! -z $date_time ]]; then touch -t $date_time $path/$file_name; fi
				echo $(ls -l  $path/$file_name)
				echo Checksum $file_name: `cksum $path/$file_name | awk '{print $1}'`
			else
				echo "Err, Bad Check Sum, file will not be deployed."
			fi
		else
			echo "Err, FILE NOT FOUND: $full_name"
		fi
	fi
	
	if [ "$flag" == "bak" ]; then
		if [[ -s $path/$bak ]]; then
			check_sum_bk=`cksum $path/$bak | awk '{print $1}'`
			if [[ -s $path/$file_name ]]; then
				check_sum_file=`cksum $path/$file_name | awk '{print $1}'`
				if [[ $check_sum_bk -ne $check_sum_file ]]; then
					copy $path/$bak $path/$file_name
					echo Checksum $file_name: $check_sum_bk
				else
					echo "$file_name: Old version already exitst"
				fi
			else
				copy $path/$bak $path/$file_name  
				echo Checksum $file_name: $(cksum $path/$file_name | awk '{print $1}')
			fi

		else
			echo "File $path/$bak does not exists"
		fi
		
	fi
}

#Sub Function for copy and check success
function copy {
	original=$1
	destination=$2
	flag=$3
	
	cp -pf $original $destination
	if [[ ! -f $destination ]]; then 
		echo Err, failed to copy: $destination
	else
		if [ "$flag" == "b" ]; then
			echo "Backup: $(ls -l $destination)"
		else
			echo "Deploy: $destination"
		fi
	fi
}


######################################
# FUNCTION FOR CREATING DIRECTORY
######################################
function creating_directory {
	
	file=$1
	file_dir=$(echo $file | cut -d":" -f1)
	permission=$(echo $file | cut -d":" -f2)

	if [ ! -d $file_dir ]; then
		mkdir $file_dir
		if [[ ! -z $permission ]]; then
			chmod $permission $file_dir
		fi
		if [ -d $file_dir ]; then
			echo "Created directory: `ls -ld $file_dir`"
		else
			echo "Deployed Failed: $file_dir"
			exit 1
		fi
	else
		if [[ ! -z $permission ]]; then 
			chmod $permission $file_dir 
		fi 
		echo "Dir existed: $(ls -ld $file_dir)"
	fi
}

######################################
# FUNCTION FOR CHANGING CRONTAB
######################################
function edit_backup_crontab {
        change_number=$1
        cron_change="$2"
        flag=$3
        user=$(whoami)
        file_name=`echo "$cron_change" | awk '{print $6}'`
        path=`dirname $file_name`

        NEW=/tmp/${change_number}_cron_${user}.new
        TMP1=/tmp/${change_number}_${user}_checking1
        TMP2=/tmp/${change_number}_${user}_checking2

	cat /dev/null > $NEW
        if [ "$flag" != "b" ]; then
	BAK=/tmp/${change_number}_cron_${user}.bak		
	if [[ -s $BAK ]]; then
			BAK=$(ls -1t /tmp/${change_number}_cron_${user}.ba* | sort -t'.' -k3 | tail -n 1)
			crontab -l > /tmp/cron_${change_number}.tmp
			if diff /tmp/cron_${change_number}.tmp $BAK > /dev/null 2>&1; then 
				echo "Backup already exist: $(ls -l $BAK)"
			else 
				BAK=$BAK.$(date +%Y%m%d%H%M)
				crontab -l > $BAK
			fi
			 
		else 
			BAK=/tmp/${change_number}_cron_${user}.bak
			crontab -l > $BAK
		fi
                
		if crontab -l | grep $file_name > /dev/null 2>&1; then
                        IFS=$'\n'
                        for i in `cat $BAK`
                        do
				file_cron=$(echo $i | awk '{print $6}')
                                if [[  $file_cron == *"$file_name"* ]]; then
                                        echo "Found: $i"
                                        echo "$cron_change" >> $NEW
                                else
                                        echo $i >> $NEW
                                fi
                        done
                        unset IFS


                        update_cron $BAK $NEW $TMP1 $TMP2 $file_name
                else
                        echo "Cron entry is not existed, add new"
                        (crontab -l ; echo "$cron_change")| crontab -
			echo "$(crontab -l | grep $file_name)"
                fi
        else
                count_bk=$(ls -1t /tmp/${change_number}_cron_${user}.ba* | wc -l)
                if [[ $count_bk -gt 1 ]]; then
                        ORIGINAL=$(printf "%s\n" /tmp/${change_number}_cron_${user}.ba* | sort -t'.' -k3 | tail -n 1)
                else
                        ORIGINAL=/tmp/${change_number}_cron_${user}.bak
                        if [[ ! -s $ORIGINAL ]]; then
                                echo Backup does not exist
                                exit 0
                        fi
                fi

                # Check to see if the entry is there. If not, it will update a new one.
                IFS=$'\n'
                for i in `cat $ORIGINAL`
                do
			file_cron=$(echo $i | awk '{print $6}')
                        if [[ $i == *"$file_name"* ]]; then
                                echo "Found: $i"
                                if grep $file_name $ORIGINAL > /dev/null 2>&1; then
                                        grep $file_name $ORIGINAL >> $NEW
                                else
                                        echo " " >> $NEW
                                fi
                        else
                                echo $i >> $NEW
                        fi
                done
                unset IFS
                CURRENT_CRON=/tmp/${change_number}_cron_${user}C.bak
                crontab -l > $CURRENT_CRON
                update_cron $CURRENT_CRON $NEW $TMP1 $TMP2 $file_name
        fi

}
# FUNCTION FOR UPDATING CRON JON
function update_cron {
	input=$1
	NEW=$2
	TMP1=$3
	TMP2=$4
	FILE_NAME=$5

	
	if diff $NEW $input > /dev/null 2>&1; then
		echo "Cronjob is existed"
	else
		echo "Updating Cron"
		crontab -r
		crontab $NEW
		crontab -l | grep -v '^#' > $TMP1
		grep -v '^#' $NEW > $TMP2

		if diff $TMP1 $TMP2; then
			echo "Updated Success"
		else
			echo "Updated Failed"
			exit 1
		fi
		rm -f $TMP1 $TMP2
	fi
}


###################################
#Updating sql 
###################################
function running_sql {

        user=$1
        query=$2
        tempsql=$3
        check=$4
	typesql=$5

        if [[ -s /etc/redhat-release ]]; then

                echo -n "SET ECHO OFF FEED OFF "       > $tempsql
                echo -n "HEADING OFF FLUSH OFF "      >> $tempsql
                echo -n "NEWPAGE NONE PAGESIZE 0 "    >> $tempsql
                echo -n "LINESIZE 32680 TERMOUT OFF " >> $tempsql
                echo -n "SERVEROUT OFF VERIFY OFF "   >> $tempsql
                if [[ $typesql == "select" ]];then
			echo -n "TRIM ON TRIMS ON NEWPAGE NONE COLSEP | FLUSH OFF FEED OFF "   >> $tempsql
                fi
		echo    "TERM OFF TRIMSPOOL ON"       >> $tempsql
                echo "$query"                 >> $tempsql


                export ORACLE_SID=$user
                $ORACLE_HOME/bin/sqlplus -s / < $tempsql > $check 2>&1
                unset ORACLE_SID
        else
                source /appl/db2/db2isp00/sqllib/db2profile
                if [[ $typesql == "select" ]];then 
			echo "EXPORT TO $check OF DEL MODIFIED BY NOCHARDEL COLDEL|" > $tempsql
		fi
		echo "$query" >> $tempsql
                $DB2DIR/bin/db2 "connect to $user"
                $DB2DIR/bin/db2 -txf $tempsql 
                $DB2DIR/bin/db2 "disconnect $user"

        fi

}


###################################
#Function to edit cron.profile
###################################
function edit_cron_profile {
        value="$1"
        CronVariable=$(echo $value | cut -d"=" -f 1)
        CronValue=$(echo $value | cut -d "=" -f 2)
        CronProfile=/u/chaintrk/Cronstuf/cron.profile

        if grep "$value" $CronProfile > /dev/null 2>&1; then
                echo Good Cron.profile - no needed to update
        else
                echo Before Updated: `grep $CronVariable $CronProfile | grep -v export`
                sed -i "/$CronVariable=.*/c\\$value" $CronProfile;
                echo After Updated: `grep "$value" $CronProfile`

                if grep "$value" $CronProfile > /dev/null 2>&1; then
                        echo Good Update Success
                        echo ""
                else
                        echo Err, updated failed
                        echo ""
                fi
        fi

}
###################################
#Function to edit config file 
###################################
function edit_file {
        value="$1"
        file=$2
	file_variable=$(echo $value | cut -d"=" -f 1)
        file_value=$(echo $value | cut -d "=" -f 2)

	echo Before Updated: `grep "$file_variable" $file`
	sed -i "/$file_variable=.*/c\\$value" $file;
	echo After Updated: `grep "$value" $file`

	if grep "$value" $file > /dev/null 2>&1; then
		echo Good Update Success
		echo ""
	else
		echo Err, updated failed
		echo ""
	fi

}
