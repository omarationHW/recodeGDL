# INFORME: Stored Procedures - Mantenimiento de Fechas de Descuento

**Fecha:** 2025-12-03
**Base de Datos:** mercados
**Esquema:** public
**Tabla Principal:** publico.ta_11_fecha_desc

---

## 1. RESUMEN EJECUTIVO

Se han creado **2 Stored Procedures principales** + **2 alias** para el mantenimiento de fechas de descuento en el sistema de Mercados.

### Stored Procedures Creados:

1. **fechas_descuento_get_all()** - Lista todas las fechas de descuento (12 meses)
2. **fechas_descuento_update()** - Actualiza/Inserta fechas por mes

### Alias de Compatibilidad:

1. **sp_fechadescuento_list()** - Alias de fechas_descuento_get_all()
2. **sp_fechadescuento_update()** - Alias de fechas_descuento_update()

---

## 2. ESTRUCTURA DE LA TABLA

### Tabla: publico.ta_11_fecha_desc

**Ubicación:** Base de datos `mercados`, esquema `publico`

**Columnas:**

| Columna          | Tipo      | Descripción                           |
|------------------|-----------|---------------------------------------|
| mes              | SMALLINT  | Número del mes (1-12)                 |
| fecha_descuento  | DATE      | Fecha límite para aplicar descuento   |
| fecha_recargos   | DATE      | Fecha a partir de la cual hay recargos|
| fecha_alta       | TIMESTAMP | Fecha/hora de última modificación     |
| id_usuario       | INTEGER   | ID del usuario que realizó el cambio  |

**Registros esperados:** 12 (uno por cada mes del año)

**Join con tabla usuarios:** `public.usuarios` (columna: usuario)

---

## 3. DETALLE DE STORED PROCEDURES

### 3.1. fechas_descuento_get_all()

**Propósito:** Lista todas las fechas de descuento configuradas por mes.

**Parámetros:** Ninguno

**Retorna:**

| Columna          | Tipo         | Descripción                          |
|------------------|--------------|--------------------------------------|
| mes              | SMALLINT     | Número del mes (1-12)                |
| fecha_descuento  | DATE         | Fecha límite de descuento            |
| fecha_recargos   | DATE         | Fecha inicio de recargos             |
| fecha_alta       | TIMESTAMP    | Última modificación                  |
| id_usuario       | INTEGER      | ID del usuario                       |
| usuario          | VARCHAR(50)  | Nombre del usuario (de tabla usuarios)|

**Ordenamiento:** Por mes ASC (1 a 12)

**SQL:**
```sql
SELECT
    a.mes,
    a.fecha_descuento,
    a.fecha_recargos,
    a.fecha_alta,
    a.id_usuario,
    COALESCE(b.usuario, 'SISTEMA')::VARCHAR(50) as usuario
FROM publico.ta_11_fecha_desc a
LEFT JOIN public.usuarios b ON a.id_usuario = b.id
ORDER BY a.mes ASC;
```

**Ejemplos de uso:**

```sql
-- Listar todas las fechas
SELECT * FROM fechas_descuento_get_all();

-- Usando alias
SELECT * FROM sp_fechadescuento_list();

-- Filtrar un mes específico
SELECT * FROM fechas_descuento_get_all() WHERE mes = 1;

-- Obtener solo fechas de Q1
SELECT * FROM fechas_descuento_get_all() WHERE mes BETWEEN 1 AND 3;
```

**Resultado esperado:**
```
 mes | fecha_descuento | fecha_recargos | fecha_alta          | id_usuario | usuario
-----+-----------------+----------------+---------------------+------------+----------
  1  | 2025-01-05      | 2025-01-10     | 2025-01-15 10:30:00 |     1      | ADMIN
  2  | 2025-02-05      | 2025-02-10     | 2025-01-15 10:30:00 |     1      | ADMIN
  3  | 2025-03-05      | 2025-03-10     | 2025-01-15 10:30:00 |     1      | ADMIN
 ...
 12  | 2025-12-05      | 2025-12-10     | 2025-01-15 10:30:00 |     1      | ADMIN
```

