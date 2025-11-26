# Guía de Pruebas - Bloqueo de Multas

## Funcionalidades Implementadas

El módulo **BloqueoMulta.vue** permite:
1. **Buscar multas** por cuenta/folio y ejercicio
2. **Ver detalles** de las multas
3. **Bloquear multas** vigentes (cambia estatus de 'V' a 'B')
4. **Desbloquear multas** bloqueadas (cambia estatus de 'B' a 'V')

## Acceso al Módulo

**URL:** http://localhost:3000/multas_reglamentos/bloqueo-multa

## Stored Procedures Utilizados

| SP | Propósito | Parámetros |
|---|---|---|
| `recaudadora_bloqueo_multa` | Lista multas vigentes/bloqueadas | cuenta, ejercicio, offset, limit |
| `recaudadora_bloquear_multa` | Bloquea una multa | cvereq, motivo, capturista |
| `recaudadora_desbloquear_multa` | Desbloquea una multa | cvereq, motivo, capturista |

## Casos de Prueba

### 📋 PRUEBA 1: Buscar Multas
**Objetivo:** Verificar que el sistema carga multas correctamente

**Pasos:**
1. Abrir http://localhost:3000/multas_reglamentos/bloqueo-multa
2. En el campo **Año**, ingresar el año actual (ej: 2025)
3. Dejar el campo **Cuenta** vacío para ver todas las multas
4. Hacer clic en **Buscar**

**Resultado esperado:**
- Se muestra una tabla con multas del año especificado
- Cada fila muestra: Folio, Año, Multa, Total, Estatus, Acciones
- Las multas vigentes tienen badge verde "✓ Vigente"
- Las multas bloqueadas tienen badge rojo "🔒 Bloqueado"

---

### 🔍 PRUEBA 2: Buscar por Folio Específico
**Objetivo:** Verificar filtrado por cuenta/folio

**Pasos:**
1. En el campo **Cuenta**, ingresar un número de folio (ej: 12345)
2. En el campo **Año**, ingresar el año (ej: 2024)
3. Presionar **Enter** o hacer clic en **Buscar**

**Resultado esperado:**
- Se muestran solo las multas que contienen ese número de folio
- El filtro busca coincidencias parciales (LIKE '%folio%')

---

### 👁️ PRUEBA 3: Ver Detalles de Multa
**Objetivo:** Verificar que el modal de detalle muestra toda la información

**Pasos:**
1. Buscar multas (PRUEBA 1 o 2)
2. Hacer clic en el botón del ojo (👁️) en cualquier multa
3. Revisar la información mostrada

**Resultado esperado:**
- Se abre un modal con el título "Detalle de Multa"
- Se muestra:
  - Folio: [folio]/[ejercicio]
  - ID Multa
  - Fecha Emisión
  - Multa: $[monto]
  - Gastos: $[monto]
  - Total: $[monto]
  - Estatus
  - Observaciones (si existen)

---

### 🔒 PRUEBA 4: Bloquear una Multa Vigente
**Objetivo:** Verificar que se puede bloquear una multa

**Pre-requisito:** Tener al menos una multa con estatus "Vigente"

**Pasos:**
1. Buscar una multa con badge verde "✓ Vigente"
2. Hacer clic en el botón amarillo de bloquear (🔒)
3. Se abre el modal "Bloquear Multa"
4. Verificar que muestra el folio correcto
5. En el campo **Motivo del Bloqueo**, ingresar:
   ```
   Prueba de bloqueo - Revisión administrativa pendiente
   ```
6. Hacer clic en el botón **Bloquear**

**Resultado esperado:**
- Aparece mensaje de éxito: "Multa bloqueada exitosamente"
- El modal se cierra automáticamente
- La tabla se recarga
- La multa ahora aparece con badge rojo "🔒 Bloqueado"
- El botón de acción cambió de amarillo (bloquear) a verde (desbloquear)

**Verificación en BD:**
```sql
-- Ver el cambio de estatus
SELECT cvereq, folioreq, axoreq, vigencia, obs
FROM catastro_gdl.reqmultas
WHERE folioreq = [FOLIO] AND axoreq = [AÑO];
-- vigencia debe ser 'B'
```

