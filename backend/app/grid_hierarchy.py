from __future__ import annotations

# Topology metadata for the Hierarchical 3-Tier Bangladesh Digital Twin Grid Model:
# Tier 0: National Root (PGCB Bangladesh National Grid)
# Tier 1: 8 Regional Hubs (Administrative Divisions) with validated baseline weights (sum = 1.0)
# Tier 2: District Substations (Major 230/132kV transmission & distribution hubs)
# Tier 3: Local Feeder Clusters (Microgrids, industrial feeds, and residential zones)

NATIONAL_NODE = {
    "node_id": "BD-NATIONAL",
    "name": "Bangladesh National Grid",
    "tier": "national",
    "parent_node_id": None,
    "division_code": None,
    "distribution_weight": None,
}

# 8 Administrative Divisions of Bangladesh with realistic baseline distribution weights (sum to 100%)
# Based on historical PGCB regional demand distribution patterns:
# Dhaka takes the largest share (~42%), followed by Chattogram industrial belt (~20%), etc.
DEFAULT_DIVISION_WEIGHTS = {
    "BD-DHAKA": 0.42,
    "BD-CHATTOGRAM": 0.20,
    "BD-KHULNA": 0.10,
    "BD-RAJSHAHI": 0.09,
    "BD-RANGPUR": 0.06,
    "BD-SYLHET": 0.05,
    "BD-MYMENSINGH": 0.05,
    "BD-BARISHAL": 0.03,
}

DIVISION_NODES = [
    {"node_id": "BD-DHAKA", "name": "Dhaka Regional Hub", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "DHA", "distribution_weight": DEFAULT_DIVISION_WEIGHTS["BD-DHAKA"]},
    {"node_id": "BD-CHATTOGRAM", "name": "Chattogram Regional Hub", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "CTG", "distribution_weight": DEFAULT_DIVISION_WEIGHTS["BD-CHATTOGRAM"]},
    {"node_id": "BD-RAJSHAHI", "name": "Rajshahi Regional Hub", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "RAJ", "distribution_weight": DEFAULT_DIVISION_WEIGHTS["BD-RAJSHAHI"]},
    {"node_id": "BD-KHULNA", "name": "Khulna Regional Hub", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "KHU", "distribution_weight": DEFAULT_DIVISION_WEIGHTS["BD-KHULNA"]},
    {"node_id": "BD-BARISHAL", "name": "Barishal Regional Hub", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "BAR", "distribution_weight": DEFAULT_DIVISION_WEIGHTS["BD-BARISHAL"]},
    {"node_id": "BD-SYLHET", "name": "Sylhet Regional Hub", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "SYL", "distribution_weight": DEFAULT_DIVISION_WEIGHTS["BD-SYLHET"]},
    {"node_id": "BD-RANGPUR", "name": "Rangpur Regional Hub", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "RAN", "distribution_weight": DEFAULT_DIVISION_WEIGHTS["BD-RANGPUR"]},
    {"node_id": "BD-MYMENSINGH", "name": "Mymensingh Regional Hub", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "MYM", "distribution_weight": DEFAULT_DIVISION_WEIGHTS["BD-MYMENSINGH"]},
]

