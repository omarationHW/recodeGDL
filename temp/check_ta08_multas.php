<?php
$conn = pg_connect('host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2');

// Ver estructura de ta_08_multas
echo "Estructura de db_ingresos.ta_08_multas:\n";
$query = "SELECT column_name, data_type, character_maximum_length
          FROM information_schema.columns
          WHERE table_schema='db_ingresos' AND table_name='ta_08_multas'
          ORDER BY ordinal_position;";
$result = pg_query($conn, $query);
while($row = pg_fetch_assoc($result)) {
  echo $row['column_name'] . ' (' . $row['data_type'] . ')' . "\n";
}

// Ver datos de ejemplo
echo "\n\nDatos de ejemplo de db_ingresos.ta_08_multas:\n";
$query = "SELECT * FROM db_ingresos.ta_08_multas LIMIT 5;";
$result = pg_query($conn, $query);
if (pg_num_rows($result) > 0) {
  while($row = pg_fetch_assoc($result)) {
    print_r($row);
    echo "\n---\n";
  }
} else {
  echo "No hay datos en esta tabla\n";
}

// Verificar si hay campo folio o similar
echo "\n\nBuscando campos con 'folio' o 'cuenta' en ta_08_multas:\n";
$query = "SELECT column_name
          FROM information_schema.columns
          WHERE table_schema='db_ingresos' AND table_name='ta_08_multas'
          AND (column_name LIKE '%folio%' OR column_name LIKE '%cuenta%' OR column_name LIKE '%clave%')
          ORDER BY ordinal_position;";
$result = pg_query($conn, $query);
while($row = pg_fetch_assoc($result)) {
  echo $row['column_name'] . "\n";
}

pg_close($conn);
