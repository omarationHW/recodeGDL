# Listados - Listados Generales de Apremios

## Propósito Administrativo
Genera múltiples tipos de reportes y listados de folios de apremio con diversos filtros y agrupaciones, facilitando consultas, análisis y generación de reportes operativos.

## Funcionalidad Principal
Módulo versátil que produce listados de folios de apremio según múltiples criterios de búsqueda y filtrado, con opciones de agrupación, ordenamiento e impresión.

## Proceso de Negocio

### ¿Qué hace?
- Genera listados de folios con múltiples filtros
- Permite filtrado por:
  - Recaudadora
  - Ejecutor
  - Fechas (emisión, practicación, pago)
  - Estado (vigente, pagado, cancelado)
  - Tipo de aplicación
  - Rango de folios
- Agrupa y ordena información
- Exporta a Excel
- Imprime reportes formateados
- Presenta totales y subtotales

### ¿Para qué sirve?
- Generar reportes operativos diarios
- Consultar folios por diversos criterios
- Producir listados para trabajo de campo
- Generar reportes para auditoría
- Facilitar análisis de información
- Documentar gestión de cobranza

### ¿Cómo lo hace?
1. Usuario selecciona criterios de filtrado
2. Define opciones de agrupación y ordenamiento
3. Sistema consulta folios que cumplen criterios
4. Organiza información según parámetros
5. Calcula totales y subtotales
6. Presenta en pantalla o imprime
7. Permite exportar a Excel

### ¿Qué necesita para funcionar?
- Criterios de selección
- Filtros deseados
- Formato de salida (pantalla, impresora, Excel)
- Opciones de agrupación

## Datos y Tablas

### Tabla Principal
**ta_15_apremios**: Folios de apremio

### Tablas Relacionadas
- **ta_15_ejecutores**: Datos de ejecutores
- **ta_11_locales / ta_16_contratos_aseo**: Información de cuentas
- **ta_catalogo_recaudadoras**: Recaudadoras
- **ta_15_detalle**: Detalle de adeudos

### Stored Procedures (SP)
Posiblemente utiliza SP para consultas complejas

### Tablas que Afecta
**Solo consulta** (no modifica)

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita trabajo diario del área
- Permite seguimiento de folios
- Optimiza búsqueda de información

### Repercusiones Financieras
- Permite análisis de adeudos
- Facilita proyecciones de cobro
- Documenta recuperación

### Repercusiones Administrativas
- Genera información para reportes
- Facilita auditorías
- Documenta gestión

## Validaciones y Controles
- Valida criterios de búsqueda
- Verifica rangos de fechas
- Optimiza consultas grandes

## Casos de Uso

**Listado para trabajo de campo:**
- Ejecutor requiere lista de sus folios del día
- Filtra por ejecutor y fecha
- Imprime listado
- Ejecutor sale a notificar con su lista

**Análisis de folios vencidos:**
- Supervisor requiere folios sin pagar de más de 60 días
- Filtra por estado vigente y fecha de emisión
- Genera listado
- Toma acciones de seguimiento

## Usuarios del Sistema
- Todo el personal del área
- Ejecutores fiscales
- Supervisores
- Coordinadores
- Personal de auditoría

## Relaciones con Otros Módulos
- Prácticamente todos los demás módulos pueden generar listados
- Es uno de los módulos más usados del sistema
