# Reporte: Requerimiento de Pago de Mercados

## Propósito Administrativo
Módulo de generación de documentos oficiales de requerimiento de pago para locales en mercados municipales. Produce los formatos legales de notificación con todos los elementos requeridos por ley.

## Funcionalidad Principal
Genera formatos oficiales de requerimientos de pago de mercados con diseño institucional, incluyendo fundamentos legales, datos del local, locatario, adeudos, recargos, gastos y firma de autoridad.

## Proceso de Negocio

### ¿Qué hace?
Produce documentos legales de requerimiento de pago de mercados con formato oficial, incluyendo todos los elementos legales necesarios, cálculos detallados y fundamentación jurídica.

### ¿Para qué sirve?
- Generar requerimientos oficiales de mercados
- Formalizar procedimiento de cobro coactivo
- Cumplir requisitos legales de notificación
- Documentar adeudos con validez jurídica
- Iniciar formalmente el procedimiento de ejecución

### ¿Cómo lo hace?
1. Recibe datos del folio de mercados emitido
2. Obtiene información completa del local
3. Calcula adeudos, recargos y gastos
4. Aplica formato oficial con logos
5. Incluye fundamento legal completo
6. Agrega firma electrónica de autoridad
7. Genera documento con validez legal

## Datos y Tablas
Dataset del folio con ta_11_locales y ta_11_adeudo_local.

## Usuarios del Sistema
Invocado por módulos de emisión (Individual, CMultEmision).

## Relaciones con Otros Módulos
- **Individual**: Emisión individual de mercados
- **CMultEmision**: Emisión masiva de mercados
- **RptReq_Aseo**: Requerimiento similar para aseo
