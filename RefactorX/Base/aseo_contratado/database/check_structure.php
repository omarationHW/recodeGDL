<?php
$conn = pg_connect("host=192.168.6.146 dbname=padron_licencias user=refact password=FF)-BQk2");

echo "=== CHECKING TABLE STRUCTURES ===\n\n";

// Check ta_16_contratos columns
echo "1. ta_16_contratos columns:\n";
$result = pg_query($conn, "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'ta_16_contratos' ORDER BY ordinal_position");
while ($row = pg_fetch_assoc($result)) {
    echo "   - {$row['column_name']} ({$row['data_type']})\n";
}

// Check ta_16_unidades columns
echo "\n2. ta_16_unidades columns:\n";
$result = pg_query($conn, "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'ta_16_unidades' ORDER BY ordinal_position");
while ($row = pg_fetch_assoc($result)) {
    echo "   - {$row['column_name']} ({$row['data_type']})\n";
}

// Check ta_16_tipos_aseo columns
echo "\n3. ta_16_tipos_aseo table existence:\n";
$result = pg_query($conn, "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ta_16_tipos_aseo')");
$exists = pg_fetch_result($result, 0, 0);
echo "   Exists: " . ($exists === 't' ? 'YES' : 'NO') . "\n";

if ($exists === 't') {
    $result = pg_query($conn, "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'ta_16_tipos_aseo' ORDER BY ordinal_position");
    while ($row = pg_fetch_assoc($result)) {
        echo "   - {$row['column_name']} ({$row['data_type']})\n";
    }
}

// Check ta_16_tipo_aseo columns
echo "\n4. ta_16_tipo_aseo table existence:\n";
$result = pg_query($conn, "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ta_16_tipo_aseo')");
$exists = pg_fetch_result($result, 0, 0);
echo "   Exists: " . ($exists === 't' ? 'YES' : 'NO') . "\n";

if ($exists === 't') {
    $result = pg_query($conn, "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'ta_16_tipo_aseo' ORDER BY ordinal_position");
    while ($row = pg_fetch_assoc($result)) {
        echo "   - {$row['column_name']} ({$row['data_type']})\n";
    }
}

// Check existing procedures/functions
echo "\n5. Existing functions that need to be dropped:\n";
$result = pg_query($conn, "SELECT proname, pg_get_function_identity_arguments(oid) as args FROM pg_proc WHERE proname LIKE 'sp_%' AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public') ORDER BY proname");
$funcs = [];
while ($row = pg_fetch_assoc($result)) {
    $funcs[] = $row;
    if (in_array($row['proname'], ['sp_gastos_insert', 'sp_gastos_delete_all', 'sp_empresas_list', 'sp_recargos_list', 'sp_zonas_delete'])) {
        echo "   - {$row['proname']}({$row['args']})\n";
    }
}

pg_close($conn);