# Tier 2: District Substations under each Division
DISTRICT_NODES = [
    # Dhaka Division
    {"node_id": "DIST-DHAKA-NORTH", "name": "Dhaka North 230/132kV Substation", "tier": "district", "parent_node_id": "BD-DHAKA", "division_code": "DHA", "distribution_weight": 0.35},
    {"node_id": "DIST-DHAKA-SOUTH", "name": "Dhaka South 230/132kV Substation", "tier": "district", "parent_node_id": "BD-DHAKA", "division_code": "DHA", "distribution_weight": 0.30},
    {"node_id": "DIST-GAZIPUR", "name": "Gazipur Industrial 132kV Substation", "tier": "district", "parent_node_id": "BD-DHAKA", "division_code": "DHA", "distribution_weight": 0.20},
    {"node_id": "DIST-NARAYANGANJ", "name": "Narayanganj Grid Substation", "tier": "district", "parent_node_id": "BD-DHAKA", "division_code": "DHA", "distribution_weight": 0.15},

    # Chattogram Division
    {"node_id": "DIST-CTG-PORT", "name": "Chattogram Port 230/132kV Substation", "tier": "district", "parent_node_id": "BD-CHATTOGRAM", "division_code": "CTG", "distribution_weight": 0.45},
    {"node_id": "DIST-COMILLA", "name": "Comilla North Grid Substation", "tier": "district", "parent_node_id": "BD-CHATTOGRAM", "division_code": "CTG", "distribution_weight": 0.35},
    {"node_id": "DIST-COX-BAZAR", "name": "Cox's Bazar 132kV Substation", "tier": "district", "parent_node_id": "BD-CHATTOGRAM", "division_code": "CTG", "distribution_weight": 0.20},

    # Khulna Division
    {"node_id": "DIST-KHULNA-CENTRAL", "name": "Khulna Central 132kV Substation", "tier": "district", "parent_node_id": "BD-KHULNA", "division_code": "KHU", "distribution_weight": 0.55},
    {"node_id": "DIST-JASHORE", "name": "Jashore Grid Substation", "tier": "district", "parent_node_id": "BD-KHULNA", "division_code": "KHU", "distribution_weight": 0.45},

    # Rajshahi Division
    {"node_id": "DIST-RAJSHAHI-CITY", "name": "Rajshahi City 132kV Substation", "tier": "district", "parent_node_id": "BD-RAJSHAHI", "division_code": "RAJ", "distribution_weight": 0.55},
    {"node_id": "DIST-BOGURA", "name": "Bogura 230/132kV Substation", "tier": "district", "parent_node_id": "BD-RAJSHAHI", "division_code": "RAJ", "distribution_weight": 0.45},

    # Rangpur Division
    {"node_id": "DIST-RANGPUR-CENTRAL", "name": "Rangpur Central 132kV Substation", "tier": "district", "parent_node_id": "BD-RANGPUR", "division_code": "RAN", "distribution_weight": 0.55},
    {"node_id": "DIST-DINAJPUR", "name": "Dinajpur Grid Substation", "tier": "district", "parent_node_id": "BD-RANGPUR", "division_code": "RAN", "distribution_weight": 0.45},

    # Sylhet Division
    {"node_id": "DIST-SYLHET-EAST", "name": "Sylhet East 132kV Substation", "tier": "district", "parent_node_id": "BD-SYLHET", "division_code": "SYL", "distribution_weight": 0.60},
    {"node_id": "DIST-SHAHJIBAZAR", "name": "Shahjibazar Grid Substation", "tier": "district", "parent_node_id": "BD-SYLHET", "division_code": "SYL", "distribution_weight": 0.40},

    # Mymensingh Division
    {"node_id": "DIST-MYMENSINGH-CITY", "name": "Mymensingh City 132kV Substation", "tier": "district", "parent_node_id": "BD-MYMENSINGH", "division_code": "MYM", "distribution_weight": 0.60},
    {"node_id": "DIST-JAMALPUR", "name": "Jamalpur Grid Substation", "tier": "district", "parent_node_id": "BD-MYMENSINGH", "division_code": "MYM", "distribution_weight": 0.40},

    # Barishal Division
    {"node_id": "DIST-BARISHAL-NORTH", "name": "Barishal North 132kV Substation", "tier": "district", "parent_node_id": "BD-BARISHAL", "division_code": "BAR", "distribution_weight": 0.60},
    {"node_id": "DIST-PATUAKHALI", "name": "Patuakhali Grid Substation", "tier": "district", "parent_node_id": "BD-BARISHAL", "division_code": "BAR", "distribution_weight": 0.40},
]

