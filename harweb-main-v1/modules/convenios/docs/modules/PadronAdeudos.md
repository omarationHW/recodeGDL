# Documentación Técnica: Padrón de Adeudos (PadronAdeudos)

## Descripción General
Este módulo permite consultar y exportar el padrón de convenios vigentes por recaudadora, mostrando información relevante como nombre, convenio, fechas, pagos realizados, adeudos y vigencia. La migración se realizó desde Delphi a una arquitectura Laravel + Vue.js + PostgreSQL, usando un endpoint API unificado y stored procedures para la lógica de negocio.

## Arquitectura
- **Backend:** Laravel 10+ (PHP 8+), controlador centralizado (`PadronAdeudosController`)
- **Frontend:** Vue.js 3 SPA, componente de página independiente
- **Base de Datos:** PostgreSQL 13+, lógica encapsulada en stored procedures
- **API:** Endpoint único `/api/execute` con patrón eRequest/eResponse
- **Exportación:** Generación de Excel vía PhpSpreadsheet (Laravel)

## Flujo de Datos
1. El usuario accede a la página de Padrón de Adeudos.
2. El frontend consulta las recaudadoras disponibles vía `/api/execute` (`action: getRecaudadoras`).
3. El usuario selecciona una recaudadora y pulsa "Buscar".
4. El frontend envía `/api/execute` (`action: getPadronAdeudos`, `params: {rec_id}`), el backend ejecuta el stored procedure `spd_17_padronconv`.
5. Los datos se muestran en una tabla. El usuario puede exportar a Excel usando el mismo endpoint con `action: exportPadronAdeudosExcel`.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "getPadronAdeudos",
    "params": { "rec_id": 1 }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ]
  }
  ```

## Stored Procedure
- **Nombre:** `spd_17_padronconv`
- **Parámetro:** `prec` (integer, id de recaudadora)
- **Retorna:** Tabla con los campos requeridos para el padrón
- **Lógica:**
  - Filtra convenios por letras de recaudadora (`ZC1`, `ZO2`, etc.)
  - Solo convenios vigentes (`vigencia = 'A'`)
  - Calcula totales de pagos, adeudos, pagos realizados, etc.

## Seguridad
- El endpoint puede requerir autenticación JWT o session según la política del sistema.
- Validación de parámetros en backend.

## Exportación a Excel
- El backend genera el archivo Excel en memoria y lo retorna en base64 para descarga directa en el frontend.

## Consideraciones
- El frontend es una página independiente, no usa tabs ni componentes compartidos.
- El backend es desacoplado y puede ser reutilizado por otros clientes.
- El stored procedure puede ser extendido para filtros adicionales.

# Esquema de Base de Datos Relacionado
- `ta_17_conv_diverso`, `ta_17_conv_d_resto`, `ta_17_tipos`, `ta_17_subtipo_conv`, `ta_17_conv_pagos`, `ta_12_recaudadoras`

# Casos de Uso
