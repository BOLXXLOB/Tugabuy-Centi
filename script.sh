#!/bin/bash
#sed -i 's/\r//' script.sh
 
Full_Project_build()
{
    #add functions to build the project
    #example: portainer, redis, API microservices
    Traefik_Portainer_compose_up;
    API_compose_up;
    echo "functions to build the project.";
}
 
#___________________________COMPOSE UP Functions
Traefik_Portainer_compose_up()
{
    sudo docker network create --internal api-internal-network;
    sudo docker network create traefik-proxy;
    cd ./traefik/;
    #Comand to create a file with "{}" text
    echo "{}" > acme.json
    sudo chmod 600 acme.json;
    sudo docker compose up -d --build;
    cd .. ;
    cd ./redis
    sudo docker compose up -d --build;
    cd ..
}
 

API_compose_up()
{
  cd ./backend/;
  sudo docker compose up -d --build;
  cd .. ;
}
 

 
#___________________________COMPOSE DOWN Functions
docker_compose_all_down()
{
    Traefik_Portainer_compose_down
    API_compose_down    
}
 
API_compose_down()
{
  cd ./backend/;
  sudo docker compose down;
  cd .. ;
}
 
 
Traefik_Portainer_compose_down()
{
    cd ./traefik/;
    sudo docker compose down;
    cd .. ;
    cd ./redis/;
    sudo docker compose down;
    cd .. ;
}
 
 
#___________________________CLEAN DOCKER
stop_backend(){
    cd ./backend/;
    sudo docker stop $(sudo docker compose ps -q)
}
 
clean_Full_docker()
{
  docker_compose_all_down
  sudo docker image rm $(sudo docker image ls -q);
  sudo docker volume rm $(sudo docker volume ls -q);
  sudo docker network rm $(sudo docker network ls -q);
}
 
#___________________________DOCKER STATUS
docker_status()
{
  sudo docker ps
}
 
#___________________________INSTALL DOCKER
install_docker()
{
  sudo apt update
  sudo apt install apt-transport-https curl gnupg-agent ca-certificates software-properties-common -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  sudo apt install docker-ce docker-ce-cli containerd.io -y
  docker version
}
 
#MENU  FUNCTIONS
 
### Colors ##
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"
 
### Color Functions ##
 
greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
redprint() { printf "${RED}%s${RESET}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }
fn_bye() { echo "Bye bye."; exit 0; }
fn_fail() { echo "Wrong option." exit 1; }
 
#___________________________BUILD MENU
buildmenu(){
  echo -ne "
$(magentaprint 'Docker Manager')
$(yellowprint '--Build Menu--')
$(magentaprint '-----------')
$(cyanprint '1) Build Full Project')
$(magentaprint '-----------')
$(greenprint '2)') Build $(greenprint 'Networks/Volumes traefik') container
$(magentaprint '-----------')
$(greenprint '3)') Build $(greenprint 'API') Container
$(magentaprint '-----------')
$(redprint '0)') Return
$(redprint '-1)') Exit
 
Choose an option:  "
    read -r ans
    case $ans in
    1)
        Full_Project_build
        fn_bye
        ;;
    2)
        Traefik_Portainer_compose_up
        mainmenu
        ;;
    3)
        API_compose_up
        mainmenu
        ;;
    0)
        mainmenu
        ;;
    -1)
        fn_bye
        ;;
    *)
        fn_fail
        ;;
    esac
}
 
composeDownmenu(){
  echo -ne "
$(magentaprint 'Docker Manager')
$(yellowprint '--Compose Down Menu--')
$(magentaprint '-----------')
$(cyanprint '1) Clean Full Docker')
$(magentaprint '-----------')
$(yellowprint '2)') Compose Down $(blueprint 'traefik') Container
$(magentaprint '-----------')
$(yellowprint '3)') Compose Down $(blueprint 'API') Container
$(magentaprint '-----------')
$(redprint '0)') Return
$(redprint '-1)') Exit
 
Choose an option:  "
    read -r ans
    case $ans in
    1)
        clean_Full_docker
        fn_bye
        ;;
    2)
        Traefik_Portainer_compose_down
        composeDownmenu
        ;;
    3)
        API_compose_down
        composeDownmenu
        ;;
    0)
        mainmenu
        ;;
    -1)
        fn_bye
        ;;
    *)
        fn_fail
        ;;
    esac
}
 
 
 
#___________________________MAIN MENU
mainmenu() {
    echo -ne "
$(magentaprint 'Docker Manager')
$(magentaprint '-----------')
$(greenprint '1)') First Time - Install docker
$(cyanprint '2) Build Full Project')
$(magentaprint '-----------')
$(greenprint '3)') Build $(greenprint 'API') Container
$(greenprint '4)') Build Menu
$(magentaprint '-----------')
$(yellowprint '5)') Compose Down $(blueprint 'API') Container
$(yellowprint '6)') Compose Down Menu
$(magentaprint '-----------')
$(cyanprint '7) Clean Full Docker')
$(yellowprint '8)') Run docker ps
$(magentaprint '-----------')
$(redprint '0)') Exit
 
Choose an option:  "
    read -r ans
    case $ans in
    1)
        install_docker
        fn_bye
        ;;
    2)
        Full_Project_build
        fn_bye
        ;;
    3)
        stop_backend
        API_compose_up
        mainmenu
        ;;
    4)
        buildmenu
        ;;
    5)
        API_compose_down
        mainmenu
        ;;
    6)
        composeDownmenu
        ;;
    7)
        clean_Full_docker
        fn_bye
        ;;
    8)
        docker_status
        mainmenu
        ;;
    0)
        fn_bye
        ;;
    *)
        fn_fail
        ;;
    esac
}
 
#se for linux
if [ "$(uname)" == "Linux" ]; then
mainmenu
fi