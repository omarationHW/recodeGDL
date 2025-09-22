<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'getContrarecibosByDate':
                    $date = $params['fecha'] ?? null;
                    $result = DB::select('SELECT a.ejercicio, a.procedencia, a.contrarecibo, b.denominacion, a.importe, a.fecha_contrarecibo, a.concepto, a.notas FROM ta_contrarecibos a JOIN ta_proveedores b ON a.id_proveedor = b.id_proveedor WHERE a.fecha_ingreso = ? ORDER BY a.ejercicio, a.procedencia, a.contrarecibo', [$date]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'sumContrarecibosByDate':
                    $date = $params['fecha'] ?? null;
                    $result = DB::select('SELECT SUM(importe) as total FROM ta_contrarecibos WHERE fecha_ingreso = ?', [$date]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                case 'getProveedorCatalog':
                    $result = DB::select('SELECT * FROM ta_proveedores WHERE fecha_termino IS NULL');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getContrareciboDetalle':
                    $id = $params['contrarecibo'] ?? null;
                    $result = DB::select('SELECT * FROM ta_contrarecibos WHERE contrarecibo = ?', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'createContrarecibo':
                    $spResult = DB::select('SELECT * FROM spd_crbo_abc(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['ejercicio'],
                        $params['procedencia'],
                        $params['crbo'],
                        $params['feccrbo'],
                        $params['diasven'],
                        $params['importe'],
                        $params['concepto'],
                        $params['proveedor'],
                        $params['doctos'],
                        $params['fecingre'],
                        $params['fecvenci'],
                        $params['feccodi'],
                        $params['fecveri'],
                        $params['fecprog'],
                        $params['fecaja'],
                        $params['feccancel'],
                        $params['cvecheq'],
                        $params['benef'],
                        $params['formapago'],
                        $params['notas'],
                        $params['param'],
                        $params['num_ctrol_cheque'],
                        $params['clave_movimiento'],
                        $params['benef_cheque']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $spResult;
                    break;
                case 'updateProveedor':
                    $spResult = DB::select('SELECT * FROM spd_proveedor_abc(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['idproveedor'],
                        $params['denominacion'],
                        $params['origen'],
                        $params['domicilio'],
                        $params['colonia'],
                        $params['cod_postal'],
                        $params['ciudad'],
                        $params['tel01'],
                        $params['tel02'],
                        $params['fax'],
                        $params['radio'],
                        $params['rfc'],
                        $params['notas'],
                        $params['fechaingreso'],
                        $params['fechatermino'],
                        $params['parametro'],
                        $params['cuenta'],
                        $params['banco'],
                        $params['plaza_nom'],
                        $params['plaza_num']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $spResult;
                    break;
                // ... Agregar más casos según los SP y lógica del formulario ...
                default:
                    $response['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
