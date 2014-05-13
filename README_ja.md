# bucket2bucket.rb

## 概要

S3バケット間でオブジェクトをまとめてコピーする。

## 必要なもの

* 最近のRuby
* aws-sdk

## 使い方

    Usage: bucket2bucket.rb [options]
        -s, --src-bucket BUCKET_NAME   # コピー元バケットの名前
        -S, --src-prefix PATH          # コピー元オブジェクトの接頭辞。"foo/"と指定したらfooフォルダ以下のオブジェクトしかコピーされない。デフォルトは全オブジェクト
        -r, --src-region REGION        # コピー元のリージョン。デフォルトは東京
        -d, --dest-bucket BUCKET_NAME  # コピー先バケットの名前
        -D, --dest-prefix PATH         # コピー先オブジェクトの接頭辞。"bar/"と指定したらbarフォルダ以下に元バケットのオブジェクトが格納される。デフォルトはバケット直下
        -R, --dest-region REGION       # コピー先のリージョン。デフォルトは東京
        -i, --access-key-id ID         # AWSのアクセスキーID。EC2上でIAM Roleを使う場合は指定不要
        -k, --secret-access-key KEY    # AWSのシークレットアクセスキー。EC2上でIAM Roleを使う場合は指定不要
        -v, --verify                   # 指定した場合Etag (MD5)によりコピー元オブジェクトとコピー先オブジェクトのベリファイを行う
        -t, --threads THREAD_COUNT     # 何スレッド平行で処理を行うか指定する。デフォルトは4。手元環境で-t 1と-t 10を比較したところ9倍ほどの差がみられた

## 使用例

    ruby bucket2bucket.rb -i AQWERTYUIOP -k asdfghjklzxcvbnmqwertyuiop -s some-bucket -d other-bucket -D copied-from-some-bucket/ -v -t 10
