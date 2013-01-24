class NagiosDataBags

  def initialize(bag_list=Chef::DataBag.list)
    @data_list = bag_list
  end

  def get(bag_name)
    if @bag_list.include?(bag_name)
      search(bag_name, "*:*")
    else
      Chef::Log.info "The #{bag_name} data bag does not exist."
      []
    end
  end
end
