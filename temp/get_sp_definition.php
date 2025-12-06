<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$def = $pdo->query("SELECT pg_get_functiondef(oid) as definition FROM pg_proc WHERE proname = 'sp_get_mercados_by_recaudadora' AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')")->fetch(PDO::FETCH_ASSOC);
if ($def) {
    echo $def['definition'];
}
?>