---

### 3.2. fechas_descuento_update()

**Propósito:** Actualiza las fechas de descuento y recargos de un mes específico. Si el mes no existe, lo crea automáticamente.

**Parámetros:**

| Parámetro         | Tipo      | Descripción                           | Requerido |
|-------------------|-----------|---------------------------------------|-----------|
| p_mes             | SMALLINT  | Número del mes (1-12)                 | Sí        |
| p_fecha_descuento | DATE      | Nueva fecha de descuento              | Sí        |
| p_fecha_recargos  | DATE      | Nueva fecha de recargos               | Sí        |
| p_id_usuario      | INTEGER   | ID del usuario que hace el cambio     | Sí        |

**Retorna:**

| Columna  | Tipo    | Descripción                              |
|----------|---------|------------------------------------------|
| success  | BOOLEAN | true si fue exitoso, false si hubo error |
| message  | TEXT    | Mensaje descriptivo del resultado        |

**Validaciones:**
- El mes debe estar entre 1 y 12
- Si el mes no existe, lo crea
- Si el mes existe, lo actualiza
- Actualiza automáticamente fecha_alta con NOW()

**Lógica:**

1. Valida que p_mes esté entre 1 y 12
2. Verifica si el mes existe en la tabla
3. Si NO existe:
   - Inserta nuevo registro con los datos proporcionados
   - Retorna: `success=true, message='Fecha de descuento creada exitosamente'`
4. Si existe:
   - Actualiza fecha_descuento, fecha_recargos, fecha_alta, id_usuario
   - Retorna: `success=true, message='Fecha de descuento actualizada exitosamente'`

**Ejemplos de uso:**

```sql
-- Actualizar mes 1 (Enero)
SELECT * FROM fechas_descuento_update(1, '2025-01-05', '2025-01-10', 1);
-- Resultado: success=true, message='Fecha de descuento actualizada exitosamente'

-- Crear mes 6 (si no existe)
SELECT * FROM fechas_descuento_update(6, '2025-06-05', '2025-06-10', 2);
-- Resultado: success=true, message='Fecha de descuento creada exitosamente'

-- Usando alias
SELECT * FROM sp_fechadescuento_update(12, '2025-12-05', '2025-12-15', 1);

-- Validación de mes inválido
SELECT * FROM fechas_descuento_update(13, '2025-12-05', '2025-12-10', 1);
-- Resultado: success=false, message='El mes debe estar entre 1 y 12'

-- Verificar el cambio
SELECT * FROM fechas_descuento_get_all() WHERE mes = 1;
```

**Respuestas posibles:**

| Success | Message                                      | Caso                    |
|---------|----------------------------------------------|-------------------------|
| true    | Fecha de descuento creada exitosamente       | Mes no existía          |
| true    | Fecha de descuento actualizada exitosamente  | Mes existía             |
| false   | El mes debe estar entre 1 y 12               | Validación de mes falló |

---

## 4. ESQUEMAS ENCONTRADOS Y CORRECCIONES

### Problema Detectado:

Los SPs en el archivo consolidado original (`53_SP_MERCADOS_FECHADESCUENTO_EXACTO_all_procedures.sql`) usaban esquemas incorrectos:

- ❌ **Esquema incorrecto:** `padron_licencias.comun.ta_11_fecha_desc`
- ❌ **Join incorrecto:** `padron_licencias.comun.ta_12_passwords`

### Corrección Aplicada:

- ✅ **Esquema correcto:** `publico.ta_11_fecha_desc`
- ✅ **Join correcto:** `public.usuarios`

Esta corrección está basada en:
1. Análisis de otros SPs del sistema que usan el mismo esquema
2. Archivos individuales que ya usaban el esquema correcto
3. SPs de reportes que hacen join con `public.ta_11_fecha_desc`

