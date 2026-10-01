class User < ApplicationRecord
  belongs_to :team, optional: true

  enum :role, { employee: "employee", support_engineer: "support_engineer" }, validate: true

  validates :team, presence: true, if: :employee?
  validates :team, absence: true, if: :support_engineer?
end
