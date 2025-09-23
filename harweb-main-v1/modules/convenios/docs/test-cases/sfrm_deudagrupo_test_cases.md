# Casos de Prueba: Deuda Grupo

## Caso 1: Alta de grupo válido
- **Entrada:**
  - Acción: create
  - Datos: { "nombre": "Grupo Test", "descripcion": "Test funcional" }
- **Esperado:**
  - success: true
  - El grupo aparece en el listado

## Caso 2: Alta de grupo sin nombre (campo requerido)
- **Entrada:**
  - Acción: create
  - Datos: { "nombre": "", "descripcion": "Sin nombre" }
- **Esperado:**
  - success: false
  - Mensaje de error indicando campo requerido

## Caso 3: Edición de grupo existente
- **Entrada:**
  - Acción: update
  - Datos: { "id": 1, "nombre": "Grupo Modificado", "descripcion": "Modificado" }
- **Esperado:**
  - success: true
  - El grupo se actualiza correctamente

## Caso 4: Eliminación de grupo inexistente
- **Entrada:**
  - Acción: delete
  - Datos: { "id": 9999 }
- **Esperado:**
  - success: false
  - Mensaje: "Registro no encontrado"

## Caso 5: Listado de grupos
- **Entrada:**
  - Acción: list
- **Esperado:**
  - success: true
  - data: Array de grupos existentes