**Referencias encontradas:**
- `RefactorX/Base/mercados/database/ok/63_SP_MERCADOS_PADRONGLOBAL_EXACTO_all_procedures.sql` - Línea 84
- `RefactorX/Base/mercados/database/ok/80_SP_MERCADOS_RPTADEUDOSLOCALES_EXACTO_all_procedures.sql` - Línea 76
- `RefactorX/Base/mercados/database/database/FechaDescuento_sp_fechadescuento_list.sql` - Línea 21

---

## 5. ARCHIVOS GENERADOS

### 5.1. Archivo Principal

**Archivo:** `C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\fechas_descuento_all_sps_FINAL.sql`

**Contenido:**
- Ambos SPs principales
- Ambos alias de compatibilidad
- Comentarios SQL
- Ejemplos de uso
- Configuración de base de datos

**Uso:**
```bash
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f fechas_descuento_all_sps_FINAL.sql
```

### 5.2. Archivos de Referencia Existentes

1. **FechaDescuento_sp_fechadescuento_list.sql** - SP individual (esquema correcto)
2. **FechaDescuento_sp_fechadescuento_update.sql** - SP individual (esquema correcto)
3. **53_SP_MERCADOS_FECHADESCUENTO_EXACTO_all_procedures.sql** - Consolidado (esquema incorrecto)

---

## 6. INTEGRACIÓN CON SISTEMA

### 6.1. Uso desde Laravel/PHP

```php
// Listar todas las fechas
$fechas = DB::select("SELECT * FROM fechas_descuento_get_all()");

// Actualizar fecha
$result = DB::select(
    "SELECT * FROM fechas_descuento_update(?, ?::DATE, ?::DATE, ?)",
    [1, '2025-01-05', '2025-01-10', auth()->id()]
);

if ($result[0]->success) {
    return response()->json([
        'success' => true,
        'message' => $result[0]->message
    ]);
}
```

### 6.2. Uso desde Vue/Frontend

```javascript
// API Service
async getFechasDescuento() {
  const response = await apiService.call('FechasDescuento', 'list');
  return response.data;
}

async updateFechaDescuento(mes, fechaDescuento, fechaRecargos) {
  const response = await apiService.call('FechasDescuento', 'update', {
    mes,
    fecha_descuento: fechaDescuento,
    fecha_recargos: fechaRecargos,
    id_usuario: store.getters['auth/userId']
  });
  return response.data;
}
```

### 6.3. Controller Laravel Sugerido

```php
<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FechasDescuentoController extends GenericController
{
    public function list(Request $request)
    {
        try {
            $fechas = DB::select("SELECT * FROM fechas_descuento_get_all()");

            return response()->json([
                'success' => true,
                'data' => $fechas
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'mes' => 'required|integer|min:1|max:12',
            'fecha_descuento' => 'required|date',
            'fecha_recargos' => 'required|date',
            'id_usuario' => 'required|integer'
        ]);

        try {
            $result = DB::select(
                "SELECT * FROM fechas_descuento_update(?, ?::DATE, ?::DATE, ?)",
                [
                    $validated['mes'],
                    $validated['fecha_descuento'],
                    $validated['fecha_recargos'],
                    $validated['id_usuario']
                ]
            );

            return response()->json([
                'success' => $result[0]->success,
                'message' => $result[0]->message
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
```

---

## 7. CASOS DE USO Y ESCENARIOS

### 7.1. Inicialización del Sistema

Si la tabla está vacía, crear los 12 meses con fechas por defecto:

```sql
-- Insertar todos los meses (Enero a Diciembre)
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..12 LOOP
        PERFORM fechas_descuento_update(
            i::SMALLINT,
            ('2025-' || LPAD(i::TEXT, 2, '0') || '-05')::DATE,
            ('2025-' || LPAD(i::TEXT, 2, '0') || '-10')::DATE,
            1
        );
    END LOOP;
END $$;

-- Verificar
SELECT * FROM fechas_descuento_get_all();
```

