# Casos de Prueba para Menú General

## Caso 1: Login exitoso
- **Entrada:** usuario: admin, password: secreto
- **Esperado:** status: ok, user.id_usuario > 0, menú cargado correctamente

## Caso 2: Login fallido
- **Entrada:** usuario: admin, password: incorrecto
- **Esperado:** status: error, message: 'Usuario o clave incorrecta'

## Caso 3: Carga de ejercicios
- **Entrada:** operación: getEjercicios
- **Esperado:** status: ok, ejercicios: lista no vacía

## Caso 4: Verificación de versión igual
- **Entrada:** operación: checkVersion, proyecto: 'Aseo.exe', version: '1.0.0.0'
- **Esperado:** update_required: false

## Caso 5: Verificación de versión diferente
- **Entrada:** operación: checkVersion, proyecto: 'Aseo.exe', version: '0.9.0.0'
- **Esperado:** update_required: true

## Caso 6: Carga de menú según nivel
- **Entrada:** operación: getMenu, usuario: 'admin'
- **Esperado:** status: ok, menú contiene opciones habilitadas según nivel

## Caso 7: Cambio de ejercicio
- **Entrada:** Selección de ejercicio diferente
- **Esperado:** El valor de ejercicio cambia y se propaga a los formularios hijos
