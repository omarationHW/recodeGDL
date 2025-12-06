<?php
// Script para verificar el filtro de giros por SMALLINT

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    echo "Error al conectar\n";
    exit;
}

echo "====== ANÁLISIS DE GIROS VIGENTES ======\n\n";

// Total de giros vigentes sin filtro
$query = "SELECT COUNT(*) as total FROM comun.c_giros WHERE vigente = 'V'";
$result = pg_query($conn, $query);
$row = pg_fetch_assoc($result);
echo "Total giros vigentes (sin filtro): {$row['total']}\n";

// Total de giros con filtro SMALLINT
$query = "SELECT COUNT(*) as total FROM sp_get_giros_vigentes()";
$result = pg_query($conn, $query);
$row = pg_fetch_assoc($result);
$total_filtrado = $row['total'];
echo "Total giros vigentes (SMALLINT): {$total_filtrado}\n";

// Rango de IDs en los giros filtrados
$query = "SELECT MIN(id_giro) as min_id, MAX(id_giro) as max_id FROM sp_get_giros_vigentes()";
$result = pg_query($conn, $query);
$row = pg_fetch_assoc($result);
echo "\nRango de IDs después del filtro:\n";
echo "  Mínimo: {$row['min_id']}\n";
echo "  Máximo: {$row['max_id']}\n";

// Giros excluidos por el filtro
$query = "SELECT COUNT(*) as excluidos
          FROM comun.c_giros
          WHERE vigente = 'V'
            AND (id_giro < -32768 OR id_giro > 32767)";
$result = pg_query($conn, $query);
$row = pg_fetch_assoc($result);
echo "\nGiros excluidos (ID fuera de SMALLINT): {$row['excluidos']}\n";

echo "\n✓ Filtro aplicado correctamente\n";

pg_close($conn);
?>
