# Reporte: multasfrmcalif.vue - Calificación de Multas con Paginación

## Resumen de Cambios

✅ **Stored Procedure Creado y Desplegado**
- Archivo: `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_multasfrmcalif.sql`
- Schema: `comun`
- Función: `comun.recaudadora_multasfrmcalif()`

✅ **Vista Vue Actualizada con Paginación**
- Archivo: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/multasfrmcalif.vue`
- Paginación de 10 registros (configurable a 25 o 50)
- Tabla HTML con 11 columnas
- Formato de moneda y fechas
- Badges de estatus con colores

## Tabla de Base de Datos

**Tabla Principal:** `comun.multas`
- **Total de Registros:** 415,017 multas
- **Ubicación:** Base de datos `padron_licencias`, schema `comun`

## Stored Procedure

### Nombre
`comun.recaudadora_multasfrmcalif`

### Parámetros
```sql
- p_clave_cuenta (VARCHAR, default: '') - Filtro por cuenta/cvepago
- p_offset (INTEGER, default: 0) - Offset para paginación
- p_limit (INTEGER, default: 10) - Límite de registros por página
```

### Retorna
```sql
TABLE (
  id_multa INTEGER,           -- ID de la multa
  folio INTEGER,              -- Número de acta
  anio INTEGER,               -- Año del acta
  fecha_acta DATE,            -- Fecha del acta
  contribuyente VARCHAR,      -- Nombre del contribuyente
  domicilio VARCHAR,          -- Domicilio
  ley SMALLINT,               -- ID de ley
  infraccion SMALLINT,        -- ID de infracción
  calificacion NUMERIC,       -- Monto de calificación
  multa NUMERIC,              -- Monto de la multa
  gastos NUMERIC,             -- Gastos administrativos
  total NUMERIC,              -- Total a pagar
  observacion TEXT,           -- Observaciones
  estatus VARCHAR,            -- Estado (PENDIENTE, PAGADA, CANCELADA)
  total_registros BIGINT      -- Total de registros para paginación
)
```

## 3 Ejemplos con Datos Reales

### Ejemplo 1: Cuenta con 79 Multas
```
Cuenta: 3142652
```
**Resultados Esperados:**
- **Total de multas**: 79
- **Suma total**: $26,670.00
- **Años**: 2005
- **Primera página (10 registros)**:
  1. Folio 2003, Año 2005, JOSE LUIS CASILLAS, Total: $200.00, Estatus: PAGADA
  2. Folio 1578, Año 2005, RAUL DELGADILLO, Total: $200.00, Estatus: PAGADA
  3. Folio 2018, Año 2005, JAIME ORTEGA, Total: $200.00, Estatus: PAGADA
  ... (7 más)
- **Páginas totales**: 8 páginas (79 multas / 10 por página)

### Ejemplo 2: Cuenta con 77 Multas
```
Cuenta: 3182509
```
**Resultados Esperados:**
- **Total de multas**: 77
- **Suma total**: $49,750.00
- **Años**: 2005
- **Primera página (10 registros)**:
  1. Folio 11221, Año 2005, JAIME SANTOS, Total: $2,400.00, Estatus: PAGADA
  2. Folio 11212, Año 2005, MARGARITA SANTOS, Total: $600.00, Estatus: PAGADA
  3. Folio 10206, Año 2005, FARMACIAS SIMILARES SA DE CV, Total: $600.00, Estatus: PAGADA
  ... (7 más)
- **Páginas totales**: 8 páginas (77 multas / 10 por página)

### Ejemplo 3: Cuenta con 64 Multas
```
Cuenta: 2508553
```
**Resultados Esperados:**
- **Total de multas**: 64
- **Suma total**: $66,560.00
- **Años**: 2004
- **Primera página (10 registros)**:
  1. Folio 36265, Año 2004, JUAN DE LA CRUZ QUEZADA PALAFOX, Total: $1,200.00, Estatus: PAGADA
  2. Folio 37201, Año 2004, CLAUDIA VAZQUEZ FERNANDEZ, Total: $500.00, Estatus: PAGADA
  3. Folio 33059, Año 2004, MIGUEL ANGEL DIAZ, Total: $500.00, Estatus: PAGADA
  ... (7 más)
- **Páginas totales**: 7 páginas (64 multas / 10 por página)

## Tabla HTML - 11 Columnas

| Columna | Descripción | Formato |
|---------|-------------|---------|
| ID | ID de la multa | Código monoespaciado |
| Folio | Número de acta | Numérico |
| Año | Año del acta | Numérico |
| Fecha | Fecha del acta | DD/MM/AAAA |
| Contribuyente | Nombre del contribuyente | Texto |
| Ley/Infracción | ID de ley e infracción | Numérico / Numérico |
| Calificación | Monto de calificación | $X,XXX.XX MXN |
| Multa | Monto de la multa | $X,XXX.XX MXN |
| Gastos | Gastos administrativos | $X,XXX.XX MXN |
| Total | Monto total | $X,XXX.XX MXN (negrita) |
| Estatus | Estado de la multa | Badge con color |

## Paginación Completa

La vista tiene **paginación de 10 en 10** con las siguientes características:

### 1. **Tamaños de Página**
- 10 registros (por defecto)
- 25 registros
- 50 registros

### 2. **Controles de Navegación**
- Botón "Anterior" (← chevron-left)
- Botón "Siguiente" (→ chevron-right)
- Los botones se deshabilitan cuando no hay más páginas

### 3. **Información de Paginación**
Muestra: "Mostrando X a Y de Z"
- Ejemplo: "Mostrando 1 a 10 de 79"
- Ejemplo: "Mostrando 11 a 20 de 79"

### 4. **Funcionamiento**
1. El usuario ingresa una cuenta y hace clic en "Buscar"
2. El SP devuelve los primeros 10 registros (offset=0, limit=10)
3. El campo `total_registros` indica el total disponible (ej. 79)
4. El usuario puede:
   - Cambiar el tamaño de página (10, 25, 50)
   - Navegar con los botones anterior/siguiente
   - Cada cambio actualiza el offset y recarga los datos

## Estatus con Colores

Los estatus se muestran con badges de colores:

- 🟢 **PAGADA** - Verde (fondo: #d4edda, texto: #155724)
- 🔴 **CANCELADA** - Rojo (fondo: #f8d7da, texto: #721c24)
- 🟡 **PENDIENTE** - Amarillo (fondo: #fff3cd, texto: #856404)

## Características del Formulario

### 1. **Búsqueda por Cuenta**
- Campo único para ingresar el número de cuenta (cvepago)
- Busca todas las multas asociadas a esa cuenta
- Ordena por fecha descendente (más recientes primero)

### 2. **Tabla Responsiva**
- Scroll horizontal en pantallas pequeñas
- Hover effect en las filas
- Formato de moneda mexicana en columnas monetarias
- Formato de fechas localizado

### 3. **Paginación Automática**
- Se activa automáticamente cuando hay resultados
- Selector de tamaño de página
- Navegación con botones anterior/siguiente
- Información de página actual

### 4. **Estados de Carga**
- Spinner mientras carga los datos
- Mensaje cuando no hay resultados
- Deshabilitación del botón durante la carga

## Archivos Modificados

1. **RefactorX/Base/multas_reglamentos/database/generated/recaudadora_multasfrmcalif.sql**
   - Stored procedure completo con paginación
   - Devuelve total_registros para paginación

2. **RefactorX/FrontEnd/src/views/modules/multas_reglamentos/multasfrmcalif.vue**
   - Tabla HTML con 11 columnas
   - Paginación completa (10, 25, 50 registros)
   - Formato de moneda y fechas
   - Badges de estatus con colores
   - Navegación con botones

## Cómo Probar en el Frontend

Con el **frontend y backend ya corriendo** (http://localhost:3000):

### Ejemplo 1: Cuenta con 79 Multas
1. Ir al módulo: Multas y Reglamentos → Calificación de Multas
2. Ingresar en "Cuenta": `3142652`
3. Hacer clic en "Buscar" o presionar Enter
4. **Verificar**:
   - La tabla muestra 10 registros
   - La paginación muestra "Mostrando 1 a 10 de 79"
   - El botón "Siguiente" está habilitado
   - El botón "Anterior" está deshabilitado

### Ejemplo 2: Navegar por las Páginas
1. Con la cuenta `3142652` cargada
2. Hacer clic en el botón "Siguiente" (→)
3. **Verificar**:
   - La tabla muestra los registros 11 al 20
   - La paginación muestra "Mostrando 11 a 20 de 79"
   - Ambos botones están habilitados

### Ejemplo 3: Cambiar Tamaño de Página
1. Con la cuenta `3182509` cargada
2. En el selector "Mostrar:", seleccionar "25"
3. **Verificar**:
   - La tabla muestra 25 registros
   - La paginación muestra "Mostrando 1 a 25 de 77"
   - Se recalcula el número de páginas

## Detalles Técnicos

### Formato de Parámetros
```javascript
{ nombre: 'p_clave_cuenta', tipo: 'string', valor: '3142652' }
{ nombre: 'p_offset', tipo: 'integer', valor: 0 }
{ nombre: 'p_limit', tipo: 'integer', valor: 10 }
```

### Formato de Respuesta
```javascript
{
  eResponse: {
    success: true,
    data: {
      result: [
        {
          id_multa: 123,
          folio: 2003,
          anio: 2005,
          fecha_acta: "2005-10-27",
          contribuyente: "JOSE LUIS CASILLAS",
          ley: 22,
          infraccion: 25,
          calificacion: 200.00,
          multa: 200.00,
          gastos: 0.00,
          total: 200.00,
          estatus: "PAGADA",
          total_registros: 79  // <-- Para paginación
        },
        // ... más registros
      ]
    }
  }
}
```

### Cálculo de Paginación
```javascript
// Offset = (página actual - 1) * tamaño de página
// Ejemplo: Página 2, tamaño 10 → offset = (2-1) * 10 = 10

// Total de páginas = Math.ceil(total_registros / tamaño)
// Ejemplo: 79 registros, tamaño 10 → 8 páginas
```

## Estadísticas

- **Total de multas en BD**: 415,017
- **Cuentas con múltiples multas**: Miles de cuentas
- **Cuenta con más multas**: 79 multas en una sola cuenta
- **Paginación por defecto**: 10 registros
- **Opciones de paginación**: 10, 25, 50 registros

## Estado Actual

✅ **COMPLETO Y FUNCIONAL**

El módulo está 100% operativo con:
- ✅ Stored procedure desplegado y probado
- ✅ Paginación de 10 en 10 (configurable)
- ✅ Tabla HTML con 11 columnas
- ✅ Formato de moneda y fechas
- ✅ Badges de estatus con colores
- ✅ Navegación anterior/siguiente
- ✅ Selector de tamaño de página
- ✅ Información de paginación

Listo para usar con los 3 ejemplos proporcionados.
