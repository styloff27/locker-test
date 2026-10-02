# Deterministic demo data. Re-running resets every record below to these values.

users = {}

[ "Sam", "Kim" ].each do |name|
  users[name] = User.find_or_initialize_by(name: "#{name} (Support Engineer)")
  users[name].update!(role: :support_engineer)
end

amazon = Tenant.find_or_create_by!(name: "Amazon")
dpd = Tenant.find_or_create_by!(name: "DPD")

[
  [ amazon, "BER-1", "Berlin, Alexanderplatz 1", :open ],
  [ amazon, "BER-2", "Berlin, Warschauer Str. 12", :closed ],
  [ amazon, "BER-3", "Berlin, Kurfürstendamm 50", :closed ],
  [ amazon, "MUC-1", "Munich, Marienplatz 8", :open ],
  [ dpd, "HAM-1", "Hamburg, Mönckebergstr. 7", :closed ],
  [ dpd, "HAM-2", "Hamburg, Jungfernstieg 30", :open ],
  [ dpd, "HAM-3", "Hamburg, Reeperbahn 1", :closed ],
  [ dpd, "CGN-1", "Cologne, Domkloster 4", :closed ]
].each do |tenant, name, location, state|
  Locker.find_or_initialize_by(tenant:, name:).update!(location:, state:)
end

# One Employee per Team. Berlin Morning and Berlin Night share BER-1, and HAM-3 stays unassigned.
[
  [ "Alice", amazon, "Berlin Morning", [ "BER-1", "BER-2" ] ],
  [ "Bob", amazon, "Berlin Night", [ "BER-1", "BER-3" ] ],
  [ "Carol", amazon, "Munich", [ "MUC-1" ] ],
  [ "Dave", dpd, "Hamburg", [ "HAM-1", "HAM-2" ] ],
  [ "Erin", dpd, "Cologne", [ "CGN-1" ] ]
].each do |first_name, tenant, team_name, locker_names|
  team = Team.find_or_create_by!(tenant:, name: team_name)
  users[first_name] = User.find_or_initialize_by(name: "#{first_name} (#{tenant.name} · #{team_name})")
  users[first_name].update!(role: :employee, team:)
  locker_names.each do |name|
    LockerAssignment.find_or_create_by!(team:, locker: Locker.find_by!(tenant:, name:))
  end
end

# Locker Actions, oldest first, one hour apart. Each Locker's last Locker Action matches its Locker State above.
# Inserted directly, because Locker#operate would check each kind against the Locker's final State.
LockerAction.delete_all
history = [
  [ "BER-1", "Alice", "close" ], [ "HAM-1", "Dave", "open" ], [ "BER-2", "Alice", "open" ],
  [ "BER-1", "Bob", "open" ], [ "MUC-1", "Carol", "open" ], [ "HAM-3", "Sam", "open" ],
  [ "CGN-1", "Erin", "open" ], [ "BER-3", "Bob", "close" ], [ "HAM-2", "Dave", "open" ],
  [ "BER-1", "Sam", "close" ], [ "HAM-1", "Kim", "close" ], [ "BER-2", "Alice", "close" ],
  [ "CGN-1", "Erin", "close" ], [ "HAM-3", "Kim", "close" ], [ "BER-1", "Alice", "open" ]
]
history.each_with_index do |(locker_name, user_name, kind), index|
  locker = Locker.find_by!(name: locker_name)
  LockerAction.insert!({ locker_id: locker.id, user_id: users.fetch(user_name).id, kind:, created_at: (history.size - index).hours.ago })
end
