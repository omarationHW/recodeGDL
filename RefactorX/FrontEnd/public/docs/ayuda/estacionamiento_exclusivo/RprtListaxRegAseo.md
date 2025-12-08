# Reporte: Listados por Registro de Aseo

## Propósito Administrativo
Módulo de generación del reporte impreso de folios de aseo contratado filtrados por tipo. Produce documentos oficiales específicos para el servicio de aseo.

## Funcionalidad Principal
Genera el formato impreso de listados de folios de aseo organizados por tipo de servicio, aplicando diseño oficial y presentando información específica del contrato.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos físicos de listados de aseo aplicando formato institucional, mostrando información del contrato, empresa y datos del folio.

### ¿Para qué sirve?
- Generar reportes específicos de aseo
- Aplicar formato para gestión de contratos
- Producir listados por tipo de aseo
- Facilitar seguimiento de cobro en aseo

### ¿Cómo lo hace?
1. Recibe parámetros del módulo ListxReg (tipo de aseo)
2. Aplica formato oficial
3. Incluye datos del contrato y empresa
4. Organiza por tipo de aseo
5. Genera documento con información completa

## Datos y Tablas
Dataset de ta_15_apremios con ta_16_contratos_aseo.

## Usuarios del Sistema
Invocado por el módulo ListxReg para aseo.

## Relaciones con Otros Módulos
- **ListxReg**: Módulo invocador
- **RptListado_Aseo**: Reporte relacionado
