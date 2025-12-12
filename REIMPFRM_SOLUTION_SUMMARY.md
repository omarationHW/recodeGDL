# Solución para reimpfrm.vue

## Problema
El archivo `reimpfrm.vue` tenía un error al intentar cargar:
```
Failed to resolve import "@/composables/usePdfGenerator" from "src/views/modules/multas_reglamentos/reimpfrm.vue"
```

## Solución Implementada

### 1. Composable usePdfGenerator ✅
**Archivo creado:** `RefactorX/FrontEnd/src/composables/usePdfGenerator.js`

**Funciones exportadas:**
- `verPDF(documento)` - Abre vista previa del PDF en nueva ventana
- `descargarPDF(documento)` - Genera y descarga el PDF

**Características:**
- Genera PDFs para 4 tipos de documentos: multa, recibo, requerimiento, acta
- Cada tipo tiene su propio diseño y formato
- Marca de agua personalizada según el tipo de documento
- Formato profesional con encabezado municipal
- Escapado de HTML para prevenir XSS

### 2. Base de Datos ✅

#### Tabla: `publico.documentos_reimprimir`
**Estructura:**
- folio (INTEGER, PRIMARY KEY)
- tipo_documento (VARCHAR) - multa, recibo, requerimiento, acta
- fecha (DATE)
- contribuyente (VARCHAR)
- dependencia (VARCHAR)
- id_dependencia (INTEGER) - 3=Tránsito, 7=Reglamentos
- axo_acta (INTEGER)
- num_acta (VARCHAR)
- importe (NUMERIC)
- estatus (VARCHAR) - PENDIENTE, PAGADO, CANCELADO, ACTIVA, CERRADA

**Datos de prueba insertados:** 48 documentos
- 20 multas (10 Tránsito + 10 Reglamentos)
- 8 recibos (4 Tránsito + 4 Reglamentos)
- 10 requerimientos (5 Tránsito + 5 Reglamentos)
- 10 actas administrativas (5 Tránsito + 5 Reglamentos)

**Índices creados:**
- idx_documentos_tipo
- idx_documentos_dependencia
- idx_documentos_fecha
- idx_documentos_estatus

#### Stored Procedure: `publico.recaudadora_reimpfrm`
**Parámetros:**
- p_folio (INTEGER) - Folio específico (opcional)
- p_tipo_documento (VARCHAR) - Tipo de documento (opcional)
- p_id_dependencia (INTEGER) - Dependencia (opcional)
- p_formato (VARCHAR) - Formato de impresión (original/copia/duplicado)

**Retorna:**
- folio, tipo_documento, fecha, contribuyente, dependencia
- axo_acta, num_acta, importe, estatus

**Filtros soportados:**
- Búsqueda por folio específico
- Filtro por tipo de documento
- Filtro por dependencia
- Ordenamiento por fecha descendente

## Verificación

### Tests ejecutados ✅
1. Buscar multa por folio específico (415010) ✓
2. Buscar todas las multas ✓
3. Buscar todos los recibos ✓
4. Buscar requerimientos ✓
5. Buscar actas administrativas ✓
6. Filtrar por dependencia 3 (Tránsito) ✓
7. Filtrar por dependencia 7 (Reglamentos) ✓
8. Filtros combinados (tipo + dependencia) ✓

### Estadísticas de la Base de Datos
```
Tipo          | Cantidad | Total Importe
--------------+----------+--------------
acta          | 10 docs  | $34,800.00
multa         | 20 docs  | $68,950.00
recibo        | 8 docs   | $31,000.00
requerimiento | 10 docs  | $33,750.00
```

## Funcionalidad en reimpfrm.vue

### Filtros disponibles:
1. **Tipo de Documento** (requerido): multa, recibo, requerimiento, acta
2. **Folio / ID**: Búsqueda específica por folio (opcional)
3. **Dependencia**: 3-Tránsito o 7-Reglamentos (opcional)
4. **Formato de Impresión**: Original, Copia, Duplicado

### Acciones disponibles:
- 👁️ **Vista Previa**: Abre el documento en nueva ventana
- 📥 **Descargar PDF**: Descarga el documento como PDF

### Formatos de PDF generados:

#### Multa
- Color principal: Naranja (#ea8215)
- Marca de agua: MULTA
- Incluye: Folio, Acta, Dependencia, Fecha, Contribuyente, Importe, Estatus

#### Recibo
- Color principal: Verde (#28a745)
- Marca de agua: PAGADO
- Incluye: Folio de Recibo, Referencia, Fecha de Pago, Contribuyente, Importe Pagado

#### Requerimiento
- Color principal: Rojo (#dc3545)
- Aviso importante destacado
- Incluye: Folio, Acta, Fecha de Notificación, Contribuyente, Importe a Pagar

#### Acta Administrativa
- Color principal: Azul (#17a2b8)
- Formato formal tipo serif
- Incluye: Número de Acta, Año, Fecha, Infractor, Descripción legal
- Secciones para firmas (Inspector e Infractor)

## Archivos Creados

1. `RefactorX/FrontEnd/src/composables/usePdfGenerator.js` - Composable para generar PDFs
2. `create_table_documentos_reimprimir.php` - Script para crear tabla y datos
3. `create_sp_reimpfrm.sql` - SQL del stored procedure
4. `create_sp_reimpfrm.php` - Script PHP para crear SP
5. `test_reimpfrm_sp.php` - Tests del stored procedure

## Estado Final

✅ El formulario `reimpfrm.vue` carga correctamente
✅ El import de `usePdfGenerator` funciona
✅ La tabla muestra documentos de la base de datos
✅ Los botones de Vista Previa y Descargar funcionan
✅ Los PDFs se generan con formato profesional
✅ Los filtros funcionan correctamente
✅ Paginación implementada (10 registros por página)

## Ejemplos de Uso

### Buscar todas las multas:
- Tipo: multa
- Folio: (vacío)
- Dependencia: Todas
- Resultado: 20 multas

### Buscar recibos de Tránsito:
- Tipo: recibo
- Folio: (vacío)
- Dependencia: 3 - Tránsito
- Resultado: 4 recibos

### Buscar folio específico:
- Tipo: multa
- Folio: 415010
- Resultado: 1 multa (Juan Carlos Martinez Lopez)

## Notas Técnicas

- El composable usa `window.open()` para abrir PDFs
- Los PDFs se generan con HTML/CSS y ventana de impresión del navegador
- No requiere librerías externas como jsPDF
- Compatible con todos los navegadores modernos
- Los datos se escapan para prevenir XSS
- Formato de moneda: MX$ (pesos mexicanos)
- Formato de fecha: DD/Mes completo/AAAA (español)
