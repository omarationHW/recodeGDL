<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ProyectoObra extends Model
{
    protected $table = 'pavimentacion.ta_99_proyecto_obra_pavimiento';
    protected $primaryKey = 'id_control';
    public $timestamps = true;
    
    protected $fillable = [
        'contrato',
        'nombre',
        'calle',
        'metros',
        'costomtr',
        'costototal',
        'tipo_pavimento'
    ];

    protected $casts = [
        'metros' => 'decimal:2',
        'costomtr' => 'decimal:2',
        'costototal' => 'decimal:2',
    ];

    protected $appends = ['pavimento_descripcion', 'adeudo_total'];

    public function adeudos(): HasMany
    {
        return $this->hasMany(AdeudoObra::class, 'id_control', 'id_control');
    }

    public function getPavimentoDescripcionAttribute(): string
    {
        return $this->tipo_pavimento === 'A' ? 'ASFALTO' : 'CONCRETO HIDRAULICO';
    }

    public function getAdeudoTotalAttribute(): float
    {
        return $this->adeudos()
            ->where('estado', 'V')
            ->sum('mensualidad');
    }
}