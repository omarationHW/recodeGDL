# Traslados - Gestión de Traslados de Restos

## Propósito Administrativo
Módulo para registrar y controlar el traslado de restos humanos entre diferentes espacios dentro de los cementerios municipales, documentando origen, destino y pago del servicio.

## Funcionalidad Principal
Permite registrar oficialmente el movimiento de restos desde un espacio funerario a otro, validando disponibilidad del destino, registrando el pago del servicio de traslado, y actualizando los registros correspondientes en el sistema.

## Proceso de Negocio

### ¿Qué hace?
Gestiona el proceso completo de traslados:
- Registro de datos del traslado (fecha, pago)
- Identificación del espacio origen (de donde se trasladan restos)
- Identificación del espacio destino (hacia donde se trasladan)
- Validación de disponibilidad del destino
- Registro del pago del servicio de traslado
- Documentación del motivo/observaciones
- Actualización de registros de origen y destino
- Generación de documentación del traslado

### ¿Para qué sirve?
Formaliza y documenta traslados de restos:
- Control legal de movimiento de restos
- Registro de cambios de ubicación
- Cobro de derecho por servicio de traslado
- Actualización de ocupación de espacios
- Trazabilidad de ubicación de restos
- Cumplimiento de normativa sanitaria y municipal

### ¿Cómo lo hace?
1. El operador captura información del pago:
   - Fecha del traslado
   - Recaudadora, caja, operación
   - Folio RCM de origen
2. El sistema valida:
   - Existencia del pago en sistema de ingresos
   - Que el folio origen esté activo
   - Que el folio origen tenga adeudos liquidados
3. Permite capturar folio RCM de destino
4. Valida que el destino:
   - Exista en el sistema
   - Esté disponible o sea del mismo concesionario
   - Tenga la capacidad necesaria
5. Registra el traslado asociando:
   - Pago del servicio
   - Folio origen
   - Folio destino
   - Observaciones del traslado
6. Puede actualizar el registro destino con datos del origen
7. Registra en histórico el movimiento
8. Genera documentación del traslado realizado

### ¿Qué necesita para funcionar?
- Pago de traslado registrado en ingresos
- Folio RCM origen válido y con adeudos al corriente
- Folio RCM destino disponible
- Autorización de traslado
- Documentación legal que respalde el traslado
- Permisos de usuario para registrar traslados

## Datos y Tablas

### Tabla Principal
**ta_13_pagosrcm** - Registro del pago por traslado (tipo específico)

### Tablas Relacionadas
- **ta_13_datosrcm** - Registros de espacios origen y destino
- **ta_13_adeudosrcm** - Validación de adeudos liquidados
- **ta_13_traslados** - Registro específico de traslados (si existe)
- **ta_ingresos** - Validación del pago
- **ta_historico** - Registro histórico del movimiento

### Stored Procedures (SP)
Posibles SP para:
- Validar disponibilidad de destino
- Registrar movimiento de traslado
- Actualizar histórico

### Tablas que Afecta
**Inserta:**
- ta_13_pagosrcm (pago del servicio)
- ta_13_traslados (registro del traslado)
- ta_historico (histórico del movimiento)

**Actualiza:**
- ta_13_datosrcm (puede actualizar observaciones o datos)

## Impacto y Repercusiones

### Repercusiones Operativas
- Control de movimientos dentro de panteones
- Actualización de ubicación de restos
- Coordinación con personal de panteones
- Programación de trabajos físicos

### Repercusiones Financieras
- Cobro de derecho por servicio de traslado
- Validación de adeudos previos liquidados
- Generación de ingresos por servicio adicional

### Repercusiones Administrativas
- Cumplimiento de normativa sanitaria
- Documentación legal del movimiento
- Actualización de registros oficiales
- Trazabilidad de ubicación de restos
- Respaldo ante controversias legales

## Validaciones y Controles
- Valida existencia del pago de traslado
- Verifica que folio origen exista y esté activo
- Valida que adeudos de origen estén liquidados
- Verifica disponibilidad del espacio destino
- Impide traslados sin pago registrado
- Requiere autorización para traslados especiales
- Valida que destino tenga capacidad suficiente
- Registra usuario que autoriza y ejecuta

## Casos de Uso
1. **Traslado por remodelación**: Mover restos temporalmente por obras
2. **Traslado a espacio familiar**: Reunir restos en una misma cripta
3. **Traslado por venta**: Mover restos por cesión del espacio
4. **Traslado definitivo**: Cambio permanente de ubicación
5. **Traslado entre panteones**: Mover entre cementerios municipales
6. **Traslado por mejora**: Cambiar a espacio de mejor categoría

## Usuarios del Sistema
- **Personal de Panteones**: Registro de traslados
- **Supervisores**: Autorización de traslados
- **Personal de Ventanilla**: Captura de solicitudes
- **Administradores**: Control y seguimiento

## Relaciones con Otros Módulos
- **ABCementer/ABCFolio**: Consulta y valida folios origen y destino
- **ABCPagos**: Valida pago del servicio
- **Liquidaciones**: Verifica adeudos liquidados de origen
- **ConsultaFol**: Consulta información completa de folios
- **Histórico**: Registra movimiento en histórico
