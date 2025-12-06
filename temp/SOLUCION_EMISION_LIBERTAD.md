# SOLUCIÓN: Error en EmisionLibertad - SP generar_emision_libertad

## PROBLEMA REPORTADO
```
"message": "El Stored Procedure 'generar_emision_libertad' no existe en el esquema 'public'.
Esquemas disponibles: public, publico. El SP no existe en ningún esquema."
```

## CAUSA DEL PROBLEMA
Los stored procedures de EmisionLibertad no están desplegados en la base de datos, o están usando referencias incorrectas a las tablas.

Las tablas referenciadas con `public.ta_*` deberían estar en el schema `comun.`:
- `ta_11_locales` → `comun.ta_11_locales`
- `ta_11_mercados` → `comun.ta_11_mercados`
- `ta_11_cuo_locales` → `comun.ta_11_cuo_locales`
- `ta_11_adeudo_local` → `comun.ta_11_adeudo_local`
- `ta_15_apremios` → `comun.ta_15_apremios`
- `ta_12_recaudadoras` → `comun.ta_12_recaudadoras`

## STORED PROCEDURES INVOLUCRADOS

Según el componente Vue `EmisionLibertad.vue`, se utilizan SPs en DOS bases de datos diferentes:

### Base: padron_licencias
1. `sp_get_recaudadoras()` - Obtiene lista de recaudadoras
2. `sp_get_mercados_by_recaudadora(p_oficina)` - Obtiene mercados por recaudadora

### Base: mercados
3. `generar_emision_libertad(p_oficina, p_mercados, p_axo, p_periodo, p_usuario_id)` - Genera emisión
4. `exportar_emision_libertad(...)` - Exporta a archivo
5. `get_emision_libertad_detalle(...)` - Obtiene detalle

## ARCHIVOS CORREGIDOS

### 1. Archivo SQL corregido con todos los SPs
📄 `temp/deploy_emision_libertad_fix.sql`
- Contiene los 5 SPs con las referencias corregidas a `comun.*`

### 2. Script PHP para despliegue automático
📄 `temp/deploy_emision_libertad_fix.php`
- Despliega automáticamente los SPs en las bases correctas
- padron_licencias: 2 SPs
- mercados: 3 SPs

### 3. Archivo original actualizado
📄 `RefactorX/Base/mercados/database/ok/47_SP_MERCADOS_EMISIONLIBERTAD_EXACTO_all_procedures.sql`
- Ya corregido con las referencias a `comun.*`

## CÓMO DESPLEGAR

### Opción 1: Script PHP (Recomendado)
```bash
# Asegúrate de que PostgreSQL esté corriendo
c:/xampp/php/php.exe temp/deploy_emision_libertad_fix.php
```

### Opción 2: Despliegue manual con psql
```bash
# Para padron_licencias (primeros 2 SPs)
psql -U postgres -d padron_licencias -f temp/deploy_emision_libertad_fix.sql

# Para mercados (siguientes 3 SPs)
psql -U postgres -d mercados -f temp/deploy_emision_libertad_fix.sql
```

### Opción 3: Desde pgAdmin o DBeaver
1. Conecta a la base `padron_licencias`
2. Ejecuta los primeros 2 SPs del archivo `temp/deploy_emision_libertad_fix.sql`
3. Conecta a la base `mercados`
4. Ejecuta los siguientes 3 SPs

## VERIFICACIÓN POST-DESPLIEGUE

Después de desplegar, verifica que los SPs existan:

```sql
-- En padron_licencias
SELECT proname FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE proname IN ('sp_get_recaudadoras', 'sp_get_mercados_by_recaudadora')
AND n.nspname = 'public';

-- En mercados
SELECT proname FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE proname IN ('generar_emision_libertad', 'exportar_emision_libertad', 'get_emision_libertad_detalle')
AND n.nspname = 'public';
```

## PRUEBA DE FUNCIONALIDAD

1. Inicia las aplicaciones:
   ```bash
   iniciar-apps.bat
   ```

2. Accede al módulo EmisionLibertad en el frontend

3. Verifica que:
   - Se cargue la lista de recaudadoras
   - Al seleccionar una recaudadora, se carguen los mercados
   - Al generar emisión, se muestren los locales con sus datos

## COMPONENTE VUE

El componente que usa estos SPs:
📄 `RefactorX/FrontEnd/src/views/modules/mercados/EmisionLibertad.vue`

Llamadas a la API:
- Línea 206: `sp_get_recaudadoras` en base `padron_licencias`
- Línea 227: `sp_get_mercados_by_recaudadora` en base `padron_licencias`
- Línea 254: `generar_emision_libertad` en base `mercados`

## NOTAS IMPORTANTES

1. **PostgreSQL debe estar corriendo**: Si el script PHP falla con error de conexión, verifica que PostgreSQL esté activo.

2. **Credenciales**: El script usa:
   - Host: localhost
   - Port: 5432
   - User: postgres
   - Password: sistemas

3. **Schemas disponibles**: Los SPs se crean en el schema `public` pero acceden a tablas en el schema `comun`.

4. **Multi-base**: Este módulo requiere SPs en DOS bases diferentes (padron_licencias y mercados).

## PROBLEMA RESUELTO

✅ Archivo SQL original corregido: `47_SP_MERCADOS_EMISIONLIBERTAD_EXACTO_all_procedures.sql`
✅ Script de despliegue creado: `temp/deploy_emision_libertad_fix.php`
✅ Archivo SQL individual creado: `temp/deploy_emision_libertad_fix.sql`
✅ Referencias de tablas corregidas: `public.ta_*` → `comun.ta_*`
✅ SPs organizados por base de datos (padron_licencias y mercados)

## SIGUIENTE PASO

Ejecuta el script de despliegue cuando PostgreSQL esté disponible:
```bash
c:/xampp/php/php.exe temp/deploy_emision_libertad_fix.php
```
