<?php
$conn = pg_connect('host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2');

echo "Folios disponibles en catastro_gdl.reqdiftransmision:\n\n";

$result = pg_query($conn, 'SELECT cvecuenta, folioreq, axoreq FROM catastro_gdl.reqdiftransmision ORDER BY cvereq LIMIT 10');

while ($row = pg_fetch_assoc($result)) {
    echo sprintf("Cuenta: %s | Folio: %d | Año: %d\n",
        $row['cvecuenta'],
        $row['folioreq'],
        $row['axoreq']
    );
}

pg_close($conn);
