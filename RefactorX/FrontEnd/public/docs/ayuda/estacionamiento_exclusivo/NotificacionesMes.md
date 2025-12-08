# Notificaciones por Mes

## Propósito Administrativo
Generar reportes estadísticos mensuales de notificaciones emitidas, practicadas y pagadas, agrupadas por ejecutor y módulo, permitiendo evaluar la efectividad de la gestión de cobro coactivo y el desempeño individual del personal.

## Funcionalidad Principal
Este módulo genera reportes estadísticos cruzando tres criterios temporales (año de emisión, año de practicado y rango de fechas de pago), mostrando cantidades de folios asignados, practicados, cancelados, pagados y monto recaudado por ejecutor y tipo de servicio.

## Proceso de Negocio

### ¿Qué hace?
Consulta folios de apremios aplicando filtros combinados de año de emisión, año de practicado y rango de fechas de pago, generando estadísticas agrupadas por mes, módulo y ejecutor, con capacidad de exportación a Excel para análisis detallado.

### ¿Para qué sirve?
- Evaluar la efectividad de la gestión de cobro mensual
- Medir el desempeño individual de ejecutores fiscales
- Generar estadísticas de productividad por mes
- Analizar tiempos entre emisión, practicado y pago
- Documentar resultados para reportes gerenciales
- Apoyar decisiones sobre incentivos y reconocimientos
- Cumplir con reportes institucionales

### ¿Cómo lo hace?
1. El usuario selecciona:
   - Año de emisión de los folios
   - Año de practicado de los folios
   - Rango de fechas de pago (fecha desde - fecha hasta)
2. El sistema ejecuta un stored procedure que:
   - Cruza los tres criterios temporales
   - Agrupa por módulo, mes y ejecutor
   - Cuenta folios asignados, practicados, cancelados y pagados
   - Suma los importes recaudados
3. Muestra los resultados en una tabla estadística
4. Permite exportar a Excel con encabezados personalizados
5. El reporte incluye:
   - Módulo de aplicación
   - Mes de análisis
   - Año de referencia
   - Ejecutor responsable
   - Cantidad de folios asignados
   - Cantidad de folios practicados
   - Cantidad de folios cancelados
   - Cantidad de folios pagados
   - Monto total recaudado

### ¿Qué necesita para funcionar?
- Usuario con permisos de consulta estadística
- Año de emisión válido
- Año de practicado válido
- Rango de fechas de pago válido
- Stored procedure de estadísticas funcional
- Folios registrados en el sistema
- Datos de ejecutores actualizados

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Fuente de datos de folios

### Tablas Relacionadas
- **ta_15_ejecutores**: Información de ejecutores
- **ta_14_recaudadoras**: Oficinas recaudadoras

### Stored Procedures (SP)
- **sp_notificaciones_mes** (o similar): Genera las estadísticas cruzadas
  - Parámetros: año de emisión, año de practicado, fecha desde pago, fecha hasta pago
  - Retorna: Estadísticas agrupadas por módulo, mes, año, ejecutor con cantidades y montos

### Tablas que Afecta
Este módulo es de solo consulta. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Permite evaluar objetivamente el desempeño
- Facilita la identificación de mejores prácticas
- Apoya la distribución equitativa de trabajo
- Documenta la productividad mensual
- Permite comparaciones entre periodos

### Repercusiones Financieras
- Muestra la recuperación mensual de adeudos
- Documenta ingresos por cobro coactivo
- Permite proyecciones basadas en tendencias
- Apoya la justificación presupuestal
- Facilita análisis de costo-beneficio

### Repercusiones Administrativas
- Genera información para evaluación de personal
- Apoya decisiones sobre incentivos
- Facilita reportes institucionales
- Documenta cumplimiento de metas
- Permite análisis de gestión temporal

## Validaciones y Controles
- Valida que los años sean numéricos y válidos
- Verifica que fecha desde sea menor o igual a fecha hasta
- Controla que existan registros en los criterios seleccionados
- Valida permisos del usuario para consultas estadísticas
- Asegura la integridad de los cálculos

## Casos de Uso
1. **Director de Ingresos**: Solicita reporte mensual de gestión de cobro
2. **Jefe de Ejecutores**: Evalúa desempeño mensual de su equipo
3. **Recursos Humanos**: Genera información para cálculo de incentivos
4. **Auditor**: Revisa estadísticas de gestión del área
5. **Coordinador**: Exporta a Excel para análisis detallado en reunión

## Usuarios del Sistema
- Directores y subdirectores
- Jefes de ejecutores fiscales
- Recursos humanos
- Coordinadores administrativos
- Auditores
- Personal de análisis y estadística

## Relaciones con Otros Módulos
- **Prenomina**: Cálculo de incentivos basado en estas estadísticas
- **Ejecutores**: Información del personal evaluado
- **Recuperacion**: Origen de los datos de pagos
- **Lista_GastosCob**: Estadísticas complementarias de gastos
- **ConsultaReg**: Consulta detallada de folios en las estadísticas
