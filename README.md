# llama.cpp build by TheRock docker container
llama.cppをtherock版のrocmでビルドするのが、いろいろバージョン管理とかうまくいかないケースに当たった後の手間がだるかったのでdocker化してしまったリポジトリ　
# usage
Get tarball filename from here
https://github.com/ROCm/TheRock/releases/tag/nightly-tarball

```
docker build . --tag llama.cpp:{suitable tag. e.g. therock-dist-linux-gfx110X-dgpu-7.0.0rc20250710} --build-arg=therock_tarb
all_filename={tarball_filename. e.g. therock-dist-linux-gfx110X-dgpu-7.0.0rc20250710.tar.gz}
```
