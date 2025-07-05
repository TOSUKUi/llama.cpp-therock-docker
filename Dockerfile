ARG therock_tarball_filename=therock-dist-linux-gfx1151-6.5.0rc20250610.tar.gz

FROM ubuntu:rolling

WORKDIR /app



RUN apt update && apt install -y --no-install-recommends \
    wget \
    tar \
    git \
    cmake \
    build-essential \
    python3 \
    python3-pip \
    ca-certificates \
    libnuma-dev \
    pkg-config \
    libcurl4-openssl-dev \
    # TheRockが要求する可能性がある追加の依存関係をインストール
    # 必要に応じて追加してください (例: libsndfile1-dev, libssl-dev など)
    && rm -rf /var/lib/apt/lists/*


ARG therock_tarball_filename
ENV ROCM_INSTALL_DIR="/opt/rocm"

COPY ./${therock_tarball_filename} /tmp/
RUN mkdir -p ${ROCM_INSTALL_DIR} \
    && tar xvzf /tmp/${therock_tarball_filename} -C ${ROCM_INSTALL_DIR} \
    && rm /tmp/${therock_tarball_filename}


# HIPCC_COMPILE_FLAGS_APPEND="-I$HOME/llama.cpp-rocm-therock/rocWMMA/library/include"
ENV ROCM_PATH="/opt/rocm"
ENV HIP_PLATFORM="amd"
ENV HIP_PATH="${ROCM_PATH}"
ENV HIP_CLANG_PATH="${ROCM_PATH}/llvm/bin"
ENV HIP_INCLUDE_PATH="${ROCM_PATH}/include"
ENV HIP_LIB_PATH="${ROCM_PATH}/lib"
ENV HIP_DEVICE_LIB_PATH="${ROCM_PATH}/lib/llvm/amdgcn/bitcode"
ENV PATH="${ROCM_PATH}/bin:${HIP_CLANG_PATH}:${PATH}"
ENV LD_LIBRARY_PATH="${ROCM_PATH}/lib:${ROCM_PATH}/lib64:${ROCM_PATH}/llvm/lib:${LD_LIBRARY_PATH}"
ENV LIBRARY_PATH="${ROCM_PATH}/lib:${ROCM_PATH}/lib64:${LIBRARY_PATH}"
ENV CPATH="${HIP_INCLUDE_PATH}:${CPATH}"
ENV PKG_CONFIG_PATH="${ROCM_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"

COPY ./llama.cpp/ .
COPY ./replace/ ./llama.cpp/
RUN mkdir build && cd build \
    # HIPCC を CMake に伝える（hipconfig -l は amdclang++ のパスを返す）
    # HIP_PATH は hipconfig -R で取得されるROCmルートパスに設定される
    # HIPCC_COMPILE_FLAGS_APPEND は CMake の CXX_FLAGS に含める
    # nproc の代わりに固定値またはCPU情報を取得するコマンドを使用
    && HIPCC="$(/opt/rocm/bin/hipconfig -l)/clang" \
       HIP_PATH="$(/opt/rocm/bin/hipconfig -R)" \
       cmake .. \
           -DGGML_HIP=ON \
           -DAMDGPU_TARGETS=gfx1151 \
           -DCMAKE_BUILD_TYPE=Release \
           -DCMAKE_CXX_FLAGS="-I${ROCWMMA_LIBRARY_INCLUDE}" \
    && cmake --build . --config Release -- -j $(grep -c ^processor /proc/cpuinfo)

CMD ["./build/bin/server"] # もしサーバーバイナリがビルドされる場合


