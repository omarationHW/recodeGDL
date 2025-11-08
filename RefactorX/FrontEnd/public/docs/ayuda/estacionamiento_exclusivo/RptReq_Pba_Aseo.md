# Reporte: Requerimiento de Pago Combinado

## Propósito Administrativo
Módulo de generación de documentos oficiales de requerimiento de pago con formato combinado o especial. Produce formatos legales adaptados para casos particulares o múltiples servicios.

## Funcionalidad Principal
Genera formatos oficiales de requerimientos de pago con diseño adaptable, permitiendo incluir información de diferentes tipos de servicios o formatos especiales según necesidades específicas.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos legales de requerimiento con formato flexible, adaptándose a diferentes tipos de servicios o combinaciones, manteniendo validez legal y formato institucional.

### ¿Para qué sirve?
- Generar requerimientos de casos especiales
- Atender necesidades de formatos combinados
- Mantener flexibilidad en documentos oficiales
- Adaptar a diferentes tipos de servicios
- Cumplir requisitos legales en casos particulares

### ¿Cómo lo hace?
1. Recibe datos del folio y tipo de servicio
2. Adapta el formato según el caso
3. Incluye información específica requerida
4. Aplica diseño oficial
5. Mantiene fundamento legal
6. Genera documento adaptado

## Datos y Tablas
Dataset variable según el tipo de servicio.

## Usuarios del Sistema
Invocado por módulos de emisión para casos especiales.

## Relaciones con Otros Módulos
- **RptReq_Aseo**: Formato específico de aseo
- **RptReq_pba**: Formato específico de estacionamientos
- **Individual**: Puede invocar este reporte
