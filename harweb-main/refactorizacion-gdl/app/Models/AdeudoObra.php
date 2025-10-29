<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AdeudoObra extends Model
{
    protected $table = 'pavimentacion.ta_99_adeudos_obra';
    protected $primaryKey = 'id_adeudo';
    public $timestamps = true;
    
    protected $fillable = [
        'id_control',
        'axo',
        'mes',
        'mensualidad',
        'numero_recibo',
        'estado'
    ];

    protected $casts = [
        'mensualidad' => 'decimal:2',
    ];

    public function proyecto(): BelongsTo
    {
        return $this->belongsTo(ProyectoObra::class, 'id_control', 'id_control');
    }
}