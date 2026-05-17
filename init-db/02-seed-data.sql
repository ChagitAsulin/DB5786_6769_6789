-- 02-seed-data.sql
-- Initial seed data + CSV import
-- Updated according to the new 3NF DSD

INSERT INTO roles (role_id, role_name) VALUES
(1, 'Admin'),
(2, 'Security Manager'),
(3, 'Security Guard'),
(4, 'IT Manager'),
(5, 'IT Technician');

INSERT INTO departments (department_id, department_name) VALUES
(1, 'Security'),
(2, 'IT'),
(3, 'Reception'),
(4, 'Management'),
(5, 'Maintenance');

INSERT INTO locations (location_id, location_name) VALUES
(1, 'Lobby'),
(2, 'Reception'),
(3, 'Server Room'),
(4, 'Parking'),
(5, 'Main Gate');

COPY roles(role_id, role_name)
FROM '/docker-entrypoint-initdb.d/roles.csv'
DELIMITER ',' CSV HEADER;

COPY departments(department_id, department_name)
FROM '/docker-entrypoint-initdb.d/departments.csv'
DELIMITER ',' CSV HEADER;

COPY locations(location_id, location_name)
FROM '/docker-entrypoint-initdb.d/locations.csv'
DELIMITER ',' CSV HEADER;

COPY users(user_id, full_name, username, email, role_id, department_id, status, created_date)
FROM '/docker-entrypoint-initdb.d/users.csv'
DELIMITER ',' CSV HEADER;

COPY cctv_cameras(camera_id, installation_date, last_maintenance_date, status, location_id)
FROM '/docker-entrypoint-initdb.d/cctv_cameras.csv'
DELIMITER ',' CSV HEADER;

COPY it_assets(asset_id, asset_type, asset_name, purchase_date, status, location_id)
FROM '/docker-entrypoint-initdb.d/it_assets.csv'
DELIMITER ',' CSV HEADER;

COPY incidents(incident_id, description, reported_date, reported_by_user_id, camera_id)
FROM '/docker-entrypoint-initdb.d/incidents.csv'
DELIMITER ',' CSV HEADER;

COPY system_backups(backup_id, backup_date, backup_type, user_id)
FROM '/docker-entrypoint-initdb.d/system_backups.csv'
DELIMITER ',' CSV HEADER;

COPY incident_assignments(incident_id, user_id, assigned_date, role_in_incident)
FROM '/docker-entrypoint-initdb.d/incident_assignments.csv'
DELIMITER ',' CSV HEADER;

COPY access_logs(log_id, access_time, status, user_id, camera_id)
FROM '/docker-entrypoint-initdb.d/access_logs.csv'
DELIMITER ',' CSV HEADER;

COPY asset_incident(incident_id, asset_id, relation_description)
FROM '/docker-entrypoint-initdb.d/asset_incident.csv'
DELIMITER ',' CSV HEADER;
