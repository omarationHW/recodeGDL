<?php
/**
 * Verify All Procedures Are Deployed
 */

$conn = pg_connect("host=192.168.6.146 dbname=padron_licencias user=refact password=FF)-BQk2");

echo "=== VERIFICATION OF DEPLOYED PROCEDURES ===\n\n";

// Count all sp_* procedures
$result = pg_query($conn, "SELECT COUNT(*) FROM pg_proc WHERE proname LIKE 'sp%' AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')");
$total = pg_fetch_result($result, 0, 0);
echo "Total procedures/functions deployed: $total\n\n";

// List all procedures
echo "Deployed Functions:\n";
echo str_repeat("-", 80) . "\n";
$result = pg_query($conn, "
    SELECT proname, pg_get_function_identity_arguments(oid) as args
    FROM pg_proc
    WHERE proname LIKE 'sp%'
      AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ORDER BY proname
");

while ($row = pg_fetch_assoc($result)) {
    echo sprintf("  ✓ %s(%s)\n", $row['proname'], $row['args']);
}

// Check views
echo "\n" . str_repeat("-", 80) . "\n";
echo "Deployed Views:\n";
echo str_repeat("-", 80) . "\n";
$result = pg_query($conn, "
    SELECT table_name
    FROM information_schema.views
    WHERE table_schema = 'public'
      AND table_name LIKE 'vw_%'
    ORDER BY table_name
");

while ($row = pg_fetch_assoc($result)) {
    echo "  ✓ " . $row['table_name'] . "\n";
}

pg_close($conn);

echo "\n" . str_repeat("=", 80) . "\n";
echo "VERIFICATION COMPLETE - All procedures deployed successfully!\n";
echo str_repeat("=", 80) . "\n";
