"""
parse_dbt.py

Parses marts-layer dbt models into text chunks ready for embedding.
Reads column names from SQL and descriptions/types from schema.yml.
"""

import re
import yaml
from dataclasses import dataclass, field
from pathlib import Path

_BQ_PROJECT = "gopro-data-project"


@dataclass
class DbtModelChunk:
    model_id: str
    bq_path: str
    description: str
    columns: list[dict] = field(default_factory=list)  # {name, type, description}

    def to_chunk_text(self) -> str:
        lines = [
            f"Model: {self.model_id}",
            f"BigQuery path: {self.bq_path}",
            f"Description: {self.description}",
            "Columns:",
        ]
        for col in self.columns:
            line = f"  - {col['name']} ({col['type']})"
            if col.get("description"):
                line += f": {col['description']}"
            lines.append(line)
        return "\n".join(lines)


def _extract_column_names(sql_text: str) -> list[str]:
    """
    Extracts output column names from the outermost SELECT of a marts SQL file.
    Takes the last SELECT...FROM match to skip CTE inner selects.
    """
    cleaned = re.sub(r"\{\{[^}]+\}\}", "PLACEHOLDER", sql_text)
    matches = re.findall(r"\bselect\b(.*?)\bfrom\b", cleaned, re.DOTALL | re.IGNORECASE)
    if not matches:
        return []

    names = []
    for expr in matches[-1].split(","):
        expr = expr.strip()
        alias = re.search(r"\bas\s+(\w+)\s*$", expr, re.IGNORECASE)
        if alias:
            names.append(alias.group(1))
        else:
            ident = re.search(r"(\w+)\s*$", expr)
            if ident:
                names.append(ident.group(1))
    return names


def _load_schema_yml(marts_dir: Path) -> dict:
    """Returns {model_name: {description, columns: {col_name: {type, description}}}}"""
    schema_path = marts_dir / "schema.yml"
    if not schema_path.exists():
        return {}

    raw = yaml.safe_load(schema_path.read_text())
    result = {}
    for model in raw.get("models", []):
        result[model["name"]] = {
            "description": model.get("description", "").strip(),
            "columns": {
                col["name"]: {
                    "type": col.get("data_type", "UNKNOWN").upper(),
                    "description": col.get("description", "").strip(),
                }
                for col in model.get("columns", [])
            },
        }
    return result


def parse_dbt_models(dbt_models_dir: str | Path) -> list[DbtModelChunk]:
    """
    Returns one DbtModelChunk per mart model, ready for embedding.

    Args:
        dbt_models_dir: path to dbt/models/
    """
    marts_dir = Path(dbt_models_dir) / "marts"
    schema_meta = _load_schema_yml(marts_dir)
    chunks = []

    for sql_path in sorted(marts_dir.glob("*.sql")):
        model_id = sql_path.stem
        meta = schema_meta.get(model_id, {})
        col_meta = meta.get("columns", {})
        col_names = _extract_column_names(sql_path.read_text())

        chunks.append(DbtModelChunk(
            model_id=model_id,
            bq_path=f"`{_BQ_PROJECT}.marts.{model_id}`",
            description=meta.get("description", model_id),
            columns=[
                {
                    "name": name,
                    "type": col_meta.get(name, {}).get("type", "UNKNOWN"),
                    "description": col_meta.get(name, {}).get("description", ""),
                }
                for name in col_names
            ],
        ))

    return chunks
