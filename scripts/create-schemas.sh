#!/bin/bash
set -e

echo "Registrando esquemas Avro encontrados en /avro ..."

for file in /avro/*.avsc; do
  if [ -f "$file" ]; then
    base=$(basename "$file" .avsc)
    subject="${base//_/-}"  # reemplaza _ por - en el nombre del subject
    echo "→ Registrando $file como subject '$subject' ..."
    curl -s -X POST http://schema-registry:8081/subjects/$subject/versions \
      -H "Content-Type: application/vnd.schemaregistry.v1+json" \
      -d @<(jq -n --argjson schema "$(cat "$file")" '{schema: ($schema|tojson)}') \
      || echo "Error registrando $file"
  fi
done

echo "Esquemas registrados."
