<?php
$db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
echo "Estructura de public.bloqueo:\n\n";
$stmt = $db->query("SELECT column_name, data_type, character_maximum_length, is_nullable FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'bloqueo' ORDER BY ordinal_position");
foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
    $type = $col["data_type"];
    if ($col["character_maximum_length"]) $type .= "({$col["character_maximum_length"]})";
    echo "  - {$col["column_name"]}: {$type} " . ($col["is_nullable"] == "NO" ? "NOT NULL" : "NULL") . "\n";
}
echo "\nMuestra de datos:\n";
$stmt = $db->query("SELECT * FROM public.bloqueo LIMIT 2");
foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) { print_r($row); }
?>
