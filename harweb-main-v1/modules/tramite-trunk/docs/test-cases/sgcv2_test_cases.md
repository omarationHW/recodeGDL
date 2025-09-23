# Casos de Prueba SGCV2 Laravel + Vue + PostgreSQL

## 1. Consulta de Cuenta Catastral
- **Entrada**: recaud=1, urbrus='U', cuenta=12345
- **Acción**: buscarCuenta
- **Esperado**: Devuelve objeto cuenta con claveutm y datos completos.
- **Prueba**:
  - Llamar /api/execute con eRequest.action='buscarCuenta' y params.
  - Verificar que eResponse.cuenta.claveutm == '1-U-12345'.

## 2. Consulta de Propietarios
- **Entrada**: cvecuenta=123
- **Acción**: consultarPropietarios
- **Esperado**: Lista de propietarios asociados a la cuenta.
- **Prueba**:
  - Llamar /api/execute con eRequest.action='consultarPropietarios' y params.
  - Verificar que eResponse.propietarios es array y contiene al menos un propietario.

## 3. Cambio de Clave
- **Entrada**: usuario='jdoe', clave_actual='oldpass', clave_nueva='newpass123'
- **Acción**: cambiarClave
- **Esperado**: success=true
- **Prueba**:
  - Llamar /api/execute con eRequest.action='cambiarClave' y params.
  - Verificar que eResponse.success == true.

## 4. Autorización de Transmisión
- **Entrada**: folio=1001, usuario='admin'
- **Acción**: autorizarTransmision
- **Esperado**: success=true
- **Prueba**:
  - Llamar /api/execute con eRequest.action='autorizarTransmision' y params.
  - Verificar que eResponse.success == true.

## 5. Consulta de Horario de Usuario
- **Entrada**: usuario='jdoe'
- **Acción**: consultarHorarioUsuario
- **Esperado**: Devuelve objeto horario con hora_inicio, hora_termino, tolerancia.
- **Prueba**:
  - Llamar /api/execute con eRequest.action='consultarHorarioUsuario' y params.
  - Verificar que eResponse.horario.hora_inicio existe.

## 6. Consulta de Versión
- **Entrada**: (sin params)
- **Acción**: consultarVersion
- **Esperado**: Devuelve objeto version con version y permite_acceso.
- **Prueba**:
  - Llamar /api/execute con eRequest.action='consultarVersion'.
  - Verificar que eResponse.version.version es string.
