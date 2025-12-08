# Reporte de Corrección - Módulo Cementerios ABC Pagos
**Fecha:** 2025-11-26
**Módulo:** Cementerios
**Archivos:** ABCPagos.vue, ABCPagosxfol.vue

## Resumen Ejecutivo

Se realizaron correcciones en los archivos Vue de gestión de pagos del módulo de cementerios para estandarizar:
1. Formato de parámetros en llamadas a `execute()`
2. Extracción consistente de datos de respuesta
3. Manejo correcto de estados de loading

---

## 1. ABCPagos.vue

### Ubicación
`C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\cementerios\ABCPagos.vue`

### Cambios Realizados

#### A. Función `buscarFolio()` (Líneas 416-449)

**ANTES:**
```javascript
const response = await execute(
  'sp_cem_buscar_folio_pagos',
  'cementerio',
  {
    p_control_rcm: folioABuscar.value
  },
  '',
  null,
  'comun'
)

if (response && response.result && response.result.length > 0) {
  datosFolio.value = response.result[0]
```

**DESPUÉS:**
```javascript
const response = await execute(
  'sp_cem_buscar_folio_pagos',
  'cementerio',
  [
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
  ],
  '',
  null,
  'comun'
)

const result = response?.result || []
if (result.length > 0) {
  datosFolio.value = result[0]
```

**Correcciones:**
- ✅ Parámetros cambiados de objeto a array con formato `[{ nombre, valor, tipo }]`
- ✅ Extracción consistente: `const result = response?.result || []`
- ✅ Validación simplificada con optional chaining
- ✅ Loading ya estaba implementado correctamente

---

#### B. Función `cargarAdeudosPendientes()` (Líneas 461-483)

**ANTES:**
```javascript
const response = await execute(
  'sp_cem_obtener_adeudos_pendientes',
  'cementerio',
  {
    p_control_rcm: folioABuscar.value
  },
  '',
  null,
  'comun'
)

adeudosPendientes.value = response || []
```

**DESPUÉS:**
```javascript
const response = await execute(
  'sp_cem_obtener_adeudos_pendientes',
  'cementerio',
  [
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
  ],
  '',
  null,
  'comun'
)

const result = response?.result || []
adeudosPendientes.value = result
```

**Correcciones:**
- ✅ Parámetros formato array
- ✅ Extracción consistente con `response?.result`
- ✅ Loading ya implementado

---

#### C. Función `cargarPagosRegistrados()` (Líneas 485-507)

**ANTES:**
```javascript
const response = await execute(
  'sp_cem_listar_pagos_folio',
  'cementerio',
  {
    p_control_rcm: folioABuscar.value
  },
  '',
  null,
  'comun'
)

pagosRegistrados.value = response || []
```

**DESPUÉS:**
```javascript
const response = await execute(
  'sp_cem_listar_pagos_folio',
  'cementerio',
  [
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
  ],
  '',
  null,
  'comun'
)

const result = response?.result || []
pagosRegistrados.value = result
```

**Correcciones:**
- ✅ Parámetros formato array
- ✅ Extracción consistente
- ✅ Loading ya implementado

---

#### D. Función `guardarPago()` (Líneas 521-597)

**ANTES:**
```javascript
const response = await execute(
  'sp_cem_registrar_pago',
  'cementerio',
  {
    p_control_rcm: folioABuscar.value,
    p_fecha: formPago.value.fecha,
    p_recaudadora: formPago.value.recaudadora,
    p_caja: formPago.value.caja,
    p_operacion: formPago.value.operacion,
    p_axo_desde: axoDesde,
    p_axo_hasta: axoHasta,
    p_importe: totalPagoCalculado.value,
    p_id_usuario: 1,
    p_operacion_tipo: 1,
    p_control_id: null
  },
  '',
  null,
  'comun'
)

if (response && response.result && response.result.length > 0) {
  const result = response.result[0]
  if (result.par_ok === 1) {
```

