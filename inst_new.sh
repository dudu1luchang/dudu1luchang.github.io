#!/bin/bash
APPROOT=$(dirname $(readlink -e $0))


[[ $(id -u) != 0 ]] && echo -e "请使用root权限运行安装脚本， 通过sudo su root切换再来运行" && exit 1

name = "端对端加密隧道流量混淆转发 - 加密端（本地端）"

down_host = "http://download.minerhome.org"



cmd="apt-get"
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
    if [[ $(command -v yum) ]]; then
        cmd="yum"
    fi
else
    echo "此脚本不支持该系统" && exit 1
fi


pid=`ps -ef | grep "mh_tunnel" |  awk '{print $2}'`
if [ -n "$pid" ]
then
	echo "kill running mh_tunnel $pid"
	kill -9 $pid
fi



check_done() {

    pid=`ps -ef | grep "12510" |  awk '{print $2}'`
    if [ -n "$pid" ]
    then
        echo -e "\n\n" 
        echo -e "--------------------------------------------------------"
        echo -e "\n" 
        echo -e "安装成功， 端对端加密隧道流量混淆转发 - 加密端（本地端）- 已经在运行......" 
        echo -e "详细用法请上 https://minerhome.org 网站查阅\n" 
        echo -e "\n" 
        echo -e "--------------------------------------------------------"
        echo -e "\n" 
    else        
        echo -e "\n\n" 
        echo "安装不成功，请重启后重新安装"   
        echo "出现各种选择，请按 确认/OK"
        echo -e "\n\n" 
    fi    


}



f2_cn(){
    echo "  1、鱼池 - 安装 install f2pool"
    echo "  2、鱼池 - 设置 - 设置你的挖矿帐号及矿池地址 set your wallet"
    echo "  3、鱼池 - 查看设置信息 view"
    read -p "$(echo -e "请选择choose[1-2]：")" choose
    case $choose in
    1)
        inst_f2_cn
        ;;
    2)
        set_f2_cn
        ;;
    3)
        view_config_f2
        ;;
    *)
        echo "输入错误请重新输入！"
        ;;
    esac
}



damo_cn(){
    echo "  1、达摩 - 安装 install damominer"
    echo "  2、达摩 - 设置 - 设置你的钱包及代理地址 set wallet"
    echo "  3、达摩 - 查看设置信息 view"
    echo "  4, 达摩 - 建立新钱包 - 安全性未知 create new wallet"
    read -p "$(echo -e "请选择choose[1-4]：")" choose
    case $choose in
    1)
        inst_damo_cn
        ;;
    2)
        set_damo_cn
        ;;
    3)
        view_config_damo
        ;;
    4) 
        damo_new_account
        ;;
    *)
        echo "输入错误请重新输入！"
        ;;
    esac
}




hpool_cn(){
    echo "  1、哈池 - 安装  install hpool"
    echo "  2、哈池 - 设置 - 设置你的apikey等  set your apikey"
    echo "  3、哈池 - 查看设置信息 view your setting"
    echo "  0、退出 exit"
    read -p "$(echo -e "请选择choose[1-3]：")" choose
    case $choose in
    0)
         exit 1
        ;;
    1)
        inst_hpool_cn
        ;;
    2)
        set_hpool_cn
        ;;
    3)
        view_config_hpool
        ;;
    *)
        echo "输入错误请重新输入！"
        ;;
    esac
}



zkrush(){
    echo "  1、zkrush - 安装  install zkrush"
    echo "  2、zkrush - 设置 - 设置你的挖矿帐号, 矿工名, 矿池地址"
    echo "  3、zkrush - 查看设置信息 view your setting"
    echo "  0、退出 exit"
    read -p "$(echo -e "请选择choose[1-3]：")" choose
    case $choose in
    0)
         exit 1
        ;;
    1)
        inst_zkrush
        ;;
    2)
        set_zkrush
        ;;
    3)
        view_config_zkrush
        ;;
    *)
        echo "输入错误请重新输入！"
        ;;
    esac
}











inst_common() {
    # 通用
    # ufw disable

    systemctl stop mh_aleo  >> /dev/null
    systemctl disable mh_aleo  >> /dev/null
    rm -f /lib/systemd/system/mh_aleo.service
    rm -f /etc/systemd/system/mh_aleo.service


    $cmd update -y
    $cmd install curl -y
    $cmd install wget -y
    $cmd install net-tools -y

    create_dirs
 
    # wget  --no-check-certificate  http://download.minerhome.org/aleo/data/aleo.sh   -O  /root/aleo/aleo.sh
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/mh_aleo.service   -O  /lib/systemd/system/mh_aleo.service
    


    inst_tunnel_cn
    inst_driver
    inst_cuda  

}


