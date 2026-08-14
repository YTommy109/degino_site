#!/usr/bin/env bash
# Workers Builds 上で Zola サイトをビルドする。
#
# Workers Builds のビルド環境には Zola が無く、wrangler の [build] custom builds も
# 無視されるため、Zola の取得からビルドまでをこのスクリプトに集約する。
# ダッシュボードの build command には `npm run build` を設定する。
set -euo pipefail

cd "$(dirname "$0")/.."

ZOLA_VERSION="$(tr -d '[:space:]' < .zola-version)"

# テーマ themes/hyde は submodule。取得されていなければビルドが失敗するため必ず初期化する
git submodule update --init --recursive

if command -v zola >/dev/null 2>&1 && [ "$(zola --version)" = "zola ${ZOLA_VERSION}" ]; then
  echo "zola ${ZOLA_VERSION} は既にインストール済み"
else
  case "$(uname -s)-$(uname -m)" in
    Linux-x86_64) target="x86_64-unknown-linux-gnu" ;;
    Linux-aarch64) target="aarch64-unknown-linux-gnu" ;;
    Darwin-arm64) target="aarch64-apple-darwin" ;;
    Darwin-x86_64) target="x86_64-apple-darwin" ;;
    *) echo "未対応のプラットフォーム: $(uname -s)-$(uname -m)" >&2; exit 1 ;;
  esac

  bindir="$(pwd)/.zola-bin"
  mkdir -p "$bindir"
  url="https://github.com/getzola/zola/releases/download/v${ZOLA_VERSION}/zola-v${ZOLA_VERSION}-${target}.tar.gz"
  echo "Zola を取得: ${url}"
  curl -fsSL "$url" | tar -xz -C "$bindir" zola
  export PATH="$bindir:$PATH"
fi

zola --version
zola build
