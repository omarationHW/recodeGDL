# Reporte: Recuperación de Adeudos de Mercados

## Propósito Administrativo
Módulo de generación de reportes de recuperación de adeudos de mercados. Produce documentos oficiales con el detalle de pagos recibidos y análisis de recuperación por mercado.

## Funcionalidad Principal
Genera formatos oficiales de reportes de recuperación de mercados, mostrando locales que pagaron, montos recuperados y análisis de efectividad por mercado.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos de recuperación de mercados con formato institucional, detallando pagos recibidos por local, mercado y periodo.

### ¿Para qué sirve?
- Documentar recuperación de cartera de mercados
- Analizar efectividad por mercado
- Generar estadísticas de cobranza
- Apoyar decisiones de gestión
- Evaluar desempeño de cobro

### ¿Cómo lo hace?
1. Recibe parámetros del módulo Recuperacion
2. Filtra pagos de mercados en el periodo
3. Agrupa por mercado y local
4. Calcula totales y análisis
5. Genera documento oficial

## Datos y Tablas
Dataset de ta_15_apremios con pagos de mercados.

## Usuarios del Sistema
Invocado por el módulo Recuperacion.

## Relaciones con Otros Módulos
- **Recuperacion**: Módulo invocador
- **RptRecup_Aseo**: Reporte similar para aseo
