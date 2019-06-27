class DrepoUsersController < ApplicationController
  skip_before_action :drepo_check_username_verification
  before_action :set_user, only: [:check_username, :verified]
  before_action :check_username_verified
  skip_before_action :verify_authenticity_token, only: :verified

  def check_username
  end

  def verified
    username = params[:bind_username]
    message = params[:message]
    signature = params[:signature]

    if [username, message, signature].any? { |x| x.blank? }
      flash[:alert] = "some param is invalid."
      return
    end

    is_equal, address = verify_signature(username, message, signature)
    unless is_equal
      flash[:alert] = "Unmatch signature. Verify failure."
      return
    end

    # rubocop: disable CodeReuse/ActiveRecord
    had_user = User.find_by(username: username)
    had_user.update(username: message, is_username_verified: false) if had_user

    @user.username = username
    @user.ethereum_addresses << address
    @user.is_username_verified = true

    if @user.save
      redirect_to root_path
    else
      redirect_to drepo_check_username_path
    end
  end

  def sign_message
    username = params[:username]
    address = params[:address]

    unless username =~ /^[a-zA-Z0-9]{1,255}$/ || address =~ /^(?:0x)?[a-zA-Z0-9]{40}$/
      return render json: { status: 'error', msg: "invalid username or address" }
    end

    unless address_possess_this_username(username, address)
      return render json: { status: 'error', msg: "the username not match the address" }
    end

    message = Digest::SHA3.hexdigest(('a'..'z').to_a.sample(10).join)
    key = "#{message}:#{username}"
    set_bind_info_in_redis(key, address)
    render json: { status: 'success', data: { username: username, address: address, message: message } }
  end

  private

  def set_user
    @user = current_user
  end

  def check_username_verified
    return unless current_user

    if !Settings['drepo'] || (Settings['drepo'] && !Settings['drepo']['need_check_username']) ||
        current_user.username == 'root' || current_user.is_username_verified
      redirect_to root_path
    end
  end

  def address_possess_this_username(username, address)
    # FIXME: use config setting to set the key and api url
    private_key = Eth::Key.new(priv: '2441BEC4BB235B0C2749200FB787164279FEE26D6F8F4B3AF52724D82CDAC2CE')
    client = Ethereum::HttpClient.new('https://rinkeby.infura.io/v3/8d1ba1e9ef484906ba94d560cc1d3a87')
    client.default_account = private_key.address

    contract_file_path = Rails.root.join('drepo/app/assets/javascripts/drepo_contract/central.json').to_s
    contract_address, abi = parse_contract_file(contract_file_path)

    contract = Ethereum::Contract.create(name: 'Central', client: client, abi: abi, address: contract_address)
    contract.key = private_key
    result = contract.call.get_entity(["#{Digest::SHA3.digest(username, 256)}"])

    if result[0] && result[0] =~ /^[a-zA-Z0-9]{1,255}$/ && result[0] == username &&
        result[5] && result[5].is_a?(Array)
      return result[5].include?(address.gsub(/^0x/, ''))
    end
  end

  def verify_signature(username, message, signature)
    key = "#{message}:#{username}"
    stored_address = get_bind_info_from_redis(key)
    return false unless stored_address

    public_key = Eth::Key.personal_recover(message, signature)
    recovered_address = Eth::Utils.public_key_to_address(public_key)
    [stored_address.gsub(/^0x/, '').casecmp(recovered_address.gsub(/^0x/, '')).zero?, stored_address]
  end

  def set_bind_info_in_redis(key, val)
    Gitlab::Redis::SharedState.with do |redis|
      redis.setex(key, 2.hours.seconds, val)
    end
  end

  def get_bind_info_from_redis(key)
    Gitlab::Redis::SharedState.with do |redis|
      redis.get(key)
    end
  end

  def parse_contract_file(file)
    return [nil, nil] unless File.exist?(file)

    contract_info = JSON.parse(File.read(file))
    [contract_info['address'], contract_info['interface']]
  end
end
