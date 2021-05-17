#!/bin/bash

# this directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/"

cd $DIR

JAR="opensha-all.jar"
JAR_URL="http://opensha.usc.edu/apps/opensha/nightlies/latest/$JAR"

if [[ -e $JAR && $ETAS_DISABLE_JAR_UPDATE -eq 1 ]];then
	# jar file already exists, and we have disabled update jecks
	exit 0;
fi

echo "Checking for updates to OpenSHA. You can disable these checks by setting the environmental variable ETAS_DISABLE_JAR_UPDATE=1"

DOWNLOAD=0
UPDAYS="${ETAS_JAR_UPDATE_DAYS:-7}"

if [[ ! -e ./git && ! -e $DIR/$JAR ]];then
	echo "We need to download/build OpenSHA. The preferred method is to checkout the OpenSHA project from GitHub and build it. Checking if we have java compilers available (must have version 11 or greater):"
	javac --version
	RET=$?
	if [[ $RET -eq 0 ]];then
		# check for git
		echo "Checking if we have git installed:"
		git --version
		RET=$?
		if [[ $RET -ne 0 ]];then
			echo "Did not find git"
		fi
	else
		echo "Did not find java compilers"
	fi
	if [[ $RET -ne 0 ]];then
		echo "We will instead download a nightly build and update every $UPDAYS days. Change update frequency by setting ETAS_JAR_UPDATE_DAYS.";
		DOWNLOAD=1
	else
		echo "javac and git are available and building is preferred for smart update checking, but you can optionally download (and routinely re-download) nightly builds instead."
		read -r -p "     Would you like to use nightly builds instead? [y/N] " response
		case "$response" in
			[yY][eE][sS]|[yY]) 
				DOWNLOAD=1
				;;
			*)
				DOWNLOAD=0
				;;
		esac
	fi
elif [[ -e $DIR/$JAR && ! -e .git ]];then
	if [[ $(find "$DIR/$JAR" -mtime +$UPDAYS -print) ]]; then
		read -r -p "     $JAR is out of date ($UPDAYS days old), do you wish to download a new version? [Y/n] " response
		case "$response" in
			[nN][oO]|[nN]) 
				DOWNLOAD=0
				echo "Skipping jar download. You can change the frequency of this check by setting ETAS_JAR_UPDATE_DAYS."
				;;
			*)
				DOWNLOAD=1
				;;
		esac
		DOWNLOAD=1
	fi
fi

REBUILD=0

if [[ $DOWNLOAD -eq 1 ]];then
	if [[ -e $DIR/$JAR ]];then
		mv $DIR/$JAR $DIR/${JAR}.bak
	fi
	wget $JAR_URL
	if [[ ! -e $DIR/$JAR ]];then
		if [[ -e $DIR/${JAR}.bak ]];then
			echo "Download failed, will re-use old jar file"
			mv $DIR/${JAR}.bak $DIR/$JAR
		else
			echo "Download failed!"
			exit 1
		fi
	fi
elif [[ -e $DIR/git/opensha ]];then
	cd $DIR/git/opensha
	echo "Checking for git updates in `pwd`"
	git remote update
	UPSTREAM='@{u}'
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse "$UPSTREAM")
	BASE=$(git merge-base @ "$UPSTREAM")
	if [ $LOCAL = $REMOTE ]; then
		echo "Up-to-date"
		if [[ ! -e build/libs/opensha-all.jar ]];then
			echo "No jar exists, will rebuild..."
			REBUILD=1
		fi
	elif [ $LOCAL = $BASE ]; then
		echo "Pulling latest updates..."
		git pull
		echo "Jar needs to be updated, will rebuild..."
		REBUILD=1
	else
		echo "ERROR: The opensha repository in `pwd` is corrupt or has been manually updated."
		echo "Please back up any changes you made, then remove `pwd` and run this script again."
		exit 1
	fi
	if [[ $REBUILD -eq 0 && ! -e $DIR/$JAR ]];then
		echo "We have already checked out OpenSHA, but don't have a jar file, forcing a rebuild."
		REBUILD=1
	fi
elif [[ ! -e $DIR/$JAR ]];then
	echo "Need to check out OpenSHA from GitHub (this may take a little while and only needs to happen once)"
	cd $DIR
	mkdir git
	cd git
	git clone https://github.com/opensha/opensha.git
	if [[ ! -e opensha ]];then
		echo "Git checkout failed, please examine any error messages above and try again."
		exit 1
	fi
	REBUILD=1
fi

if [[ $REBUILD -eq 1 ]];then
	cd $DIR/git/opensha
	echo "Building OpenSHA jar with Gradle in `pwd`"
	./gradlew fatJar
	if [[ -e build/libs/$JAR ]];then
		cp build/libs/$JAR $DIR/$JAR
	else
		echo "Build failed. Make sure that you have java development kit 11 or higher installed and set as your default JDK, and examine any other error messages above."
		read -r -p "     Would you like to download nighly build instead? [Y/n] " response
		case "$response" in
			[nN][oO]|[nN]) 
				DOWNLOAD=0
				cd $DIR
				wget $JAR_URL
				;;
			*)
				;;
		esac
	fi
fi

if [[ ! -e $DIR/$JAR ]];then
	echo "We failed to find, download, or build an OpenSHA jar. Examine any error messages above and try again"
	exit 1
fi
