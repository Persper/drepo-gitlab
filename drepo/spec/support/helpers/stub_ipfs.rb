module StubIpfs
  def stub_ipfs_add
    uri = /#{Gitlab.config.ipfs.http_api}\/api\/v0\/add.*/
    body = {
      "Name" => "2019-04-26_16-55-600_twitter_typeahead-js_drepo_export.tar.gz",
      "Hash" => "QmZ1x7NRurQ6ptWG1bW2zB3y1QFNySTjgCE9vTiATcP71g",
      "Size" => "2324134"
    }
    WebMock.stub_request(:get, uri).to_return(body: body.to_json)
  end

  def stub_ipfs_cat(file)
    uri = /#{Gitlab.config.ipfs.http_api}\/api\/v0\/cat\?.*/
    WebMock.stub_request(:any, uri).to_return(body: File.new(file))
  end
end
