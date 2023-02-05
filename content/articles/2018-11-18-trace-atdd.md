+++
title = "[技術] ライフゲームを ATDD で実装してみる"
date = 2018-11-18
+++

![秋芳洞](https://www.dropbox.com/s/b97n992pay5v4hz/akiyoshi1.jpeg?dl=1)

# 前置き

この記事は ATDD 上の設計戦略手順の事例を解説するものですので、厳密な TDD 手順の記載は省略しています。実際の作業は、かなり厳格な TDD 手順を踏んで行ないましたが、それを記事にするとあまりにも読みにくくなってしまうため、大幅に省略しました。ご了承ください。


# 概要

通常の開発では、何もないところから徐々に部品を組み立ててゆく手順を踏むと思います。ライフゲームなら、セル、ワールド、ボード…あたりから着手するのが一般的かと思います。

しかしここでは、ライフゲームで出現する [ブリンカーパターン](https://ja.wikipedia.org/wiki/ブリンカー_(ライフゲーム)) を、まず最初に動かしてしまうところからスタートします。 [Coderetreat](http://coderetreat.org/) に参加して教えていただいたのですが、このアプローチは ATDD (もしくは BDD) と呼ばれるものだそうです。

* 言語: ECMAScript 2017
* テストツール: Jest


# 手順

大まかな手順は次の通りです。

1. ブリンカーパターンのテストケースを作る。
1. セル単位の判断に分解する。
1. ライフゲームのルールを組み込む。
1. 生存数を数えられるようにする。


# 実践

## STEP 1

最初に目指すゴールをテストコードで表明してみます。

```javascript
import Board from './board'

describe('ボードに関するテスト', () => {
    // ブリンカーパターン1
    const bl1 = [
        0, 0, 0,
        1, 1, 1,
        0, 0, 0]
    // ブリンカーパターン2
    const bl2 = [
        0, 1, 0,
        0, 1, 0,
        0, 1, 0
    ]

    it('ボードが初期化されること', () => {
        const board = new Board(3, bl1)
        expect(board.state).toEqual(bl1)
        expect(board.width).toBe(3)
        expect(board.height).toBe(3)
    })

    it('ブリンカーが動作すること', () => {
        const board1 = new Board(3, bl1)
        const board2 = new Board(3, bl2)
        expect(board1.nextBoard()).toEqual(board2)
        expect(board2.nextBoard()).toEqual(board1)
    })
})
```

ブリンカーパターンは、2パターンの繰り返しですので、二つのボードを切り替えることさえできれば、ひとまず動作します。まず最初にその状態を作ります。

では、テストが通るように実装します。

```javascript
// ブリンカーパターン1
const bl1 = [
    0, 0, 0,
    1, 1, 1,
    0, 0, 0]
// ブリンカーパターン2
const bl2 = [
    0, 1, 0,
    0, 1, 0,
    0, 1, 0
]

class Board {
    constructor(width, init) {
        this._width = width
        this._height = init.length / width
        this._state = init
    }
    get width() { return this._width }
    get height() { return this._height }
    get state() { return this._state }

    // 次世代ボードを取得する
    nextBoard() {
        if (JSON.stringify(this.state) == JSON.stringify(bl1)) {
            return new Board(this.width, bl2)
        }
        return new Board(this.width, bl1)
    }
}

export default Board
```

なんとゆーデタラメなライフゲームの実装でしょう。(笑) [Coderetreat](http://coderetreat.org/) では45分の制限時間があるため、ライフゲームの完成を見ることは滅多にありません。でも、これならいきなり動かせます (ブリンカーだけ)。(笑)


## STEP 2

最初に作ったものは、配列比較を行った上でボードをごっそりと入れ替えるという方式でした。あまりにも乱暴すぎるので、次はセル毎に分解することにします。テストコードでゴールを表明します。

```javascript
it('オフセットで指定したセルの来世が決まること', () => {
    const board1 = new Board(3, bl1)
    expect(board1.nextCell(0)).toBe(0)
    expect(board1.nextCell(1)).toBe(1)

    const board2 = new Board(3, bl2)
    expect(board2.nextCell(0)).toBe(0)
    expect(board2.nextCell(1)).toBe(0)
})
```

オフセットは配列のインデックスのことです。私は、ゼロオリジンであることを表明するために、インデックスではなく、オフセットと呼ぶようにしています。

```javascript
// セルの来世を取得する
nextCell(offset) {
    if (JSON.stringify(this.state) == JSON.stringify(bl1)) {
        return bl2[offset]
    }
    return bl1[offset]
}
```

引き続き、まったくライフゲームのルールを組み込まないまま、配列比較を使ったデタラメな実装が続きます。

nextCell ができたので、 nextBoard に組み込んで、リファクタリングします。

```javascript
// ブリンカーパターン1
const bl1 = [
    0, 0, 0,
    1, 1, 1,
    0, 0, 0]
// ブリンカーパターン2
const bl2 = [
    0, 1, 0,
    0, 1, 0,
    0, 1, 0
]

class Board {
    constructor(width, init) {
        this._width = width
        this._height = init.length / width
        this._state = init
    }
    get width() { return this._width }
    get height() { return this._height }
    get state() { return this._state }

    // セルの来世を取得する
    nextCell(offset) {
        if (JSON.stringify(this.state) == JSON.stringify(bl1)) {
            return bl2[offset]
        }
        return bl1[offset]
    }

    // 次世代ボードを取得する
    nextBoard() {
        const nb = []
        for (let offset in this.state) {
            nb.push(this.nextCell(offset))
        }
        return new Board(this.width, nb)
    }
}

export default Board
```

nextBoard からはおかしな実装は消えました。なんとなく、流れ (仮実装しておいて、それを直すという手順) が見えてきた気がしませんか?

## STEP 3

nextCell に移動した配列比較を消したいのですが、少し準備が必要です。今回はユーティリティ的な関数を用意します。テストコードによるゴール表明は次の通りです。

```javascript
it('生存者数に基づいて、来世の定めが決まること', () => {
    const board1 = new Board(3, bl1)
    expect(board1.nextLife(0)).toBe(0)
    expect(board1.nextLife(1)).toBe(0)
    expect(board1.nextLife(3)).toBe(1)
    expect(board1.nextLife(2, 0)).toBe(0)
    expect(board1.nextLife(2, 1)).toBe(1)
})
```

nextLife に渡しているのは、周りの生きてるセルの数です。周りの生存数が 2 の時は、状態が変化しないので、現在のセルの状態を渡さなければなりません。ここに来て、やっとライフゲームのルールが登場しました。 (笑)

```javascript
  nextLife(lives, state=null) {
      if (lives==3) { return 1 }
      if (lives==2) { return state }
      return 0
  }
```

ソースコードはこのようになりました。せっかくライフゲームのルールを組み込んだので、実際のロジックに反映しましょう。そして、リファクタリングして、整理したのがこちら。

```javascript
// ブリンカーパターン1
const bl1 = [
    0, 0, 0,
    1, 1, 1,
    0, 0, 0]
// ブリンカーパターン2
const bl2 = [
    0, 1, 0,
    0, 1, 0,
    0, 1, 0
]
// 事前に数えた生存数1
const lv1 = [
    2, 3, 2,
    1, 2, 1,
    2, 3, 2
]
// 事前に数えた生存数2
const lv2 = [
    2, 1, 2,
    3, 2, 3,
    2, 1, 2
]

class Board {
    constructor(width, init) {
        this._width = width
        this._height = init.length / width
        this._state = init
    }
    get width() { return this._width }
    get height() { return this._height }
    get state() { return this._state }

    // セルの来世を取得する
    nextCell(offset) {
        const NLIFE = [0, 0, this.state[offset], 1, 0, 0, 0, 0, 0]
        let lives = lv2[offset]
        if (JSON.stringify(this.state) == JSON.stringify(bl1)) {
            lives = lv1[offset]
        }
        return NLIFE[lives]
    }

    // 次世代ボードを取得する
    nextBoard() {
        const nb = []
        for (let offset in this.state) {
            nb.push(this.nextCell(offset))
        }
        return new Board(this.width, nb)
    }
}

export default Board
```

ブログ記事としては、ちょっとやり過ぎたかもしれません。書いたばかりの nextLife がいきなり消えてしまいました。

そして、配列比較が消えないばかりか、事前に生存数を数えて準備しておくという、またしてもデタラメな実装が登場しました。 (笑)

でも逆に、周りの生存数さえ数えられれば、動作するということでもあります。

## STEP 4

いよいよ終盤です。周りの生存数を数えられるようにします。もう、徐々に部品を育ててゆく方法と、やることは同じですので、一気に行きます。まずは、テストコード。

```javascript
it('オフセットから座標を求められること', () => {
    const board1 = new Board(3, bl1)
    expect(board1.position(0)).toEqual([1, 1])
    expect(board1.position(1)).toEqual([2, 1])
    expect(board1.position(2)).toEqual([3, 1])
    expect(board1.position(3)).toEqual([1, 2])
    expect(board1.position(8)).toEqual([3, 3])
})

it('座標からセルを取得する', () => {
    const board1 = new Board(3, bl1)
    expect(board1.cell(1, 1)).toBe(0)
    expect(board1.cell(1, 2)).toBe(1)

    expect(board1.cell(0, 1)).toBeNull()
    expect(board1.cell(1, 0)).toBeNull()
    expect(board1.cell(4, 1)).toBeNull()
    expect(board1.cell(1, 4)).toBeNull()
})

it('オフセットで指定したセルの周囲の生存数を取得できること', () => {
    const board1 = new Board(3, bl1)
    expect(board1.lives(0)).toBe(2)
    expect(board1.lives(1)).toBe(3)
    expect(board1.lives(2)).toBe(2)
    expect(board1.lives(3)).toBe(1)

    const board2 = new Board(3, bl2)
    expect(board2.lives(0)).toBe(2)
    expect(board2.lives(1)).toBe(1)
    expect(board2.lives(2)).toBe(2)
    expect(board2.lives(3)).toBe(3)
})
```

そして実装します。

```javascript
// オフセットから座標を求める
position(offset) {
    return [offset % this.width + 1, parseInt(offset / this.width) + 1]
}

// 座標からセルを取得する
cell(x, y) {
    if (x<1) { return null }
    if (y<1) { return null }
    if (x>this.width) { return null }
    if (y>this.height) { return null }
    const offset = x-1 + (y-1)*this.width
    return this.state[offset]
}

//  周囲の生存数を取得する
lives(offset) {
    const [x, y] = this.position(offset)
    const cells = []
    cells.push(this.cell(x-1, y-1))
    cells.push(this.cell(x  , y-1))
    cells.push(this.cell(x+1, y-1))
    cells.push(this.cell(x-1, y  ))
    // cells.push(this.cell(x  , y  ))
    cells.push(this.cell(x+1, y  ))
    cells.push(this.cell(x-1, y+1))
    cells.push(this.cell(x  , y+1))
    cells.push(this.cell(x+1, y+1))

    return cells.filter((v) => { return v == 1}).length
}
```

最後にロジックに組み込んで、リファクタリングします。

```javascript
class Board {
    constructor(width, init) {
        this._width = width
        this._height = init.length / width
        this._state = init
    }
    get width() { return this._width }
    get height() { return this._height }
    get state() { return this._state }

    // オフセットから座標を求める
    position(offset) {
        return [offset % this.width + 1, parseInt(offset / this.width) + 1]
    }

    // 座標からセルを取得する
    cell(x, y) {
        if (x<1) { return null }
        if (y<1) { return null }
        if (x>this.width) { return null }
        if (y>this.height) { return null }
        const offset = x-1 + (y-1)*this.width

        return this.state[offset]
    }

    //  周囲の生存数を取得する
    lives(offset) {
        const [x, y] = this.position(offset)
        const cells = []
        cells.push(this.cell(x-1, y-1))
        cells.push(this.cell(x  , y-1))
        cells.push(this.cell(x+1, y-1))
        cells.push(this.cell(x-1, y  ))
        // cells.push(this.cell(x  , y  ))
        cells.push(this.cell(x+1, y  ))
        cells.push(this.cell(x-1, y+1))
        cells.push(this.cell(x  , y+1))
        cells.push(this.cell(x+1, y+1))

        return cells.filter((v) => { return v == 1 }).length
    }

    // セルの来世を取得する
    nextCell(offset) {
        const NLIFE = [0, 0, this.state[offset], 1, 0, 0, 0, 0, 0]

        return NLIFE[this.lives(offset)]
    }

    // 次世代ボードを取得する
    nextBoard() {
        const nb = []
        for (let offset in this.state) {
            nb.push(this.nextCell(offset))
        }
        return new Board(this.width, nb)
    }
}

export default Board
```

やっと、配列比較や事前に数えておいた配列を消せました。

最初から最後までブリンカーが動作する状態を維持したまま、実装が完了したというわけです。
