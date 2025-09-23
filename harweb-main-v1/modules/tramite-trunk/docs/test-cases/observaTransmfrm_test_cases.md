# Casos de Prueba: ObservaTransm

## 1. Alta de Observación (Bloqueo)
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "create",
      "params": {
        "nocontrol": 12345,
        "cvecuenta": 67890,
        "folio": 20231234,
        "observacion": "Se bloquea por falta de documentos.",
        "usuario": "jdoe"
      }
    }
  }
  ```
- **Esperado**: success=true, status='B', mensaje de éxito, registro visible en listado

## 2. Desbloqueo de Observación
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "unlock",
      "params": {
        "nocontrol": 12345,
        "folio": 20231234,
        "observacion": "Se desbloquea por entrega de documentos.",
        "usuario": "jdoe"
      }
    }
  }
  ```
- **Esperado**: success=true, status='D', mensaje de éxito, registro actualizado

## 3. Listado de Observaciones
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "list",
      "params": {
        "folio": 20231234
      }
    }
  }
  ```
- **Esperado**: success=true, data es array de observaciones para ese folio

## 4. Edición de Observación
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "update",
      "params": {
        "nocontrol": 12345,
        "folio": 20231234,
        "observacion": "Se actualiza motivo de bloqueo.",
        "usuario": "jdoe"
      }
    }
  }
  ```
- **Esperado**: success=true, mensaje de éxito, observación actualizada

## 5. Baja de Observación
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "delete",
      "params": {
        "nocontrol": 12345,
        "folio": 20231234,
        "usuario": "jdoe"
      }
    }
  }
  ```
- **Esperado**: success=true, status='D', mensaje de éxito, registro marcado como baja

## 6. Validación de Parámetros
- **Entrada**: Faltan campos obligatorios
- **Esperado**: success=false, mensaje de error claro
