class User < ApplicationRecord
  enum :role, { employee: "employee", support_engineer: "support_engineer" }, validate: true
end
