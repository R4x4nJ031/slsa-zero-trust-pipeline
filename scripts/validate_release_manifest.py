#!/usr/bin/env python3
"""Validate the release manifest contract using only the Python standard library."""

import json
import re
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"release manifest invalid: {message}", file=sys.stderr)
    raise SystemExit(1)


def check_type(value, expected: str) -> bool:
    return {
        "object": lambda: isinstance(value, dict),
        "string": lambda: isinstance(value, str),
        "integer": lambda: isinstance(value, int) and not isinstance(value, bool),
        "boolean": lambda: isinstance(value, bool),
        "array": lambda: isinstance(value, list),
        "number": lambda: isinstance(value, (int, float)) and not isinstance(value, bool),
        "null": lambda: value is None,
    }[expected]()


def validate(value, schema: dict, path: str = "$", root_schema: dict | None = None) -> None:
    if root_schema is None:
        root_schema = schema
    if "$ref" in schema:
        ref = schema["$ref"]
        if not ref.startswith("#/"):
            fail(f"{path}: external schema references are not supported")
        target = root_schema
        for part in ref[2:].split("/"):
            target = target[part.replace("~1", "/").replace("~0", "~")]
        validate(value, target, path, root_schema)
        return
    if "type" in schema and not check_type(value, schema["type"]):
        fail(f"{path}: expected {schema['type']}")
    if "const" in schema and value != schema["const"]:
        fail(f"{path}: value must be {schema['const']!r}")
    if "enum" in schema and value not in schema["enum"]:
        fail(f"{path}: value is not one of the allowed values")
    if isinstance(value, str):
        if len(value) < schema.get("minLength", 0):
            fail(f"{path}: string is too short")
        if "pattern" in schema and re.fullmatch(schema["pattern"], value) is None:
            fail(f"{path}: string does not match the required pattern")
    if isinstance(value, dict):
        missing = set(schema.get("required", [])) - value.keys()
        if missing:
            fail(f"{path}: missing fields: {', '.join(sorted(missing))}")
        properties = schema.get("properties", {})
        if schema.get("additionalProperties") is False:
            extra = value.keys() - properties.keys()
            if extra:
                fail(f"{path}: unexpected fields: {', '.join(sorted(extra))}")
        for key, child in properties.items():
            if key in value:
                validate(value[key], child, f"{path}.{key}", root_schema)


def main() -> None:
    if len(sys.argv) != 3:
        print(f"usage: {Path(sys.argv[0]).name} <schema.json> <manifest.json>", file=sys.stderr)
        raise SystemExit(2)
    schema_path, manifest_path = map(Path, sys.argv[1:])
    try:
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(str(exc))
    validate(manifest, schema)
    print(f"{manifest_path} is valid")


if __name__ == "__main__":
    main()
