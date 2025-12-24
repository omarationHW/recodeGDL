# Documentación Técnica: sfrm_chgfirma

## Análisis Técnico

# Documentación Técnica: Migración de Formulario de Cambio de Firma Electrónica

## 1. Descripción General
Este módulo permite a los usuarios cambiar su firma electrónica para módulos específicos (por ejemplo, Licencias o Ubicación). La migración incluye:
- Un endpoint API unificado en Laravel (`/api/execute`)
- Un componente Vue.js como página independiente
- Un stored procedure en PostgreSQL para la lógica de negocio
- Uso del patrón eRequest/eResponse

## 2. Arquitectura
- **Backend:** Laravel 10+, PostgreSQL
- **Frontend:** Vue.js 3 (Composition API o Options API)
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`
- **Seguridad:** El usuario debe estar autenticado (middleware Laravel Auth)

## 3. Flujo de Datos
1. El usuario accede a la página de cambio de firma electrónica.
2. Ingresa la firma actual, la nueva y la confirmación.
3. El formulario envía un POST a `/api/execute` con el siguiente payload:
   ```json
   {
     "eRequest": {
       "action": "chg_firma",
       "usuario": "usuario",
       "firma_actual": "...",
       "firma_nueva": "...",
       "firma_conf": "...",
       "modulos_id": 1
     }
   }
   ```
4. El controlador Laravel valida y llama al stored procedure `upd_firma`.
5. El stored procedure valida la firma actual, la nueva y la confirmación, y actualiza la base de datos.
6. El resultado se devuelve en `eResponse` con `success` y `message`.

## 4. API Detalle
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  - `eRequest.action`: "chg_firma"
  - `eRequest.usuario`: string
  - `eRequest.firma_actual`: string
  - `eRequest.firma_nueva`: string
  - `eRequest.firma_conf`: string
  - `eRequest.modulos_id`: integer
- **Salida:**
  - `eResponse.success`: boolean
  - `eResponse.message`: string

## 5. Validaciones
- El usuario debe existir
- La firma actual debe coincidir
- La nueva firma debe tener al menos 6 caracteres
- La confirmación debe coincidir
- La nueva firma no puede ser igual a la actual

## 6. Seguridad
- El endpoint debe estar protegido por autenticación JWT o sesión
- El usuario sólo puede cambiar su propia firma

## 7. Consideraciones de UI
- El formulario debe ser una página independiente
- No usar tabs ni componentes tabulares
- Mostrar mensajes claros de éxito o error
- Limpiar los campos tras éxito

## 8. Base de Datos
- Tabla `usuarios` (id, usuario, ...)
- Tabla `usuarios_firma` (usuario_id, modulos_id, firma, fecha_mod)

## 9. Extensibilidad
- El endpoint `/api/execute` puede recibir otras acciones en el futuro
- El stored procedure puede extenderse para más validaciones

## 10. Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "message": "Firma electrónica actualizada correctamente"
  }
}
```

## Casos de Prueba

## Casos de Prueba para Cambio de Firma Electrónica

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| 1 | Cambio exitoso | usuario: 'jdoe', firma_actual: 'abc123', firma_nueva: 'nuevaFirma456', firma_conf: 'nuevaFirma456', modulos_id: 1 | success: true, message: 'Firma electrónica actualizada correctamente' |
| 2 | Firma actual incorrecta | usuario: 'jdoe', firma_actual: 'incorrecta', firma_nueva: 'nuevaFirma456', firma_conf: 'nuevaFirma456', modulos_id: 1 | success: false, message: 'La firma actual es incorrecta' |
| 3 | Confirmación no coincide | usuario: 'jdoe', firma_actual: 'abc123', firma_nueva: 'nuevaFirma456', firma_conf: 'otraFirma789', modulos_id: 1 | success: false, message: 'La confirmación no coincide' |
| 4 | Nueva firma igual a actual | usuario: 'jdoe', firma_actual: 'abc123', firma_nueva: 'abc123', firma_conf: 'abc123', modulos_id: 1 | success: false, message: 'La nueva firma no puede ser igual a la actual' |
| 5 | Nueva firma muy corta | usuario: 'jdoe', firma_actual: 'abc123', firma_nueva: '123', firma_conf: '123', modulos_id: 1 | success: false, message: 'La nueva firma debe tener al menos 6 caracteres' |
| 6 | Usuario no existe | usuario: 'noexiste', firma_actual: 'abc123', firma_nueva: 'nuevaFirma456', firma_conf: 'nuevaFirma456', modulos_id: 1 | success: false, message: 'Usuario no encontrado' |

## Casos de Uso

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


