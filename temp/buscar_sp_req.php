<?php
$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");
$result = pg_query($conn, "SELECT routine_schema, routine_name FROM information_schema.routines WHERE routine_name ILIKE '%recaudadora_req%' AND routine_type='FUNCTION'");
echo "=== SPs que contienen 'recaudadora_req' ===\n";
while($row = pg_fetch_assoc($result)) {
    echo $row['routine_schema'] . '.' . $row['routine_name'] . "\n";
}
pg_close($conn);
