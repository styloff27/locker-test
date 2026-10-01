CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "tenants" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "lockers" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "tenant_id" integer NOT NULL, "name" varchar NOT NULL, "location" varchar NOT NULL, "state" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_372ed80f63"
FOREIGN KEY ("tenant_id")
  REFERENCES "tenants" ("id")
, CONSTRAINT lockers_state_check CHECK (state IN ('open', 'closed')));
CREATE INDEX "index_lockers_on_tenant_id" ON "lockers" ("tenant_id") /*application='LockerPlatform'*/;
CREATE TABLE IF NOT EXISTS "teams" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "tenant_id" integer NOT NULL, "name" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_287242fcbb"
FOREIGN KEY ("tenant_id")
  REFERENCES "tenants" ("id")
);
CREATE INDEX "index_teams_on_tenant_id" ON "teams" ("tenant_id") /*application='LockerPlatform'*/;
CREATE UNIQUE INDEX "index_teams_on_id_and_tenant_id" ON "teams" ("id", "tenant_id") /*application='LockerPlatform'*/;
CREATE UNIQUE INDEX "index_lockers_on_id_and_tenant_id" ON "lockers" ("id", "tenant_id") /*application='LockerPlatform'*/;
CREATE TABLE IF NOT EXISTS "locker_assignments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "team_id" integer NOT NULL, "locker_id" integer NOT NULL, "tenant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_fd0538b821"
FOREIGN KEY ("team_id", "tenant_id")
  REFERENCES "teams" ("id", "tenant_id")
, CONSTRAINT "fk_rails_8e0b739861"
FOREIGN KEY ("locker_id", "tenant_id")
  REFERENCES "lockers" ("id", "tenant_id")
);
CREATE INDEX "index_locker_assignments_on_locker_id" ON "locker_assignments" ("locker_id") /*application='LockerPlatform'*/;
CREATE UNIQUE INDEX "index_locker_assignments_on_team_id_and_locker_id" ON "locker_assignments" ("team_id", "locker_id") /*application='LockerPlatform'*/;
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "role" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "team_id" integer, CONSTRAINT "fk_rails_b2bbf87303"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
, CONSTRAINT users_role_check CHECK (role IN ('employee', 'support_engineer')), CONSTRAINT users_team_check CHECK ((role = 'employee' AND team_id IS NOT NULL) OR (role = 'support_engineer' AND team_id IS NULL)));
CREATE INDEX "index_users_on_team_id" ON "users" ("team_id") /*application='LockerPlatform'*/;
CREATE TABLE IF NOT EXISTS "locker_actions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "locker_id" integer NOT NULL, "user_id" integer NOT NULL, "kind" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_96d43ca878"
FOREIGN KEY ("locker_id")
  REFERENCES "lockers" ("id")
, CONSTRAINT "fk_rails_70fed88948"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT locker_actions_kind_check CHECK (kind IN ('open', 'close')));
CREATE INDEX "index_locker_actions_on_locker_id" ON "locker_actions" ("locker_id") /*application='LockerPlatform'*/;
CREATE INDEX "index_locker_actions_on_user_id" ON "locker_actions" ("user_id") /*application='LockerPlatform'*/;
CREATE TRIGGER locker_actions_tenant_check
BEFORE INSERT ON locker_actions
WHEN EXISTS (
  SELECT 1 FROM users
  JOIN teams ON teams.id = users.team_id
  JOIN lockers ON lockers.id = NEW.locker_id
  WHERE users.id = NEW.user_id
    AND teams.tenant_id != lockers.tenant_id
)
BEGIN
  SELECT RAISE(ABORT, 'Locker Action: the Locker and the Employee belong to different tenants');
END;
INSERT INTO "schema_migrations" (version) VALUES
('20261001191651'),
('20261001185042'),
('20261001165030'),
('20261001165028'),
('20261001165027'),
('20261001164306'),
('20261001161652'),
('20261001161651'),
('20261001161650');

