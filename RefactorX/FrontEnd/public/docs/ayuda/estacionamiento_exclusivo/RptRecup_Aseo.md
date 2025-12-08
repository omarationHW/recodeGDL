# Reporte: Recuperación de Adeudos de Aseo

## Propósito Administrativo
Módulo de generación de reportes de recuperación de adeudos de aseo contratado. Produce documentos oficiales con el detalle de pagos recibidos y análisis de recuperación de cartera.

## Funcionalidad Principal
Genera formatos oficiales de reportes de recuperación de aseo, mostrando contratos que pagaron, montos recuperados y análisis de efectividad del cobro.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos de recuperación de aseo con formato institucional, detallando pagos recibidos por contrato, empresa y periodo.

### ¿Para qué sirve?
- Documentar recuperación de cartera de aseo
- Analizar efectividad de cobro
- Generar estadísticas de pagos
- Apoyar proyecciones de ingresos
- Evaluar gestión de cobranza

### ¿Cómo lo hace?
1. Recibe parámetros del módulo Recuperacion
2. Filtra pagos de aseo en el periodo
3. Agrupa por contrato y empresa
4. Calcula totales y porcentajes
5. Genera documento con análisis

## Datos y Tablas
Dataset de ta_15_apremios con pagos de aseo.

## Usuarios del Sistema
Invocado por el módulo Recuperacion.

## Relaciones con Otros Módulos
- **Recuperacion**: Módulo invocador
- **RptRecup_Merc**: Reporte similar para mercados
