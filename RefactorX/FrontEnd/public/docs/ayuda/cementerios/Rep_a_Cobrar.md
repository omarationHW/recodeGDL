# Rep_a_Cobrar - Reporte de Cuentas por Cobrar

## Propósito Administrativo
Módulo que genera reportes detallados de adeudos pendientes de cobro, permitiendo análisis de cartera vencida, antigüedad de saldos y proyección de ingresos por concepto de mantenimiento.

## Funcionalidad Principal
Produce reportes consolidados de cuentas por cobrar con diferentes filtros y agrupaciones, mostrando adeudos, recargos, descuentos aplicables y totales netos por cobrar.

## Proceso de Negocio

### ¿Qué hace?
- Genera reporte de todos los adeudos pendientes
- Filtra por cementerio, recaudadora, rango de fechas
- Agrupa por antigüedad de adeudo
- Calcula recargos por mora
- Aplica descuentos y bonificaciones
- Muestra totales por panteón y global
- Permite exportación a Excel

### ¿Para qué sirve?
- Control de cartera por cobrar
- Análisis de antigüedad de saldos
- Proyección de ingresos
- Identificación de cuentas problema
- Base para campañas de cobranza
- Reportes para dirección y contabilidad

### ¿Cómo lo hace?
1. Usuario selecciona parámetros del reporte
2. Sistema consulta ta_13_adeudosrcm vigentes
3. Calcula recargos según tabla oficial
4. Aplica descuentos y bonificaciones
5. Agrupa según criterios seleccionados
6. Genera reporte con totales
7. Permite impresión o exportación

## Datos y Tablas
- **ta_13_adeudosrcm** - Adeudos pendientes
- **ta_13_datosrcm** - Información de espacios
- **ta_13_recargosrcm** - Cálculo de recargos
- **ta_13_descuentos** - Descuentos aplicables
- **ta_13_bonifrcm** - Bonificaciones

## Usuarios del Sistema
- Contabilidad
- Dirección Financiera
- Jefes de Departamento
- Personal de Cobranza
