<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class eResponse extends Model
{
    public int $ID = 0;
    public int $Err = 0;
    public string $Message = 'Ejecución satisfactoria';
    public array $Data = [];
    public mixed $DataObj = null;
    
    public static function success($id = 0, $data = null, $message = 'Ejecución satisfactoria')
    {
        return new self([
            'ID' => $id,
            'Err' => 0,
            'Message' => $message,
            'Data' => is_array($data) ? $data : [],
            'DataObj' => !is_array($data) ? $data : null
        ]);
    }
    
    public static function error($code = 1, $message = 'Error en la ejecución')
    {
        return new self([
            'ID' => 0,
            'Err' => $code,
            'Message' => $message,
            'Data' => [],
            'DataObj' => null
        ]);
    }
}