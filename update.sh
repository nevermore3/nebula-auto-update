#!/bin/bash
# current dir
current_dir=$(pwd)
install_dir=${current_dir}"/nebula-install"

build_dir='build'

function install_graph() {
    cd ${current_dir}
    # graph url
    graph_url="https://github.com/vesoft-inc/nebula-graph.git"

    graph_name='nebula-graph'
    # graph dir
    graph_dir=${current_dir}"/"${graph_name}
    echo $graph_dir

    cmake_graph=" -DENABLE_BUILD_STORAGE=ON \
                -DCMAKE_INSTALL_PREFIX=${current_dir}/nebula-install \
                -DENABLE_GDB_SCRIPT_SECTION=ON .."

    # del graph_dir
    if [ -d ${graph_dir} ]; then
        rm -rf ${graph_dir}
    fi

    echo "Start download graph"
    git clone ${graph_url}

    cd ${graph_dir}
    mkdir ${build_dir}
    cd ${build_dir}

    cmake ${cmake_graph}
    make -j 16

    if [ $? -eq 0 ]; then
        echo "make graph success"
        make install
    else
        echo "fail"
        install_graph
    fi

}

function install_storage() {
    cd ${current_dir}
    # storage url
    storage_url="https://github.com/vesoft-inc/nebula-storage.git"

    storage_name='nebula-storage'

    # storage dir
    storage_dir=${current_dir}"/"${storage_name}
    echo $storage_dir

    cmake_storage=" -DCMAKE_INSTALL_PREFIX=${current_dir}/nebula-install .."

    # del storage_dir
    if [ -d ${storage_dir} ]; then
        rm -rf ${storage_dir}
    fi

    # del install_dir
    if [ -d ${install_dir} ]; then
        rm -rf ${install_dir}
    fi

    echo "Start download storage"
    git clone ${storage_url}

    cd ${storage_dir}
    mkdir ${build_dir}
    cd ${build_dir}

    echo ${cmake_storage}
    cmake ${cmake_storage}
    make -j 16

    if [ $? -eq 0 ]; then
        echo "make storage success"
        make install
    else
        echo "fail"
        install_storage
    fi
}

function install_console() {
    echo "Install console"

    console_url="https://github.com/vesoft-inc/nebula-console.git"

    console_dir=${current_dir}"/nebula-console"

    # del console_dir
    if [ -d ${console_dir} ]; then
        rm -rf ${console_dir}
    fi

    cd ${current_dir}

    git clone ${console_url}

    cd ${console_dir}

    make
}

function start_serve() {
    echo "Start set config"
    configs=${current_dir}"/config/* "

    cp -r ${configs}  ${install_dir}"/etc"

    ${install_dir}"/scripts/nebula.service" stop all

    ${install_dir}"/scripts/nebula.service" start all

    ${install_dir}"/scripts/nebula.service" status all
}


echo "Install storage"
install_storage
echo "Install graph"
install_graph
echo "Start serve"
#start_serve
echo "Install console"
install_console
