<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ZonaAnuncioController extends Controller
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
            case 'zonaanuncio.list':
                return $this->list($params);
            case 'zonaanuncio.get':
                return $this->get($params);
            case 'zonaanuncio.create':
                return $this->create($params, $user);
            case 'zonaanuncio.update':
                return $this->update($params, $user);
            case 'zonaanuncio.delete':
                return $this->delete($params, $user);
            case 'zonaanuncio.catalogs':
                return $this->catalogs();
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    public function list($params)
    {
        $anuncio = $params['anuncio'] ?? null;
        $result = DB::select('SELECT * FROM anuncios_zona WHERE anuncio = ?', [$anuncio]);
        return response()->json(['data' => $result]);
    }

    public function get($params)
    {
        $anuncio = $params['anuncio'] ?? null;
        $result = DB::select('SELECT * FROM anuncios_zona WHERE anuncio = ?', [$anuncio]);
        if (count($result) === 0) {
            return response()->json(['error' => 'No encontrado'], 404);
        }
        return response()->json(['data' => $result[0]]);
    }

    public function create($params, $user)
    {
        $validator = Validator::make($params, [
            'anuncio' => 'required|integer',
            'zona' => 'required|integer',
            'subzona' => 'required|integer',
            'recaud' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $exists = DB::select('SELECT 1 FROM anuncios_zona WHERE anuncio = ?', [$params['anuncio']]);
        if ($exists) {
            return response()->json(['error' => 'Ya existe registro para este anuncio'], 409);
        }
        $now = now();
        $capturista = $user ? $user->username : 'system';
        DB::insert('INSERT INTO anuncios_zona (anuncio, zona, subzona, recaud, feccap, capturista) VALUES (?, ?, ?, ?, ?, ?)', [
            $params['anuncio'], $params['zona'], $params['subzona'], $params['recaud'], $now, $capturista
        ]);
        return response()->json(['success' => true]);
    }

    public function update($params, $user)
    {
        $validator = Validator::make($params, [
            'anuncio' => 'required|integer',
            'zona' => 'required|integer',
            'subzona' => 'required|integer',
            'recaud' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $now = now();
        $capturista = $user ? $user->username : 'system';
        $affected = DB::update('UPDATE anuncios_zona SET zona = ?, subzona = ?, recaud = ?, feccap = ?, capturista = ? WHERE anuncio = ?', [
            $params['zona'], $params['subzona'], $params['recaud'], $now, $capturista, $params['anuncio']
        ]);
        if ($affected === 0) {
            return response()->json(['error' => 'No encontrado'], 404);
        }
        return response()->json(['success' => true]);
    }

    public function delete($params, $user)
    {
        $anuncio = $params['anuncio'] ?? null;
        if (!$anuncio) {
            return response()->json(['error' => 'Falta parámetro anuncio'], 422);
        }
        $affected = DB::delete('DELETE FROM anuncios_zona WHERE anuncio = ?', [$anuncio]);
        return response()->json(['success' => $affected > 0]);
    }

    public function catalogs()
    {
        $zonas = DB::select('SELECT cvezona as id, zona as nombre, cvezona || \' - \' || zona as descripcion FROM c_zonas ORDER BY cvezona');
        $subzonas = DB::select('SELECT cvezona, cvesubzona as id, descsubzon as nombre, cvesubzona || \' - \' || descsubzon as descripcion FROM c_subzonas ORDER BY cvezona, cvesubzona');
        $recaudadoras = DB::select('SELECT recaud as id, descripcion as nombre, recaud || \' - \' || descripcion as descripcion FROM c_recaud WHERE recaud <= 5 ORDER BY recaud');
        return response()->json([
            'zonas' => $zonas,
            'subzonas' => $subzonas,
            'recaudadoras' => $recaudadoras
        ]);
    }
}
