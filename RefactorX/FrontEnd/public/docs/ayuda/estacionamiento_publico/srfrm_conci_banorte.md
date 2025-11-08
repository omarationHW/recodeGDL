# srfrm_conci_banorte - Sistema de Estacionamientos

## Proposito Administrativo

Modulo del sistema integral de gestion de estacionamientos municipales que contribuye a las operaciones diarias de control, cobro y administracion de espacios de estacionamiento publicos y exclusivos.

## Funcionalidad Principal

Componente especializado del sistema que procesa operaciones especificas relacionadas con folios, pagos, concesiones, reportes o administracion de estacionamientos en la ciudad de Guadalajara.

## Proceso de Negocio

### Que hace
- Ejecuta operaciones administrativas del sistema de estacionamientos
- Procesa transacciones relacionadas con folios e infracciones
- Gestiona datos de vehiculos, propietarios y concesiones
- Genera reportes y consultas para supervisión y auditoria

### Para que
- Facilitar la administracion eficiente de estacionamientos municipales
- Garantizar control de ingresos por cobro de folios
- Mantener registro actualizado de concesiones y contratos
- Proveer informacion para toma de decisiones administrativas

### Como funciona
El modulo se integra al sistema principal accediendo a la base de datos esta_ifx mediante procedimientos almacenados y consultas SQL. Implementa validaciones de negocio y mantiene integridad transaccional.

### Que necesita
- Conexion activa a base de datos esta_ifx (Informix)
- Usuario con permisos adecuados
- Sesion iniciada en el sistema
- Datos basicos configurados (catalogos, parametros)

## Datos y Tablas

### Tablas principales del sistema
- ta14_folios_adeudo: folios vigentes pendientes de pago
- ta14_folios_histo: historico de folios pagados/cancelados
- ta14_infraccion: catalogo de tipos de infraccion
- ta14_tarifas: montos de infracciones por periodo
- ta14_refrecibo: recibos de pago emitidos
- ta14_publicos: estacionamientos publicos concesionados
- ta14_exclusivos: estacionamientos exclusivos/privados
- ta14_contratos: contratos de concesion
- ta14_recaudadoras: oficinas recaudadoras
- ta14_bitacora: registro de operaciones batch

## Impacto y Repercusiones

### Impacto operativo
La correcta operacion de este modulo impacta directamente en:
- Recaudacion de ingresos municipales por estacionamientos
- Calidad del servicio al ciudadano
- Integridad de informacion administrativa
- Cumplimiento de contratos de concesion

### Repercusiones
Fallas o errores pueden generar:
- Perdida de ingresos o duplicidad de cobros
- Inconsistencia en padrones de vehiculos
- Problemas en conciliaciones bancarias
- Incumplimiento de obligaciones contractuales

## Validaciones

El modulo implementa validaciones estandar:
1. Existencia de registros antes de operaciones
2. Integridad referencial entre tablas
3. Rangos validos de fechas y montos
4. Permisos de usuario para operacion
5. Estados validos de registros (vigente, pagado, cancelado)

## Casos de Uso

### Caso general de operacion
1. Usuario accede al modulo desde menu principal
2. Selecciona criterios u opciones de operacion
3. Sistema valida datos y permisos
4. Ejecuta operacion solicitada
5. Confirma resultado al usuario
6. Registra operacion para auditoria

## Usuarios del Modulo

- Personal de ventanilla (cajeros)
- Supervisores operativos
- Administradores del sistema
- Personal de auditoria y control
- Concesionarios de estacionamientos

## Relaciones con Otros Modulos

- sFrm_menu: menu principal del sistema
- DsDBGasto: modulo de conexion a base de datos
- UnDatos: almacen de variables globales de sesion
- mensaje: despliegue de alertas y mensajes
- Otros modulos especificos segun funcionalidad

## Notas Importantes

- Modulo desarrollado en Delphi para ambiente Windows
- Utiliza base de datos Informix (esta_ifx)
- Implementa transacciones para mantener consistencia
- Genera logs de operaciones para auditoria
- Requiere configuracion previa de parametros del sistema

---
*Documentacion generada para sistema de Estacionamientos Municipales de Guadalajara*
*Para informacion tecnica detallada consultar codigo fuente srfrm_conci_banorte.pas*
