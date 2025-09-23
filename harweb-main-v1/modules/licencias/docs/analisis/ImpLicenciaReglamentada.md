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

