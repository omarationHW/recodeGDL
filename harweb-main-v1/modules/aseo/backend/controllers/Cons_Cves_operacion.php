<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsCvesOperacionController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'eRequest' => 'required|array',
            'eRequest.action' => 'required|string',
            'eRequest.data' => 'nullable|array',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => $validator->errors()->first(),
                    'data' => null
                ]
            ], 400);
        }

        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data', []);
        $response = [
            'status' => 'error',
            'message' => 'Unknown action',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'list':
                    $order = $data['order'] ?? 'ctrol_operacion';
                    $result = DB::select('SELECT * FROM ta_16_operacion ORDER BY ' . preg_replace('/[^a-zA-Z0-9_]/', '', $order));
                    $response = [
                        'status' => 'success',
                        'message' => 'Listado obtenido',
                        'data' => $result
                    ];
                    break;
                case 'create':
                    $cve = $data['cve_operacion'] ?? null;
                    $desc = $data['descripcion'] ?? null;
                    $res = DB::select('SELECT * FROM sp16_operacion_create(?, ?)', [$cve, $desc]);
                    $response = [
                        'status' => $res[0]->status == 0 ? 'success' : 'error',
                        'message' => $res[0]->leyenda,
                        'data' => null
                    ];
                    break;
                case 'update':
                    $ctrol = $data['ctrol_operacion'] ?? null;
                    $desc = $data['descripcion'] ?? null;
                    $res = DB::select('SELECT * FROM sp16_operacion_update(?, ?)', [$ctrol, $desc]);
                    $response = [
                        'status' => $res[0]->status == 0 ? 'success' : 'error',
                        'message' => $res[0]->leyenda,
                        'data' => null
                    ];
                    break;
                case 'delete':
                    $ctrol = $data['ctrol_operacion'] ?? null;
                    $res = DB::select('SELECT * FROM sp16_operacion_delete(?)', [$ctrol]);
                    $response = [
                        'status' => $res[0]->status == 0 ? 'success' : 'error',
                        'message' => $res[0]->leyenda,
                        'data' => null
                    ];
                    break;
                case 'export_excel':
                    // Implementar exportación a Excel si es necesario
                    $response = [
                        'status' => 'success',
                        'message' => 'Exportación no implementada en API',
                        'data' => null
                    ];
                    break;
                default:
                    $response = [
                        'status' => 'error',
                        'message' => 'Acción no soportada',
                        'data' => null
                    ];
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'message' => $e->getMessage(),
                'data' => null
            ];
        }

        return response()->json(['eResponse' => $response]);
    }
}
