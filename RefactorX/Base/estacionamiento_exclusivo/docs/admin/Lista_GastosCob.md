# Lista de Gastos Cobrados

## Propósito Administrativo
Generar reportes de gastos de ejecución cobrados en un periodo determinado, permitiendo conocer el monto de gastos recuperados por tipo de diligencia y por ejecutor fiscal.

## Funcionalidad Principal
Este módulo genera reportes detallados de los gastos de ejecución que han sido cobrados a contribuyentes, mostrando estadísticas por tipo de diligencia, ejecutor y oficina recaudadora.

## Proceso de Negocio

### ¿Qué hace?
Consulta los folios pagados en un periodo y genera reportes estadísticos de los gastos de ejecución cobrados, clasificándolos por tipo de diligencia (notificación, requerimiento, secuestro, embargo) y por ejecutor responsable.

### ¿Para qué sirve?
- Conocer la recuperación de gastos de ejecución
- Evaluar el desempeño de ejecutores fiscales
- Generar estadísticas de cobro de gastos
- Apoyar la toma de decisiones sobre incentivos
- Documentar la efectividad del área de cobro
- Cumplir con reportes financieros y operativos

### ¿Cómo lo hace?
1. El usuario selecciona el rango de fechas de consulta
2. Define el tipo de aplicación (Mercados, Aseo, etc.)
3. Selecciona la oficina recaudadora
4. El sistema consulta folios pagados en ese periodo
5. Suma los gastos de ejecución por tipo de diligencia
6. Agrupa la información por ejecutor fiscal
7. Calcula totales por diligencia y por ejecutor
8. Genera el reporte impreso o en pantalla

### ¿Qué necesita para funcionar?
- Usuario con permisos de consulta
- Rango de fechas válido
- Folios pagados con gastos de ejecución
- Información de ejecutores actualizada
- Oficina recaudadora seleccionada

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Folios con información de gastos y pagos

### Tablas Relacionadas
- **ta_15_ejecutores**: Datos de ejecutores fiscales
- **ta_14_recaudadoras**: Información de oficinas recaudadoras
- **ta_15_claves**: Catálogo de tipos de diligencia

### Stored Procedures (SP)
No utiliza stored procedures específicos. Realiza consultas SQL con agrupaciones y totales.

### Tablas que Afecta
Este módulo es de solo consulta. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Permite evaluar la gestión de ejecutores
- Facilita la identificación de mejores prácticas
- Apoya la asignación equitativa de trabajo
- Documenta la productividad del área

### Repercusiones Financieras
- Muestra la recuperación de gastos de ejecución
- Documenta ingresos adicionales al adeudo principal
- Permite calcular el costo-beneficio de las acciones de cobro
- Apoya la justificación presupuestal del área

### Repercusiones Administrativas
- Genera información para evaluación de desempeño
- Apoya decisiones sobre incentivos y reconocimientos
- Facilita reportes gerenciales y de transparencia
- Documenta la efectividad de las acciones de cobro

## Validaciones y Controles
- Valida que el rango de fechas sea correcto
- Verifica que existan folios pagados en el periodo
- Controla el acceso por oficina recaudadora
- Valida permisos del usuario
- Asegura la integridad de los cálculos

## Casos de Uso
1. **Director de Ingresos**: Solicita reporte mensual de gastos cobrados
2. **Jefe de Ejecutores**: Evalúa desempeño de su personal
3. **Contador**: Requiere información para conciliación de ingresos
4. **Supervisor**: Genera estadísticas para reunión de resultados
5. **Auditor**: Revisa recuperación de gastos de ejecución

## Usuarios del Sistema
- Directores y subdirectores
- Jefes de ejecutores fiscales
- Contadores y personal financiero
- Supervisores de cobro
- Auditores internos y externos
- Coordinadores administrativos

## Relaciones con Otros Módulos
- **Recuperacion**: Registra los pagos que generan los gastos
- **Prenomina**: Cálculo de incentivos basados en gastos cobrados
- **Ejecutores**: Información del personal responsable
- **ConsultaReg**: Consulta detallada de folios
- **Facturacion**: Certificación de pagos con gastos