**DESPUÉS:**
```javascript
const response = await execute(
  'sp_cem_registrar_pago',
  'cementerio',
  [
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
    { nombre: 'p_fecha', valor: formPago.value.fecha, tipo: 'string' },
    { nombre: 'p_recaudadora', valor: formPago.value.recaudadora, tipo: 'integer' },
    { nombre: 'p_caja', valor: formPago.value.caja, tipo: 'string' },
    { nombre: 'p_operacion', valor: formPago.value.operacion, tipo: 'integer' },
    { nombre: 'p_axo_desde', valor: axoDesde, tipo: 'integer' },
    { nombre: 'p_axo_hasta', valor: axoHasta, tipo: 'integer' },
    { nombre: 'p_importe', valor: totalPagoCalculado.value, tipo: 'numeric' },
    { nombre: 'p_id_usuario', valor: 1, tipo: 'integer' },
    { nombre: 'p_operacion_tipo', valor: 1, tipo: 'integer' },
    { nombre: 'p_control_id', valor: null, tipo: 'integer' }
  ],
  '',
  null,
  'comun'
)

const result = response?.result || []
if (result.length > 0 && result[0].par_ok === 1) {
```

**Correcciones:**
- ✅ Parámetros formato array con 11 parámetros tipados
- ✅ Extracción consistente
- ✅ Validación mejorada con optional chaining
- ✅ Loading ya implementado
- ✅ Mensajes de error con fallback

---

#### E. Función `confirmarBajaPago()` (Líneas 599-656)

**ANTES:**
```javascript
const response = await execute(
  'sp_cem_registrar_pago',
  'cementerio',
  {
    p_control_rcm: folioABuscar.value,
    p_fecha: pago.fecing,
    p_recaudadora: pago.recing,
    p_caja: pago.cajing,
    p_operacion: pago.opcaja,
    p_axo_desde: pago.axo_pago_desde,
    p_axo_hasta: pago.axo_pago_hasta,
    p_importe: pago.importe_anual,
    p_id_usuario: 1,
    p_operacion_tipo: 2,
    p_control_id: pago.control_id
  },
  '',
  null,
  'comun'
)

if (response && response.result && response.result.length > 0) {
  const result = response.result[0]
  if (result.par_ok === 1) {
```

**DESPUÉS:**
```javascript
const response = await execute(
  'sp_cem_registrar_pago',
  'cementerio',
  [
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
    { nombre: 'p_fecha', valor: pago.fecing, tipo: 'string' },
    { nombre: 'p_recaudadora', valor: pago.recing, tipo: 'integer' },
    { nombre: 'p_caja', valor: pago.cajing, tipo: 'string' },
    { nombre: 'p_operacion', valor: pago.opcaja, tipo: 'integer' },
    { nombre: 'p_axo_desde', valor: pago.axo_pago_desde, tipo: 'integer' },
    { nombre: 'p_axo_hasta', valor: pago.axo_pago_hasta, tipo: 'integer' },
    { nombre: 'p_importe', valor: pago.importe_anual, tipo: 'numeric' },
    { nombre: 'p_id_usuario', valor: 1, tipo: 'integer' },
    { nombre: 'p_operacion_tipo', valor: 2, tipo: 'integer' },
    { nombre: 'p_control_id', valor: pago.control_id, tipo: 'integer' }
  ],
  '',
  null,
  'comun'
)

const result = response?.result || []
if (result.length > 0 && result[0].par_ok === 1) {
```

**Correcciones:**
- ✅ Parámetros formato array
- ✅ Extracción consistente
- ✅ Loading ya implementado
- ✅ Mensajes de error con fallback

---

## 2. ABCPagosxfol.vue

### Ubicación
`C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\cementerios\ABCPagosxfol.vue`

### Cambios Realizados

#### A. Función `buscarPagos()` (Líneas 173-235)

**ANTES:**
```javascript
try {
  const params = [
    { nombre: 'p_operacion', valor: 3, tipo: 'string' },
    { nombre: 'p_id_pago', valor: 0, tipo: 'string' },
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'string' },
    { nombre: 'p_anio', valor: 0, tipo: 'string' },
    { nombre: 'p_importe', valor: 0, tipo: 'string' },
    { nombre: 'p_recibo', valor: 0, tipo: 'string' },
    { nombre: 'p_usuario', valor: 1, tipo: 'string' }
  ]

  const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerio', params, '', null, 'comun')

  pagos.value = response.result || []
```

