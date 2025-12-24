# AplicaPgo_DivAdmin - Sistema de Estacionamientos

## Proposito Administrativo

Aplicar pagos realizados en el sistema DIVERSOS ADMIN a los folios correspondientes en el sistema de estacionamientos. Permite sincronizar pagos efectuados en otra dependencia municipal.

## Funcionalidad Principal

Buscar folios pendientes y aplicarles pagos que fueron registrados en el sistema administrativo del Ayuntamiento (DIVERSOS ADMIN), vinculando ambos sistemas para mantener actualizado el estado de los folios.

## Proceso de Negocio

### Que hace
- Busca folios por placa, placa+folio o año+folio
- Muestra folios vigentes que requieren aplicacion de pago
- Permite seleccionar multiples folios
- Aplica datos de pago: fecha, recaudadora, caja, folio de recibo, operacion
- Actualiza estado del folio a pagado con datos de DIVERSOS ADMIN

### Para que
- Sincronizar pagos entre sistema de estacionamientos y sistema administrativo municipal
- Evitar duplicidad de cobranza
- Mantener actualizado el estado real de folios
- Permitir que pagos en otras oficinas se reflejen en estacionamientos

### Como funciona
1. Usuario selecciona criterio busqueda (placa, placa+folio, año+folio)
2. Ingresa datos y presiona buscar
3. Sistema muestra folios vigentes encontrados
4. Usuario selecciona folios en grid (puede marcar varios)
5. Presiona boton aplicar pagos
6. Captura datos del pago: fecha, recaudadora, caja, operacion
7. Sistema ejecuta procedimiento almacenado por cada folio seleccionado
8. Actualiza tabla de folios con datos del pago
9. Muestra resultado: cuantos exitosos, cuantos con error

### Que necesita
- Folios existentes en estado vigente (no pagados, no cancelados)
- Datos del pago realizados en DIVERSOS ADMIN: recaudadora, caja, numero operacion
- Procedimiento almacenado sp14_AplPgo_DivAdmin en base de datos
- Catalogo de recaudadoras actualizado

## Datos y Tablas

### Tablas consultadas
- **ta14_folios_adeudo**: busca folios vigentes por placa/año/folio
- **ta14_tarifas**: obtiene tarifa vigente segun infraccion y fecha
- **ta14_folios_free**: verifica descuentos aplicados
- **ta14_notifica_edo**: datos de notificacion si existe
- **ta14_recaudadoras**: catalogo de oficinas recaudadoras

### Tablas afectadas
- Procedimiento sp14_AplPgo_DivAdmin actualiza el folio con datos de pago

### Datos clave
- Placa del vehiculo
- Año y folio de infraccion
- Fecha del pago
- Recaudadora (oficina que cobro)
- Caja (terminal de cobro)
- Consecutivo de operacion
- Usuario que aplica

## Impacto y Repercusiones

### Impacto operativo
- MEDIO-ALTO: Sincroniza informacion entre dos sistemas municipales
- Evita que ciudadano pague dos veces el mismo folio
- Mantiene consistencia de datos

### Repercusiones
- Error en aplicacion genera folio pagado en DIVERSOS pero pendiente en ESTACIONAMIENTOS
- Datos incorrectos (caja, operacion) dificultan conciliaciones
- No aplicar pagos genera duplicidad de adeudos
- Aplicacion masiva erronea requiere reversion manual

## Validaciones

1. Folio existe en tabla de adeudos
2. Folio esta en estado vigente (no pagado previamente)
3. Fecha de pago es valida
4. Recaudadora existe en catalogo
5. Datos de caja y operacion no vacios
6. Usuario registrado en sistema

## Casos de Uso

### Caso 1: Aplicar pago por placa
1. Ciudadano pago folio en oficina de Atencion Ciudadana (DIVERSOS ADMIN)
2. Operador de estacionamientos recibe notificacion
3. Abre modulo, selecciona busqueda por placa
4. Ingresa placa del vehiculo
5. Sistema muestra folios vigentes de esa placa
6. Selecciona el folio correspondiente
7. Captura: fecha pago, recaudadora 05, caja A, operacion 12345
8. Aplica pago
9. Folio queda marcado como pagado

### Caso 2: Aplicar multiple folios de un vehiculo
1. Vehiculo tiene 5 folios pendientes
2. Propietario pago todos en DIVERSOS ADMIN
3. Operador busca por placa
4. Sistema muestra los 5 folios
5. Selecciona los 5 (marca en grid)
6. Captura datos del pago (misma fecha, recaudadora, operaciones consecutivas)
7. Aplica en bloque
8. Los 5 folios quedan pagados

### Caso 3: Error en aplicacion
1. Operador busca folio por año+folio
2. Selecciona folio correcto
3. Por error captura caja equivocada
4. Aplica pago
5. Sistema confirma aplicacion
6. Al revisar bitacora detecta error
7. Debe solicitar a supervisor corregir datos

## Usuarios del Modulo

- Operadores administrativos: aplican pagos de DIVERSOS ADMIN
- Supervisores: verifican aplicaciones correctas
- Personal de conciliacion: validan sincronizacion entre sistemas

## Relaciones con Otros Modulos

- DIVERSOS ADMIN (sistema externo): fuente de informacion de pagos
- DsDBGasto: conexion a base de datos
- UnDatos: datos de usuario que aplica
- sp14_AplPgo_DivAdmin: procedimiento almacenado que ejecuta la aplicacion
- Tablas ta14_*: actualizan estado de folios

## Notas Importantes

- Cada folio se procesa en transaccion individual (commit/rollback por folio)
- Si hay errores, muestra cuantos registros NO se aplicaron
- Usuario que aplica queda registrado para auditoria
- Fecha de pago puede ser diferente a fecha de aplicacion
- La recaudadora debe existir en catalogo (01-99)
- Caja es texto libre (A, B, C, 01, etc)
- Numero de operacion es entero consecutivo
- IMPORTANTE: No valida si el pago ya fue aplicado previamente
