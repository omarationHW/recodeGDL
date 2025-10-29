# Documentación Técnica: Migración Formulario Liquidaciones (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **Comunicación**: El frontend consume el endpoint `/api/execute` enviando la acción y parámetros.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "...", "params": { ... } } }`
- **Salida**: `{ "eResponse": { "success": true|false, "data": ..., "message": "..." } }`

### Acciones soportadas
- `list_cemeteries`: Lista cementerios disponibles.
- `calculate_liquidation`: Calcula liquidación de mantenimiento y recargos.
- `print_liquidation`: Devuelve datos para impresión (o PDF en futuro).

## Stored Procedure Principal
- **sp_liquidaciones_calcular**: Recibe cementerio, años, metros, tipo, si es nuevo, mes. Devuelve tabla con año, mantenimiento, recargos.
- La lógica replica la de Delphi, usando la columna de cuota según tipo y calcula recargos según porcentaje del año y mes.

## Controlador Laravel
- Un solo método `execute` que despacha según acción.
- Validación de parámetros.
- Llama al SP y retorna resultados.

## Componente Vue.js
- Página completa, sin tabs.
- Formulario para seleccionar cementerio, años, metros, tipo, nuevo, mes.
- Botón calcular y botón imprimir.
- Tabla de resultados con totales.
- Manejo de errores y validaciones.

## Seguridad
- Validación de parámetros en backend.
- No se exponen queries directos, todo va por SP.

## Extensibilidad
- Se pueden agregar nuevas acciones al endpoint único.
- El frontend puede crecer a otras páginas independientes.

# Estructura de la Base de Datos
- **tc_13_cementerios**: Catálogo de cementerios.
- **ta_13_rcmcuotas**: Cuotas por año, tipo y cementerio.
- **ta_13_recargosrcm**: Porcentajes de recargos por año y mes.

# Flujo de Cálculo
1. El usuario selecciona cementerio, años, metros, tipo, nuevo, mes.
2. El frontend llama a `/api/execute` con acción `calculate_liquidation`.
3. El backend llama al SP, que recorre los años y calcula mantenimiento y recargos.
4. El resultado se muestra en tabla, con totales.

# Consideraciones
- El SP puede ser extendido para soportar reglas adicionales.
- El endpoint puede ser autenticado según necesidades.
- El PDF de impresión puede ser implementado usando Laravel Snappy o similar.
