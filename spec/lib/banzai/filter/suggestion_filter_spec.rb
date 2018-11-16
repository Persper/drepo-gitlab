require 'spec_helper'

describe Banzai::Filter::SuggestionFilter do
  include FilterSpecHelper

  it 'includes `js-render-suggestion` class' do
    input = "<pre class='code highlight js-syntax-highlight suggestion'><code>foo\n</code></pre>"

    doc = filter(input)
    result = doc.css('code').first

    expect(result[:class]).to include('js-render-suggestion')
  end
end
