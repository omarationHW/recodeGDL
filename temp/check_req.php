<?php
$db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$db->exec("SET search_path TO public, comun");

echo "Tablas con 'req':\n";
$stmt = $db->query("SELECT schemaname, tablename FROM pg_tables WHERE tablename LIKE '%req%' ORDER BY schemaname");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo $row['schemaname'] . "." . $row['tablename'] . "\n";
}

echo "\nSPs en public con 'req':\n";
$stmt = $db->query("SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND proname LIKE '%req%'");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "public." . $row['proname'] . "\n";
}

echo "\nSPs en comun con 'req':\n";
$stmt = $db->query("SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'comun' AND proname LIKE '%req%'");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "comun." . $row['proname'] . "\n";
}
