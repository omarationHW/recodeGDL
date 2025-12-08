# Documentación Técnica: ImpLicenciaReglamentada

## Análisis Técnico

# Documentación Técnica: Migración de ImpLicenciaReglamentadaFrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (stored procedures para lógica de negocio)
- **Patrón API:** eRequest/eResponse (acción + parámetros)

## 2. Flujo de la Aplicación
1. **Usuario ingresa No. de Licencia** en el formulario Vue y presiona Enter o Buscar.
2. **Vue.js** envía petición POST a `/api/execute` con `{ action: 'getLicenciaReglamentada', params: { licencia: <valor> } }`.
3. **Laravel Controller** procesa la acción:
   - Consulta la licencia, giro, convcta y zona_lic.
   - Valida que la licencia esté vigente, no bloqueada y que el giro sea de clasificación 'D'.
   - Devuelve los datos para mostrar en pantalla.
4. **Usuario presiona Imprimir**:
   - Vue.js ejecuta acción `calcAdeudoLicencia` (llama SP `calc_adeudolic`), luego obtiene detalle con `getTmpAdeudoLic`.
   - Muestra tabla de adeudos y mensaje de impresión.

## 3. Endpoints y Acciones
- `/api/execute` (POST)
  - **getLicenciaReglamentada**: Consulta datos de licencia y relaciones.
  - **calcAdeudoLicencia**: Ejecuta SP para calcular adeudo y llenar tabla temporal.
  - **getTmpAdeudoLic**: Devuelve detalle de adeudo de la tabla temporal.
  - **getDetSaldoLic**: Devuelve detalle de saldo (SP de reporte).

## 4. Stored Procedures
- **calc_adeudolic(p_id_licencia INTEGER):** Calcula y llena tmp_adeudolic para impresión.
- **detsaldo_licencia(p_id_licencia INTEGER):** Devuelve detalle de saldo de licencia y anuncios.

## 5. Validaciones
- Licencia debe existir y estar vigente.
- No debe estar bloqueada (`bloqueado = 1`).
- Giro debe ser de clasificación 'D'.

## 6. Seguridad
- Todas las acciones pasan por validación de parámetros.
- Se recomienda proteger el endpoint con autenticación JWT o similar en producción.

## 7. Consideraciones de Migración
- Los reportes impresos en Delphi se simulan como tabla en Vue.js. Para impresión real, se recomienda generar PDF en backend.
- La tabla temporal `tmp_adeudolic` debe ser limpiada por usuario/licencia para evitar colisiones multiusuario.

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones sin modificar la estructura de la API.

## 9. Estructura de la Respuesta
```json
{
  "success": true,
  "data": { ... },
  "message": ""
}
```

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 12

## Casos de Prueba

# Casos de Prueba: ImpLicenciaReglamentadaFrm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| TC01 | Consulta de licencia válida y vigente | licencia = 12345 | Muestra datos completos, botón Imprimir habilitado, detalle de adeudo visible tras imprimir |
| TC02 | Consulta de licencia bloqueada | licencia = 54321 | Mensaje de error: 'La licencia está bloqueada.' |
| TC03 | Consulta de licencia con giro no permitido | licencia = 67890 | Mensaje de error: 'El giro no es de clasificación D.' |
| TC04 | Consulta de licencia inexistente | licencia = 99999 | Mensaje de error: 'Licencia no encontrada o no vigente' |
| TC05 | Impresión de licencia sin calcular adeudo | licencia = 12345, omitir paso de impresión | No muestra detalle de adeudo, botón Imprimir disponible |
| TC06 | Impresión de licencia con error en SP | licencia = 12345, forzar error en SP | Mensaje de error: 'Error al calcular adeudo' |

## Casos de Uso

# Casos de Uso - ImpLicenciaReglamentadaFrm

**Categoría:** Form

## Caso de Uso 1: Consulta e impresión de licencia reglamentada vigente

**Descripción:** El usuario consulta una licencia vigente, válida y de giro clasificación D, y procede a imprimir el detalle de adeudo.

**Precondiciones:**
La licencia existe, está vigente, no está bloqueada y su giro es de clasificación 'D'.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia en el formulario y presiona Enter o Buscar.
2. El sistema muestra los datos de la licencia, giro, ubicación, propietario, etc.
3. El usuario presiona el botón Imprimir.
4. El sistema ejecuta el cálculo de adeudo y muestra el detalle en tabla.

**Resultado esperado:**
Se muestran correctamente los datos de la licencia y el detalle de adeudo. El botón Imprimir está habilitado y la impresión se simula exitosamente.

**Datos de prueba:**
licencia = 12345 (vigente, no bloqueada, giro clasificación D)

---

## Caso de Uso 2: Intento de consulta de licencia bloqueada

**Descripción:** El usuario intenta consultar una licencia que está bloqueada.

**Precondiciones:**
La licencia existe, está vigente, pero tiene el campo bloqueado = 1.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia bloqueada y presiona Buscar.
2. El sistema valida y muestra un mensaje de error indicando que la licencia está bloqueada.

**Resultado esperado:**
El sistema no permite imprimir ni consultar detalle, mostrando el mensaje de error correspondiente.

**Datos de prueba:**
licencia = 54321 (vigente, bloqueado = 1)

---

## Caso de Uso 3: Consulta de licencia con giro no permitido

**Descripción:** El usuario consulta una licencia cuyo giro no es de clasificación D.

**Precondiciones:**
La licencia existe, está vigente, no está bloqueada, pero su giro es de clasificación diferente a 'D'.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia y presiona Buscar.
2. El sistema valida y muestra un mensaje de error indicando que el giro no es permitido.

**Resultado esperado:**
El sistema no permite imprimir ni consultar detalle, mostrando el mensaje de error correspondiente.

**Datos de prueba:**
licencia = 67890 (vigente, no bloqueada, giro clasificación 'B')

---