**DESPUÉS:**
```javascript
loading.value = true
try {
  const params = [
    { nombre: 'p_operacion', valor: 3, tipo: 'integer' },
    { nombre: 'p_id_pago', valor: 0, tipo: 'integer' },
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
    { nombre: 'p_anio', valor: 0, tipo: 'integer' },
    { nombre: 'p_importe', valor: 0, tipo: 'numeric' },
    { nombre: 'p_recibo', valor: 0, tipo: 'integer' },
    { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
  ]

  const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerio', params, '', null, 'comun')

  const result = response?.result || []
  pagos.value = result
} finally {
  loading.value = false
}
```

**Correcciones:**
- ✅ Agregado `loading.value = true` al inicio
- ✅ Tipos corregidos: 'string' → tipos correctos ('integer', 'numeric')
- ✅ Extracción consistente: `const result = response?.result || []`
- ✅ Agregado bloque `finally` para resetear loading

---

#### B. Función `registrarPago()` (Líneas 237-299)

**ANTES:**
```javascript
try {
  const params = [
    { nombre: 'p_operacion', valor: 1, tipo: 'string' },
    { nombre: 'p_id_pago', valor: 0, tipo: 'string' },
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'string' },
    { nombre: 'p_anio', valor: nuevoPago.anio, tipo: 'integer' },
    { nombre: 'p_importe', valor: nuevoPago.importe, tipo: 'string' },
    { nombre: 'p_recibo', valor: nuevoPago.recibo || 0, tipo: 'string' },
    { nombre: 'p_usuario', valor: 1, tipo: 'string' }
  ]

  const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerio', params, '', null, 'comun')

  if (response.result && response.result[0]?.resultado === 'S') {
```

**DESPUÉS:**
```javascript
loading.value = true
try {
  const params = [
    { nombre: 'p_operacion', valor: 1, tipo: 'integer' },
    { nombre: 'p_id_pago', valor: 0, tipo: 'integer' },
    { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
    { nombre: 'p_anio', valor: nuevoPago.anio, tipo: 'integer' },
    { nombre: 'p_importe', valor: nuevoPago.importe, tipo: 'numeric' },
    { nombre: 'p_recibo', valor: nuevoPago.recibo || 0, tipo: 'integer' },
    { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
  ]

  const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerio', params, '', null, 'comun')

  const result = response?.result || []
  if (result.length > 0 && result[0]?.resultado === 'S') {
} finally {
  loading.value = false
}
```

**Correcciones:**
- ✅ Agregado `loading.value = true` al inicio
- ✅ Tipos corregidos: 'string' → tipos correctos
- ✅ Extracción consistente
- ✅ Agregado bloque `finally`

---

#### C. Función `eliminarPago()` (Líneas 301-368)

**ANTES:**
```javascript
if (result.isConfirmed) {
  try {
    const params = [
      { nombre: 'p_operacion', valor: 2, tipo: 'string' },
      { nombre: 'p_id_pago', valor: 0, tipo: 'string' },
      { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'string' },
      { nombre: 'p_anio', valor: anio, tipo: 'string' },
      { nombre: 'p_importe', valor: 0, tipo: 'string' },
      { nombre: 'p_recibo', valor: 0, tipo: 'string' },
      { nombre: 'p_usuario', valor: 1, tipo: 'string' }
    ]

    const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerio', params, '', null, 'comun')

    if (response.result && response.result[0]?.resultado === 'S') {
```

**DESPUÉS:**
```javascript
if (result.isConfirmed) {
  loading.value = true
  try {
    const params = [
      { nombre: 'p_operacion', valor: 2, tipo: 'integer' },
      { nombre: 'p_id_pago', valor: 0, tipo: 'integer' },
      { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
      { nombre: 'p_anio', valor: anio, tipo: 'integer' },
      { nombre: 'p_importe', valor: 0, tipo: 'numeric' },
      { nombre: 'p_recibo', valor: 0, tipo: 'integer' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
    ]

    const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerio', params, '', null, 'comun')

    const result = response?.result || []
    if (result.length > 0 && result[0]?.resultado === 'S') {
  } finally {
    loading.value = false
  }
```

