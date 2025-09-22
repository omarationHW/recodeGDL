# Casos de Prueba para Servicio (Obra Pública)

## 1. Alta de Servicio Válido
- **Entrada:**
  ```json
  { "eRequest": { "action": "create", "data": { "descripcion": "Reparación de banquetas", "serv_obra94": 94 } } }
  ```
- **Esperado:**
  - success: true
  - data.servicio: (nuevo id)
  - data.descripcion: "Reparación de banquetas"
  - data.serv_obra94: 94

## 2. Alta de Servicio sin descripción (inválido)
- **Entrada:**
  ```json
  { "eRequest": { "action": "create", "data": { "descripcion": "", "serv_obra94": 94 } } }
  ```
- **Esperado:**
  - success: false
  - message: "La descripción es obligatoria"

## 3. Edición de Servicio Existente
- **Entrada:**
  ```json
  { "eRequest": { "action": "update", "data": { "servicio": 2, "descripcion": "Nueva descripción", "serv_obra94": 95 } } }
  ```
- **Esperado:**
  - success: true
  - data.servicio: 2
  - data.descripcion: "Nueva descripción"
  - data.serv_obra94: 95

## 4. Eliminación de Servicio Inexistente
- **Entrada:**
  ```json
  { "eRequest": { "action": "delete", "data": { "servicio": 9999 } } }
  ```
- **Esperado:**
  - success: false
  - message: "Servicio no encontrado"

## 5. Listado de Servicios
- **Entrada:**
  ```json
  { "eRequest": { "action": "list" } }
  ```
- **Esperado:**
  - success: true
  - data: [ { servicio, descripcion, serv_obra94 }, ... ]

## 6. Reporte de Servicios
- **Entrada:**
  ```json
  { "eRequest": { "action": "report" } }
  ```
- **Esperado:**
  - success: true
  - data: [ { servicio, descripcion, serv_obra94 }, ... ]
