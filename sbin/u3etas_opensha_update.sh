#!/bin/bash

DEFAULTS=0
while getopts d name
do
	case $name in
	d)    DEFAULTS=1;;
	?)   printf "Usage: %s: [-d]\n" $0
		exit 2;;
	esac
done

if [[ $DEFAULTS -eq 1 ]];then
	echo "Forcing all default options due to -d flag"
fi

# this directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/../opensha"

if [[ ! -e $DIR ]];then
	echo "creating $DIR"
	mkdir $DIR
fi
cd $DIR

JAR="opensha-all.jar"
JAR_URL="https://data.opensha.org/apps/opensha/etas_launcher/$JAR"
HASH_URL="https://data.opensha.org/apps/opensha/etas_launcher/build-version.githash"
GIT_BRANCH="${ETAS_GIT_BRANCH:-etas-launcher-stable}"

if [[ -e $JAR && $ETAS_JAR_DISABLE_UPDATE -eq 1 ]];then
	# jar file already exists, and we have disabled update checks
	exit 0;
fi

echo "Checking for updates to OpenSHA. You can disable these checks by setting the environmental variable ETAS_JAR_DISABLE_UPDATE=1"

DOWNLOAD="${ETAS_JAR_FORCE_DOWNLOAD:-0}"
REBUILD="${ETAS_JAR_FORCE_REBUILD:-0}"
UPDAYS="${ETAS_JAR_UPDATE_DAYS:-7}"
if [[ $UPDAYS -lt 1 ]];then
	UPDAYS=1
fi

if [[ ! -e ./git && ! -e $DIR/$JAR ]];then
	echo "We need to download and/or build OpenSHA. The preferred method is to checkout the OpenSHA project from GitHub and build it. Checking if we have java compilers available (must have version 11 or greater):"
	javac --version
	RET=$?
	if [[ $RET -eq 0 ]];then
		# check for git
		echo "	Checking if we have git installed:"
		git --version
		RET=$?
		if [[ $RET -ne 0 ]];then
			echo "	Did not find git"
		fi
	else
		echo "	Did not find java compilers"
	fi
	if [[ $RET -ne 0 ]];then
		echo "We will instead download a nightly build and update every $UPDAYS days. Change update frequency by setting ETAS_JAR_UPDATE_DAYS.";
		DOWNLOAD=1
	elif [[ $DEFAULTS -ne 1 ]];then
		echo "javac and git are available and building is preferred for smart update checking, but you can optionally download (and routinely re-download) nightly builds instead."
		read -r -p "	Would you like to use nightly builds instead? [y/N] " response
		case "$response" in
			[yY][eE][sS]|[yY]) 
				DOWNLOAD=1
				;;
			*)
				DOWNLOAD=0
				;;
		esac
	fi
elif [[ -e $DIR/$JAR && ! -e $DIR/git/opensha ]];then
	if [[ $(find "$DIR/$JAR" -mtime +$UPDAYS -print) ]]; then
		echo "	$DIR/$JAR may be out of date (>$UPDAYS days old)"
		cd $DIR
		UP_TO_DATE=0
		if [[ -e build-version.githash ]];then
			echo "	fetching hash of current remote version..."
			wget --quiet -O build-version.githash.tmp $HASH_URL
			CUR_HASH=`cat build-version.githash`
			REMOTE_HASH=`cat build-version.githash.tmp`
#			echo "current: $CUR_HASH"
#			echo "remote: $REMOTE_HASH"
			if [[ $CUR_HASH = $REMOTE_HASH ]];then
				echo "up-to-date, skipping download. will check again in $UPDAYS days"
				touch $DIR/$JAR
				UP_TO_DATE=1
			else
				echo "new version detected! local=$CUR_HASH, remote=$REMOTE_HASH"
			fi
			rm build-version.githash.tmp
		fi
		if [[ $UP_TO_DATE -ne 1 ]];then
			if [[ $DEFAULTS -eq 1 ]];then
				echo "Will download new jar file"
				DOWNLOAD=1
			else
				read -r -p "	$JAR is out of date ($UPDAYS days old), do you wish to download a new version? [Y/n] " response
				case "$response" in
					[nN][oO]|[nN]) 
						DOWNLOAD=0
						echo "Skipping jar download, will check again in $UPDAYS days. You can change the frequency of this check by setting ETAS_JAR_UPDATE_DAYS."
						touch $DIR/$JAR
						;;
					*)
						DOWNLOAD=1
						;;
				esac
			fi
		fi
	fi
fi

