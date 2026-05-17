-- Queries.sql
-- שלב ב - שאילתות SELECT / UPDATE / DELETE
-- Hotel Security Management System

/* =========================================================
   8 SELECT QUERIES
   4 הראשונות כתובות בשתי צורות: גרסת JOIN וגרסת SUBQUERY/EXISTS.
   מומלץ להריץ כל שאילתא בנפרד ולצלם עד 5 שורות תוצאה.
   ========================================================= */

-- SELECT 1A: דוח משתמשים פעילים עם מספר אירועי אבטחה שדיווחו עליהם בחודש/שנה.
-- מתאים למסך: Users / Security staff performance
SELECT
    u.user_id,
    u.full_name,
    r.role_name,
    d.department_name,
    EXTRACT(YEAR FROM i.reported_date) AS report_year,
    EXTRACT(MONTH FROM i.reported_date) AS report_month,
    COUNT(i.incident_id) AS incidents_reported
FROM users u
JOIN roles r ON u.role_id = r.role_id
JOIN departments d ON u.department_id = d.department_id
JOIN incidents i ON i.reported_by_user_id = u.user_id
WHERE u.status = 'Active'
GROUP BY u.user_id, u.full_name, r.role_name, d.department_name,
         EXTRACT(YEAR FROM i.reported_date), EXTRACT(MONTH FROM i.reported_date)
HAVING COUNT(i.incident_id) >= 1
ORDER BY incidents_reported DESC, report_year DESC, report_month DESC
LIMIT 5;

-- SELECT 1B: אותה מטרה בעזרת תת-שאילתא מתואמת.
SELECT
    u.user_id,
    u.full_name,
    (SELECT r.role_name FROM roles r WHERE r.role_id = u.role_id) AS role_name,
    (SELECT d.department_name FROM departments d WHERE d.department_id = u.department_id) AS department_name,
    EXTRACT(YEAR FROM i.reported_date) AS report_year,
    EXTRACT(MONTH FROM i.reported_date) AS report_month,
    COUNT(i.incident_id) AS incidents_reported
FROM users u
JOIN incidents i ON i.reported_by_user_id = u.user_id
WHERE u.status = 'Active'
GROUP BY u.user_id, u.full_name, u.role_id, u.department_id,
         EXTRACT(YEAR FROM i.reported_date), EXTRACT(MONTH FROM i.reported_date)
HAVING COUNT(i.incident_id) >= 1
ORDER BY incidents_reported DESC, report_year DESC, report_month DESC
LIMIT 5;

-- SELECT 2A: מצלמות עם כמות ניסיונות גישה שנכשלו/נדחו לפי מיקום.
-- מתאים למסך: Cameras / Access monitoring
SELECT
    c.camera_id,
    l.location_name,
    c.status AS camera_status,
    COUNT(al.log_id) AS denied_or_failed_logs,
    MAX(al.access_time) AS last_problem_access_date
FROM cctv_cameras c
JOIN locations l ON c.location_id = l.location_id
JOIN access_logs al ON al.camera_id = c.camera_id
WHERE al.status IN ('Denied', 'Failed')
GROUP BY c.camera_id, l.location_name, c.status
HAVING COUNT(al.log_id) >= 5
ORDER BY denied_or_failed_logs DESC, last_problem_access_date DESC
LIMIT 5;

-- SELECT 2B: אותה מטרה בעזרת תתי שאילתות מתואמות.
SELECT
    c.camera_id,
    l.location_name,
    c.status AS camera_status,
    (SELECT COUNT(*)
     FROM access_logs al
     WHERE al.camera_id = c.camera_id
       AND al.status IN ('Denied', 'Failed')) AS denied_or_failed_logs,
    (SELECT MAX(al.access_time)
     FROM access_logs al
     WHERE al.camera_id = c.camera_id
       AND al.status IN ('Denied', 'Failed')) AS last_problem_access_date
FROM cctv_cameras c
JOIN locations l ON c.location_id = l.location_id
WHERE (SELECT COUNT(*)
       FROM access_logs al
       WHERE al.camera_id = c.camera_id
         AND al.status IN ('Denied', 'Failed')) >= 5
ORDER BY denied_or_failed_logs DESC, last_problem_access_date DESC
LIMIT 5;

-- SELECT 3A: אירועים שיש להם גם עובדים משויכים וגם נכסי IT קשורים.
-- מתאים למסך: Incident details
SELECT
    i.incident_id,
    i.reported_date,
    reporter.full_name AS reported_by,
    c.camera_id,
    l.location_name,
    COUNT(DISTINCT ia.user_id) AS assigned_users,
    COUNT(DISTINCT ai.asset_id) AS related_assets
