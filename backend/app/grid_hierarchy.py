from __future__ import annotations

# Topology metadata only; this list intentionally contains no measurements, capacities,
# district names, substations, or feeder data. Those must come from the user's source feed.
NATIONAL_NODE = {
    "node_id": "BD-NATIONAL",
    "name": "Bangladesh National Grid",
    "tier": "national",
    "parent_node_id": None,
    "division_code": None,
    "distribution_weight": None,
}

DIVISION_NODES = [
    {"node_id": "BD-DHAKA", "name": "Dhaka", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "DHA", "distribution_weight": None},
    {"node_id": "BD-CHATTOGRAM", "name": "Chattogram", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "CTG", "distribution_weight": None},
    {"node_id": "BD-RAJSHAHI", "name": "Rajshahi", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "RAJ", "distribution_weight": None},
    {"node_id": "BD-KHULNA", "name": "Khulna", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "KHU", "distribution_weight": None},
    {"node_id": "BD-BARISHAL", "name": "Barishal", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "BAR", "distribution_weight": None},
    {"node_id": "BD-SYLHET", "name": "Sylhet", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "SYL", "distribution_weight": None},
    {"node_id": "BD-RANGPUR", "name": "Rangpur", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "RAN", "distribution_weight": None},
    {"node_id": "BD-MYMENSINGH", "name": "Mymensingh", "tier": "division", "parent_node_id": "BD-NATIONAL", "division_code": "MYM", "distribution_weight": None},
]

GRID_TIERS = {"national", "division", "district", "feeder"}
TIER_DEPTH = {"national": 0, "division": 1, "district": 2, "feeder": 3}
