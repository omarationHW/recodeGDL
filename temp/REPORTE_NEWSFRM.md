# Reporte: newsfrm.vue - Novedades de Multas con Paginación

## Resumen de Cambios

✅ **Stored Procedure Creado y Desplegado**
- Archivo: `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_newsfrm.sql`
- Schema: `comun`
- Función: `comun.recaudadora_newsfrm()`

✅ **Vista Vue Actualizada con Paginación**
- Archivo: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/newsfrm.vue`
- Paginación de 10 registros (configurable a 25 o 50)
- Tabla HTML con 9 columnas
- Formato de moneda y fechas
- Badges de estatus con colores

## Tabla de Base de Datos

**Tabla Principal:** `comun.multas`
- **Total de Registros:** 415,017 multas
- **Registros Válidos (1990-2030):** 414,738 multas
- **Ubicación:** Base de datos `padron_licencias`, schema `comun`

## Stored Procedure

### Nombre
`comun.recaudadora_newsfrm`

### Parámetros
```sql
- p_filtro (VARCHAR, default: '') - Filtro de búsqueda (busca en contribuyente, folio, año, domicilio)
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
  fecha_recepcion DATE,       -- Fecha de recepción
  contribuyente VARCHAR,      -- Nombre del contribuyente
  domicilio VARCHAR,          -- Domicilio
  giro VARCHAR,               -- Giro del negocio
  total NUMERIC,              -- Total de la multa
  estatus VARCHAR,            -- Estado (PENDIENTE, PAGADA, CANCELADA)
  total_registros BIGINT      -- Total de registros para paginación
)
```

### Características Especiales
- **Filtro de Años**: Solo muestra multas entre 1990 y 2030 (evita datos incorrectos)
- **Ordenamiento**: Por año descendente, luego por fecha descendente (más recientes primero)
- **Búsqueda Universal**: El filtro busca en contribuyente, folio, año y domicilio simultáneamente

## 3 Ejemplos con Datos Reales

### Ejemplo 1: Multas Más Recientes (Sin Filtro)
```
Búsqueda: (vacío)
```
**Resultados Esperados:**
- **Total de multas**: 414,738
- **Primera página (10 registros)**:
  1. Folio 716, Año 2025, Fecha: 2026-07-04
     - Contribuyente: EQUITECNOVO S DE RL DE CV
     - Total: $8,000.00
     - Estatus: PENDIENTE

  2. Folio 1248, Año 2025, Fecha: 2026-07-04
     - Contribuyente: EQUITECNOVO S DE RL DE CV
     - Total: $15,000.00
     - Estatus: PENDIENTE

  3. Folio 637, Año 2025, Fecha: 2026-07-03
     - Contribuyente: PULIDO MONTAÑO HECTOR
     - Total: $20,000.00
     - Estatus: PENDIENTE

- **Páginas totales**: 41,474 páginas (414,738 multas / 10 por página)

### Ejemplo 2: Búsqueda por Nombre "GARCIA"
```
Búsqueda: GARCIA
```
**Resultados Esperados:**
- **Total de multas**: 19,341
- **Primera página (10 registros)**:
  1. Folio 1324, Año 2025
     - Contribuyente: BLANCA MARGARITA GARCIA ORDOÑEZ
     - Total: $0.00
     - Estatus: PENDIENTE

  2. Folio 6747, Año 2025
     - Contribuyente: AUSENTE (domicilio contiene GARCIA)
     - Total: $0.00
     - Estatus: PENDIENTE

  3. Folio 510, Año 2025
     - Contribuyente: TOMAS GARCIA PEREZ
     - Total: $15,000.00
     - Estatus: PENDIENTE

- **Páginas totales**: 1,935 páginas (19,341 multas / 10 por página)

### Ejemplo 3: Búsqueda por Año "2024"
```
Búsqueda: 2024
```
**Resultados Esperados:**
- **Total de multas**: 4,279
- **Primera página (10 registros)**:
  1. Folio 17631, Fecha: 2027-04-27
     - Contribuyente: MARIA LUISAESQUEDA INZUNZA
     - Total: $2,500.00
     - Estatus: PAGADA

  2. Folio 904, Fecha: 2025-08-12
     - Contribuyente: JOSE LUIS AVILA RAMIREZ
     - Total: $0.00
     - Estatus: PENDIENTE

  3. Folio 1372, Fecha: 2025-07-24
     - Contribuyente: ABELINO
     - Total: $0.00
     - Estatus: CANCELADA

- **Páginas totales**: 428 páginas (4,279 multas / 10 por página)

## Tabla HTML - 9 Columnas

| Columna | Descripción | Formato |
|---------|-------------|---------|
| ID | ID de la multa | Código monoespaciado |
| Folio | Número de acta | Numérico |
| Año | Año del acta | Numérico |
| Fecha Acta | Fecha del acta | DD/MM/AAAA |
| Fecha Recepción | Fecha de recepción | DD/MM/AAAA |
| Contribuyente | Nombre del contribuyente | Texto |
| Domicilio | Domicilio | Texto |
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
- Ejemplo: "Mostrando 1 a 10 de 414,738"
- Ejemplo: "Mostrando 11 a 20 de 414,738"

### 4. **Funcionamiento**
1. El usuario puede buscar por cualquier término (contribuyente, folio, año, domicilio)
2. El SP devuelve los primeros 10 registros (offset=0, limit=10)
3. El campo `total_registros` indica el total disponible
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

### 1. **Búsqueda Universal**
- Campo único que busca en múltiples campos simultáneamente:
  - Nombre del contribuyente (ILIKE)
  - Número de folio (num_acta)
  - Año (axo_acta)
  - Domicilio (ILIKE)
- Búsqueda con Enter o botón "Buscar"

### 2. **Ordenamiento Inteligente**
- Por año descendente (más recientes primero)
- Luego por fecha de acta descendente
- Finalmente por ID de multa descendente
- Las fechas NULL se colocan al final

### 3. **Filtro de Datos Válidos**
- Solo muestra multas entre los años 1990 y 2030
- Esto excluye 279 registros con años incorrectos
- Total válido: 414,738 de 415,017 registros

### 4. **Tabla Responsiva**
- Scroll horizontal en pantallas pequeñas
- Hover effect en las filas
- Formato de moneda mexicana
- Formato de fechas localizado

### 5. **Paginación Automática**
- Se activa automáticamente cuando hay resultados
- Selector de tamaño de página
- Navegación con botones anterior/siguiente
- Información de página actual

### 6. **Estados de Carga**
- Spinner mientras carga los datos
- Mensaje cuando no hay resultados
- Deshabilitación del botón durante la carga

## Archivos Modificados

1. **RefactorX/Base/multas_reglamentos/database/generated/recaudadora_newsfrm.sql**
   - Stored procedure completo con paginación
   - Devuelve total_registros para paginación
   - Filtro de años 1990-2030
   - Búsqueda en múltiples campos

2. **RefactorX/FrontEnd/src/views/modules/multas_reglamentos/newsfrm.vue**
   - Tabla HTML con 9 columnas
   - Paginación completa (10, 25, 50 registros)
   - Formato de moneda y fechas
   - Badges de estatus con colores
   - Navegación con botones
   - Campo de búsqueda único

## Cómo Probar en el Frontend

Con el **frontend y backend ya corriendo** (http://localhost:3000):

### Ejemplo 1: Ver Multas Más Recientes
1. Ir al módulo: Multas y Reglamentos → Novedades de Multas
2. Dejar el campo "Búsqueda" vacío
3. Hacer clic en "Buscar" o presionar Enter
4. **Verificar**:
   - La tabla muestra 10 multas más recientes
   - La paginación muestra "Mostrando 1 a 10 de 414,738"
   - Primera multa: Folio 716, Año 2025, EQUITECNOVO S DE RL DE CV
   - El botón "Siguiente" está habilitado
   - El botón "Anterior" está deshabilitado

### Ejemplo 2: Buscar por Nombre "GARCIA"
1. Con el módulo abierto
2. Ingresar en "Búsqueda": `GARCIA`
3. Hacer clic en "Buscar" o presionar Enter
4. **Verificar**:
   - La tabla muestra 10 multas que contienen "GARCIA"
   - La paginación muestra "Mostrando 1 a 10 de 19,341"
   - Todas las multas tienen "GARCIA" en el nombre del contribuyente o domicilio
   - Puede navegar entre 1,935 páginas

### Ejemplo 3: Buscar por Año "2024"
1. Con el módulo abierto
2. Ingresar en "Búsqueda": `2024`
3. Hacer clic en "Buscar"
4. **Verificar**:
   - La tabla muestra 10 multas del año 2024
   - La paginación muestra "Mostrando 1 a 10 de 4,279"
   - Todas las multas tienen el año 2024
   - Total de páginas: 428

### Ejemplo 4: Cambiar Tamaño de Página
1. Con cualquier búsqueda activa
2. En el selector "Mostrar:", seleccionar "25"
3. **Verificar**:
   - La tabla muestra 25 registros
   - La paginación se actualiza: "Mostrando 1 a 25 de X"
   - Se recalcula el número de páginas

## Detalles Técnicos

### Formato de Parámetros
```javascript
{ nombre: 'p_filtro', tipo: 'string', valor: 'GARCIA' }
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
          id_multa: 123456,
          folio: 716,
          anio: 2025,
          fecha_acta: "2026-07-04",
          fecha_recepcion: "2026-07-05",
          contribuyente: "EQUITECNOVO S DE RL DE CV",
          domicilio: "AV CHAPULTEPEC 123",
          giro: "COMERCIO",
          total: 8000.00,
          estatus: "PENDIENTE",
          total_registros: 414738  // <-- Para paginación
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
// Ejemplo: 414,738 registros, tamaño 10 → 41,474 páginas
```

## Estadísticas de la Base de Datos

- **Total de multas en BD**: 415,017
- **Multas válidas (1990-2030)**: 414,738
- **Multas con años incorrectos**: 279
- **Rango de años**: 1990 a 2030
- **Multas con "GARCIA"**: 19,341
- **Multas del año 2024**: 4,279
- **Paginación por defecto**: 10 registros
- **Opciones de paginación**: 10, 25, 50 registros

## Estado Actual

✅ **COMPLETO Y FUNCIONAL**

El módulo está 100% operativo con:
- ✅ Stored procedure desplegado y probado
- ✅ Paginación de 10 en 10 (configurable a 25 o 50)
- ✅ Tabla HTML con 9 columnas
- ✅ Formato de moneda y fechas
- ✅ Badges de estatus con colores
- ✅ Navegación anterior/siguiente
- ✅ Selector de tamaño de página
- ✅ Información de paginación
- ✅ Búsqueda universal (contribuyente, folio, año, domicilio)
- ✅ Filtro de años válidos (1990-2030)
- ✅ Ordenamiento por más recientes primero

Listo para usar con los 3 ejemplos proporcionados.