if [[ $DOWNLOAD -ne 1 && -e $DIR/git/opensha ]];then
	cd $DIR/git/opensha
	CUR_BRANCH=`git rev-parse --abbrev-ref HEAD`
	echo "Checking for git updates in `pwd`"
	echo "	On branch: $CUR_BRANCH"
	if [[ $CUR_BRANCH != $GIT_BRANCH ]];then
		echo "	Switching to branch: $GIT_BRANCH"
		git fetch
		git checkout $GIT_BRANCH
	fi
	git remote update
	UPSTREAM='@{u}'
	LOCAL=$(git rev-parse HEAD)
	if [[ $? -ne 0 ]];then
		echo "WARNING: could not detect git revision, you might have an outdated git client, or the opensha repository in `pwd` is corrupt."
		echo "Skipping update";
		exit 1
	fi
	REMOTE=$(git rev-parse "$UPSTREAM")
	BASE=$(git merge-base HEAD "$UPSTREAM")
	if [ $LOCAL = $REMOTE ]; then
		echo "Up-to-date"
		if [[ -e build/libs/opensha-all.jar ]];then
			# see if we previously skipped a rebuild
			if [[ -e $DIR/build-version.githash && $(find "$DIR/$JAR" -mtime +$UPDAYS -print) ]]; then
				CUR_HASH=`cat $DIR/build-version.githash`
				if [ $LOCAL != $CUR_HASH ];then
					echo "  $DIR/$JAR is >$UPDAYS days old, and we skipped a previous build (build hash=$CUR_HASH, git hash=$LOCAL)"
					if [[ $DEFAULTS -eq 1 ]];then
						echo "Will rebuild"
						REBUILD=1
					else
						read -r -p "    Would you like to rebuild now? [Y/n] " response
						case "$response" in
							][oO]|[nN])
								echo "Skipping jar rebuild, will prompt again in $UPDAYS days or next time the upstream repository is updated. You can change the frequency of this check by setting ETAS_JAR_UPDATE_DAYS."
								touch $DIR/$JAR
								;;
							*)
								REBUILD=1
								;;
						esac
					fi
				fi
			fi
		else
			echo "No jar exists, will rebuild..."
			REBUILD=1
		fi
	elif [ $LOCAL = $BASE ]; then
		echo "The internal OpenSHA repository (branch: $GIT_BRANCH) is out of date and needs to be updated/rebuilt."
		echo "Pulling latest updates..."
		git pull
		if [[ $DEFAULTS -eq 1 ]];then
			echo "Will rebuild"
			REBUILD=1
		elif [[ -e $DIR/$JAR ]];then
			read -r -p "    Would you like to rebuild now? [Y/n] " response
	                case "$response" in
				][oO]|[nN])
					echo "Skipping jar rebuild, will prompt again in $UPDAYS days or next time the upstream repository is updated. You can change the frequency of this check by setting ETAS_JAR_UPDATE_DAYS."
					touch $DIR/$JAR
					;;
				*)
					REBUILD=1
					;;
				esac
		else
			echo "Jar doesn't exist (first time), will build."
			REBUILD=1
		fi
	else
		echo "ERROR: The opensha repository in `pwd` is corrupt or has been manually updated."
		echo "Please back up any changes you made, then remove `pwd` and run this script again."
		exit 1
	fi
	if [[ $REBUILD -eq 0 && ! -e $DIR/$JAR ]];then
		echo "We have already checked out OpenSHA, but don't have a jar file, forcing a rebuild."
		REBUILD=1
	fi
elif [[ $DOWNLOAD -ne 1 && ! -e $DIR/$JAR ]];then
	echo "Need to check out OpenSHA from GitHub (this may take a little while and only needs to happen once)"
	cd $DIR
	mkdir git
	cd git
	git clone https://github.com/opensha/opensha.git
	if [[ ! -e opensha ]];then
		echo "Git checkout failed, please examine any error messages above and try again."
		exit 1
	fi
	if [[ ! -z "$GIT_BRANCH" ]];then
		cd opensha
		git checkout $GIT_BRANCH
	fi
	REBUILD=1
fi

if [[ $REBUILD -eq 1 ]];then
	cd $DIR/git/opensha
	echo "Building OpenSHA jar with Gradle in `pwd`"
	./gradlew fatJar
	RET=$?
	if [[ $RET -eq 0 && -e build/libs/$JAR ]];then
		cp build/libs/$JAR $DIR/$JAR
		LOCAL=$(git rev-parse HEAD)
		if [[ $? -ne 0 ]];then
			echo "WARNING: couldn't detect git revision, your git client may be out of date?"
		else
			echo "$LOCAL" > "$DIR/build-version.githash"
		fi
	else
		echo "Build failed. Make sure that you have java development kit 11 or higher installed and set as your default JDK, and examine any other error messages above."
		if [[ $DEFAULTS -eq 1 ]];then
			echo "Will download nightly build instead"
			DOWNLOAD=1
		else
			read -r -p "	Would you like to download nighly build instead? [Y/n] " response
			case "$response" in
				[nN][oO]|[nN]) 
					DOWNLOAD=0
					;;
				*)
					DOWNLOAD=1
					;;
			esac
		fi
	fi
fi

if [[ $DOWNLOAD -eq 1 ]];then
	if [[ -e $DIR/$JAR ]];then
		mv $DIR/$JAR $DIR/${JAR}.bak
	fi
	if [[ -e $DIR/build-version.githash ]];then
		mv $DIR/build-version.githash $DIR/build-version.githash.bak
	fi
	cd $DIR
	wget $JAR_URL
	wget --quiet $HASH_URL
	if [[ ! -e $DIR/$JAR ]];then
		if [[ -e $DIR/${JAR}.bak ]];then
			echo "Download failed, will re-use old jar file"
			mv $DIR/${JAR}.bak $DIR/$JAR
			if [[ -e $DIR/build-version.githash.bak ]];then
				mv $DIR/build-version.githash.bak $DIR/build-version.githash
			fi
		else
			echo "Download failed!"
			exit 1
		fi
	else
		if [[ -e $DIR/${JAR}.bak ]];then
			rm $DIR/${JAR}.bak
		fi
		if [[ -e $DIR/build-version.githash.bak ]];then
			rm $DIR/build-version.githash.bak
		fi
	fi
fi

if [[ ! -e $DIR/$JAR ]];then
	echo "FATAL: We failed to find, download, and/or build an OpenSHA jar. Examine any error messages above and try again"
	exit 1
fi
