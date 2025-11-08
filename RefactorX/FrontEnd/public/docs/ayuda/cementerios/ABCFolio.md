# ABCFolio - Modificación de Registros por Folio

## Propósito Administrativo
Módulo especializado para localizar y modificar registros de espacios funerarios utilizando directamente el número de folio RCM (Registro de Cementerios Municipal).

## Funcionalidad Principal
Permite realizar cambios en la información de espacios funerarios existentes cuando se conoce el número de folio, agilizando el proceso de actualización sin necesidad de buscar por ubicación física o nombre del concesionario.

## Proceso de Negocio

### ¿Qué hace?
Facilita la modificación rápida de registros mediante:
- Búsqueda directa por número de folio RCM
- Modificación de datos del concesionario
- Actualización de ubicación física del espacio
- Cambio de tipo de espacio (Fosa/Urna/Gaveta)
- Actualización de información fiscal adicional
- Baja de registros con validaciones menos restrictivas que ABCementer

### ¿Para qué sirve?
Agiliza las operaciones de actualización cuando:
- El usuario ya conoce el folio del registro
- Se requieren correcciones administrativas urgentes
- Hay cambios de titularidad documentados
- Se necesita actualizar información fiscal o de contacto

### ¿Cómo lo hace?
1. El operador captura el número de folio RCM
2. El sistema recupera y muestra todos los datos del registro
3. Muestra historial de pagos, adeudos y descuentos aplicados
4. Permite editar: nombre, domicilio, ubicación física, metros, tipo, datos adicionales
5. Valida que los cambios estén autorizados (especialmente cambios de último año pagado)
6. Genera histórico del cambio antes de aplicar modificaciones
7. Recalcula adeudos automáticamente si cambia el último año pagado
8. Permite baja del registro (inclusive con pagos registrados, requiere autorización)

### ¿Qué necesita para funcionar?
- Folio RCM válido y existente
- Autorización especial para cambiar último año pagado
- Permisos de usuario para modificar/dar de baja
- Registro activo (vigencia="V")

## Datos y Tablas

### Tabla Principal
**ta_13_datosrcm** - Registro maestro de espacios funerarios

### Tablas Relacionadas
- **ta_13_datosrcmadic** - Información adicional (RFC, CURP, teléfono, IFE)
- **ta_13_pagosrcm** - Pagos realizados sobre el espacio
- **ta_13_adeudosrcm** - Adeudos pendientes y su detalle
- **ta_autoriza** - Control de usuarios autorizados para cambios críticos
- **ta_historico** - Histórico de modificaciones

### Stored Procedures (SP)
- **StrdPrcHis** - Graba snapshot del registro antes de modificar
  - Par_control: Folio RCM del registro
  - Par_ok: Indicador de éxito
  - Sobserv: Observaciones del proceso

- **StrdPrcABC** - Actualiza adeudos tras modificación
  - Par_control: Folio RCM
  - Par_opc: 2=Baja de adeudos, 3=Actualización
  - Par_usu: Usuario ejecutor

### Tablas que Afecta
**Actualiza:**
- ta_13_datosrcm (todos los campos editables)
- ta_13_datosrcmadic (información fiscal)
- ta_13_adeudosrcm (recálculo si cambia año pagado)

**Inserta:**
- ta_historico (registro de cada modificación)
- ta_13_datosrcmadic (si no existía información adicional)

**Marca como Baja:**
- ta_13_datosrcm (vigencia="B")
- ta_13_adeudosrcm (cancelación de adeudos)

## Impacto y Repercusiones

### Repercusiones Operativas
- Acceso rápido para correcciones urgentes
- Permite cambios administrativos ágiles
- Mantiene trazabilidad de todas las modificaciones
- Facilita actualización de datos incompletos o incorrectos

### Repercusiones Financieras
- Cambios en último año pagado afectan cálculo de adeudos
- Modificación de metros puede afectar tarifas futuras
- Bajas eliminan cuentas por cobrar pendientes
- Requiere autorización para cambios que afecten finanzas

### Repercusiones Administrativas
- Todo cambio queda registrado en histórico
- Cambios críticos requieren doble autorización
- Permite corregir errores de captura sin borrar registro
- Mantiene integridad referencial con pagos existentes

## Validaciones y Controles
- Verifica existencia del folio antes de permitir edición
- Valida que registro no esté dado de baja
- Controla que último año pagado no sea menor a (actual - 6 años)
- Controla que último año pagado no sea mayor a (actual + 1 año)
- Verifica autorización especial para cambiar último año pagado
- Consulta tabla ta_autoriza para validar permisos de usuario
- Impide modificaciones sin transacción completa
- Genera histórico obligatorio antes de cualquier cambio

## Casos de Uso
1. **Corrección de datos personales**: Cliente reporta error en nombre o domicilio registrado
2. **Actualización de titularidad**: Cambio de concesionario por venta o herencia
3. **Corrección de ubicación**: Error en captura de clase, sección, línea o fosa
4. **Agregar información fiscal**: Completar RFC, CURP solicitados posteriormente
5. **Ajuste de año pagado**: Con autorización, corregir último año de mantenimiento
6. **Baja por duplicado**: Eliminar registro capturado dos veces
7. **Cambio de tipo de espacio**: Convertir fosa a urna por remodelación

## Usuarios del Sistema
- **Supervisores de Ventanilla**: Correcciones y cambios autorizados
- **Administradores de Panteones**: Actualizaciones de registros
- **Personal de Archivo**: Actualización de datos históricos
- **Contabilidad**: Ajustes financieros autorizados

## Relaciones con Otros Módulos
- **ABCementer**: Complementa funcionalidad, ABCementer para altas, ABCFolio para cambios
- **ConsultaFol**: Muestra información detallada antes de modificar
- **ABCPagos**: Los pagos se asocian al folio, cambios afectan cálculos
- **Liquidaciones**: Bajas afectan cuentas por liquidar
- **Histórico**: Genera registro de cada modificación para auditoría
- **Títulos**: Cambios en datos se reflejan en títulos impresos
- **Descuentos**: Cambios en año pagado afectan aplicación de descuentos
