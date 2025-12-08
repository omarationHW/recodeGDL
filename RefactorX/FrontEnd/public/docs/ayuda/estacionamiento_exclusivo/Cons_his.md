# Cons_his - Consulta de Historial de Folios

## Propósito Administrativo
Visualiza el historial completo y detallado de un folio de apremio específico, mostrando todas las modificaciones, estados y movimientos que ha tenido desde su emisión hasta su estado actual.

## Funcionalidad Principal
Módulo de consulta que muestra la trazabilidad completa de un folio de apremio, incluyendo fechas de diligencias, ejecutores asignados, importes, observaciones y todos los cambios registrados en su ciclo de vida.

## Proceso de Negocio

### ¿Qué hace?
- Muestra historial completo de un folio de apremio
- Despliega todos los estados por los que ha pasado el folio
- Muestra fechas de emisión, practicación, entregas, citatorios
- Presenta importes desglosados (multa, recargos, gastos, actualización)
- Muestra información del contribuyente y cuenta asociada
- Despliega datos del ejecutor asignado
- Muestra detalle de periodos adeudados
- Presenta observaciones y movimientos históricos

### ¿Para qué sirve?
- Auditar el ciclo completo de un folio de apremio
- Verificar seguimiento de notificaciones y diligencias
- Revisar cambios de estado y fechas
- Consultar histórico de montos y actualizaciones
- Investigar incidencias o reclamaciones
- Documentar proceso de cobro para evidencia legal
- Analizar tiempo de gestión de folios

### ¿Cómo lo hace?
1. Recibe como parámetro el ID de control del folio
2. Consulta todos los registros históricos del folio
3. Muestra información de la cuenta asociada (mercado, aseo, etc.)
4. Presenta detalle de periodos y montos adeudados
5. Despliega fechas de todas las diligencias
6. Muestra estados e importes en cada momento
7. Permite navegar entre registros históricos del mismo folio
8. Interpreta claves y códigos mostrando descripciones

### ¿Qué necesita para funcionar?
- ID de control del folio a consultar
- Acceso a tablas históricas de apremios
- Acceso a información de cuenta asociada (mercados, aseo)
- Catálogo de diligencias, estados y claves

## Datos y Tablas

### Tabla Principal
**ta_15_apremios_historial** (QryHistoria): Historial de movimientos del folio

### Tablas Relacionadas
- **ta_11_locales** (QryMercados): Información de locales de mercados
- **ta_16_contratos_aseo** (QryAseo): Información de contratos de aseo
- **ta_15_detalle_historial** (QryDetal): Detalle de periodos adeudados por el folio

### Stored Procedures (SP)
No utiliza stored procedures

### Tablas que Afecta
**Solo consulta** (no modifica):
- ta_15_apremios_historial
- ta_15_detalle_historial
- ta_11_locales
- ta_16_contratos_aseo

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita investigación de incidencias
- Permite auditoría completa de folios
- Agiliza respuesta a reclamaciones de contribuyentes
- Documenta proceso de cobro ejecutivo

### Repercusiones Financieras
- Permite verificar cálculo de montos en diferentes momentos
- Facilita auditorías de cobro
- Documenta aplicación de descuentos y actualizaciones

### Repercusiones Administrativas
- Genera evidencia documental del proceso
- Facilita auditorías internas y externas
- Permite análisis de tiempos de gestión
- Documenta actuación de ejecutores

## Validaciones y Controles
- Valida existencia del folio antes de mostrar
- Solo permite consulta (lectura únicamente)
- Muestra información según permisos de usuario

## Casos de Uso

**Investigación de reclamación:**
- Contribuyente reclama monto incorrecto
- Usuario consulta historial del folio
- Verifica fechas y montos originales vs. actuales
- Documenta cambios y fundamentación

**Auditoría de gestión:**
- Auditor revisa tiempos de diligencias
- Consulta historial para ver fechas de cada etapa
- Calcula días entre emisión y practicación
- Evalúa eficiencia del proceso

## Usuarios del Sistema
- Personal de auditoría
- Supervisores de cobranza
- Jefes de ejecución fiscal
- Personal de atención a contribuyentes
- Investigadores de incidencias

## Relaciones con Otros Módulos
- **Individual.pas / Individual_Folio.pas**: Puede invocar historial desde consulta individual
- Todos los módulos que modifican folios generan historial que se consulta aquí
