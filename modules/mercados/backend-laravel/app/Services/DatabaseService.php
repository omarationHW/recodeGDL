<?php

namespace App\Services;

use App\Models\eRequest;
use Illuminate\Support\Facades\DB;

class DatabaseService
{
    public function executeProcedure(eRequest $request, string $storedProcedure = null)
    {
        // Usar el stored procedure proporcionado o construirlo desde la operación
        $sp = $storedProcedure ?? ('sp_' . strtolower($request->Operacion ?? ''));
        
        $params = [];
        foreach ($request->Parametros as $param) {
            $params[] = $param['Valor'];
        }
        
        $query = "SELECT * FROM {$sp}(" . str_repeat('?,', count($params));
        $query = rtrim($query, ',') . ')';
        
        if ($request->Tiempo > 0) {
            DB::statement("SET statement_timeout = ?", [$request->Tiempo * 1000]);
        }
        
        try {
            if ($request->Tipo === 0) {
                $results = DB::select($query, $params);
                return array_map(function($item) {
                    return (array) $item;
                }, $results);
            } else {
                DB::beginTransaction();
                $result = DB::selectOne($query, $params);
                DB::commit();
                return (array) $result;
            }
        } catch (\Exception $e) {
            if ($request->Tipo === 1) {
                DB::rollBack();
            }
            throw $e;
        }
    }
}