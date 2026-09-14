from datetime import datetime, timezone

CONTRACT_VERSION = "1.0.0"
UPDATED_AT = datetime.now(timezone.utc)

# Política: no procesar datos con un contrato desconocido.
OLD_CONTRACT_POLICY = "reject"

def validate_contract(data: dict) -> None:
    version = data.get("contract_version")

    if version is None:
        raise ValueError("Missing contract_version")

    if version != CONTRACT_VERSION:
        raise ValueError(
            f"Unsupported version: {version}. "
            f"Expected: {CONTRACT_VERSION}"
        )

def contract_metadata() -> dict:
    return {
        "contract_version": CONTRACT_VERSION,
        "updated_at": UPDATED_AT.isoformat(),
        "old_contract_policy": OLD_CONTRACT_POLICY,
    }

if __name__ == "__main__":
    print(contract_metadata())