### 7.2. Actualización Mensual

```sql
-- Actualizar solo el mes actual (ejemplo: Enero)
SELECT * FROM fechas_descuento_update(1, '2026-01-05', '2026-01-10', 1);

-- Verificar cambio
SELECT * FROM fechas_descuento_get_all() WHERE mes = 1;
```

### 7.3. Actualización Masiva por Trimestre

```sql
-- Q1: Enero, Febrero, Marzo
SELECT * FROM fechas_descuento_update(1, '2026-01-05', '2026-01-10', 1);
SELECT * FROM fechas_descuento_update(2, '2026-02-05', '2026-02-10', 1);
SELECT * FROM fechas_descuento_update(3, '2026-03-05', '2026-03-10', 1);

-- Verificar
SELECT * FROM fechas_descuento_get_all() WHERE mes BETWEEN 1 AND 3;
```

### 7.4. Auditoría de Cambios

```sql
-- Ver quién modificó qué y cuándo
SELECT
    mes,
    fecha_descuento,
    fecha_recargos,
    fecha_alta,
    usuario
FROM fechas_descuento_get_all()
ORDER BY fecha_alta DESC;
```

---

## 8. PRUEBAS RECOMENDADAS

### 8.1. Prueba de Creación

```sql
-- Limpiar tabla (solo en desarrollo)
DELETE FROM publico.ta_11_fecha_desc;

-- Crear mes 1
SELECT * FROM fechas_descuento_update(1, '2025-01-05', '2025-01-10', 1);
-- Esperado: success=true, message='Fecha de descuento creada exitosamente'

-- Verificar
SELECT * FROM fechas_descuento_get_all();
-- Esperado: 1 registro con mes=1
```

### 8.2. Prueba de Actualización

```sql
-- Actualizar mes 1
SELECT * FROM fechas_descuento_update(1, '2025-01-06', '2025-01-11', 2);
-- Esperado: success=true, message='Fecha de descuento actualizada exitosamente'

-- Verificar
SELECT * FROM fechas_descuento_get_all() WHERE mes = 1;
-- Esperado: fecha_descuento='2025-01-06', fecha_recargos='2025-01-11'
```

### 8.3. Prueba de Validación

```sql
-- Mes inválido (< 1)
SELECT * FROM fechas_descuento_update(0, '2025-01-05', '2025-01-10', 1);
-- Esperado: success=false, message='El mes debe estar entre 1 y 12'

-- Mes inválido (> 12)
SELECT * FROM fechas_descuento_update(13, '2025-01-05', '2025-01-10', 1);
-- Esperado: success=false, message='El mes debe estar entre 1 y 12'
```

### 8.4. Prueba de Join con Usuarios

```sql
-- Insertar usuario de prueba (si no existe)
INSERT INTO public.usuarios (id, usuario)
VALUES (999, 'TEST_USER')
ON CONFLICT (id) DO NOTHING;

-- Actualizar con usuario de prueba
SELECT * FROM fechas_descuento_update(6, '2025-06-05', '2025-06-10', 999);

-- Verificar que aparezca el usuario
SELECT * FROM fechas_descuento_get_all() WHERE mes = 6;
-- Esperado: usuario='TEST_USER'
```

---

## 9. COMANDOS DE DESPLIEGUE

### 9.1. Usando psql (Recomendado)

```bash
# Configurar password
export PGPASSWORD='FF)-BQk2'

# Ejecutar archivo SQL
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f fechas_descuento_all_sps_FINAL.sql

# Verificar creación
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -c "\df fechas_descuento*"
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -c "\df sp_fechadescuento*"
```

### 9.2. Usando script PHP (Si hay drivers)

```bash
php verify_and_create_fechas_descuento_sps.php
```

### 9.3. Verificación Post-Despliegue

