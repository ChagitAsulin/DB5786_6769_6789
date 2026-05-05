-- checkCounts.sql
-- Check number of records in each table

SELECT 'roles' AS table_name, COUNT(*) AS total_rows FROM roles
UNION ALL SELECT 'departments', COUNT(*) FROM departments
UNION ALL SELECT 'locations', COUNT(*) FROM locations
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'cctv_cameras', COUNT(*) FROM cctv_cameras
UNION ALL SELECT 'it_assets', COUNT(*) FROM it_assets
UNION ALL SELECT 'incidents', COUNT(*) FROM incidents
UNION ALL SELECT 'system_backups', COUNT(*) FROM system_backups
UNION ALL SELECT 'incident_assignments', COUNT(*) FROM incident_assignments
UNION ALL SELECT 'access_logs', COUNT(*) FROM access_logs
UNION ALL SELECT 'asset_incident', COUNT(*) FROM asset_incident
ORDER BY table_name;
