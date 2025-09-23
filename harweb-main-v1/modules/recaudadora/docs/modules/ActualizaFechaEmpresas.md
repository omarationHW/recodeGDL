# Documentación Técnica: Actualiza Fecha de Práctica de Empresas

## Descripción General
Este módulo permite cargar un archivo de texto con folios de empresas y actualizar en lote la fecha de práctica (`fecent`) de los folios de requerimientos de empresas en la base de datos PostgreSQL. La migración respeta la lógica original Delphi, pero modernizada para Laravel + Vue.js + PostgreSQL.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa (sin tabs)
- **Base de Datos:** PostgreSQL con stored procedure para actualización
- **API:** Todas las acciones se ejecutan vía `/api/execute` con parámetros `action` y `params`

## Flujo de Trabajo
1. **Carga de Archivo:** El usuario selecciona un archivo de texto plano con los folios a procesar.
2. **Parseo:** El archivo se parsea y se muestra una tabla con los folios y sus datos.
3. **Actualización:** El usuario puede actualizar individualmente o en lote la fecha de práctica de los folios seleccionados.
4. **Resultados:** Se muestran los folios procesados, correctos, incorrectos y los errores encontrados.

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Métodos soportados:**
  - `parse_file`: Parsea el archivo de texto y devuelve los folios
  - `get_empresa_info`: Obtiene información de la empresa por folio/cuenta
  - `actualiza_fechas`: Actualiza la fecha de práctica de uno o varios folios

### Ejemplo de Request
```json
{
  "action": "actualiza_fechas",
  "params": {
    "folios": [
      { "clave_cuenta": 12345, "folio": 678, "anio_folio": 2023, "fecha_practica": "2024-06-01" }
    ]
  }
}
```

### Ejemplo de Response
```json
{
  "success": true,
  "message": "Actualización finalizada",
  "data": {
    "aplicados": 1,
    "pendientes": 0,
    "errores": []
  }
}
```

## Stored Procedure
- **sp_actualiza_fecha_practica**: Actualiza el campo `fecent` en la tabla `reqpredial` para el folio indicado.

## Seguridad
- Todas las acciones requieren autenticación Laravel (middleware estándar).
- Validación de parámetros en backend.

## Consideraciones
- El archivo de texto debe estar delimitado por `|` y contener los campos en el orden esperado.
- El proceso es idempotente: si un folio no existe, se reporta como error pero no detiene el proceso.
- El frontend permite ver el resultado de cada folio y los errores detallados.

## Extensibilidad
- Se pueden agregar más stored procedures para otras operaciones relacionadas con empresas.
- El endpoint `/api/execute` puede ser extendido para otras acciones del sistema.