---

### 🔓 PRUEBA 5: Desbloquear una Multa Bloqueada
**Objetivo:** Verificar que se puede desbloquear una multa

**Pre-requisito:** Tener una multa bloqueada (usar PRUEBA 4 primero)

**Pasos:**
1. Buscar la multa que bloqueaste en PRUEBA 4
2. Hacer clic en el botón verde de desbloquear (🔓)
3. Se abre el modal "Desbloquear Multa"
4. Verificar que muestra el folio correcto
5. En el campo **Motivo del Desbloqueo**, ingresar:
   ```
   Prueba de desbloqueo - Revisión completada
   ```
6. Hacer clic en el botón **Desbloquear**

**Resultado esperado:**
- Aparece mensaje de éxito: "Multa desbloqueada exitosamente"
- El modal se cierra automáticamente
- La tabla se recarga
- La multa vuelve a aparecer con badge verde "✓ Vigente"
- El botón de acción volvió a ser amarillo (bloquear)

**Verificación en BD:**
```sql
-- Ver el cambio de estatus
SELECT cvereq, folioreq, axoreq, vigencia, obs
FROM catastro_gdl.reqmultas
WHERE folioreq = [FOLIO] AND axoreq = [AÑO];
-- vigencia debe ser 'V'
```

---

### ❌ PRUEBA 6: Validación de Motivo Requerido
**Objetivo:** Verificar que el sistema no permite bloquear/desbloquear sin motivo

**Pasos:**
1. Intentar bloquear una multa vigente
2. Dejar el campo **Motivo del Bloqueo** vacío
3. Intentar hacer clic en **Bloquear**

**Resultado esperado:**
- El botón **Bloquear** está deshabilitado (gris)
- No se puede hacer clic hasta escribir algo en el campo motivo

---

### 🔄 PRUEBA 7: Paginación
**Objetivo:** Verificar que la paginación funciona correctamente

**Pasos:**
1. Buscar multas sin filtro de cuenta para obtener muchos resultados
2. Cambiar el selector "Mostrar" a 10, 25 o 50 registros
3. Usar las flechas de navegación (< >) para cambiar de página

**Resultado esperado:**
- El contador muestra "Mostrando X a Y de Z"
- Al cambiar de página, se cargan los siguientes registros
- La flecha izquierda (◁) está deshabilitada en la primera página
- La flecha derecha (▷) está deshabilitada en la última página

---

### ⚡ PRUEBA 8: Búsqueda con Enter
**Objetivo:** Verificar que la búsqueda funciona al presionar Enter

**Pasos:**
1. Escribir un número de cuenta
2. Presionar **Enter** (sin hacer clic en Buscar)

**Resultado esperado:**
- La búsqueda se ejecuta automáticamente
- Se cargan los resultados del filtro

---

## Ejemplos de Datos para Probar

### Ejemplo 1: Buscar por Año
```
Cuenta: [dejar vacío]
Año: 2024
```

### Ejemplo 2: Buscar Folio Específico
```
Cuenta: 1001
Año: 2024
```

### Ejemplo 3: Búsqueda Parcial
```
Cuenta: 10
Año: 2024
```
(Encontrará todos los folios que contengan "10": 10, 100, 1001, 210, etc.)

---

## Verificación de API

### Llamadas que hace el frontend:

1. **Listar multas:**
```javascript
POST http://localhost:8000/api/generic/execute
{
  "base_db": "multas_reglamentos",
  "operation": "RECAUDADORA_BLOQUEO_MULTA",
  "params": [
    {"nombre": "p_clave_cuenta", "valor": "1001", "tipo": "string"},
    {"nombre": "p_ejercicio", "valor": 2024, "tipo": "int"},
    {"nombre": "p_offset", "valor": 0, "tipo": "int"},
    {"nombre": "p_limit", "valor": 10, "tipo": "int"}
  ]
}
```

