# EdoCuenta - Migración Delphi a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite la consulta y emisión de estados de cuenta para convenios de regularización de predios. Incluye la visualización de adeudos, pagos, recargos y permite la impresión de reportes detallados.

## Arquitectura
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL con lógica encapsulada en stored procedures.
- **API**: Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Flujo de Trabajo
1. El usuario accede a la página de EdoCuenta.
2. Selecciona el Tipo y Subtipo de convenio.
3. El frontend envía la petición a `/api/execute` con `{ eRequest: { action: 'list', tipo, subtipo } }`.
4. El backend ejecuta el stored procedure `edo_cuenta_list` y retorna los resultados.
5. El usuario puede solicitar la impresión, que ejecuta `edo_cuenta_report`.
6. Los cálculos de recargos y sumas de pagos se realizan mediante SPs dedicados.

## API Detalle
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ eRequest: { action: 'list'|'report'|'recargos'|'sumPagos', ...params } }`
- **Salida**: `{ eResponse: { success, data, message } }`

## Stored Procedures
- `edo_cuenta_list(tipo, subtipo)`: Lista los convenios y adeudos.
- `edo_cuenta_report(tipo, subtipo)`: Reporte detallado para impresión.
- `edo_cuenta_calc_recargos(id_conv_resto, pago_parcial)`: Calcula recargos.
- `edo_cuenta_sum_pagos(id_conv_resto)`: Suma pagos y recargos.

## Seguridad
- Validación de parámetros en el controlador.
- Uso de funciones parametrizadas para evitar SQL Injection.

## Consideraciones
- El frontend debe manejar la carga de tipos y subtipos (puede ser por catálogo o endpoint adicional).
- El reporte de impresión puede ser generado en PDF o mostrado en pantalla.
- Los cálculos de recargos consideran días inhábiles y vencimientos según la lógica original.

## Migración de Lógica Delphi
- Los métodos `FormShow`, `FlatCboxLocTipoChange`, y cálculos de recargos se migraron a SPs y lógica Vue.
- El flujo de cierre y apertura de queries se maneja automáticamente en PostgreSQL.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.

