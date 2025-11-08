# Casos de Prueba

## Caso 1: Consulta básica de usuarios
- **Entrada:**
  - eRequest: getUsuariosPrivilegios
  - params: { campo: 'usuario', filtro: '', page: 1, perPage: 20 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene hasta 20 usuarios

## Caso 2: Filtro por nombre
- **Entrada:**
  - eRequest: getUsuariosPrivilegios
  - params: { campo: 'nombres', filtro: 'ana', page: 1, perPage: 20 }
- **Esperado:**
  - eResponse.success = true
  - Todos los usuarios en data tienen 'ana' en el nombre

## Caso 3: Consulta de permisos de usuario
- **Entrada:**
  - eRequest: getPermisosUsuario
  - params: { usuario: 'jlopez' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene los permisos del usuario 'jlopez'

## Caso 4: Consulta de auditoría de usuario
- **Entrada:**
  - eRequest: getAuditoriaUsuario
  - params: { usuario: 'jlopez' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene movimientos de auditoría

## Caso 5: Consulta de movimientos de trámites
- **Entrada:**
  - eRequest: getMovTramites
  - params: { usuario: 'jlopez', fechaini: '2024-01-01', fechafin: '2024-01-31' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene movimientos en ese rango de fechas

## Caso 6: Consulta de movimientos de licencias
- **Entrada:**
  - eRequest: getMovLicencias
  - params: { usuario: 'jlopez', fechaini: '2024-01-01', fechafin: '2024-01-31' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene movimientos de licencias

## Caso 7: Consulta de departamentos
- **Entrada:**
  - eRequest: getDeptos
  - params: { }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene lista de departamentos

## Caso 8: Consulta de revisiones
- **Entrada:**
  - eRequest: getRevisiones
  - params: { usuario: 'jlopez', fechaini: '2024-01-01', fechafin: '2024-01-31' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene revisiones realizadas por el usuario en ese periodo
