<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pavimentacion.ta_99_adeudos_obra', function (Blueprint $table) {
            $table->id('id_adeudo');
            $table->unsignedBigInteger('id_control');
            $table->integer('axo');
            $table->integer('mes');
            $table->decimal('mensualidad', 18, 2);
            $table->string('numero_recibo', 20)->nullable();
            $table->char('estado', 1)->default('V');
            $table->timestamps();
            
            $table->foreign('id_control')
                  ->references('id_control')
                  ->on('pavimentacion.ta_99_proyecto_obra_pavimiento')
                  ->onDelete('cascade');
            
            $table->index('id_control');
            $table->index('estado');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pavimentacion.ta_99_adeudos_obra');
    }
};