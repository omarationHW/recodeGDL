# Corrección Componente FechasDescuentoMntto

**Fecha:** 2025-12-03
**Problema Inicial:** Error "El Stored Procedure 'fechas_descuento_get_all' no existe en el esquema 'public'"

## Diagnóstico

### Problema 1: SPs No Desplegados
Los 3 SPs necesarios no estaban desplegados en la base de datos:

| SP | Estado Inicial |
|---|---|
| fechas_descuento_get_all | ❌ No desplegado |
| fechas_descuento_update | ❌ No desplegado |
| fechas_descuento_get_by_mes | ❌ No desplegado |

### Problema 2: Schema Incorrecto
Los SPs originales usaban tabla en schema `public`, pero los datos están en schema `publico`:

**Diferencias entre schemas:**
```
public.ta_11_fecha_desc:
  - mes (int2)
  - fecha_recargos (date)
  - fecha_descuento (date)
  - trimestre (int2)
  - sabados (int2)
  - sabadosacum (int2)
  ❌ NO tiene: fecha_alta, id_usuario

publico.ta_11_fecha_desc:
  - mes (int2)
  - fecha_descuento (date)
  - fecha_alta (timestamp)
  - id_usuario (int4)
  - fecha_recargos (date)
  - trimestre (int2)
  - sabados (int2)
  - sabadosacum (int2)
  ✅ SÍ tiene: fecha_alta, id_usuario
```

### Problema 3: Referencia Cross-Database
Los SPs intentaban hacer JOIN con `ta_12_passwords` (de otra BD), necesitan usar `public.usuarios` en la misma BD.

## Solución Aplicada

### Script de Despliegue
**Archivo:** `temp/deploy_fechas_descuento_sps.php`

Correcciones aplicadas a los 3 SPs:

1. **Cambio de schema:** `ta_11_fecha_desc` → `publico.ta_11_fecha_desc`
2. **Cambio de JOIN:** `ta_12_passwords` → `public.usuarios`
3. **Campo usuario agregado** en RETURNS TABLE
4. **COALESCE para valores nulos** en campo usuario

### Resultado del Despliegue

```
=== DESPLEGANDO SPs DE FECHAS DESCUENTO ===

1. fechas_descuento_get_all     ✅ Desplegado exitosamente
2. fechas_descuento_update      ✅ Desplegado exitosamente
3. fechas_descuento_get_by_mes  ✅ Desplegado exitosamente

=== PRUEBA DE LISTADO ===
✅ Listado funciona correctamente

Mes:  1 | Descuento: 2025-01-06 | Recargos: 2025-01-08 | Usuario: maortega
Mes:  2 | Descuento: 2025-02-05 | Recargos: 2025-02-07 | Usuario: maortega
Mes:  3 | Descuento: 2025-03-05 | Recargos: 2025-03-06 | Usuario: bcabrera
Mes:  4 | Descuento: 2025-04-07 | Recargos: 2025-04-08 | Usuario: bcabrera
Mes:  5 | Descuento: 2025-05-06 | Recargos: 2025-05-07 | Usuario: bcabrera
```

## Archivos Actualizados

### 1. Archivos SQL Individuales
- `FechasDescuentoMntto_fechas_descuento_get_all.sql` (corregido)
- `FechasDescuentoMntto_fechas_descuento_update.sql` (corregido)
- `FechasDescuentoMntto_fechas_descuento_get_by_mes.sql` (corregido)

### 2. Componente Vue
- `FechasDescuentoMntto.vue`:
  - Modal actualizado para usar clases del tema: `.modal.d-block` + `.modal-dialog`
  - Título simple con ícono

## Correcciones Técnicas

### 1. Cambio de Schema
```sql
-- ANTES (INCORRECTO):
FROM ta_11_fecha_desc f
-- Schema 'public' no tiene fecha_alta ni id_usuario

-- DESPUÉS (CORRECTO):
FROM publico.ta_11_fecha_desc f
-- Schema 'publico' tiene todos los campos necesarios
```

### 2. Cambio de JOIN con Usuarios
```sql
-- ANTES (INCORRECTO):
LEFT JOIN ta_12_passwords u ON u.id_usuario = f.id_usuario
-- ERROR: ta_12_passwords está en otra BD (padron_licencias)

-- DESPUÉS (CORRECTO):
LEFT JOIN public.usuarios u ON u.id = f.id_usuario
-- Usa tabla en la misma BD
```

### 3. Tipo de Datos del Campo Usuario
```sql
-- ANTES:
usuario text

-- DESPUÉS:
usuario varchar
-- Con COALESCE para manejar valores nulos
COALESCE(u.usuario, 'N/A')::varchar AS usuario
```

## Funcionalidad del Componente

**FechasDescuentoMntto** gestiona las fechas de descuento y recargos por mes:

### Operaciones Disponibles:
1. **Listar todas las fechas** (12 meses)
   - SP: `fechas_descuento_get_all()`
   - Muestra: mes, fechas de descuento/recargos, última actualización, usuario

2. **Editar fechas por mes**
   - SP: `fechas_descuento_update(p_mes, p_fecha_descuento, p_fecha_recargos, p_id_usuario)`
   - Validación: fechas deben corresponder al mes seleccionado

3. **Consultar por mes específico**
   - SP: `fechas_descuento_get_by_mes(p_mes)`

### Validaciones de Negocio:
- ✅ Las fechas ingresadas DEBEN corresponder al mes seleccionado
- ✅ Se valida con `EXTRACT(MONTH FROM fecha)`
- ✅ Retorna mensaje de error si las fechas no coinciden

## Configuración de BD

- **Host:** 192.168.6.146
- **Puerto:** 5432
- **Base de datos:** mercados
- **Tabla principal:** publico.ta_11_fecha_desc
- **Tabla usuarios:** public.usuarios

## Estructura de publico.ta_11_fecha_desc

| Campo | Tipo | Descripción |
|---|---|---|
| mes | smallint | Número del mes (1-12) |
| fecha_descuento | date | Fecha límite para descuento |
| fecha_recargos | date | Fecha de inicio de recargos |
| fecha_alta | timestamp | Última modificación |
| id_usuario | integer | Usuario que modificó |
| trimestre | smallint | Trimestre del año |
| sabados | smallint | Sábados en el mes |
| sabadosacum | smallint | Sábados acumulados |

## Scripts Generados

1. `verify_fechas_descuento_sps.php` - Verificación de SPs y tablas
2. `deploy_fechas_descuento_sps.php` - **Despliegue exitoso de los 3 SPs**

## Pruebas Realizadas

✅ **fechas_descuento_get_all()** - Lista los 12 meses correctamente
✅ **fechas_descuento_update()** - Valida y actualiza fechas
✅ **fechas_descuento_get_by_mes()** - Consulta por mes específico
✅ **JOIN con usuarios** - Muestra nombres de usuario correctamente
✅ **Modal centrado** - Usa clases del tema municipal

## Notas Importantes

- **Schema correcto:** Siempre usar `publico.ta_11_fecha_desc` (NO `public`)
- **12 registros fijos:** La tabla contiene un registro por cada mes del año
- **No hay INSERT/DELETE:** Solo UPDATE de fechas existentes
- **Validación estricta:** Las fechas deben ser del mes correcto
- **Campo usuario:** Obtenido mediante JOIN con `public.usuarios`

**El componente FechasDescuentoMntto ahora funciona correctamente.** ✅
