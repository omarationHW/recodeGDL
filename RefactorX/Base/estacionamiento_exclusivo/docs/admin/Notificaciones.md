# Notificaciones - Generación de Notificaciones Oficiales

## Propósito Administrativo
Genera e imprime notificaciones oficiales subsecuentes al requerimiento de pago. Son documentos legales que continúan el procedimiento administrativo de ejecución cuando el contribuyente no pagó después del requerimiento inicial.

## Funcionalidad Principal
Módulo similar a Requerimientos.pas pero enfocado en notificaciones posteriores del procedimiento de apremio. Genera documentos oficiales de notificación, controla entregas y citatorios, actualiza estado de folios y documenta el avance del procedimiento de cobro coactivo.

## Proceso de Negocio

### ¿Qué hace?
- Genera notificaciones oficiales para folios existentes
- Registra fechas de diligencias (entregas, citatorios)
- Actualiza gastos de ejecución por cada diligencia
- Imprime documentos oficiales de notificación
- Controla segunda y tercera entrega de notificaciones
- Programa citatorios cuando no se localiza al contribuyente
- Documenta resultado de cada diligencia
- Actualiza montos con gastos adicionales

### ¿Para qué sirve?
- Continuar el procedimiento cuando no hubo pago por requerimiento
- Agotar instancias de notificación antes del embargo
- Cumplir requisitos legales de notificación múltiple
- Documentar intentos de localización del contribuyente
- Actualizar gastos de ejecución por diligencias
- Fundamentar proceder al embargo por falta de pago
- Generar evidencia legal del procedimiento completo

### ¿Cómo lo hace?
1. Usuario selecciona folios que requieren notificación adicional
2. Define tipo de diligencia (primera entrega, segunda entrega, citatorio)
3. Asigna o confirma ejecutor responsable
4. Sistema:
   - Actualiza fecha de la diligencia correspondiente
   - Suma gastos de notificación al adeudo
   - Actualiza monto global del folio
   - Cambia estado de diligencia
5. Genera documento oficial de notificación con:
   - Referencia al folio de apremio
   - Datos actualizados del adeudo
   - Tipo de diligencia realizada
   - Resultado de la diligencia
   - Fundamento legal
   - Firma del ejecutor
6. Imprime notificación para entregar al contribuyente

### ¿Qué necesita para funcionar?
- Folios de apremio existentes con requerimiento previo
- Tipo de diligencia a realizar
- Ejecutor asignado
- Catálogo de gastos actualizado
- Plantillas de documentos oficiales
- Fechas de diligencias

## Datos y Tablas

### Tabla Principal
**ta_15_apremios**: Actualiza fechas de diligencias y gastos

### Tablas Relacionadas
- **ta_15_ejecutores**: Ejecutores que practican notificaciones
- **ta_15_gastos**: Gastos por tipo de diligencia
- **ta_11_locales / ta_16_contratos_aseo**: Información de cuentas
- **ta_15_detalle**: Detalle de adeudos

### Stored Procedures (SP)
Posiblemente utiliza SP para actualizar gastos y fechas

### Tablas que Afecta
**Actualiza:**
- ta_15_apremios (fechas de diligencias, gastos, estado)

**Consulta:**
- Todas las tablas de soporte mencionadas

## Impacto y Repercusiones

### Repercusiones Operativas
- Documenta avance del procedimiento
- Justifica proceder a embargo
- Registra actuaciones de ejecutores
- Controla tiempos del procedimiento

### Repercusiones Financieras
- Incrementa adeudo con gastos de notificación
- Documenta costos de cobro ejecutivo
- Justifica montos adicionales cobrados

### Repercusiones Administrativas
- Cumple requisitos legales del procedimiento
- Genera evidencia para defensas legales
- Documenta agotamiento de instancias
- Permite auditoría de diligencias

## Validaciones y Controles
- Valida que folio exista y esté vigente
- Requiere requerimiento previo
- Controla secuencia de diligencias
- Valida fechas (no permite fechas futuras ni anteriores al requerimiento)
- Control transaccional de actualizaciones

## Casos de Uso

**Primera entrega no recibida:**
- Ejecutor intentó notificar pero contribuyente no estaba
- Registra primera entrega sin éxito
- Sistema suma gastos de primera entrega
- Imprime acta de diligencia

**Segunda entrega:**
- Ejecutor regresa a notificar
- Encuentra al contribuyente
- Registra segunda entrega exitosa
- Imprime notificación recibida

**Citatorio:**
- Después de dos entregas sin localizar contribuyente
- Se programa citatorio
- Sistema registra fecha y hora
- Imprime citatorio oficial

## Usuarios del Sistema
- Ejecutores fiscales
- Coordinador de notificaciones
- Supervisores de ejecución
- Personal de control de diligencias

## Relaciones con Otros Módulos
- **Requerimientos.pas**: Genera folios que luego requieren notificaciones
- **Individual.pas**: Consulta estado de diligencias
- **Prenomina.pas**: Considera gastos por diligencias
- **Listados.pas**: Reportes de notificaciones
- **NotificacionesMes.pas**: Reporte mensual de notificaciones
