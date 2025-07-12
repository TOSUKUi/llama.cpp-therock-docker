ARG therock_tarball_filename=therock-dist-linux-gfx1151-7.0.0rc20250710.tar.gz
ARG hsa_override_gfx_version=11.5.1
ARG amdgpu_targets=gfx1151

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
    clang \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

ARG therock_tarball_filename
ENV ROCM_INSTALL_DIR="/opt/rocm"

RUN mkdir -p ${ROCM_INSTALL_DIR} \
    && wget -q -O /tmp/the_rock.tar.gz "https://github.com/ROCm/TheRock/releases/download/nightly-tarball/${therock_tarball_filename}" \
    && tar xz -C "${ROCM_INSTALL_DIR}" -f /tmp/the_rock.tar.gz \
    && rm /tmp/the_rock.tar.gz

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

RUN git clone https://github.com/ggml-org/llama.cpp ./ \
    && sed -i \
    -e 's/#define CUBLAS_COMPUTE_16F HIPBLAS_R_16F/#define CUBLAS_COMPUTE_16F HIPBLAS_COMPUTE_16F/' \
    -e 's/#define CUBLAS_COMPUTE_32F HIPBLAS_R_32F/#define CUBLAS_COMPUTE_32F HIPBLAS_COMPUTE_32F/' \
    -e 's/#define CUBLAS_COMPUTE_32F_FAST_16F HIPBLAS_R_32F/#define CUBLAS_COMPUTE_32F_FAST_16F HIPBLAS_COMPUTE_32F_FAST_16F/' \
    -e 's/#define cublasComputeType_t hipblasDatatype_t/#define cublasComputeType_t hipblasComputeType_t/' \
    -e 's/#define cudaDataType_t hipblasDatatype_t/#define cudaDataType_t hipDataType/' \
    "ggml/src/ggml-cuda/vendors/hip.h"
ARG amdgpu_targets
RUN mkdir build && cd build \
    && HIPCC="$(/opt/rocm/bin/hipconfig -l)/clang" \
    HIP_PATH="$(/opt/rocm/bin/hipconfig -R)" \
    cmake .. \
    -G Ninja \
    -DGGML_HIP=ON \
    -DAMDGPU_TARGETS=${amdgpu_targets} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DHIP_PLATFORM=amd \
    && cmake --build . --config Release -- -j $(grep -c ^processor /proc/cpuinfo)

ARG hsa_override_gfx_version
ENV HSA_OVERRIDE_GFX_VERSION=${hsa_override_gfx_version}
ENV ROCBLAS_USE_HIPBLASLT=1
# もしサーバーバイナリを起動する場合
CMD ["build/bin/llama-server"]