start(){
    chmod +x /root/aleo/*
    systemctl daemon-reload
    systemctl enable mh_aleo  >> /dev/null
    systemctl restart mh_aleo  &   
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "手工重启之后, 再次运行此脚本可进行设置/查看挖矿状况......"
    echo "reboot and run this script, set/view......"
    echo -e "\n"   
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    sleep 5s
    check_log
}



install() {
    
    # ufw disable
    $cmd update -y
    $cmd install curl -y
    $cmd install wget -y
    $cmd install net-tools -y
    
    mkdir /root/aleo
    mkdir /root/aleo/f2pool
    mkdir /root/aleo/damo
    mkdir /root/aleo/hpool

    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/aleo.sh   -O  /root/aleo/aleo.sh
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/mh_aleo.service   -O  /lib/systemd/system/mh_aleo.service
    
    inst_tunnel_cn
    inst_driver
    inst_cuda

    inst_aleo_f2_cn
 
    systemctl daemon-reload
    systemctl enable mh_aleo  >> /dev/null
    systemctl restart mh_aleo  &   


}



uninstall() {    
        clear
        echo -e "\n" 
        echo -e "\n" 
        echo -e "\n" 
        echo -e "\n" 
        echo -e "\n" 
        echo "正在卸载aleo挖矿软件......aleo miner uninstalling...."
        systemctl stop mh_aleo  &
        systemctl disable mh_aleo  >> /dev/null
        rm -rf /root/aleo
        rm -rf /lib/systemd/system/mh_aleo.service        
        rm -f /etc/systemd/system/mh_aleo.service

        echo "卸载完记得重启 reboot after uninstall"
}







inst_driver(){
    clear
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "正在安装显卡驱动 nvidia driver installing..."
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    sleep 5s
    $cmd install build-essential  -y
    $cmd install ubuntu-drivers-common  -y
    $cmd install nvidia-driver-515-server  -y
}


inst_cuda(){
    clear
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "正在安装cuda, cuda installing"
    echo "如果出现Abort Continue可以选择 Continue"
    echo "if Abort Continue appears, select Continue"
    echo "输入 accept | enter accept"
    echo "出现CUDA Installer时把Driver去掉, 光标移到 Install然后回车"
    echo "when CUDA Installer Driver appear, unselect Driver, move arrow to Install and hit enter"
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    sleep 10s   
    if test ! -f "$APPROOT/cuda_11.7.1_515.65.01_linux.run"; then
        echo "文件不存在, 重新下载"
       wget https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run  -O $APPROOT/cuda_11.7.1_515.65.01_linux.run
    fi
    sudo bash cuda_11.7.1_515.65.01_linux.run
}


inst_tunnel_cn(){
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "正在安装加密隧道 mh_tunnel installing..."
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    sleep 5s
    rm -rf /etc/rc.local
    rm -rf /root/mh_tunnel
    mkdir /root/mh_tunnel                                                           
    wget  --no-check-certificate  http://download.minerhome.org/mh_tunnel/scripts/tunnel/pools.txt  -O  /root/mh_tunnel/pools.txt
    wget  --no-check-certificate  http://download.minerhome.org/mh_tunnel/scripts/tunnel/httpsites.txt  -O  /root/mh_tunnel/httpsites.txt
    wget  --no-check-certificate  http://download.minerhome.org/mh_tunnel/scripts/tunnel/run_mh_tunnel.sh  -O  /root/mh_tunnel/run_mh_tunnel.sh
    wget  --no-check-certificate  http://download.minerhome.org/mh_tunnel/scripts/tunnel/mh_tunnel.service  -O  /lib/systemd/system/mh_tunnel.service
    wget  --no-check-certificate  http://download.minerhome.org/mh_tunnel/releases/mh_tunnel/v7.0.0/mh_tunnel    -O /root/mh_tunnel/mh_tunnel

    chmod +x /root/mh_tunnel/*
    systemctl daemon-reload
    systemctl enable mh_tunnel  >> /dev/null
    systemctl restart mh_tunnel  &    
}


set_f2_cn(){

    echo
    while :; do
        echo -e "请输入你的鱼池挖矿帐号, 如viponedream"
        echo -e "input your account on f2pool, exampleviponedream"
        read -p "$(echo -e "(default: [viponedream]):")" ACCOUNT_NAME
        [[ -z $ACCOUNT_NAME ]] && ACCOUNT_NAME="viponedream"

        case $ACCOUNT_NAME in
        *)
            echo
            echo
            echo -e " 你的挖矿帐号:$ACCOUNT_NAME"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo -e "你已经输入:$ACCOUNT_NAME"
    echo -e "如果错误可以重复执行此脚本"


    echo
    while :; do
        echo -e "请输入你的鱼池矿池地址, 如 127.0.0.1:10655"
        read -p "$(echo -e "(默认: [127.0.0.1:10655]):")" POOL
        [[ -z $POOL ]] && POOL="127.0.0.1:10655"

        case $POOL in
        *)
            echo
            echo
            echo -e " 你的矿池地址:$POOL"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo -e "你已经输入, 挖矿帐号:$ACCOUNT_NAME"
    echo -e "你已经输入, 矿池地址:$POOL"
    echo -e "如果错误可以重复执行此脚本"
    write_conf_f2
}


set_damo_cn(){

    echo
    while :; do
        echo -e "请输入你的aleo钱包地址, 如 aleo1vcuvtwk2fa6d539q9udfauydhruue8j77097hg85mctauznv95qq99u9vu"
        echo -e "input your aleo address,  example aleo1vcuvtwk2fa6d539q9udfauydhruue8j77097hg85mctauznv95qq99u9vu"
        read -p "$(echo -e "(默认default: [aleo1vcuvtwk2fa6d539q9udfauydhruue8j77097hg85mctauznv95qq99u9vu]):")" ADDRESS
        [[ -z $ADDRESS ]] && ADDRESS="aleo1vcuvtwk2fa6d539q9udfauydhruue8j77097hg85mctauznv95qq99u9vu"

        case $ADDRESS in
        *)
            echo
            echo
            echo -e " 你的钱包地址:$ADDRESS"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo -e "你已经输入:$ADDRESS"
    echo -e "如果错误可以重复执行此脚本"


    echo
    while :; do
        echo -e "请输入达摩代理 , 如 127.0.0.1:10675 aleo3.damominer.hk:9090"
        read -p "$(echo -e "(默认: [127.0.0.1:10675]):")" PROXY
        [[ -z $PROXY ]] && PROXY="127.0.0.1:10675"

        case $PROXY in
        *)
            echo
            echo
            echo -e " 你的代理:$PROXY"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo -e "你已经输入, 挖矿钱包地址:$ADDRESS"
    echo -e "你已经输入, 代理:$PROXY"
    echo -e "如果错误可以重复执行此脚本"
    write_conf_damo
}



set_hpool_cn(){

    echo
    while :; do
        echo -e "请输入哈池的apiKey, 如 aleo0000-444d-ce5f-3f7b-a4f5df6958cd"
        echo -e "input your apiKey, example aleo0000-444d-ce5f-3f7b-a4f5df6958cd"
        read -p "$(echo -e "(默认default: [aleo0000-444d-ce5f-3f7b-a4f5df6958cd]):")" APIKEY
        
        [[ -z $APIKEY ]] && APIKEY="aleo0000-444d-ce5f-3f7b-a4f5df6958cd"

        case $APIKEY in
        *)
            echo
            echo
            echo -e " 你的apiKey:$APIKEY"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo
    while :; do
        echo -e "请输入矿工名称 , 如 mh01"
        echo -e "please input your worker name, example mh01"
        read -p "$(echo -e "(默认default: [mh01]):")" MINERNAME
        [[ -z $MINERNAME ]] && MINERNAME="mh01"

        case $MINERNAME in
        *)
            echo
            echo
            echo -e " 你的矿工名称your worker:$MINERNAME"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo
    while :; do
        echo -e "请输入显卡编号, 从0开始, 如4卡为0,1,2,3, 单卡则为0"
        echo -e "input gpus , from 0, like 4 gpus should be 0,1,2,3, only one gpu input 0"
        read -p "$(echo -e "(默认default: [0]):")" DEVICES
        [[ -z $DEVICES ]] && DEVICES="0"

        case $DEVICES in
        *)
            echo
            echo
            echo -e " 你的显卡编号为gpus:$DEVICES"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo
    while :; do
        echo -e "请输入任务线程数, 如10, 可以自己测试多少算力高"
        read -p "$(echo -e "(默认: [10]):")" TASKTHREADS
        [[ -z $TASKTHREADS ]] && TASKTHREADS="10"

        case $TASKTHREADS in
        *)
            echo
            echo
            echo -e " 你的任务线程数:$TASKTHREADS"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo -e "你的apiKey:$APIKEY"
    echo -e "你的矿工名称worker:$MINERNAME"
    echo -e "你的显卡编号gpu:$DEVICES"
    echo -e "你的线程数量threads:$TASKTHREADS"

    echo -e "如果错误可以重复执行此脚本"
    write_conf_hpool
    write_conf_hpool_yml
    sleep 1s
}



set_zkrush(){

    echo
    while :; do
        echo -e "输入你的挖矿帐号, 进https://www.zkrush.com/网站注册, 如vip1"
        read -p "$(echo -e "(默认default: [vip1]):")" ACCOUNT_NAME
        
        [[ -z $ACCOUNT_NAME ]] && ACCOUNT_NAME="vip1"

        case $ACCOUNT_NAME in
        *)
            echo
            echo
            echo -e " 你的挖矿帐号:$ACCOUNT_NAME"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo
    while :; do
        echo -e "请输入矿工名称 , 如 mh01"
        echo -e "please input your worker name, example mh01"
        read -p "$(echo -e "(默认default: [mh01]):")" MINERNAME
        [[ -z $MINERNAME ]] && MINERNAME="mh01"

        case $MINERNAME in
        *)
            echo
            echo
            echo -e " 你的矿工名称your worker:$MINERNAME"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

    echo
    while :; do
        echo -e "请输入矿池地址如 127.0.0.1:10685"
        read -p "$(echo -e "(默认default: [127.0.0.1:10685]):")" POOL
        [[ -z $POOL ]] && POOL="127.0.0.1:10685"

        case $POOL in
        *)
            echo
            echo
            echo -e " 矿池地址:$POOL"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        esac
    done

 
    echo -e "你的挖矿帐号:$ACCOUNT_NAME"
    echo -e "你的矿工名称worker:$MINERNAME"
    echo -e "矿池地址:$POOL"

    echo -e "如果错误可以重复执行此脚本"
    write_conf_zkrush
    sleep 1s
}


view_config_f2(){
    fpath=/root/aleo/f2pool   
   # 显示信息
    cat  $fpath/config.cfg
}

view_config_damo(){
    fpath=/root/aleo/damo   
   # 显示信息
    cat  $fpath/config.cfg
}

view_config_hpool(){
    fpath=/root/aleo/hpool
   # 显示信息
    cat  $fpath/config.cfg
}


view_config_zkrush(){
    fpath=/root/aleo/zkrush
   # 显示信息
    cat  $fpath/config.cfg
}




damo_new_account(){
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "正在建立新aleo钱包, 安全性未知由达摩软件 new wallet creating... "
    echo "请自己记好 save the account "
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n"       
    sleep 5s
    fpath=/root/aleo/damo   
    $fpath/damominer --new-account >  $fpath/new-account.cfg
    # 显示信息
    cat  $fpath/new-account.cfg
}



function write_conf_f2() {
rm -f /root/aleo/f2pool/config.cfg
cat <<  EOF > /root/aleo/f2pool/config.cfg
ACCOUNT_NAME=$ACCOUNT_NAME
POOL="$POOL"
EOF
}



function write_conf_damo() {
rm -f /root/aleo/damo/config.cfg
cat <<  EOF > /root/aleo/damo/config.cfg
ADDRESS=$ADDRESS
PROXY="$PROXY"
EOF
}


function write_conf_zkrush() {
fpath=/root/aleo/zkrush/config.cfg
rm -f $fpath
cat <<  EOF > $fpath
MINERNAME=$MINERNAME
ACCOUNT_NAME=$ACCOUNT_NAME
POOL="$POOL"

EOF
}


function write_conf_hpool() {
fpath=/root/aleo/hpool/config.cfg
rm -f $fpath
cat <<  EOF > $fpath
MINERNAME=$MINERNAME
APIKEY="$APIKEY"
DEVICES=$DEVICES
TASKTHREADS=$TASKTHREADS
EOF
}


function write_conf_hpool_yml() {
fpath=/root/aleo/hpool/config.yaml
t=-1
cpu_cores=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
cpu_affinity=($(nvidia-smi topo -m 2>/dev/null | awk -F'\t+| {2,}' '{for (i=1;i<=NF;i++) if($i ~ /CPU Affinity/) col=i; if (NR != 1 && $0 ~ /^GPU/) print $col}'))
gpu_num=${#cpu_affinity[*]}

TASKTHREADS=`expr $cpu_cores / $gpu_num` 

if [ $gpu_num -eq 0 ]; then
   t=-1
elif [ $gpu_num -eq 1 ]; then
   t=-1
else
   t=0
fi


rm -f $fpath
cat <<  EOF > $fpath
minerName: $MINERNAME
apiKey: "$APIKEY"
extraParams:
    devices: $DEVICES
    taskThreads: $TASKTHREADS
    cpuAffinityStep: 0
    cpuAffinityStart: $t
EOF
}



inst_f2_cn(){
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "正在安装 鱼池aleo挖矿  f2pool miner is installing..."
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n"       
    sleep 5s


    inst_common
    pool_path=/root/aleo/f2pool

                                                        
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/f2pool/aleo-f2.sh   -O  $pool_path/aleo-f2.sh
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/f2pool/aleo-prover-cuda   -O  $pool_path/aleo-prover-cuda
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/f2pool/config.cfg   -O  $pool_path/config.cfg
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/tools/libssl.so.1.1   -O  $pool_path/libssl.so.1.1
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/tools/libcrypto.so.1.1   -O  $pool_path/libcrypto.so.1.1

    # unlink $f2pool_path/prover.log
    # ln -sf  $f2pool_path/prover.log   /root/aleo/prover.log


cat <<  EOF > /root/aleo/aleo.sh
#!/bin/bash
chmod   +x /root/aleo/*
chmod   +x $pool_path/*
cd $pool_path
bash ./aleo-f2.sh
EOF

    start

}


create_dirs(){

    pool_paths=(/root/aleo  /root/aleo/hpool  /root/aleo/f2pool  /root/aleo/damo   /root/aleo/zkrush)

    # pool_path=/root/aleo
    # if test ! -d "$pool_path"; then
    #     mkdir $pool_path  
    # fi  

    # pool_path=/root/aleo/hpool
    # if test ! -d "$pool_path"; then
    #     mkdir $pool_path  
    # fi  

    # pool_path=/root/aleo/f2pool
    # if test ! -d "$pool_path"; then
    #     mkdir $pool_path  
    # fi  

    # pool_path=/root/aleo/damo


    for pool_path in ${pool_paths[@]}; 
        do	
            if test ! -d "$pool_path"; then
                mkdir $pool_path  
            fi
        done
}




inst_zkrush(){
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "正在安装 zkrush aleo挖矿  zkrush  miner is installing..."
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n"       
    sleep 5s


    # create_dirs
    inst_common

    pool_path=/root/aleo/zkrush

    
   
    # if test ! -d "$pool_path"; then
    #     mkdir $pool_path  
    # fi  

    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/zkrush/aleo-zk.sh   -O  $pool_path/aleo-zk.sh
    wget  --no-check-certificate  https://github.com/zkrush/aleo-pool-client/releases/download/v1.0/aleo-pool-prover-ubuntu1804 && mv aleo-pool-prover-ubuntu1804 aleo-pool-prover  -O  $pool_path/aleo-pool-prover
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/zkrush/config.cfg   -O  $pool_path/config.cfg



    # unlink $f2pool_path/prover.log
    # ln -sf  $f2pool_path/prover.log   /root/aleo/prover.log


cat <<  EOF > /root/aleo/aleo.sh
#!/bin/bash
chmod   +x /root/aleo/*
chmod   +x $pool_path/*
cd $pool_path
bash ./aleo-zk.sh
EOF

    start

}



inst_hpool_cn(){
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "正在安装 哈池 aleo挖矿  hpool miner is installing..."
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n"       
    sleep 5s

    
    # create_dirs
    inst_common

    pool_path=/root/aleo/hpool

    
   
    # if test ! -d "$pool_path"; then
    #     mkdir $pool_path  
    # fi  

    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/hpool/aleo-hp.sh   -O  $pool_path/aleo-hp.sh
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/hpool/hpool-miner-aleo-cuda   -O  $pool_path/hpool-miner-aleo-cuda
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/hpool/config.cfg   -O  $pool_path/config.cfg
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/hpool/config.yaml   -O  $pool_path/config.yaml
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/tools/libssl.so.1.1   -O  $pool_path/libssl.so.1.1
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/tools/libcrypto.so.1.1   -O  $pool_path/libcrypto.so.1.1

    # unlink $f2pool_path/prover.log
    # ln -sf  $f2pool_path/prover.log   /root/aleo/prover.log


cat <<  EOF > /root/aleo/aleo.sh
#!/bin/bash
chmod   +x /root/aleo/*
chmod   +x $pool_path/*
cd $pool_path
bash ./aleo-hp.sh
EOF

    start

}




inst_damo_cn(){
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n" 
    echo "正在安装 达摩aleo挖矿 damominer is installing..."
    echo -e "\n" 
    echo -e "\n" 
    echo -e "\n"       
    sleep 5s


    inst_common
    pool_path=/root/aleo/damo

                                                        
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/damo/aleo-damo.sh   -O  $pool_path/aleo-damo.sh
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/damo/damominer   -O  $pool_path/damominer
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/damo/config.cfg   -O  $pool_path/config.cfg
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/tools/libssl.so.1.1   -O  $pool_path/libssl.so.1.1
    wget  --no-check-certificate  http://download.minerhome.org/aleo/data/tools/libcrypto.so.1.1   -O  $pool_path/libcrypto.so.1.1
    wget  download.minerhome.org/aleo/data/tools/libnvidia-ml.so -O  /usr/lib/x86_64-linux-gnu/libnvidia-ml.so
    wget  download.minerhome.org/aleo/data/tools/libnvidia-ml.so -O  $pool_path/libnvidia-ml.so


    # unlink $f2pool_path/prover.log
    # ln -sf  $f2pool_path/prover.log   /root/aleo/prover.log


cat <<  EOF > /root/aleo/aleo.sh
#!/bin/bash
chmod   +x /root/aleo/*
chmod   +x $pool_path/*
cd $pool_path
bash ./aleo-damo.sh
EOF

    start

}







check_log(){
    tail -f /tmp/prover.log
}




clear
echo -e "\n" 
echo -e "\n" 
echo -e "\n" 
echo -e "\n" 
echo -e "\n" 
echo "========================================================================================="
echo "安装aleo挖矿软件  鱼池 达摩 哈池 以后会增加其它池 - 矿工之家 - https://minerhome.org"
echo "install aleo miner - f2poo damo hpool and will add more - 矿工之家 - https://minerhome.org"
echo "适合 hiveos, ubuntu18, 20, 22"
echo "compatible with hiveos, ubuntu18, 20, 22"
echo "hiveos要手工扩展磁盘, 进后台 disk-expand"
echo "run disk-expand if you're on hiveos"
echo "默认安装到 /root/aleo"
echo "default dir /root/aleo"
echo "安装完成后请自己修改你的挖矿帐号/钱包地址"
echo "change the wallet address yourself after installation"
echo "如果安装不成功，则重启服务器后重新安装"
echo "if install failed, reboot and reinstall"
echo "  1、鱼池 f2pool - 安装/设置/查看 (默认安装到/root/aleo/f2pool) - 安装完记得重启服务器 - 软件开机会自动启动，后台守护运行"
echo "  2、达摩 damominer (solo) - 安装/设置/查看/建立新钱包 (默认安装到/root/aleo/damo)   - 安装完记得重启服务器 - 软件开机会自动启动，后台守护运行"
echo "  3、哈池 hpool - 安装/设置/查看 (默认安装到/root/aleo/hpool)  - 安装完记得重启服务器 - 软件开机会自动启动，后台守护运行"
echo "  4、zkrush - install/set/view (/root/aleo/zkrush) 声称无需CPU"
echo "  5、查看挖矿状况 view log"
echo "  6、重启 restart miner  - aleo挖矿软件, 设置过后要重启才生效"
echo "  7、关闭 shutdown - aleo挖矿软件"
echo "  8、卸载 uninstall - 删除本软件"
echo "  9、重启电脑 reboot computer"
echo "  0、退出"
echo "========================================================================================="
read -p "$(echo -e "请选择please choose[1-8]：")" choose
case $choose in
0)
    exit 1
    ;;
1)
    f2_cn
    ;;
2)
    damo_cn
    ;;
3)
    hpool_cn
    ;;
4)
    zkrush
    ;; 
5)
    check_log
    ;;    
6)  
    echo "正在重启aleo挖矿软件 restarting..."
    systemctl restart mh_aleo
    ;;    
7)
    echo "正在停止aleo挖矿软件 stopping..."
    systemctl stop mh_aleo
    ;;    
8)
    uninstall
    ;;    
9)
    reboot
    ;;
*)
    echo "输入错误请重新输入！error"
    ;;
esac



