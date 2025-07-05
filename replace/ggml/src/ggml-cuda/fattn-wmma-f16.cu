// ggml/src/ggml-cuda/fattn-wmma-f16.cu (replacement)
#include "common.cuh"
#include "fattn-common.cuh"

extern "C" __global__ void flash_attn_ext_f16_stub() { /* noop */ }

void ggml_cuda_flash_attn_ext_wmma_f16(ggml_backend_cuda_context & ctx,
                                       ggml_tensor * dst) {
    GGML_UNUSED(ctx);
    GGML_UNUSED(dst);
}
