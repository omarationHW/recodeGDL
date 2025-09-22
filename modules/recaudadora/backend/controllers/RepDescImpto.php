<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RepDescImptoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario RepDescImpto
     * Entrada: eRequest con acción y parámetros
     * Salida: eResponse con datos/resultados
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $user = $request->user(); // Si hay autenticación
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getCatalogs':
                    $response['data'] = [
                        'recaudadoras' => DB::select('SELECT id_recau, nombredepto FROM deptos WHERE id_recau > 0'),
                        'tipos_descuento' => DB::select('SELECT cvedescuento, (axodescto || \'-\' || descripcion) as tipo FROM c_descpred WHERE axodescto <= EXTRACT(YEAR FROM CURRENT_DATE) ORDER BY 2 DESC')
                    ];
                    $response['success'] = true;
                    break;
                case 'getDescuentos':
                    $tipoArchivo = $params['tipoArchivo'] ?? 'aplicados';
                    $tipoFecha = $params['tipoFecha'] ?? 0;
                    $fecha1 = $params['fecha1'] ?? null;
                    $fecha2 = $params['fecha2'] ?? null;
                    $recaudadora = $params['recaudadora'] ?? null;
                    $tipoDescuento = $params['tipoDescuento'] ?? null;
                    $cuenta = $params['cuenta'] ?? null;
                    $sql = '';
                    if ($tipoArchivo === 'aplicados') {
                        $sql = 'SELECT d.cvecuenta, d.cvedescuento, bimini, bimfin, fecalta, (SELECT nombres FROM usuarios WHERE usuario=captalta) AS usualta, fecbaja, (SELECT nombres FROM usuarios WHERE usuario=captbaja) AS usubaja, propie, solicitante, observaciones, d.recaud, foliodesc, status, identificacion, fecnac, i.institucion, c.recaud AS recaud_1, c.urbrus, c.cuenta, e.descripcion, e.axodescto, (SELECT COALESCE(SUM(impfac-impvir-imppag),0) FROM detsaldos WHERE cvecuenta= d.cvecuenta AND cvedescuento=d.cvedescuento) AS adeudo, CASE WHEN d.fecbaja IS NOT NULL THEN \'C\' WHEN (SELECT COALESCE(SUM(impfac-impvir-imppag),0) FROM detsaldos WHERE cvecuenta= d.cvecuenta AND cvedescuento=d.cvedescuento) = 0 THEN \'P\' ELSE \'A\' END AS vigen FROM descpred d JOIN convcta c ON d.cvecuenta=c.cvecuenta JOIN c_descpred e ON d.cvedescuento=e.cvedescuento LEFT JOIN c_instituciones i ON d.institucion=i.cveinst WHERE 1=1';
                        if ($tipoFecha == 1 && $fecha1 && $fecha2) {
                            $sql .= ' AND d.fecalta BETWEEN ? AND ? AND d.fecbaja IS NULL';
                        } elseif ($tipoFecha == 2 && $fecha1 && $fecha2) {
                            $sql .= ' AND d.fecbaja BETWEEN ? AND ?';
                        }
                        if ($recaudadora) {
                            $sql .= ' AND d.recaud = ?';
                        }
                        if ($tipoDescuento) {
                            $sql .= ' AND d.cvedescuento = ?';
                        }
                        $bindings = [];
                        if ($tipoFecha == 1 || $tipoFecha == 2) {
                            $bindings[] = $fecha1;
                            $bindings[] = $fecha2;
                        }
                        if ($recaudadora) $bindings[] = $recaudadora;
                        if ($tipoDescuento) $bindings[] = $tipoDescuento;
                        $response['data'] = DB::select($sql, $bindings);
                        $response['success'] = true;
                    } else if ($tipoArchivo === 'reactivados') {
                        $sql = 'SELECT d.cvecuenta, d.cvedescuento, bimini, bimfin, fecalta, nombres AS usualta, (SELECT nombres FROM usuarios WHERE usuario=capbaja) AS usubaja, (SELECT CASE WHEN razonsocial<>\'\' THEN razonsocial ELSE (TRIM(paterno)||\' \'|| TRIM(materno)||\' \'||TRIM(nombres)) END FROM uem3 WHERE cvectacat=d.cvecuenta) AS propie, solicitante, observaciones, s.id_recau, d.rowid AS foliodesc, status, identificacion, fecnac, i.institucion, c.recaud, c.urbrus, c.cuenta, e.descripcion, e.axodescto, (SELECT COALESCE(SUM(impfac-impvir-imppag),0) FROM detsaldos WHERE cvecuenta= d.cvecuenta AND cvedescuento=d.cvedescuento) AS adeudo, CASE WHEN d.capbaja<>\'\' THEN \'C\' WHEN (SELECT COALESCE(SUM(impfac-impvir-imppag),0) FROM detsaldos WHERE cvecuenta= d.cvecuenta AND cvedescuento=d.cvedescuento) = 0 THEN \'P\' ELSE \'A\' END AS vigen FROM descpred_reactiva d JOIN convcta c ON d.cvecuenta=c.cvecuenta JOIN c_descpred e ON d.cvedescuento=e.cvedescuento LEFT JOIN c_instituciones i ON d.institucion=i.cveinst JOIN usuarios u ON d.captalta=u.usuario JOIN deptos s ON u.cvedepto=s.cvedepto WHERE 1=1';
                        if ($tipoFecha == 1 && $fecha1 && $fecha2) {
                            $sql .= ' AND d.fecalta BETWEEN ? AND ? AND d.capbaja IS NULL';
                        } elseif ($tipoFecha == 2 && $fecha1 && $fecha2) {
                            $sql .= ' AND d.capbaja <> \'\'';
                        }
                        if ($recaudadora) {
                            $sql .= ' AND d.recaud = ?';
                        }
                        if ($tipoDescuento) {
                            $sql .= ' AND d.cvedescuento = ?';
                        }
                        $bindings = [];
                        if ($tipoFecha == 1 || $tipoFecha == 2) {
                            $bindings[] = $fecha1;
                            $bindings[] = $fecha2;
                        }
                        if ($recaudadora) $bindings[] = $recaudadora;
                        if ($tipoDescuento) $bindings[] = $tipoDescuento;
                        $response['data'] = DB::select($sql, $bindings);
                        $response['success'] = true;
                    }
                    break;
                case 'exportExcel':
                    // Implementar exportación a Excel si es necesario
                    $response['success'] = true;
                    $response['message'] = 'Exportación no implementada en backend, usar frontend.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