FROM incidents i
JOIN users reporter ON i.reported_by_user_id = reporter.user_id
LEFT JOIN cctv_cameras c ON i.camera_id = c.camera_id
LEFT JOIN locations l ON c.location_id = l.location_id
JOIN incident_assignments ia ON ia.incident_id = i.incident_id
JOIN asset_incident ai ON ai.incident_id = i.incident_id
GROUP BY i.incident_id, i.reported_date, reporter.full_name, c.camera_id, l.location_name
HAVING COUNT(DISTINCT ia.user_id) >= 1
   AND COUNT(DISTINCT ai.asset_id) >= 2
ORDER BY related_assets DESC, assigned_users DESC
LIMIT 5;

-- SELECT 3B: אותה מטרה בעזרת EXISTS ותתי שאילתות לספירה.
SELECT
    i.incident_id,
    i.reported_date,
    reporter.full_name AS reported_by,
    c.camera_id,
    l.location_name,
    (SELECT COUNT(DISTINCT ia.user_id)
     FROM incident_assignments ia
     WHERE ia.incident_id = i.incident_id) AS assigned_users,
    (SELECT COUNT(DISTINCT ai.asset_id)
     FROM asset_incident ai
     WHERE ai.incident_id = i.incident_id) AS related_assets
FROM incidents i
JOIN users reporter ON i.reported_by_user_id = reporter.user_id
LEFT JOIN cctv_cameras c ON i.camera_id = c.camera_id
LEFT JOIN locations l ON c.location_id = l.location_id
WHERE EXISTS (SELECT 1 FROM incident_assignments ia WHERE ia.incident_id = i.incident_id)
  AND (SELECT COUNT(*) FROM asset_incident ai WHERE ai.incident_id = i.incident_id) >= 2
ORDER BY related_assets DESC, assigned_users DESC
LIMIT 5;

-- SELECT 4A: עובדים שביצעו גיבויים, לפי שנה וחודש, כולל כמות וסוגי גיבוי.
-- מתאים למסך: Backup management
SELECT
    u.user_id,
    u.full_name,
    d.department_name,
    EXTRACT(YEAR FROM sb.backup_date) AS backup_year,
    EXTRACT(MONTH FROM sb.backup_date) AS backup_month,
    COUNT(sb.backup_id) AS backup_count,
    COUNT(DISTINCT sb.backup_type) AS backup_type_count
FROM system_backups sb
JOIN users u ON sb.user_id = u.user_id
JOIN departments d ON u.department_id = d.department_id
GROUP BY u.user_id, u.full_name, d.department_name,
         EXTRACT(YEAR FROM sb.backup_date), EXTRACT(MONTH FROM sb.backup_date)
HAVING COUNT(sb.backup_id) >= 1
ORDER BY backup_count DESC, backup_year DESC, backup_month DESC
LIMIT 5;

-- SELECT 4B: אותה מטרה בעזרת CTE שמחשב קודם אגרגציה ואז מצטרף למשתמשים.
WITH backup_summary AS (
    SELECT
        user_id,
        EXTRACT(YEAR FROM backup_date) AS backup_year,
        EXTRACT(MONTH FROM backup_date) AS backup_month,
        COUNT(backup_id) AS backup_count,
        COUNT(DISTINCT backup_type) AS backup_type_count
    FROM system_backups
    GROUP BY user_id, EXTRACT(YEAR FROM backup_date), EXTRACT(MONTH FROM backup_date)
)
SELECT
    u.user_id,
    u.full_name,
    d.department_name,
    bs.backup_year,
    bs.backup_month,
    bs.backup_count,
    bs.backup_type_count
FROM backup_summary bs
JOIN users u ON bs.user_id = u.user_id
JOIN departments d ON u.department_id = d.department_id
WHERE bs.backup_count >= 1
ORDER BY bs.backup_count DESC, bs.backup_year DESC, bs.backup_month DESC
LIMIT 5;

-- SELECT 5: נכסי IT בעייתיים במיקומים שבהם היו אירועים.
-- מתאים למסך: Assets / Risk map
SELECT
    a.asset_id,
    a.asset_name,
    a.asset_type,
    a.status AS asset_status,
    l.location_name,
    COUNT(DISTINCT ai.incident_id) AS related_incidents
FROM it_assets a
JOIN locations l ON a.location_id = l.location_id
JOIN asset_incident ai ON ai.asset_id = a.asset_id
WHERE a.status IN ('Offline', 'Maintenance', 'Retired')
GROUP BY a.asset_id, a.asset_name, a.asset_type, a.status, l.location_name
HAVING COUNT(DISTINCT ai.incident_id) >= 1
ORDER BY related_incidents DESC, a.status
LIMIT 5;

-- SELECT 6: חודשים עם עומס גבוה של יומני גישה בעייתיים.
-- מתאים למסך: Access logs dashboard
SELECT
    EXTRACT(YEAR FROM al.access_time) AS access_year,
    EXTRACT(MONTH FROM al.access_time) AS access_month,
    al.status,
    COUNT(*) AS log_count,
    COUNT(DISTINCT al.user_id) AS affected_users,
    COUNT(DISTINCT al.camera_id) AS affected_cameras
