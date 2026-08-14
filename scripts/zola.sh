#!/usr/bin/env bash
# .zola-version に固定した Zola を用意して、引数をそのまま zola に渡す。
#
# ローカルと CI で同じバージョンを使うための唯一の入口。バージョンが違うと
# config.toml の設定形式が非互換になりビルドが失敗するため、PATH 上の zola を
# そのまま使う経路は用意しない。
#
# Workers Builds のビルド環境には Zola が無く、wrangler の [build] custom builds も
# 無視されるため、Zola の取得もここで行う。ダッシュボードの build command には
# `npm run build` を設定する。
#
#   scripts/zola.sh build
#   scripts/zola.sh serve --port 1111
set -euo pipefail

cd "$(dirname "$0")/.."

ZOLA_VERSION="$(tr -d '[:space:]' < .zola-version)"

# テーマ themes/hyde は submodule。取得されていなければビルドが失敗するため必ず初期化する
echo "submodule を取得中..."
git submodule update --init --recursive
git submodule status

bindir="$(pwd)/.zola-bin"

if command -v zola >/dev/null 2>&1 && [ "$(zola --version)" = "zola ${ZOLA_VERSION}" ]; then
  echo "zola ${ZOLA_VERSION} は既にインストール済み"
elif [ -x "${bindir}/zola" ] && [ "$("${bindir}/zola" --version)" = "zola ${ZOLA_VERSION}" ]; then
  echo "zola ${ZOLA_VERSION} は ${bindir} に取得済み"
  export PATH="${bindir}:$PATH"
else
  case "$(uname -s)-$(uname -m)" in
    Linux-x86_64) target="x86_64-unknown-linux-gnu" ;;
    Linux-aarch64) target="aarch64-unknown-linux-gnu" ;;
    Darwin-arm64) target="aarch64-apple-darwin" ;;
    Darwin-x86_64) target="x86_64-apple-darwin" ;;
    *) echo "未対応のプラットフォーム: $(uname -s)-$(uname -m)" >&2; exit 1 ;;
  esac

  mkdir -p "$bindir"
  url="https://github.com/getzola/zola/releases/download/v${ZOLA_VERSION}/zola-v${ZOLA_VERSION}-${target}.tar.gz"
  echo "Zola を取得: ${url}"
  curl -fsSL "$url" | tar -xz -C "$bindir" zola
  export PATH="${bindir}:$PATH"
fi

zola --version
exec zola "$@"
