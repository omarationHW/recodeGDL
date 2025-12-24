# Prenomina - Generación de Prenómina de Ejecutores

## Propósito Administrativo
Genera el cálculo de comisiones y prenómina de ejecutores fiscales basado en los folios de apremio cobrados en un periodo determinado. Permite determinar el monto a pagar a cada ejecutor por su gestión de cobro.

## Funcionalidad Principal
Módulo que calcula y genera reportes de prenómina para ejecutores fiscales, considerando los gastos de ejecución cobrados en los folios que gestionaron, permitiendo determinar comisiones y pagos por periodo.

## Proceso de Negocio

### ¿Qué hace?
- Genera prenómina de ejecutores por periodo de fechas
- Calcula gastos de ejecución cobrados por ejecutor
- Permite generar para todas las recaudadoras o una específica
- Lista folios pagados por cada ejecutor
- Muestra RFC, nombre y datos del ejecutor
- Presenta resumen de gastos cobrados
- Genera reporte impreso de prenómina
- Agrupa información por ejecutor y recaudadora

### ¿Para qué sirve?
- Calcular comisiones de ejecutores por cobros realizados
- Determinar pagos a ejecutores por periodo
- Justificar pagos con base en folios cobrados
- Generar documentación de prenómina para recursos humanos
- Auditar productividad de ejecutores
- Distribuir presupuesto de comisiones por recaudadora

### ¿Cómo lo hace?
1. Usuario selecciona rango de fechas (inicio y fin)
2. Selecciona si desea prenómina de todas las recaudadoras o una específica
3. Sistema consulta folios pagados en ese periodo
4. Agrupa folios por ejecutor asignado
5. Suma gastos de ejecución por ejecutor
6. Genera lista de ejecutores con:
   - RFC del ejecutor
   - Nombre completo
   - Recaudadora
   - Número de folios cobrados
   - Total de gastos de ejecución
7. Genera reporte impreso con totales por ejecutor y recaudadora

### ¿Qué necesita para funcionar?
- Rango de fechas de pago a consultar
- Selección de recaudadora (todas o específica)
- Folios pagados con ejecutor asignado
- Catálogo de ejecutores con RFC y nombre
- Tabla de apremios con fecha de pago e importe de gastos

## Datos y Tablas

### Tabla Principal
**ta_15_apremios**: Folios de apremio pagados con gastos de ejecución

### Tablas Relacionadas
- **ta_15_ejecutores**: Datos de ejecutores (RFC, nombre)
- **ta_catalogo_recaudadoras** (Qryrec): Recaudadoras del sistema

### Stored Procedures (SP)
No utiliza stored procedures

### Tablas que Afecta
**Solo consulta** (no modifica):
- ta_15_apremios
- ta_15_ejecutores
- ta_catalogo_recaudadoras

## Impacto y Repercusiones

### Repercusiones Operativas
- Define compensación de ejecutores
- Mide productividad por ejecutor
- Facilita planificación de nómina
- Documenta trabajo realizado

### Repercusiones Financieras
- Determina monto a pagar por comisiones
- Afecta presupuesto de nómina
- Permite proyectar costos de cobranza
- Facilita análisis costo-beneficio de ejecución fiscal
- Documenta gastos de operación recuperados

### Repercusiones Administrativas
- Genera documentación para recursos humanos
- Facilita auditoría de pagos a ejecutores
- Permite evaluación de desempeño
- Documenta productividad por periodo
- Justifica presupuesto de comisiones

## Validaciones y Controles
- Valida que fechas estén capturadas
- Requiere selección de recaudadora si no es "todas"
- Solo considera folios efectivamente pagados
- Agrupa correctamente por ejecutor
- Valida que haya datos en el periodo seleccionado

## Casos de Uso

**Prenómina quincenal:**
- Coordinador requiere calcular pagos de quincena
- Selecciona fechas del 1 al 15 del mes
- Selecciona "Todas las recaudadoras"
- Sistema genera prenómina completa
- Se turna a recursos humanos para pago

**Prenómina por recaudadora:**
- Jefe de recaudadora requiere su prenómina
- Selecciona su recaudadora específica
- Define periodo mensual
- Obtiene prenómina solo de su área
- Valida contra su control interno

**Auditoría de comisiones:**
- Auditor revisa pagos de un ejecutor
- Genera prenómina del periodo auditado
- Verifica folios cobrados contra reporte
- Valida cálculo de comisiones
- Confirma o detecta inconsistencias

**Evaluación de productividad:**
- Supervisor analiza desempeño de ejecutores
- Genera prenómina del trimestre
- Compara número de folios cobrados por ejecutor
- Identifica ejecutores más productivos
- Toma decisiones de asignación de trabajo

## Usuarios del Sistema
- Coordinador de cobranza
- Jefes de recaudadora
- Personal de recursos humanos
- Contabilidad/finanzas
- Supervisores de ejecución fiscal
- Personal de auditoría

## Relaciones con Otros Módulos
- **Facturacion.pas**: Genera pagos que alimentan la prenómina
- **ABCEjec.pas / Ejecutores.pas**: Mantiene catálogo de ejecutores
- **Requerimientos.pas**: Asigna folios que generarán comisiones
- **Reasignacion.pas**: Reasignaciones afectan prenómina
- **Listados.pas**: Reportes complementarios de cobro
- **RptPrenomina.pas**: Reporte visual de la prenómina
