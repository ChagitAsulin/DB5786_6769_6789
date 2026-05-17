-- RollbackCommit.sql
-- שלב ב - הדגמת ROLLBACK ו-COMMIT
-- חשוב להריץ כל חלק בנפרד ולצלם את מצב הנתונים לפני/אחרי.

/* =========================================================
   דוגמה 1: UPDATE + ROLLBACK
   לאחר ROLLBACK המצלמה תחזור לסטטוס המקורי.
   ========================================================= */

-- מצב לפני
SELECT camera_id, status, last_maintenance_date
FROM cctv_cameras
WHERE camera_id = 1;

BEGIN;

UPDATE cctv_cameras
SET status = 'Offline'
WHERE camera_id = 1;

-- מצב אחרי העדכון, לפני ROLLBACK
SELECT camera_id, status, last_maintenance_date
FROM cctv_cameras
WHERE camera_id = 1;

ROLLBACK;

-- מצב אחרי ROLLBACK - אמור לחזור לערך שהיה לפני העדכון
SELECT camera_id, status, last_maintenance_date
FROM cctv_cameras
WHERE camera_id = 1;


/* =========================================================
   דוגמה 2: UPDATE + COMMIT
   לאחר COMMIT השינוי נשמר.
   ========================================================= */

-- מצב לפני
SELECT asset_id, asset_name, status, purchase_date
FROM it_assets
WHERE asset_id = 1;

BEGIN;

UPDATE it_assets
SET status = 'Maintenance'
WHERE asset_id = 1;

-- מצב אחרי העדכון, לפני COMMIT
SELECT asset_id, asset_name, status, purchase_date
FROM it_assets
WHERE asset_id = 1;

COMMIT;

-- מצב אחרי COMMIT - אמור להישאר כמו אחרי העדכון
SELECT asset_id, asset_name, status, purchase_date
FROM it_assets
WHERE asset_id = 1;
