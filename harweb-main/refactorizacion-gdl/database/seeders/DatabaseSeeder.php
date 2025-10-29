<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Usar la función stored procedure para insertar datos de prueba
        // Esto garantiza que se use la lógica de negocio implementada en PostgreSQL
        
        // Proyecto 1: BENITA CABRERA TOSCANO
        DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            1, 'BENITA CABRERA TOSCANO', 'ZARAGOZA', 15, 650.00, 'H'
        ]);

        // Proyecto 2: OWEN NUÑO
        DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            2, 'OWEN NUÑO', 'HIDALGO', 7, 650.00, 'A'
        ]);

        // Proyecto 3: OMAR ALEJANDRO JIMENEZ
        DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            3, 'OMAR ALEJANDRO JIMENEZ', 'INDEPENDENCIA', 5, 650.00, 'H'
        ]);

        // Proyecto 4: JUAN PÉREZ GARCÍA
        DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            4, 'JUAN PÉREZ GARCÍA', 'AV. REVOLUCIÓN #123', 25.50, 850.00, 'A'
        ]);

        // Proyecto 5: MARÍA GONZÁLEZ LÓPEZ
        DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            5, 'MARÍA GONZÁLEZ LÓPEZ', 'CALLE MORELOS #456', 18.75, 950.00, 'H'
        ]);

        // Marcar algunos pagos como realizados para simular el estado real
        // Proyecto 2 (OWEN NUÑO) - primeros 3 meses pagados
        DB::update("
            UPDATE pavimentacion.ta_99_adeudos_obra 
            SET estado = 'P', numero_recibo = 'REC-2024-001'
            WHERE id_control = 2 AND mes IN (1, 2, 3)
        ");

        // Proyecto 3 (OMAR ALEJANDRO) - primer mes pagado  
        DB::update("
            UPDATE pavimentacion.ta_99_adeudos_obra 
            SET estado = 'P', numero_recibo = 'REC-2024-002'
            WHERE id_control = 3 AND mes = 1
        ");

        // Proyecto 5 (MARÍA GONZÁLEZ) - primeros 6 meses pagados
        DB::update("
            UPDATE pavimentacion.ta_99_adeudos_obra 
            SET estado = 'P', numero_recibo = CONCAT('REC-2024-00', mes + 2)
            WHERE id_control = 5 AND mes IN (1, 2, 3, 4, 5, 6)
        ");

        // Agregar más proyectos para demostrar variedad
        DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            6, 'ANA MARÍA RODRÍGUEZ', 'CALLE REFORMA #789', 12.25, 720.00, 'A'
        ]);

        DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            7, 'CARLOS MENDOZA SILVA', 'AV. JUÁREZ #234', 20.00, 680.00, 'H'
        ]);

        DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            8, 'LAURA FERNÁNDEZ CRUZ', 'CALLE CONSTITUCIÓN #567', 8.50, 750.00, 'A'
        ]);
    }
}