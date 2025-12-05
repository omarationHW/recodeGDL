<?php
$conn = pg_connect('host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2');

// Ver datos de ejemplo
echo "Datos de ejemplo de catastro_gdl.multas:\n";
$query = "SELECT id_multa, axo_acta, num_acta, num_licencia, contribuyente, multa, total
          FROM catastro_gdl.multas
          WHERE axo_acta >= 2020
          LIMIT 5;";
$result = pg_query($conn, $query);
while($row = pg_fetch_assoc($result)) {
  echo 'ID: ' . $row['id_multa'] .
       ' | Año: ' . $row['axo_acta'] .
       ' | Acta: ' . $row['num_acta'] .
       ' | Licencia: ' . $row['num_licencia'] .
       ' | Contribuyente: ' . substr($row['contribuyente'], 0, 20) .
       ' | Total: ' . $row['total'] . "\n";
}

// Buscar en db_ingresos
echo "\n\nTablas en schema db_ingresos relacionadas con multas:\n";
$query = "SELECT table_name
          FROM information_schema.tables
          WHERE table_schema='db_ingresos'
          AND table_name LIKE '%multa%'
          AND table_type='BASE TABLE'
          ORDER BY table_name
          LIMIT 10;";
$result = pg_query($conn, $query);
while($row = pg_fetch_assoc($result)) {
  echo 'db_ingresos.' . $row['table_name'] . "\n";
}

// Buscar SPs en db_ingresos
echo "\n\nSPs en schema db_ingresos:\n";
$query = "SELECT routine_name
          FROM information_schema.routines
          WHERE routine_schema='db_ingresos'
          AND routine_type='FUNCTION'
          ORDER BY routine_name
          LIMIT 10;";
$result = pg_query($conn, $query);
while($row = pg_fetch_assoc($result)) {
  echo 'db_ingresos.' . $row['routine_name'] . "\n";
}

pg_close($conn);
