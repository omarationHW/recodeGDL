<?php
// Verificar estructura de tabla usuarios

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

if (!$conn) {
    echo "❌ Error de conexión\n";
    exit(1);
}

echo "=== VERIFICANDO TABLA PUBLIC.USUARIOS ===\n\n";

// Ver estructura
$query = "
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'usuarios'
    ORDER BY ordinal_position;
";

$result = pg_query($conn, $query);

if ($result && pg_num_rows($result) > 0) {
    echo "Columnas de public.usuarios:\n";
    while ($row = pg_fetch_assoc($result)) {
        echo sprintf(
            "  - %-20s %-15s %s\n",
            $row['column_name'],
            $row['data_type'],
            $row['is_nullable'] === 'YES' ? '(nullable)' : '(NOT NULL)'
        );
    }
} else {
    echo "No se pudo obtener estructura\n";
}

echo "\n" . str_repeat("=", 80) . "\n\n";

// Ver algunos datos de ejemplo
echo "Datos de ejemplo:\n";

$query2 = "SELECT * FROM public.usuarios LIMIT 5";
$result2 = pg_query($conn, $query2);

if ($result2 && pg_num_rows($result2) > 0) {
    while ($row = pg_fetch_assoc($result2)) {
        print_r($row);
    }
} else {
    echo "No hay datos o error: " . pg_last_error($conn) . "\n";
}

pg_close($conn);
