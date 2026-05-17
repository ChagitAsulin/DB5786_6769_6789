-- Index.sql
-- שלב ב - 3 אינדקסים ובדיקת זמן ריצה לפני ואחרי
-- סדר עבודה מומלץ לכל אינדקס:
-- 1. להריץ EXPLAIN ANALYZE לפני יצירת האינדקס ולצלם.
-- 2. להריץ CREATE INDEX.
-- 3. להריץ שוב EXPLAIN ANALYZE ולצלם.
-- 4. להסביר בדוח האם התוכנית השתנתה מ-Seq Scan ל-Index Scan/Bitmap Index Scan והאם הזמן ירד.

/* =========================================================
   אינדקס 1: יומני גישה לפי סטטוס ותאריך
   טוב לשאילתות Dashboard שמסננות Failed/Denied ולפי תאריכים.
   ========================================================= */

-- לפני אינדקס:
EXPLAIN ANALYZE
SELECT
    status,
    EXTRACT(YEAR FROM access_time) AS access_year,
    EXTRACT(MONTH FROM access_time) AS access_month,
    COUNT(*) AS log_count
FROM access_logs
WHERE status IN ('Denied', 'Failed')
  AND access_time >= DATE '2025-01-01'
GROUP BY status, EXTRACT(YEAR FROM access_time), EXTRACT(MONTH FROM access_time)
ORDER BY access_year DESC, access_month DESC;

CREATE INDEX IF NOT EXISTS idx_access_logs_status_time
ON access_logs(status, access_time);

-- אחרי אינדקס:
EXPLAIN ANALYZE
SELECT
    status,
    EXTRACT(YEAR FROM access_time) AS access_year,
    EXTRACT(MONTH FROM access_time) AS access_month,
    COUNT(*) AS log_count
FROM access_logs
WHERE status IN ('Denied', 'Failed')
  AND access_time >= DATE '2025-01-01'
GROUP BY status, EXTRACT(YEAR FROM access_time), EXTRACT(MONTH FROM access_time)
ORDER BY access_year DESC, access_month DESC;


/* =========================================================
   אינדקס 2: אירועים לפי מדווח ותאריך
   טוב למסכי משתמש/אירועים שמציגים כמה אירועים דיווח כל עובד בתקופה.
   ========================================================= */

-- לפני אינדקס:
EXPLAIN ANALYZE
SELECT
    reported_by_user_id,
    EXTRACT(YEAR FROM reported_date) AS report_year,
    EXTRACT(MONTH FROM reported_date) AS report_month,
    COUNT(*) AS incident_count
FROM incidents
WHERE reported_date >= DATE '2024-09-01'
GROUP BY reported_by_user_id, EXTRACT(YEAR FROM reported_date), EXTRACT(MONTH FROM reported_date)
ORDER BY incident_count DESC;

CREATE INDEX IF NOT EXISTS idx_incidents_reported_by_date
ON incidents(reported_by_user_id, reported_date);

-- אחרי אינדקס:
EXPLAIN ANALYZE
SELECT
    reported_by_user_id,
    EXTRACT(YEAR FROM reported_date) AS report_year,
    EXTRACT(MONTH FROM reported_date) AS report_month,
    COUNT(*) AS incident_count
FROM incidents
WHERE reported_date >= DATE '2024-09-01'
GROUP BY reported_by_user_id, EXTRACT(YEAR FROM reported_date), EXTRACT(MONTH FROM reported_date)
ORDER BY incident_count DESC;


/* =========================================================
   אינדקס 3: גיבויים לפי סוג ותאריך
   טוב למסך Backup management שמסנן לפי סוג גיבוי ותקופה.
   ========================================================= */

-- לפני אינדקס:
EXPLAIN ANALYZE
SELECT
    backup_type,
    EXTRACT(YEAR FROM backup_date) AS backup_year,
    EXTRACT(MONTH FROM backup_date) AS backup_month,
    COUNT(*) AS backup_count
FROM system_backups
WHERE backup_type IN ('Full', 'Cloud')
  AND backup_date >= DATE '2025-01-01'
GROUP BY backup_type, EXTRACT(YEAR FROM backup_date), EXTRACT(MONTH FROM backup_date)
ORDER BY backup_year DESC, backup_month DESC;

CREATE INDEX IF NOT EXISTS idx_system_backups_type_date
ON system_backups(backup_type, backup_date);

-- אחרי אינדקס:
EXPLAIN ANALYZE
SELECT
    backup_type,
    EXTRACT(YEAR FROM backup_date) AS backup_year,
    EXTRACT(MONTH FROM backup_date) AS backup_month,
    COUNT(*) AS backup_count
FROM system_backups
WHERE backup_type IN ('Full', 'Cloud')
  AND backup_date >= DATE '2025-01-01'
GROUP BY backup_type, EXTRACT(YEAR FROM backup_date), EXTRACT(MONTH FROM backup_date)
ORDER BY backup_year DESC, backup_month DESC;
