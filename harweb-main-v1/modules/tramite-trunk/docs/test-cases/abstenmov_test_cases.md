# Casos de Prueba: Abstención de Movimientos

## 1. Registrar abstención correctamente
- **Entrada:**
  - cvecuenta: 1001 (vigente)
  - axoefec: 2024
  - bimefec: 2
  - observacion: "Por solicitud del propietario."
  - usuario: "admin"
- **Acción:** registrar_abstencion
- **Esperado:** success=true, message='La abstención ha sido registrada', cvemov=12 en catastro

## 2. Eliminar abstención correctamente
- **Entrada:**
  - cvecuenta: 1001 (cvemov=12)
  - axoefec: 2024
  - bimefec: 2
  - observacion: "Se reactivan movimientos."
  - usuario: "admin"
- **Acción:** eliminar_abstencion
- **Esperado:** success=true, message='La abstención ha sido eliminada.', cvemov=14 en catastro

## 3. Intentar registrar abstención en cuenta cancelada
- **Entrada:**
  - cvecuenta: 2002 (vigente='C')
  - axoefec: 2024
  - bimefec: 2
  - observacion: "Intento en cuenta cancelada."
  - usuario: "admin"
- **Acción:** registrar_abstencion
- **Esperado:** success=false, message='Esta cuenta está cancelada, la abstención no es posible!'

## 4. Intentar eliminar abstención cuando no existe
- **Entrada:**
  - cvecuenta: 1003 (cvemov!=12)
  - axoefec: 2024
  - bimefec: 2
  - observacion: "No hay abstención."
  - usuario: "admin"
- **Acción:** eliminar_abstencion
- **Esperado:** success=false, message='No existe una abstención activa para eliminar.'

## 5. Validar año y bimestre fuera de rango
- **Entrada:**
  - cvecuenta: 1001
  - axoefec: 1899
  - bimefec: 7
  - observacion: "Fuera de rango."
  - usuario: "admin"
- **Acción:** registrar_abstencion
- **Esperado:** success=false, message de validación de año/bimestre
