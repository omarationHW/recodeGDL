# Reporte: Requerimiento de Pago de Aseo

## Propósito Administrativo
Módulo de generación de documentos oficiales de requerimiento de pago para contratos de aseo contratado. Produce los formatos legales de notificación con todos los elementos requeridos por ley.

## Funcionalidad Principal
Genera formatos oficiales de requerimientos de pago de aseo con diseño institucional, incluyendo fundamentos legales, datos del contrato, empresa, adeudos, recargos, gastos y firma de autoridad.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos legales de requerimiento de pago de aseo con formato oficial, incluyendo todos los elementos legales necesarios, cálculos de adeudos y fundamentación jurídica.

### ¿Para qué sirve?
- Generar requerimientos oficiales de aseo
- Formalizar procedimiento de cobro coactivo
- Cumplir requisitos legales de notificación
- Documentar adeudos con validez jurídica
- Iniciar formalmente el procedimiento de ejecución

### ¿Cómo lo hace?
1. Recibe datos del folio de aseo emitido
2. Obtiene información completa del contrato
3. Calcula adeudos, recargos y gastos
4. Aplica formato oficial con logos
5. Incluye fundamento legal completo
6. Agrega firma electrónica de autoridad
7. Genera documento con validez legal

## Datos y Tablas
Dataset del folio con ta_16_contratos_aseo y ta_16_adeudos_aseo.

## Usuarios del Sistema
Invocado por módulos de emisión (Individual, CMultEmision).

## Relaciones con Otros Módulos
- **Individual**: Emisión individual de aseo
- **CMultEmision**: Emisión masiva de aseo
- **RptReq_Merc**: Requerimiento similar para mercados
