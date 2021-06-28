module UserLogHelper
  def get_receivers(send_matter_id,item)
    receivers = Receiver.where(:send_matter_id => send_matter_id)
    tmp_receivers = Hash.new
    tmp_receivers[:name] = Array.new
    tmp_receivers[:mail_address] = Array.new
    unless receivers.blank?
      receivers.each do |receiver|
        tmp_receivers[:name].push receiver.name
        tmp_receivers[:mail_address].push receiver.mail_address
      end
    end
    return tmp_receivers[item.to_sym]
  end

  def get_requested_matters_info(request_matter_id)
    requested_matters = RequestedMatter.where(:request_matter_id => request_matter_id)
    tmp_info = Hash.new
    info = Array.new
    tmp_info[:name] = Array.new
    tmp_info[:mail_address] = Array.new
    unless requested_matters.blank?
      requested_matters.each do |requested_matter|
        tmp_info[:name].push requested_matter.name
        tmp_info[:mail_address].push requested_matter.mail_address
        info.push [requested_matter.id, requested_matter.name, requested_matter.mail_address]
      end
    end
    return info
  end

end
