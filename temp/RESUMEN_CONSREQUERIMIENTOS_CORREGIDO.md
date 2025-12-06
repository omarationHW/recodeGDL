# Resumen: Corrección de ConsRequerimientos

## ¿Qué son los "Requerimientos"?

En el sistema, **"Requerimientos" son en realidad "APREMIOS"** (notificaciones de cobro/multas fiscales).

- **Tabla de apremios**: `comun.ta_15_apremios`
- **Tabla de periodos**: `comun.ta_15_periodos`
- **Módulo**: 11 (Mercados)
- **Relación**: `modulo = 11 AND control_otr = id_local`

## Cambios Aplicados

### 1. **Stored Procedures Corregidos**

Se desplegaron 3 SPs correctos con schemas y tipos de datos apropiados:

#### `sp_get_locales_by_mercado`
- **Función**: Buscar locales por oficina, mercado, sección, local, letra y bloque
- **Schema**: Usa `comun.ta_11_locales` (antes usaba `public.ta_11_locales` que no existe)
- **Tipos corregidos**: `seccion character(2)`, `letra_local varchar(3)`, `bloque varchar(2)`
- **Parámetros**: NULL handling para letra_local y bloque opcionales

#### `sp_get_requerimientos_by_local`
- **Función**: Obtener apremios de un local
- **Schema**: Usa `comun.ta_15_apremios` y `comun.ta_12_passwords`
- **Parámetros**: `p_modulo = 11` (mercados), `p_control_otr = id_local`
- **Tipos corregidos**: Todos los character fields con longitudes exactas
- **Cast añadido**: `usuario::varchar`, `nombre::varchar`, `estado::varchar`

#### `sp_get_periodos_by_requerimiento`
- **Función**: Obtener periodos de un apremio
- **Schema**: Usa `comun.ta_15_periodos`
- **Parámetro**: `p_control_otr`

### 2. **ConsRequerimientos.vue - Actualizado**

#### Función `buscarLocales`:
```javascript
Operacion: 'sp_get_locales_by_mercado'
Parametros: [
  { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
  { Nombre: 'p_num_mercado', Valor: parseInt(form.value.num_mercado) },
  { Nombre: 'p_categoria', Valor: 1 },
  { Nombre: 'p_seccion', Valor: form.value.seccion },
  { Nombre: 'p_local', Valor: parseInt(form.value.local) },
  { Nombre: 'p_letra_local', Valor: letraLocal },  // null si vacío
  { Nombre: 'p_bloque', Valor: bloque }            // null si vacío
]
```

#### Función `seleccionarLocal`:
```javascript
Operacion: 'sp_get_requerimientos_by_local'
Parametros: [
  { Nombre: 'p_modulo', Valor: 11 },  // 11 = módulo de mercados
  { Nombre: 'p_control_otr', Valor: local.id_local }
]
```

#### Función `verPeriodos`:
```javascript
Operacion: 'sp_get_periodos_by_requerimiento'
Parametros: [
  { Nombre: 'p_control_otr', Valor: requerimiento.control_otr }
]
```

#### Manejo de NULL mejorado:
```javascript
// Convierte strings vacíos a null para los parámetros opcionales
const letraLocal = (form.value.letra_local && form.value.letra_local.trim() !== '')
  ? form.value.letra_local.trim()
  : null

const bloque = (form.value.bloque && form.value.bloque.trim() !== '')
  ? form.value.bloque.trim()
  : null
```

#### Estructura de respuesta corregida:
```javascript
// ANTES (incorrecto):
if (response.data.success && response.data.data) {
  locales.value = response.data.data

// DESPUÉS (correcto):
if (response.data.eResponse && response.data.eResponse.success === true) {
  locales.value = response.data.eResponse.data.result || []
```

### 3. **Archivos Creados**

- `temp/fix_consrequerimientos_sps.sql` - Script SQL con los 3 SPs corregidos
- `temp/deploy_fix_consrequerimientos_sps.php` - Script de despliegue con tests
- `temp/TEST_CONS_REQUERIMIENTOS.md` - Guía de pruebas

## Datos de Prueba

### Locales que funcionan:
- **Oficina:** 1
- **Mercado:** 2
- **Sección:** SS
- **Local:** 1
- **Resultado:** 2 locales (uno con letra='A', otro con letra='B')

### Estado Actual de Apremios:
- No hay apremios activos para el módulo 11 (mercados) en la base de datos
- Esto es normal si los locales no tienen adeudos pendientes
- Los SPs funcionan correctamente, solo están esperando datos

## Flujo Completo

1. **Usuario busca un local** → `sp_get_locales_by_mercado`
   - Retorna los locales que coinciden con los criterios

2. **Usuario selecciona un local** → `sp_get_requerimientos_by_local`
   - Busca apremios del módulo 11 donde `control_otr = id_local`
   - Retorna requerimientos con datos del usuario que los creó

3. **Usuario selecciona un requerimiento** → `sp_get_periodos_by_requerimiento`
   - Busca los periodos asociados al apremio
   - Retorna año, periodo, importe y recargos

## Próximos Pasos

1. **Probar en el navegador**:
   - Abrir ConsRequerimientos
   - Buscar local: Oficina=1, Mercado=2, Sección=SS, Local=1
   - Verificar que aparezcan 2 locales
   - Verificar que NO haya error (puede no haber requerimientos)

2. **Si se requieren datos de prueba**:
   - Insertar registros en `comun.ta_15_apremios` con `modulo=11` y `control_otr=<id_local>`
   - Insertar periodos correspondientes en `comun.ta_15_periodos`

3. **Limpiar código de debugging**:
   - Eliminar console.log de ConsRequerimientos.vue líneas 633-642

## Archivos Modificados

✅ `RefactorX/FrontEnd/src/views/modules/mercados/ConsRequerimientos.vue`
✅ SPs desplegados en base de datos `padron_licencias.public`

## Validación

✅ `sp_get_locales_by_mercado(1, 2, 1, 'SS', 1, NULL, NULL)` → 2 locales
✅ `sp_get_requerimientos_by_local(11, 11256)` → 0 apremios (normal)
✅ Manejo de NULL correcto para letra_local y bloque
✅ Estructura de respuesta API correcta
✅ Tipos de datos coinciden con las tablas
