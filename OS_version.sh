function OS_type {
	# Recognize OS type:
	if [[ -f /etc/redhat-release ]]; then
        OStype="CentOS"
	elif [[ -f /usr/bin/lsb_release ]]; then
        OStype="Ubuntu"
	elif [[ -f /usr/bin/sw_vers ]]; then
		OStype="OSX"
	else
		error_msg "This script supports CentOS \ RHEL, OSX or Ubuntu OS ditributions!"
		exit 102
	fi
}

function OS_version {
    if [[ ${OStype} == "CentOS" ]]; then
        if [[ `cat /etc/redhat-release` == "CentOS Linux release 7."* ]]; then
			OSversion=7
		elif [[ `cat /etc/redhat-release` == "CentOS release 6."* ]]; then
			OSversion=6
        else
            error_msg "Your CentOS version is not supported yet!"
            exit 103
		fi
    elif [[ ${OStype} == "Ubuntu" ]]; then
        OSval=`/usr/bin/lsb_release -rs`
        case ${OSval} in
        14.04)
            OSname='Trusty Tahr'
            OSversion="14.04"
            ;;
        14.10)
            OSname='Utopic Unicorn'
            OSversion="14.10"
            ;;
        15.04)
            OSname='Vivid Vervet'
            OSversion="15.04"
            ;;
        15.10)
            OSname='Wily Werewolf'
            OSversion="15.10"
            ;;
        16.04)
            OSname='Xenial Xerus'
            OSversion="16.04"
            ;;
        16.10)
            OSname='Yakkety Yak'
            OSversion="16.10"
            ;;
        17.04)
            OSname='Zesty Zapus'
            OSversion="17.04"
            ;;
        17.10)
            OSname='Artful Aardvark'
            OSversion="17.10"
            ;;
        18.04)
            OSname='Bionic Beaver'
            OSversion="18.04"
            ;;
        18.10)
            OSname='Cosmic Cuttlefish'
            OSversion="18.10"
            ;;
        19.04)
            OSname='Disco Dingo'
            OSversion="19.04"
            ;;
        19.10)
            OSname='Eoan Ermine'
            OSversion="19.10"
            ;;
        20.04)
            OSname='Focal Fossa'
            OSversion="20.04"
            ;;
        20.10)
            OSname='Groovy Gorilla'
            OSversion="20.10"
            ;;
        *)
            error_msg "Your Ubuntu version is not supported yet!"
            exit 104
            ;;
       esac
    elif [[ ${OStype} == "OSX" ]]; then
		OSval=`sw_vers -productVersion`
		case ${OSval} in
            10.6.*)
                OSname='Snow Leopard'
                OSversion="10.6"
                ;;
            10.7.*)
                OSname='Lion'
                OSversion="10.7"
                ;;
            10.8.*)
                OSname='Mountain Lion'
                OSversion="10.8"
                ;;
            10.9.*)
                OSname='Mavericks'
                OSversion="10.9"
                ;;
            10.10.*)
                OSname='Yosemite'
                OSversion="10.10"
                ;;
            10.11.*)
                OSname="El Capitan"
                OSversion="10.11"
                ;;
            10.12.*)
                OSname='High Sierra'
                OSversion="10.12"
                ;;
            10.13.*)
                OSname='High Sierra'
                OSversion="10.13"
                ;;
            10.14.*)
                OSname='Mojave'
                OSversion="10.14"
                ;;
            10.14.*)
                OSname='Mojave'
                OSversion="10.14"
                ;;
            10.15 | 10.15.*)
                OSname='Catalina'
                OSversion="10.15"
                ;;
            11.0.*)
                OSname='Big Sur'
                OSVersion="11.0"
                ;;
            *)
                error_msg "Your Mac OS version is not supported yet!"
                exit 105
        esac
    fi
}