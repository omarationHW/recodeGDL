# CMultFolio - Consulta Múltiple por Rango de Folios

## Propósito Administrativo
Herramienta de consulta para localizar múltiples folios de apremio dentro de un rango consecutivo de números. Facilita la revisión de grupos de folios por su numeración.

## Funcionalidad Principal
Módulo de consulta que permite buscar y visualizar folios de apremio en un rango de 100 folios consecutivos, filtrados por recaudadora y tipo de aplicación.

## Proceso de Negocio

### ¿Qué hace?
- Consulta folios de apremio por rango de números
- Busca automáticamente 100 folios consecutivos a partir del número inicial
- Filtra por recaudadora
- Filtra por tipo de aplicación (módulo)
- Muestra lista de folios encontrados en el rango
- Permite acceder al detalle individual de cada folio

### ¿Para qué sirve?
- Localizar folios en rangos específicos de numeración
- Verificar folios consecutivos de una emisión
- Auditar bloques de folios asignados
- Facilitar búsqueda de folios conociendo número aproximado
- Revisar folios de un lote o paquete específico

### ¿Cómo lo hace?
1. Usuario selecciona recaudadora del catálogo
2. Selecciona tipo de aplicación (mercados, aseo, públicos, exclusivos, infracciones, cementerios)
3. Captura número de folio inicial
4. Sistema busca desde ese folio hasta 100 folios después
5. Muestra resultados en cuadrícula
6. Permite seleccionar folio para ver detalle completo

### ¿Qué necesita para funcionar?
- Recaudadora seleccionada
- Tipo de aplicación (módulo: 11=Mercados, 16=Aseo, 24=Est.Públicos, 28=Est.Exclusivos, 14=Infracciones, 13=Cementerios)
- Número de folio inicial
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
- Facilita localización de folios en bloques consecutivos
- Permite verificar continuidad de folios
- Agiliza búsqueda conociendo numeración aproximada
- Facilita auditoría de rangos asignados

### Repercusiones Financieras
- Permite verificar montos en rangos específicos
- Facilita cuadres de folios consecutivos
- Ayuda en auditorías de emisiones por bloques

### Repercusiones Administrativas
- Facilita control de folios por rangos
- Permite verificar asignaciones de bloques consecutivos
- Ayuda en investigaciones de folios específicos
- Facilita auditorías de emisiones por paquetes

## Validaciones y Controles
- Requiere selección de recaudadora
- Valida que el folio inicial sea válido
- Solo muestra folios de la recaudadora seleccionada
- Limita búsqueda a 100 folios consecutivos para optimizar rendimiento

## Casos de Uso

**Auditoría de rango de folios:**
- Se asignaron folios del 1000 al 1100
- Auditor consulta desde folio 1000
- Sistema muestra folios en ese rango
- Auditor verifica continuidad y datos

**Búsqueda conociendo número aproximado:**
- Usuario recuerda que el folio es aproximadamente 5000
- Consulta desde folio 5000
- Sistema muestra folios del 5000 al 5100
- Usuario localiza el folio buscado

**Verificación de bloque asignado:**
- Ejecutor recibió folios del 2000 al 2050
- Supervisor consulta desde folio 2000
- Verifica que todos estén asignados correctamente
- Confirma datos de asignación

## Usuarios del Sistema
- Personal de auditoría
- Supervisores de cobranza
- Coordinadores de emisiones
- Personal de control de apremios
- Ejecutores fiscales

## Relaciones con Otros Módulos
- **Individual.pas**: Abre detalle del folio seleccionado
- **CMultEmision.pas**: Módulo similar pero busca por fecha de emisión
- **Listados.pas**: Genera reportes de los folios consultados
- **Reasignacion.pas**: Puede usar esta consulta para reasignar bloques de folios
