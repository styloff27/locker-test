class Team < ApplicationRecord
  belongs_to :tenant
  attr_readonly :tenant_id
end
