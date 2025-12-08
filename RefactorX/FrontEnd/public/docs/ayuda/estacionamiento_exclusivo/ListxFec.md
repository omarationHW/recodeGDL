# Listados por Fecha

## Propósito Administrativo
Generar listados de folios de apremios filtrando por diferentes tipos de fechas (emisión, practicado, citatorio, pago) permitiendo análisis y seguimiento de la gestión de cobro coactivo en periodos específicos.

## Funcionalidad Principal
Este módulo genera reportes de folios de apremios agrupados por diferentes criterios de fecha, facilitando el análisis de la gestión operativa, la productividad de ejecutores y el cumplimiento de metas de cobro.

## Proceso de Negocio

### ¿Qué hace?
Consulta folios de apremios aplicando filtros por tipo de fecha (actualización, practicado, citatorio, pago, emisión, entrega a ejecutor) y genera listados detallados con información del folio, contribuyente, ejecutor y estado.

### ¿Para qué sirve?
- Generar reportes operativos por periodo
- Monitorear la productividad de ejecutores
- Analizar tiempos de gestión de cobro
- Identificar folios en diferentes etapas del proceso
- Evaluar cumplimiento de metas
- Generar estadísticas de gestión

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de fecha a filtrar (6 opciones)
2. Define el rango de fechas de consulta
3. Selecciona el tipo de aplicación (Mercados, Aseo, Públicos, Exclusivos, Infracciones, Cementerios)
4. Puede filtrar por todas las vigencias o una específica
5. Opcionalmente filtra por ejecutor específico o todos
6. El sistema consulta los folios que cumplen los criterios
7. Ordena los resultados por fecha y folio
8. Genera el reporte con toda la información del folio

### ¿Qué necesita para funcionar?
- Usuario con permisos de consulta
- Rango de fechas válido (fecha desde menor o igual a fecha hasta)
- Tipo de aplicación seleccionado
- Oficina recaudadora asignada
- Folios registrados en el sistema

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Folios de apremios con todas sus fechas

### Tablas Relacionadas
- **ta_15_ejecutores**: Datos de ejecutores fiscales
- **ta_14_recaudadoras**: Información de oficinas recaudadoras
- **ta_15_claves**: Catálogos de vigencias y estados

### Stored Procedures (SP)
No utiliza stored procedures. Realiza consultas SQL dinámicas.

### Tablas que Afecta
Este módulo es de solo consulta. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita el seguimiento de la gestión diaria
- Permite identificar cuellos de botella en el proceso
- Apoya la evaluación de desempeño de ejecutores
- Genera información para mejora de procesos

### Repercusiones Financieras
- Permite analizar la velocidad de cobro
- Facilita proyección de ingresos por cobro coactivo
- Apoya el cálculo de indicadores financieros
- Documenta la gestión de recuperación de cartera

### Repercusiones Administrativas
- Genera reportes gerenciales periódicos
- Apoya la toma de decisiones operativas
- Facilita auditorías de gestión
- Documenta el cumplimiento de objetivos
- Permite evaluación de eficiencia del área

## Validaciones y Controles
- Valida que la fecha inicial no sea mayor que la fecha final
- Verifica que existan registros en el rango solicitado
- Controla el acceso por oficina recaudadora
- Valida el tipo de aplicación seleccionado
- Asegura la integridad de los datos consultados

## Casos de Uso
1. **Director de Ingresos**: Solicita reporte mensual de folios practicados
2. **Jefe de Ejecutores**: Genera listado diario de folios pagados
3. **Supervisor**: Consulta folios emitidos en la semana
4. **Auditor**: Revisa folios actualizados en un periodo
5. **Coordinador**: Analiza tiempos entre emisión y practicado

## Usuarios del Sistema
- Directores y subdirectores
- Jefes de ejecutores fiscales
- Supervisores de cobro
- Coordinadores administrativos
- Auditores
- Personal de análisis y estadística

## Relaciones con Otros Módulos
- **ConsultaReg**: Consulta detallada de folios individuales
- **Ejecutores**: Información de los ejecutores asignados
- **RprtListaxFec**: Módulo de generación del reporte
- **Notificaciones**: Seguimiento de notificaciones por fecha
- **Recuperacion**: Análisis de pagos por periodo
