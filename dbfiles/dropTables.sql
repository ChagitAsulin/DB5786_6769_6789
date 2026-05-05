-- Drop tables in correct order (children -> parents)

DROP TABLE IF EXISTS asset_incident;
DROP TABLE IF EXISTS access_logs;
DROP TABLE IF EXISTS incident_assignments;
DROP TABLE IF EXISTS system_backups;
DROP TABLE IF EXISTS incidents;
DROP TABLE IF EXISTS it_assets;
DROP TABLE IF EXISTS cctv_cameras;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS roles;
