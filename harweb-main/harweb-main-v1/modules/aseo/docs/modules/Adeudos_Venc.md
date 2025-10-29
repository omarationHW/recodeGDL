# Documentación Técnica: Migración de Formulario Adeudos_Venc (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs), navegación por rutas.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## Flujo de Trabajo
1. **Carga de Tipos de Aseo**: Al cargar la página, el frontend solicita los tipos de aseo disponibles.
2. **Búsqueda de Contrato**: El usuario ingresa número de contrato y tipo de aseo, el frontend llama a `buscar_contrato_adeudos_vencidos`.
3. **Consulta de Adeudos**: Al seleccionar un contrato, el frontend llama a `get_adeudos_vencidos` para obtener los adeudos vencidos.
4. **Reporte/Resumen**: El usuario puede solicitar un resumen, que llama a `reporte_adeudos_vencidos`.
5. **Apremios**: Si se requiere, se puede consultar los apremios asociados con `get_apremios_adeudos_vencidos`.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "getTipoAseo|buscarContrato|getAdeudos|getReporte|getDiaLimite|getApremios",
      "params": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": { ... } // array o error
  }
  ```

## Stored Procedures
- Toda la lógica de negocio y reportes se implementa en stored procedures PostgreSQL.
- Los procedimientos devuelven tablas (RETURNS TABLE) para fácil consumo desde Laravel.

## Seguridad
- Validación de parámetros en el backend.
- El endpoint puede protegerse con middleware de autenticación si se requiere.

## Frontend (Vue.js)
- Cada formulario es una página independiente.
- No se usan tabs ni componentes tabulares.
- Navegación por rutas.
- Breadcrumb para navegación contextual.
- Manejo de errores y mensajes amigables.

## Backend (Laravel)
- Un solo controlador maneja todas las acciones relacionadas con Adeudos Vencidos.
- Uso de DB::select para ejecutar stored procedures.
- Manejo de errores y respuestas unificadas.

## Base de Datos
- Tablas principales: ta_16_contratos, ta_16_tipo_aseo, ta_16_pagos, ta_15_apremios, ta_16_recargos, etc.
- Todos los cálculos de recargos, multas, gastos, etc., se hacen en los stored procedures.

## Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y un nuevo stored procedure.

# Ejemplo de Flujo
1. Usuario ingresa contrato y tipo de aseo → `/api/execute` action: buscarContrato
2. Usuario consulta adeudos → `/api/execute` action: getAdeudos
3. Usuario solicita reporte → `/api/execute` action: getReporte

# Validaciones
- El frontend valida campos obligatorios antes de enviar.
- El backend valida tipos y existencia de datos.

# Errores
- Todos los errores se devuelven en `eResponse.error`.

# Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