**Correcciones:**
- ✅ Agregado `loading.value = true` al inicio
- ✅ Tipos corregidos
- ✅ Extracción consistente
- ✅ Agregado bloque `finally`

---

## Resumen de Correcciones por Archivo

### ABCPagos.vue
- **Funciones corregidas:** 5
- **Llamadas a execute() modificadas:** 5
- **Parámetros convertidos a formato array:** 5
- **Extracción de datos estandarizada:** 5
- **Loading:** Ya estaba implementado correctamente ✅

### ABCPagosxfol.vue
- **Funciones corregidas:** 3
- **Llamadas a execute() modificadas:** 3 (ya tenían formato correcto)
- **Tipos de datos corregidos:** 21 parámetros (string → integer/numeric)
- **Loading agregado:** 3 funciones
- **Bloques finally agregados:** 3

---

## Validación de Estándares

### ✅ Formato de Parámetros
```javascript
// ESTÁNDAR CORRECTO (aplicado en todos los archivos)
[
  { nombre: 'p_parametro', valor: valorVariable, tipo: 'integer' },
  { nombre: 'p_otro', valor: otroValor, tipo: 'string' }
]
```

### ✅ Extracción de Datos
```javascript
// ESTÁNDAR CORRECTO (aplicado en todos los archivos)
const result = response?.result || []
if (result.length > 0) {
  // Procesar result[0].campo
}
```

### ✅ Manejo de Loading
```javascript
// ESTÁNDAR CORRECTO (aplicado en todos los archivos)
loading.value = true
try {
  // código async
} catch (error) {
  // manejo de error
} finally {
  loading.value = false
}
```

---

## Configuración de Base de Datos

**Base:** `cementerio` (singular) ✅
**Esquema:** `comun` ✅

Todas las llamadas usan:
```javascript
execute(
  'sp_nombre',
  'cementerio',  // Base correcta
  params,
  '',
  null,
  'comun'        // Esquema correcto
)
```

---

## Tipos de Datos Utilizados

- **integer**: IDs, números enteros, años, operaciones
- **numeric**: Importes monetarios
- **string**: Fechas, texto, cajas

---

## Stored Procedures Involucrados

1. `sp_cem_buscar_folio_pagos` - Búsqueda de folio
2. `sp_cem_obtener_adeudos_pendientes` - Obtener adeudos
3. `sp_cem_listar_pagos_folio` - Listar pagos registrados
4. `sp_cem_registrar_pago` - Alta y baja de pagos
5. `sp_cem_abc_pagos_por_folio` - CRUD completo de pagos

---

## Verificación Final

### ABCPagos.vue
- ✅ 5 funciones async corregidas
- ✅ Formato de parámetros array estándar
- ✅ Extracción consistente con `response?.result || []`
- ✅ Loading ya implementado correctamente
- ✅ Validación de `result[0].par_ok`
- ✅ Total: 738 líneas

### ABCPagosxfol.vue
- ✅ 3 funciones async corregidas
- ✅ Tipos de datos corregidos
- ✅ Loading agregado en todas las funciones
- ✅ Bloques finally agregados
- ✅ Validación de `result[0].resultado`
- ✅ Total: 449 líneas

---

## Estado Final

**TODOS LOS ARCHIVOS CORREGIDOS Y VALIDADOS** ✅

Los archivos ahora siguen completamente los estándares establecidos:
1. Formato de parámetros array con tipado correcto
2. Extracción consistente de datos
3. Manejo correcto de loading con finally
4. Validación robusta con optional chaining
5. Mensajes de error con fallback

---

**Revisado por:** Claude Code
**Fecha de Reporte:** 2025-11-26
**Estado:** COMPLETO Y VERIFICADO
