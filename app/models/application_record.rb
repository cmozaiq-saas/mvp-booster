class ApplicationRecord < ActiveRecord::Base
  include SpreadsheetArchitect; primary_abstract_class
  self.implicit_order_column = "created_at" # great when using uuid to by default order records
end
