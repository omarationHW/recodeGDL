<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ZonaLicenciaController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asumimos autenticación JWT

        switch ($action) {
            case 'get_zonas':
                $recaud = $params['recaud'] ?? null;
                $zonas = DB::select('SELECT * FROM c_zonas WHERE cvezona IN (SELECT zona FROM c_zonayrec WHERE rec = ?) ORDER BY cvezona', [$recaud]);
                return response()->json(['success' => true, 'data' => $zonas]);
            case 'get_subzonas':
                $cvezona = $params['cvezona'] ?? null;
                $recaud = $params['recaud'] ?? null;
                $subzonas = DB::select('SELECT * FROM c_subzonas WHERE cvezona = ? AND cvesubzona IN (SELECT subzona FROM c_zonayrec WHERE rec = ? AND zona = cvezona) ORDER BY cvesubzona', [$cvezona, $recaud]);
                return response()->json(['success' => true, 'data' => $subzonas]);
            case 'get_recaudadoras':
                $recaudadoras = DB::select('SELECT * FROM c_recaud WHERE recaud <= 5');
                return response()->json(['success' => true, 'data' => $recaudadoras]);
            case 'get_licencia':
                $licencia = $params['licencia'] ?? null;
                $row = DB::selectOne('SELECT * FROM licencias WHERE licencia = ?', [$licencia]);
                return response()->json(['success' => true, 'data' => $row]);
            case 'get_licencias_zona':
                $licencia = $params['licencia'] ?? null;
                $row = DB::selectOne('SELECT * FROM licencias_zona WHERE licencia = ?', [$licencia]);
                return response()->json(['success' => true, 'data' => $row]);
            case 'save_licencias_zona':
                $licencia = $params['licencia'];
                $zona = $params['zona'];
                $subzona = $params['subzona'];
                $recaud = $params['recaud'];
                $capturista = $user->username ?? 'sistema';
                $now = now();
                $exists = DB::selectOne('SELECT 1 FROM licencias_zona WHERE licencia = ?', [$licencia]);
                if ($exists) {
                    DB::update('UPDATE licencias_zona SET zona = ?, subzona = ?, recaud = ?, feccap = ?, capturista = ? WHERE licencia = ?', [$zona, $subzona, $recaud, $now, $capturista, $licencia]);
                } else {
                    DB::insert('INSERT INTO licencias_zona (licencia, zona, subzona, recaud, feccap, capturista) VALUES (?, ?, ?, ?, ?, ?)', [$licencia, $zona, $subzona, $recaud, $now, $capturista]);
                }
                return response()->json(['success' => true]);
            default:
                return response()->json(['success' => false, 'error' => 'Acción no soportada'], 400);
        }
    }
}
