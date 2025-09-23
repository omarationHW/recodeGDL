## Casos de Prueba para Formulario Aviso

### Caso 1: Aceptar aviso sin mostrar información adicional
- **Precondición:** Usuario autenticado (user_id=1)
- **Acción:**
  - POST /api/execute
  - Payload:
    ```json
    {
      "eRequest": {
        "action": "logAvisoAcknowledgement",
        "params": {
          "user_id": 1,
          "show_more": false,
          "memo_text": null
        }
      }
    }
    ```
- **Resultado esperado:**
  - HTTP 200
  - eResponse.success = true
  - Registro en tabla aviso_acknowledgements con show_more=false

---

### Caso 2: Aceptar aviso mostrando información adicional
- **Precondición:** Usuario autenticado (user_id=2)
- **Acción:**
  - POST /api/execute
  - Payload:
    ```json
    {
      "eRequest": {
        "action": "logAvisoAcknowledgement",
        "params": {
          "user_id": 2,
          "show_more": true,
          "memo_text": "Aquí puede ir información adicional sobre el error en la clave catastral."
        }
      }
    }
    ```
- **Resultado esperado:**
  - HTTP 200
  - eResponse.success = true
  - Registro en tabla aviso_acknowledgements con show_more=true y memo_text no nulo

---

### Caso 3: Intento de aceptar aviso sin autenticación
- **Precondición:** Usuario no autenticado (user_id=null)
- **Acción:**
  - POST /api/execute
  - Payload:
    ```json
    {
      "eRequest": {
        "action": "logAvisoAcknowledgement",
        "params": {
          "user_id": null,
          "show_more": false,
          "memo_text": null
        }
      }
    }
    ```
- **Resultado esperado:**
  - HTTP 200
  - eResponse.success = false
  - Mensaje de error indicando falta de autenticación o parámetro inválido
  - No se registra nada en la base de datos
