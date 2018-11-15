# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../rubocop/cop/safe_params'

describe RuboCop::Cop::SafeParams do
  include CopHelper

  subject(:cop) { described_class.new }

  it 'flags the params as an argument of url_for' do
    inspect_source('url_for(params)')

    expect(cop.offenses.size).to eq(1)
  end

  it 'flags the merged params as an argument of url_for' do
    inspect_source('url_for(params.merge(additional_params))')

    expect(cop.offenses.size).to eq(1)
  end

  it 'flags the merged params arg as an argument of url_for' do
    inspect_source('url_for(something.merge(additional).merge(params))')

    expect(cop.offenses.size).to eq(1)
  end

  it 'does not flag other argument of url_for' do
    inspect_source('url_for(something)')

    expect(cop.offenses).to be_empty
  end
end
