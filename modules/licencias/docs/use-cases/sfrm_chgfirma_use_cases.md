# Casos de Uso - sfrm_chgfirma

**Categoría:** Form

## Caso de Uso 1: Cambio exitoso de firma electrónica

**Descripción:** El usuario desea cambiar su firma electrónica para el módulo de Licencias.

**Precondiciones:**
El usuario está autenticado y conoce su firma actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de firma electrónica.
2. Ingresa su firma actual, la nueva firma y la confirmación.
3. Selecciona el módulo 'Licencias'.
4. Presiona 'Cambiar Firma'.
5. El sistema valida y actualiza la firma.

**Resultado esperado:**
La firma electrónica se actualiza y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "usuario": "jdoe",
  "firma_actual": "abc123",
  "firma_nueva": "nuevaFirma456",
  "firma_conf": "nuevaFirma456",
  "modulos_id": 1
}

---

## Caso de Uso 2: Error por firma actual incorrecta

**Descripción:** El usuario intenta cambiar su firma pero ingresa mal la firma actual.

**Precondiciones:**
El usuario está autenticado pero no recuerda bien su firma actual.

**Pasos a seguir:**
1. Accede a la página de cambio de firma.
2. Ingresa una firma actual incorrecta.
3. Ingresa la nueva firma y la confirmación.
4. Presiona 'Cambiar Firma'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la firma actual es incorrecta.

**Datos de prueba:**
{
  "usuario": "jdoe",
  "firma_actual": "incorrecta",
  "firma_nueva": "nuevaFirma456",
  "firma_conf": "nuevaFirma456",
  "modulos_id": 1
}

---

## Caso de Uso 3: Error por confirmación de firma no coincidente

**Descripción:** El usuario ingresa una nueva firma pero la confirmación no coincide.

**Precondiciones:**
El usuario está autenticado y conoce su firma actual.

**Pasos a seguir:**
1. Accede a la página de cambio de firma.
2. Ingresa la firma actual correcta.
3. Ingresa una nueva firma y una confirmación diferente.
4. Presiona 'Cambiar Firma'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la confirmación no coincide.

**Datos de prueba:**
{
  "usuario": "jdoe",
  "firma_actual": "abc123",
  "firma_nueva": "nuevaFirma456",
  "firma_conf": "otraFirma789",
  "modulos_id": 1
}

---

