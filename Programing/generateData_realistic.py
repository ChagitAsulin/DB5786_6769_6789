import csv
import random
from datetime import date, timedelta
from pathlib import Path

# Realistic CSV generator for Hotel Security Management System
# Compatible with the updated ERD and Docker COPY files:
# roles.csv, departments.csv, locations.csv, users.csv, cctv_cameras.csv,
# it_assets.csv, incidents.csv, system_backups.csv, incident_assignments.csv,
# access_logs.csv, asset_incident.csv

NUM_SMALL = 500
NUM_BIG = 20000

random.seed(5786)
base_date = date(2024, 1, 1)
OUTPUT_DIR = Path(__file__).resolve().parent

user_statuses = ["Active", "Inactive", "Disabled"]
access_types = ["System Login", "Room Access", "Server Room Access"]
access_statuses_weighted = ["Success"] * 82 + ["Denied"] * 12 + ["Failed"] * 6
camera_statuses_weighted = ["Active"] * 78 + ["Maintenance"] * 10 + ["Offline"] * 7 + ["Inactive"] * 5
severity_weighted = ["Low"] * 45 + ["Medium"] * 32 + ["High"] * 17 + ["Critical"] * 6
incident_status_weighted = ["Resolved"] * 62 + ["In Progress"] * 24 + ["Open"] * 14
asset_status_weighted = ["Operational"] * 76 + ["Maintenance"] * 12 + ["Offline"] * 8 + ["Retired"] * 4
backup_types_weighted = ["Incremental"] * 48 + ["Full"] * 24 + ["Differential"] * 18 + ["Cloud"] * 10
backup_status_weighted = ["Success"] * 86 + ["In Progress"] * 8 + ["Failed"] * 6

# IDs 1-5 are inserted manually in 02-seed-data.sql.
manual_roles = {
    1: "Admin",
    2: "Security Manager",
    3: "Security Guard",
    4: "IT Manager",
    5: "IT Technician",
}
manual_departments = {
    1: "Security",
    2: "IT",
    3: "Reception",
    4: "Management",
    5: "Maintenance",
}
manual_locations = {
    1: "Lobby",
    2: "Reception",
    3: "Server Room",
    4: "Parking",
    5: "Main Gate",
}

role_base_names = [
    "Night Shift Security Guard", "Day Shift Security Guard", "Lobby Security Officer",
    "Parking Patrol Officer", "CCTV Monitoring Operator", "Access Control Officer",
    "Incident Response Officer", "Guest Safety Coordinator", "VIP Floor Security Officer",
    "Emergency Evacuation Officer", "Server Room Access Supervisor", "Fire Safety Assistant",
    "Back Gate Security Guard", "Pool Area Safety Guard", "Event Security Coordinator",
    "Loading Dock Security Officer", "Lost And Found Security Clerk", "Security Dispatcher",
    "Security Training Assistant", "Security Audit Assistant", "IT Support Technician",
    "Network Security Technician", "Maintenance Safety Coordinator"
]

department_base_names = [
    "Security Operations", "CCTV Monitoring Center", "Access Control Desk",
    "Guest Safety Services", "Emergency Response Team", "Parking Security",
    "VIP Security Services", "Event Security", "Loss Prevention", "Fire Safety",
    "IT Infrastructure", "Network Operations", "Hotel Maintenance",
    "Front Desk Operations", "Housekeeping Coordination", "Food And Beverage Operations",
    "Spa And Pool Operations", "Conference And Events", "Executive Management",
    "Vendor And Delivery Control"
]

hotel_areas = [
    "Lobby", "Reception", "Main Gate", "Back Gate", "Parking Level A", "Parking Level B",
    "Underground Parking", "Server Room", "Security Control Room", "CCTV Room",
    "Kitchen Entrance", "Main Kitchen", "Loading Dock", "Laundry Room", "Storage Room",
    "Maintenance Workshop", "Conference Hall", "Ballroom Entrance", "Business Lounge",
    "VIP Lounge", "Pool Deck", "Gym Entrance", "Spa Reception", "Restaurant Entrance",
    "Bar Entrance", "Emergency Exit North", "Emergency Exit South", "Staff Entrance",
    "Elevator Lobby", "Service Elevator", "Guest Corridor", "Rooftop Access",
    "Kids Club", "Garden Entrance", "Beach Gate"
]

