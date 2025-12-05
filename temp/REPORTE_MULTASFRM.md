# Reporte: multasfrm.vue - Stored Procedure y Ejemplos

## Resumen de Cambios

✅ **Stored Procedure Creado y Desplegado**
- Archivo: `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_multasfrm.sql`
- Schema: `comun`
- Función: `comun.recaudadora_multasfrm()`

✅ **Vista Vue Actualizada**
- Archivo: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/multasfrm.vue`
- Tabla HTML completa con 10 columnas
- Formato de moneda y fechas
- Badges de estatus con colores
- Búsqueda en tiempo real

## Tabla de Base de Datos

**Tabla Principal:** `comun.multas`
- **Total de Registros:** 415,017 multas
- **Ubicación:** Base de datos `padron_licencias`, schema `comun`

### Campos Principales
```sql
comun.multas:
  - id_multa (integer) - ID único
  - num_acta (integer) - Número de folio/acta
  - axo_acta (smallint) - Año del acta
  - fecha_acta (date) - Fecha del acta
  - contribuyente (varchar) - Nombre del contribuyente
  - domicilio (varchar) - Domicilio
  - giro (varchar) - Giro del negocio
  - num_licencia (integer) - Número de licencia
  - total (numeric) - Total de la multa
  - cvepago (integer) - Clave de pago (indica si está pagada)
  - fecha_cancelacion (date) - Fecha de cancelación
