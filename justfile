set dotenv-load         # .env があれば自動読み込み (任意)

ZOLA := "zola"
PORT := "1111"

build:
    {{ZOLA}} build

serve:
    {{ZOLA}} serve --port {{PORT}}

draft:
    {{ZOLA}} serve --drafts --port {{PORT}}

check:
    {{ZOLA}} check

clean:
    rm -rf public

default: build
