<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class eRequest extends Model
{
    public string $Tenant = '';
    public int $Tipo = 0;  // 0=Consulta, 1=Comando
    public string $Base = '';
    public string $Operacion = '';  // Nombre de operación (ej: "login", "get_usuarios")
    public array $Parametros = [];
    public int $Tiempo = 30;
    
    public function __construct(array $attributes = [])
    {
        parent::__construct($attributes);
        
        if (isset($attributes['Tenant'])) $this->Tenant = $attributes['Tenant'];
        if (isset($attributes['Tipo'])) $this->Tipo = $attributes['Tipo'];
        if (isset($attributes['Base'])) $this->Base = $attributes['Base'];
        if (isset($attributes['Operacion'])) $this->Operacion = $attributes['Operacion'];
        if (isset($attributes['Parametros'])) $this->Parametros = $attributes['Parametros'];
        if (isset($attributes['Tiempo'])) $this->Tiempo = $attributes['Tiempo'];
    }
}