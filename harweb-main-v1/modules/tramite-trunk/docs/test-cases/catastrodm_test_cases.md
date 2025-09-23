# Casos de Prueba Catastro Laravel + Vue.js

## Caso 1: Consulta de Cuenta Catastral
- **Entrada**: recaud=1, urbrus='U', cuenta=123456
- **Acción**: Buscar cuenta
- **Esperado**: Se muestra información de cuenta, propietarios y saldos.
- **Validación**: El campo 'cvecatnva' coincide con la cuenta buscada.

## Caso 2: Exentar Saldos
- **Entrada**: cvecuenta=123456, bimestre=2, año=2024, exento='S'
- **Acción**: Ejecutar exención vía SP
- **Esperado**: El saldo del bimestre/año aparece como exento, los totales se recalculan.
- **Validación**: El campo 'exento' en detsaldos es 'S', los saldos totales cambian.

## Caso 3: Modificar Propietario
- **Entrada**: cvereg=1, cvecont=1001, cvecuenta=123456, cveregprop=2, encabeza='S', porcentaje=100, exento='N', vigencia='V'
- **Acción**: Guardar cambios de propietario
- **Esperado**: Los datos del propietario se actualizan en la consulta.
- **Validación**: El propietario aparece con los nuevos datos en la tabla regprop.

## Caso 4: Error de Parámetros
- **Entrada**: action='getCatastroByCuenta', params={}
- **Acción**: Buscar sin cvecuenta
- **Esperado**: Error de validación
- **Validación**: eResponse.errors contiene mensaje de error.

## Caso 5: Seguridad
- **Entrada**: Usuario no autenticado
- **Acción**: Intentar cualquier acción
- **Esperado**: Error de autenticación
- **Validación**: eResponse.success = false, mensaje de error de autenticación.
