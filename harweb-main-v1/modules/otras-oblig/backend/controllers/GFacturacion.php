<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for GFacturacion (Facturación General)
     * Endpoint: /api/execute
     * Pattern: eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'getTablas':
                    $result = DB::select('SELECT cve_tab, nombre, descripcion FROM t34_tablas INNER JOIN t34_unidades USING (cve_tab) WHERE cve_tab = ? GROUP BY cve_tab, nombre, descripcion ORDER BY cve_tab, nombre, descripcion', [$params['par_tab']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getEtiquetas':
                    $result = DB::select('SELECT * FROM t34_etiq WHERE cve_tab = ?', [$params['par_tab']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getFacturacion':
                    $result = DB::select('CALL sp_con34_gfact_02(?, ?, ?, ?, ?)', [
                        $params['par_Tab'],
                        $params['par_Ade'],
                        $params['Par_Rcgo'],
                        $params['par_Axo'],
                        $params['par_Mes']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getMeses':
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        ['value' => 1, 'label' => 'Enero'],
                        ['value' => 2, 'label' => 'Febrero'],
                        ['value' => 3, 'label' => 'Marzo'],
                        ['value' => 4, 'label' => 'Abril'],
                        ['value' => 5, 'label' => 'Mayo'],
                        ['value' => 6, 'label' => 'Junio'],
                        ['value' => 7, 'label' => 'Julio'],
                        ['value' => 8, 'label' => 'Agosto'],
                        ['value' => 9, 'label' => 'Septiembre'],
                        ['value' => 10, 'label' => 'Octubre'],
                        ['value' => 11, 'label' => 'Noviembre'],
                        ['value' => 12, 'label' => 'Diciembre']
                    ];
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
