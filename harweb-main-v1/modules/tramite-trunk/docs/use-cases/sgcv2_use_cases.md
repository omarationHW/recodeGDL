# Casos de Uso - sgcv2

**Categoría:** Form

## Caso de Uso 1: Consulta de Cuenta Catastral y Propietarios

**Descripción:** El usuario ingresa los datos de recaudadora, tipo (urbano/rústico) y número de cuenta para consultar la información de la cuenta y sus propietarios.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de consulta.

**Pasos a seguir:**
[
  "El usuario accede a la página de consulta de cuenta.",
  "Ingresa los datos: recaudadora, urbrus, cuenta.",
  "Presiona 'Buscar Cuenta'.",
  "El sistema muestra los datos de la cuenta.",
  "El usuario presiona 'Ver Propietarios'.",
  "El sistema muestra la lista de propietarios asociados."
]

**Resultado esperado:**
Se muestra la información completa de la cuenta y sus propietarios.

**Datos de prueba:**
{
  "recaud": 1,
  "urbrus": "U",
  "cuenta": 12345
}

---

## Caso de Uso 2: Cambio de Clave de Usuario

**Descripción:** El usuario desea cambiar su clave de acceso al sistema.

**Precondiciones:**
El usuario debe estar autenticado.

**Pasos a seguir:**
[
  "El usuario accede a la opción de cambio de clave.",
  "Ingresa la clave actual y la nueva clave.",
  "Confirma la nueva clave.",
  "El sistema valida la clave actual y actualiza la clave.",
  "El sistema muestra un mensaje de éxito."
]

**Resultado esperado:**
La clave es cambiada correctamente y el usuario puede autenticarse con la nueva clave.

**Datos de prueba:**
{
  "usuario": "jdoe",
  "clave_actual": "oldpass",
  "clave_nueva": "newpass123"
}

---

## Caso de Uso 3: Autorización de Transmisión Patrimonial

**Descripción:** Un usuario con permisos autoriza una transmisión patrimonial.

**Precondiciones:**
El usuario debe tener permisos de autorización y existir un folio pendiente de autorización.

**Pasos a seguir:**
[
  "El usuario accede a la lista de transmisiones pendientes.",
  "Selecciona un folio y presiona 'Autorizar'.",
  "El sistema actualiza el estado de la transmisión a 'Autorizada' y registra la autorización.",
  "El sistema muestra un mensaje de éxito."
]

**Resultado esperado:**
La transmisión queda autorizada y registrada en el sistema.

**Datos de prueba:**
{
  "folio": 1001,
  "usuario": "admin"
}

---

