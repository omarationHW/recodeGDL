# Ejemplos para Probar el Formulario Propuestatab

## Stored Procedure Creado
**Nombre:** `public.recaudadora_propuestatab(p_filtro VARCHAR)`

**Descripción:** Consulta propuestas y pagos realizados con filtro de búsqueda.

**Parámetro:**
- `p_filtro`: Filtro de búsqueda (puede ser número de cuenta, folio, recaudadora, caja o cajero)

## Base de Datos
- **Host:** 192.168.6.146
- **Database:** padron_licencias
- **Tablas utilizadas:** comun.pagos

## Estadísticas de la Base de Datos
- Total de pagos activos: **13,660,695 registros**
- Total de importes: **$39,985,637,336.71 MXN**
- Fecha más antigua: 0002-03-06
- Fecha más reciente: 2025-10-02

---

## 3 EJEMPLOS DE PRUEBA CON DATOS REALES

### EJEMPLO 1: Búsqueda por Número de Cuenta
**Valor a buscar:** `260676`

**Tipo:** Número de cuenta (cvecuenta)

**Descripción:** Busca todos los pagos asociados a la cuenta 260676

**Resultado esperado:**
- cvepago: 13578982
- cvecuenta: 260676
- recaud: 9
- caja: 18
- folio: 6334905
- fecha: 2025-10-02
- hora: 08:13:00
- importe: $44,229.33 MXN
- cajero: ODOO
- cveconcepto: 8
- estado: ACTIVO

---

### EJEMPLO 2: Búsqueda por Folio
**Valor a buscar:** `7530946`

**Tipo:** Número de folio

**Descripción:** Busca el pago con el folio específico 7530946

**Resultado esperado:**
- cvepago: 13878146
- cvecuenta: 395539
- recaud: 9
- caja: 24
- folio: 7530946
- fecha: 2025-08-27
- hora: 16:46:10
- importe: $2,442.00 MXN
- cajero: ODOO
- cveconcepto: 8
- estado: ACTIVO

---

### EJEMPLO 3: Búsqueda por Cajero
**Valor a buscar:** `ODOO`

**Tipo:** Nombre de cajero

**Descripción:** Busca todos los pagos realizados por el cajero ODOO

**Resultado esperado:** Múltiples registros de pagos procesados por ODOO, mostrando:
- Diferentes cuentas y folios
- Fechas variadas (2025)
- Importes diversos
- Estado: ACTIVO

---

## Características del Formulario Actualizado

### 1. Búsqueda Inteligente
- Acepta búsquedas numéricas (cuenta, folio, cvepago, recaud)
- Acepta búsquedas de texto (caja, cajero)
- Búsqueda case-insensitive para texto

### 2. Tabla con Formato
- **Columnas renombradas:**
  - cvepago → ID Pago
  - cvecuenta → Cuenta
  - recaud → Recaud.
  - caja → Caja
  - folio → Folio
  - fecha → Fecha
  - hora → Hora
  - importe → Importe (formato moneda MXN)
  - cajero → Cajero
  - cveconcepto → Concepto
  - estado → Estado (ACTIVO/CANCELADO)

### 3. Paginación (10 registros por página)
- Navegación con botones: Primera página, Anterior, Siguiente, Última página
- Botones de páginas visibles (máximo 5 a la vez)
- Indicador de registros: "Mostrando X - Y de Z"
- Página actual resaltada en azul

### 4. Formateo de Datos
- **Importes:** Formato de moneda mexicana ($X,XXX.XX MXN)
- **Fechas:** Formato localizado (DD/MM/YYYY)
- **Valores nulos:** Se muestran como "-"
- **Estado:** Calcula si el pago está ACTIVO o CANCELADO

---

## Cómo Probar

1. **Abrir el formulario:** Acceder al módulo "Propuesta Tabla" en multas_reglamentos

2. **Prueba sin filtro:**
   - Dejar el campo vacío y hacer clic en "Buscar"
   - Debe mostrar los primeros 100 registros ordenados por fecha descendente
   - Verificar que la paginación muestre 10 registros por página

3. **Prueba con Ejemplo 1:**
   - Escribir: `260676`
   - Hacer clic en "Buscar" o presionar Enter
   - Verificar que muestre el pago con cuenta 260676

4. **Prueba con Ejemplo 2:**
   - Escribir: `7530946`
   - Hacer clic en "Buscar"
   - Verificar que muestre el pago con folio 7530946

5. **Prueba con Ejemplo 3:**
   - Escribir: `ODOO`
   - Hacer clic en "Buscar"
   - Verificar que muestre múltiples pagos del cajero ODOO
   - Probar la navegación entre páginas

6. **Verificar paginación:**
   - Si hay más de 10 resultados, verificar que:
     - Los botones de paginación funcionen
     - El contador muestre correctamente "Mostrando X - Y de Z"
     - Los botones de primera/última página funcionen
     - Los botones anterior/siguiente funcionen

---

## Archivos Modificados

1. **Stored Procedure:**
   - Archivo: `temp/recaudadora_propuestatab.sql`
   - Ubicación en BD: `public.recaudadora_propuestatab(VARCHAR)`

2. **Componente Vue:**
   - Archivo: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/Propuestatab.vue`
   - Cambios: Agregada paginación, formateo de datos, y búsqueda mejorada

---

## Notas Técnicas

- El SP limita los resultados a 100 registros para optimizar el rendimiento
- La paginación se hace en el frontend (10 registros por página del total de 100)
- El filtro busca en múltiples campos simultáneamente
- Los registros se ordenan por fecha y hora descendente (más recientes primero)
- El estado se calcula basándose en el campo `cvecanc` (si tiene valor, está CANCELADO)