```

## Stored Procedure

### Nombre
`comun.recaudadora_multasfrm`

### Parámetros
```sql
- p_filtro (VARCHAR, default: '') - Filtro general de búsqueda
```

### Búsqueda Inteligente
El parámetro `p_filtro` busca en **5 campos diferentes**:
1. **Contribuyente** (nombre) - Búsqueda con ILIKE (case-insensitive)
2. **Folio** (num_acta) - Búsqueda exacta o parcial
3. **Domicilio** - Búsqueda con ILIKE
4. **Giro** - Búsqueda con ILIKE
5. **Licencia** (num_licencia) - Búsqueda exacta o parcial

### Retorna
```sql
TABLE (
  id_multa INTEGER,           -- ID de la multa
  folio INTEGER,              -- Número de acta
  anio INTEGER,               -- Año del acta
  fecha_acta DATE,            -- Fecha del acta
  contribuyente VARCHAR,      -- Nombre del contribuyente
  domicilio VARCHAR,          -- Domicilio
  giro VARCHAR,               -- Giro del negocio
  licencia INTEGER,           -- Número de licencia
  calificacion NUMERIC,       -- Calificación
  multa NUMERIC,              -- Monto de la multa
  gastos NUMERIC,             -- Gastos administrativos
  total NUMERIC,              -- Total a pagar
  estatus VARCHAR             -- PENDIENTE, PAGADA o CANCELADA
)
```

### Límite de Resultados
El SP retorna un **máximo de 100 registros** para optimizar el rendimiento.

## 3 Ejemplos con Datos Reales

### Ejemplo 1: Búsqueda por Nombre
```
Filtro: GARCIA
```
**Resultados Esperados (3 primeros):**
1. ID: 415232, Folio: 1324, Año: 2025
   - Contribuyente: BLANCA MARGARITA GARCIA ORDOÑEZ
   - Domicilio: CALZADA INDEPENDENCIA NORTE 4511 INT 12
   - Giro: PLURIFAMILIAR HORIZONTAL
   - Total: $0.00
   - Estatus: PENDIENTE

2. ID: 415221, Folio: 829, Año: 2025
   - Contribuyente: PANIAGUA GARCIA HUGO ARMANDO
   - Domicilio: VICENTE FERNANDEZ
   - Giro: VENTA DE CERVEZA Y VINOS GENEROSOS EN B.A ANEXO A FONDA
   - Total: $0.00
   - Estatus: PENDIENTE

3. ID: 415213, Folio: 510, Año: 2025
   - Contribuyente: TOMAS GARCIA PEREZ
   - Domicilio: DAMIAN CARMONA
   - Total: $15,000.00
   - Estatus: PENDIENTE

### Ejemplo 2: Búsqueda por Folio
```
Filtro: 711
```
**Resultados Esperados:**
1. ID: 415028, Folio: 711, Año: 2025
   - Contribuyente: HERNANDEZ PEREZ EDUARDO
   - Domicilio: DEL ISTMO
   - Giro: CASA HABITACION
   - Total: $0.00
   - Estatus: PENDIENTE

2. ID: 414413, Folio: 468, Año: 2025
   - Contribuyente: QUIÑONES VERDUZCO RICARDO
   - Domicilio: ARCOS DE LOS AV.
   - Giro: FONDA
   - Total: $10,500.00
   - Estatus: PAGADA

### Ejemplo 3: Búsqueda por Giro
```
Filtro: VENTA
```
**Resultados Esperados:**
1. ID: 415277, Folio: 917, Año: 2025
   - Contribuyente: VERGARA VARGAS ARMANDO
   - Domicilio: NUEZ
   - Giro: VENTA DE CERVEZA EN BOTELLA CERRADA ANEXO A ABARROTES
   - Total: $0.00
   - Estatus: PENDIENTE

2. ID: 415256, Folio: 1375, Año: 2025
   - Contribuyente: CHAVEZ TERRIQUEZ GAMALIEL
   - Domicilio: HACIENDA SANTIAGO
   - Giro: VENTA DE CALZADO DEPORTIVO
   - Total: $0.00
   - Estatus: PENDIENTE

3. ID: 415255, Folio: 1519, Año: 2025
   - Contribuyente: ORNELAS RAZO SERGIO
   - Domicilio: MARIPOSA
   - Giro: VENTA DE FRUTAS Y VERDURAS
   - Total: $0.00
   - Estatus: PENDIENTE

## Tabla HTML - Columnas

La tabla HTML en el componente Vue muestra **10 columnas**:

| Columna | Descripción | Formato |
|---------|-------------|---------|
| ID | ID de la multa | Código monoespaciado |
| Folio | Número de acta | Numérico |
| Año | Año del acta | Numérico |
| Fecha | Fecha del acta | DD/MM/AAAA |
| Contribuyente | Nombre del contribuyente | Texto |
| Domicilio | Dirección | Texto |
| Giro | Giro del negocio | Texto |
| Licencia | Número de licencia | Numérico (N/A si es 0) |
| Total | Monto total | $X,XXX.XX MXN |
| Estatus | Estado de la multa | Badge con color |

## Estatus con Colores

Los estatus se muestran con badges de colores:

- 🟢 **PAGADA** - Verde (fondo: #d4edda, texto: #155724)
- 🔴 **CANCELADA** - Rojo (fondo: #f8d7da, texto: #721c24)
- 🟡 **PENDIENTE** - Amarillo (fondo: #fff3cd, texto: #856404)

## Características del Formulario

### 1. **Búsqueda Inteligente**
- Un solo campo de búsqueda que filtra por múltiples columnas
- Búsqueda case-insensitive (no distingue mayúsculas/minúsculas)
- Búsqueda parcial (encuentra "GAR" en "GARCIA")

### 2. **Tabla Responsiva**
- Scroll horizontal en pantallas pequeñas
- Hover effect en las filas
- Formato de moneda mexicana
- Formato de fechas localizado

### 3. **Estados de Carga**
- Spinner mientras carga los datos
- Mensaje cuando no hay resultados
- Deshabilitación del botón durante la carga

### 4. **Sin Paginación Inicial**
- Muestra hasta 100 registros por búsqueda
- Se puede implementar paginación si es necesario

## Archivos Modificados

1. **RefactorX/Base/multas_reglamentos/database/generated/recaudadora_multasfrm.sql**
   - Stored procedure completo con búsqueda en múltiples campos
   - Límite de 100 registros

2. **RefactorX/FrontEnd/src/views/modules/multas_reglamentos/multasfrm.vue**
   - Tabla HTML con 10 columnas
   - Formato de moneda y fechas
   - Badges de estatus con colores
   - Búsqueda en tiempo real

## Cómo Probar en el Frontend

1. **Abrir el módulo** en: http://localhost:3000
2. **Navegar a**: Multas y Reglamentos → Consulta General de Multas
3. **Probar con los ejemplos**:
   - Campo "Búsqueda General": `GARCIA` → Enter o clic en "Buscar"
   - Campo "Búsqueda General": `711` → Enter o clic en "Buscar"
   - Campo "Búsqueda General": `VENTA` → Enter o clic en "Buscar"
4. **Verificar**:
   - La tabla debe mostrar los resultados
   - Los estatus deben aparecer con colores
   - Los totales deben estar formateados como moneda
   - Las fechas deben estar en formato DD/MM/AAAA

## Estadísticas

- **Total de multas**: 415,017
- **Límite por búsqueda**: 100 registros
- **Campos de búsqueda**: 5 (contribuyente, folio, domicilio, giro, licencia)
- **Columnas mostradas**: 10
- **Estatus posibles**: 3 (PENDIENTE, PAGADA, CANCELADA)

## Notas Técnicas

1. El SP está en el schema `comun`, no en `public`
2. El GenericController busca automáticamente en schemas permitidos
3. La búsqueda es case-insensitive (no distingue mayúsculas/minúsculas)
4. El límite de 100 registros evita sobrecarga en el frontend
5. Los valores NULL se convierten a "N/A" o 0 según corresponda

## Estado Actual

✅ **COMPLETO Y FUNCIONAL**

El módulo está listo para usar. Solo necesitas:
1. Recargar el frontend (ya está corriendo)
2. Probar con los ejemplos proporcionados
3. Verificar que la tabla muestra los datos correctamente
