# Listados con Adeudos

## Propósito Administrativo
Generar listados impresos de contribuyentes con adeudos vencidos, mostrando el detalle de periodos adeudados, importes, recargos y gastos acumulados, útil para planeación de emisión de requerimientos y análisis de cartera vencida.

## Funcionalidad Principal
Este módulo genera reportes detallados de contribuyentes que tienen adeudos vencidos, calculando automáticamente recargos moratorios acumulados y mostrando el monto total adeudado por cada contribuyente.

## Proceso de Negocio

### ¿Qué hace?
Consulta y lista todos los contribuyentes con adeudos vencidos en un mercado, tipo de aseo o rango específico, calculando para cada uno el total de periodos adeudados, el importe original, los recargos acumulados y el total a pagar.

### ¿Para qué sirve?
- Identificar contribuyentes con adeudos susceptibles de apremio
- Planear la emisión de requerimientos de pago
- Conocer el monto de cartera vencida por zona
- Priorizar acciones de cobro por monto adeudado
- Generar estadísticas de morosidad
- Apoyar estrategias de recuperación de cartera

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de aplicación (Mercados o Aseo)
2. Define el mercado o tipo de aseo específico
3. Puede filtrar por todos los registros o un rango específico
4. El sistema consulta todos los adeudos vencidos
5. Calcula recargos moratorios por cada periodo
6. Suma los gastos de ejecución acumulados (si los hay)
7. Totaliza el monto adeudado por contribuyente
8. Genera el listado ordenado por número de control
9. Muestra totales generales al final del reporte

### ¿Qué necesita para funcionar?
- Usuario con permisos de consulta
- Selección de mercado o tipo de aseo
- Tabla de recargos actualizada
- Tabla de gastos de ejecución vigente
- Adeudos registrados en la base de datos

## Datos y Tablas

### Tabla Principal
- **ta_11_adeudo_local**: Adeudos de locales en mercados
- **ta_16_adeudos_aseo**: Adeudos de aseo contratado

### Tablas Relacionadas
- **ta_11_locales**: Datos de locales en mercados
- **ta_16_contratos_aseo**: Contratos de aseo
- **ta_12_recargos**: Porcentajes de recargos moratorios
- **ta_15_apremios**: Gastos de ejecución acumulados
- **ta_11_mercados**: Información de mercados
- **ta_16_tipos_aseo**: Tipos de aseo contratado

### Stored Procedures (SP)
No utiliza stored procedures. Realiza consultas SQL complejas con cálculos de recargos.

### Tablas que Afecta
Este módulo es de solo consulta. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita la planeación de emisión de requerimientos
- Permite priorizar acciones de cobro
- Identifica casos críticos de morosidad
- Apoya la distribución de cargas de trabajo

### Repercusiones Financieras
- Cuantifica la cartera vencida por zona
- Documenta el monto recuperable por recargos
- Permite proyectar ingresos por cobro coactivo
- Apoya análisis de riesgo crediticio

### Repercusiones Administrativas
- Genera información para toma de decisiones
- Documenta el estado de la cartera de cobro
- Facilita reportes gerenciales
- Apoya estrategias de recuperación de adeudos
- Permite evaluación de gestión de cobro

## Validaciones y Controles
- Valida que existan adeudos vencidos
- Calcula correctamente los recargos moratorios
- Verifica que los adeudos estén dentro del periodo
- Aplica correctamente el tope máximo de recargos
- Controla el acceso por oficina recaudadora

## Casos de Uso
1. **Jefe de Cobro Coactivo**: Planea emisión mensual de requerimientos
2. **Director de Ingresos**: Solicita reporte de cartera vencida
3. **Supervisor**: Identifica contribuyentes con mayor adeudo para atención prioritaria
4. **Contador**: Requiere información para estimación de ingresos recuperables
5. **Auditor**: Revisa el estado de la cartera de cobro del área

## Usuarios del Sistema
- Directores y subdirectores de ingresos
- Jefes de cobro coactivo
- Supervisores de área
- Contadores y personal financiero
- Auditores
- Coordinadores administrativos

## Relaciones con Otros Módulos
- **CMultEmision**: Emisión masiva de requerimientos basada en estos listados
- **Individual**: Emisión individual de casos específicos
- **CartaInvitacion**: Notificación previa a contribuyentes listados
- **Recuperacion**: Seguimiento de pagos de los adeudos listados
- **ConsultaReg**: Consulta detallada de cada contribuyente
