# Casos de Uso - sfrm_chgfirma

**Categoría:** Form

## Caso de Uso 1: Cambio exitoso de firma electrónica

**Descripción:** Un usuario autenticado desea cambiar su firma electrónica por una nueva.

**Precondiciones:**
El usuario está autenticado y conoce su firma electrónica actual.

**Pasos a seguir:**
[
  "El usuario accede a la página de cambio de firma electrónica.",
  "Ingresa su firma actual, la nueva firma y la confirmación.",
  "Presiona el botón 'Cambiar Firma'.",
  "El sistema valida los datos y actualiza la firma en la base de datos."
]

**Resultado esperado:**
La firma electrónica se actualiza correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "usuario": "jdoe",
  "firma_actual": "abc123",
  "firma_nueva": "nuevaFirma2024",
  "firma_conf": "nuevaFirma2024",
  "modulos_id": 3
}

---

## Caso de Uso 2: Error por firma actual incorrecta

**Descripción:** El usuario intenta cambiar su firma electrónica pero ingresa una firma actual incorrecta.

**Precondiciones:**
El usuario está autenticado pero no recuerda bien su firma actual.

**Pasos a seguir:**
[
  "El usuario accede a la página de cambio de firma electrónica.",
  "Ingresa una firma actual incorrecta, una nueva firma y la confirmación.",
  "Presiona el botón 'Cambiar Firma'."
]

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la firma actual es incorrecta.

**Datos de prueba:**
{
  "usuario": "jdoe",
  "firma_actual": "claveErronea",
  "firma_nueva": "nuevaFirma2024",
  "firma_conf": "nuevaFirma2024",
  "modulos_id": 3
}

---

## Caso de Uso 3: Error por confirmación de firma no coincidente

**Descripción:** El usuario ingresa una nueva firma y una confirmación que no coincide.

**Precondiciones:**
El usuario está autenticado y conoce su firma actual.

**Pasos a seguir:**
[
  "El usuario accede a la página de cambio de firma electrónica.",
  "Ingresa la firma actual, una nueva firma y una confirmación diferente.",
  "Presiona el botón 'Cambiar Firma'."
]

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la confirmación no coincide.

**Datos de prueba:**
{
  "usuario": "jdoe",
  "firma_actual": "abc123",
  "firma_nueva": "nuevaFirma2024",
  "firma_conf": "otraFirma2024",
  "modulos_id": 3
}

---

