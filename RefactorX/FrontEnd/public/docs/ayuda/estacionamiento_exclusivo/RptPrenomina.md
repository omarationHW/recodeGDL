# Reporte: Prenómina de Ejecutores

## Propósito Administrativo
Módulo de generación de reportes de prenómina para cálculo de incentivos de ejecutores fiscales. Produce documentos oficiales con el detalle de folios practicados y pagados para determinar compensaciones.

## Funcionalidad Principal
Genera formatos oficiales de prenómina mostrando la productividad de ejecutores, cantidades de folios practicados, pagados y montos recaudados para cálculo de incentivos.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos de prenómina con formato institucional, detallando la gestión de cada ejecutor con cantidades de folios, montos recuperados y cálculos de incentivos.

### ¿Para qué sirve?
- Generar información para incentivos
- Documentar productividad de ejecutores
- Calcular compensaciones variables
- Apoyar decisiones de recursos humanos
- Facilitar pago de incentivos

### ¿Cómo lo hace?
1. Recibe parámetros del módulo Prenomina
2. Obtiene estadísticas por ejecutor
3. Calcula totales de folios y montos
4. Aplica fórmulas de incentivos
5. Genera documento oficial con firmas

## Datos y Tablas
Dataset de ta_15_apremios agrupado por ejecutor.

## Usuarios del Sistema
Invocado por el módulo Prenomina.

## Relaciones con Otros Módulos
- **Prenomina**: Módulo invocador
- **Lista_GastosCob**: Estadísticas relacionadas
- **Ejecutores**: Datos del personal
