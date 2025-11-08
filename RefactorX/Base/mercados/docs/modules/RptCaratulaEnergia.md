# Documentación Técnica: Carátula de Energía Eléctrica (RptCaratulaEnergia)

## Descripción General
Este módulo permite consultar y visualizar la carátula de energía eléctrica de un local, mostrando los datos generales, adeudos, recargos calculados y requerimientos asociados. Incluye lógica de cálculo de recargos según reglas históricas y de negocio, y permite la impresión de la carátula.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa (sin tabs)
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio y reportes

## Flujo de Datos
1. El usuario ingresa el ID del local y solicita la consulta.
2. El frontend realiza llamadas a `/api/execute` con acciones:
   - `getEnergiaCaratula` → Obtiene datos generales del local y energía
   - `getAdeudosEnergia` → Obtiene lista de adeudos y recargos calculados
   - `getRequerimientosEnergia` → Obtiene requerimientos asociados
3. El backend ejecuta los stored procedures correspondientes y retorna los datos en formato JSON.
4. El frontend muestra los datos y permite imprimir la carátula.

## Endpoints API
- **POST /api/execute**
  - **Body:** `{ action: string, params: object }`
  - **Acciones soportadas:**
    - `getEnergiaCaratula` { id_local }
    - `getAdeudosEnergia` { id_local }
    - `getRequerimientosEnergia` { id_local }
    - `getDiaVencimiento` { mes }
    - `calcularRecargosEnergia` { id_adeudo }

## Stored Procedures
- `sp_get_energia_caratula(id_local)` → Datos generales del local y energía
- `sp_get_adeudos_energia(id_local)` → Lista de adeudos y recargos
- `sp_get_requerimientos_energia(id_local)` → Requerimientos asociados
- `sp_get_dia_vencimiento(mes)` → Día de vencimiento para recargos
- `sp_calcular_recargos_energia(id_adeudo)` → Cálculo de recargos según reglas históricas

## Lógica de Recargos
- Si el mercado es 1 (Cruz del Sur), no hay recargos.
- Para años <= 2002, los adeudos son bimestrales y el cálculo es especial.
- El cálculo de recargos depende de la fecha actual, el periodo, y si existen requerimientos.
- Los porcentajes de recargo se obtienen de la tabla `ta_12_recargos`.

## Seguridad
- Todas las acciones requieren autenticación (middleware Laravel, no mostrado aquí).
- Validación de parámetros en backend.

## Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones sin modificar la ruta.
- Los stored procedures encapsulan la lógica de negocio, facilitando el mantenimiento.

## Pruebas
- Se recomienda usar Postman o similar para probar el endpoint con diferentes acciones y parámetros.
- El frontend puede ser probado de forma independiente usando mock de la API.

## Consideraciones
- El cálculo de recargos es sensible a la fecha actual y a la existencia de requerimientos.
- El frontend debe manejar errores y mostrar mensajes claros al usuario.
