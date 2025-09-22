<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ConsTiposAseoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'cons_tipos_aseo_list':
                    $order = $params['order'] ?? 'ctrol_aseo';
                    $result = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY ' . $this->sanitizeOrder($order));
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'cons_tipos_aseo_export_excel':
                    // Implementación de exportación a Excel (puede ser un job o return de archivo)
                    $response['success'] = true;
                    $response['data'] = null;
                    $response['message'] = 'Exportación a Excel generada (implementación pendiente)';
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }

    /**
     * Sanitiza el campo de ordenamiento para evitar SQL Injection
     */
    private function sanitizeOrder($order)
    {
        $allowed = ['ctrol_aseo', 'tipo_aseo', 'descripcion'];
        return in_array($order, $allowed) ? $order : 'ctrol_aseo';
    }
}
