CREATE TABLE roles (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    role_id INT NOT NULL,
    department_id INT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Active', 'Inactive', 'Disabled')),
    created_date DATE NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE access_logs (
    log_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    access_type VARCHAR(50) NOT NULL CHECK (access_type IN ('System Login', 'Room Access', 'Server Room Access')),
    location VARCHAR(100) NOT NULL,
    access_time DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Success', 'Failed', 'Denied')),
    ip_address VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE cctv_cameras (
    camera_id INT PRIMARY KEY,
    location VARCHAR(100) NOT NULL,
    installation_date DATE NOT NULL,
    last_maintenance_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Active', 'Inactive', 'Offline', 'Maintenance'))
);

CREATE TABLE incidents (
    incident_id INT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    reported_by INT NOT NULL,
    reported_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Open', 'In Progress', 'Resolved')),
    camera_id INT,
    FOREIGN KEY (reported_by) REFERENCES users(user_id),
    FOREIGN KEY (camera_id) REFERENCES cctv_cameras(camera_id)
);

CREATE TABLE it_assets (
    asset_id INT PRIMARY KEY,
    asset_type VARCHAR(50) NOT NULL,
    asset_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    purchase_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Operational', 'Maintenance', 'Offline', 'Retired'))
);

CREATE TABLE system_backups (
    backup_id INT PRIMARY KEY,
    backup_type VARCHAR(50) NOT NULL CHECK (backup_type IN ('Full', 'Incremental', 'Differential', 'Cloud')),
    backup_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Success', 'Failed', 'In Progress')),
    performed_by INT NOT NULL,
    FOREIGN KEY (performed_by) REFERENCES users(user_id)
);

CREATE TABLE incident_assignments (
    incident_id INT NOT NULL,
    user_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    role_in_incident VARCHAR(50) NOT NULL,
    PRIMARY KEY (incident_id, user_id),
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE asset_incident (
    incident_id INT NOT NULL,
    asset_id INT NOT NULL,
    relation_description VARCHAR(200),
    PRIMARY KEY (incident_id, asset_id),
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id),
    FOREIGN KEY (asset_id) REFERENCES it_assets(asset_id)
);