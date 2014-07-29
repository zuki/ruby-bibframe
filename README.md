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
require 'rdf'
require 'marc'
require 'bibframe'
require 'rdf/rdfxml'

reader = MARC::XMLReader.new('/path/to/MARCXML.xml')
repo = RDF::Repository.new
# 典拠IDを付加し、名前付きグラフにする
for record in reader
	repo << Bibframe::BFRDF(record, resolve: true, repository: repo).graph
end

RDF::RDFXML::Writer.open('/path/to/output.rdf') do |writer|
  writer << repo
end
````

## TODO

- Testの追加
- コードのリファイン
- Bibframeの進捗状況に合わせた改訂
