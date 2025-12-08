# Reporte: Lista de Adeudos de Mercados

## Propósito Administrativo
Módulo de generación de reportes impresos de adeudos de locales en mercados. Produce documentos oficiales con el detalle de periodos adeudados y montos para planeación de cobro.

## Funcionalidad Principal
Genera formatos impresos de listados de adeudos en mercados, mostrando periodos vencidos, importes, recargos calculados y totales por local.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos de adeudos de mercados con formato oficial, calculando recargos automáticamente y mostrando el detalle completo por local y periodo.

### ¿Para qué sirve?
- Generar listados de adeudos para emisión
- Calcular automáticamente recargos
- Planear acciones de cobro
- Documentar cartera vencida

### ¿Cómo lo hace?
1. Recibe parámetros del módulo Listados_Ade
2. Aplica cálculo de recargos
3. Genera formato con detalles
4. Totaliza por local y global
5. Produce documento imprimible

## Datos y Tablas
Dataset de ta_11_adeudo_local con ta_11_locales.

## Usuarios del Sistema
Invocado por el módulo Listados_Ade.

## Relaciones con Otros Módulos
- **Listados_Ade**: Módulo invocador
- **CMultEmision**: Usa estos listados para emisión
