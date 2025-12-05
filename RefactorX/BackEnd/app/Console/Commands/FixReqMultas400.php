<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class FixReqMultas400 extends Command
{
    protected $signature = 'fix:reqmultas400';
    protected $description = 'Corrige stored procedures con estructura real de req_mul_400';

    public function handle()
    {
        $this->info('=== CORRIGIENDO STORED PROCEDURES REQMULTAS400FRM ===');
        $this->newLine();

        try {
            $schema = 'catastro_gdl';

            // 1. Obtener estructura real de la tabla
            $this->info('1. Obteniendo estructura de la tabla...');

            $columns = DB::select("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = ? AND table_name = 'req_mul_400'
                ORDER BY ordinal_position
            ", [$schema]);

            $this->info('   Columnas disponibles:');
            foreach ($columns as $col) {
                $this->line("      - {$col->column_name} ({$col->data_type})");
            }

            $this->newLine();

            // 2. Recrear SP 1: Búsqueda por acta
            $this->info('2. Recreando req_mul_400_by_acta...');

            DB::statement("DROP FUNCTION IF EXISTS req_mul_400_by_acta(VARCHAR, INTEGER, INTEGER, INTEGER) CASCADE");

            $sql1 = "
            CREATE OR REPLACE FUNCTION req_mul_400_by_acta(
                p_dep VARCHAR,
                p_axo INTEGER,
                p_numacta INTEGER,
                p_tipo INTEGER
            )
            RETURNS TABLE (
                cvelet VARCHAR,
                cvenum INTEGER,
                ctarfc INTEGER,
                cveapl INTEGER,
                axoreq INTEGER,
                folreq INTEGER,
                fecreq INTEGER,
                impcuo NUMERIC,
                observr VARCHAR,
                vigreq INTEGER,
                actreq INTEGER
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT
                    r.cvelet,
                    r.cvenum,
                    r.ctarfc,
                    r.cveapl,
                    r.axoreq,
                    r.folreq,
                    r.fecreq,
                    r.impcuo,
                    r.observr,
                    r.vigreq,
                    r.actreq
                FROM {$schema}.req_mul_400 r
                WHERE SUBSTRING(r.cvelet FROM 1 FOR 3) = p_dep
                  AND r.cvenum = p_axo
                  AND r.ctarfc = p_numacta
                  AND r.cveapl = p_tipo
                ORDER BY r.axoreq DESC, r.folreq DESC;
            END;
            \$\$ LANGUAGE plpgsql;
            ";

            DB::statement($sql1);
            $this->info('   ✓ req_mul_400_by_acta recreado');

            // 3. Recrear SP 2: Búsqueda por folio
            $this->newLine();
            $this->info('3. Recreando req_mul_400_by_folio...');

            DB::statement("DROP FUNCTION IF EXISTS req_mul_400_by_folio(INTEGER, INTEGER, INTEGER) CASCADE");

            $sql2 = "
            CREATE OR REPLACE FUNCTION req_mul_400_by_folio(
                p_axo INTEGER,
                p_folio INTEGER,
                p_tipo INTEGER
            )
            RETURNS TABLE (
                cvelet VARCHAR,
                cvenum INTEGER,
                ctarfc INTEGER,
                cveapl INTEGER,
                axoreq INTEGER,
                folreq INTEGER,
                fecreq INTEGER,
                impcuo NUMERIC,
                observr VARCHAR,
                vigreq INTEGER,
                actreq INTEGER
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT
                    r.cvelet,
                    r.cvenum,
                    r.ctarfc,
                    r.cveapl,
                    r.axoreq,
                    r.folreq,
                    r.fecreq,
                    r.impcuo,
                    r.observr,
                    r.vigreq,
                    r.actreq
                FROM {$schema}.req_mul_400 r
                WHERE r.axoreq = p_axo
                  AND r.folreq = p_folio
                  AND r.cveapl = p_tipo
                ORDER BY r.axoreq DESC, r.folreq DESC;
            END;
            \$\$ LANGUAGE plpgsql;
            ";

            DB::statement($sql2);
            $this->info('   ✓ req_mul_400_by_folio recreado');

            // 4. Recrear SP 3: Búsqueda general (principal)
            $this->newLine();
            $this->info('4. Recreando recaudadora_reqmultas400frm...');

            DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqmultas400frm(VARCHAR) CASCADE");

            $sql3 = "
            CREATE OR REPLACE FUNCTION recaudadora_reqmultas400frm(
                p_clave_cuenta VARCHAR DEFAULT NULL
            )
            RETURNS TABLE (
                cvelet VARCHAR,
                cvenum INTEGER,
                ctarfc INTEGER,
                cveapl INTEGER,
                axoreq INTEGER,
                folreq INTEGER,
                fecreq INTEGER,
                impcuo NUMERIC,
                observr VARCHAR,
                vigreq INTEGER,
                actreq INTEGER,
                tipo_multa VARCHAR
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT
                    r.cvelet,
                    r.cvenum,
                    r.ctarfc,
                    r.cveapl,
                    r.axoreq,
                    r.folreq,
                    r.fecreq,
                    r.impcuo,
                    r.observr,
                    r.vigreq,
                    r.actreq,
                    CASE
                        WHEN r.cveapl = 6 THEN 'Federal'
                        WHEN r.cveapl = 5 THEN 'Municipal'
                        ELSE 'Otro'
                    END::VARCHAR as tipo_multa
                FROM {$schema}.req_mul_400 r
                WHERE p_clave_cuenta IS NULL
                   OR r.cvelet ILIKE '%' || p_clave_cuenta || '%'
                   OR CAST(r.folreq AS VARCHAR) = p_clave_cuenta
                   OR CAST(r.axoreq AS VARCHAR) = p_clave_cuenta
                ORDER BY r.axoreq DESC, r.folreq DESC
                LIMIT 100;
            END;
            \$\$ LANGUAGE plpgsql;
            ";

            DB::statement($sql3);
            $this->info('   ✓ recaudadora_reqmultas400frm recreado');

            // 5. Probar el SP principal
            $this->newLine();
            $this->info('5. Probando recaudadora_reqmultas400frm...');

            try {
                $test = DB::select("SELECT * FROM recaudadora_reqmultas400frm(NULL) LIMIT 3");
                $this->info('   ✓ SP funciona correctamente');
                $this->info('   Retornó ' . count($test) . ' registros');

                if (count($test) > 0) {
                    $this->newLine();
                    $this->info('   Ejemplo de resultado:');
                    $first = (array)$test[0];
                    foreach ($first as $key => $value) {
                        $this->line("      $key: " . ($value ?? 'NULL'));
                    }
                }
            } catch (\Exception $e) {
                $this->error('   ✗ Error probando SP: ' . $e->getMessage());
                return Command::FAILURE;
            }

            // 6. Mostrar ejemplos para probar
            $this->newLine();
            $this->info('6. EJEMPLOS PARA PROBAR EN EL FORMULARIO:');
            $this->newLine();

            // Obtener ejemplos de diferentes criterios
            $examples = DB::select("
                SELECT DISTINCT
                    cvelet,
                    cvenum,
                    ctarfc,
                    cveapl,
                    axoreq,
                    folreq
                FROM {$schema}.req_mul_400
                WHERE axoreq >= 2002
                ORDER BY axoreq DESC, folreq DESC
                LIMIT 3
            ");

            foreach ($examples as $i => $ex) {
                $this->line("   Ejemplo " . ($i + 1) . ":");
                $this->line("      Búsqueda General:");
                $this->line("         - Folio: {$ex->folreq}");
                $this->line("         - Año: {$ex->axoreq}");
                $this->line("");
                $this->line("      Búsqueda por Acta:");
                $this->line("         - Dependencia: " . trim(substr($ex->cvelet, 0, 3)));
                $this->line("         - Año Acta: {$ex->cvenum}");
                $this->line("         - Núm Acta: {$ex->ctarfc}");
                $this->line("         - Tipo: {$ex->cveapl}");
                $this->line("");
                $this->line("      Búsqueda por Folio:");
                $this->line("         - Año Req: {$ex->axoreq}");
                $this->line("         - Folio Req: {$ex->folreq}");
                $this->line("         - Tipo: {$ex->cveapl}");
                $this->newLine();
            }

            $this->newLine();
            $this->info('✅ CORRECCIÓN COMPLETADA EXITOSAMENTE');
            $this->newLine();
            $this->info('Puedes probar el formulario en: http://localhost:3000');
            $this->info('Usa los ejemplos de arriba para hacer búsquedas.');

            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error('❌ ERROR: ' . $e->getMessage());
            $this->error($e->getTraceAsString());
            return Command::FAILURE;
        }
    }
}
