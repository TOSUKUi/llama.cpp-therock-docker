# llama.cpp build by TheRock docker container for gfx1151(strix halo)
llama.cppをtherock版のrocmでビルドするのがだるいのでdocker化してしまったリポジトリ　

Ryzen AI Max+ 395(strix halo(gfx1151))向けのリポジトリ

# usage
Get tarball filename from here
https://github.com/ROCm/TheRock/releases/tag/nightly-tarball

```
docker build . --tag llama.cpp:{suitable tag. e.g. therock-dist-linux-gfx110X-dgpu-7.0.0rc20250710} --build-arg=therock_tarb
all_filename={tarball_filename. e.g. therock-dist-linux-gfx110X-dgpu-7.0.0rc20250710.tar.gz}
```
