FROM omnetpp/inet:o6.0-4.4.1
COPY ./install_cmake.sh /root/
SHELL ["/bin/bash", "-c"]
RUN ["apt", "update"] 
RUN ["apt", "install","-y", "git", "build-essential", "libssl-dev", "ninja-build", "software-properties-common", "lsb-release", "libcrypto++-dev", "libboost-all-dev", "libpaho-mqtt-dev"]
WORKDIR /models
RUN ["git", "clone", "--branch", "lora-fhss", "https://github.com/glmoritz/labscim.git" ]
WORKDIR /models/labscim/src/common
RUN ["chmod", "+x", "fix_symlinks.sh"]
RUN ["./fix_symlinks.sh"]
WORKDIR /root
RUN ["chmod", "+x", "install_cmake.sh"]
RUN ["/root/install_cmake.sh"]
RUN ["ln", "-s", "/models/labscim", "labscim"]
RUN ["git", "clone", "https://github.com/glmoritz/contiki-ng", "--recursive"]
RUN ["git", "clone", "--branch", "lora-fhss", "https://github.com/glmoritz/LoRaMac-node.git"]
RUN ["git", "clone", "--branch", "lora-fhss", "https://github.com/glmoritz/lora_gateway.git"]
RUN ["git", "clone", "--branch", "lora-fhss", "https://github.com/glmoritz/packet_forwarder.git"]
WORKDIR /root/lora_gateway
RUN ["chmod", "+x", "fix_symlinks.sh"]
RUN ["./fix_symlinks.sh"]
RUN ["make"]
WORKDIR /root/packet_forwarder/lora_pkt_fwd/inc
RUN ["chmod", "+x", "fix_symlinks.sh"]
RUN ["./fix_symlinks.sh"]
WORKDIR /root/packet_forwarder
RUN ["make"]
WORKDIR /root/contiki-ng/examples/6tisch/simple-node
RUN ["make", "TARGET=labscim"]
WORKDIR /models/labscim/src
COPY ./makemake.sh /models/labscim/src
RUN ["chmod", "+x", "makemake.sh"]
RUN ["./makemake.sh"]
WORKDIR /root/LoRaMac-node/src/boards/labscim
RUN ["chmod", "+x", "fix_symlinks.sh"]
RUN ["./fix_symlinks.sh"]
WORKDIR /root/LoRaMac-node
RUN ["cmake", "--no-warn-unused-cli", "-DCMAKE_BUILD_TYPE:STRING=Release", "-DAPPLICATION:STRING=LoRaMac", "-DSUB_PROJECT:STRING=periodic-uplink-lpp", "-DLORAWAN_DEFAULT_CLASS:STRING=CLASS_A", "-DCLASSB_ENABLED:STRING=ON", "-DACTIVE_REGION:STRING=LORAMAC_REGION_AU915", "-DMODULATION:STRING=LORA", "-DBOARD:STRING=labscim", "-DMBED_RADIO_SHIELD:STRING=LABSCIM_SHIELD", "-DLORAMAC_LR_FHSS_IS_ON:STRING=ON", "-DSECURE_ELEMENT:STRING=SOFT_SE", "-DSECURE_ELEMENT_PRE_PROVISIONED:STRING=OFF", "-DREGION_EU868:STRING=ON", "-DREGION_US915:STRING=OFF", "-DREGION_CN779:STRING=OFF", "-DREGION_EU433:STRING=OFF", "-DREGION_AU915:STRING=ON", "-DREGION_CN470:STRING=OFF", "-DREGION_AS923:STRING=OFF", "-DREGION_KR920:STRING=OFF", "-DREGION_IN865:STRING=OFF", "-DREGION_RU864:STRING=OFF", "-DREGION_AS923_DEFAULT_CHANNEL_PLAN:STRING=CHANNEL_PLAN_GROUP_AS923_1", "-DREGION_CN470_DEFAULT_CHANNEL_PLAN:STRING=CHANNEL_PLAN_20MHZ_TYPE_A", "-DUSE_RADIO_DEBUG:STRING=OFF", "-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE", "-DCMAKE_C_COMPILER:FILEPATH=/usr/bin/gcc", "-DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++", "-S/root/LoRaMac-node", "-B/root/LoRaMac-node/build", "-G", "Ninja"]
WORKDIR /root/LoRaMac-node/build
RUN ["ninja"]
WORKDIR /root/contiki-ng/examples/rpl-udp
RUN ["make", "TARGET=labscim"]
WORKDIR /models/labscim/simulations/wireless/nic
#WORKDIR /root/inet4
#RUN "make -j$(nproc)"
#$HOME/omnetpp/bin/opp_run -r $i -m -u Cmdenv -c Ping$j -n $HOME/inet4/src --image-path=$HOME/inet4/src/images -l $HOME/inet4/src/inet omnetpp.ini
ENTRYPOINT ["tail", "-f", "/dev/null"]
