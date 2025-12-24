# Descuentos - Gestión de Descuentos Autorizados

## Propósito Administrativo
Módulo para administrar descuentos especiales autorizados sobre adeudos de mantenimiento anual, permitiendo aplicar porcentajes de reducción por períodos específicos a concesionarios que califiquen para este beneficio.

## Funcionalidad Principal
Permite registrar, modificar y controlar descuentos especiales sobre adeudos de mantenimiento, definiendo el porcentaje de descuento, el rango de años al que aplica, y manteniendo el control de vigencia y autorización de cada descuento.

## Proceso de Negocio

### ¿Qué hace?
Gestiona el ciclo completo de descuentos autorizados:
- Registro de nuevos descuentos por folio RCM
- Definición de porcentaje de descuento (1-100%)
- Especificación de años de aplicación (desde-hasta)
- Registro de autorización (fecha, usuario, recaudadora, caja, operación)
- Consulta de descuentos vigentes
- Reactivación de descuentos dados de baja
- Control de vigencia (Activo/Baja)

### ¿Para qué sirve?
Permite otorgar beneficios económicos especiales a:
- Adultos mayores
- Personas con discapacidad
- Casos sociales autorizados
- Concesionarios con convenios especiales
- Programas de regularización
- Campañas de incentivo al pago

### ¿Cómo lo hace?
1. El operador captura el folio RCM del beneficiario
2. Verifica la existencia del registro de cementerio
3. Define el descuento:
   - Porcentaje de descuento a aplicar
   - Año inicial de aplicación
   - Año final de aplicación
4. Registra la autorización del descuento:
   - Fecha de autorización
   - Recaudadora que autoriza
   - Número de caja
   - Número de operación de respaldo
5. El sistema valida que no exista un descuento activo para el mismo período
6. Genera el registro en ta_13_descuentos
7. El descuento se aplica automáticamente en el módulo ABCPagos al procesar pagos
8. Permite reactivar descuentos previamente dados de baja si es necesario
9. Mantiene histórico de todos los descuentos otorgados

### ¿Qué necesita para funcionar?
- Folio RCM válido y activo
- Autorización formal para otorgar descuento
- Definición clara del período de aplicación
- Documento de respaldo (operación de caja)
- Permisos de usuario para gestionar descuentos

## Datos y Tablas

### Tabla Principal
**ta_13_descuentos** - Registro de descuentos autorizados
Contiene: id_descto, control_rcm, axo_inicio, axo_fin, fecha_alta, usuario_alta, fecha_baja, usuario_baja, fecha_pago, id_rec, caja, operación, vigencia, porcentaje

### Tablas Relacionadas
- **ta_13_datosrcm** - Registro del espacio funerario
- **ta_13_adeudosrcm** - Adeudos a los que se aplicará el descuento
- **ta_usuarios** - Información de usuarios que autorizan
- **ta_recaudadoras** - Recaudadora que procesa la autorización

### Stored Procedures (SP)
Ninguno (usa SQL directo para INSERT, UPDATE, DELETE)

### Tablas que Afecta
**Inserta:**
- ta_13_descuentos (nuevo descuento autorizado)

**Actualiza:**
- ta_13_descuentos (modificación de porcentaje o período)
- ta_13_descuentos (cambio de vigencia para baja/reactivación)

**Marca como Baja:**
- ta_13_descuentos (vigencia="B")

## Impacto y Repercusiones

### Repercusiones Operativas
- Agiliza aplicación de políticas de descuento
- Reduce conflictos con usuarios beneficiados
- Control centralizado de autorizaciones
- Trazabilidad de descuentos otorgados

### Repercusiones Financieras
- Reducción de ingresos por mantenimiento
- Debe estar presupuestado y autorizado
- Impacta indicadores de cobranza
- Requiere justificación y respaldo documental
- Afecta cálculo de cuentas por cobrar

### Repercusiones Administrativas
- Cumplimiento de programas sociales
- Documentación de casos especiales
- Control de autorizaciones
- Base para auditoría de descuentos
- Transparencia en aplicación de beneficios

## Validaciones y Controles
- Valida existencia del folio RCM antes de registrar descuento
- Verifica que porcentaje esté entre 1 y 100
- Valida que año inicial sea menor o igual a año final
- Impide duplicar descuentos activos para el mismo folio y período
- Requiere datos completos de autorización (fecha, recaudadora, caja, operación)
- Permite reactivación solo de descuentos previamente dados de baja
- Control transaccional completo
- Registra usuario y fecha de cada operación

## Casos de Uso
1. **Descuento por adulto mayor**: Aplicar 50% de descuento permanente
2. **Descuento por discapacidad**: Reducción del 70% por documentación de discapacidad
3. **Campaña de regularización**: 30% de descuento temporal por 3 años
4. **Caso social**: Descuento del 100% autorizado por dirección
5. **Corrección de descuento**: Modificar porcentaje aplicado incorrectamente
6. **Cancelación de descuento**: Dar de baja descuento por cambio de condiciones
7. **Reactivación**: Volver a activar descuento temporalmente suspendido

## Usuarios del Sistema
- **Supervisores de Ventanilla**: Autorización de descuentos estándar
- **Jefes de Departamento**: Autorización de descuentos especiales
- **Trabajo Social**: Evaluación y solicitud de descuentos sociales
- **Contabilidad**: Consulta y control de descuentos aplicados
- **Auditoría**: Verificación de autorizaciones

## Relaciones con Otros Módulos
- **ABCementer/ABCFolio**: Consulta datos del registro para validar descuento
- **ABCPagos**: Aplica automáticamente descuentos registrados al procesar pagos
- **ConsultaFol**: Muestra descuentos autorizados en consulta individual
- **ConIndividual**: Presenta detalle de descuentos del folio
- **Liquidaciones**: Considera descuentos al calcular total a liquidar
- **Rep_a_Cobrar**: Reporta adeudos netos después de descuentos