```bash
# Listar funciones creadas
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -c "
    SELECT routine_name, routine_type
    FROM information_schema.routines
    WHERE routine_name LIKE '%fechadescuento%'
    OR routine_name LIKE '%fechas_descuento%';
"

# Probar SP de listado
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -c "
    SELECT * FROM fechas_descuento_get_all();
"

# Probar SP de actualización
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -c "
    SELECT * FROM fechas_descuento_update(1, '2025-12-05', '2025-12-10', 1);
"
```

---

## 10. MIGRACIÓN DESDE ESQUEMAS ANTERIORES

Si los SPs antiguos usan `padron_licencias.comun.ta_11_fecha_desc`:

### Opción A: Migrar Datos

```sql
-- Copiar datos del esquema antiguo al nuevo
INSERT INTO publico.ta_11_fecha_desc (mes, fecha_descuento, fecha_recargos, fecha_alta, id_usuario)
SELECT mes, fecha_descuento, fecha_recargos, fecha_alta, id_usuario
FROM padron_licencias.comun.ta_11_fecha_desc
ON CONFLICT (mes) DO UPDATE SET
    fecha_descuento = EXCLUDED.fecha_descuento,
    fecha_recargos = EXCLUDED.fecha_recargos,
    fecha_alta = EXCLUDED.fecha_alta,
    id_usuario = EXCLUDED.id_usuario;
```

### Opción B: Crear Vista de Compatibilidad

```sql
-- Vista en esquema antiguo que apunta al nuevo
CREATE OR REPLACE VIEW padron_licencias.comun.ta_11_fecha_desc AS
SELECT * FROM publico.ta_11_fecha_desc;
```

---

## 11. TROUBLESHOOTING

### Problema: SP no encuentra la tabla

**Error:** `relation "publico.ta_11_fecha_desc" does not exist`

**Solución:**
```sql
-- Verificar esquemas
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'ta_11_fecha_desc';

-- Ajustar el SP al esquema correcto
```

### Problema: Join con usuarios falla

**Error:** `relation "public.usuarios" does not exist`

**Solución:**
```sql
-- Buscar tabla usuarios
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'usuarios';

-- Verificar columnas
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'usuarios'
AND table_schema = 'public';
```

### Problema: No hay datos en la tabla

**Solución:**
```sql
-- Inicializar los 12 meses
SELECT fechas_descuento_update(1, '2025-01-05', '2025-01-10', 1);
SELECT fechas_descuento_update(2, '2025-02-05', '2025-02-10', 1);
-- ... continuar para todos los meses
```

---

## 12. CONCLUSIONES

✅ **Stored Procedures creados y listos para usar**
- Nombres actualizados y estandarizados
- Alias para compatibilidad con código anterior
- Esquemas corregidos según el estándar del sistema

✅ **Funcionalidad completa**
- Listado de todas las fechas (12 meses)
- Actualización e inserción automática
- Validaciones incluidas
- Join con tabla de usuarios para auditoría

✅ **Integración con sistema existente**
- Compatible con GenericController de Laravel
- Listo para uso desde Vue.js
- Documentación completa de ejemplos

✅ **Archivos entregables**
- `fechas_descuento_all_sps_FINAL.sql` - Archivo de despliegue
- `INFORME_FECHAS_DESCUENTO.md` - Este documento

---

## 13. PRÓXIMOS PASOS RECOMENDADOS

1. ✅ **Desplegar SPs** usando el archivo SQL generado
2. ✅ **Probar SPs** con datos reales de la base de datos
3. ⏭️ **Crear componente Vue** para el mantenimiento de fechas
4. ⏭️ **Registrar rutas** en Laravel (api.php)
5. ⏭️ **Actualizar sidebar** con opción de menú
6. ⏭️ **Crear tests unitarios** para validar funcionalidad

---

**Fin del Informe**

_Generado el 2025-12-03 para el proyecto RecodeGDL - Sistema de Mercados_
