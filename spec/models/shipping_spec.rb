require 'spec_helper'

describe "ShippingMethod"  do
  it "has at least one method with data" do
    methods = OfficeClerk::ShippingMethod.all
    expect(methods).not_to be_empty
    expect(methods.values.first.data).to be_a(Hash)
  end
  it "provides pickup" do
    method = OfficeClerk::ShippingMethod.all[:pickup]
    expect(method).not_to be nil
    expect(method.name).not_to be nil
    expect(method.type).not_to be nil
  end
  it "Pickup is free" do
    method = OfficeClerk::ShippingMethod.all[:pickup]
    basket = create :basket
    expect(method.price_for(basket)).to eq 0.0
  end
  it "creates Pickup with data" do
    method = OfficeClerk::Pickup.new(:name => "me" , :type => :pick2)
    expect(method.name).to eq "me"
    expect(method.type).to eq :pick2
  end
end
