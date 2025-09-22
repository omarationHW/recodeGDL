<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement('CREATE SCHEMA IF NOT EXISTS pavimentacion');
        
        Schema::create('pavimentacion.ta_99_proyecto_obra_pavimiento', function (Blueprint $table) {
            $table->id('id_control');
            $table->integer('contrato')->unique();
            $table->string('nombre', 100);
            $table->string('calle', 100);
            $table->decimal('metros', 5, 2);
            $table->decimal('costomtr', 18, 2);
            $table->decimal('costototal', 18, 2);
            $table->char('tipo_pavimento', 1);
            $table->timestamps();
            
            $table->index('contrato');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pavimentacion.ta_99_proyecto_obra_pavimiento');
    }
};