# Documentación Técnica: ConsultaDatosEnergia

## Descripción General
Este módulo permite consultar la información de energía eléctrica asociada a un local, incluyendo:
- Datos generales de energía
- Requerimientos (multas, gastos)
- Adeudos por mes (con cálculo de recargos)
- Pagos realizados
- Condonaciones

La arquitectura utiliza un endpoint API unificado `/api/execute` bajo el patrón eRequest/eResponse, con stored procedures en PostgreSQL para toda la lógica de negocio y un frontend Vue.js como página independiente.

## Arquitectura
- **Backend**: Laravel Controller (`ConsultaDatosEnergiaController`) que recibe peticiones eRequest y despacha a los stored procedures correspondientes.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y tablas para cada sección.
- **Base de Datos**: PostgreSQL, toda la lógica encapsulada en stored procedures.
- **API**: Endpoint único `/api/execute` que recibe `{ eRequest: { action, params } }` y responde `{ eResponse: { success, data, message } }`.

## Flujo de Datos
1. El usuario ingresa el ID del local y presiona "Buscar".
2. El frontend llama a `/api/execute` con `action: getEnergiaByLocal` y el ID.
3. El backend ejecuta el stored procedure `sp_get_energia_by_local` y retorna los datos.
4. El frontend muestra los datos y, en paralelo, consulta requerimientos y adeudos.
5. El usuario puede ver pagos y condonaciones, que se consultan bajo demanda.

## Seguridad
- Todas las operaciones se validan en el backend.
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).

## Extensibilidad
- Para agregar nuevas operaciones, basta con crear un nuevo stored procedure y mapearlo en el controlador.
- El frontend puede extenderse para mostrar más detalles o exportar datos.

## Integración
- El componente Vue.js puede integrarse en cualquier SPA Vue Router.
- El backend puede convivir con otros módulos bajo el mismo endpoint `/api/execute`.

## Notas de Migración
- Todos los queries SQL y lógica de recargos se migran a stored procedures.
- El cálculo de recargos es simplificado y debe ajustarse según reglas fiscales reales.
- El frontend asume que los stored procedures retornan los datos en el formato esperado.

