# llama.cpp build by TheRock docker container for gfx1151(strix halo)
llama.cppをtherock版のrocmでビルドするのがだるいのでdocker化してしまったリポジトリ　

Ryzen AI Max+ 395(strix halo(gfx1151))向けのリポジトリ

## usage(build)
Get tarball filename from here
https://github.com/ROCm/TheRock/releases/tag/nightly-tarball

```bash
docker build . --tag llama.cpp:<suitable tag. e.g. therock-dist-linux-gfx1151-7.0.0rc20250710> --build-arg=therock_tarball_filename=<tarball_filename. e.g. therock-dist-linux-gfx1151-7.0.0rc20250710.tar.gz>
```

## usage
note1: `--no-mmap`がないとシステムメモリ以上の領域をアロケーションできない(Without --no-mmap, you cannot allocate a region larger than the system memory.)

note2: `ROCBLAS_USE_HIPBLASLT=1`を付けるとprompt processingのパフォーマンスが20~30%上がるので必須(prompt processing performance increase by 20%~30% when `ROCBLAS_USE_HIPBLASLT=1` option is set.)

### when `llama-server`
```bash
docker run -it -p 8080:8080 -v /mnt/data/models/llama.cpp/common/:/app/models --device /dev/kfd --device /dev/dri --security-opt seccomp=unconfined -e ROCBLAS_USE_HIPBLASLT=1 llama.cpp:therock-dist-linux-gfx1151-7.0.0rc20250710 build/bin/llama-server --no-mmap -m ./models/Qwen3-30B-A3B-UD-Q4_K_XL.gguf --host 0.0.0.0

```

### when `llama-bench`
```bash
docker run -it -p 8080:8080 -v /mnt/data/models/llama.cpp/common/:/app/models --device /dev/kfd --device /dev/dri --security-opt seccomp=unconfined -e ROCBLAS_USE_HIPBLASLT=1 llama.cpp:therock-dist-linux-gfx1151-7.0.0rc20250710 build/bin/llama-bench -mmap 0 -m ./models/Qwen3-30B-A3B-UD-Q4_K_XL.gguf
```
