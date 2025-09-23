# Documentación Técnica: Migración de Formulario sfrm_valet_paso (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite al usuario cargar un archivo (CSV o XLSX) con datos de valet, visualizar una vista previa y procesar los datos para insertarlos en la base de datos PostgreSQL. La migración se realizó desde un formulario Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (almacenamiento y lógica de negocio).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de procesamiento en stored procedures.

## 3. Flujo de Trabajo
1. El usuario selecciona y sube un archivo desde la interfaz.
2. El backend almacena el archivo y genera una vista previa (primeras filas).
3. El usuario confirma y ejecuta el procesamiento de datos.
4. El backend llama al stored procedure que procesa el archivo e inserta los datos.
5. Se muestra un resumen del resultado al usuario.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:** Objeto `eRequest` con la acción a ejecutar y parámetros necesarios.
- **Salida:** Objeto `eResponse` con éxito, mensaje y datos.

### Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "process_valet_data",
    "file_path": "valet_uploads/archivo.csv"
  }
}
```

## 5. Stored Procedure
- **Nombre:** process_valet_file
- **Función:** Procesa el archivo CSV y lo inserta en la tabla `valet_data`.
- **Retorno:** Resumen por fila (OK/ERROR).
- **Nota:** Ajustar los nombres de columnas según la estructura real de los datos.

## 6. Seguridad
- Validación de archivos (tipo y tamaño).
- Manejo de errores y mensajes claros al usuario.
- El endpoint está protegido por autenticación (agregar middleware según sea necesario).

## 7. Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- El frontend puede adaptarse fácilmente a nuevos formularios o flujos.

## 8. Consideraciones
- El procesamiento de archivos grandes puede requerir optimización (procesamiento en background, chunking, etc).
- Para archivos XLSX, se recomienda usar una librería PHP como PhpSpreadsheet.
- El stored procedure debe ajustarse a la estructura real de los datos de valet.
