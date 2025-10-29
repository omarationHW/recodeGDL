# Documentación Técnica: Actualización de Unidades de Recolección (Cantidad) - Contratos_Upd_UndC

## Descripción General
Este módulo permite la actualización de la cantidad de unidades de recolección asociadas a un contrato vigente. Incluye la validación de datos, actualización de importes en pagos futuros, y registro de la documentación probatoria del cambio. La migración Delphi → Laravel + Vue.js + PostgreSQL se implementa siguiendo arquitectura API RESTful con endpoint unificado y lógica de negocio en stored procedures.

## Arquitectura
- **Frontend:** Vue.js SPA, página independiente, navegación por rutas.
- **Backend:** Laravel Controller, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos:** PostgreSQL, lógica principal en stored procedures.

## Flujo de Trabajo
1. **Carga de Tipos de Aseo:**
   - El frontend solicita los tipos de aseo disponibles para poblar el select.
   - Endpoint: `action: listarTiposAseo`
2. **Búsqueda de Contrato:**
   - El usuario ingresa número de contrato y tipo de aseo.
   - El backend busca el contrato vigente y retorna todos los datos relevantes.
   - Endpoint: `action: buscarContrato`
3. **Actualización de Unidades:**
   - El usuario ingresa la nueva cantidad, ejercicio, mes, documento y descripción.
   - El backend valida, actualiza la cantidad, recalcula importes de pagos futuros, y registra el documento probatorio.
   - Endpoint: `action: actualizarUnidades`

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `listarTiposAseo`
  - `buscarContrato`
  - `actualizarUnidades`

## Stored Procedures
- **sp_contratos_upd_undc_buscar:** Busca contrato vigente por número y tipo de aseo.
- **sp_contratos_upd_undc_listar_tipos_aseo:** Lista tipos de aseo.
- **sp_contratos_upd_undc_actualizar_unidades:** Actualiza cantidad de unidades, recalcula importes y registra documento.

## Validaciones
- El contrato debe estar vigente.
- La cantidad nueva debe ser mayor a cero.
- El documento probatorio es obligatorio.
- El ejercicio y mes deben ser válidos.
- No se permite actualizar si los datos no cumplen las reglas de negocio.

## Seguridad
- El usuario autenticado se obtiene vía middleware Laravel y se pasa como parámetro a los SP.
- Todas las operaciones quedan registradas con el id_usuario.

## Manejo de Errores
- Los SP retornan un campo `success` y `message` para indicar el resultado.
- El frontend muestra mensajes de error o éxito según corresponda.

## Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.
