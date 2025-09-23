# Casos de Prueba para Clave Catastral

## 1. Cambio exitoso de clave catastral
- **Entrada**: clave = 'D65H3123456', subpredio = 2, cuenta vigente
- **Acción**: Enviar formulario
- **Resultado esperado**: Mensaje de éxito, datos actualizados en BD

## 2. Clave catastral ya existente
- **Entrada**: clave = 'D66A0123456', subpredio vacío, existe en otra cuenta
- **Acción**: Enviar formulario
- **Resultado esperado**: Error 'La clave catastral ya se encuentra en uso...'

## 3. Longitud inválida
- **Entrada**: clave = 'D65H3123', subpredio = 1
- **Acción**: Enviar formulario
- **Resultado esperado**: Error 'Existe un error en la longitud de la clave ...'

## 4. Zona inválida
- **Entrada**: clave = 'D67H3123456', subpredio = 1
- **Acción**: Enviar formulario
- **Resultado esperado**: Error 'La clave catastral no corresponde a una zona dentro de Guadalajara ...'

## 5. Subzona inválida
- **Entrada**: clave = 'D65K3123456', subpredio = 1
- **Acción**: Enviar formulario
- **Resultado esperado**: Error 'Subzona inválida para D65'

## 6. Manzana bloqueada
- **Entrada**: clave = 'D65H3123456', subpredio = 1, manzana D65H31234 bloqueada
- **Acción**: Enviar formulario
- **Resultado esperado**: Error 'No puedes modificar la clave catastral de esta cuenta porque la manzana está bloqueada'

## 7. Cambio solo de subpredio
- **Entrada**: clave = 'D65H3123456', subpredio = 5, soloSubpredio = true
- **Acción**: Enviar formulario
- **Resultado esperado**: Solo se actualiza el subpredio, clave permanece igual