2. **Bloquear multa:**
```javascript
POST http://localhost:8000/api/generic/execute
{
  "base_db": "multas_reglamentos",
  "operation": "RECAUDADORA_BLOQUEAR_MULTA",
  "params": [
    {"nombre": "p_cvereq", "valor": 12345, "tipo": "int"},
    {"nombre": "p_motivo", "valor": "Motivo del bloqueo", "tipo": "string"},
    {"nombre": "p_capturista", "valor": "usuario", "tipo": "string"}
  ]
}
```

3. **Desbloquear multa:**
```javascript
POST http://localhost:8000/api/generic/execute
{
  "base_db": "multas_reglamentos",
  "operation": "RECAUDADORA_DESBLOQUEAR_MULTA",
  "params": [
    {"nombre": "p_cvereq", "valor": 12345, "tipo": "int"},
    {"nombre": "p_motivo", "valor": "Motivo del desbloqueo", "tipo": "string"},
    {"nombre": "p_capturista", "valor": "usuario", "tipo": "string"}
  ]
}
```

---

## Resolución de Problemas

### ❌ Error: "Sin registros"
**Causas posibles:**
1. No existen multas para ese ejercicio
2. El folio no existe
3. Solo hay multas con vigencia 'C' (Cancelada) o 'P' (Pagada)

**Solución:**
- Probar con diferentes años
- Verificar en la BD qué datos existen

### ❌ Error al bloquear/desbloquear
**Causas posibles:**
1. Los SPs `recaudadora_bloquear_multa` o `recaudadora_desbloquear_multa` no existen
2. Error en la tabla de bloqueos
3. Permisos de BD

**Solución:**
- Verificar que los SPs estén desplegados en la BD
- Revisar logs del backend

### ❌ El botón no se habilita
**Causa:**
- El campo motivo está vacío o solo tiene espacios

**Solución:**
- Escribir al menos un carácter en el campo motivo

---

## Checklist de Verificación

- [ ] ✅ El frontend carga en http://localhost:3000
- [ ] ✅ El backend responde en http://localhost:8000
- [ ] ✅ Se pueden buscar multas por año
- [ ] ✅ Se pueden buscar multas por folio
- [ ] ✅ El modal de detalle muestra la información completa
- [ ] ✅ Se puede bloquear una multa vigente
- [ ] ✅ El estatus cambia de Vigente a Bloqueado
- [ ] ✅ Se puede desbloquear una multa bloqueada
- [ ] ✅ El estatus cambia de Bloqueado a Vigente
- [ ] ✅ La validación de motivo funciona
- [ ] ✅ La paginación funciona correctamente
- [ ] ✅ La búsqueda con Enter funciona

---

## Notas Técnicas

### Tabla Principal
- **Tabla:** `catastro_gdl.reqmultas`
- **Campo clave:** `cvereq` (ID interno del requerimiento)
- **Campo vigencia:**
  - 'V' = Vigente
  - 'B' = Bloqueado
  - 'C' = Cancelada
  - 'P' = Pagada

### Campos Importantes
- `folioreq`: Número de folio visible al usuario
- `axoreq`: Año/ejercicio fiscal
- `multas`: Monto de la multa
- `gastos`: Gastos administrativos
- `total`: Suma de multa + gastos
- `obs`: Observaciones/motivo del bloqueo

### Usuario Capturista
Actualmente el sistema usa 'usuario' como valor fijo (línea 240 y 271 de BloqueoMulta.vue).
TODO: Implementar obtención del usuario autenticado.

---

## Próximos Pasos

1. **Probar con datos reales**
   - Ejecutar las pruebas 1-8
   - Documentar cualquier error encontrado

2. **Verificar integración completa**
   - Frontend → API → SP → Base de Datos
   - Confirmar que los cambios persisten

3. **Implementar mejoras pendientes**
   - Obtener usuario autenticado real
   - Agregar histórico de bloqueos/desbloqueos
   - Agregar filtro por estatus (Vigente/Bloqueado)

---

**Fecha de creación:** 2025-11-23
**Sistema:** RefactorX - Módulo Multas y Reglamentos
