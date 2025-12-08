<?php
$conn = pg_connect("host=192.168.6.146 dbname=padron_licencias user=refact password=FF)-BQk2");
$r = pg_query($conn, "SELECT DISTINCT column_name FROM information_schema.columns WHERE table_name = 'ta_16_contratos' ORDER BY column_name");
while ($row = pg_fetch_row($r)) {
    echo $row[0] . "\n";
}
