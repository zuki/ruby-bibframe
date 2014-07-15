# Bibframe

[marc2bibframe](https://github.com/lcnetdev/marc2bibframe)のXQueryをRubyに変換した、MARCXMLレコードを[Bibframe](http://www.loc.gov/bibframe/)形式に変換するRubyGem。

## インストール

以下をアプリケーションのGemfileに追加する:

    gem 'ruby-bibframe'

bundleコマンドを実行する:

    $ bundle

あるいは、次のコマンドでインストールする:

    $ gem install ruby-bibframe

## 利用法

````
require 'marc'
require 'bibframe'

reader = MARC::XMLReader.new('/path/to/MARCXML.xml')
bf = Bibframe::Repository.new(reader)
bf.to_ttl('/path/to/output.ttl')
#bf.to_xmlrdf('/path/to/output.rdf')
#bf.to_nt('/path/to/output.nt')
#bf.to_nq('/path/to/output.nq')
#bf.to_json('/path/to/output.json')
#bf.to_jsonld('/path/to/output.jsonld')
````

## TODO

- Testの追加
- コードのリファイン
- Bibframeの進捗状況に合わせた改訂
