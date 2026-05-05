import csv
import random
from datetime import date, timedelta
from pathlib import Path

NUM_SMALL = 500
NUM_BIG = 20000

random.seed(5786)
base_date = date(2024, 1, 1)
OUTPUT_DIR = Path(__file__).resolve().parent

user_statuses = ["Active", "Inactive", "Disabled"]
access_types = ["System Login", "Room Access", "Server Room Access"]
access_statuses = ["Success", "Failed", "Denied"]
camera_statuses = ["Active", "Inactive", "Offline", "Maintenance"]
severity_values = ["Low", "Medium", "High", "Critical"]
incident_statuses = ["Open", "In Progress", "Resolved"]
asset_statuses = ["Operational", "Maintenance", "Offline", "Retired"]
backup_types = ["Full", "Incremental", "Differential", "Cloud"]
backup_statuses = ["Success", "Failed", "In Progress"]
asset_types = ["Laptop", "Server", "Router", "Switch", "Camera System", "Firewall", "Printer"]
incident_roles = ["Owner", "Investigator", "Technician", "Reporter", "Reviewer"]

location_names = [
    "Lobby", "Reception", "Server Room", "Parking", "Kitchen", "Floor 1", "Floor 2",
    "Floor 3", "Pool", "Gym", "Storage", "Conference Room", "Main Gate", "Back Gate"
]

first_names = [
    "Hagit", "Noa", "Dana", "Ron", "Amit", "Maya", "David", "Yael", "Lior", "Shira",
    "Daniel", "Tamar", "Yossi", "Rina", "Eli", "Michal", "Avi", "Sara", "Omer", "Gal"
]
last_names = [
    "Cohen", "Levi", "Mizrahi", "Peretz", "Biton", "Avraham", "Friedman", "Azulai", "Katz", "Dahan",
    "Malka", "Shalom", "Ben David", "Harel", "Bar", "Tal", "Assulin", "Mor", "Dayan", "Sela"
]


def random_date(start_offset=0, max_days=850):
    return base_date + timedelta(days=random.randint(start_offset, max_days))


def write_csv(filename, header, rows):
    with open(OUTPUT_DIR / filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)


# IDs 1-5 are intended for manual INSERT commands in insertTables.sql.
# Python-generated CSV rows therefore start from ID 6 where relevant.

# 1. roles.csv
roles_rows = [(i, f"Role {i}") for i in range(6, NUM_SMALL + 1)]
write_csv("roles.csv", ["role_id", "role_name"], roles_rows)

# 2. departments.csv
departments_rows = [(i, f"Department {i}") for i in range(6, NUM_SMALL + 1)]
write_csv("departments.csv", ["department_id", "department_name"], departments_rows)

# 3. locations.csv - NEW table in the updated ERD
locations_rows = [
    (i, f"{location_names[(i - 1) % len(location_names)]} {i}")
    for i in range(6, NUM_SMALL + 1)
]
write_csv("locations.csv", ["location_id", "location_name"], locations_rows)

# 4. users.csv
users_rows = []
for i in range(1, NUM_SMALL + 1):
    full_name = f"{random.choice(first_names)} {random.choice(last_names)}"
    users_rows.append((
        i,
        full_name,
        f"user{i}",
        f"user{i}@hotel.com",
        random.randint(1, NUM_SMALL),      # role_id FK
        random.randint(1, NUM_SMALL),      # department_id FK
        random.choice(user_statuses),
        random_date()
    ))
write_csv(
    "users.csv",
    ["user_id", "full_name", "username", "email", "role_id", "department_id", "status", "created_date"],
    users_rows
)

# 5. cctv_cameras.csv - location text replaced by location_id FK
cameras_rows = []
for i in range(1, NUM_SMALL + 1):
    installation = random_date(0, 500)
    maintenance = installation + timedelta(days=random.randint(30, 300))
    cameras_rows.append((
        i,
        installation,
        maintenance,
        random.choice(camera_statuses),
        random.randint(1, NUM_SMALL)       # location_id FK
    ))
write_csv(
    "cctv_cameras.csv",
    ["camera_id", "installation_date", "last_maintenance_date", "status", "location_id"],
    cameras_rows
)

# 6. incidents.csv - reported_by renamed to user_id
incidents_rows = []
for i in range(1, NUM_SMALL + 1):
    incidents_rows.append((
        i,
        f"Incident {i}",
        f"Security incident description number {i}",
        random.choice(severity_values),
        random_date(),
        random.choice(incident_statuses),
        random.randint(1, NUM_SMALL),      # user_id FK
        random.randint(1, NUM_SMALL)       # camera_id FK
    ))
write_csv(
    "incidents.csv",
    ["incident_id", "title", "description", "severity", "reported_date", "status", "user_id", "camera_id"],
    incidents_rows
)

# 7. it_assets.csv - location text replaced by location_id FK
assets_rows = []
for i in range(1, NUM_SMALL + 1):
    assets_rows.append((
        i,
        random.choice(asset_types),
        f"Asset {i}",
        random_date(),
        random.choice(asset_statuses),
        random.randint(1, NUM_SMALL)       # location_id FK
    ))
write_csv(
    "it_assets.csv",
    ["asset_id", "asset_type", "asset_name", "purchase_date", "status", "location_id"],
    assets_rows
)

# 8. system_backups.csv - performed_by renamed to user_id
backup_rows = []
for i in range(1, NUM_SMALL + 1):
    backup_rows.append((
        i,
        random.choice(backup_types),
        random_date(),
        random.choice(backup_statuses),
        random.randint(1, NUM_SMALL)       # user_id FK
    ))
write_csv(
    "system_backups.csv",
    ["backup_id", "backup_type", "backup_date", "status", "user_id"],
    backup_rows
)

# 9. incident_assignments.csv - assignment_id added as primary key
pairs = set()
assignment_rows = []
while len(assignment_rows) < NUM_SMALL:
    pair = (random.randint(1, NUM_SMALL), random.randint(1, NUM_SMALL))
    if pair in pairs:
        continue
    pairs.add(pair)
    assignment_rows.append((
        len(assignment_rows) + 1,          # assignment_id PK
        random_date(),
        random.choice(incident_roles),
        pair[0],                           # incident_id FK
        pair[1]                            # user_id FK
    ))
write_csv(
    "incident_assignments.csv",
    ["assignment_id", "assigned_date", "role_in_incident", "incident_id", "user_id"],
    assignment_rows
)

# 10. access_logs.csv - location text replaced by location_id FK
access_rows = []
for i in range(1, NUM_BIG + 1):
    access_rows.append((
        i,
        random.choice(access_types),
        random_date(),
        random.choice(access_statuses),
        random.randint(1, NUM_SMALL),      # user_id FK
        random.randint(1, NUM_SMALL)       # location_id FK
    ))
write_csv(
    "access_logs.csv",
    ["log_id", "access_type", "access_time", "status", "user_id", "location_id"],
    access_rows
)

# 11. asset_incident.csv - 20,000 unique records
asset_incident_pairs = set()
asset_incident_rows = []
while len(asset_incident_rows) < NUM_BIG:
    pair = (random.randint(1, NUM_SMALL), random.randint(1, NUM_SMALL))
    if pair in asset_incident_pairs:
        continue
    asset_incident_pairs.add(pair)
    asset_incident_rows.append((pair[0], pair[1], "Related asset to security incident"))
write_csv(
    "asset_incident.csv",
    ["incident_id", "asset_id", "relation_description"],
    asset_incident_rows
)

print("CSV files generated successfully according to the updated ERD.")
