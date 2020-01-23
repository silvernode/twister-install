#!/bin/bash


# Colors
RED='\033[0;31m'
LRED="\033[1;31m"
BLUE="\033[0;34m"
LBLUE="\033[1;34m"
GREEN="\033[0;32m"
LGREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
LCYAN="\033[1;36m"
PURPLE="\033[0;35m"
LPURPLE="\033[1;35m"
BWHITE="\e[1m"
NC='\033[0m' # No Color

coreCloneDir="${HOME}/twister-core"
configDir="${HOME}/.twister"
htmlCloneDir="${configDir}/html"
makeJobs="j5"

twister_deps_supported(){
    echo -e "\nPlease supply one of the following aruments: \n\n"

    echo -e "void\n"
    echo -e "fedora\n\n"

    echo -e "Example: ${0} deps void\n\n"
}

twister_deps(){
    local curDistro="${1}"
    local voidPkgs="git boost boost-devel db db-devel libressl-devel base-devel"
    local fedoraPkgs="git boost boost-devel libdb-cxx-devel openssl-devel"

    if [[ "${curDistro}" == "void" ]];then
        sudo xbps-install -S ${voidPkgs}

    elif [[ "${curDistro}" = "fedora" ]];then
        sudo dnf install ${fedoraPkgs}
        sudo dnf group install "Development Tools"
    else
        echo -e "${LRED}Distro not supported ${NC}\n"
        echo -e "${YCYAN}Dependencies: boost, boost-devel, libressl-devel, db, db-devel, base-devel${NC}"
    fi 
}

twister_core(){
    local cloneRepo="https://github.com/miguelfreitas/twister-core.git"
    

    if [[ ! -d "${coreCloneDir}" ]];then
        echo -e "\n${LGREEN}${cloneDir} Creating ${coreCloneDir}${NC}\n\n"
        git clone ${cloneRepo} ${coreCloneDir}
    fi
}

twister_html(){
    local cloneRepo="https://github.com/miguelfreitas/twister-html.git"

    if [[ ! -d "${htmlCloneDir}" ]];then
        echo -e "\n${LGREEN}Creating ${htmlCloneDir}...${NC}\n\n"
        git clone ${cloneRepo} ${htmlCloneDir}
    fi
}

twister_compile(){

    cd ${coreCloneDir}
    ./bootstrap.sh
    make ${makejobs}

    if [ ! -f ${coreCloneDir}/twisterd ];then
        echo -e "\n${LRED}Twisterd was not found in ${coreCloneDir}${NC}\n\n"
        exit 1

    else
        echo -e "\n${LGREEN}Success! Now run: ${0} launch${NC}\n\n"
        exit 0
    fi


}

twister_delete(){
    echo ${coreCloneDir}
    yes | rm -v -r ${coreCloneDir}
}

twister_help(){
    echo -e "\n${0} [-h deps, build, launch, delete]\n"

    echo -e "deps        install dependencies"
    echo -e "build       clone/compile twister core & html"
    echo -e "delete      delete the twister git repository (removes everything)"
    echo -e "launch      launch twister in the default web browser"
    echo -e "kill        kill twisterd\n"
}

twister_launch(){

    
    if [[ ! -f ${coreCloneDir}/twisterd ]];then
        echo -e "\n${LRED}Cannot launch twister because twisterd does not exist in ${coreCloneDir}${NC}\n\n"
    else

        if [ ! -d ${HOME}/.twister ];then
            mkdir ${HOME}/.twister
            cp twister.conf ${HOME}/.twister
        fi
        echo -e -n "\n${LGREEN}Launch twister in your default web browser?[Y/n]:${NC} "
        read launch

        if [[ "${launch}" != "n" ]];then
            cd ${coreCloneDir}
            ./twister-control --launch
        fi
    fi
}

twister_kill(){
    if [[ $(ps -A | grep twisterd) ]];then
        killall twisterd
        echo -e "\n${LRED}Process Killed${NC}\n"

    else
        echo -e "\n${LRED}No process found${NC}\n"
    fi
}

twister_rpc(){
    echo -e "\n${YELLOW}When you launch twister, you may be asked for a name and password:${NC}"
    echo -e "${YELLOW}user: user${NC}"
    echo -e "${YELLOW}password: pwd${NC}"
    echo -e "If for some reason this isn't the case, check /$HOME/.twister"
}

if [[ -z "${1}" ]];then
    twister_help
    exit 1
elif [[ "${1}" == "-h" ]];then
    twister_help
elif [[ "${1}" = "deps" ]];then
    
    if [ -z "${2}" ];then
        twister_deps_supported
    else
        twister_deps "${2}"
    fi
elif [[ "${1}" = "build" ]];then
    twister_core
    twister_compile
    twister_launch

elif [[ "${1}" = "delete" ]];then
    twister_delete

elif [[ "${1}" = "launch" ]];then
    
    twister_html
    twister_rpc
    twister_launch

elif [[ "${1}" = "kill" ]];then
    twister_kill

else
    twister_help
    exit 1
fi
