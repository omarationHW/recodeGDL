<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ListadoMultipleController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'getRecaudadoras':
                $data = DB::select('SELECT * FROM c_recaud WHERE recaud < 5');
                return response()->json(['success' => true, 'data' => $data]);
            case 'getConveniosEmpresas':
                $year = $params['year'] ?? date('Y');
                $fecha = $params['fecha'] ?? date('Y-m-d');
                $data = DB::select('SELECT * FROM conveniosempresas(:paxo, :pfecha)', [
                    'paxo' => $year,
                    'pfecha' => $fecha
                ]);
                return response()->json(['success' => true, 'data' => $data]);
            case 'getPagosConveniosEmpresas':
                $ejecutor = $params['ejecutor'] ?? null;
                $ftrab = $params['ftrab'] ?? null;
                $fpagod = $params['fpagod'] ?? null;
                $fpagoh = $params['fpagoh'] ?? null;
                $data = DB::select('SELECT * FROM pagos_convenios_empresas(:pejec, :pftrab, :pfpagod, :pfpagoh)', [
                    'pejec' => $ejecutor,
                    'pftrab' => $ftrab,
                    'pfpagod' => $fpagod,
                    'pfpagoh' => $fpagoh
                ]);
                return response()->json(['success' => true, 'data' => $data]);
            case 'getEjecutoresEmpresas':
                $ftrabajo = $params['ftrabajo'] ?? null;
                $data = DB::select('SELECT DISTINCT f.cveejecutor, TRIM(e.paterno)||' '||TRIM(e.materno)||' '||TRIM(e.nombres) AS empresa FROM ctaempexterna f INNER JOIN ejecutor e ON e.cveejecutor=f.cveejecutor WHERE f.fecha_trabajo >= :ftrabajo', [
                    'ftrabajo' => $ftrabajo
                ]);
                return response()->json(['success' => true, 'data' => $data]);
            case 'exportConveniosEmpresasExcel':
                // Implementar lógica de exportación a Excel
                // ...
                return response()->json(['success' => true, 'message' => 'Exportación generada']);
            case 'exportPagosConveniosEmpresasExcel':
                // Implementar lógica de exportación a Excel
                // ...
                return response()->json(['success' => true, 'message' => 'Exportación generada']);
            default:
                return response()->json(['success' => false, 'message' => 'Acción no soportada'], 400);
        }
    }
}
