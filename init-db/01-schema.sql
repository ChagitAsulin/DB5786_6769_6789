-- 01-schema.sql
-- Schema for Hotel Security Management System
-- Updated according to the new 3NF DSD

CREATE TABLE IF NOT EXISTS roles (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS locations (
    location_id INT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Active', 'Inactive', 'Disabled')),
    created_date DATE NOT NULL,
    role_id INT NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE IF NOT EXISTS cctv_cameras (
    camera_id INT PRIMARY KEY,
    installation_date DATE NOT NULL,
    last_maintenance_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Active', 'Inactive', 'Offline', 'Maintenance')),
    location_id INT NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE IF NOT EXISTS it_assets (
    asset_id INT PRIMARY KEY,
    asset_type VARCHAR(50) NOT NULL,
    asset_name VARCHAR(100) NOT NULL,
    purchase_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Operational', 'Maintenance', 'Offline', 'Retired')),
    location_id INT NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE IF NOT EXISTS incidents (
    incident_id INT PRIMARY KEY,
    description TEXT NOT NULL,
    reported_date DATE NOT NULL,
    reported_by_user_id INT NOT NULL,
    camera_id INT,
    FOREIGN KEY (reported_by_user_id) REFERENCES users(user_id),
    FOREIGN KEY (camera_id) REFERENCES cctv_cameras(camera_id)
);

CREATE TABLE IF NOT EXISTS system_backups (
    backup_id INT PRIMARY KEY,
    backup_date DATE NOT NULL,
    backup_type VARCHAR(50) NOT NULL CHECK (backup_type IN ('Full', 'Incremental', 'Differential', 'Cloud')),
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS incident_assignments (
    incident_id INT NOT NULL,
    user_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    role_in_incident VARCHAR(50) NOT NULL,
    PRIMARY KEY (incident_id, user_id),
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS access_logs (
    log_id INT PRIMARY KEY,
    access_time DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Success', 'Failed', 'Denied')),
    user_id INT NOT NULL,
    camera_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (camera_id) REFERENCES cctv_cameras(camera_id)
);

CREATE TABLE IF NOT EXISTS asset_incident (
    incident_id INT NOT NULL,
    asset_id INT NOT NULL,
    relation_description VARCHAR(200),
    PRIMARY KEY (incident_id, asset_id),
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id),
    FOREIGN KEY (asset_id) REFERENCES it_assets(asset_id)
);
