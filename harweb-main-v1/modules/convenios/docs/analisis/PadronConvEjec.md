# PadronConvEjec - Documentación Técnica

## Descripción General
El formulario PadronConvEjec permite consultar, filtrar y exportar el padrón de convenios ejecutados, filtrando por tipo, subtipo, recaudadora, vigencia, ejecutor y rango de años. Incluye la visualización de datos y exportación a Excel.

## Arquitectura
- **Backend:** Laravel Controller (PadronConvEjecController) expone un endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con filtros y tabla de resultados.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures y funciones.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|export|filters|init|getFolios|getTipos|getSubtipos|getRecaudadoras|getEjecutores",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": ...,
      "message": "..."
    }
  }
  ```

## Stored Procedures
- **sp_padronconvejec_get_tipos:** Devuelve tipos de convenio.
- **sp_padronconvejec_get_subtipos:** Devuelve subtipos para un tipo.
- **sp_padronconvejec_get_recaudadoras:** Devuelve recaudadoras.
- **sp_padronconvejec_get_ejecutores:** Devuelve ejecutores activos.
- **sp_padronconvejec_list:** Devuelve el listado filtrado de convenios.

## Seguridad
- Validar que los parámetros recibidos sean correctos y estén autorizados.
- El endpoint debe estar protegido por autenticación Laravel (middleware `auth:api`).

## Flujo de Datos
1. El frontend solicita los catálogos (tipos, subtipos, recaudadoras, ejecutores) usando `action: 'init'`.
2. El usuario selecciona filtros y solicita el listado (`action: 'list'`).
3. El backend ejecuta el stored procedure y retorna los datos.
4. El usuario puede exportar el resultado (`action: 'export'`).

## Consideraciones
- Los stored procedures deben ser optimizados para grandes volúmenes de datos.
- El frontend debe manejar estados de carga y errores.
- La exportación a Excel puede implementarse en backend o frontend según requerimiento.

## Estructura de la Tabla de Resultados
- id_conv_resto
- convenio
- folio
- ejecutor
- fprac
- fecha_inicio
- fecha_venc
- pago_parcial
- costo
- pagos
- adeudo
- vigencia
- vigfolio
- fpago
- importe_pago
- referencia
- impuesto
- recargos
- gastos
- multa
- periodos

# Integración
- El componente Vue.js se integra como página independiente en el router.
- El controlador Laravel debe estar registrado en `routes/api.php`.
- Los stored procedures deben estar cargados en la base de datos PostgreSQL.

# Pruebas
- Probar todos los filtros combinados.
- Probar exportación con grandes volúmenes de datos.
- Probar casos de error (parámetros inválidos, sin resultados, etc).