# Tier 3: Local Feeder Clusters (Microgrids, industrial feeds, and endpoints)
FEEDER_NODES = [
    # Feeders under Dhaka North
    {"node_id": "FDR-GULSHAN", "name": "Gulshan-Banani Commercial Feeder 33/11kV", "tier": "feeder", "parent_node_id": "DIST-DHAKA-NORTH", "division_code": "DHA", "distribution_weight": 0.40},
    {"node_id": "FDR-UTTARA-RES", "name": "Uttara Residential Feeder 11kV", "tier": "feeder", "parent_node_id": "DIST-DHAKA-NORTH", "division_code": "DHA", "distribution_weight": 0.35},
    {"node_id": "FDR-MIRPUR-MICRO", "name": "Mirpur Solar Microgrid Interface", "tier": "feeder", "parent_node_id": "DIST-DHAKA-NORTH", "division_code": "DHA", "distribution_weight": 0.25},

    # Feeders under Gazipur
    {"node_id": "FDR-TONGI-IND", "name": "Tongi Garments Industrial Feeder", "tier": "feeder", "parent_node_id": "DIST-GAZIPUR", "division_code": "DHA", "distribution_weight": 0.55},
    {"node_id": "FDR-GAZIPUR-EXPORT", "name": "Gazipur EPZ Heavy Line", "tier": "feeder", "parent_node_id": "DIST-GAZIPUR", "division_code": "DHA", "distribution_weight": 0.45},

    # Feeders under Chattogram Port
    {"node_id": "FDR-PORT-TERMINAL", "name": "Port Container Terminal Feeder", "tier": "feeder", "parent_node_id": "DIST-CTG-PORT", "division_code": "CTG", "distribution_weight": 0.50},
    {"node_id": "FDR-AGRABAD-CBD", "name": "Agrabad Commercial Feeder", "tier": "feeder", "parent_node_id": "DIST-CTG-PORT", "division_code": "CTG", "distribution_weight": 0.50},

    # Feeders under Cox's Bazar
    {"node_id": "FDR-COX-WIND", "name": "Cox's Bazar Coastal Wind Microgrid", "tier": "feeder", "parent_node_id": "DIST-COX-BAZAR", "division_code": "CTG", "distribution_weight": 0.50},
    {"node_id": "FDR-TEKNAF-SOLAR", "name": "Teknaf Solar Plant Feeder 33kV", "tier": "feeder", "parent_node_id": "DIST-COX-BAZAR", "division_code": "CTG", "distribution_weight": 0.50},

    # Feeders under Khulna
    {"node_id": "FDR-MONGLA-IND", "name": "Mongla SEZ Industrial Feeder", "tier": "feeder", "parent_node_id": "DIST-KHULNA-CENTRAL", "division_code": "KHU", "distribution_weight": 0.60},
    {"node_id": "FDR-KHULNA-RES", "name": "Khulna City Feeder", "tier": "feeder", "parent_node_id": "DIST-KHULNA-CENTRAL", "division_code": "KHU", "distribution_weight": 0.40},

    # Feeders under Sylhet East
    {"node_id": "FDR-SYLHET-TEA", "name": "Sylhet Tea Estate Microgrid", "tier": "feeder", "parent_node_id": "DIST-SYLHET-EAST", "division_code": "SYL", "distribution_weight": 0.50},
    {"node_id": "FDR-SYLHET-TECH", "name": "Sylhet Tech Park Feeder", "tier": "feeder", "parent_node_id": "DIST-SYLHET-EAST", "division_code": "SYL", "distribution_weight": 0.50},
]

ALL_GRID_NODES = [NATIONAL_NODE, *DIVISION_NODES, *DISTRICT_NODES, *FEEDER_NODES]

GRID_TIERS = {"national", "division", "district", "feeder"}
TIER_DEPTH = {"national": 0, "division": 1, "district": 2, "feeder": 3}
