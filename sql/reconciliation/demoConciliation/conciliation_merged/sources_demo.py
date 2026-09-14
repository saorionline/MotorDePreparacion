SOURCES = {
    "A": {
        "name": "transactions",
        "file_path": "data/raw/transactions_raw.json",
        "format": "json",
        "granularity": "transaction",
        "timezone": "UTC",
        "natural_key": "order_ref",
    },
    "B": {
        "name": "payments",
        "file_path": "data/raw/payments_raw.json",
        "format": "json",
        "granularity": "transaction",
        "timezone": "America/Bogota",
        "natural_key": "document_ref",
    },
}

def normalize_key(value: str) -> str:
    if value is None:
        raise ValueError("Natural key cannot be null")

    value = value.strip().upper()

    if not value:
        raise ValueError("Natural key cannot be empty")

    return value

def get_natural_key(source: str, record: dict) -> str:
    field = SOURCES[source]["natural_key"]
    return normalize_key(record.get(field))

for source, config in SOURCES.items():
    print(source, config["name"], config["natural_key"])