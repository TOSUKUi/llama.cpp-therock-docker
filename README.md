# llama.cpp build by TheRock docker container for gfx1151(strix halo)
llama.cppをtherock版のrocmでビルドするのがだるいのでdocker化してしまったリポジトリ　

Ryzen AI Max+ 395(strix halo(gfx1151))向けのリポジトリ

## usage(build)
Get tarball filename from here
https://github.com/ROCm/TheRock/releases/tag/nightly-tarball

```bash
docker build . --tag llama.cpp:<suitable tag. e.g. therock-dist-linux-gfx1151-7.0.0rc20250710> --build-arg=therock_tarball_filename=<tarball_filename. e.g. therock-dist-linux-gfx1151-7.0.0rc20250710.tar.gz>
```

### build llama.cpp for gfx1100 therock build
```bash
docker buildx build . -t llama.cpp:therock-dist-linux-gfx110X-7.0.0rc20250704 --build-arg=therock_tarball_filename=therock-dist-linux-gfx110X-dgpu-7.0.0rc20250704.tar.gz --build-arg=hsa_override_gfx_version=11.0.0 --build-arg=amdgpu_targets=gfx1100
```


## usage
note: `--no-mmap`がないとシステムメモリ以上の領域をアロケーションできない(Without --no-mmap, you cannot allocate a region larger than the system memory.)


### when `llama-server`
```bash
docker run -it -p 8080:8080 -v /mnt/data/models/llama.cpp/common/:/app/models --device /dev/kfd --device /dev/dri --security-opt seccomp=unconfined llama.cpp:therock-dist-linux-gfx1151-7.0.0rc20250710 build/bin/llama-server --no-mmap -m ./models/Qwen3-30B-A3B-UD-Q4_K_XL.gguf --host 0.0.0.0
```

### when `llama-bench`
```bash
docker run -it -p 8080:8080 -v /mnt/data/models/llama.cpp/common/:/app/models --device /dev/kfd --device /dev/dri --security-opt seccomp=unconfined llama.cpp:therock-dist-linux-gfx1151-7.0.0rc20250710 build/bin/llama-bench -mmap 0 -m ./models/Qwen3-30B-A3B-UD-Q4_K_XL.gguf
```