first_names = [
    "Hagit", "Noa", "Dana", "Ron", "Amit", "Maya", "David", "Yael", "Lior", "Shira",
    "Daniel", "Tamar", "Yossi", "Rina", "Eli", "Michal", "Avi", "Sara", "Omer", "Gal",
    "Eden", "Niv", "Maayan", "Itay", "Adi", "Or", "Bar", "Neta", "Yarden", "Sivan",
    "Roni", "Alon", "Tal", "Mor", "Shani", "Yuval", "Ariel", "Naama", "Dvir", "Karin"
]
last_names = [
    "Cohen", "Levi", "Mizrahi", "Peretz", "Biton", "Avraham", "Friedman", "Azulai",
    "Katz", "Dahan", "Malka", "Shalom", "Ben David", "Harel", "Bar", "Tal",
    "Assulin", "Mor", "Dayan", "Sela", "Ohana", "Golan", "Shapira", "Vaknin",
    "Amar", "Turgeman", "Barkan", "Elbaz", "Hazan", "Atias"
]

incident_templates = {
    "Low": [
        ("Lost guest keycard", "Guest reported a missing keycard. Access permissions were reviewed and the card was blocked."),
        ("Unattended luggage", "Unattended luggage was reported by hotel staff and inspected by security."),
        ("Minor door alarm", "A guest corridor door alarm was triggered and checked by the security team."),
        ("Guest assistance request", "Security assisted a guest with access verification and escort to the correct area.")
    ],
    "Medium": [
        ("Unauthorized staff-only access attempt", "A person attempted to enter a staff-only area without proper authorization."),
        ("Suspicious activity near restricted area", "CCTV operator noticed suspicious movement near a restricted hotel area."),
        ("Parking gate dispute", "Security handled a dispute at the parking gate and documented the access event."),
        ("Vendor access issue", "A vendor arrived outside approved access hours and required security validation.")
    ],
    "High": [
        ("Server room access violation", "Unauthorized access attempt was detected near the server room and escalated to management."),
        ("Guest room corridor disturbance", "Repeated disturbance was reported in a guest corridor and security responded."),
        ("Emergency exit forced open", "An emergency exit door was opened without authorization and the area was inspected."),
        ("Theft report under investigation", "A theft report was opened and CCTV footage was reviewed by the security team.")
    ],
    "Critical": [
        ("Fire alarm security response", "Security responded to a fire alarm and coordinated with maintenance and management."),
        ("Critical server room breach attempt", "A critical access attempt to the server room was denied and escalated immediately."),
        ("Medical emergency support", "Security supported emergency response procedures for a medical incident on hotel premises."),
        ("Major evacuation procedure", "Security initiated support procedures for a major evacuation drill or emergency event.")
    ]
}

asset_catalog = [
    ("Laptop", "Security supervisor laptop"),
    ("Server", "Access control database server"),
    ("Router", "Security network router"),
    ("Switch", "CCTV network switch"),
    ("Camera System", "CCTV recording unit"),
    ("Firewall", "Hotel security firewall"),
    ("Printer", "Security office report printer"),
    ("Badge Reader", "Staff badge reader"),
    ("Door Controller", "Electronic door controller"),
    ("NVR", "Network video recorder"),
    ("Radio Device", "Security patrol radio"),
    ("Alarm Panel", "Emergency alarm panel")
]

incident_roles = [
    "Incident Owner", "Investigator", "CCTV Reviewer", "Field Security Officer",
    "Technical Support", "Reporter", "Shift Supervisor", "Access Control Reviewer"
]

def random_date(start_offset=0, max_days=850):
    return base_date + timedelta(days=random.randint(start_offset, max_days))

