# RubyClerk product may represent one of three things
# - the normal product (all attributes work as expected)
# - a product line, in which case it may not be sold and inventory is the sum of the items
#                   other attributes (like price/cost) act as a template and are copied into children
#                   where they are then used.
# - an (line) item of a product line, in which case the default view concatenates name and description and
#                   shows prices relative to it's parent
#
# This makes the model a three headed one and validation is a little more complicated
# - a product line _may not_ have an ean (as it can't be sold)
# - a product and product line _must_ have a link , but  (those are generated if needed)
# - line item _may not_ have a link (this is enforced, not validated)

# attributes : see permitted_attributes + inventory + deleted_on

class Product < ActiveRecord::Base
  mount_uploader :main_picture, ImageUploader
  has_many :products
  has_many :items
  store :properties, accessors: [ :color, :size , :model_number ] #, coder: JSON
  belongs_to :product
  belongs_to :category
  belongs_to :supplier
  has_attached_file :main_picture
  has_attached_file :extra_picture
  validates_attachment_content_type :main_picture, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :extra_picture, :content_type => /\Aimage\/.*\Z/

  # default product scope only lists non-deleted products
  default_scope {where(:deleted_on => nil).order('created_at DESC') }
  scope :online, -> { where(:online => true) }
  scope :no_items, -> { where(:product_id => nil) }
  scope :with_inventory, -> { where("inventory > 0") }
  # some shops may wish to add .with_inventory to the scope, but that means users can't see the page
  # and for products you carry regularly that is not desirable. The Product page checks, and the controller
  scope :shop_products , -> { online.no_items }

  validates :price, :numericality => true
  validates :cost, :numericality => true
  validates :name, :presence => true
  validates :deleted_on , :absence => true , :if => :has_inventory?

  before_save :check_attributes
  before_save :fix_cost
  after_save :update_line_inventory , :if => :product_id
  after_save :check_parent_ean , :if => :product_id


  def update_line_inventory
    parent = self.product
    return unless parent
    inv = parent.inventory
    parent.inventory = parent.products.sum(:inventory)
    parent.save! if inv != parent.inventory
  end

  def check_parent_ean
    parent = self.product
    return unless parent
    parent.check_attributes
    parent.save! if parent.changed?
  end

  # if no url is set we generate one based on the name
  # but product_items don't have urls, so not for them
  def check_attributes
    if product_item?
      self.link = ""
    else
      self.link = self.name.gsub(" " , "_").downcase if self.link.blank? && self.name != nil
    end
    if line?
      self.ean = "" unless self.ean.blank?
      self.scode = "" unless self.scode.blank?
    end
  end

  def has_inventory?
    self.inventory > 0
  end
  # has the product been deleted (marked as deleted)
  def deleted?
    not deleted_on.blank?
  end

  # deleting sets the deleted_on flag to today
  # Products can not be deleted because of the risk of invalidating old orders
  # to actually remove a product from the db, use the console
  def delete
    self.deleted_on = Date.today
    self.link = ""
    products.each {|p| p.delete}
    self
  end

  # the type is one of:
  # - product
  # -product_line
  # -product_item
  # mostly used for translation. Function below let you test for each of the possibilities
  def type
    return :product_item if product_item?
    products.empty? ? :product : :product_line
  end

  # this product represents a product line (ie is not sellable in itself)
  def line?
    !product_item? and !products.empty?
  end

  # this product is an item of a product line (so is sellable)
  def product_item?
    self.product_id != nil
  end

  # only products and product items are sellable. in other words if it's not a line
  def sellable?
    !line?
  end

  # full name, or display name, is the name for a product,
  # and the concatination of the parents name and the name, for product items
  def full_name
    if product_item?
      product.name + " : " + self.name
    else
      self.name
    end
  end

  def new_product_item
    Product.new :tax => self.tax , :weight => self.weight , :cost => self.cost ,  :product_id => self.id ,
        :supplier_id => self.supplier_id , :category_id => self.category_id , :price => self.price
  end

  private
  def fix_cost
    if self.cost == 0.0
      self.cost = self.price / 2
    end
  end
end
