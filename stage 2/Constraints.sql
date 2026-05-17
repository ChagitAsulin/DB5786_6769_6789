-- Constraints.sql
-- שלב ב - הוספת 3 אילוצים חדשים בעזרת ALTER TABLE
-- להריץ אחרי יצירת הטבלאות והכנסת הנתונים.

-- אילוץ 1: אימייל חייב להיות בפורמט בסיסי תקין.
ALTER TABLE users
ADD CONSTRAINT chk_users_email_format
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- בדיקת שגיאה לאילוץ 1 - להריץ בנפרד כדי לצלם את השגיאה:
-- INSERT INTO users (user_id, full_name, username, email, status, created_date, role_id, department_id)
-- VALUES (999001, 'Bad Email User', 'bad.email.user', 'not-an-email', 'Active', CURRENT_DATE, 1, 1);


-- אילוץ 2: תאריך תחזוקה אחרונה של מצלמה לא יכול להיות לפני תאריך ההתקנה.
ALTER TABLE cctv_cameras
ADD CONSTRAINT chk_camera_maintenance_after_installation
CHECK (last_maintenance_date IS NULL OR last_maintenance_date >= installation_date);

-- בדיקת שגיאה לאילוץ 2 - להריץ בנפרד כדי לצלם את השגיאה:
-- INSERT INTO cctv_cameras (camera_id, installation_date, last_maintenance_date, status, location_id)
-- VALUES (999002, DATE '2025-01-10', DATE '2024-01-10', 'Active', 1);


-- אילוץ 3: תפקיד עובד באירוע לא יכול להיות מחרוזת ריקה או רווחים בלבד.
ALTER TABLE incident_assignments
ADD CONSTRAINT chk_incident_assignment_role_not_blank
CHECK (LENGTH(TRIM(role_in_incident)) > 0);

-- בדיקת שגיאה לאילוץ 3 - להריץ בנפרד כדי לצלם את השגיאה:
-- INSERT INTO incident_assignments (incident_id, user_id, assigned_date, role_in_incident)
-- VALUES (1, 2, CURRENT_DATE, '   ');