def write_csv(filename, header, rows):
    with open(OUTPUT_DIR / filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

def unique_names(base_list, count, prefix_suffix=""):
    names = []
    index = 0
    while len(names) < count:
        base = base_list[index % len(base_list)]
        cycle = index // len(base_list) + 1
        if cycle == 1:
            name = f"{base}{prefix_suffix}"
        else:
            name = f"{base} - Unit {cycle:02d}{prefix_suffix}"
        names.append(name)
        index += 1
    return names

# roles.csv: 495 generated records, plus 5 manual records = 500 total.
role_names = unique_names(role_base_names, NUM_SMALL - 5)
roles_rows = [(i, role_names[i - 6]) for i in range(6, NUM_SMALL + 1)]
write_csv("roles.csv", ["role_id", "role_name"], roles_rows)

# departments.csv: 495 generated records, plus 5 manual records = 500 total.
department_names = unique_names(department_base_names, NUM_SMALL - 5)
departments_rows = [(i, department_names[i - 6]) for i in range(6, NUM_SMALL + 1)]
write_csv("departments.csv", ["department_id", "department_name"], departments_rows)

# locations.csv: 495 generated records, plus 5 manual records = 500 total.
locations_rows = []
for i in range(6, NUM_SMALL + 1):
    area = hotel_areas[(i - 6) % len(hotel_areas)]
    floor = ((i - 6) // len(hotel_areas)) + 1
    # Make every location unique but still realistic.
    if "Parking" in area:
        name = f"{area} - Zone {floor}"
    elif "Guest Corridor" in area or "Elevator" in area or "Service Elevator" in area:
        name = f"{area} - Floor {floor}"
    else:
        name = f"{area} - Section {floor}"
    locations_rows.append((i, name))
write_csv("locations.csv", ["location_id", "location_name"], locations_rows)

all_location_ids = list(range(1, NUM_SMALL + 1))

# users.csv
users_rows = []
used_usernames = set()
for i in range(1, NUM_SMALL + 1):
    first = random.choice(first_names)
    last = random.choice(last_names)
    full_name = f"{first} {last}"

    username_base = f"{first.lower()}.{last.lower().replace(' ', '').replace('-', '')}"
    username = f"{username_base}{i}"
    while username in used_usernames:
        username = f"{username_base}{random.randint(100, 9999)}"
    used_usernames.add(username)

    # Bias most users toward security, IT, maintenance, and reception roles/departments.
    role_id = random.choice(
        [2, 3, 4, 5] * 8 +
        list(range(6, 80)) * 3 +
        list(range(80, NUM_SMALL + 1))
    )
    department_id = random.choice(
        [1, 2, 3, 5] * 10 +
        list(range(6, 90)) * 3 +
        list(range(90, NUM_SMALL + 1))
    )

    status = random.choice(["Active"] * 82 + ["Inactive"] * 13 + ["Disabled"] * 5)
    users_rows.append((
        i,
        full_name,
        username,
        f"{username}@grand-hotel-security.com",
        role_id,
        department_id,
        status,
        random_date(0, 760)
    ))

write_csv(
    "users.csv",
    ["user_id", "full_name", "username", "email", "role_id", "department_id", "status", "created_date"],
    users_rows
)

# cctv_cameras.csv
camera_locations = {}
cameras_rows = []
for i in range(1, NUM_SMALL + 1):
    location_id = random.choice(all_location_ids)
    camera_locations[i] = location_id
    installation = random_date(0, 620)
    maintenance = installation + timedelta(days=random.randint(30, 360))
    if maintenance > base_date + timedelta(days=900):
        maintenance = base_date + timedelta(days=random.randint(650, 900))

    cameras_rows.append((
        i,
        installation,
        maintenance,
        random.choice(camera_statuses_weighted),
        location_id
    ))

write_csv(
    "cctv_cameras.csv",
    ["camera_id", "installation_date", "last_maintenance_date", "status", "location_id"],
    cameras_rows
)

# it_assets.csv
asset_locations = {}
assets_rows = []
for i in range(1, NUM_SMALL + 1):
    asset_type, asset_base_name = random.choice(asset_catalog)
    location_id = random.choice(all_location_ids)
    asset_locations[i] = location_id
    purchase = random_date(0, 780)
    status = random.choice(asset_status_weighted)
    assets_rows.append((
        i,
        asset_type,
        f"{asset_base_name} #{i:04d}",
        purchase,
        status,
        location_id
    ))

write_csv(
    "it_assets.csv",
    ["asset_id", "asset_type", "asset_name", "purchase_date", "status", "location_id"],
    assets_rows
)

# incidents.csv
incidents_rows = []
incident_severity_by_id = {}
for i in range(1, NUM_SMALL + 1):
    severity = random.choice(severity_weighted)
    incident_severity_by_id[i] = severity
    _title, description = random.choice(incident_templates[severity])

    camera_id = random.randint(1, NUM_SMALL)
    location_id = camera_locations[camera_id]
    enriched_description = (
        f"{description} Related camera ID: {camera_id}, location ID: {location_id}. "
        f"Initial response was documented by hotel security. Severity level used for generation: {severity}."
    )

    incidents_rows.append((
        i,
        enriched_description,
        random_date(120, 880),
        random.randint(1, NUM_SMALL),  # reported_by_user_id
        camera_id
    ))

write_csv(
    "incidents.csv",
    ["incident_id", "description", "reported_date", "reported_by_user_id", "camera_id"],
    incidents_rows
)

# system_backups.csv
backup_rows = []
for i in range(1, NUM_SMALL + 1):
    backup_type = random.choice(backup_types_weighted)
    backup_date = random_date(250, 900)
    # Bias backups toward IT managers/technicians, but any system user can appear.
    user_id = random.choice([4, 5] * 12 + list(range(1, NUM_SMALL + 1)))
    backup_rows.append((i, backup_date, backup_type, user_id))

write_csv(
    "system_backups.csv",
    ["backup_id", "backup_date", "backup_type", "user_id"],
    backup_rows
)

# incident_assignments.csv
pairs = set()
assignment_rows = []
while len(assignment_rows) < NUM_SMALL:
    incident_id = random.randint(1, NUM_SMALL)
    user_id = random.randint(1, NUM_SMALL)
    pair = (incident_id, user_id)
    if pair in pairs:
        continue
    pairs.add(pair)

    severity = incident_severity_by_id[incident_id]
    if severity in ("Critical", "High"):
        role_in_incident = random.choice(
            ["Incident Owner", "Investigator", "Shift Supervisor", "CCTV Reviewer", "Technical Support"]
        )
    else:
        role_in_incident = random.choice(incident_roles)

    assignment_rows.append((
        incident_id,
        user_id,
        random_date(120, 900),
        role_in_incident
    ))

write_csv(
    "incident_assignments.csv",
    ["incident_id", "user_id", "assigned_date", "role_in_incident"],
    assignment_rows
)

# access_logs.csv
access_rows = []
for i in range(1, NUM_BIG + 1):
    camera_id = random.randint(1, NUM_SMALL)
    status = random.choice(access_statuses_weighted)
    access_rows.append((
        i,
        random_date(200, 900),
        status,
        random.randint(1, NUM_SMALL),
        camera_id
    ))

write_csv(
    "access_logs.csv",
    ["log_id", "access_time", "status", "user_id", "camera_id"],
    access_rows
)

# asset_incident.csv
relation_by_type = {
    "Camera System": "CCTV footage reviewed for this incident",
    "NVR": "Video recording checked during investigation",
    "Badge Reader": "Badge reader logs used for access verification",
    "Door Controller": "Door controller event related to the incident",
    "Alarm Panel": "Alarm panel alert connected to the response",
    "Server": "Server logs reviewed for investigation",
    "Firewall": "Network security logs reviewed",
    "Laptop": "Security workstation used for incident documentation",
    "Router": "Network device checked during response",
    "Switch": "CCTV network switch checked during response",
    "Printer": "Incident report printed from this device",
    "Radio Device": "Patrol radio used during response coordination"
}

asset_type_by_id = {row[0]: row[1] for row in assets_rows}
asset_incident_pairs = set()
asset_incident_rows = []
while len(asset_incident_rows) < NUM_BIG:
    incident_id = random.randint(1, NUM_SMALL)
    asset_id = random.randint(1, NUM_SMALL)
    pair = (incident_id, asset_id)
    if pair in asset_incident_pairs:
        continue
    asset_incident_pairs.add(pair)

    asset_type = asset_type_by_id.get(asset_id, "Asset")
    description = relation_by_type.get(asset_type, "Asset related to security incident")
    asset_incident_rows.append((incident_id, asset_id, description))

write_csv(
    "asset_incident.csv",
    ["incident_id", "asset_id", "relation_description"],
    asset_incident_rows
)

print("Realistic hotel security CSV files generated successfully.")
print(f"Output directory: {OUTPUT_DIR}")
print("Remember to copy the generated CSV files into init-db and recreate Docker volume.")
