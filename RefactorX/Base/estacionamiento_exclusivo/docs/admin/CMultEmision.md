# CMultEmision - Consulta Múltiple por Fecha de Emisión

## Propósito Administrativo
Herramienta de consulta para localizar múltiples folios de apremio generados en una fecha específica. Facilita la revisión y seguimiento de folios emitidos en fechas determinadas.

## Funcionalidad Principal
Módulo de consulta que permite buscar y visualizar todos los folios de apremio emitidos en una fecha específica, filtrados por recaudadora y tipo de aplicación (mercados, aseo, estacionamientos, infracciones, cementerios).

## Proceso de Negocio

### ¿Qué hace?
- Consulta folios de apremio por fecha de emisión
- Filtra por recaudadora
- Filtra por tipo de aplicación (módulo)
- Muestra lista de folios encontrados
- Permite acceder al detalle individual de cada folio

### ¿Para qué sirve?
- Verificar folios emitidos en una fecha específica
- Auditar emisiones masivas de apremios
- Localizar folios de una jornada de trabajo
- Revisar folios generados en procesos por lote
- Facilitar búsqueda de folios sin conocer el número exacto

### ¿Cómo lo hace?
1. Usuario selecciona recaudadora del catálogo
2. Selecciona tipo de aplicación (mercados, aseo, públicos, exclusivos, infracciones, cementerios)
3. Captura fecha de emisión a consultar
4. Sistema busca todos los folios emitidos en esa fecha
5. Muestra resultados en cuadrícula
6. Permite seleccionar folio para ver detalle completo

### ¿Qué necesita para funcionar?
- Recaudadora seleccionada
- Tipo de aplicación (módulo: 11=Mercados, 16=Aseo, 24=Est.Públicos, 28=Est.Exclusivos, 14=Infracciones, 13=Cementerios)
- Fecha de emisión a consultar
- Folios existentes en la tabla de apremios

## Datos y Tablas

### Tabla Principal
**ta_15_apremios** (QryFolio): Folios de apremio del sistema

### Tablas Relacionadas
**ta_catalogo_recaudadoras** (Qryrec): Catálogo de recaudadoras

### Stored Procedures (SP)
No utiliza stored procedures

### Tablas que Afecta
**Solo consulta** (no inserta ni actualiza):
- ta_15_apremios

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita localización de folios en procesos de emisión masiva
- Permite auditar emisiones diarias
- Agiliza búsqueda de folios sin número exacto
- Facilita seguimiento de jornadas de trabajo

### Repercusiones Financieras
- Permite verificar montos emitidos por fecha
- Facilita cuadres de emisiones vs. registros contables
- Ayuda en conciliaciones de adeudos emitidos

### Repercusiones Administrativas
- Facilita auditorías por fecha de emisión
- Permite verificar volumen de trabajo por día
- Ayuda en investigaciones de folios específicos

## Validaciones y Controles
- Requiere selección de recaudadora
- Valida que la fecha sea válida
- Solo muestra folios de la recaudadora seleccionada

## Casos de Uso

**Auditoría de emisión masiva:**
- Se emitieron 500 folios el día 15 de marzo
- Auditor consulta fecha para verificar
- Sistema muestra los 500 folios emitidos
- Auditor puede revisar uno por uno

**Búsqueda de folio sin número exacto:**
- Usuario recuerda que el folio se emitió ayer
- Consulta por fecha de emisión
- Localiza el folio en la lista
- Accede al detalle del folio

## Usuarios del Sistema
- Personal de auditoría
- Supervisores de cobranza
- Coordinadores de emisiones
- Personal de control de apremios

## Relaciones con Otros Módulos
- **Individual.pas**: Abre detalle del folio seleccionado
- **CMultFolio.pas**: Módulo similar pero busca por rango de folios
- **Listados.pas**: Genera reportes de los folios consultados