FROM access_logs al
WHERE al.status IN ('Denied', 'Failed')
GROUP BY EXTRACT(YEAR FROM al.access_time), EXTRACT(MONTH FROM al.access_time), al.status
HAVING COUNT(*) >= 10
ORDER BY access_year DESC, access_month DESC, log_count DESC
LIMIT 5;

-- SELECT 7: מצלמות שדורשות תחזוקה לפי פער בין תאריך התקנה לתחזוקה אחרונה.
-- מתאים למסך: Camera maintenance
SELECT
    c.camera_id,
    l.location_name,
    c.status,
    c.installation_date,
    c.last_maintenance_date,
    (c.last_maintenance_date - c.installation_date) AS days_until_first_or_last_maintenance,
    EXTRACT(YEAR FROM c.last_maintenance_date) AS maintenance_year,
    EXTRACT(MONTH FROM c.last_maintenance_date) AS maintenance_month
FROM cctv_cameras c
JOIN locations l ON c.location_id = l.location_id
WHERE c.last_maintenance_date IS NOT NULL
  AND (c.last_maintenance_date - c.installation_date) > 180
ORDER BY days_until_first_or_last_maintenance DESC
LIMIT 5;

-- SELECT 8: עובדים עם הרבה כישלונות גישה ופרטי תפקיד/מחלקה.
-- מתאים למסך: User access audit
SELECT
    u.user_id,
    u.full_name,
    r.role_name,
    d.department_name,
    COUNT(al.log_id) AS failed_or_denied_count,
    MIN(al.access_time) AS first_problem_date,
    MAX(al.access_time) AS last_problem_date
FROM users u
JOIN roles r ON u.role_id = r.role_id
JOIN departments d ON u.department_id = d.department_id
JOIN access_logs al ON al.user_id = u.user_id
WHERE al.status IN ('Failed', 'Denied')
GROUP BY u.user_id, u.full_name, r.role_name, d.department_name
HAVING COUNT(al.log_id) >= 5
ORDER BY failed_or_denied_count DESC, last_problem_date DESC
LIMIT 5;

/* =========================================================
   3 UPDATE QUERIES
   מומלץ להריץ בתוך טרנזקציה בזמן צילום לפני/אחרי.
   ========================================================= */

-- UPDATE 1: סימון מצלמות כ-Maintenance אם עברו מעל 250 ימים מהתחזוקה האחרונה ויש להן ניסיונות גישה בעייתיים.
UPDATE cctv_cameras c
SET status = 'Maintenance'
WHERE c.status = 'Active'
  AND c.last_maintenance_date < DATE '2025-01-01'
  AND EXISTS (
      SELECT 1
      FROM access_logs al
      WHERE al.camera_id = c.camera_id
        AND al.status IN ('Denied', 'Failed')
  )
RETURNING c.camera_id, c.status, c.last_maintenance_date, c.location_id;

-- UPDATE 2: השבתת משתמשים לא פעילים שנוצרו לפני 2024-06-01 ויש להם ניסיונות גישה שנכשלו.
UPDATE users u
SET status = 'Disabled'
WHERE u.status = 'Inactive'
  AND u.created_date < DATE '2024-06-01'
  AND EXISTS (
      SELECT 1
      FROM access_logs al
      WHERE al.user_id = u.user_id
        AND al.status = 'Failed'
  )
RETURNING u.user_id, u.full_name, u.status, u.created_date;

-- UPDATE 3: העברת נכסי IT ישנים במצב Offline ל-Retired.
UPDATE it_assets a
SET status = 'Retired'
WHERE a.status = 'Offline'
  AND a.purchase_date < DATE '2024-07-01'
RETURNING a.asset_id, a.asset_name, a.asset_type, a.status, a.purchase_date;

/* =========================================================
   3 DELETE QUERIES
   נמחק רק מטבלאות בן כדי לא לשבור קשרי FK.
   ========================================================= */

-- DELETE 1: מחיקת יומני גישה ישנים שנכשלו/נדחו לפני 2024-10-01.
DELETE FROM access_logs al
WHERE al.access_time < DATE '2024-10-01'
  AND al.status IN ('Failed', 'Denied')
RETURNING al.log_id, al.access_time, al.status, al.user_id, al.camera_id;

-- DELETE 2: מחיקת קשרי נכס-אירוע עבור נכסים שכבר Retired.
DELETE FROM asset_incident ai
USING it_assets a
WHERE ai.asset_id = a.asset_id
  AND a.status = 'Retired'
RETURNING ai.incident_id, ai.asset_id, ai.relation_description, a.asset_name, a.status;

-- DELETE 3: מחיקת שיוכי עובדים לאירועים ישנים במיוחד.
DELETE FROM incident_assignments ia
USING incidents i
WHERE ia.incident_id = i.incident_id
  AND i.reported_date < DATE '2024-09-01'
RETURNING ia.incident_id, ia.user_id, ia.assigned_date, ia.role_in_incident;
